package com.smartcalendar.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

import com.smartcalendar.models.User;
import com.smartcalendar.utils.DatabaseUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class WebAuthnServlet extends HttpServlet {
    private static final SecureRandom RANDOM = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String path = req.getPathInfo();
        if (path == null) path = "";
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        switch (path) {
            case "/challenge": {
                byte[] bytes = new byte[32];
                RANDOM.nextBytes(bytes);
                String challenge = base64Url(bytes);
                HttpSession s = req.getSession(true);
                s.setAttribute("webauthn_challenge", challenge);
                String rpId = req.getServerName();
                out.write("{\"challenge\":\"" + challenge + "\",\"rpId\":\"" + rpId + "\"}");
                break;
            }
            case "/allow": {
                List<String> ids = getCredentialIds(user.getUserId());
                out.write("[");
                for (int i = 0; i < ids.size(); i++) {
                    if (i > 0) out.write(",");
                    out.write("\"" + escapeJson(ids.get(i)) + "\"");
                }
                out.write("]");
                break;
            }
            default: {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String path = req.getPathInfo();
        if (path == null) path = "";
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

    String body = req.getReader().lines().reduce("", (a, b) -> a + b);
    String credentialId = extractField(body, "credentialId");
    String latStr = extractField(body, "latitude");
    String lonStr = extractField(body, "longitude");
    Double latitude = latStr != null ? parseDouble(latStr) : null;
    Double longitude = lonStr != null ? parseDouble(lonStr) : null;

        switch (path) {
            case "/register": {
                if (!withinAllowedWindow()) {
                    resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    logAttempt(user.getUserId(), "register", latitude, longitude, false);
                    out.write("{\"ok\":false,\"error\":\"Face ID allowed only Mon & Wed 08:00–12:00 and 12:00–17:00\"}");
                    return;
                }
                if (credentialId == null || credentialId.isEmpty()) {
                    resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.write("{\"ok\":false,\"error\":\"Missing credentialId\"}");
                    return;
                }
                boolean saved = saveCredential(user.getUserId(), credentialId);
                logAttempt(user.getUserId(), "register", latitude, longitude, saved);
                out.write("{\"ok\":" + (saved ? "true" : "false") + "}");
                break;
            }
            case "/assert": {
                if (!withinAllowedWindow()) {
                    resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    logAttempt(user.getUserId(), "verify", latitude, longitude, false);
                    out.write("{\"ok\":false,\"error\":\"Face ID allowed only Mon & Wed 08:00–12:00 and 12:00–17:00\"}");
                    return;
                }
                String challenge = (String) session.getAttribute("webauthn_challenge");
                if (challenge == null) {
                    resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    logAttempt(user.getUserId(), "verify", latitude, longitude, false);
                    out.write("{\"ok\":false,\"error\":\"No challenge\"}");
                    return;
                }
                boolean exists = hasCredential(user.getUserId(), credentialId);
                if (exists) {
                    session.setAttribute("faceIdVerified", true);
                    logAttempt(user.getUserId(), "verify", latitude, longitude, true);
                    out.write("{\"ok\":true}");
                } else {
                    logAttempt(user.getUserId(), "verify", latitude, longitude, false);
                    out.write("{\"ok\":false}");
                }
                break;
            }
            default: {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            }
        }
    }

    private String base64Url(byte[] bytes) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String escapeJson(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    // naive JSON field extractor for {"credentialId":"..."}
    private String extractField(String json, String field) {
        String key = "\"" + field + "\":";
        int idx = json.indexOf(key);
        if (idx < 0) return null;
        int start = json.indexOf('"', idx + key.length());
        if (start < 0) return null;
        int end = json.indexOf('"', start + 1);
        if (end < 0) return null;
        return json.substring(start + 1, end);
    }

    private boolean saveCredential(int userId, String credentialId) {
        String sql = "INSERT INTO webauthn_credentials (user_id, credential_id) VALUES (?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setString(2, credentialId);
            stmt.executeUpdate();
            return true;
        } catch (SQLException e) {
            // likely duplicate or DB error
            return false;
        }
    }

    private boolean hasCredential(int userId, String credentialId) {
        String sql = "SELECT 1 FROM webauthn_credentials WHERE user_id = ? AND credential_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setString(2, credentialId);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            return false;
        }
    }

    private List<String> getCredentialIds(int userId) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT credential_id FROM webauthn_credentials WHERE user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) list.add(rs.getString(1));
        } catch (SQLException ignored) {}
        return list;
    }

    private Double parseDouble(String s) {
        try {
            return Double.parseDouble(s);
        } catch (Exception e) {
            return null;
        }
    }

    private void logAttempt(int userId, String action, Double latitude, Double longitude, boolean success) {
        String sql = "INSERT INTO faceid_attempts (user_id, action, latitude, longitude, success) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setString(2, action);
            if (latitude == null) stmt.setNull(3, java.sql.Types.DOUBLE); else stmt.setDouble(3, latitude);
            if (longitude == null) stmt.setNull(4, java.sql.Types.DOUBLE); else stmt.setDouble(4, longitude);
            stmt.setBoolean(5, success);
            stmt.executeUpdate();
        } catch (SQLException ignored) {}
    }

    private boolean withinAllowedWindow() {
        LocalDateTime now = LocalDateTime.now();
        DayOfWeek dow = now.getDayOfWeek();
        if (!(dow == DayOfWeek.MONDAY || dow == DayOfWeek.WEDNESDAY)) return false;
        LocalTime t = now.toLocalTime();
        LocalTime start1 = LocalTime.of(8, 0);
        LocalTime end1 = LocalTime.of(12, 0);
        LocalTime start2 = LocalTime.of(12, 0);
        LocalTime end2 = LocalTime.of(17, 0);
        boolean inFirst = !t.isBefore(start1) && t.isBefore(end1);
        boolean inSecond = !t.isBefore(start2) && t.isBefore(end2);
        return inFirst || inSecond;
    }
}

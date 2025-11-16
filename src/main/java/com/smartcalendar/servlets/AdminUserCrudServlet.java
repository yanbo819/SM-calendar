package com.smartcalendar.servlets;

import com.smartcalendar.models.User;
import com.smartcalendar.utils.DatabaseUtil;
import com.smartcalendar.utils.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet(urlPatterns = {"/admin-user-crud"})
public class AdminUserCrudServlet extends HttpServlet {
    private boolean isAdmin(User user) {
        return user != null && "admin".equalsIgnoreCase(user.getRole());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User current = session != null ? (User) session.getAttribute("user") : null;
        if (!isAdmin(current)) { resp.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }

        String action = req.getParameter("action");
        if (action == null) { resp.sendRedirect("admin-users?error=Missing+action"); return; }

        try (Connection conn = DatabaseUtil.getConnection()) {
            switch (action) {
                case "create": {
                    String username = param(req, "username");
                    String fullName = param(req, "fullName");
                    String email = param(req, "email");
                    String phone = param(req, "phone");
                    String password = param(req, "password");
                    String role = param(req, "role");
                    if (username == null || fullName == null || email == null || password == null) {
                        resp.sendRedirect("admin-users?error=Missing+required+fields"); return;
                    }
                    if (exists(conn, "SELECT 1 FROM users WHERE username = ?", username) || exists(conn, "SELECT 1 FROM users WHERE LOWER(email) = LOWER(?)", email)) {
                        resp.sendRedirect("admin-users?error=Username+or+email+already+exists"); return;
                    }
                    String pwHash = PasswordUtil.hashPassword(password);
                    try (PreparedStatement ps = conn.prepareStatement("INSERT INTO users (username, email, phone_number, full_name, password_hash, role, preferred_language, is_active) VALUES (?,?,?,?,?, ?, 'en', TRUE)")) {
                        ps.setString(1, username);
                        ps.setString(2, email);
                        ps.setString(3, phone);
                        ps.setString(4, fullName);
                        ps.setString(5, pwHash);
                        ps.setString(6, (role != null && role.equalsIgnoreCase("admin")) ? "admin" : "user");
                        ps.executeUpdate();
                    }
                    resp.sendRedirect("admin-users?success=Created");
                    return;
                }
                case "update": {
                    int userId = Integer.parseInt(req.getParameter("userId"));
                    String fullName = param(req, "fullName");
                    String email = param(req, "email");
                    String phone = param(req, "phone");
                    String role = param(req, "role");
                    boolean active = "on".equals(req.getParameter("active")) || "true".equalsIgnoreCase(req.getParameter("active"));
                    String password = param(req, "password");

                    // Basic update
                    try (PreparedStatement ps = conn.prepareStatement("UPDATE users SET full_name=?, email=?, phone_number=?, role=?, is_active=?, updated_at=CURRENT_TIMESTAMP WHERE user_id=?")) {
                        ps.setString(1, fullName);
                        ps.setString(2, email);
                        ps.setString(3, phone);
                        ps.setString(4, (role != null && role.equalsIgnoreCase("admin")) ? "admin" : "user");
                        ps.setBoolean(5, active);
                        ps.setInt(6, userId);
                        ps.executeUpdate();
                    }
                    if (password != null && !password.isBlank()) {
                        String pwHash = PasswordUtil.hashPassword(password);
                        try (PreparedStatement ps = conn.prepareStatement("UPDATE users SET password_hash=?, updated_at=CURRENT_TIMESTAMP WHERE user_id=?")) {
                            ps.setString(1, pwHash);
                            ps.setInt(2, userId);
                            ps.executeUpdate();
                        }
                    }
                    resp.sendRedirect("admin-user?id=" + userId + "&success=Updated");
                    return;
                }
                case "delete": {
                    int userId = Integer.parseInt(req.getParameter("userId"));
                    try (PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE user_id=?")) {
                        ps.setInt(1, userId);
                        ps.executeUpdate();
                    }
                    resp.sendRedirect("admin-users?success=Deleted");
                    return;
                }
                default:
                    resp.sendRedirect("admin-users?error=Unknown+action");
                    return;
            }
        } catch (SQLException | NumberFormatException e) {
            resp.sendRedirect("admin-users?error=Operation+failed");
        }
    }

    private boolean exists(Connection conn, String sql, String value) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, value);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    private String param(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v != null && !v.isBlank() ? v.trim() : null;
    }
}

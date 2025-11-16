package com.smartcalendar.servlets;

import com.smartcalendar.models.User;
import com.smartcalendar.utils.DatabaseUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;
import java.text.SimpleDateFormat;

/**
 * Servlet for publishing admin (global) events. Global events are inserted with the admin's user_id
 * and are visible read-only to all users (enforced in JSP by userId check).
 * Admin is identified by hard-coded email 'admin@smartcalendar.com'.
 */
@WebServlet(urlPatterns = {"/admin-event"})
public class AdminEventServlet extends HttpServlet {
    private static final String ADMIN_CATEGORY_NAME = "Admin Announcement";
    private static final String ADMIN_CATEGORY_COLOR = "#ff9800"; // orange

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null || !isAdmin(user)) {
            resp.sendRedirect("login.jsp");
            return;
        }
    req.getRequestDispatcher("/admin-event.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null || !isAdmin(user)) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String title = param(req, "title");
        String eventDateStr = param(req, "eventDate");
        String eventTimeStr = param(req, "eventTime");
        String durationStr = param(req, "duration");
        String location = param(req, "location");
        String description = param(req, "description");
        String reminderStr = param(req, "reminder");

    if (title == null || title.isBlank() || eventDateStr == null || eventTimeStr == null) {
            req.setAttribute("errorMessage", "Missing required fields");
            req.getRequestDispatcher("/admin-event.jsp").forward(req, resp);
            return;
        }

        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);
            int categoryId = getOrCreateAdminCategory(conn);

            SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat tf = new SimpleDateFormat("HH:mm");
            Date sqlDate = new Date(df.parse(eventDateStr).getTime());
            Time sqlTime = new Time(tf.parse(eventTimeStr).getTime());
            int duration = 60;
            try { if (durationStr != null && !durationStr.isBlank()) duration = Integer.parseInt(durationStr.trim()); } catch (Exception ignored) {}
            int reminder = 15;
            try { if (reminderStr != null && !reminderStr.isBlank()) reminder = Integer.parseInt(reminderStr.trim()); } catch (Exception ignored) {}

        PreparedStatement stmt = conn.prepareStatement(
                    "INSERT INTO events (user_id, category_id, title, description, event_date, event_time, duration_minutes, location, notes, reminder_minutes_before, is_active) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, TRUE)");
            stmt.setInt(1, user.getUserId());
            stmt.setInt(2, categoryId);
            stmt.setString(3, title.trim());
            stmt.setString(4, description != null ? description.trim() : null);
            stmt.setDate(5, sqlDate);
            stmt.setTime(6, sqlTime);
            stmt.setInt(7, duration);
            stmt.setString(8, location != null ? location.trim() : null);
            stmt.setString(9, null); // notes not supported in admin form yet
            stmt.setInt(10, reminder);
            stmt.executeUpdate();

            // Notify all active users except admin
            try (PreparedStatement selUsers = conn.prepareStatement("SELECT user_id FROM users WHERE is_active = TRUE AND user_id <> ?");
                 PreparedStatement insNotif = conn.prepareStatement("INSERT INTO notifications (event_id, user_id, message, notification_time, is_sent) VALUES (?, ?, ?, CURRENT_TIMESTAMP, FALSE)")) {
                selUsers.setInt(1, user.getUserId());
                ResultSet usersRs = selUsers.executeQuery();
                String msg = "New admin event: " + title + " on " + df.format(sqlDate) + (eventTimeStr != null ? (" at " + eventTimeStr) : "");
                // Retrieve last inserted event id for admin
                int eventId = -1;
                try (PreparedStatement lastEvt = conn.prepareStatement("SELECT MAX(event_id) FROM events WHERE user_id = ?")) {
                    lastEvt.setInt(1, user.getUserId());
                    ResultSet er = lastEvt.executeQuery();
                    if (er.next()) eventId = er.getInt(1);
                }
                while (usersRs.next()) {
                    int uid = usersRs.getInt(1);
                    insNotif.setInt(1, eventId);
                    insNotif.setInt(2, uid);
                    insNotif.setString(3, msg);
                    insNotif.addBatch();
                }
                insNotif.executeBatch();
            }
            conn.commit();
        } catch (Exception e) {
            req.setAttribute("errorMessage", "Failed to publish admin event: " + e.getMessage());
            req.getRequestDispatcher("/admin-event.jsp").forward(req, resp);
            return;
        }

        resp.sendRedirect("dashboard.jsp?success=Admin event published");
    }

    private boolean isAdmin(User user) {
        return user != null && "admin".equalsIgnoreCase(user.getRole());
    }

    private int getOrCreateAdminCategory(Connection conn) throws SQLException {
        PreparedStatement sel = conn.prepareStatement("SELECT category_id FROM categories WHERE category_name = ?");
        sel.setString(1, ADMIN_CATEGORY_NAME);
        ResultSet rs = sel.executeQuery();
        if (rs.next()) return rs.getInt(1);
        PreparedStatement ins = conn.prepareStatement("INSERT INTO categories (category_name, category_color) VALUES (?, ?)", PreparedStatement.RETURN_GENERATED_KEYS);
        ins.setString(1, ADMIN_CATEGORY_NAME);
        ins.setString(2, ADMIN_CATEGORY_COLOR);
        ins.executeUpdate();
        ResultSet keys = ins.getGeneratedKeys();
        if (keys.next()) return keys.getInt(1);
        throw new SQLException("Failed to create admin category");
    }

    private String param(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v != null ? v : null;
    }
}

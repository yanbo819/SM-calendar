package com.smartcalendar.servlets;

import com.smartcalendar.models.User;
import com.smartcalendar.models.Event;
import com.smartcalendar.utils.DatabaseUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = {"/admin-user"})
public class AdminUserDetailServlet extends HttpServlet {
    private boolean isAdmin(User user) {
        if (user == null) return false;
        return "admin".equalsIgnoreCase(user.getRole());
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (!isAdmin(user)) { resp.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }

        String idStr = req.getParameter("id");
        if (idStr == null) { resp.sendRedirect("admin-users?error=Missing+user+id"); return; }
        int uid = Integer.parseInt(idStr);

        User target = null;
        List<Event> events = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement("SELECT user_id, username, email, phone_number, full_name, role, preferred_language, is_active, created_at, updated_at FROM users WHERE user_id=?")) {
                ps.setInt(1, uid);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        target = new User();
                        target.setUserId(rs.getInt("user_id"));
                        target.setUsername(rs.getString("username"));
                        target.setEmail(rs.getString("email"));
                        target.setPhoneNumber(rs.getString("phone_number"));
                        target.setFullName(rs.getString("full_name"));
                        target.setRole(rs.getString("role"));
                        target.setPreferredLanguage(rs.getString("preferred_language"));
                        target.setActive(rs.getBoolean("is_active"));
                        target.setCreatedAt(rs.getTimestamp("created_at"));
                        target.setUpdatedAt(rs.getTimestamp("updated_at"));
                    }
                }
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT event_id, user_id, title, event_date, event_time, duration_minutes, location, reminder_minutes_before FROM events WHERE user_id=? AND is_active=TRUE ORDER BY event_date, event_time")) {
                ps.setInt(1, uid);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Event e = new Event();
                        e.setEventId(rs.getInt("event_id"));
                        e.setUserId(rs.getInt("user_id"));
                        e.setTitle(rs.getString("title"));
                        e.setEventDate(rs.getDate("event_date"));
                        e.setEventTime(rs.getTime("event_time"));
                        e.setDurationMinutes(rs.getInt("duration_minutes"));
                        e.setLocation(rs.getString("location"));
                        e.setReminderMinutesBefore(rs.getInt("reminder_minutes_before"));
                        events.add(e);
                    }
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Failed to load user detail", e);
        }
        if (target == null) { resp.sendRedirect("admin-users?error=User+not+found"); return; }
    req.setAttribute("target", target);
    req.setAttribute("events", events);
    req.getRequestDispatcher("/admin-user-detail.jsp").forward(req, resp);
    }
}

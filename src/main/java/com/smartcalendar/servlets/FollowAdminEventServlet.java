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

@WebServlet(urlPatterns = {"/follow-admin-event"})
public class FollowAdminEventServlet extends HttpServlet {
    private static final String ADMIN_EMAIL = "admin@smartcalendar.com";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null) { resp.sendRedirect("login.jsp"); return; }

        String idStr = req.getParameter("id");
        if (idStr == null) { resp.sendRedirect("events.jsp?error=Missing+event+id"); return; }
        int eventId;
        try { eventId = Integer.parseInt(idStr); } catch (NumberFormatException e) { resp.sendRedirect("events.jsp?error=Invalid+event+id"); return; }

        try (Connection conn = DatabaseUtil.getConnection()) {
            // Verify admin event
            PreparedStatement sel = conn.prepareStatement("SELECT e.title, e.description, e.event_date, e.event_time, e.duration_minutes, e.location, e.reminder_minutes_before FROM events e JOIN users u ON e.user_id = u.user_id WHERE e.event_id = ? AND (u.email = ? OR u.email = 'admin')");
            sel.setInt(1, eventId);
            sel.setString(2, ADMIN_EMAIL);
            ResultSet rs = sel.executeQuery();
            if (!rs.next()) { resp.sendRedirect("events.jsp?error=Admin+event+not+found"); return; }

            String title = rs.getString("title");
            Date date = rs.getDate("event_date");
            Time time = rs.getTime("event_time");
            int duration = rs.getInt("duration_minutes");
            String location = rs.getString("location");
            String description = rs.getString("description");
            int reminder = rs.getInt("reminder_minutes_before");

            // Prevent duplicate (same user, title, date, time)
            PreparedStatement dup = conn.prepareStatement("SELECT event_id FROM events WHERE user_id = ? AND title = ? AND event_date = ? AND event_time = ? AND is_active = TRUE");
            dup.setInt(1, user.getUserId());
            dup.setString(2, title);
            dup.setDate(3, date);
            dup.setTime(4, time);
            ResultSet dupRs = dup.executeQuery();
            if (dupRs.next()) {
                resp.sendRedirect("events.jsp?info=Already+followed");
                return;
            }

            // Insert clone for user (no description modification)
            PreparedStatement ins = conn.prepareStatement("INSERT INTO events (user_id, title, description, event_date, event_time, duration_minutes, location, reminder_minutes_before, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, TRUE)");
            ins.setInt(1, user.getUserId());
            ins.setString(2, title);
            ins.setString(3, description);
            ins.setDate(4, date);
            ins.setTime(5, time);
            ins.setInt(6, duration);
            ins.setString(7, location);
            ins.setInt(8, reminder);
            ins.executeUpdate();
        } catch (SQLException e) {
            resp.sendRedirect("events.jsp?error=Failed+to+follow+event");
            return;
        }

        resp.sendRedirect("events.jsp?success=Admin+event+added+to+your+events");
    }
}

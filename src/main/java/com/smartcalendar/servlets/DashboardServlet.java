package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.smartcalendar.models.Event;
import com.smartcalendar.models.User;
import com.smartcalendar.utils.DatabaseUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null) { resp.sendRedirect("login.jsp"); return; }

        int todayEvents = 0;
        int weekEvents = 0;
        int totalEvents = 0;
        List<Event> upcomingEvents = new ArrayList<>();
        int pendingNotifications = 0;

        try (Connection conn = DatabaseUtil.getConnection()) {
            // Counts
            try (PreparedStatement psToday = conn.prepareStatement(
                    "SELECT COUNT(*) FROM events WHERE user_id = ? AND event_date = CURRENT_DATE AND is_active = TRUE")) {
                psToday.setInt(1, user.getUserId());
                ResultSet rs = psToday.executeQuery();
                if (rs.next()) todayEvents = rs.getInt(1);
            }
            try (PreparedStatement psWeek = conn.prepareStatement(
                    "SELECT COUNT(*) FROM events WHERE user_id = ? AND event_date BETWEEN CURRENT_DATE AND DATEADD('DAY', 7, CURRENT_DATE) AND is_active = TRUE")) {
                psWeek.setInt(1, user.getUserId());
                ResultSet rs = psWeek.executeQuery();
                if (rs.next()) weekEvents = rs.getInt(1);
            }
            try (PreparedStatement psTotal = conn.prepareStatement(
                    "SELECT COUNT(*) FROM events WHERE user_id = ? AND is_active = TRUE")) {
                psTotal.setInt(1, user.getUserId());
                ResultSet rs = psTotal.executeQuery();
                if (rs.next()) totalEvents = rs.getInt(1);
            }

            // Pending notifications
            try (PreparedStatement psNotif = conn.prepareStatement(
                    "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_sent = FALSE")) {
                psNotif.setInt(1, user.getUserId());
                ResultSet rs = psNotif.executeQuery();
                if (rs.next()) pendingNotifications = rs.getInt(1);
            }

            // Upcoming events (include admin published)
            try (PreparedStatement psUpcoming = conn.prepareStatement(
                    "SELECT e.event_id, e.user_id, e.title, e.event_date, e.event_time, e.location, " +
                            "c.category_name, c.category_color, s.subject_name FROM events e " +
                            "LEFT JOIN categories c ON e.category_id = c.category_id " +
                            "LEFT JOIN subjects s ON e.subject_id = s.subject_id " +
                            "WHERE e.event_date >= CURRENT_DATE AND e.is_active = TRUE AND (e.user_id = ? OR e.user_id IN (SELECT user_id FROM users WHERE role='admin')) " +
                            "ORDER BY e.event_date ASC, e.event_time ASC LIMIT 5")) {
                psUpcoming.setInt(1, user.getUserId());
                ResultSet rs = psUpcoming.executeQuery();
                while (rs.next()) {
                    Event ev = new Event();
                    ev.setEventId(rs.getInt("event_id"));
                    ev.setUserId(rs.getInt("user_id"));
                    ev.setTitle(rs.getString("title"));
                    ev.setEventDate(rs.getDate("event_date"));
                    ev.setEventTime(rs.getTime("event_time"));
                    ev.setLocation(rs.getString("location"));
                    ev.setCategoryName(rs.getString("category_name"));
                    ev.setCategoryColor(rs.getString("category_color"));
                    ev.setSubjectName(rs.getString("subject_name"));
                    upcomingEvents.add(ev);
                }
            }
        } catch (SQLException ex) {
            // Log minimal error to stderr; page will still render with zeros
            System.err.println("[DashboardServlet] DB error: " + ex.getMessage());
        }

        req.setAttribute("todayEvents", todayEvents);
        req.setAttribute("weekEvents", weekEvents);
        req.setAttribute("totalEvents", totalEvents);
        req.setAttribute("upcomingEvents", upcomingEvents);
        req.setAttribute("pendingNotifications", pendingNotifications);
        req.getRequestDispatcher("/dashboard.jsp").forward(req, resp);
    }
}

package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Time;

import com.smartcalendar.models.User;
import com.smartcalendar.utils.DatabaseUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Servlet to update an event
 */
public class UpdateEventServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        if (user == null) { response.sendRedirect("login.jsp"); return; }

        String id = request.getParameter("id");
        String title = request.getParameter("title");
        String eventDate = request.getParameter("eventDate");
        String eventTime = request.getParameter("eventTime");
        String location = request.getParameter("location");
        String description = request.getParameter("description");
        String reminderStr = request.getParameter("reminderMinutes");
        if (id == null || title == null || eventDate == null || eventTime == null) { response.sendRedirect("events.jsp"); return; }
        int reminder = 15;
        try { if (reminderStr != null && !reminderStr.trim().isEmpty()) reminder = Integer.parseInt(reminderStr.trim()); } catch (Exception ignored) {}
        switch (reminder) {
            case 5: case 15: case 30: case 60: case 1440: break;
            default: reminder = 15;
        }

        try (Connection conn = DatabaseUtil.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
                "UPDATE events SET title=?, event_date=?, event_time=?, location=?, description=?, reminder_minutes_before=? WHERE event_id=? AND user_id=?"
            );
            stmt.setString(1, title.trim());
            stmt.setDate(2, Date.valueOf(eventDate));
            stmt.setTime(3, Time.valueOf(eventTime + ":00"));
            stmt.setString(4, location);
            stmt.setString(5, description);
            stmt.setInt(6, reminder);
            stmt.setInt(7, Integer.parseInt(id));
            stmt.setInt(8, user.getUserId());
            stmt.executeUpdate();
        } catch (SQLException e) {
            // log
        }
        response.sendRedirect("events.jsp");
    }
}

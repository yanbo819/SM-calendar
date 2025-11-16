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

@WebServlet(urlPatterns = {"/admin-update-user-event"})
public class AdminUpdateUserEventServlet extends HttpServlet {
    private boolean isAdmin(User user) {
        if (user == null) return false;
        String email = user.getEmail();
        String full = user.getFullName();
        return (email != null && email.equals("admin@smartcalendar.com")) || (full != null && full.equalsIgnoreCase("admin"));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (!isAdmin(user)) { resp.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }

        String idStr = req.getParameter("eventId");
        String dateStr = req.getParameter("eventDate"); // yyyy-MM-dd
        String timeStr = req.getParameter("eventTime"); // HH:mm
        String redirectUserId = req.getParameter("userId");
        if (idStr == null || dateStr == null || timeStr == null || redirectUserId == null) { resp.sendRedirect("admin-users?error=Missing+params"); return; }

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE events SET event_date=?, event_time=?, updated_at=CURRENT_TIMESTAMP WHERE event_id=?")) {
            ps.setDate(1, Date.valueOf(dateStr));
            ps.setTime(2, Time.valueOf(timeStr + ":00"));
            ps.setInt(3, Integer.parseInt(idStr));
            ps.executeUpdate();
        } catch (SQLException | IllegalArgumentException e) {
            resp.sendRedirect("admin-user?id=" + redirectUserId + "&error=Update+failed");
            return;
        }
        resp.sendRedirect("admin-user?id=" + redirectUserId + "&success=Updated");
    }
}

package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import com.smartcalendar.models.User;
import com.smartcalendar.utils.DatabaseUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/delete-event"})
public class DeleteEventServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null) { resp.sendRedirect("login.jsp"); return; }

        String idStr = req.getParameter("id");
        int eventId;
        try { eventId = Integer.parseInt(idStr); } catch (Exception e) { resp.sendRedirect("events.jsp?error=invalidId"); return; }

        try (Connection conn = DatabaseUtil.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement("UPDATE events SET is_active=FALSE WHERE event_id=? AND user_id=?");
            stmt.setInt(1, eventId);
            stmt.setInt(2, user.getUserId());
            stmt.executeUpdate();
        } catch (SQLException e) {
            resp.sendRedirect("events.jsp?error=deleteFailed");
            return;
        }
        resp.sendRedirect("events.jsp?success=deleted");
    }
}

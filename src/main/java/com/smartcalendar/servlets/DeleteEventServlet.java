package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import com.smartcalendar.models.User;
import com.smartcalendar.utils.DatabaseUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Servlet to delete an event belonging to the logged-in user
 */
public class DeleteEventServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String id = request.getParameter("id");
        if (id == null) {
            response.sendRedirect("events.jsp");
            return;
        }
        try (Connection conn = DatabaseUtil.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement("DELETE FROM events WHERE event_id = ? AND user_id = ?");
            stmt.setInt(1, Integer.parseInt(id));
            stmt.setInt(2, user.getUserId());
            stmt.executeUpdate();
        } catch (SQLException e) {
            // log
        }
        response.sendRedirect("events.jsp");
    }
}

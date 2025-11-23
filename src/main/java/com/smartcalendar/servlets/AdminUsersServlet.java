package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.smartcalendar.models.User;
import com.smartcalendar.utils.DatabaseUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/admin-users"})
public class AdminUsersServlet extends HttpServlet {
    private boolean isAdmin(User user) {
        if (user == null) return false;
        return "admin".equalsIgnoreCase(user.getRole());
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (!isAdmin(user)) { resp.sendRedirect("dashboard?error=Not+authorized"); return; }
        List<User> users = new ArrayList<>();
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            if (conn == null) {
                req.setAttribute("loadError", "Could not load users list.");
            } else {
                try (PreparedStatement ps = conn.prepareStatement("SELECT user_id, username, email, phone_number, full_name, role, preferred_language, is_active, created_at, updated_at FROM users ORDER BY full_name");
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        User u = new User();
                        u.setUserId(rs.getInt("user_id"));
                        u.setUsername(rs.getString("username"));
                        u.setEmail(rs.getString("email"));
                        u.setPhoneNumber(rs.getString("phone_number"));
                        u.setFullName(rs.getString("full_name"));
                        u.setRole(rs.getString("role"));
                        u.setPreferredLanguage(rs.getString("preferred_language"));
                        u.setActive(rs.getBoolean("is_active"));
                        u.setCreatedAt(rs.getTimestamp("created_at"));
                        u.setUpdatedAt(rs.getTimestamp("updated_at"));
                        users.add(u);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[AdminUsersServlet] Failed to load users: " + e.getMessage());
            req.setAttribute("loadError", "Could not load users list.");
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
        req.setAttribute("users", users);
        req.getRequestDispatcher("/admin-users.jsp").forward(req, resp);
    }
}

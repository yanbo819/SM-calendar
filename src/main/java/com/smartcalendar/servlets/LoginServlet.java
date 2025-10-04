package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.smartcalendar.models.User;
import com.smartcalendar.utils.DatabaseUtil;
import com.smartcalendar.utils.PasswordUtil;

/**
 * Servlet for handling user login
 */
public class LoginServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Check if user is already logged in
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        
        // Forward to login page
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
    String username = request.getParameter("username");
    String password = request.getParameter("password");
        
        // Check for demo admin credentials first
        if ("admin".equals(username) && "admin".equals(password)) {
            // Create admin user object
            User adminUser = new User();
            adminUser.setUserId(1);
            adminUser.setEmail("admin@smartcalendar.com");
            adminUser.setFullName("Administrator");
            adminUser.setPreferredLanguage("en");
            
            // Create session
            HttpSession session = request.getSession(true);
            session.setAttribute("user", adminUser);
            session.setAttribute("userId", adminUser.getUserId());
            session.setAttribute("userLanguage", "en");
            session.setMaxInactiveInterval(30 * 60); // 30 minutes
            
            // Redirect to dashboard
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
            return;
        }
        
        // Validate input
        String errorMessage = null;
        if (username != null && !username.trim().isEmpty() && password != null && !password.trim().isEmpty()) {
            // Authenticate user from database
            User user = authenticateUser(username.trim(), password);
            if (user != null) {
                // Create session
                HttpSession session = request.getSession(true);
                session.setAttribute("user", user);
                session.setAttribute("userId", user.getUserId());
                session.setAttribute("userLanguage", "en");
                session.setMaxInactiveInterval(30 * 60); // 30 minutes
                
                // Redirect to dashboard
                response.sendRedirect("dashboard.jsp");
                return;
            } else {
                errorMessage = "Invalid username or password";
            }
        } else if (username == null || username.trim().isEmpty()) {
            errorMessage = "Username is required";
        } else {
            errorMessage = "Password is required";
        }
        
        // If we reach here, there was an error
        request.setAttribute("errorMessage", errorMessage);
        request.setAttribute("username", username); // Keep the entered username
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
    
    /**
     * Authenticate user with username and password
     * @param username User username or email
     * @param password User password
     * @return User object if authentication successful, null otherwise
     */
    private User authenticateUser(String username, String password) {
    String sql = "SELECT user_id, email, phone_number, full_name, password_hash, " +
            "preferred_language, created_at, updated_at, is_active " +
            "FROM users WHERE (username = ? OR LOWER(email) = LOWER(?)) AND is_active = TRUE";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            stmt.setString(2, username);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                String storedPasswordHash = rs.getString("password_hash");
                
                // Verify password
                if (PasswordUtil.verifyPassword(password, storedPasswordHash)) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setEmail(rs.getString("email"));
                    user.setPhoneNumber(rs.getString("phone_number"));
                    user.setFullName(rs.getString("full_name"));
                    user.setPasswordHash(storedPasswordHash);
                    user.setPreferredLanguage(rs.getString("preferred_language"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                    user.setUpdatedAt(rs.getTimestamp("updated_at"));
                    user.setActive(rs.getBoolean("is_active"));
                    
                    return user;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error authenticating user: " + e.getMessage());
        }
        
        return null;
    }
}
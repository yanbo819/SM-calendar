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
import jakarta.servlet.annotation.WebServlet;

// Servlet for handling user login
 
@WebServlet(urlPatterns = {"/login"})
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
        // Preserve selected portal (user/admin)
        String portal = request.getParameter("portal");
        if (portal != null) request.setAttribute("portal", portal);
        // Forward to login page
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String portal = request.getParameter("portal"); // 'user' or 'admin'
    if (portal == null || portal.isBlank()) portal = "user";
        
        // Check for demo admin credentials first
        if ("admin".equals(username) && "admin".equals(password)) {
            if (!"admin".equalsIgnoreCase(portal)) {
                request.setAttribute("errorMessage", "Use the Admin Login to sign in as admin.");
                request.setAttribute("username", username);
                request.setAttribute("portal", portal);
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }
            // Ensure admin user exists in DB (by email or username)
            User adminUser = ensureAdminUser();
            HttpSession session = request.getSession(true);
            session.setAttribute("user", adminUser);
            session.setAttribute("userId", adminUser.getUserId());
            session.setAttribute("userLanguage", adminUser.getPreferredLanguage() != null ? adminUser.getPreferredLanguage() : "en");
            session.setMaxInactiveInterval(30 * 60);
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
            return;
        }
        
        // Validate input
        String errorMessage = null;
        if (username != null && !username.trim().isEmpty() && password != null && !password.trim().isEmpty()) {
            // Authenticate user from database
            User user = authenticateUser(username.trim(), password);
            if (user != null) {
                // Enforce portal-role match
                boolean isAdmin = "admin".equalsIgnoreCase(user.getRole());
                if ("admin".equalsIgnoreCase(portal) && !isAdmin) {
                    errorMessage = "Only admin accounts can use the Admin Login.";
                } else if ("user".equalsIgnoreCase(portal) && isAdmin) {
                    errorMessage = "Admins must use the Admin Login.";
                }
                if (errorMessage != null) {
                    request.setAttribute("errorMessage", errorMessage);
                    request.setAttribute("username", username);
                    request.setAttribute("portal", portal);
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }
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
        request.setAttribute("portal", portal);
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
    
    /**
     * Authenticate user with username and password
     * @param username User username or email
     * @param password User password
     * @return User object if authentication successful, null otherwise
     */
    private User authenticateUser(String username, String password) {
    String sql = "SELECT user_id, username, email, phone_number, full_name, password_hash, role, " +
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
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setPhoneNumber(rs.getString("phone_number"));
                    user.setFullName(rs.getString("full_name"));
                    user.setPasswordHash(storedPasswordHash);
                    user.setRole(rs.getString("role"));
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

    private User ensureAdminUser() {
        String findSql = "SELECT user_id, username, email, full_name, preferred_language, password_hash, role, created_at, updated_at, is_active FROM users WHERE (username = 'admin' OR email = 'admin@smartcalendar.com') LIMIT 1";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement find = conn.prepareStatement(findSql)) {
            ResultSet rs = find.executeQuery();
            if (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setUsername(rs.getString("username"));
                u.setEmail(rs.getString("email"));
                u.setFullName(rs.getString("full_name"));
                u.setPasswordHash(rs.getString("password_hash"));
                u.setRole(rs.getString("role"));
                u.setPreferredLanguage(rs.getString("preferred_language"));
                u.setCreatedAt(rs.getTimestamp("created_at"));
                u.setUpdatedAt(rs.getTimestamp("updated_at"));
                u.setActive(rs.getBoolean("is_active"));
                return u;
            }
            // Create admin
            String pwHash = PasswordUtil.hashPassword("admin");
            String insertSql = "INSERT INTO users (username, email, full_name, password_hash, role, preferred_language, is_active) VALUES (?, ?, ?, ?, 'admin', ?, TRUE)";
            PreparedStatement ins = conn.prepareStatement(insertSql, PreparedStatement.RETURN_GENERATED_KEYS);
            ins.setString(1, "admin");
            ins.setString(2, "admin@smartcalendar.com");
            ins.setString(3, "Administrator");
            ins.setString(4, pwHash);
            ins.setString(5, "en");
            ins.executeUpdate();
            ResultSet keys = ins.getGeneratedKeys();
            if (keys.next()) {
                User u = new User();
                u.setUserId(keys.getInt(1));
                u.setUsername("admin");
                u.setEmail("admin@smartcalendar.com");
                u.setFullName("Administrator");
                u.setPasswordHash(pwHash);
                u.setRole("admin");
                u.setPreferredLanguage("en");
                return u;
            }
        } catch (SQLException e) {
            System.err.println("Failed to ensure admin user: " + e.getMessage());
        }
        // Fallback ephemeral admin
        User fallback = new User();
        fallback.setUserId(1);
        fallback.setUsername("admin");
        fallback.setEmail("admin@smartcalendar.com");
        fallback.setFullName("Administrator");
        fallback.setRole("admin");
        fallback.setPreferredLanguage("en");
        return fallback;
    }
}
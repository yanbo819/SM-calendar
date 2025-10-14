package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.regex.Pattern;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.smartcalendar.models.User;
import com.smartcalendar.utils.DatabaseUtil;
import com.smartcalendar.utils.PasswordUtil;

/**
 * Servlet for handling user registration
 */
public class RegisterServlet extends HttpServlet {
    private static final Pattern EMAIL_PATTERN = 
        Pattern.compile("^[A-Za-z0-9+_.-]+@([A-Za-z0-9.-]+\\.[A-Za-z]{2,})$");
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Check if user is already logged in
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        
        // Forward to registration page
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String fullName = request.getParameter("fullName");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String mobileNumber = request.getParameter("mobileNumber");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
    String preferredLanguage = "en";
        
        // Validate input
    String errorMessage = validateRegistrationInput(fullName, username, email, mobileNumber, 
                              password, confirmPassword);
        
        if (errorMessage == null) {
            // Check if email or username already exists
            if (isEmailExists(email)) {
                errorMessage = "Email address already registered";
            } else if (isUsernameExists(username)) {
                errorMessage = "Username already taken";
            } else {
                // Create new user
                User newUser = createUser(fullName.trim(), username.trim(), email.trim().toLowerCase(), 
                                        mobileNumber != null ? mobileNumber.trim() : null,
                                        password, preferredLanguage);
                
                if (newUser != null) {
                    // Create session
                    HttpSession session = request.getSession(true);
                    session.setAttribute("user", newUser);
                    session.setAttribute("userId", newUser.getUserId());
                    session.setAttribute("userLanguage", "en");
                    session.setMaxInactiveInterval(30 * 60); // 30 minutes
                    
                    // Redirect to dashboard
                    response.sendRedirect("dashboard.jsp");
                    return;
                } else {
                    errorMessage = "Registration failed. Please try again.";
                }
            }
        }
        
        // If we reach here, there was an error
        request.setAttribute("errorMessage", errorMessage);
        request.setAttribute("fullName", fullName);
        request.setAttribute("username", username);
        request.setAttribute("email", email);
        request.setAttribute("mobileNumber", mobileNumber);
    // preferredLanguage is forced to 'en' and not user-editable; no need to echo back
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }
    
    /**
     * Validate registration input
     */
    private String validateRegistrationInput(String fullName, String username, String email, String mobileNumber,
                                           String password, String confirmPassword) {
        if (fullName == null || fullName.trim().isEmpty()) {
            return "Full name is required";
        }
        
        if (fullName.trim().length() < 2) {
            return "Full name must be at least 2 characters";
        }
        
        if (username == null || username.trim().isEmpty()) {
            return "Username is required";
        }
        
        if (username.trim().length() < 3) {
            return "Username must be at least 3 characters";
        }
        
        if (email == null || email.trim().isEmpty()) {
            return "Email address is required";
        }
        
        if (!EMAIL_PATTERN.matcher(email.trim()).matches()) {
            return "Please enter a valid email address";
        }
        
        if (mobileNumber == null || mobileNumber.trim().isEmpty()) {
            return "Mobile number is required";
        }
        
        if (password == null || password.isEmpty()) {
            return "Password is required";
        }
        
        if (!PasswordUtil.isPasswordValid(password)) {
            return "Password must be at least 6 characters and include at least two of: uppercase, lowercase, number, symbol";
        }
        
        if (confirmPassword == null || !password.equals(confirmPassword)) {
            return "Password confirmation does not match";
        }
        
            // Language is forced to English across the app; skip language validation
        
        return null; // No validation errors
    }
    
    /**
     * Check if email already exists in database
     */
    private boolean isEmailExists(String email) {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email.trim().toLowerCase());
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("Error checking email existence: " + e.getMessage());
        }
        
        return false;
    }
    
    /**
     * Check if username already exists in database
     */
    private boolean isUsernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username.trim());
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("Error checking username existence: " + e.getMessage());
        }
        
        return false;
    }
    
    /**
     * Create new user in database
     */
    private User createUser(String fullName, String username, String email, String mobileNumber, 
                          String password, String preferredLanguage) {
        String sql = "INSERT INTO users (username, email, phone_number, full_name, password_hash, preferred_language) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            
            String hashedPassword = PasswordUtil.hashPassword(password);
            
            stmt.setString(1, username);
            stmt.setString(2, email);
            stmt.setString(3, mobileNumber);
            stmt.setString(4, fullName);
            stmt.setString(5, hashedPassword);
            stmt.setString(6, preferredLanguage);
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    User user = new User(email, fullName, hashedPassword, preferredLanguage);
                    user.setUserId(generatedKeys.getInt(1));
                    user.setPhoneNumber(mobileNumber);
                    return user;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error creating user: " + e.getMessage());
        }
        
        return null;
    }
}
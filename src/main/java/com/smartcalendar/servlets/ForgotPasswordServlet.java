package com.smartcalendar.servlets;

import com.smartcalendar.utils.DatabaseUtil;
import com.smartcalendar.utils.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

/**
 * Servlet for handling password recovery functionality
 */
public class ForgotPasswordServlet extends HttpServlet {
    
    // Simple in-memory storage for verification codes (in production, use Redis or database)
    private static final Map<String, VerificationCode> verificationCodes = new HashMap<>();
    
    private static class VerificationCode {
        String code;
        String username;
        String contact;
        long timestamp;
        
        VerificationCode(String code, String username, String contact) {
            this.code = code;
            this.username = username;
            this.contact = contact;
            this.timestamp = System.currentTimeMillis();
        }
        
        boolean isExpired() {
            return System.currentTimeMillis() - timestamp > 15 * 60 * 1000; // 15 minutes
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Forward to forgot password page
        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String step = request.getParameter("step");
        
        if ("1".equals(step)) {
            handleStep1(request, response);
        } else if ("2".equals(step)) {
            handleStep2(request, response);
        } else if ("3".equals(step)) {
            handleStep3(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid step");
        }
    }
    
    /**
     * Step 1: Verify username and contact information
     */
    private void handleStep1(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String contact = request.getParameter("contact");
        
        if (username == null || username.trim().isEmpty() || 
            contact == null || contact.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Please fill in all required fields");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }
        
        // Verify user exists and contact matches
        if (verifyUserContact(username.trim(), contact.trim())) {
            // Generate and send verification code
            String code = generateVerificationCode();
            String key = username.trim() + ":" + contact.trim();
            verificationCodes.put(key, new VerificationCode(code, username.trim(), contact.trim()));
            
            // In a real application, send email/SMS here
            System.out.println("Verification code for " + username + ": " + code);
            
            // Redirect to step 2
            response.sendRedirect("forgot-password.jsp?step=2&username=" + username + "&contact=" + contact);
        } else {
            request.setAttribute("errorMessage", "Username and contact information do not match our records");
            request.setAttribute("username", username);
            request.setAttribute("contact", contact);
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
        }
    }
    
    /**
     * Step 2: Verify the code
     */
    private void handleStep2(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String contact = request.getParameter("contact");
        
        // Collect verification code digits
        String code = "";
        for (int i = 1; i <= 6; i++) {
            String digit = request.getParameter("digit" + i);
            if (digit != null) {
                code += digit;
            }
        }
        
        if (username == null || contact == null || code.length() != 6) {
            request.setAttribute("errorMessage", "Please enter the complete verification code");
            response.sendRedirect("forgot-password.jsp?step=2&username=" + username + "&contact=" + contact);
            return;
        }
        
        String key = username.trim() + ":" + contact.trim();
        VerificationCode storedCode = verificationCodes.get(key);
        
        if (storedCode == null) {
            request.setAttribute("errorMessage", "Invalid session. Please start over.");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }
        
        if (storedCode.isExpired()) {
            verificationCodes.remove(key);
            request.setAttribute("errorMessage", "Verification code has expired. Please try again.");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }
        
        if (!storedCode.code.equals(code)) {
            request.setAttribute("errorMessage", "Invalid verification code. Please try again.");
            response.sendRedirect("forgot-password.jsp?step=2&username=" + username + "&contact=" + contact);
            return;
        }
        
        // Code verified, proceed to step 3
        response.sendRedirect("forgot-password.jsp?step=3&username=" + username + "&verificationCode=" + code);
    }
    
    /**
     * Step 3: Reset password
     */
    private void handleStep3(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String verificationCode = request.getParameter("verificationCode");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmNewPassword");
        
        if (username == null || verificationCode == null || 
            newPassword == null || confirmPassword == null) {
            request.setAttribute("errorMessage", "Please fill in all required fields");
            response.sendRedirect("forgot-password.jsp?step=3&username=" + username + "&verificationCode=" + verificationCode);
            return;
        }
        
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match");
            response.sendRedirect("forgot-password.jsp?step=3&username=" + username + "&verificationCode=" + verificationCode);
            return;
        }
        
        if (!PasswordUtil.isPasswordValid(newPassword)) {
            request.setAttribute("errorMessage", "Password must be at least 6 characters with uppercase, lowercase, and digit");
            response.sendRedirect("forgot-password.jsp?step=3&username=" + username + "&verificationCode=" + verificationCode);
            return;
        }
        
        // Update password in database
        if (updateUserPassword(username, newPassword)) {
            // Clean up verification code
            verificationCodes.entrySet().removeIf(entry -> 
                entry.getValue().username.equals(username) && 
                entry.getValue().code.equals(verificationCode));
            
            request.setAttribute("successMessage", "Password successfully reset! You can now log in with your new password.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Failed to reset password. Please try again.");
            response.sendRedirect("forgot-password.jsp?step=3&username=" + username + "&verificationCode=" + verificationCode);
        }
    }
    
    /**
     * Verify that username and contact information match
     */
    private boolean verifyUserContact(String username, String contact) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ? AND (email = ? OR phone_number = ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            stmt.setString(2, contact);
            stmt.setString(3, contact);
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("Error verifying user contact: " + e.getMessage());
        }
        
        return false;
    }
    
    /**
     * Update user password in database
     */
    private boolean updateUserPassword(String username, String newPassword) {
        String sql = "UPDATE users SET password_hash = ? WHERE username = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            String hashedPassword = PasswordUtil.hashPassword(newPassword);
            stmt.setString(1, hashedPassword);
            stmt.setString(2, username);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating user password: " + e.getMessage());
        }
        
        return false;
    }
    
    /**
     * Generate a random 6-digit verification code
     */
    private String generateVerificationCode() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(1000000));
    }
}
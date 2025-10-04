package com.smartcalendar.utils;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Utility class for password hashing and verification
 */
public class PasswordUtil {
    private static final String ALGORITHM = "SHA-256";
    private static final int SALT_LENGTH = 16;
    
    /**
     * Generate a random salt
     * @return Base64 encoded salt
     */
    private static String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[SALT_LENGTH];
        random.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }
    
    /**
     * Hash a password with salt
     * @param password Plain text password
     * @param salt Salt to use for hashing
     * @return Hashed password
     */
    private static String hashPassword(String password, String salt) {
        try {
            MessageDigest md = MessageDigest.getInstance(ALGORITHM);
            md.update(Base64.getDecoder().decode(salt));
            byte[] hashedPassword = md.digest(password.getBytes());
            return Base64.getEncoder().encodeToString(hashedPassword);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Password hashing algorithm not available", e);
        }
    }
    
    /**
     * Hash a password with a generated salt
     * @param password Plain text password
     * @return Salt + ":" + HashedPassword
     */
    public static String hashPassword(String password) {
        String salt = generateSalt();
        String hashedPassword = hashPassword(password, salt);
        return salt + ":" + hashedPassword;
    }
    
    /**
     * Verify a password against a stored hash
     * @param password Plain text password to verify
     * @param storedHash Stored hash in format "salt:hashedPassword"
     * @return true if password matches, false otherwise
     */
    public static boolean verifyPassword(String password, String storedHash) {
        try {
            String[] parts = storedHash.split(":", 2);
            if (parts.length != 2) {
                return false;
            }
            
            String salt = parts[0];
            String hashedPassword = parts[1];
            String newHash = hashPassword(password, salt);
            
            return hashedPassword.equals(newHash);
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * Generate a secure random token for password reset
     * @return Random token string
     */
    public static String generateResetToken() {
        SecureRandom random = new SecureRandom();
        byte[] token = new byte[32];
        random.nextBytes(token);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(token);
    }
    
    /**
     * Validate password strength
     * @param password Password to validate
     * @return true if password meets strength requirements
     */
    public static boolean isPasswordValid(String password) {
        if (password == null || password.length() < 6) {
            return false;
        }
        
        boolean hasUpper = false;
        boolean hasLower = false;
        boolean hasDigit = false;
        
        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) hasUpper = true;
            if (Character.isLowerCase(c)) hasLower = true;
            if (Character.isDigit(c)) hasDigit = true;
        }
        
        return hasUpper && hasLower && hasDigit;
    }
}
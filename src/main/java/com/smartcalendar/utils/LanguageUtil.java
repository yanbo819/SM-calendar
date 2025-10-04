package com.smartcalendar.utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

/**
 * Utility class for handling multi-language support
 */
public class LanguageUtil {
    private static final Map<String, Map<String, String>> languageResources = new HashMap<>();
    private static boolean isInitialized = false;
    
    /**
     * Initialize language resources from database
     */
    public static synchronized void initializeResources() {
        if (isInitialized) {
            return;
        }
        
        try (Connection conn = DatabaseUtil.getConnection()) {
            String sql = "SELECT language_code, resource_key, resource_value FROM language_resources";
            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                String langCode = rs.getString("language_code");
                String key = rs.getString("resource_key");
                String value = rs.getString("resource_value");
                
                languageResources.computeIfAbsent(langCode, k -> new HashMap<>()).put(key, value);
            }
            
            isInitialized = true;
        } catch (SQLException e) {
            System.err.println("Error loading language resources: " + e.getMessage());
        }
    }
    
    /**
     * Get localized text for a given key and language
     * @param languageCode Language code (en, ar, zh)
     * @param key Resource key
     * @return Localized text or key if not found
     */
    public static String getText(String languageCode, String key) {
        if (!isInitialized) {
            initializeResources();
        }
        
        Map<String, String> langMap = languageResources.get(languageCode);
        if (langMap != null && langMap.containsKey(key)) {
            return langMap.get(key);
        }
        
        // Fallback to English if not found
        if (!"en".equals(languageCode)) {
            langMap = languageResources.get("en");
            if (langMap != null && langMap.containsKey(key)) {
                return langMap.get(key);
            }
        }
        
        // Return key if not found anywhere
        return key;
    }
    
    /**
     * Check if a language is supported
     * @param languageCode Language code to check
     * @return true if supported, false otherwise
     */
    public static boolean isSupportedLanguage(String languageCode) {
        return "en".equals(languageCode);
    }
    
    /**
     * Get the text direction for a language
     * @param languageCode Language code
     * @return "rtl" for Arabic, "ltr" for others
     */
    public static String getTextDirection(String languageCode) {
        return "ltr";
    }
    
    /**
     * Get language name in the language itself
     * @param languageCode Language code
     * @return Language name
     */
    public static String getLanguageName(String languageCode) {
        return "English";
    }
    
    /**
     * Get all supported language codes
     * @return Array of supported language codes
     */
    public static String[] getSupportedLanguages() {
        return new String[]{"en"};
    }
    
    /**
     * Refresh language resources from database
     */
    public static synchronized void refreshResources() {
        languageResources.clear();
        isInitialized = false;
        initializeResources();
    }
}
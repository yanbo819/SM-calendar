package com.smartcalendar.utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

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
        if (isInitialized) return;
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            if (conn == null) { // DB unavailable, skip without failing
                isInitialized = true; // prevent repeated attempts hammering logs
                return;
            }
            PreparedStatement stmt = conn.prepareStatement("SELECT language_code, resource_key, resource_value FROM language_resources");
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                String langCode = rs.getString("language_code");
                String key = rs.getString("resource_key");
                String value = rs.getString("resource_value");
                languageResources.computeIfAbsent(langCode, k -> new HashMap<>()).put(key, value);
            }
            isInitialized = true;
        } catch (SQLException e) {
            // Downgrade to DEBUG-like output; rely on property bundles
            System.err.println("[LanguageUtil] DB resource load failed; falling back to property bundles. Cause: " + e.getMessage());
            isInitialized = true; // prevent infinite retry loop
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
    }
    
    /**
     * Get localized text for a given key and language
     * @param languageCode Language code (en, ar, zh)
     * @param key Resource key
     * @return Localized text or key if not found
     */
    public static String getText(String languageCode, String key) {
        if (!isInitialized) initializeResources();
        
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

        // Property bundle fallback (allows shipping translations without DB rows)
        String bundleVal = bundleLookup(languageCode, key);
        if (bundleVal != null) return bundleVal;
        if (!"en".equals(languageCode)) {
            bundleVal = bundleLookup("en", key);
            if (bundleVal != null) return bundleVal;
        }
        
        // Friendly fallback: humanize the key (replace dots/underscores with spaces and title-case)
        return humanizeKey(key);
    }

    private static String bundleLookup(String languageCode, String key) {
        try {
            Locale locale = new Locale(languageCode);
            ResourceBundle rb = ResourceBundle.getBundle("i18n.messages", locale);
            if (rb.containsKey(key)) {
                return rb.getString(key);
            }
        } catch (MissingResourceException ignored) {
        }
        return null;
    }

    private static String humanizeKey(String key) {
        if (key == null) return "";
        String replaced = key.replaceAll("[._-]+", " ").trim();
        if (replaced.isEmpty()) return key;
        String[] parts = replaced.split("\\s+");
        StringBuilder sb = new StringBuilder();
        for (String part : parts) {
            if (part.isEmpty()) continue;
            char first = part.charAt(0);
            String rest = part.length() > 1 ? part.substring(1).toLowerCase() : "";
            sb.append(Character.toUpperCase(first)).append(rest).append(' ');
        }
        return sb.toString().trim();
    }
    
    /**
     * Check if a language is supported
     * @param languageCode Language code to check
     * @return true if supported, false otherwise
     */
    public static boolean isSupportedLanguage(String languageCode) {
        if (languageCode == null) return false;
        switch (languageCode) {
            case "en":
            case "ar":
            case "zh":
            case "fr":
                return true;
            default:
                return false;
        }
    }
    
    /**
     * Get the text direction for a language
     * @param languageCode Language code
     * @return "rtl" for Arabic, "ltr" for others
     */
    public static String getTextDirection(String languageCode) {
        return "ar".equalsIgnoreCase(languageCode) ? "rtl" : "ltr";
    }
    
    /**
     * Get language name in the language itself
     * @param languageCode Language code
     * @return Language name
     */
    public static String getLanguageName(String languageCode) {
        if (languageCode == null) return "";
        switch (languageCode) {
            case "en": return "English";
            case "ar": return "العربية";
            case "zh": return "中文";
            case "fr": return "Français";
            default: return languageCode;
        }
    }
    
    /**
     * Get all supported language codes
     * @return Array of supported language codes
     */
    public static String[] getSupportedLanguages() {
        return new String[]{"en","ar","zh","fr"};
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
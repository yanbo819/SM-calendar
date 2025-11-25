package com.smartcalendar.utils;

import jakarta.servlet.http.HttpServletRequest;

public final class WebUtil {
    private WebUtil() {}

    public static String resolveLang(HttpServletRequest req) {
        Object attr = req.getAttribute("lang");
        String lang = attr != null ? String.valueOf(attr) : (String) req.getSession().getAttribute("lang");
        if (lang == null || !LanguageUtil.isSupportedLanguage(lang)) lang = "en";
        return lang;
    }

    public static String withLang(String url, String lang) {
        if (url == null || lang == null || lang.isEmpty()) return url;
        return url.contains("?") ? (url + "&lang=" + lang) : (url + "?lang=" + lang);
    }
}

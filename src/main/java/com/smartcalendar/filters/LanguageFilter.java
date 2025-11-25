package com.smartcalendar.filters;

import java.io.IOException;
import java.util.logging.Logger;

import com.smartcalendar.models.User;
import com.smartcalendar.utils.LanguageUtil;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter("/*")
public class LanguageFilter implements Filter {
    private static final Logger LOGGER = Logger.getLogger(LanguageFilter.class.getName());

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(true);

        // Determine desired language: URL param > session > user preference > default
        String paramLang = req.getParameter("lang");
        String sessionLang = (String) session.getAttribute("lang");
        User user = (User) session.getAttribute("user");
        String userPref = user != null ? user.getPreferredLanguage() : null;

        String chosen = paramLang != null ? paramLang : (sessionLang != null ? sessionLang : (userPref != null ? userPref : "en"));
        if (!LanguageUtil.isSupportedLanguage(chosen)) {
            chosen = "en";
        }
        if (!chosen.equals(sessionLang)) {
            session.setAttribute("lang", chosen);
        }
        request.setAttribute("lang", chosen);
        request.setAttribute("textDir", LanguageUtil.getTextDirection(chosen));
        // Diagnostic header for curl-based troubleshooting
        resp.setHeader("X-App-Lang", chosen);

        try {
            chain.doFilter(request, response);
        } catch (Throwable t) {
            System.err.println("\n=== Unhandled Exception (LanguageFilter) ===");
            System.err.println("Path: " + req.getRequestURI());
            System.err.println("Lang: " + chosen);
            System.err.println("Query: " + (req.getQueryString() != null ? req.getQueryString() : "(none)"));
            System.err.println("User-Agent: " + req.getHeader("User-Agent"));
            System.err.println("Exception Type: " + t.getClass().getName());
            System.err.println("Message: " + t.getMessage());
            t.printStackTrace(System.err);
            System.err.println("=== End Exception ===\n");
            throw t instanceof ServletException ? (ServletException) t : new ServletException(t);
        }
        
    }
}
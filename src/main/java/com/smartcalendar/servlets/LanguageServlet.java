package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import com.smartcalendar.models.User;
import com.smartcalendar.utils.DatabaseUtil;
import com.smartcalendar.utils.LanguageUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/set-language"})
public class LanguageServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String lang = req.getParameter("lang");
        if (!LanguageUtil.isSupportedLanguage(lang)) {
            lang = "en"; // fallback
        }
        HttpSession session = req.getSession(true);
        session.setAttribute("lang", lang);
        // update user preference if logged in
        User user = (User) session.getAttribute("user");
        if (user != null) {
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement("UPDATE users SET preferred_language=? WHERE user_id=?")) {
                ps.setString(1, lang);
                ps.setInt(2, user.getUserId());
                ps.executeUpdate();
            } catch (Exception ignore) {}
        }
        // refresh cached resources (ignore failures to avoid 500 page)
        try { LanguageUtil.refreshResources(); } catch (Exception e) { System.err.println("Language refresh failed: " + e.getMessage()); }
        String referer = req.getHeader("Referer");
        if (referer == null || referer.isEmpty()) referer = "dashboard.jsp";
        resp.sendRedirect(referer);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Allow GET for convenience (e.g., language links)
        String lang = req.getParameter("lang");
        if (!LanguageUtil.isSupportedLanguage(lang)) {
            lang = "en"; // fallback
        }
        HttpSession session = req.getSession(true);
        session.setAttribute("lang", lang);
        User user = (User) session.getAttribute("user");
        if (user != null) {
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement("UPDATE users SET preferred_language=? WHERE user_id=?")) {
                ps.setString(1, lang);
                ps.setInt(2, user.getUserId());
                ps.executeUpdate();
            } catch (Exception ignore) {}
        }
        try { LanguageUtil.refreshResources(); } catch (Exception e) { System.err.println("Language refresh failed: " + e.getMessage()); }
        String referer = req.getHeader("Referer");
        if (referer == null || referer.isEmpty()) referer = "dashboard.jsp";
        resp.sendRedirect(referer);
    }
}

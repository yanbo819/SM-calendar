package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Time;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import com.smartcalendar.models.User;
import com.smartcalendar.utils.DatabaseUtil;
import com.smartcalendar.utils.LanguageUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/update-event"})
public class UpdateEventServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String lang = (String) session.getAttribute("lang");
        if (lang == null) lang = user.getPreferredLanguage() != null ? user.getPreferredLanguage() : "en";

        String idStr = req.getParameter("id");
        String title = trim(req.getParameter("title"));
        String dateStr = trim(req.getParameter("eventDate"));
        String timeStr = trim(req.getParameter("eventTime"));
        String location = trim(req.getParameter("location"));
        String description = trim(req.getParameter("description"));
        String reminderStr = trim(req.getParameter("reminderMinutes"));

        if (idStr == null || title == null || title.isBlank() || dateStr == null || dateStr.isBlank() || timeStr == null || timeStr.isBlank()) {
            req.setAttribute("errorMessage", LanguageUtil.getText(lang, "event.update.missing"));
            forwardBack(req, resp, idStr);
            return;
        }

        int eventId;
        try { eventId = Integer.parseInt(idStr); } catch (NumberFormatException nfe) {
            req.setAttribute("errorMessage", LanguageUtil.getText(lang, "event.update.invalidId"));
            forwardBack(req, resp, idStr);
            return;
        }

        int reminder = 15;
        try { if (reminderStr != null && !reminderStr.isBlank()) reminder = Integer.parseInt(reminderStr); } catch (NumberFormatException ignore) {}

        try (Connection conn = DatabaseUtil.getConnection()) {
            SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat tf = new SimpleDateFormat("HH:mm");
            Date sqlDate;
            Time sqlTime;
            try {
                sqlDate = new Date(df.parse(dateStr).getTime());
                sqlTime = new Time(tf.parse(timeStr).getTime());
            } catch (ParseException pe) {
                req.setAttribute("errorMessage", LanguageUtil.getText(lang, "event.update.parseError"));
                forwardBack(req, resp, idStr);
                return;
            }

            PreparedStatement stmt = conn.prepareStatement(
                "UPDATE events SET title=?, event_date=?, event_time=?, location=?, description=?, reminder_minutes_before=? WHERE event_id=? AND user_id=?");
            stmt.setString(1, title);
            stmt.setDate(2, sqlDate);
            stmt.setTime(3, sqlTime);
            stmt.setString(4, location);
            stmt.setString(5, description);
            stmt.setInt(6, reminder);
            stmt.setInt(7, eventId);
            stmt.setInt(8, user.getUserId());
            int updated = stmt.executeUpdate();
            if (updated == 0) {
                req.setAttribute("errorMessage", LanguageUtil.getText(lang, "event.update.notFound"));
            } else {
                req.setAttribute("successMessage", LanguageUtil.getText(lang, "event.update.success"));
            }
        } catch (SQLException e) {
            req.setAttribute("errorMessage", LanguageUtil.getText(lang, "event.update.error") + ": " + e.getMessage());
        }

        forwardBack(req, resp, idStr);
    }

    private void forwardBack(HttpServletRequest req, HttpServletResponse resp, String id) throws ServletException, IOException {
        if (id != null) req.setAttribute("id", id);
        req.getRequestDispatcher("/edit-event.jsp?id=" + id).forward(req, resp);
    }

    private String trim(String v) { return v == null ? null : v.trim(); }
}

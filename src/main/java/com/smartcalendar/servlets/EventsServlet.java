package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.smartcalendar.models.Category;
import com.smartcalendar.models.Event;
import com.smartcalendar.models.User;
import com.smartcalendar.utils.DatabaseUtil;
import com.smartcalendar.utils.LanguageUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/events"})
public class EventsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String searchQuery = param(req, "search");
        String categoryFilter = param(req, "category");
        String dateFrom = param(req, "dateFrom");
        String dateTo = param(req, "dateTo");
        String sortBy = param(req, "sortBy");

        boolean isAdmin = user.getEmail() != null && user.getEmail().equals("admin@smartcalendar.com");

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT e.event_id, e.user_id, e.title, e.description, e.event_date, e.event_time, ");
        sql.append("e.duration_minutes, e.location, e.notes, e.reminder_minutes_before, ");
        sql.append("c.category_name, c.category_color, s.subject_name ");
        sql.append("FROM events e ");
        sql.append("LEFT JOIN categories c ON e.category_id = c.category_id ");
        sql.append("LEFT JOIN subjects s ON e.subject_id = s.subject_id ");
        if (isAdmin) {
            sql.append("WHERE e.is_active = TRUE AND e.user_id = ? ");
        } else {
            sql.append("WHERE e.is_active = TRUE AND (e.user_id = ? OR e.user_id IN (SELECT user_id FROM users WHERE email = 'admin@smartcalendar.com')) ");
        }

        List<Object> parameters = new ArrayList<>();
        parameters.add(user.getUserId());

        if (notBlank(searchQuery)) {
            sql.append("AND (e.title LIKE ? OR e.description LIKE ? OR e.location LIKE ? OR e.notes LIKE ?) ");
            String pattern = "%" + searchQuery.trim() + "%";
            parameters.add(pattern);
            parameters.add(pattern);
            parameters.add(pattern);
            parameters.add(pattern);
        }
        if (notBlank(categoryFilter)) {
            try {
                int catId = Integer.parseInt(categoryFilter.trim());
                sql.append("AND e.category_id = ? ");
                parameters.add(catId);
            } catch (NumberFormatException ignored) {}
        }
        if (notBlank(dateFrom)) {
            try {
                Date df = Date.valueOf(dateFrom.trim());
                sql.append("AND e.event_date >= ? ");
                parameters.add(df);
            } catch (IllegalArgumentException ignored) {}
        }
        if (notBlank(dateTo)) {
            try {
                Date dt = Date.valueOf(dateTo.trim());
                sql.append("AND e.event_date <= ? ");
                parameters.add(dt);
            } catch (IllegalArgumentException ignored) {}
        }

        if ("date_desc".equals(sortBy)) {
            sql.append("ORDER BY e.event_date DESC, e.event_time DESC");
        } else if ("title_asc".equals(sortBy)) {
            sql.append("ORDER BY e.title ASC");
        } else if ("title_desc".equals(sortBy)) {
            sql.append("ORDER BY e.title DESC");
        } else if ("category".equals(sortBy)) {
            sql.append("ORDER BY c.category_name ASC, e.event_date ASC");
        } else {
            sql.append("ORDER BY e.event_date ASC, e.event_time ASC");
        }

        List<Event> events = new ArrayList<>();
        List<Category> categories = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < parameters.size(); i++) {
                Object p = parameters.get(i);
                if (p instanceof Integer) {
                    stmt.setInt(i + 1, (Integer) p);
                } else if (p instanceof Date) {
                    stmt.setDate(i + 1, (Date) p);
                } else {
                    stmt.setString(i + 1, p.toString());
                }
            }
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Event e = new Event();
                e.setEventId(rs.getInt("event_id"));
                e.setUserId(rs.getInt("user_id"));
                e.setTitle(rs.getString("title"));
                e.setDescription(rs.getString("description"));
                e.setEventDate(rs.getDate("event_date"));
                e.setEventTime(rs.getTime("event_time"));
                e.setDurationMinutes(rs.getInt("duration_minutes"));
                e.setLocation(rs.getString("location"));
                e.setNotes(rs.getString("notes"));
                e.setReminderMinutesBefore(rs.getInt("reminder_minutes_before"));
                e.setCategoryName(rs.getString("category_name"));
                e.setCategoryColor(rs.getString("category_color"));
                e.setSubjectName(rs.getString("subject_name"));
                events.add(e);
            }
            // Load categories for filter select
            try (PreparedStatement catStmt = conn.prepareStatement("SELECT category_id, category_name, category_color FROM categories ORDER BY category_name")) {
                ResultSet crs = catStmt.executeQuery();
                while (crs.next()) {
                    Category c = new Category();
                    c.setCategoryId(crs.getInt("category_id"));
                    c.setCategoryName(crs.getString("category_name"));
                    c.setCategoryColor(crs.getString("category_color"));
                    categories.add(c);
                }
            }
        } catch (SQLException ex) {
            req.setAttribute("loadError", "Failed to load events.");
        }

        // Expose filters back to JSP
        req.setAttribute("events", events);
        req.setAttribute("categories", categories);
        req.setAttribute("search", searchQuery);
        req.setAttribute("category", categoryFilter);
        req.setAttribute("dateFrom", dateFrom);
        req.setAttribute("dateTo", dateTo);
        req.setAttribute("sortBy", sortBy);

        // Ensure language defaults for iteration
        String lang = (String) session.getAttribute("lang");
        if (lang == null) lang = "en";
        req.setAttribute("lang", lang);
        req.setAttribute("textDir", LanguageUtil.getTextDirection(lang));

        req.getRequestDispatcher("/events.jsp").forward(req, resp);
    }

    private String param(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v != null && !v.isBlank() ? v : null;
    }

    private boolean notBlank(String v) { return v != null && !v.trim().isEmpty(); }
}

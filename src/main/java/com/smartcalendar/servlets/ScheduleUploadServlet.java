package com.smartcalendar.servlets;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Types;

import com.smartcalendar.models.User;
import com.smartcalendar.utils.DatabaseUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

/**
 * Servlet to upload and import course schedule from CSV
 */
@MultipartConfig
public class ScheduleUploadServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Part filePart = request.getPart("file");
        if (filePart == null || filePart.getSize() == 0) {
            request.setAttribute("errorMessage", "Please choose a CSV file to upload.");
            request.getRequestDispatcher("schedule-upload.jsp").forward(request, response);
            return;
        }

        int imported = 0;
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(filePart.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            boolean headerSkipped = false;
            while ((line = reader.readLine()) != null) {
                if (!headerSkipped) { headerSkipped = true; continue; }
                String[] cols = line.split(",");
                if (cols.length < 8) continue; // skip invalid rows
                String title = cols[0].trim();
                String categoryName = cols[1].trim();
                String subjectName = cols[2].trim();
                String date = cols[3].trim();
                String time = cols[4].trim();
                int duration = parseIntOr(cols[5].trim(), 60);
                String location = cols[6].trim();
                int reminder = parseIntOr(cols[7].trim(), 15);

                if (title.isEmpty() || date.isEmpty() || time.isEmpty()) continue;
                importRow(user.getUserId(), title, categoryName, subjectName, date, time, duration, location, reminder);
                imported++;
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Failed to import schedule: " + e.getMessage());
            request.getRequestDispatcher("schedule-upload.jsp").forward(request, response);
            return;
        }

        request.setAttribute("successMessage", "Imported " + imported + " events from schedule.");
        request.getRequestDispatcher("schedule-upload.jsp").forward(request, response);
    }

    private void importRow(int userId, String title, String categoryName, String subjectName,
                           String date, String time, int duration, String location, int reminder) throws Exception {
        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);
            Integer categoryId = getOrCreateCategory(conn, categoryName);
            Integer subjectId = (subjectName != null && !subjectName.isEmpty()) ? getOrCreateSubject(conn, userId, subjectName) : null;

            PreparedStatement insert = conn.prepareStatement(
                "INSERT INTO events (user_id, category_id, subject_id, title, event_date, event_time, duration_minutes, location, reminder_minutes_before, is_active) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, TRUE)"
            );
            insert.setInt(1, userId);
            if (categoryId != null) insert.setInt(2, categoryId); else insert.setNull(2, Types.INTEGER);
            if (subjectId != null) insert.setInt(3, subjectId); else insert.setNull(3, Types.INTEGER);
            insert.setString(4, title);
            insert.setDate(5, Date.valueOf(date));
            insert.setTime(6, Time.valueOf(time + ":00"));
            insert.setInt(7, duration);
            insert.setString(8, location);
            insert.setInt(9, reminder);
            insert.executeUpdate();
            conn.commit();
        }
    }

    private Integer getOrCreateCategory(Connection conn, String name) throws SQLException {
        if (name == null || name.isEmpty()) return null;
        PreparedStatement sel = conn.prepareStatement("SELECT category_id FROM categories WHERE category_name = ?");
        sel.setString(1, name);
        ResultSet rs = sel.executeQuery();
        if (rs.next()) return rs.getInt(1);
        PreparedStatement ins = conn.prepareStatement("INSERT INTO categories (category_name, category_color) VALUES (?, '#6c5ce7')", PreparedStatement.RETURN_GENERATED_KEYS);
        ins.setString(1, name);
        ins.executeUpdate();
        ResultSet keys = ins.getGeneratedKeys();
        if (keys.next()) return keys.getInt(1);
        return null;
    }

    private Integer getOrCreateSubject(Connection conn, int userId, String name) throws SQLException {
        PreparedStatement sel = conn.prepareStatement("SELECT subject_id FROM subjects WHERE user_id = ? AND subject_name = ?");
        sel.setInt(1, userId);
        sel.setString(2, name);
        ResultSet rs = sel.executeQuery();
        if (rs.next()) return rs.getInt(1);
        PreparedStatement ins = conn.prepareStatement("INSERT INTO subjects (user_id, subject_name) VALUES (?, ?)", PreparedStatement.RETURN_GENERATED_KEYS);
        ins.setInt(1, userId);
        ins.setString(2, name);
        ins.executeUpdate();
        ResultSet keys = ins.getGeneratedKeys();
        if (keys.next()) return keys.getInt(1);
        return null;
    }

    private int parseIntOr(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
}

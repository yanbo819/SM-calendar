package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartcalendar.models.User;
import com.smartcalendar.utils.DatabaseUtil;

/**
 * Servlet for retrieving upcoming reminders
 */
public class UpcomingRemindersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Not authenticated\"}");
            return;
        }

        User user = (User) session.getAttribute("user");
        
        try (Connection conn = DatabaseUtil.getConnection()) {
            String sql = "SELECT e.event_id, e.title, e.description, e.event_date, e.event_time, " +
                        "c.category_name as category_name, s.subject_name as subject_name " +
                        "FROM events e " +
                        "LEFT JOIN categories c ON e.category_id = c.category_id " +
                        "LEFT JOIN subjects s ON e.subject_id = s.subject_id " +
                        "WHERE e.user_id = ? AND e.event_date >= CURRENT_DATE " +
                        "ORDER BY e.event_date ASC, e.event_time ASC LIMIT 10";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, user.getUserId());
                
                try (ResultSet rs = stmt.executeQuery()) {
                    List<String> reminders = new ArrayList<>();
                    
                    while (rs.next()) {
                        String reminder = String.format(
                            "{\"id\":%d,\"title\":\"%s\",\"description\":\"%s\"," +
                            "\"date\": \"%s\",\"time\":\"%s\",\"category\":\"%s\",\"subject\":\"%s\"}",
                            rs.getInt("event_id"),
                            rs.getString("title").replace("\"", "\\\""),
                            (rs.getString("description") != null ? rs.getString("description").replace("\"", "\\\"") : ""),
                            rs.getDate("event_date").toString(),
                            (rs.getTime("event_time") != null ? rs.getTime("event_time").toString() : ""),
                            (rs.getString("category_name") != null ? rs.getString("category_name") : ""),
                            (rs.getString("subject_name") != null ? rs.getString("subject_name") : "")
                        );
                        reminders.add(reminder);
                    }
                    
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.getWriter().write("[" + String.join(",", reminders) + "]");
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error\"}");
        }
    }
}
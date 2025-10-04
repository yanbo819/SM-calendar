package com.smartcalendar.servlets;

import com.smartcalendar.models.Event;
import com.smartcalendar.models.User;
import com.smartcalendar.models.Subject;
import com.smartcalendar.utils.DatabaseUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;

/**
 * Servlet for creating events
 */
public class CreateEventServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Forward to event creation form
        request.getRequestDispatcher("create-event.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String title = request.getParameter("title");
        String categoryIdStr = request.getParameter("categoryId");
        String subjectName = request.getParameter("subjectName");
        String existingSubjectIdStr = request.getParameter("existingSubjectId");
        String description = request.getParameter("description");
        String eventDateStr = request.getParameter("eventDate");
        String eventTimeStr = request.getParameter("eventTime");
        String durationStr = request.getParameter("duration");
        String location = request.getParameter("location");
        String notes = request.getParameter("notes");
        String reminderStr = request.getParameter("reminderMinutes");
        
        // Validate input
        String errorMessage = validateEventInput(title, eventDateStr, eventTimeStr);
        
        if (errorMessage == null) {
            try {
                Event event = new Event();
                event.setUserId(user.getUserId());
                event.setTitle(title.trim());
                event.setDescription(description != null ? description.trim() : null);
                
                // Parse and set date
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                event.setEventDate(new Date(dateFormat.parse(eventDateStr).getTime()));
                
                // Parse and set time
                SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
                event.setEventTime(new Time(timeFormat.parse(eventTimeStr).getTime()));
                
                // Set category
                if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
                    event.setCategoryId(Integer.parseInt(categoryIdStr));
                }
                
                // Handle subject (create new or use existing)
                if (subjectName != null && !subjectName.trim().isEmpty()) {
                    int subjectId = createOrGetSubject(user.getUserId(), subjectName.trim());
                    event.setSubjectId(subjectId);
                } else if (existingSubjectIdStr != null && !existingSubjectIdStr.trim().isEmpty()) {
                    event.setSubjectId(Integer.parseInt(existingSubjectIdStr));
                }
                
                // Set optional fields
                event.setDurationMinutes(durationStr != null && !durationStr.trim().isEmpty() ? 
                                       Integer.parseInt(durationStr) : 60);
                event.setLocation(location != null ? location.trim() : null);
                event.setNotes(notes != null ? notes.trim() : null);
                event.setReminderMinutesBefore(reminderStr != null && !reminderStr.trim().isEmpty() ? 
                                             Integer.parseInt(reminderStr) : 15);
                
                // Save event
                if (saveEvent(event)) {
                    response.sendRedirect("dashboard.jsp?success=Event created successfully");
                    return;
                } else {
                    errorMessage = "Failed to create event. Please try again.";
                }
                
            } catch (ParseException e) {
                errorMessage = "Invalid date or time format";
            } catch (NumberFormatException e) {
                errorMessage = "Invalid number format";
            } catch (Exception e) {
                errorMessage = "An error occurred while creating the event";
                System.err.println("Error creating event: " + e.getMessage());
            }
        }
        
        // If we reach here, there was an error
        request.setAttribute("errorMessage", errorMessage);
        request.setAttribute("title", title);
        request.setAttribute("categoryId", categoryIdStr);
        request.setAttribute("subjectName", subjectName);
        request.setAttribute("existingSubjectId", existingSubjectIdStr);
        request.setAttribute("description", description);
        request.setAttribute("eventDate", eventDateStr);
        request.setAttribute("eventTime", eventTimeStr);
        request.setAttribute("duration", durationStr);
        request.setAttribute("location", location);
        request.setAttribute("notes", notes);
        request.setAttribute("reminderMinutes", reminderStr);
        
        request.getRequestDispatcher("create-event.jsp").forward(request, response);
    }
    
    /**
     * Validate event input
     */
    private String validateEventInput(String title, String eventDate, String eventTime) {
        if (title == null || title.trim().isEmpty()) {
            return "Event title is required";
        }
        
        if (title.trim().length() > 255) {
            return "Event title is too long (maximum 255 characters)";
        }
        
        if (eventDate == null || eventDate.trim().isEmpty()) {
            return "Event date is required";
        }
        
        if (eventTime == null || eventTime.trim().isEmpty()) {
            return "Event time is required";
        }
        
        return null;
    }
    
    /**
     * Create a new subject or get existing one
     */
    private int createOrGetSubject(int userId, String subjectName) throws SQLException {
        // First, check if subject already exists for this user
        String selectSql = "SELECT subject_id FROM subjects WHERE user_id = ? AND subject_name = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement selectStmt = conn.prepareStatement(selectSql)) {
            
            selectStmt.setInt(1, userId);
            selectStmt.setString(2, subjectName);
            ResultSet rs = selectStmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("subject_id");
            }
            
            // Subject doesn't exist, create new one
            String insertSql = "INSERT INTO subjects (user_id, subject_name) VALUES (?, ?)";
            PreparedStatement insertStmt = conn.prepareStatement(insertSql, PreparedStatement.RETURN_GENERATED_KEYS);
            insertStmt.setInt(1, userId);
            insertStmt.setString(2, subjectName);
            
            int affectedRows = insertStmt.executeUpdate();
            if (affectedRows > 0) {
                ResultSet generatedKeys = insertStmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
            }
        }
        
        throw new SQLException("Failed to create or retrieve subject");
    }
    
    /**
     * Save event to database
     */
    private boolean saveEvent(Event event) {
        String sql = "INSERT INTO events (user_id, category_id, subject_id, title, description, " +
                    "event_date, event_time, duration_minutes, location, notes, reminder_minutes_before) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, event.getUserId());
            
            if (event.getCategoryId() > 0) {
                stmt.setInt(2, event.getCategoryId());
            } else {
                stmt.setNull(2, Types.INTEGER);
            }
            
            if (event.getSubjectId() > 0) {
                stmt.setInt(3, event.getSubjectId());
            } else {
                stmt.setNull(3, Types.INTEGER);
            }
            
            stmt.setString(4, event.getTitle());
            stmt.setString(5, event.getDescription());
            stmt.setDate(6, event.getEventDate());
            stmt.setTime(7, event.getEventTime());
            stmt.setInt(8, event.getDurationMinutes());
            stmt.setString(9, event.getLocation());
            stmt.setString(10, event.getNotes());
            stmt.setInt(11, event.getReminderMinutesBefore());
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error saving event: " + e.getMessage());
            return false;
        }
    }
}
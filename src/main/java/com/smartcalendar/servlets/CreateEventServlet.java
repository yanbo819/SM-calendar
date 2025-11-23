package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Types;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import com.smartcalendar.dao.NotificationDao;
import com.smartcalendar.models.Event;
import com.smartcalendar.models.User;
import com.smartcalendar.utils.DatabaseUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Servlet for creating events
 */
@WebServlet(urlPatterns = {"/create-event"})
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
        // additional optional reminders (up to 2 more)
        String reminder2 = request.getParameter("reminder2");
        String reminder3 = request.getParameter("reminder3");
        
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
                // Clamp reminder to allowed set {5,15,30,60,1440}
                int reminder = 15;
                try { if (reminderStr != null && !reminderStr.trim().isEmpty()) reminder = Integer.parseInt(reminderStr.trim()); } catch (NumberFormatException ignored) {}
                switch (reminder) {
                    case 5: case 15: case 30: case 60: case 1440: break;
                    default: reminder = 15;
                }
                event.setReminderMinutesBefore(reminder);
                
                // Save event
                int newEventId = saveEventAndReturnId(event);
                if (newEventId > 0) {
                    // If admin created this reminder/event, broadcast notification to all users
                    boolean isAdminCreator = user.getRole() != null && user.getRole().equalsIgnoreCase("admin");
                    if (isAdminCreator) {
                        broadcastAdminReminder(newEventId, event.getTitle(), event.getEventDate(), event.getEventTime());
                    }
                    // Always create a personal notification for the creator with creation time
                    try {
                        String createMsg = "Created event: " + event.getTitle() + " (" + event.getEventDate() + (event.getEventTime()!=null?" " + event.getEventTime().toString().substring(0,5):"") + ")";
                        NotificationDao.create(newEventId, user.getUserId(), createMsg, new java.sql.Timestamp(System.currentTimeMillis()));
                    } catch (SQLException ignored) {}
                    // Save extra reminders if provided and valid (dedupe against primary and each other)
                    String primary = String.valueOf(reminder);
                    if (reminder2 != null && !reminder2.equals(primary)) {
                        insertAdditionalReminder(newEventId, reminder2);
                    }
                    if (reminder3 != null && !reminder3.equals(primary) && (reminder2 == null || !reminder3.equals(reminder2))) {
                        insertAdditionalReminder(newEventId, reminder3);
                    }
                    response.sendRedirect("dashboard?success=Event+created+successfully");
                    return;
                } else {
                    errorMessage = "Failed to create event. Please try again.";
                }
                
            } catch (ParseException | NumberFormatException e) {
                errorMessage = "Invalid date/time or number format";
            } catch (SQLException e) {
                errorMessage = "Database error while creating event";
                System.err.println("SQL error creating event: " + e.getMessage());
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
    request.setAttribute("reminder2", reminder2);
    request.setAttribute("reminder3", reminder3);
        
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
    private int saveEventAndReturnId(Event event) {
        String sql = "INSERT INTO events (user_id, category_id, subject_id, title, description, " +
                    "event_date, event_time, duration_minutes, location, notes, reminder_minutes_before) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

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

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                ResultSet keys = stmt.getGeneratedKeys();
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error saving event: " + e.getMessage());
        }
        return -1;
    }

    private void insertAdditionalReminder(int eventId, String reminder) {
        if (reminder == null || reminder.trim().isEmpty()) return;
        int minutes;
        try {
            minutes = Integer.parseInt(reminder.trim());
        } catch (NumberFormatException e) {
            return;
        }
        switch (minutes) {
            case 5: case 15: case 30: case 60: case 1440: break;
            default: return;
        }
        String sql = "INSERT INTO event_reminders (event_id, minutes_before) VALUES (?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, eventId);
            stmt.setInt(2, minutes);
            stmt.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error saving additional reminder: " + e.getMessage());
        }
    }

    /**
     * Broadcast a notification for an admin-created reminder/event to all users.
     */
    private void broadcastAdminReminder(int eventId, String title, Date date, Time time) {
        String selectUsers = "SELECT user_id FROM users WHERE is_active = TRUE";
        String insertNotif = "INSERT INTO notifications (event_id, user_id, message, notification_time, is_sent) VALUES (?,?,?,?,FALSE)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement psUsers = conn.prepareStatement(selectUsers);
             ResultSet rs = psUsers.executeQuery()) {
            while (rs.next()) {
                int uid = rs.getInt(1);
                String msg = "New admin reminder: " + title + " (" + date + " " + (time != null ? time.toString().substring(0,5) : "") + ")";
                try (PreparedStatement psIns = conn.prepareStatement(insertNotif)) {
                    psIns.setInt(1, eventId);
                    psIns.setInt(2, uid);
                    psIns.setString(3, msg);
                    psIns.setTimestamp(4, new java.sql.Timestamp(System.currentTimeMillis()));
                    psIns.executeUpdate();
                }
            }
        } catch (SQLException e) {
            System.err.println("Error broadcasting admin reminder notifications: " + e.getMessage());
        }
    }
}
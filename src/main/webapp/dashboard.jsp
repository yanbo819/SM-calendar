<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.models.Event" %>
<%@ page import="com.smartcalendar.utils.LanguageUtil" %>
<%@ page import="com.smartcalendar.utils.DatabaseUtil" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String lang = "en";
    String textDir = "ltr";
    
    // Get upcoming events for dashboard preview
    List<Event> upcomingEvents = new ArrayList<Event>();
    Connection conn = null;
    try {
        conn = DatabaseUtil.getConnection();
        String sql = "SELECT e.event_id, e.title, e.event_date, e.event_time, e.location, " +
                    "c.category_name, c.category_color, s.subject_name " +
                    "FROM events e " +
                    "LEFT JOIN categories c ON e.category_id = c.category_id " +
                    "LEFT JOIN subjects s ON e.subject_id = s.subject_id " +
                    "WHERE e.user_id = ? AND e.event_date >= CURRENT_DATE AND e.is_active = TRUE " +
                    "ORDER BY e.event_date ASC, e.event_time ASC LIMIT 5";
        
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, user.getUserId());
        ResultSet rs = stmt.executeQuery();
        
        while (rs.next()) {
            Event event = new Event();
            event.setEventId(rs.getInt("event_id"));
            event.setTitle(rs.getString("title"));
            event.setEventDate(rs.getDate("event_date"));
            event.setEventTime(rs.getTime("event_time"));
            event.setLocation(rs.getString("location"));
            event.setCategoryName(rs.getString("category_name"));
            event.setCategoryColor(rs.getString("category_color"));
            event.setSubjectName(rs.getString("subject_name"));
            upcomingEvents.add(event);
        }
    } catch (SQLException e) {
        // Error fetching upcoming events: " + e.getMessage()
    } finally {
        if (conn != null) {
            try { conn.close(); } catch (SQLException e) {}
        }
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= LanguageUtil.getText(lang, "app.title") %> - Dashboard</title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/dashboard.css">
</head>
<body>
    <!-- Animated background behind tiles -->
    <div class="dashboard-bg">
        <div class="orb orb-1"></div>
        <div class="orb orb-2"></div>
        <div class="orb orb-3"></div>
    </div>
    <nav class="main-nav">
        <div class="nav-container">
            <h1 class="nav-title"><%= LanguageUtil.getText(lang, "app.title") %></h1>
            <div class="nav-actions">
                <span class="user-welcome">
                    <%= LanguageUtil.getText(lang, "dashboard.welcome") %>, <%= user.getFullName() %>!
                </span>
                <a href="logout" class="btn btn-outline">
                    <%= LanguageUtil.getText(lang, "nav.logout") %>
                </a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <div class="tiles-grid">
            <!-- Tile 1: My Events with quick stats and next upcoming -->
            <a class="tile tile-events" href="events.jsp">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">📅</span>
                        <h3>My Events</h3>
                    </div>
                    <div class="tile-stats">
                        <%
                            int todayEvents = 0;
                            int weekEvents = 0;
                            int totalEvents = 0;
                            Connection conn2 = null;
                            try {
                                conn2 = DatabaseUtil.getConnection();
                                PreparedStatement stmt1 = conn2.prepareStatement(
                                    "SELECT COUNT(*) FROM events WHERE user_id = ? AND event_date = CURRENT_DATE AND is_active = TRUE");
                                stmt1.setInt(1, user.getUserId());
                                ResultSet rs1 = stmt1.executeQuery();
                                if (rs1.next()) todayEvents = rs1.getInt(1);
                                PreparedStatement stmt2 = conn2.prepareStatement(
                                    "SELECT COUNT(*) FROM events WHERE user_id = ? AND event_date BETWEEN CURRENT_DATE AND DATEADD('DAY', 7, CURRENT_DATE) AND is_active = TRUE");
                                stmt2.setInt(1, user.getUserId());
                                ResultSet rs2 = stmt2.executeQuery();
                                if (rs2.next()) weekEvents = rs2.getInt(1);
                                PreparedStatement stmt3 = conn2.prepareStatement(
                                    "SELECT COUNT(*) FROM events WHERE user_id = ? AND is_active = TRUE");
                                stmt3.setInt(1, user.getUserId());
                                ResultSet rs3 = stmt3.executeQuery();
                                if (rs3.next()) totalEvents = rs3.getInt(1);
                            } catch (SQLException e) { /* ignore */ } finally { if (conn2 != null) { try { conn2.close(); } catch (SQLException e) {} } }
                        %>
                        <div class="stat"><span class="stat-number"><%= todayEvents %></span><span class="stat-label">Today</span></div>
                        <div class="stat"><span class="stat-number"><%= weekEvents %></span><span class="stat-label">This Week</span></div>
                        <div class="stat"><span class="stat-number"><%= totalEvents %></span><span class="stat-label">Total</span></div>
                    </div>
                    <div class="tile-upcoming">
                        <% if (upcomingEvents.isEmpty()) { %>
                            <div class="upcoming-empty">No upcoming events</div>
                        <% } else { Event next = upcomingEvents.get(0); %>
                            <div class="upcoming-row">
                                <div class="upcoming-when"><%= dateFormat.format(next.getEventDate()) %> · <%= timeFormat.format(next.getEventTime()) %></div>
                                <div class="upcoming-title"><%= next.getTitle() %></div>
                            </div>
                        <% } %>
                    </div>
                </div>
                <span class="tile-cta">Open →</span>
            </a>

            <!-- Tile 2: Create Reminder -->
            <a class="tile tile-create" href="create-reminder.jsp">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">➕</span>
                        <h3>Create Reminder</h3>
                    </div>
                    <p class="tile-desc">Add a new meeting, exam, course, or activity with a reminder.</p>
                </div>
                <span class="tile-cta">Create →</span>
            </a>

            <!-- Tile 3: Upload Schedule -->
            <a class="tile tile-upload" href="schedule-upload.jsp">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">⬆️</span>
                        <h3>Upload Schedule</h3>
                    </div>
                    <p class="tile-desc">Import your course schedule from a CSV file in seconds.</p>
                </div>
                <span class="tile-cta">Upload →</span>
            </a>

            <!-- Tile 4: Colleges Info -->
            <a class="tile tile-colleges" href="colleges-info.jsp">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">🏫</span>
                        <h3>Colleges Info</h3>
                    </div>
                    <p class="tile-desc">Browse colleges information and helpful links.</p>
                </div>
                <span class="tile-cta">Browse →</span>
            </a>
        </div>
    </div>

    <script>
        // Request notification permission when page loads
        document.addEventListener('DOMContentLoaded', function() {
            if ('Notification' in window && Notification.permission === 'default') {
                Notification.requestPermission();
            }
        });
    </script>
</body>
</html>
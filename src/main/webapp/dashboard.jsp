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
        <div class="dashboard-header">
            <h2>Dashboard</h2>
            <div class="quick-actions">
                <a href="create-event.jsp" class="btn btn-primary">
                    <i class="icon-calendar"></i>
                    <%= LanguageUtil.getText(lang, "dashboard.create_calendar") %>
                </a>
                <a href="create-reminder.jsp" class="btn btn-secondary">
                    <i class="icon-bell"></i>
                    <%= LanguageUtil.getText(lang, "dashboard.create_reminder") %>
                </a>
                <a href="events.jsp" class="btn btn-outline">
                    <i class="icon-list"></i>
                    <%= LanguageUtil.getText(lang, "dashboard.view_events") %>
                </a>
            </div>
        </div>

        <div class="dashboard-grid">
            <div class="dashboard-card">
                <h3>Upcoming Events</h3>
                <div class="events-preview">
                    <% if (upcomingEvents.isEmpty()) { %>
                        <p class="no-events">No upcoming events</p>
                    <% } else { %>
                        <% for (Event event : upcomingEvents) { %>
                        <div class="event-preview-item">
                            <div class="event-date">
                                <span class="date"><%= dateFormat.format(event.getEventDate()) %></span>
                                <span class="time"><%= timeFormat.format(event.getEventTime()) %></span>
                            </div>
                            <div class="event-details">
                                <h4 class="event-title"><%= event.getTitle() %></h4>
                                <% if (event.getCategoryName() != null) { %>
                                <span class="event-category" style="background-color: <%= event.getCategoryColor() %>">
                                    <%= event.getCategoryName() %>
                                </span>
                                <% } %>
                                <% if (event.getLocation() != null && !event.getLocation().trim().isEmpty()) { %>
                                <p class="event-location">
                                    <i class="icon-location"></i>
                                    <%= event.getLocation() %>
                                </p>
                                <% } %>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
                <% if (!upcomingEvents.isEmpty()) { %>
                <a href="events.jsp" class="view-all-link">View All Events →</a>
                <% } %>
            </div>

            <div class="dashboard-card">
                <h3>Quick Stats</h3>
                <div class="stats-grid">
                    <%
                        int todayEvents = 0;
                        int weekEvents = 0;
                        int totalEvents = 0;
                        Connection conn2 = null;
                        
                        try {
                            conn2 = DatabaseUtil.getConnection();
                            // Today's events
                            PreparedStatement stmt1 = conn2.prepareStatement(
                                "SELECT COUNT(*) FROM events WHERE user_id = ? AND event_date = CURRENT_DATE AND is_active = TRUE"
                            );
                            stmt1.setInt(1, user.getUserId());
                            ResultSet rs1 = stmt1.executeQuery();
                            if (rs1.next()) todayEvents = rs1.getInt(1);
                            
                            // This week's events
                            PreparedStatement stmt2 = conn2.prepareStatement(
                                "SELECT COUNT(*) FROM events WHERE user_id = ? AND event_date BETWEEN CURRENT_DATE AND DATEADD('DAY', 7, CURRENT_DATE) AND is_active = TRUE"
                            );
                            stmt2.setInt(1, user.getUserId());
                            ResultSet rs2 = stmt2.executeQuery();
                            if (rs2.next()) weekEvents = rs2.getInt(1);
                            
                            // Total events
                            PreparedStatement stmt3 = conn2.prepareStatement(
                                "SELECT COUNT(*) FROM events WHERE user_id = ? AND is_active = TRUE"
                            );
                            stmt3.setInt(1, user.getUserId());
                            ResultSet rs3 = stmt3.executeQuery();
                            if (rs3.next()) totalEvents = rs3.getInt(1);
                        } catch (SQLException e) {
                            // Error fetching stats: " + e.getMessage()
                        } finally {
                            if (conn2 != null) {
                                try { conn2.close(); } catch (SQLException e) {}
                            }
                        }
                    %>
                    <div class="stat-item">
                        <span class="stat-number"><%= todayEvents %></span>
                        <span class="stat-label">Today</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-number"><%= weekEvents %></span>
                        <span class="stat-label">This Week</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-number"><%= totalEvents %></span>
                        <span class="stat-label">Total Events</span>
                    </div>
                </div>
            </div>

            <div class="dashboard-card">
                <h3>Search Events</h3>
                <form action="events.jsp" method="get" class="search-form">
                    <div class="form-group">
                        <input type="text" name="search" placeholder="<%= LanguageUtil.getText(lang, "dashboard.search_events") %>" class="form-control">
                    </div>
                    <div class="form-group">
                        <select name="category" class="form-control">
                            <option value="">All Categories</option>
                            <%
                                Connection conn3 = null;
                                try {
                                    conn3 = DatabaseUtil.getConnection();
                                    PreparedStatement stmt = conn3.prepareStatement("SELECT category_id, category_name FROM categories ORDER BY category_name");
                                    ResultSet rs = stmt.executeQuery();
                                    while (rs.next()) {
                            %>
                                <option value="<%= rs.getInt("category_id") %>"><%= rs.getString("category_name") %></option>
                            <%
                                    }
                                } catch (SQLException e) {
                                    // Error fetching categories: " + e.getMessage()
                                } finally {
                                    if (conn3 != null) {
                                        try { conn3.close(); } catch (SQLException e) {}
                                    }
                                }
                            %>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-primary btn-small">Search</button>
                </form>
            </div>
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
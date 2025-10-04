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
    
    // Get search parameters
    String searchQuery = request.getParameter("search");
    String categoryFilter = request.getParameter("category");
    String dateFrom = request.getParameter("dateFrom");
    String dateTo = request.getParameter("dateTo");
    String sortBy = request.getParameter("sortBy");
    if (sortBy == null) sortBy = "date_asc";
    
    // Build SQL query with filters
    StringBuilder sql = new StringBuilder();
    sql.append("SELECT e.event_id, e.title, e.description, e.event_date, e.event_time, ");
    sql.append("e.duration_minutes, e.location, e.notes, e.reminder_minutes_before, ");
    sql.append("c.category_name, c.category_color, s.subject_name ");
    sql.append("FROM events e ");
    sql.append("LEFT JOIN categories c ON e.category_id = c.category_id ");
    sql.append("LEFT JOIN subjects s ON e.subject_id = s.subject_id ");
    sql.append("WHERE e.user_id = ? AND e.is_active = TRUE ");
    
    List<Object> parameters = new ArrayList<Object>();
    parameters.add(user.getUserId());
    
    // Add search filter
    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
        sql.append("AND (e.title LIKE ? OR e.description LIKE ? OR e.location LIKE ? OR e.notes LIKE ?) ");
        String searchPattern = "%" + searchQuery.trim() + "%";
        parameters.add(searchPattern);
        parameters.add(searchPattern);
        parameters.add(searchPattern);
        parameters.add(searchPattern);
    }
    
    // Add category filter
    if (categoryFilter != null && !categoryFilter.trim().isEmpty()) {
        sql.append("AND e.category_id = ? ");
        parameters.add(Integer.parseInt(categoryFilter));
    }
    
    // Add date range filter
    if (dateFrom != null && !dateFrom.trim().isEmpty()) {
        sql.append("AND e.event_date >= ? ");
        parameters.add(java.sql.Date.valueOf(dateFrom));
    }
    
    if (dateTo != null && !dateTo.trim().isEmpty()) {
        sql.append("AND e.event_date <= ? ");
        parameters.add(java.sql.Date.valueOf(dateTo));
    }
    
    // Add sorting
    if ("date_desc".equals(sortBy)) {
        sql.append("ORDER BY e.event_date DESC, e.event_time DESC");
    } else if ("title_asc".equals(sortBy)) {
        sql.append("ORDER BY e.title ASC");
    } else if ("title_desc".equals(sortBy)) {
        sql.append("ORDER BY e.title DESC");
    } else if ("category".equals(sortBy)) {
        sql.append("ORDER BY c.category_name ASC, e.event_date ASC");
    } else { // date_asc
        sql.append("ORDER BY e.event_date ASC, e.event_time ASC");
    }
    
    // Get events
    List<Event> events = new ArrayList<Event>();
    Connection conn = null;
    try {
        conn = DatabaseUtil.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql.toString());
        
        for (int i = 0; i < parameters.size(); i++) {
            Object param = parameters.get(i);
            if (param instanceof Integer) {
                stmt.setInt(i + 1, (Integer) param);
            } else if (param instanceof java.sql.Date) {
                stmt.setDate(i + 1, (java.sql.Date) param);
            } else {
                stmt.setString(i + 1, param.toString());
            }
        }
        
        ResultSet rs = stmt.executeQuery();
        
        while (rs.next()) {
            Event event = new Event();
            event.setEventId(rs.getInt("event_id"));
            event.setTitle(rs.getString("title"));
            event.setDescription(rs.getString("description"));
            event.setEventDate(rs.getDate("event_date"));
            event.setEventTime(rs.getTime("event_time"));
            event.setDurationMinutes(rs.getInt("duration_minutes"));
            event.setLocation(rs.getString("location"));
            event.setNotes(rs.getString("notes"));
            event.setReminderMinutesBefore(rs.getInt("reminder_minutes_before"));
            event.setCategoryName(rs.getString("category_name"));
            event.setCategoryColor(rs.getString("category_color"));
            event.setSubjectName(rs.getString("subject_name"));
            events.add(event);
        }
    } catch (SQLException e) {
        // Error fetching events: " + e.getMessage()
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
    <title><%= LanguageUtil.getText(lang, "app.title") %> - Events</title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/events.css">
</head>
<body data-user-id="<%= user.getUserId() %>">
    <nav class="main-nav">
        <div class="nav-container">
            <h1 class="nav-title">
                <a href="dashboard.jsp"><%= LanguageUtil.getText(lang, "app.title") %></a>
            </h1>
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

    <div class="events-container">
        <div class="events-header">
            <h2>My Events</h2>
            <div class="header-actions">
                <a href="create-event.jsp" class="btn btn-primary">
                    <i class="icon-plus"></i>
                    Create New Event
                </a>
                <a href="dashboard.jsp" class="btn btn-outline">
                    ← Back to Dashboard
                </a>
            </div>
        </div>

        <!-- Search and Filter Form -->
        <div class="search-filters">
            <form method="get" action="events.jsp" class="filter-form">
                <div class="filter-row">
                    <div class="filter-group">
                        <input type="text" name="search" placeholder="<%= LanguageUtil.getText(lang, "dashboard.search_events") %>" 
                               value="<%= searchQuery != null ? searchQuery : "" %>" class="form-control">
                    </div>
                    
                    <div class="filter-group">
                        <select name="category" class="form-control">
                            <option value="">All Categories</option>
                            <%
                                Connection conn2 = null;
                                try {
                                    conn2 = DatabaseUtil.getConnection();
                                    PreparedStatement stmt = conn2.prepareStatement("SELECT category_id, category_name FROM categories ORDER BY category_name");
                                    ResultSet rs = stmt.executeQuery();
                                    while (rs.next()) {
                                        String selected = String.valueOf(rs.getInt("category_id")).equals(categoryFilter) ? "selected" : "";
                            %>
                                <option value="<%= rs.getInt("category_id") %>" <%= selected %>>
                                    <%= rs.getString("category_name") %>
                                </option>
                            <%
                                    }
                                } catch (SQLException e) {
                                    // Error fetching categories: " + e.getMessage()
                                } finally {
                                    if (conn2 != null) {
                                        try { conn2.close(); } catch (SQLException e) {}
                                    }
                                }
                            %>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <input type="date" name="dateFrom" placeholder="From Date" 
                               value="<%= dateFrom != null ? dateFrom : "" %>" class="form-control">
                    </div>
                    
                    <div class="filter-group">
                        <input type="date" name="dateTo" placeholder="To Date" 
                               value="<%= dateTo != null ? dateTo : "" %>" class="form-control">
                    </div>
                    
                    <div class="filter-group">
                        <select name="sortBy" class="form-control">
                            <option value="date_asc" <%= "date_asc".equals(sortBy) ? "selected" : "" %>>Date (Oldest First)</option>
                            <option value="date_desc" <%= "date_desc".equals(sortBy) ? "selected" : "" %>>Date (Newest First)</option>
                            <option value="title_asc" <%= "title_asc".equals(sortBy) ? "selected" : "" %>>Title (A-Z)</option>
                            <option value="title_desc" <%= "title_desc".equals(sortBy) ? "selected" : "" %>>Title (Z-A)</option>
                            <option value="category" <%= "category".equals(sortBy) ? "selected" : "" %>>Category</option>
                        </select>
                    </div>
                    
                    <div class="filter-actions">
                        <button type="submit" class="btn btn-primary">Search</button>
                        <a href="events.jsp" class="btn btn-secondary">Clear</a>
                    </div>
                </div>
            </form>
        </div>

        <!-- Events List -->
        <div class="events-list">
            <% if (events.isEmpty()) { %>
                <div class="no-events">
                    <h3>No events found</h3>
                    <p>
                        <% if (searchQuery != null || categoryFilter != null || dateFrom != null || dateTo != null) { %>
                            Try adjusting your search filters or
                        <% } %>
                        <a href="create-event.jsp">create your first event</a>.
                    </p>
                </div>
            <% } else { %>
                <div class="events-stats">
                    Found <%= events.size() %> event<%= events.size() != 1 ? "s" : "" %>
                </div>
                
                <% 
                    java.sql.Date currentDate = null;
                    for (Event event : events) { 
                        // Group by date
                        if (currentDate == null || !currentDate.equals(event.getEventDate())) {
                            currentDate = event.getEventDate();
                %>
                    <div class="date-group">
                        <h3 class="date-header"><%= dateFormat.format(currentDate) %></h3>
                <% } %>
                
                        <div class="event-card">
                            <div class="event-time">
                                <span class="time"><%= timeFormat.format(event.getEventTime()) %></span>
                                <% if (event.getDurationMinutes() > 0) { %>
                                    <span class="duration"><%= event.getDurationMinutes() %> min</span>
                                <% } %>
                            </div>
                            
                            <div class="event-content">
                                <div class="event-header">
                                    <h4 class="event-title"><%= event.getTitle() %></h4>
                                    <% if (event.getCategoryName() != null) { %>
                                    <span class="event-category" style="background-color: <%= event.getCategoryColor() %>">
                                        <%= event.getCategoryName() %>
                                    </span>
                                    <% } %>
                                </div>
                                
                                <% if (event.getSubjectName() != null) { %>
                                <div class="event-subject">
                                    <i class="icon-book"></i>
                                    Subject: <%= event.getSubjectName() %>
                                </div>
                                <% } %>
                                
                                <% if (event.getDescription() != null && !event.getDescription().trim().isEmpty()) { %>
                                <div class="event-description">
                                    <%= event.getDescription() %>
                                </div>
                                <% } %>
                                
                                <% if (event.getLocation() != null && !event.getLocation().trim().isEmpty()) { %>
                                <div class="event-location">
                                    <i class="icon-location"></i>
                                    <%= event.getLocation() %>
                                </div>
                                <% } %>
                                
                                <div class="event-reminder">
                                    <i class="icon-bell"></i>
                                    Reminder: 
                                    <% 
                                        int minutes = event.getReminderMinutesBefore();
                                        if (minutes < 60) {
                                    %>
                                        <%= minutes %> minutes before
                                    <% } else { %>
                                        <%= minutes / 60 %> hour<%= minutes >= 120 ? "s" : "" %> before
                                    <% } %>
                                </div>
                                
                                <% if (event.getNotes() != null && !event.getNotes().trim().isEmpty()) { %>
                                <div class="event-notes">
                                    <i class="icon-note"></i>
                                    Notes: <%= event.getNotes() %>
                                </div>
                                <% } %>
                            </div>
                            
                            <div class="event-actions">
                                <a href="edit-event.jsp?id=<%= event.getEventId() %>" class="btn btn-small btn-outline">
                                    Edit
                                </a>
                                <a href="delete-event.jsp?id=<%= event.getEventId() %>" 
                                   class="btn btn-small btn-danger" 
                                   onclick="return confirm('Are you sure you want to delete this event?')">
                                    Delete
                                </a>
                            </div>
                        </div>
                
                <% 
                        // Check if this is the last event or if the next event has a different date
                        int currentIndex = events.indexOf(event);
                        boolean isLastEvent = currentIndex == events.size() - 1;
                        boolean nextEventDifferentDate = !isLastEvent && 
                            !events.get(currentIndex + 1).getEventDate().equals(currentDate);
                        
                        if (isLastEvent || nextEventDifferentDate) {
                %>
                    </div> <!-- Close date-group -->
                <% 
                        }
                    } 
                %>
            <% } %>
        </div>
    </div>

    <!-- Include notification system -->
    <script src="js/notifications.js"></script>
    
    <script>
        // Auto-submit form when filters change
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.querySelector('.filter-form');
            const selects = form.querySelectorAll('select');
            const dateInputs = form.querySelectorAll('input[type="date"]');
            
            selects.forEach(select => {
                select.addEventListener('change', () => {
                    form.submit();
                });
            });
            
            dateInputs.forEach(input => {
                input.addEventListener('change', () => {
                    form.submit();
                });
            });
            
            // Search on Enter key
            const searchInput = form.querySelector('input[name="search"]');
            searchInput.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    form.submit();
                }
            });
        });
    </script>
</body>
</html>
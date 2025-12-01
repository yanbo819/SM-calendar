<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.models.Event" %>
<%@ page import="com.smartcalendar.models.Category" %>
<%@ page import="com.smartcalendar.utils.LanguageUtil" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    String lang = (String) request.getAttribute("lang");
    if (lang == null) lang = (String) session.getAttribute("lang");
    if (lang == null) lang = "en";
    String textDir = (String) request.getAttribute("textDir");
    if (textDir == null) textDir = LanguageUtil.getTextDirection(lang);
    @SuppressWarnings("unchecked") List<Event> events = (List<Event>) request.getAttribute("events");
    if (events == null) events = Collections.emptyList();
    @SuppressWarnings("unchecked") List<Category> categories = (List<Category>) request.getAttribute("categories");
    if (categories == null) categories = Collections.emptyList();
    String searchQuery = (String) request.getAttribute("search");
    String categoryFilter = (String) request.getAttribute("category");
    String dateFrom = (String) request.getAttribute("dateFrom");
    String dateTo = (String) request.getAttribute("dateTo");
    String sortBy = (String) request.getAttribute("sortBy");
    String loadError = (String) request.getAttribute("loadError");
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= LanguageUtil.getText(lang, "app.title") %> - <%= LanguageUtil.getText(lang, "events.title") %></title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/events.css">
</head>
<body data-user-id="<%= user.getUserId() %>">
    <%@ include file="/WEB-INF/jspf/flash-messages.jspf" %>
    <nav class="main-nav">
        <div class="nav-container">
            <h1 class="nav-title">
                <a href="dashboard"><%= LanguageUtil.getText(lang, "app.title") %></a>
            </h1>
            <div class="nav-actions">
                <span class="user-welcome">
                    <%= LanguageUtil.getText(lang, "dashboard.welcome") %>, <%= user.getFullName() %>!
                </span>
                
            </div>
        </div>
    </nav>

    <div class="events-container">
        <div class="events-header">
            <h2><%= LanguageUtil.getText(lang, "events.myEvents") %></h2>
            <div class="header-actions">
                <a href="create-event.jsp" class="btn btn-primary">
                    <i class="icon-plus"></i>
                    <%= LanguageUtil.getText(lang, "events.createNew") %>
                </a>
                <a href="dashboard" class="btn btn-outline">
                    ← <%= LanguageUtil.getText(lang, "events.backDashboard") %>
                </a>
            </div>
        </div>

        <!-- Search and Filter Form -->
        <div class="search-filters">
            <form method="get" action="events" class="filter-form">
                <div class="filter-row">
                    <div class="filter-group">
                        <input type="text" name="search" placeholder="<%= LanguageUtil.getText(lang, "dashboard.search_events") %>" 
                               value="<%= searchQuery != null ? searchQuery : "" %>" class="form-control">
                    </div>
                    
                    <div class="filter-group">
                        <select name="category" class="form-control">
                            <option value=""><%= LanguageUtil.getText(lang, "events.allCategories") %></option>
                            <% for (Category c : categories) { %>
                                <option value="<%= c.getCategoryId() %>" <%= String.valueOf(c.getCategoryId()).equals(categoryFilter) ? "selected" : "" %>>
                                    <%= c.getCategoryName() %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <input type="date" name="dateFrom" placeholder="<%= LanguageUtil.getText(lang, "events.fromDate") %>" 
                               value="<%= dateFrom != null ? dateFrom : "" %>" class="form-control">
                    </div>
                    
                    <div class="filter-group">
                        <input type="date" name="dateTo" placeholder="<%= LanguageUtil.getText(lang, "events.toDate") %>" 
                               value="<%= dateTo != null ? dateTo : "" %>" class="form-control">
                    </div>
                    
                    <div class="filter-group">
                        <select name="sortBy" class="form-control">
                            <option value="date_asc" <%= "date_asc".equals(sortBy) ? "selected" : "" %>><%= LanguageUtil.getText(lang, "events.sort.dateAsc") %></option>
                            <option value="date_desc" <%= "date_desc".equals(sortBy) ? "selected" : "" %>><%= LanguageUtil.getText(lang, "events.sort.dateDesc") %></option>
                            <option value="title_asc" <%= "title_asc".equals(sortBy) ? "selected" : "" %>><%= LanguageUtil.getText(lang, "events.sort.titleAsc") %></option>
                            <option value="title_desc" <%= "title_desc".equals(sortBy) ? "selected" : "" %>><%= LanguageUtil.getText(lang, "events.sort.titleDesc") %></option>
                            <option value="category" <%= "category".equals(sortBy) ? "selected" : "" %>><%= LanguageUtil.getText(lang, "events.sort.category") %></option>
                        </select>
                    </div>
                    
                    <div class="filter-actions">
                        <button type="submit" class="btn btn-primary"><%= LanguageUtil.getText(lang, "events.search") %></button>
                        <a href="events" class="btn btn-secondary"><%= LanguageUtil.getText(lang, "events.clear") %></a>
                    </div>
                </div>
            </form>
        </div>

        <!-- Events List -->
        <div class="events-list">
            <% if (loadError != null) { %>
                <div class="error-box" style="background:#fee2e2;color:#b91c1c;padding:12px;border-radius:6px;margin-bottom:12px;">
                    <strong><%= LanguageUtil.getText(lang, "common.error") %>:</strong> <%= loadError %>
                </div>
            <% } %>
            <% if (events.isEmpty()) { %>
                <div class="no-events">
                    <h3><%= LanguageUtil.getText(lang, "events.noneFound") %></h3>
                    <p>
                        <% if (searchQuery != null || categoryFilter != null || dateFrom != null || dateTo != null) { %>
                            <%= LanguageUtil.getText(lang, "events.adjustFilters") %>
                        <% } %>
                        <a href="create-event.jsp"><%= LanguageUtil.getText(lang, "events.createFirst") %></a>.
                    </p>
                </div>
            <% } else { %>
                <div class="events-stats">
                    <%= LanguageUtil.getText(lang, "events.foundPrefix") %> <%= events.size() %> <%= events.size() == 1 ? LanguageUtil.getText(lang, "events.countSingular") : LanguageUtil.getText(lang, "events.countPlural") %>
                </div>
                
                <% 
                    java.util.Date currentDate = null;
                    for (int i = 0; i < events.size(); i++) { 
                        Event event = events.get(i);
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
                                    <%= LanguageUtil.getText(lang, "events.subject") %>: <%= event.getSubjectName() %>
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
                                    <%= LanguageUtil.getText(lang, "events.reminder") %>: 
                                    <% 
                                        int minutes = event.getReminderMinutesBefore();
                                        if (minutes < 60) {
                                    %>
                                        <%= minutes %> <%= LanguageUtil.getText(lang, "events.minutesBefore") %>
                                    <% } else { %>
                                        <%= minutes / 60 %> <%= minutes >= 120 ? LanguageUtil.getText(lang, "events.hoursBeforePlural") : LanguageUtil.getText(lang, "events.hoursBeforeSingular") %>
                                    <% } %>
                                </div>
                                
                                <% if (event.getNotes() != null && !event.getNotes().trim().isEmpty()) { %>
                                <div class="event-notes">
                                    <i class="icon-note"></i>
                                    <%= LanguageUtil.getText(lang, "events.notes") %>: <%= event.getNotes() %>
                                </div>
                                <% } %>
                            </div>
                            
                            <div class="event-actions">
                                <% if (event.getUserId() == user.getUserId()) { %>
                                    <a href="edit-event.jsp?id=<%= event.getEventId() %>" class="btn btn-small btn-outline">
                                        <%= LanguageUtil.getText(lang, "common.edit") %>
                                    </a>
                                    <form method="post" action="delete-event" style="display:inline" onsubmit="return confirm('<%= LanguageUtil.getText(lang, "events.confirmDelete") %>')">
                                        <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
                                        <input type="hidden" name="id" value="<%= event.getEventId() %>">
                                        <button type="submit" class="btn btn-small btn-danger"><%= LanguageUtil.getText(lang, "common.delete") %></button>
                                    </form>
                                <% } else { %>
                                    <span class="locked-tag" style="font-size:.75rem;color:#6b7280;display:inline-flex;align-items:center;gap:4px;">🔒 Admin</span>
                                <% } %>
                            </div>
                        </div>
                
                <% 
                        // Check if this is the last event or if the next event has a different date
                        boolean isLastEvent = i == events.size() - 1;
                        boolean nextEventDifferentDate = !isLastEvent && 
                            !events.get(i + 1).getEventDate().equals(currentDate);
                        
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
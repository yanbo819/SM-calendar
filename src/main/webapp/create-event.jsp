<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.utils.LanguageUtil" %>
<%@ page import="com.smartcalendar.utils.DatabaseUtil" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String lang = "en";
    String textDir = "ltr";
    String errorMessage = (String) request.getAttribute("errorMessage");
    
    // Get form values for repopulation on error
    String title = (String) request.getAttribute("title");
    String categoryId = (String) request.getAttribute("categoryId");
    String subjectName = (String) request.getAttribute("subjectName");
    String existingSubjectId = (String) request.getAttribute("existingSubjectId");
    String description = (String) request.getAttribute("description");
    String eventDate = (String) request.getAttribute("eventDate");
    String eventTime = (String) request.getAttribute("eventTime");
    String duration = (String) request.getAttribute("duration");
    String location = (String) request.getAttribute("location");
    String notes = (String) request.getAttribute("notes");
    String reminderMinutes = (String) request.getAttribute("reminderMinutes");
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= LanguageUtil.getText(lang, "app.title") %> - Create Event</title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/forms.css">
</head>
<body>
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

    <div class="form-container">
        <div class="form-header">
            <h2>Create New Event</h2>
            <a href="dashboard.jsp" class="btn btn-outline">← Back to Dashboard</a>
        </div>

        <% if (errorMessage != null) { %>
        <div class="alert alert-error">
            <%= errorMessage %>
        </div>
        <% } %>

        <form method="post" action="create-event" class="event-form">
            <div class="form-row">
                <div class="form-group">
                    <input type="text" id="title" name="title" required maxlength="255"
                           value="<%= title != null ? title : "" %>"
                           placeholder="<%= LanguageUtil.getText(lang, "event.title") %>">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <select id="categoryId" name="categoryId" class="form-control">
                        <option value=""><%= LanguageUtil.getText(lang, "event.category") %></option>
                        <%
                            Connection conn = null;
                            try {
                                conn = DatabaseUtil.getConnection();
                                PreparedStatement stmt = conn.prepareStatement("SELECT category_id, category_name, category_color FROM categories ORDER BY category_name");
                                ResultSet rs = stmt.executeQuery();
                                while (rs.next()) {
                                    String selected = String.valueOf(rs.getInt("category_id")).equals(categoryId) ? "selected" : "";
                        %>
                            <option value="<%= rs.getInt("category_id") %>" <%= selected %> data-color="<%= rs.getString("category_color") %>">
                                <%= rs.getString("category_name") %>
                            </option>
                        <%
                                }
                            } catch (SQLException e) {
                                // Error fetching categories: " + e.getMessage()
                            } finally {
                                if (conn != null) {
                                    try { conn.close(); } catch (SQLException e) {}
                                }
                            }
                        %>
                    </select>
                </div>

                <div class="form-group">
                    <div class="subject-selector">
                        <label class="radio-label">
                            <input type="radio" name="subjectType" value="existing" onchange="toggleSubjectInput()" 
                                   <%= (existingSubjectId != null && !existingSubjectId.isEmpty()) ? "checked" : "" %>>
                            Use Existing Subject
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="subjectType" value="new" onchange="toggleSubjectInput()" 
                                   <%= (subjectName != null && !subjectName.isEmpty()) || (existingSubjectId == null || existingSubjectId.isEmpty()) ? "checked" : "" %>>
                            Create New Subject
                        </label>
                    </div>
                    
                    <select id="existingSubjectId" name="existingSubjectId" class="form-control" 
                            style="<%= (existingSubjectId == null || existingSubjectId.isEmpty()) ? "display:none" : "" %>">
                        <option value=""><%= LanguageUtil.getText(lang, "event.subject") %></option>
                        <%
                            Connection conn2 = null;
                            try {
                                conn2 = DatabaseUtil.getConnection();
                                PreparedStatement stmt = conn2.prepareStatement("SELECT subject_id, subject_name FROM subjects WHERE user_id = ? ORDER BY subject_name");
                                stmt.setInt(1, user.getUserId());
                                ResultSet rs = stmt.executeQuery();
                                while (rs.next()) {
                                    String selected = String.valueOf(rs.getInt("subject_id")).equals(existingSubjectId) ? "selected" : "";
                        %>
                            <option value="<%= rs.getInt("subject_id") %>" <%= selected %>>
                                <%= rs.getString("subject_name") %>
                            </option>
                        <%
                                }
                            } catch (SQLException e) {
                                // Error fetching subjects: " + e.getMessage()
                            } finally {
                                if (conn2 != null) {
                                    try { conn2.close(); } catch (SQLException e) {}
                                }
                            }
                        %>
                    </select>
                    
                    <input type="text" id="subjectName" name="subjectName" class="form-control" 
                           placeholder="<%= LanguageUtil.getText(lang, "event.subject") %>" maxlength="100"
                           value="<%= subjectName != null ? subjectName : "" %>"
                           style="<%= (existingSubjectId != null && !existingSubjectId.isEmpty()) ? "display:none" : "" %>">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <input type="date" id="eventDate" name="eventDate" required
                           value="<%= eventDate != null ? eventDate : "" %>">
                </div>

                <div class="form-group">
                    <input type="time" id="eventTime" name="eventTime" required
                           value="<%= eventTime != null ? eventTime : "" %>">
                </div>

                <div class="form-group">
                    <select id="duration" name="duration" class="form-control">
                        <option value=""> <%= LanguageUtil.getText(lang, "event.duration") %> </option>
                        <option value="30" <%= "30".equals(duration) ? "selected" : "" %>>30 minutes</option>
                        <option value="60" <%= duration == null || "60".equals(duration) ? "selected" : "" %>>1 hour</option>
                        <option value="90" <%= "90".equals(duration) ? "selected" : "" %>>1.5 hours</option>
                        <option value="120" <%= "120".equals(duration) ? "selected" : "" %>>2 hours</option>
                        <option value="180" <%= "180".equals(duration) ? "selected" : "" %>>3 hours</option>
                        <option value="240" <%= "240".equals(duration) ? "selected" : "" %>>4 hours</option>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <input type="text" id="location" name="location" maxlength="255"
                           value="<%= location != null ? location : "" %>"
                           placeholder="<%= LanguageUtil.getText(lang, "event.location") %>">
                </div>

                <div class="form-group">
                    <select id="reminderMinutes" name="reminderMinutes" class="form-control">
                        <option value=""><%= LanguageUtil.getText(lang, "event.reminder") %></option>
                        <option value="5" <%= "5".equals(reminderMinutes) ? "selected" : "" %>><%= LanguageUtil.getText(lang, "reminder.5min") %></option>
                        <option value="15" <%= reminderMinutes == null || "15".equals(reminderMinutes) ? "selected" : "" %>><%= LanguageUtil.getText(lang, "reminder.15min") %></option>
                        <option value="30" <%= "30".equals(reminderMinutes) ? "selected" : "" %>><%= LanguageUtil.getText(lang, "reminder.30min") %></option>
                        <option value="60" <%= "60".equals(reminderMinutes) ? "selected" : "" %>><%= LanguageUtil.getText(lang, "reminder.1hour") %></option>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group full-width">
                    <textarea id="description" name="description" rows="3" maxlength="1000"
                              placeholder="Event description (optional)"><%= description != null ? description : "" %></textarea>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group full-width">
                    <textarea id="notes" name="notes" rows="3" maxlength="1000"
                              placeholder="<%= LanguageUtil.getText(lang, "event.notes") %> (optional)"><%= notes != null ? notes : "" %></textarea>
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">
                    <%= LanguageUtil.getText(lang, "event.save") %>
                </button>
                <a href="dashboard.jsp" class="btn btn-secondary">
                    <%= LanguageUtil.getText(lang, "event.cancel") %>
                </a>
            </div>
        </form>
    </div>

    <script>
        function toggleSubjectInput() {
            const subjectType = document.querySelector('input[name="subjectType"]:checked').value;
            const existingSelect = document.getElementById('existingSubjectId');
            const newInput = document.getElementById('subjectName');
            
            if (subjectType === 'existing') {
                existingSelect.style.display = 'block';
                newInput.style.display = 'none';
                newInput.value = '';
            } else {
                existingSelect.style.display = 'none';
                newInput.style.display = 'block';
                existingSelect.value = '';
            }
        }

        // Set minimum date to today
        document.addEventListener('DOMContentLoaded', function() {
            const today = new Date().toISOString().split('T')[0];
            document.getElementById('eventDate').setAttribute('min', today);
            
            // Set default time if not set
            const eventTimeInput = document.getElementById('eventTime');
            if (!eventTimeInput.value) {
                const now = new Date();
                const hours = String(now.getHours()).padStart(2, '0');
                const minutes = String(Math.ceil(now.getMinutes() / 15) * 15).padStart(2, '0');
                eventTimeInput.value = hours + ':' + (minutes === '60' ? '00' : minutes);
            }
        });
    </script>
</body>
</html>
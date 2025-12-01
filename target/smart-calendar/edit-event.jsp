<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.utils.DatabaseUtil" %>
<%@ page import="java.sql.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    String id = request.getParameter("id");
    if (id == null) { response.sendRedirect("events"); return; }
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");

    String title = ""; String date = ""; String time = ""; String location = ""; String description = ""; int reminder = 15;
    try (Connection conn = DatabaseUtil.getConnection()) {
        PreparedStatement stmt = conn.prepareStatement("SELECT title, event_date, event_time, location, description, reminder_minutes_before FROM events WHERE event_id=? AND user_id=?");
        stmt.setInt(1, Integer.parseInt(id));
        stmt.setInt(2, user.getUserId());
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            title = rs.getString(1);
            date = rs.getDate(2).toString();
            time = rs.getTime(3) != null ? rs.getTime(3).toString().substring(0,5) : "";
            location = rs.getString(4);
            description = rs.getString(5);
            reminder = rs.getInt(6);
        } else {
            response.sendRedirect("events");
            return;
        }
    } catch (SQLException e) {
        errorMessage = "Failed to load event";
    }
%>
<!DOCTYPE html>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "event.editTitle") %></title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/forms.css">
        <style>
            .card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;box-shadow:0 1px 2px rgba(0,0,0,.04);padding:24px}
            .page-title{margin:0;font-size:1.5rem;font-weight:600}
            .page-sub{color:#6b7280;margin-block-start:4px}
        </style>
</head>
<body>
    <nav class="main-nav">
        <div class="nav-container">
            <h1 class="nav-title"><a href="dashboard.jsp"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "app.title") %></a></h1>
            <div class="nav-actions">
                <span class="user-welcome"><%= user.getFullName() %></span>
                
            </div>
        </div>
    </nav>

    <div class="form-container">
        <div class="form-header" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
            <div>
                <h2 class="page-title"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "event.editTitle") %></h2>
                <div class="page-sub"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "event.editSub") %></div>
            </div>
            <a href="events" class="btn btn-outline"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "events.backDashboard") %></a>
        </div>
        <% if (errorMessage != null) { %>
            <div class="alert alert-error"><%= errorMessage %></div>
        <% } %>
        <% if (successMessage != null) { %>
            <div class="alert alert-success"><%= successMessage %></div>
        <% } %>

    <form method="post" action="update-event" class="event-form card">
        <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
            <input type="hidden" name="id" value="<%= id %>" />
            <div class="form-row">
                <div class="form-group">
                    <input type="text" name="title" value="<%= title %>" required placeholder="<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "events.subject") %>" />
                </div>
                <div class="form-group">
                    <input type="date" name="eventDate" value="<%= date %>" required />
                </div>
                <div class="form-group">
                    <input type="time" name="eventTime" value="<%= time %>" required />
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <input type="text" name="location" value="<%= location %>" placeholder="<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "event.locationPlaceholder") %>" />
                </div>
                <div class="form-group">
                    <select name="reminderMinutes">
                        <option value="5" <%= reminder==5?"selected":"" %>>5 <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "events.minutesBefore") %></option>
                        <option value="15" <%= reminder==15?"selected":"" %>>15 <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "events.minutesBefore") %></option>
                        <option value="30" <%= reminder==30?"selected":"" %>>30 <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "events.minutesBefore") %></option>
                        <option value="60" <%= reminder==60?"selected":"" %>>1 <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "events.hoursBeforeSingular") %></option>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group full-width">
                    <textarea name="description" rows="3" placeholder="<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "event.descriptionPlaceholder") %>"><%= description!=null?description:"" %></textarea>
                </div>
            </div>
            <div class="form-actions" style="display:flex;gap:10px;justify-content:flex-end;border-block-start:1px dashed #e5e7eb;padding-block-start:16px;margin-block-start:8px;">
                <a href="events" class="btn btn-secondary"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "event.cancel") %></a>
                <button type="submit" class="btn btn-primary"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "event.saveChanges") %></button>
            </div>
        </form>
    </div>
</body>
</html>

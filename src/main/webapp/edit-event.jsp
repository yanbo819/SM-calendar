<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.utils.DatabaseUtil" %>
<%@ page import="java.sql.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    String id = request.getParameter("id");
    if (id == null) { response.sendRedirect("events.jsp"); return; }
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
            response.sendRedirect("events.jsp");
            return;
        }
    } catch (SQLException e) {
        errorMessage = "Failed to load event";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Event</title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/forms.css">
        <style>
            .card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;box-shadow:0 1px 2px rgba(0,0,0,.04);padding:24px}
            .page-title{margin:0;font-size:1.5rem;font-weight:600}
            .page-sub{color:#6b7280;margin-top:4px}
        </style>
</head>
<body>
    <nav class="main-nav">
        <div class="nav-container">
            <h1 class="nav-title"><a href="dashboard.jsp">Smart Calendar</a></h1>
            <div class="nav-actions">
                <span class="user-welcome">Welcome, <%= user.getFullName() %>!</span>
                
            </div>
        </div>
    </nav>

    <div class="form-container">
        <div class="form-header" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
            <div>
                <h2 class="page-title">Edit Event</h2>
                <div class="page-sub">Update details and reminder time. Changes are saved for this event only.</div>
            </div>
            <a href="events.jsp" class="btn btn-outline">← Back to Events</a>
        </div>
        <% if (errorMessage != null) { %>
            <div class="alert alert-error"><%= errorMessage %></div>
        <% } %>
        <% if (successMessage != null) { %>
            <div class="alert alert-success"><%= successMessage %></div>
        <% } %>

    <form method="post" action="update-event" class="event-form card">
            <input type="hidden" name="id" value="<%= id %>" />
            <div class="form-row">
                <div class="form-group">
                    <input type="text" name="title" value="<%= title %>" required placeholder="Title" />
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
                    <input type="text" name="location" value="<%= location %>" placeholder="Location" />
                </div>
                <div class="form-group">
                    <select name="reminderMinutes">
                        <option value="5" <%= reminder==5?"selected":"" %>>5 minutes</option>
                        <option value="15" <%= reminder==15?"selected":"" %>>15 minutes</option>
                        <option value="30" <%= reminder==30?"selected":"" %>>30 minutes</option>
                        <option value="60" <%= reminder==60?"selected":"" %>>1 hour</option>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group full-width">
                    <textarea name="description" rows="3" placeholder="Description (optional)"><%= description!=null?description:"" %></textarea>
                </div>
            </div>
            <div class="form-actions" style="display:flex;gap:10px;justify-content:flex-end;border-top:1px dashed #e5e7eb;padding-top:16px;margin-top:8px;">
                <a href="events.jsp" class="btn btn-secondary">Cancel</a>
                <button type="submit" class="btn btn-primary">Save Changes</button>
            </div>
        </form>
    </div>
</body>
</html>

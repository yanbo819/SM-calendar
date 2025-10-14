<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Course Schedule</title>
    <link rel="stylesheet" href="css/main.css">
        <link rel="stylesheet" href="css/forms.css">
        <style>
            .card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;box-shadow:0 1px 2px rgba(0,0,0,.04);padding:24px}
            .page-title{margin:0;font-size:1.5rem;font-weight:600}
            .page-sub{color:#6b7280;margin-top:4px}
            .hint{color:#6b7280;font-size:.9rem}
        </style>
</head>
<body>
    <nav class="main-nav">
        <div class="nav-container">
            <h1 class="nav-title"><a href="dashboard.jsp">Smart Calendar</a></h1>
            <div class="nav-actions">
                <span class="user-welcome">Welcome, <%= user.getFullName() %>!</span>
                <a href="logout" class="btn btn-outline">Logout</a>
            </div>
        </div>
    </nav>

    <div class="form-container">
        <div class="form-header" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
            <div>
                <h2 class="page-title">Upload Course Schedule</h2>
                <div class="page-sub">Import from a CSV file. We’ll auto-create subjects and categories.</div>
            </div>
            <a href="dashboard.jsp" class="btn btn-outline">← Back to Dashboard</a>
        </div>

        <% if (errorMessage != null) { %>
          <div class="alert alert-error"><%= errorMessage %></div>
        <% } %>
        <% if (successMessage != null) { %>
          <div class="alert alert-success"><%= successMessage %></div>
        <% } %>

        <form method="post" action="upload-schedule" enctype="multipart/form-data" class="event-form card">
            <div class="form-row">
                <div class="form-group full-width">
                    <input type="file" name="file" accept=".csv" required />
                </div>
            </div>
            <div class="form-row">
                <div class="form-group full-width">
                    <p class="hint">CSV columns: title, category, subject, date (YYYY-MM-DD), time (HH:mm), durationMinutes, location, reminderMinutes</p>
                </div>
            </div>
            <div class="form-actions" style="display:flex;gap:10px;justify-content:flex-end;border-top:1px dashed #e5e7eb;padding-top:16px;margin-top:8px;">
                <a href="events.jsp" class="btn btn-secondary">View Events</a>
                <button type="submit" class="btn btn-primary">Upload & Import</button>
            </div>
        </form>
    </div>
</body>
</html>

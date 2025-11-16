<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    boolean isAdmin = user.getEmail() != null && user.getEmail().equals("admin@smartcalendar.com");
    if (!isAdmin) { response.sendRedirect("dashboard.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Admin Publish Event</title>
  <link rel="stylesheet" href="css/main.css" />
  <style>
    .card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;padding:24px;box-shadow:0 1px 2px rgba(0,0,0,.04)}
    .page-title{margin:0;font-size:1.4rem;font-weight:600}
    .form-grid{display:grid;gap:16px}
    @media (min-width:700px){ .form-grid{grid-template-columns:1fr 1fr} }
    .full-span{grid-column:1/-1}
    .actions{display:flex;gap:12px;justify-content:flex-end;margin-top:20px}
  </style>
</head>
<body>
  <nav class="main-nav">
    <div class="nav-container">
      <h1 class="nav-title"><a href="dashboard.jsp">Smart Calendar</a></h1>
      <div class="nav-actions">
        <span class="user-welcome">Admin: <%= user.getFullName() %></span>
        <a href="logout" class="btn btn-outline">Logout</a>
      </div>
    </div>
  </nav>
  <div class="form-container">
    <div class="form-header" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
      <div>
        <h2 class="page-title">Publish Admin Event</h2>
        <div class="page-sub" style="color:#6b7280">Create a read-only event visible to all users.</div>
      </div>
      <a href="dashboard.jsp" class="btn btn-outline">← Dashboard</a>
    </div>
    <div class="card">
      <form method="post" action="admin-event" class="admin-event-form">
        <div class="form-grid">
          <div class="full-span">
            <label>Title</label>
            <input type="text" name="title" required class="form-control" />
          </div>
          <div>
            <label>Date</label>
            <input type="date" name="eventDate" required class="form-control" />
          </div>
          <div>
            <label>Time</label>
            <input type="time" name="eventTime" required class="form-control" />
          </div>
          <div>
            <label>Duration (minutes)</label>
            <input type="number" name="duration" value="60" min="1" class="form-control" />
          </div>
          <div>
            <label>Reminder (minutes before)</label>
            <select name="reminder" class="form-control">
              <option value="15">15</option>
              <option value="30">30</option>
              <option value="60">60</option>
              <option value="1440">1440 (1 day)</option>
            </select>
          </div>
          <div class="full-span">
            <label>Location (optional)</label>
            <input type="text" name="location" class="form-control" />
          </div>
          <div class="full-span">
            <label>Description (optional)</label>
            <textarea name="description" rows="4" class="form-control"></textarea>
          </div>
        </div>
        <div class="actions">
          <button type="submit" class="btn btn-primary">Publish</button>
        </div>
      </form>
    </div>
  </div>
</body>
</html>

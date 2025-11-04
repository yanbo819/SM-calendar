<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>School location, Buildings &amp; gates</title>
    <link rel="stylesheet" href="css/main.css">
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
                <a href="logout" class="btn btn-outline">Logout</a>
            </div>
        </div>
    </nav>

    <div class="form-container">
        <div class="form-header" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
            <div>
                <h2 class="page-title">School location, Buildings &amp; gates</h2>
                <div class="page-sub">Locations of buildings, classrooms, offices, facilities, and campus gates.</div>
            </div>
            <div style="display:flex;gap:8px;flex-wrap:wrap;">
                <a href="important-locations.jsp" class="btn btn-outline">← Important Locations</a>
                <a href="dashboard.jsp" class="btn btn-outline">Dashboard</a>
            </div>
        </div>
        <div class="card">
            <p>Coming soon: an interactive directory of building codes, floors, and room numbers with maps.</p>
            <p class="page-sub">Tip: Share a campus map PDF or dataset to integrate.</p>
        </div>
    </div>
</body>
</html>

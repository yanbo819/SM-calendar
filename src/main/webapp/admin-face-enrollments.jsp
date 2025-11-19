<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.smartcalendar.models.FaceEnrollment" %>
<%@ page import="com.smartcalendar.models.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<FaceEnrollment> faces = (List<FaceEnrollment>) request.getAttribute("faces");
    String loadError = (String) request.getAttribute("loadError");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>Admin: Face ID Enrollments</title>
    <link rel="stylesheet" href="css/main.css" />
    <style>
        .card{background:#fff;border:1px solid #ddd;border-radius:12px;max-inline-size:1000px;margin:24px auto;padding:24px;box-shadow:0 4px 12px rgba(0,0,0,.06)}
        table{border-collapse:collapse;inline-size:100%;}
        th,td{padding:10px 12px;text-align:left;border-bottom:1px solid #eee;font-size:0.9rem}
        th{background:#f8f9fa;font-weight:600}
        tbody tr:hover{background:#f1f5f9}
        .status-badge{display:inline-block;padding:2px 8px;border-radius:12px;font-size:0.7rem;background:#e0f2fe;color:#0369a1}
    </style>
</head>
<body>
<nav class="main-nav">
    <div class="nav-container">
        <h1 class="nav-title"><a href="dashboard.jsp">Smart Calendar</a></h1>
        <div class="nav-actions">
            <a href="dashboard.jsp" class="btn btn-outline">Dashboard</a>
            <a href="logout" class="btn btn-outline">Logout</a>
        </div>
    </div>
</nav>
<div class="card">
    <h2 style="margin-block-start:0;margin-block-end:12px">Face ID Enrollments</h2>
    <p style="margin-block-start:0;margin-block-end:20px">Users who have enrolled Face ID. Includes enrollment time, last update, and location (if provided).</p>
    <% if (loadError != null) { %>
        <div style="background:#fee2e2;color:#7f1d1d;padding:12px;border-radius:8px;margin-block-end:16px"><%= loadError %></div>
    <% } %>
    <table>
        <thead>
            <tr>
                <th>User ID</th>
                <th>Full Name</th>
                <th>Username</th>
                <th>Enrolled At</th>
                <th>Updated At</th>
                <th>Location</th>
            </tr>
        </thead>
        <tbody>
        <% if (faces == null || faces.isEmpty()) { %>
            <tr><td colspan="6" style="text-align:center;padding:24px;color:#6b7280">No face enrollments yet.</td></tr>
        <% } else { for (FaceEnrollment fe : faces) { %>
            <tr>
                <td><%= fe.getUserId() %></td>
                <td><%= fe.getFullName() %></td>
                <td><%= fe.getUsername() %></td>
                <td><%= fe.getCreatedAt() %></td>
                <td><%= fe.getUpdatedAt() %></td>
                <td>
                    <% if (fe.getLatitude() != null && fe.getLongitude() != null) { %>
                        <%= String.format("%.5f, %.5f", fe.getLatitude(), fe.getLongitude()) %>
                    <% } else { %>
                        <span style="color:#9ca3af">(none)</span>
                    <% } %>
                </td>
            </tr>
        <% }} %>
        </tbody>
    </table>
</div>
</body>
</html>
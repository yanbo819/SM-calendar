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
<%
    String lang = (String) session.getAttribute("lang");
    if (lang == null && user.getPreferredLanguage() != null) lang = user.getPreferredLanguage();
    if (lang == null) lang = "en";
    String textDir = com.smartcalendar.utils.LanguageUtil.getTextDirection(lang);
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
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
<%
    boolean noHeader = "1".equals(request.getParameter("noheader"));
%>
<nav class="main-nav" <%= noHeader?"style=\"display:none\"":"" %>>
    <div class="nav-container">
        <h1 class="nav-title"><a href="dashboard.jsp">Smart Calendar</a></h1>
        <div class="nav-actions"></div>
    </div>
</nav>
<div class="card">
    <h2 style="margin-block-start:0;margin-block-end:12px">Face ID Enrollments</h2>
    <p style="margin-block-start:0;margin-block-end:20px">Users with Face ID enrollment. Shows latest enrollment location (if provided) and time.</p>
    <% if (loadError != null) { %>
        <div style="background:#fee2e2;color:#7f1d1d;padding:12px;border-radius:8px;margin-block-end:16px"><%= loadError %></div>
    <% } %>
    <table>
        <thead>
            <tr>
                <th>User ID</th>
                <th>Full Name</th>
                <th>Username</th>
                <th>Enrollment Time</th>
                <th>Location (Lat, Lon)</th>
            </tr>
        </thead>
        <tbody>
        <% if (faces == null || faces.isEmpty()) { %>
            <tr><td colspan="5" style="text-align:center;padding:24px;color:#6b7280">No face enrollments yet.</td></tr>
        <% } else { for (FaceEnrollment fe : faces) { %>
            <tr>
                <td><%= fe.getUserId() %></td>
                <td><%= fe.getFullName() %></td>
                <td><%= fe.getUsername() %></td>
                <td><%= fe.getAttemptTime() != null ? fe.getAttemptTime() : fe.getCreatedAt() %></td>
                <td>
                    <% if (fe.getLatitude() != null && fe.getLongitude() != null) { %>
                        <%= String.format("%.5f, %.5f", fe.getLatitude(), fe.getLongitude()) %>
                    <% } else { %>
                        <span style="color:#6b7280">N/A</span>
                    <% } %>
                </td>
            </tr>
        <% }} %>
        </tbody>
    </table>
    <div style="margin-top:20px;display:flex;justify-content:center">
        <a href="admin-tools.jsp" class="btn btn-outline" style="min-inline-size:160px">Go Back</a>
    </div>
</div>
</body>
</html>
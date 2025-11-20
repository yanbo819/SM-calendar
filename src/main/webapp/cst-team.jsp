<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.models.CstDepartment" %>
<%@ page import="com.smartcalendar.models.CstVolunteer" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    List<CstDepartment> deps = (List<CstDepartment>) request.getAttribute("departments");
    Map<Integer, List<CstVolunteer>> members = (Map<Integer, List<CstVolunteer>>) request.getAttribute("members");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CST Shining Team</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .team-grid{display:grid;gap:16px}
        .dept-card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;padding:16px}
        .member-list{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:12px;margin-top:10px}
        .member{border:1px solid #e5e7eb;border-radius:10px;padding:12px;display:flex;gap:10px;background:#fff}
        .member img{width:56px;height:56px;border-radius:50%;object-fit:cover;border:1px solid #e5e7eb}
        .member .meta{font-size:.9rem;color:#374151}
        .kv{display:flex;gap:6px}
        .kv b{min-inline-size:88px}
    </style>
</head>
<body>
<nav class="main-nav">
    <div class="nav-container">
        <h1 class="nav-title">CST Shining Team</h1>
        <div class="nav-actions">
            <a href="dashboard.jsp" class="btn btn-outline">Go Back</a>
        </div>
    </div>
</nav>
<div class="dashboard-container">
    <div class="team-grid">
        <% for (CstDepartment d : deps) { List<CstVolunteer> vs = members.getOrDefault(d.getId(), java.util.Collections.emptyList()); %>
            <div class="dept-card">
                <h3 style="margin:0 0 8px 0"><%= d.getName() %></h3>
                <% if (vs.isEmpty()) { %>
                    <div style="color:#6b7280">No volunteers yet.</div>
                <% } else { %>
                <div class="member-list">
                    <% for (CstVolunteer v : vs) { %>
                    <div class="member">
                        <img src="<%= v.getPhotoUrl()!=null && !v.getPhotoUrl().isEmpty() ? v.getPhotoUrl() : "https://via.placeholder.com/56" %>" alt="photo" />
                        <div class="meta">
                            <div><b><%= v.getPassportName()!=null?v.getPassportName():"Unknown" %></b> <span style="color:#6b7280">(<%= v.getChineseName()!=null?v.getChineseName():"" %>)</span></div>
                            <div class="kv"><b>Student ID</b><span><%= v.getStudentId()!=null?v.getStudentId():"" %></span></div>
                            <div class="kv"><b>Phone</b><span><%= v.getPhone()!=null?v.getPhone():"" %></span></div>
                            <div class="kv"><b>Gender</b><span><%= v.getGender()!=null?v.getGender():"" %></span></div>
                            <div class="kv"><b>Nationality</b><span><%= v.getNationality()!=null?v.getNationality():"" %></span></div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>
        <% } %>
    </div>
</div>
</body>
</html>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%
  User me = (User) session.getAttribute("user");
  if (me == null) { response.sendRedirect("login.jsp"); return; }
  boolean isAdmin = me.getRole() != null && me.getRole().equalsIgnoreCase("admin");
  if (!isAdmin) { response.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }
  String idStr = request.getParameter("id");
  com.smartcalendar.models.User target = (com.smartcalendar.models.User) request.getAttribute("target");
%>
<!doctype html>
<html>
<head>
  <meta charset="utf-8" />
  <title>User Safety Chain</title>
  <link rel="stylesheet" href="css/main.css" />
  <style>
    .card{background:#fff;border:1px solid #e5e7eb;border-radius:14px;padding:28px;max-inline-size:900px;margin:28px auto;box-shadow:0 4px 12px rgba(0,0,0,.05)}
    .info-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:18px}
    @media (max-width:760px){.info-grid{grid-template-columns:1fr}}
    .small-label{font-size:.65rem;text-transform:uppercase;letter-spacing:.5px;color:#374151;font-weight:600;margin-block-end:4px}
  </style>
</head>
<body>
<nav class="main-nav">
  <div class="nav-container">
    <h1 class="nav-title"><a href="dashboard.jsp">Smart Calendar</a></h1>
    <div class="nav-actions"><a href="admin-users" class="btn btn-outline">Users</a><a href="logout" class="btn btn-outline">Logout</a></div>
  </div>
</nav>
<div class="card">
  <h2 style="margin:0 0 6px">Safety Chain</h2>
  <div style="color:#6b7280;font-size:.9rem;margin:0 0 18px">This page is a placeholder for future safety / emergency contact chain features.</div>
  <div class="info-grid">
    <div style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:10px;padding:14px 16px">
      <div class="small-label">User ID</div>
      <div><%= target!=null?target.getUserId():idStr %></div>
    </div>
    <div style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:10px;padding:14px 16px">
      <div class="small-label">Name</div>
      <div><%= target!=null?target.getFullName():"" %></div>
    </div>
    <div style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:10px;padding:14px 16px">
      <div class="small-label">Email</div>
      <div><%= target!=null?target.getEmail():"" %></div>
    </div>
    <div style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:10px;padding:14px 16px">
      <div class="small-label">Status</div>
      <div><%= target!=null?(target.isActive()?"Active":"Inactive"):"" %></div>
    </div>
  </div>
  <div style="margin-top:24px;display:flex;gap:12px;flex-wrap:wrap">
    <a href="admin-user?id=<%= target!=null?target.getUserId():idStr %>" class="btn btn-primary" style="min-inline-size:140px"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.user.backProfile") %></a>
    <a href="admin-users" class="btn btn-outline" style="min-inline-size:140px">Users List</a>
  </div>
</div>
</body>
</html>Bro, hey hiya
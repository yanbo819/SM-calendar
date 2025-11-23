<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null) { response.sendRedirect("login.jsp"); return; }
    boolean isAdmin = me.getRole() != null && me.getRole().equalsIgnoreCase("admin");
    if (!isAdmin) { response.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }
%>
<%
    String lang = (String) session.getAttribute("lang");
    if (lang == null && me.getPreferredLanguage() != null) lang = me.getPreferredLanguage();
    if (lang == null) lang = "en";
    String textDir = com.smartcalendar.utils.LanguageUtil.getTextDirection(lang);
%>
<!doctype html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Add New User</title>
    <link rel="stylesheet" href="css/main.css" />
    <link rel="stylesheet" href="css/forms.css" />
    <style>
        .page-wrap { max-inline-size:900px; margin:16px auto; padding:0 16px; }
        .card { background:#fff; border:1px solid #e5e7eb; border-radius:12px; box-shadow:0 1px 2px rgba(0,0,0,.04); padding:20px; }
        .page-title { margin:0; font-size:1.35rem; font-weight:600; }
        .page-sub { color:#6b7280; margin-block-start:4px; }
        .form-grid { display:grid; grid-template-columns:1fr 1fr; gap:16px; margin-top:12px; }
        @media (max-width:768px){ .form-grid { grid-template-columns:1fr; } }
        .form-group { display:flex; flex-direction:column; gap:6px; }
        .actions { display:flex; justify-content:center; gap:12px; border-top:1px dashed #e5e7eb; padding-top:16px; margin-top:20px; }
    </style>
</head>
<body>
<!-- Top navigation and admin toolbar removed for minimal Create User page -->
<div class="page-wrap">
    <div class="form-header" style="display:flex;align-items:center;justify-content:center;gap:12px;flex-direction:column;text-align:center;">
        <h2 class="page-title" style="margin:0">Create User</h2>
        <div class="page-sub">Fill out details below. All required fields are marked.</div>
    </div>
    <form class="card" method="post" action="admin-user-crud">
        <input type="hidden" name="action" value="create" />
        <div class="form-grid">
            <div class="form-group">
                <label for="username">Username</label>
                <input id="username" name="username" class="form-control" required maxlength="150" />
            </div>
            <div class="form-group">
                <label for="fullName">Full Name</label>
                <input id="fullName" name="fullName" class="form-control" required maxlength="255" />
            </div>
            <div class="form-group">
                <label for="email">Email</label>
                <input id="email" name="email" type="email" class="form-control" required maxlength="255" />
            </div>
            <div class="form-group">
                <label for="phone">Phone</label>
                <input id="phone" name="phone" class="form-control" maxlength="50" />
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input id="password" name="password" type="password" class="form-control" required minlength="4" />
            </div>
            <div class="form-group">
                <label for="role">Role</label>
                <select id="role" name="role" class="form-control">
                    <option value="user">User</option>
                    <option value="admin">Admin</option>
                </select>
            </div>
        </div>
        <div class="actions">
            <button type="button" class="btn" onclick="location.href='admin-users'">Cancel</button>
            <button type="submit" class="btn btn-primary">Create</button>
        </div>
    </form>
</div>
</body>
</html>
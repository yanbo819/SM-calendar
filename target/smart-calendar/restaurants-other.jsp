<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<%
    // Allow anonymous viewing
    User user = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.restaurants") %></title>
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
            <h1 class="nav-title"><a href="dashboard"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "app.title") %></a></h1>
            <div class="nav-actions">
                <% if (user != null) { %>
                <span class="user-welcome"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "dashboard.welcome") %> <%= user.getFullName() %>!</span>
                <% } %>
            </div>
        </div>
    </nav>

    <div class="form-container">
        <div class="form-header" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
            <div>
                <h2 class="page-title"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.restaurants") %></h2>
                <div class="page-sub"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.restaurants.desc") %></div>
            </div>
        </div>
        <div class="card">
            <p><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "restaurants.comingSoon") %></p>
            <p class="page-sub"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "restaurants.tip") %></p>
        </div>
        <div style="display:grid;place-items:center;margin-top:24px">
            <a href="important-locations.jsp" class="btn btn-outline" style="min-inline-size:160px"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.back") %></a>
        </div>
    </div>
</body>
</html>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.Location" %>
<%@ page import="com.smartcalendar.models.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) { response.sendRedirect("login.jsp"); return; }
    Location loc = (Location) request.getAttribute("location");
    if (loc == null) { response.sendRedirect("admin-locations?error=Not+found"); return; }
    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8" />
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.location.detail.title") %></title>
    <link rel="stylesheet" href="css/main.css" />
    <style>
        .card{background:#fff;border:1px solid #ddd;border-radius:12px;max-inline-size:900px;margin:28px auto;padding:28px;box-shadow:0 4px 12px rgba(0,0,0,.06)}
        .actions{display:flex;flex-wrap:wrap;gap:12px;justify-content:center;margin-top:16px}
        .field-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:16px}
        @media (max-width:780px){.field-grid{grid-template-columns:1fr}}
        label span{font-size:.75rem;color:#374151;font-weight:600;letter-spacing:.5px;text-transform:uppercase}
    </style>
</head>
<body>
<nav class="main-nav">
    <div class="nav-container">
        <h1 class="nav-title"><a href="dashboard.jsp"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "app.title") %></a></h1>
        <div class="nav-actions">
            <a href="admin-locations" class="btn btn-outline"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.locations") %></a>
            <a href="logout" class="btn btn-outline"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "nav.logout") %></a>
        </div>
    </div>
</nav>
<div class="card">
    <h2 style="margin-block-start:0;margin-block-end:4px"><%= loc.getName() %></h2>
    <div style="color:#6b7280;font-size:.9rem;margin-block-end:16px"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.location.detail.title") %></div>
    <% if (success != null) { %>
        <div style="background:#ecfdf5;color:#065f46;padding:10px 14px;border-radius:8px;margin-block-end:16px">Saved successfully.</div>
    <% } %>
    <% if (error != null) { %>
        <div style="background:#fee2e2;color:#7f1d1d;padding:10px 14px;border-radius:8px;margin-block-end:16px"><%= error %></div>
    <% } %>
    <form method="post" action="admin-location">
        <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
        <input type="hidden" name="action" value="save" />
        <input type="hidden" name="locationId" value="<%= loc.getLocationId() %>" />
        <div class="field-grid">
            <label style="display:flex;flex-direction:column;gap:6px">
                <span><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.location.name") %></span>
                <input class="form-control" type="text" name="name" value="<%= loc.getName() %>" />
            </label>
            <label style="display:flex;flex-direction:column;gap:6px">
                <span><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.location.category") %></span>
                <select class="form-control" name="category">
                    <option value="gate" <%= "gate".equals(loc.getCategory())?"selected":"" %>>Gate</option>
                    <option value="hospital" <%= "hospital".equals(loc.getCategory())?"selected":"" %>>Hospital</option>
                    <option value="immigration" <%= "immigration".equals(loc.getCategory())?"selected":"" %>>Immigration</option>
                    <option value="other" <%= "other".equals(loc.getCategory())?"selected":"" %>>Other</option>
                </select>
            </label>
            <label style="display:flex;flex-direction:column;gap:6px;grid-column:1/-1">
                <span><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.location.description") %></span>
                <textarea class="form-control" name="description" rows="2" placeholder="Short description"><%= loc.getDescription()==null?"":loc.getDescription() %></textarea>
            </label>
            <label style="display:flex;flex-direction:column;gap:6px;grid-column:1/-1">
                <span><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.location.mapUrl") %></span>
                <input class="form-control" type="text" name="mapUrl" value="<%= loc.getMapUrl()==null?"":loc.getMapUrl() %>" placeholder="https://" />
            </label>
            <div style="grid-column:1/-1;display:flex;align-items:center;gap:8px;margin-top:4px">
                <input type="checkbox" id="activeBox" name="active" <%= loc.isActive()?"checked":"" %> />
                <label for="activeBox" style="font-size:.85rem;color:#374151"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.location.active") %></label>
            </div>
        </div>
        <div class="actions">
            <button type="submit" class="btn btn-primary" style="min-inline-size:120px"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.location.save") %></button>
            <a class="btn btn-outline" style="min-inline-size:120px" href="<%= loc.getMapUrl() %>" target="_blank" rel="noopener"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.location.openMap") %></a>
            <form method="post" action="admin-location" onsubmit="return confirm('<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "confirm.delete.location") %>');" style="display:inline">
                <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
                <input type="hidden" name="action" value="delete" />
                <input type="hidden" name="locationId" value="<%= loc.getLocationId() %>" />
                <button type="submit" class="btn btn-danger" style="min-inline-size:120px">Delete</button>
            </form>
            <a class="btn" style="min-inline-size:120px" href="admin-locations"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.location.goBack") %></a>
        </div>
    </form>
</div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>
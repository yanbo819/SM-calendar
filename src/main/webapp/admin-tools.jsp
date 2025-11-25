<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    if (user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) { response.sendRedirect("dashboard"); return; }
%>
<!DOCTYPE html>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
<meta charset="UTF-8" />
<title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.tools") %></title>
<link rel="stylesheet" href="css/main.css" />
<link rel="stylesheet" href="css/dashboard.css" />
<style>
    .admin-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:16px;margin-block-start:24px}
    .tool-card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;padding:18px;display:flex;flex-direction:column;justify-content:space-between;box-shadow:0 2px 6px rgba(0,0,0,.06)}
    .tool-card h3{margin:0 0 8px;font-size:1.05rem;display:flex;align-items:center;gap:6px}
    .tool-card p{margin:0 0 12px;font-size:.85rem;color:#555;line-height:1.3}
    .tool-card a{align-self:flex-start}
    .page-wrapper{max-inline-size:1100px;margin:0 auto;padding:24px}
    .breadcrumb{font-size:.75rem;color:#6b7280;margin-block-end:8px}
</style>
</head>
<body dir="<%= textDir %>">
<nav class="main-nav">
    <div class="nav-container">
        <h1 class="nav-title"><a href="dashboard"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "app.title") %></a></h1>
        <div class="nav-actions" style="display:flex;gap:8px;align-items:center;">
            <form action="set-language" method="post" style="margin:0;display:flex;align-items:center;gap:4px;">
                <select name="lang" onchange="this.form.submit()" class="form-control" style="padding:4px 8px;min-inline-size:110px;">
                    <%
                        for (String code : com.smartcalendar.utils.LanguageUtil.getSupportedLanguages()) {
                    %>
                    <option value="<%= code %>" <%= code.equals(lang)?"selected":"" %>><%= com.smartcalendar.utils.LanguageUtil.getLanguageName(code) %></option>
                    <% } %>
                </select>
            </form>
            <a href="events" class="btn btn-outline"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "dashboard.view_events") %></a>
            <a href="logout" class="btn btn-outline"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "nav.logout") %></a>
        </div>
    </div>
</nav>
<div class="page-wrapper">
    <div class="admin-grid">
        <div class="tool-card">
            <h3>🧑‍🦰 <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.face.windows") %></h3>
            <p><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.face.windows") %></p>
            <a href="admin-face-config?noheader=1" target="_blank" rel="noopener" class="btn btn-primary"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.face.windows") %></a>
        </div>
        <div class="tool-card">
            <h3>📸 <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.face.enrollments") %></h3>
            <p><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.face.enrollments") %></p>
            <a href="admin-face-enrollments?noheader=1" target="_blank" rel="noopener" class="btn btn-primary"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.face.enrollments") %></a>
        </div>
        <div class="tool-card">
            <h3>👥 <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.users") %></h3>
            <p><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.users") %></p>
            <a href="admin-users?noheader=1" target="_blank" rel="noopener" class="btn btn-primary"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.users") %></a>
        </div>
        <div class="tool-card">
            <h3>📍 <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.locations") %></h3>
            <p><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.locations") %></p>
            <a href="admin-locations?category=gate&noheader=1" target="_blank" rel="noopener" class="btn btn-primary"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.locations") %></a>
        </div>
        <div class="tool-card">
            <h3>🔔 <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.reminders") %></h3>
            <p><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.reminders") %></p>
            <a href="create-event.jsp?noheader=1" target="_blank" rel="noopener" class="btn btn-primary"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "dashboard.create_reminder") %></a>
        </div>
        <div class="tool-card">
            <h3>➕ <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.face.add") %></h3>
            <p><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.face.add") %></p>
            <a href="face-id.jsp?noheader=1" target="_blank" rel="noopener" class="btn btn-primary"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.face.add") %></a>
        </div>
        <div class="tool-card">
            <h3>🤝 <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.cst.title") %></h3>
            <p><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.cst.desc") %></p>
            <a href="admin-cst-team?noheader=1" target="_blank" rel="noopener" class="btn btn-primary"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.cst.open") %></a>
        </div>
        <div class="tool-card">
            <h3>🏫 <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.title") %></h3>
            <p><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.desc") %></p>
            <a href="admin-colleges" class="btn btn-primary"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.title") %></a>
        </div>
    </div>
</div>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>
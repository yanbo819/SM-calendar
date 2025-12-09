<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>
<!DOCTYPE html>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "schedule.uploadTitle") %></title>
    <link rel="stylesheet" href="css/main.css">
        <link rel="stylesheet" href="css/forms.css">
        <style>
            .card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;box-shadow:0 1px 2px rgba(0,0,0,.04);padding:24px}
            .page-title{margin:0;font-size:1.5rem;font-weight:600}
            .page-sub{color:#6b7280;margin-block-start:4px}
            .hint{color:#6b7280;font-size:.9rem}
        </style>
</head>
<body>
    <%@ include file="/WEB-INF/jspf/topnav.jspf" %>

    <div class="form-container">
        <div class="form-header" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
            <div>
                <h2 class="page-title"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "schedule.uploadTitle") %></h2>
                <div class="page-sub"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "schedule.uploadSub") %></div>
            </div>
            <!-- Back to dashboard button removed for consistency as requested -->
            <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;">
                <a href="events" class="btn btn-outline"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "schedule.viewEvents") %></a>
                <a href="https://webvpn.zjnu.edu.cn/http/77726476706e69737468656265737421f1e2559434357a467b1ac7b6925b367b621b2f49c7b0/authserver/login?service=https%3A%2F%2Fwebvpn.zjnu.edu.cn%2Flogin%3Fcas_login%3Dtrue" target="_blank" rel="noopener" class="btn btn-secondary">Add course timetable from school system directly</a>
            </div>
        </div>

        <% if (errorMessage != null) { %>
          <div class="alert alert-error"><%= errorMessage %></div>
        <% } %>
        <% if (successMessage != null) { %>
          <div class="alert alert-success"><%= successMessage %></div>
        <% } %>

        <form method="post" action="upload-schedule" enctype="multipart/form-data" class="event-form card">
            <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
            <div class="form-row">
                <div class="form-group full-width">
                    <input type="file" name="file" accept=".csv,.ics,.pdf" required />
                </div>
            </div>
            <div class="form-row">
                <div class="form-group full-width">
                    <p class="hint"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "schedule.uploadHint") %></p>
                </div>
            </div>
            <div class="form-actions" style="display:flex;gap:10px;justify-content:flex-end;border-block-start:1px dashed #e5e7eb;padding-block-start:16px;margin-block-start:8px;">
                <button type="submit" class="btn btn-primary"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "schedule.uploadSubmit") %></button>
            </div>
        </form>
    </div>
</body>
</html>

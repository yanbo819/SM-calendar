<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    boolean isAdmin = user.getRole() != null && user.getRole().equalsIgnoreCase("admin");
    if (!isAdmin) { response.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }
    String currentCategory = request.getParameter("category");
    if (currentCategory == null) currentCategory = "";
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.location.addNewTitle") %></title>
    <link rel="stylesheet" href="css/main.css" />
    <link rel="stylesheet" href="css/ui.css" />
    <style>
        .page { max-inline-size: 900px; margin: 16px auto; padding: 0 16px; }
        .header-row { display:flex; align-items:center; justify-content:space-between; gap:12px; margin-block:8px 16px; }
        .create-grid { display:grid; grid-template-columns: repeat(2, minmax(0,1fr)); gap: 12px; }
        @media (max-width: 700px){ .create-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<!-- Navigation and admin toolbar removed for streamlined new location form -->
<div class="form-container page">
    <div class="header-row" style="justify-content:center;flex-direction:column;text-align:center">
        <h2 style="margin:0"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.location.addNewTitle") %></h2>
    </div>

    <div class="card">
        <div class="card-body">
            <form method="post" action="admin-locations">
                <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
                <input type="hidden" name="action" value="create" />
                <input type="hidden" name="returnCategory" value="<%= currentCategory %>" />
                <div class="create-grid">
                    <div>
                        <label><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.name") %></label>
                        <input class="form-control" type="text" name="name" required />
                    </div>
                    <div>
                        <label>Category</label>
                        <select class="form-control" name="category" required>
                            <option value="gate" <%= "gate".equals(currentCategory)?"selected":"" %>>Gate</option>
                            <option value="hospital" <%= "hospital".equals(currentCategory)?"selected":"" %>>Hospital</option>
                            <option value="immigration" <%= "immigration".equals(currentCategory)?"selected":"" %>>Immigration</option>
                            <option value="other" <%= "other".equals(currentCategory)?"selected":"" %>>Other</option>
                        </select>
                    </div>
                    <div>
                        <label>Map URL</label>
                        <input class="form-control" type="text" name="mapUrl" placeholder="https://" required />
                    </div>
                    <div>
                        <label>Description</label>
                        <input class="form-control" type="text" name="description" placeholder="Short description" />
                    </div>
                </div>
                <div class="form-actions" style="display:flex;flex-direction:column;align-items:center;gap:14px;margin-top:18px;">
                    <label style="display:inline-flex;align-items:center;gap:8px;font-size:.9rem;color:#374151"><input type="checkbox" name="active" checked /> Active</label>
                    <div style="display:flex; gap:12px; justify-content:center;">
                        <a href="admin-tools.jsp" class="btn btn-outline" style="min-inline-size:140px"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.back") %></a>
                        <button type="submit" class="btn btn-primary" style="min-inline-size:140px"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.location.addButton") %></button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>

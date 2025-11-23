<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.smartcalendar.models.FaceConfig" %>
<%
    com.smartcalendar.models.User user = (com.smartcalendar.models.User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    boolean isAdmin = (user.getFullName() != null && user.getFullName().equalsIgnoreCase("admin")) || (user.getEmail() != null && user.getEmail().toLowerCase().startsWith("admin"));
    if (!isAdmin) { response.sendRedirect("dashboard?error=Not+authorized"); return; }
    List<FaceConfig> windows = (List<FaceConfig>) request.getAttribute("windows");
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
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.modalTitle") %></title>
    <link rel="stylesheet" href="css/main.css" />
    <link rel="stylesheet" href="css/ui.css" />
    <style>
        table{inline-size:100%;border-collapse:collapse;margin-block-start:12px}
        th,td{border:1px solid #e5e7eb;padding:6px;font-size:.85rem}
        th{background:#f9fafb}
        .day-badge{display:inline-block;padding:2px 6px;border-radius:6px;font-size:.65rem;background:#eef2ff;color:#3730a3;border:1px solid #c7d2fe}
    </style>
</head>
<body>
<%
    boolean noHeader = "1".equals(request.getParameter("noheader"));
%>
<nav class="main-nav" <%= noHeader?"style=\"display:none\"":"" %>>
    <div class="nav-container">
        <h1 class="nav-title"><a href="dashboard">Smart Calendar</a></h1>
        <div class="nav-actions"><!-- admin toolbar below --></div>
    </div>
</nav>
<% if (isAdmin && !noHeader) { %>
<jsp:include page="/WEB-INF/jsp/includes/admin-toolbar.jspf" />
<% } %>
<style>
    .page-wrap { max-inline-size: 900px; margin: 16px auto; padding: 0 16px; }
    .card { background:#fff; border:1px solid #e5e7eb; border-radius:12px; box-shadow:0 1px 2px rgba(0,0,0,.04); padding:16px; }
    .page-title { margin:0; font-size:1.25rem; font-weight:600; }
    .page-sub { color:#6b7280; margin-block-start:4px; }
    .action-btn-sm { min-inline-size: 90px; }
</style>
<div class="page-wrap">
    <div class="form-header" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
        <div>
            <h2 class="page-title"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.modalTitle") %></h2>
            <div class="page-sub"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.enrollSub") %></div>
        </div>
        <a class="btn btn-primary" href="admin-face-window-new.jsp"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.face.addWindow") %></a>
    </div>

    <div class="card" style="margin-top:12px">
    <table>
        <thead>
            <tr><th>ID</th><th>Day</th><th>Start</th><th>End</th><th>Actions</th></tr>
        </thead>
        <tbody>
        <% if (windows != null) {
               for (FaceConfig fc : windows) { 
                    String startStr = fc.getStartTime() != null ? fc.getStartTime().toString() : "";
                    String endStr = fc.getEndTime() != null ? fc.getEndTime().toString() : "";
                    startStr = startStr.length() >= 5 ? startStr.substring(0,5) : startStr;
                    endStr = endStr.length() >= 5 ? endStr.substring(0,5) : endStr;
        %>
            <tr>
                <td><%= fc.getId() %></td>
                <td>
                    <form method="post" action="admin-face-config" style="display:flex;gap:6px;align-items:center;flex-wrap:wrap">
                        <input type="hidden" name="action" value="update" />
                        <input type="hidden" name="id" value="<%= fc.getId() %>" />
                        <select name="dayOfWeek" class="form-control" required style="inline-size:10rem">
                            <option value="1" <%= fc.getDayOfWeek()==1?"selected":"" %>>Monday</option>
                            <option value="2" <%= fc.getDayOfWeek()==2?"selected":"" %>>Tuesday</option>
                            <option value="3" <%= fc.getDayOfWeek()==3?"selected":"" %>>Wednesday</option>
                            <option value="4" <%= fc.getDayOfWeek()==4?"selected":"" %>>Thursday</option>
                            <option value="5" <%= fc.getDayOfWeek()==5?"selected":"" %>>Friday</option>
                            <option value="6" <%= fc.getDayOfWeek()==6?"selected":"" %>>Saturday</option>
                            <option value="7" <%= fc.getDayOfWeek()==7?"selected":"" %>>Sunday</option>
                        </select>
                </td>
                <td>
                        <input type="text" name="start" value="<%= startStr %>" required pattern="[0-2][0-9]:[0-5][0-9]" class="form-control" style="inline-size:9rem">
                </td>
                <td>
                        <input type="text" name="end" value="<%= endStr %>" required pattern="[0-2][0-9]:[0-5][0-9]" class="form-control" style="inline-size:9rem">
                </td>
                <td>
                        <button type="submit" class="btn btn-primary btn-sm action-btn-sm"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.save") %></button>
                    </form>
                    <form method="post" action="admin-face-config" onsubmit="return confirm('<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.face.deleteWindowConfirm") %>');" style="display:inline-block;margin-inline-start:6px">
                        <input type="hidden" name="action" value="delete" />
                        <input type="hidden" name="id" value="<%= fc.getId() %>" />
                        <button type="submit" class="btn btn-danger btn-sm action-btn-sm"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.delete") %></button>
                    </form>
                </td>
            </tr>
        <% } } %>
        </tbody>
    </table>
    </div>
</div>
<div style="margin-block-start:16px;display:flex;justify-content:center">
    <a href="admin-tools.jsp" class="btn btn-outline" style="min-inline-size:160px"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.back") %></a>
</div>
</body>
</html>

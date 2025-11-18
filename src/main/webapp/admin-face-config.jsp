<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.smartcalendar.models.FaceConfig" %>
<%
    com.smartcalendar.models.User user = (com.smartcalendar.models.User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    boolean isAdmin = (user.getFullName() != null && user.getFullName().equalsIgnoreCase("admin")) || (user.getEmail() != null && user.getEmail().toLowerCase().startsWith("admin"));
    if (!isAdmin) { response.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }
    List<FaceConfig> windows = (List<FaceConfig>) request.getAttribute("windows");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin: Face Recognition Windows</title>
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
<nav class="main-nav">
    <div class="nav-container">
        <h1 class="nav-title"><a href="dashboard.jsp">Smart Calendar</a></h1>
        <div class="nav-actions"><!-- admin toolbar below --></div>
    </div>
</nav>
<% if (isAdmin) { %>
<jsp:include page="/WEB-INF/jsp/includes/admin-toolbar.jspf" />
<% } %>
<div class="form-container">
    <h2>Face Recognition Windows</h2>
    <p style="margin-block-start:4px;color:#6b7280;font-size:.9rem">Configure allowed days and time ranges for Face Recognition usage.</p>

    <form method="post" action="admin-face-config" style="margin-block-start:12px;display:flex;flex-wrap:wrap;gap:8px;align-items:flex-end">
        <input type="hidden" name="action" value="create" />
        <div>
            <label>Day<br>
                <select name="dayOfWeek" required>
                    <option value="1">Monday</option>
                    <option value="2">Tuesday</option>
                    <option value="3">Wednesday</option>
                    <option value="4">Thursday</option>
                    <option value="5">Friday</option>
                    <option value="6">Saturday</option>
                    <option value="7">Sunday</option>
                </select>
            </label>
        </div>
        <div><label>Start (HH:MM)<br><input type="text" name="start" placeholder="08:00" required pattern="[0-2][0-9]:[0-5][0-9]"></label></div>
        <div><label>End (HH:MM)<br><input type="text" name="end" placeholder="12:00" required pattern="[0-2][0-9]:[0-5][0-9]"></label></div>
        <div><button type="submit" class="btn btn-primary">Add Window</button></div>
    </form>

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
                        <select name="dayOfWeek" required>
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
                        <input type="text" name="start" value="<%= startStr %>" required pattern="[0-2][0-9]:[0-5][0-9]" style="inline-size:6.5rem">
                </td>
                <td>
                        <input type="text" name="end" value="<%= endStr %>" required pattern="[0-2][0-9]:[0-5][0-9]" style="inline-size:6.5rem">
                </td>
                <td>
                        <button type="submit" class="btn btn-primary btn-sm">Update</button>
                    </form>
                    <form method="post" action="admin-face-config" onsubmit="return confirm('Delete this window?');" style="display:inline-block;margin-inline-start:6px">
                        <input type="hidden" name="action" value="delete" />
                        <input type="hidden" name="id" value="<%= fc.getId() %>" />
                        <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                    </form>
                </td>
            </tr>
        <% } } %>
        </tbody>
    </table>
</div>
</body>
</html>

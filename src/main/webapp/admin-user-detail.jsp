<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.models.Event" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null) { response.sendRedirect("login.jsp"); return; }
    boolean isAdmin = me.getRole() != null && me.getRole().equalsIgnoreCase("admin");
    if (!isAdmin) { response.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }
    User target = (User) request.getAttribute("target");
    List<Event> events = (List<Event>) request.getAttribute("events");
%>
<!doctype html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin: User Detail</title>
    <link rel="stylesheet" href="css/main.css" />
    <link rel="stylesheet" href="css/ui.css" />
    <style>
    table{inline-size:100%;border-collapse:collapse;margin-block-start:12px}
        th,td{border:1px solid #e5e7eb;padding:6px;font-size:.85rem}
        th{background:#f9fafb}
        .inline-form{display:flex;gap:6px;align-items:center;flex-wrap:wrap}
    </style>
</head>
<body>
<nav class="main-nav">
    <div class="nav-container">
        <h1 class="nav-title"><a href="dashboard.jsp">Smart Calendar</a></h1>
        <div class="nav-actions"><!-- admin toolbar below --></div>
    </div>
</nav>
<jsp:include page="/WEB-INF/jsp/includes/admin-toolbar.jspf" />
<div class="form-container">
    <h2>User: <%= target.getFullName() %> (#<%= target.getUserId() %>)</h2>
    <div style="color:#6b7280;margin-block-start:4px">Username: <strong><%= target.getUsername() %></strong> · Role: <span class="badge <%= ("admin".equalsIgnoreCase(target.getRole())?"gray":"green") %>"><%= target.getRole() %></span> · Status: <span class="badge <%= (target.isActive()?"green":"gray") %>"><%= target.isActive()?"Active":"Inactive" %></span></div>
    <div style="color:#6b7280;margin-block-start:4px">Email: <%= target.getEmail() %> · Phone: <%= target.getPhoneNumber() %></div>

    <h3 style="margin-block-start:16px">Edit User</h3>
    <form method="post" action="admin-user-crud" class="inline-form" style="gap:8px;flex-wrap:wrap">
        <input type="hidden" name="action" value="update" />
        <input type="hidden" name="userId" value="<%= target.getUserId() %>" />
        <label>Full Name <input name="fullName" value="<%= target.getFullName() %>" required /></label>
        <label>Email <input type="email" name="email" value="<%= target.getEmail() %>" required /></label>
        <label>Phone <input name="phone" value="<%= target.getPhoneNumber() != null ? target.getPhoneNumber() : "" %>" /></label>
        <label>Role
            <select name="role" <%= ("admin".equalsIgnoreCase(target.getRole()) ? "disabled" : "") %>>
                <option value="user" <%= ("user".equalsIgnoreCase(target.getRole()) ? "selected" : "") %>>User</option>
                <option value="admin" <%= ("admin".equalsIgnoreCase(target.getRole()) ? "selected" : "") %>>Admin</option>
            </select>
        </label>
        <label>Active <input type="checkbox" name="active" <%= target.isActive() ? "checked" : "" %> <%= ("admin".equalsIgnoreCase(target.getRole()) ? "disabled" : "") %> /></label>
        <label>Reset Password <input type="password" name="password" placeholder="Leave blank to keep" /></label>
        <button type="submit" class="btn btn-primary btn-sm">Save Changes</button>
    </form>

    <% if (!"admin".equalsIgnoreCase(target.getRole())) { %>
    <div class="card" style="margin-top:12px;padding:10px;border:1px solid #e5e7eb;border-radius:8px">
        <div class="card-body" style="display:flex;gap:8px;flex-wrap:wrap;align-items:center">
            <form method="post" action="admin-user-crud" style="display:inline">
                <input type="hidden" name="action" value="update" />
                <input type="hidden" name="userId" value="<%= target.getUserId() %>" />
                <input type="hidden" name="fullName" value="<%= target.getFullName() %>" />
                <input type="hidden" name="email" value="<%= target.getEmail() %>" />
                <input type="hidden" name="phone" value="<%= target.getPhoneNumber() %>" />
                <input type="hidden" name="role" value="<%= target.getRole() %>" />
                <input type="hidden" name="active" value="<%= !target.isActive() %>" />
                <button type="submit" class="btn btn-outline btn-sm"><%= target.isActive() ? "Deactivate" : "Activate" %></button>
            </form>
            <form method="post" action="admin-user-crud" style="display:inline" onsubmit="return confirm('Delete this user? This cannot be undone.')">
                <input type="hidden" name="action" value="delete" />
                <input type="hidden" name="userId" value="<%= target.getUserId() %>" />
                <button type="submit" class="btn btn-danger btn-sm">Delete</button>
            </form>
        </div>
    </div>
    <% } %>

    <h3 style="margin-block-start:16px">Events</h3>
    <table>
        <thead><tr><th>ID</th><th>Title</th><th>Date</th><th>Time</th><th>Duration</th><th>Location</th><th>Actions</th></tr></thead>
        <tbody>
        <% if (events != null) { for (Event e : events) { %>
            <tr>
                <td><%= e.getEventId() %></td>
                <td><%= e.getTitle() %></td>
                <td><%= e.getEventDate() %></td>
                <td><%= e.getEventTime() %></td>
                <td><%= e.getDurationMinutes() %>m</td>
                <td><%= e.getLocation() %></td>
                <td>
                    <form class="inline-form" method="post" action="admin-update-user-event">
                        <input type="hidden" name="eventId" value="<%= e.getEventId() %>" />
                        <input type="hidden" name="userId" value="<%= target.getUserId() %>" />
                        <label>Date <input type="date" name="eventDate" value="<%= e.getEventDate() %>" required /></label>
                        <label>Time <input type="time" name="eventTime" value="<%= e.getEventTime() != null ? e.getEventTime().toString().substring(0,5) : "" %>" required /></label>
                        <button type="submit" class="btn btn-outline">Save</button>
                    </form>
                </td>
            </tr>
        <% } } %>
        </tbody>
    </table>
</div>
</body>
</html>

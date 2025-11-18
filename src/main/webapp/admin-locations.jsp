<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.smartcalendar.models.Location" %>
<%
    com.smartcalendar.models.User user = (com.smartcalendar.models.User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    boolean isAdmin = user.getFullName() != null && user.getFullName().equalsIgnoreCase("admin");
    if (!isAdmin && (user.getEmail() == null || !user.getEmail().toLowerCase().startsWith("admin"))) { response.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }
    List<Location> locations = (List<Location>) request.getAttribute("locations");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin: Manage Locations</title>
    <link rel="stylesheet" href="css/main.css" />
    <link rel="stylesheet" href="css/ui.css" />
    <style>
    table{inline-size:100%;border-collapse:collapse;margin-block-start:12px}
        th,td{border:1px solid #e5e7eb;padding:6px;font-size:.85rem;vertical-align:top}
        th{background:#f9fafb}
    .form-inline input[type=text]{inline-size:140px}
        .badge-cat{display:inline-block;padding:2px 6px;border-radius:6px;font-size:.65rem;background:#eef2ff;color:#3730a3;border:1px solid #c7d2fe}
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
    <h2>Manage Locations</h2>
    <p style="margin-block-start:4px;color:#6b7280;font-size:.9rem">Create, edit, or remove campus and city locations.</p>

    <%
        String currentCategory = (String) request.getAttribute("currentCategory");
        if (currentCategory == null) currentCategory = request.getParameter("category");
        if (currentCategory == null) currentCategory = "";
        String activeAll = currentCategory.isEmpty() ? "btn-primary" : "btn-outline";
        String activeGate = "gate".equals(currentCategory) ? "btn-primary" : "btn-outline";
        String activeHospital = "hospital".equals(currentCategory) ? "btn-primary" : "btn-outline";
        String activeImmigration = "immigration".equals(currentCategory) ? "btn-primary" : "btn-outline";
    %>
    <div style="margin-block-start:8px;display:flex;gap:8px;flex-wrap:wrap">
        <a class="btn <%= activeAll %>" href="admin-locations">All</a>
        <a class="btn <%= activeGate %>" href="admin-locations?category=gate">Colleges / Gates</a>
        <a class="btn <%= activeHospital %>" href="admin-locations?category=hospital">Hospitals</a>
        <a class="btn <%= activeImmigration %>" href="admin-locations?category=immigration">Police &amp; Immigration</a>
    </div>

    <form method="post" action="admin-locations" style="margin-block-start:12px;display:flex;flex-wrap:wrap;gap:8px;align-items:flex-end">
        <input type="hidden" name="action" value="create" />
        <div>
            <label>Name<br><input type="text" name="name" required></label>
        </div>
        <div>
            <label>Category<br>
                <select name="category" required>
                    <option value="gate" <%= "gate".equals(currentCategory)?"selected":"" %>>Gate</option>
                    <option value="hospital" <%= "hospital".equals(currentCategory)?"selected":"" %>>Hospital</option>
                    <option value="immigration" <%= "immigration".equals(currentCategory)?"selected":"" %>>Immigration</option>
                    <option value="other" <%= "other".equals(currentCategory)?"selected":"" %>>Other</option>
                </select>
            </label>
        </div>
        <div>
            <label>Map URL<br><input type="text" name="mapUrl" placeholder="https://" required></label>
        </div>
        <div style="flex:1 1 240px">
            <label>Description<br><input type="text" name="description" placeholder="Short description" ></label>
        </div>
        <div><label><input type="checkbox" name="active" checked> Active</label></div>
        <div><button type="submit" class="btn btn-primary">Add Location</button></div>
    </form>

    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Category</th>
                <th>Description</th>
                <th>Map URL</th>
                <th>Active</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
        <% if (locations != null) {
               for (Location l : locations) { %>
            <tr>
                <td><%= l.getLocationId() %></td>
                <td>
                    <form method="post" action="admin-locations" class="form-inline" style="display:flex;flex-wrap:wrap;gap:4px;align-items:center">
                        <input type="hidden" name="action" value="update" />
                        <input type="hidden" name="locationId" value="<%= l.getLocationId() %>" />
                        <input type="text" name="name" value="<%= l.getName() %>" required />
                        <select name="category">
                            <option value="gate" <%= "gate".equals(l.getCategory())?"selected":"" %>>Gate</option>
                            <option value="hospital" <%= "hospital".equals(l.getCategory())?"selected":"" %>>Hospital</option>
                            <option value="immigration" <%= "immigration".equals(l.getCategory())?"selected":"" %>>Immigration</option>
                            <option value="other" <%= "other".equals(l.getCategory())?"selected":"" %>>Other</option>
                        </select>
                        <input type="text" name="mapUrl" value="<%= l.getMapUrl() %>" placeholder="Map URL" />
                        <input type="text" name="description" value="<%= l.getDescription() == null ? "" : l.getDescription() %>" placeholder="Description" />
                        <label class="btn-sm" style="display:inline-flex;align-items:center;gap:6px"><input type="checkbox" name="active" <%= l.isActive()?"checked":"" %>> Active</label>
                        <button type="submit" class="btn btn-primary btn-sm">Save</button>
                    </form>
                </td>
                <td><span class="badge-cat"><%= l.getCategory() %></span></td>
                <td style="max-inline-size:240px"><%= l.getDescription() %></td>
                <td style="max-inline-size:200px;word-break:break-all"><a href="<%= l.getMapUrl() %>" target="_blank" rel="noopener">Map →</a></td>
                <td><%= l.isActive() ? "Yes" : "No" %></td>
                <td>
                    <form method="post" action="admin-locations" onsubmit="return confirm('Delete this location?');">
                        <input type="hidden" name="action" value="delete" />
                        <input type="hidden" name="locationId" value="<%= l.getLocationId() %>" />
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

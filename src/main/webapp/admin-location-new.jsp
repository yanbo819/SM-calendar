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
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin: New Location</title>
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
<nav class="main-nav">
    <div class="nav-container">
        <h1 class="nav-title"><a href="dashboard.jsp">Smart Calendar</a></h1>
        <div class="nav-actions"><!-- admin toolbar below --></div>
    </div>
</nav>
<% if (isAdmin) { %>
<jsp:include page="/WEB-INF/jsp/includes/admin-toolbar.jspf" />
<% } %>
<div class="form-container page">
    <div class="header-row">
        <h2>Add New Location</h2>
        <a href="admin-locations<%= currentCategory.isEmpty()? "" : ("?category="+currentCategory) %>" class="btn btn-outline">← Back to Manage Locations</a>
    </div>

    <div class="card">
        <div class="card-body">
            <form method="post" action="admin-locations">
                <input type="hidden" name="action" value="create" />
                <input type="hidden" name="returnCategory" value="<%= currentCategory %>" />
                <div class="create-grid">
                    <div>
                        <label>Name</label>
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
                <div class="form-actions" style="justify-content:space-between; margin-top:10px;">
                    <label style="display:inline-flex;align-items:center;gap:8px"><input type="checkbox" name="active" checked /> Active</label>
                    <div style="display:flex; gap:8px;">
                        <a href="admin-locations<%= currentCategory.isEmpty()? "" : ("?category="+currentCategory) %>" class="btn btn-outline">Cancel</a>
                        <button type="submit" class="btn btn-primary">Add Location</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>

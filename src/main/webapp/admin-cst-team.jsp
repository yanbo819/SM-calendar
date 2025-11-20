<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.models.CstDepartment" %>
<%@ page import="com.smartcalendar.dao.CstDepartmentDao" %>
<%@ page import="com.smartcalendar.dao.CstVolunteerDao" %>
<%@ page import="com.smartcalendar.models.CstVolunteer" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    if (user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) { response.sendRedirect("dashboard.jsp"); return; }
    List<CstDepartment> deps = (List<CstDepartment>) request.getAttribute("departments");
    if (deps == null) deps = CstDepartmentDao.listAll();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin · CST Shining Team</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .grid{display:grid;grid-template-columns:1fr;gap:16px}
        .card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;padding:16px}
        table{inline-size:100%;border-collapse:collapse}
        th,td{border-block-end:1px solid #e5e7eb;padding:8px;text-align:start}
        .row{display:flex;gap:8px;flex-wrap:wrap}
        .row input,.row select{padding:8px;border:1px solid #e5e7eb;border-radius:8px}
        .cap{text-transform:capitalize}
        .actions{display:flex;gap:8px;align-items:center}
    </style>
</head>
<body>
<nav class="main-nav">
    <div class="nav-container">
        <h1 class="nav-title">CST Shining Team (Admin)</h1>
    </div>
</nav>
<div class="dashboard-container">
    <div class="grid">
        <div class="card">
            <h3 style="margin:0 0 10px 0">Departments</h3>
            <div style="display:flex;justify-content:flex-end;margin-bottom:12px">
                <a href="admin-add-department" class="btn btn-primary" style="font-size:1.05em;padding:10px 24px;">Add New Department</a>
            </div>
            <table style="margin-block-start:12px">
                <thead><tr><th>Name</th><th>Manage</th></tr></thead>
                <tbody>
                <% for (CstDepartment d : deps) { %>
                    <tr>
                        <td style="vertical-align:middle;">
                            <form method="post" action="admin-cst-team" style="display:flex;align-items:center;gap:10px;">
                                <input type="hidden" name="action" value="update-department" />
                                <input type="hidden" name="id" value="<%= d.getId() %>" />
                                <input name="name" value="<%= d.getName() %>" class="cap" style="padding:7px 10px;font-size:15px;border-radius:6px;min-width:180px;max-width:260px;" />
                                <div style="display:flex;gap:6px;">
                                    <button class="btn btn-primary" type="submit" style="padding:7px 18px;">Save</button>
                            </form>
                            <form method="post" action="admin-cst-team" onsubmit="return confirm('Delete department? This removes members too.');" style="display:inline;">
                                <input type="hidden" name="action" value="delete-department" />
                                <input type="hidden" name="id" value="<%= d.getId() %>" />
                                <button class="btn btn-danger" type="submit" style="padding:7px 18px;">Delete</button>
                            </form>
                                </div>
                        </td>
                        <td style="vertical-align:middle;">
                            <a class="btn btn-primary" href="admin-cst-volunteers?dept=<%= d.getId() %>&noheader=1" target="_blank" rel="noopener" style="padding:7px 18px;">Manage Volunteers</a>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>
<div style="display:grid;place-items:center;margin-block-start:24px;margin-block-end:24px">
    <a href="admin-tools.jsp" class="btn btn-outline" style="min-inline-size:160px">Go Back</a>
</div>
</body>
</html>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.models.CstDepartment" %>
<%@ page import="com.smartcalendar.dao.CstDepartmentDao" %>
<%@ page import="com.smartcalendar.dao.CstVolunteerDao" %>
<%@ page import="com.smartcalendar.models.CstVolunteer" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    if (user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) { response.sendRedirect("dashboard.jsp"); return; }
    String deptIdStr = request.getParameter("dept");
    int deptId = deptIdStr != null ? Integer.parseInt(deptIdStr) : -1;
    CstDepartment dept = CstDepartmentDao.findById(deptId);
    if (dept == null) { response.sendRedirect("admin-cst-team.jsp"); return; }
    java.util.List<CstVolunteer> volunteers = CstVolunteerDao.listByDepartment(deptId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Volunteers - <%= dept.getName() %></title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .container{max-width:900px;margin:32px auto;padding:0 16px;}
        .header-row{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:18px;}
        .vol-list{margin-bottom:32px;}
        .vol-list table{width:100%;border-collapse:collapse;}
        .vol-list th,.vol-list td{border-bottom:1px solid #e5e7eb;padding:10px;text-align:left;}
        .actions{display:flex;gap:8px;}
        .form-section{background:#fff;border:1px solid #e5e7eb;border-radius:12px;padding:24px;max-width:500px;margin:0 auto;}
        .form-grid{display:grid;gap:14px;}
        .form-grid label{font-weight:500;}
        .form-grid input,.form-grid select{padding:8px;border:1px solid #e5e7eb;border-radius:8px;}
        .form-actions{display:flex;gap:12px;justify-content:flex-end;margin-top:18px;}
        .photo-preview{width:120px;height:120px;object-fit:cover;border-radius:12px;border:1px solid #e5e7eb;}
        .btn{padding:8px 18px;border-radius:8px;}
        .btn-primary{background:#2563eb;color:#fff;border:none;}
        .btn-outline{background:#fff;color:#2563eb;border:1px solid #2563eb;}
        .btn-danger{background:#dc2626;color:#fff;border:none;}
        .back-btn{margin-bottom:18px;}
    </style>
    <script>
    function disableBack() {
        history.pushState(null, document.title, location.href);
        window.addEventListener('popstate', function () {
            history.pushState(null, document.title, location.href);
        });
    }
    window.onload = disableBack;
    </script>
</head>
<body>
<div class="container">
    <div class="header-row">
        <h2 style="margin:0">Volunteers — <%= dept.getName() %></h2>
        <a class="btn btn-primary" href="admin-add-volunteer.jsp?dept=<%= dept.getId() %>">Add New Volunteer</a>
    </div>
    <div class="vol-list">
        <h3 style="margin:0 0 18px 0;text-align:center;font-size:1.15em;color:#2563eb;">Current Members</h3>
        <table style="background:#fff;border-radius:10px;box-shadow:0 1px 4px #e5e7eb;overflow:hidden;">
            <thead>
                <tr style="background:#f3f4f6;">
                    <th>Photo</th>
                    <th>Passport Name</th>
                    <th>Chinese Name</th>
                    <th>Student ID</th>
                    <th>Nationality</th>
                    <th>Gender</th>
                    <th>Phone</th>
                </tr>
            </thead>
            <tbody>
            <% for (CstVolunteer v : volunteers) { %>
                <tr>
                    <td style="text-align:center;">
                        <% if (v.getPhotoUrl() != null && !v.getPhotoUrl().isEmpty()) { %>
                            <img src="<%= v.getPhotoUrl() %>" class="photo-preview"/>
                        <% } else { %>
                            <span style="color:#bbb;font-size:1.2em;">—</span>
                        <% } %>
                    </td>
                    <td><%= v.getPassportName() %></td>
                    <td><%= v.getChineseName() %></td>
                    <td><%= v.getStudentId() %></td>
                    <td><%= v.getNationality() %></td>
                    <td><%= v.getGender() %></td>
                    <td><%= v.getPhone() %></td>
                </tr>
            <% } %>
            </tbody>
        </table>
    </div>
    <div style="display:flex;justify-content:center;margin-top:48px;padding-bottom:32px;">
        <button class="btn btn-outline" onclick="window.location.href='admin-cst-team.jsp'">Go Back</button>
    </div>
</div>
</body>
</html>

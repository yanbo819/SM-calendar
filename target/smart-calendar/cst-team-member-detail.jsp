<%@ page import="com.smartcalendar.models.CstVolunteer, com.smartcalendar.dao.CstVolunteerDao, com.smartcalendar.dao.CstDepartmentDao, com.smartcalendar.models.CstDepartment" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String idStr = request.getParameter("id");
    String deptIdStr = request.getParameter("dept");
    int id = -1;
    int deptId = -1;
    if (idStr != null) {
        try { id = Integer.parseInt(idStr); } catch (Exception e) { id = -1; }
    }
    if (deptIdStr != null) {
        try { deptId = Integer.parseInt(deptIdStr); } catch (Exception e) { deptId = -1; }
    }
    CstVolunteer v = null;
    CstDepartment dept = null;
    String errorMsg = null;
    try {
        v = com.smartcalendar.dao.CstVolunteerDao.findById(id);
        if (deptId > 0) {
            dept = com.smartcalendar.dao.CstDepartmentDao.findById(deptId);
        }
        if (v == null) errorMsg = "Volunteer not found.";
    } catch (Exception e) {
        errorMsg = "Error loading volunteer information.";
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>CST Shining Team - Member Detail</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .member-detail-card{background:#fff;border-radius:10px;box-shadow:0 2px 12px #e5e7eb;padding:32px;max-width:420px;margin:40px auto;}
        .member-img{width:96px;height:96px;border-radius:50%;object-fit:cover;border:1px solid #e5e7eb;margin-bottom:18px;}
        .kv{display:flex;justify-content:space-between;margin:8px 0;}
        .kv b{color:#374151;}
        .back-btn{margin:32px auto 0 auto;display:block;}
    </style>
</head>
<body>
    <div class="container">
        <% if (dept != null) { %>
            <div style="text-align:left;margin-bottom:18px;">
                <span class="btn btn-light" style="pointer-events:none;opacity:.85;font-weight:bold;font-size:1.1em;">Department: <%= dept.getName() %></span>
            </div>
        <% } %>
        <% if (errorMsg != null) { %>
            <div class="member-detail-card" style="text-align:center;color:#ef4444;font-weight:bold;"> <%= errorMsg %> </div>
        <% } else { %>
        <div class="member-detail-card" style="text-align:center;">
            <img class="member-img" src="<%= v.getPhotoUrl()!=null && !v.getPhotoUrl().isEmpty() ? v.getPhotoUrl() : "https://via.placeholder.com/96" %>" alt="photo" />
            <h2 style="margin-bottom:8px;"><%= v.getPassportName()!=null?v.getPassportName():"Unknown" %></h2>
            <div style="color:#6b7280;font-size:1.1em;margin-bottom:18px;"><%= v.getChineseName()!=null?v.getChineseName():"" %></div>
            <div class="kv"><b>Student ID</b><span><%= v.getStudentId()!=null?v.getStudentId():"" %></span></div>
            <div class="kv"><b>Phone</b><span><%= v.getPhone()!=null?v.getPhone():"" %></span></div>
            <div class="kv"><b>Gender</b><span><%= v.getGender()!=null?v.getGender():"" %></span></div>
            <div class="kv"><b>Nationality</b><span><%= v.getNationality()!=null?v.getNationality():"" %></span></div>
            <div style="margin-top:24px;display:flex;gap:16px;justify-content:center;">
                <a href="admin-edit-volunteer.jsp?id=<%= v.getId() %>&dept=<%= deptId %>" class="btn btn-primary">Edit</a>
                <form method="post" action="admin-delete-volunteer" style="display:inline;" onsubmit="return confirm('Are you sure you want to delete this volunteer?');">
                    <input type="hidden" name="id" value="<%= v.getId() %>" />
                    <input type="hidden" name="dept" value="<%= deptId %>" />
                    <button type="submit" class="btn btn-danger">Delete</button>
                </form>
            </div>
        </div>
        <% } %>
        <div style="margin-top:32px;text-align:center;">
        <% if (deptId > 0) { %>
            <a href="cst-team-members.jsp?dept=<%= deptId %>" class="btn btn-primary back-btn">&larr; Back to Department</a>
        <% } else { %>
            <a href="cst-team.jsp" class="btn btn-primary back-btn">&larr; Back to Departments</a>
        <% } %>
        </div>
    </div>
</body>
</html>

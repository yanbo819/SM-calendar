<%@ page import="java.util.*, com.smartcalendar.models.CstDepartment, com.smartcalendar.models.CstVolunteer, com.smartcalendar.dao.CstVolunteerDao, com.smartcalendar.dao.CstDepartmentDao" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String deptIdStr = request.getParameter("dept");
    int deptId = -1;
    if (deptIdStr != null) {
        try { deptId = Integer.parseInt(deptIdStr); } catch (Exception e) { deptId = -1; }
    }
    CstDepartment dept = null;
    List<CstVolunteer> members = Collections.emptyList();
    String errorMsg = null;
    try {
        dept = com.smartcalendar.dao.CstDepartmentDao.findById(deptId);
        if (dept != null) {
            members = com.smartcalendar.dao.CstVolunteerDao.listByDepartment(deptId);
        } else {
            errorMsg = "Department not found.";
        }
    } catch (Exception e) {
        errorMsg = "Error loading department or volunteers.";
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>CST Shining Team - Members</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .member-list{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:12px;margin-block-start:10px}
        .member-card{background:#fff;border-radius:8px;box-shadow:0 2px 8px #e5e7eb;padding:18px;text-align:center;transition:box-shadow .2s;cursor:pointer;}
        .member-card:hover{box-shadow:0 4px 16px #cbd5e1;}
        .member-img{width:56px;height:56px;border-radius:50%;object-fit:cover;border:1px solid #e5e7eb;margin-bottom:8px;}
        .member-name{font-weight:bold;font-size:1.1em;}
        .back-btn{margin:24px auto 0 auto;display:block;}
    </style>
</head>
<body>
    <div class="container">
        <h2 style="margin-bottom:18px;">Department: <%= dept != null ? dept.getName() : "Unknown" %></h2>
        <% if (errorMsg != null) { %>
            <div style="color:#ef4444;font-weight:bold;margin-bottom:18px;"><%= errorMsg %></div>
        <% } else if (members.isEmpty()) { %>
            <div style="color:#6b7280">No volunteers in this department.</div>
        <% } else { %>
        <div class="member-list">
            <% for (CstVolunteer v : members) { %>
                <div class="member-card">
                    <a href="cst-team-member-detail.jsp?id=<%= v.getId() %>&dept=<%= deptId %>">
                        <img class="member-img" src="<%= v.getPhotoUrl()!=null && !v.getPhotoUrl().isEmpty() ? v.getPhotoUrl() : "https://via.placeholder.com/56" %>" alt="photo" />
                        <div class="member-name"><%= v.getPassportName()!=null?v.getPassportName():"Unknown" %></div>
                        <div style="color:#6b7280;font-size:.95em;"><%= v.getChineseName()!=null?v.getChineseName():"" %></div>
                    </a>
                </div>
            <% } %>
        </div>
        <% } %>
        <a href="cst-team.jsp" class="btn btn-secondary back-btn">&larr; Back to Departments</a>
    </div>
</body>
</html>

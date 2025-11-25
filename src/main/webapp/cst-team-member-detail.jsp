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
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.member.detail.title") %></title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .member-detail-card{background:#fff;border-radius:10px;box-shadow:0 2px 12px #e5e7eb;padding:32px;max-width:420px;margin:40px auto;}
        .member-img{width:96px;height:96px;border-radius:50%;object-fit:cover;border:1px solid #e5e7eb;margin-bottom:18px;}
        .kv{display:flex;justify-content:space-between;margin:8px 0;}
        .kv b{color:#374151;}
        .back-btn{margin:32px auto 0 auto;display:block;}
        .contact-row{margin-top:16px;display:flex;gap:10px;flex-wrap:wrap;justify-content:center;}
        .btn-sm{padding:6px 12px;font-size:.7rem;border-radius:6px;}
    </style>
</head>
<body>
    <div class="container">
        <% if (dept != null) { %>
            <div style="text-align:left;margin-bottom:18px;">
                <span class="btn btn-light" style="pointer-events:none;opacity:.85;font-weight:bold;font-size:1.1em;"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.department") %>: <%= dept.getName() %></span>
            </div>
        <% } %>
        <% if (errorMsg != null) { %>
            <div class="member-detail-card" style="text-align:center;color:#ef4444;font-weight:bold;"> <%= errorMsg %> </div>
        <% } else { %>
        <div class="member-detail-card" style="text-align:center;max-inline-size:760px;">
            <img class="member-img" style="width:140px;height:140px;" src="<%= v.getPhotoUrl()!=null && !v.getPhotoUrl().isEmpty() ? v.getPhotoUrl() : "https://via.placeholder.com/140" %>" alt="photo" />
            <h2 style="margin-bottom:12px;font-size:2rem"><%= v.getPassportName()!=null?v.getPassportName():"Unknown" %></h2>
            <% if (v.getChineseName()!=null && !v.getChineseName().isEmpty()) { %>
               <div style="color:#6b7280;font-size:1.15rem;margin-bottom:18px;">(<%= v.getChineseName() %>)</div>
            <% } %>
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:12px;text-align:left;margin-bottom:24px;font-size:.9rem;">
                <div class="kv"><b><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "vol.studentId") %></b><span><%= v.getStudentId()!=null?v.getStudentId():"—" %></span></div>
                <div class="kv"><b><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "vol.phone") %></b><span><%= v.getPhone()!=null?v.getPhone():"—" %></span></div>
                <div class="kv"><b>Email</b><span><%= v.getEmail()!=null?v.getEmail():"—" %></span></div>
                <div class="kv"><b><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "vol.gender") %></b><span><%= v.getGender()!=null?v.getGender():"—" %></span></div>
                <div class="kv"><b><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "vol.nationality") %></b><span><%= v.getNationality()!=null?v.getNationality():"—" %></span></div>
                <div class="kv"><b>Active</b><span><%= v.isActive()?"Yes":"No" %></span></div>
            </div>
            <% com.smartcalendar.models.User currentUser = (com.smartcalendar.models.User) session.getAttribute("user");
               boolean isAdmin = currentUser != null && currentUser.getRole() != null && currentUser.getRole().equalsIgnoreCase("admin"); %>
            <div class="contact-row">
                <% if (v.getPhone()!=null && !v.getPhone().isEmpty()) { %>
                    <a href="tel:<%= v.getPhone() %>" class="btn btn-outline btn-sm">Call</a>
                <% } %>
                <% if (v.getEmail()!=null && !v.getEmail().isEmpty()) { %>
                    <a href="mailto:<%= v.getEmail() %>" class="btn btn-primary btn-sm">Email</a>
                <% } %>
                <% if (isAdmin) { %>
                    <a href="edit-volunteer.jsp?id=<%= v.getId() %>&dept=<%= deptId %>" class="btn btn-primary btn-sm"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.edit") %></a>
                    <form method="post" action="delete-volunteer" style="display:inline;" onsubmit="return confirm('<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.volunteer.deleteConfirm") %>');">
                        <input type="hidden" name="id" value="<%= v.getId() %>" />
                        <input type="hidden" name="dept" value="<%= deptId %>" />
                        <button type="submit" class="btn btn-danger btn-sm"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.delete") %></button>
                    </form>
                <% } %>
            </div>
        </div>
        <% } %>
        <div style="margin-top:32px;text-align:center;">
        <% if (deptId > 0) { %>
            <a href="cst-team-members.jsp?dept=<%= deptId %>" class="btn btn-primary back-btn">&larr; <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.back.department") %></a>
        <% } else { %>
            <a href="cst-team.jsp" class="btn btn-primary back-btn">&larr; <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.back.departments") %></a>
        <% } %>
        </div>
    </div>
</body>
</html>

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
    <title>Edit Volunteer</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .edit-form{max-width:420px;margin:40px auto;background:#fff;padding:32px;border-radius:10px;box-shadow:0 2px 12px #e5e7eb;}
        .form-group{margin-bottom:18px;}
        label{font-weight:bold;display:block;margin-bottom:6px;}
        input,select{width:100%;padding:8px 10px;border:1px solid #e5e7eb;border-radius:6px;}
        .btn-row{display:flex;gap:16px;justify-content:center;margin-top:24px;}
    </style>
</head>
<body>
    <div class="container">
        <h2>Edit Volunteer</h2>
        <% if (errorMsg != null) { %>
            <div style="color:#ef4444;font-weight:bold;margin-bottom:18px;"><%= errorMsg %></div>
        <% } else { %>
        <form class="edit-form" method="post" action="admin-edit-volunteer" enctype="multipart/form-data">
            <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
            <input type="hidden" name="id" value="<%= v.getId() %>" />
            <input type="hidden" name="dept" value="<%= deptId %>" />
            <div class="form-group">
                <label>Passport Name</label>
                <input type="text" name="passportName" value="<%= v.getPassportName() != null ? v.getPassportName() : "" %>" required />
            </div>
            <div class="form-group">
                <label>Chinese Name</label>
                <input type="text" name="chineseName" value="<%= v.getChineseName() != null ? v.getChineseName() : "" %>" />
            </div>
            <div class="form-group">
                <label>Student ID</label>
                <input type="text" name="studentId" value="<%= v.getStudentId() != null ? v.getStudentId() : "" %>" />
            </div>
            <div class="form-group">
                <label>Phone</label>
                <input type="text" name="phone" value="<%= v.getPhone() != null ? v.getPhone() : "" %>" />
            </div>
            <div class="form-group">
                <label>Gender</label>
                <select name="gender">
                    <option value="" <%= v.getGender()==null||v.getGender().isEmpty()?"selected":"" %>>Select</option>
                    <option value="Male" <%= "Male".equals(v.getGender())?"selected":"" %>>Male</option>
                    <option value="Female" <%= "Female".equals(v.getGender())?"selected":"" %>>Female</option>
                </select>
            </div>
            <div class="form-group">
                <label>Nationality</label>
                <input type="text" name="nationality" value="<%= v.getNationality() != null ? v.getNationality() : "" %>" />
            </div>
            <div class="form-group">
                <label>Photo</label>
                <input type="file" name="photo_file" accept="image/*" />
                <% if (v.getPhotoUrl() != null && !v.getPhotoUrl().isEmpty()) { %>
                    <img src="<%= v.getPhotoUrl() %>" alt="photo" style="width:56px;height:56px;border-radius:50%;margin-top:8px;" />
                <% } %>
            </div>
            <div class="btn-row">
                <button type="submit" class="btn btn-primary">Save</button>
                <a href="cst-team-member-detail.jsp?id=<%= v.getId() %>&dept=<%= deptId %>" class="btn btn-secondary">Cancel</a>
            </div>
        </form>
        <% } %>
    </div>
</body>
</html>

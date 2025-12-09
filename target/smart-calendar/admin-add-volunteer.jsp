<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.models.CstDepartment" %>
<%@ page import="com.smartcalendar.dao.CstDepartmentDao" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    if (user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) { response.sendRedirect("dashboard"); return; }
    String deptIdStr = request.getParameter("dept");
    int deptId = deptIdStr != null ? Integer.parseInt(deptIdStr) : -1;
    CstDepartment dept = CstDepartmentDao.findById(deptId);
    if (dept == null) { response.sendRedirect("admin-cst-team"); return; }
%>
<!DOCTYPE html>
<%
    String lang = (String) session.getAttribute("lang");
    if (lang == null && user.getPreferredLanguage() != null) lang = user.getPreferredLanguage();
    if (lang == null) lang = "en";
    String textDir = com.smartcalendar.utils.LanguageUtil.getTextDirection(lang);
%>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.volunteer.addNew") %> - <%= dept.getName() %></title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .container{max-width:500px;margin:40px auto;padding:0 16px;}
        .form-section{background:#fff;border:1px solid #e5e7eb;border-radius:12px;padding:32px;}
        .form-title{margin:0 0 18px 0;text-align:center;font-size:1.3em;font-weight:600;}
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
        .form-grid{display:grid;gap:18px;}
        .form-grid label{font-weight:500;display:block;margin-bottom:6px;}
        .form-grid input,.form-grid select{width:100%;padding:10px;border:1px solid #e5e7eb;border-radius:8px;font-size:1em;}
        .form-actions{display:flex;gap:16px;justify-content:center;margin-top:24px;}
        .photo-preview{width:120px;height:120px;object-fit:cover;border-radius:12px;border:1px solid #e5e7eb;margin-bottom:10px;display:none;}
    </style>
    <script>
    function previewPhoto(input) {
        const img = document.getElementById('photoPreview');
        if (input.files && input.files[0]) {
            img.src = URL.createObjectURL(input.files[0]);
            img.style.display = 'block';
        } else {
            img.style.display = 'none';
        }
    }
    </script>
</head>
<body>
<div class="container">
    <form class="form-section" method="post" action="admin-cst-volunteers" enctype="multipart/form-data">
        <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
        <input type="hidden" name="action" value="add" />
        <h2 class="form-title"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.volunteer.addNew") %><br><span style="font-size:.8em;font-weight:400;color:#666;"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.volunteer.departmentLabel") %> <%= dept.getName() %></span></h2>
        <div class="form-grid">
            <input type="hidden" name="department_id" value="<%= dept.getId() %>" />
            <label>Volunteer Picture
                <input type="file" name="photo_file" accept="image/*" required onchange="previewPhoto(this)">
                <img id="photoPreview" class="photo-preview" alt="Preview" />
            </label>
            <label>Email
                <input type="email" name="email" maxlength="255" placeholder="volunteer@example.com">
            </label>
            <label>Passport Name
                <input type="text" name="passport_name" required maxlength="100">
            </label>
            <label>Chinese Name
                <input type="text" name="chinese_name" required maxlength="100">
            </label>
            <label>Student ID Number
                <input type="text" name="student_id" required maxlength="50">
            </label>
            <label>Nationality
                <input type="text" name="nationality" required maxlength="50">
            </label>
            <label>Gender
                <select name="gender" required>
                    <option value="">Select</option>
                    <option value="Male">Male</option>
                    <option value="Female">Female</option>
                </select>
            </label>
            <label>Phone Number
                <input type="text" name="phone" required maxlength="30">
            </label>
        </div>
        <div class="form-actions">
            <button type="submit" class="btn btn-primary"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.save") %></button>
            <a href="admin-volunteers.jsp?dept=<%= dept.getId() %>" class="btn btn-outline"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.back") %></a>
        </div>
    </form>
</div>
</body>
</html>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.smartcalendar.models.College" %>
<%@ page import="java.util.List" %>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<%@ include file="/WEB-INF/jspf/flash-messages.jspf" %>
<%
    List<College> colleges = (List<College>) request.getAttribute("colleges");
    if (colleges == null) {
        colleges = java.util.Collections.emptyList();
    }
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.title") %></title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .college-card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;padding:18px;margin-block-end:18px;max-inline-size:600px}
        .college-photo{inline-size:64px;block-size:64px;border-radius:50%;object-fit:cover;border:1px solid #e5e7eb}
        .form-group{margin-block-end:14px;}
        label{font-weight:bold;display:block;margin-block-end:4px;}
        input,textarea{inline-size:100%;padding:7px 10px;border:1px solid #e5e7eb;border-radius:6px;}
        .btn-row{display:flex;gap:12px;justify-content:flex-end;margin-block-start:10px;}
    </style>
</head>
<body>
    <div class="container">
        <h2><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.title") %></h2>
        <% if (error != null) { %>
            <div style="color:#ef4444;font-weight:bold;margin-bottom:18px;"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.error.save") %></div>
        <% } %>
        <% for (College c : colleges) { %>
        <div class="college-card">
            <form method="post" action="admin-colleges" enctype="multipart/form-data">
                <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
                <input type="hidden" name="id" value="<%= c.getId() %>" />
                <div class="form-group">
                    <label><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.name") %></label>
                    <input type="text" name="name" value="<%= c.getName() %>" required />
                </div>
                <div class="form-group">
                    <label><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.address") %></label>
                    <input type="text" name="address" value="<%= c.getAddress() %>" />
                </div>
                <div class="form-group">
                    <label><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.phone") %></label>
                    <input type="text" name="phone" value="<%= c.getPhone() %>" />
                </div>
                <div class="form-group">
                    <label><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.teacher.name") %></label>
                    <input type="text" name="teacherName" value="<%= c.getTeacherName() %>" />
                </div>
                <div class="form-group">
                    <label><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.teacher.photo") %></label>
                    <input type="file" name="teacherPhoto" accept="image/*" />
                    <% if (c.getTeacherPhotoUrl() != null && !c.getTeacherPhotoUrl().isEmpty()) { %>
                        <img src="<%= c.getTeacherPhotoUrl() %>" alt="photo" class="college-photo" />
                    <% } %>
                </div>
                <div class="btn-row">
                    <button type="submit" class="btn btn-primary"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.save") %></button>
                </div>
            </form>
        </div>
        <% } %>
            <div style="margin-block-start:24px">
            <a href="admin-tools.jsp" class="btn btn-outline"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.back.tools") %></a>
        </div>
    </div>
</body>
</html>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.smartcalendar.models.College" %>
<%@ page import="java.util.List" %>
<%
    List<College> colleges = (List<College>) request.getAttribute("colleges");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Colleges Info</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .college-card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;padding:18px;margin-bottom:18px;max-width:600px}
        .college-photo{width:64px;height:64px;border-radius:50%;object-fit:cover;border:1px solid #e5e7eb}
        .form-group{margin-bottom:14px;}
        label{font-weight:bold;display:block;margin-bottom:4px;}
        input,textarea{width:100%;padding:7px 10px;border:1px solid #e5e7eb;border-radius:6px;}
        .btn-row{display:flex;gap:12px;justify-content:flex-end;margin-top:10px;}
    </style>
</head>
<body>
    <div class="container">
        <h2>Colleges Info</h2>
        <% if (error != null) { %>
            <div style="color:#ef4444;font-weight:bold;margin-bottom:18px;">Error saving college info.</div>
        <% } %>
        <% for (College c : colleges) { %>
        <div class="college-card">
            <form method="post" action="admin-colleges" enctype="multipart/form-data">
                <input type="hidden" name="id" value="<%= c.getId() %>" />
                <div class="form-group">
                    <label>Name</label>
                    <input type="text" name="name" value="<%= c.getName() %>" required />
                </div>
                <div class="form-group">
                    <label>Address</label>
                    <input type="text" name="address" value="<%= c.getAddress() %>" />
                </div>
                <div class="form-group">
                    <label>Phone</label>
                    <input type="text" name="phone" value="<%= c.getPhone() %>" />
                </div>
                <div class="form-group">
                    <label>Teacher Name</label>
                    <input type="text" name="teacherName" value="<%= c.getTeacherName() %>" />
                </div>
                <div class="form-group">
                    <label>Teacher Photo</label>
                    <input type="file" name="teacherPhoto" accept="image/*" />
                    <% if (c.getTeacherPhotoUrl() != null && !c.getTeacherPhotoUrl().isEmpty()) { %>
                        <img src="<%= c.getTeacherPhotoUrl() %>" alt="photo" class="college-photo" />
                    <% } %>
                </div>
                <div class="btn-row">
                    <button type="submit" class="btn btn-primary">Save</button>
                </div>
            </form>
        </div>
        <% } %>
        <div style="margin-top:24px">
            <a href="admin-tools.jsp" class="btn btn-outline">Back to Admin Tools</a>
        </div>
    </div>
</body>
</html>

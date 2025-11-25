<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.dao.CstDepartmentDao" %>
<%@ page import="com.smartcalendar.models.CstDepartment" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    boolean isAdmin = user.getRole()!=null && user.getRole().equalsIgnoreCase("admin");
    if (!isAdmin) { response.sendRedirect("college-volunteers.jsp"); return; }
    int deptId = -1; CstDepartment dept = null; String d = request.getParameter("dept");
    if (d != null) { try { deptId = Integer.parseInt(d); } catch(Exception ignored) {} }
    if (deptId > 0) { try { dept = CstDepartmentDao.findById(deptId); } catch(Exception ignored) {} }
    if (dept == null) { response.sendRedirect("college-volunteers.jsp"); return; }
%>
<!DOCTYPE html>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8" />
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.volunteer.addPageTitle") %></title>
    <link rel="stylesheet" href="css/main.css" />
    <style>
        .form-wrap{max-inline-size:760px;margin:32px auto;padding:34px;background:#fff;border:1px solid #e5e7eb;border-radius:24px;box-shadow:0 8px 28px rgba(0,0,0,.07)}
        .form-wrap h1{margin:0 0 4px 0;font-size:1.9rem;font-weight:700;color:#1f2937}
        .sub{margin:0 0 20px 0;font-size:.9rem;color:#6b7280}
        .grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:20px}
        label{display:block;font-size:.65rem;font-weight:600;letter-spacing:.5px;text-transform:uppercase;color:#374151;margin-block-end:6px}
        input{inline-size:100%;padding:11px 14px;border:1px solid #d1d5db;border-radius:12px;font-size:.85rem}
        .actions{display:flex;gap:14px;flex-wrap:wrap;margin-block-start:28px}
    </style>
</head>
<body>
<nav class="main-nav"><div class="nav-container"><h1 class="nav-title">Add Volunteer</h1></div></nav>
<div class="form-wrap">
    <h1><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.volunteer.addNew") %></h1>
    <p class="sub">Department: <strong><%= dept.getName() %></strong></p>
    <form method="post" action="create-volunteer" enctype="multipart/form-data">
        <input type="hidden" name="deptId" value="<%= dept.getId() %>" />
        <div class="grid">
            <div>
                <label for="photoFile">Photo File (jpg/png/webp)</label>
                <input id="photoFile" name="photoFile" type="file" accept="image/jpeg,image/png,image/webp" />
            </div>
            <div>
                <label for="passportName">English Name</label>
                <input id="passportName" name="passportName" required />
            </div>
            <div>
                <label for="chineseName">Chinese Name</label>
                <input id="chineseName" name="chineseName" />
            </div>
            <div>
                <label for="nationality">Nationality</label>
                <input id="nationality" name="nationality" />
            </div>
            <div>
                <label for="phone">Phone</label>
                <input id="phone" name="phone" />
            </div>
            <div>
                <label for="email">Email</label>
                <input id="email" name="email" type="email" />
            </div>
        </div>
        <div class="actions">
            <button type="submit" class="btn btn-primary" style="padding:12px 22px;border-radius:14px">+ <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.volunteer.addButton") %></button>
            <a href="cst-team-members.jsp?dept=<%= dept.getId() %>" class="btn btn-secondary" style="padding:12px 22px;border-radius:14px"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.back") %></a>
        </div>
    </form>
</div>
</body>
</html>

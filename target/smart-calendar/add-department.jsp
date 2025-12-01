<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    boolean isAdmin = user.getRole()!=null && user.getRole().equalsIgnoreCase("admin");
    if (!isAdmin) { response.sendRedirect("college-volunteers.jsp"); return; }
    String variant = request.getParameter("variant");
    if (variant == null) variant = "generic";
%>
<!DOCTYPE html>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8" />
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.department.addPageTitle") %></title>
    <link rel="stylesheet" href="css/main.css" />
    <style>
        .form-wrap{max-inline-size:640px;margin:32px auto;padding:32px;background:#fff;border:1px solid #e5e7eb;border-radius:20px;box-shadow:0 6px 24px rgba(0,0,0,.06);}
        .form-wrap h1{margin:0 0 8px 0;font-size:1.7rem;font-weight:700;color:#1f2937}
        .form-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:18px;margin-block:24px}
        .field label{display:block;font-size:.70rem;letter-spacing:.5px;text-transform:uppercase;font-weight:600;color:#374151;margin-block-end:6px}
        .field input{inline-size:100%;padding:10px 14px;border:1px solid #d1d5db;border-radius:10px;font-size:.85rem}
        .actions{display:flex;gap:12px;flex-wrap:wrap}
        .hint{font-size:.65rem;color:#6b7280;margin-block-start:4px}
    </style>
</head>
<body>
<nav class="main-nav"><div class="nav-container"><h1 class="nav-title">Add Department</h1></div></nav>
<div class="form-wrap">
    <h1><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.department.addNew") %></h1>
    <form method="post" action="create-department">
        <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
        <input type="hidden" name="variant" value="<%= variant %>" />
        <div class="form-grid">
            <div class="field">
                <label for="deptName"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.department.name") %></label>
                <input id="deptName" name="name" required maxlength="120" placeholder="e.g. Outreach & Partnerships" />
            </div>
            <div class="field">
                <label for="leaderName">Leader Name</label>
                <input id="leaderName" name="leaderName" maxlength="120" placeholder="Optional" />
            </div>
            <div class="field">
                <label for="leaderPhone">Leader Phone</label>
                <input id="leaderPhone" name="leaderPhone" maxlength="40" placeholder="Optional" />
            </div>
        </div>
        <div class="actions">
            <button type="submit" class="btn btn-primary" style="padding:12px 20px;border-radius:12px">+ <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.department.addButton") %></button>
            <a href="<%= "business".equals(variant)?"business-admin":"chinese".equals(variant)?"chinese-volunteers":"college-volunteers.jsp" %>" class="btn btn-secondary" style="padding:12px 20px;border-radius:12px"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.back") %></a>
        </div>
        <p class="hint">After creation you can add volunteers.</p>
    </form>
</div>
</body>
</html>

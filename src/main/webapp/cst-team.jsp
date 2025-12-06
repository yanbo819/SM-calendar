<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.models.CstDepartment" %>
<%@ page import="com.smartcalendar.models.CstVolunteer" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    List<CstDepartment> deps = (List<CstDepartment>) request.getAttribute("departments");
    Map<Integer, List<CstVolunteer>> members = (Map<Integer, List<CstVolunteer>>) request.getAttribute("members");
%>
<!DOCTYPE html>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.team.title") %></title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .hero{display:flex;flex-wrap:wrap;align-items:flex-end;justify-content:space-between;margin:10px auto 28px auto;gap:18px}
        .hero h1{margin:0;font-size:2.1rem;font-weight:700;letter-spacing:.5px;color:#1f2937}
        .hero .sub{margin:4px 0 0 0;font-size:.85rem;color:#555}
        .dept-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:20px}
        .dept-card{position:relative;background:#fff;border:1px solid #e5e7eb;border-radius:18px;padding:18px 18px 54px 18px;box-shadow:0 2px 4px rgba(0,0,0,.05);display:flex;flex-direction:column;justify-content:space-between;transition:box-shadow .25s,transform .25s}
        .dept-card:hover{box-shadow:0 10px 28px rgba(0,0,0,.08);transform:translateY(-5px)}
        .dept-name{font-size:1.05rem;font-weight:600;color:#1f2937;margin:0 0 6px 0}
        .dept-count{font-size:.65rem;color:#64748b;letter-spacing:.5px;text-transform:uppercase}
        .dept-actions{position:absolute;left:0;right:0;bottom:0;padding:10px 16px;display:flex;justify-content:flex-end;gap:10px}
        .dept-actions a{flex:1}
        @media (max-width:640px){.hero h1{font-size:1.7rem}.dept-grid{grid-template-columns:repeat(auto-fill,minmax(180px,1fr))}.dept-card{padding:16px 14px 50px 14px}}
    </style>
</head>
<body>
<nav class="main-nav">
    <div class="nav-container">
        <h1 class="nav-title"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.team.title") %></h1>
    </div>
</nav>
<div class="dashboard-container">
    <div class="hero">
        <div style="flex:1;min-width:260px">
            <h1><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.team.title") %></h1>
            <p class="sub"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.departments") %> · <strong><%= deps != null ? deps.size() : 0 %></strong></p>
        </div>
        <div style="display:flex;gap:10px;align-items:center;">
            <a href="dashboard" class="btn btn-secondary">&larr; <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.back") %></a>
        </div>
    </div>
    <div class="dept-grid">
        <% for (CstDepartment d : deps) { int cnt = 0; List<CstVolunteer> mv = members!=null?members.get(d.getId()):null; if(mv!=null) cnt = mv.size(); %>
            <div class="dept-card">
                <div>
                    <h2 class="dept-name"><%= d.getName() %></h2>
                    <div class="dept-count"><%= cnt %> <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.members.count.label") %></div>
                </div>
                <div class="dept-actions">
                    <a href="cst-team-members.jsp?dept=<%= d.getId() %>" class="btn btn-primary" style="font-size:.8rem;padding:10px 14px;"> <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.view.members") %> </a>
                </div>
            </div>
        <% } %>
    </div>
</div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>

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
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "dashboard.businessAdmin") %> - <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "app.title") %></title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .hero{display:flex;flex-wrap:wrap;align-items:flex-end;justify-content:space-between;margin:10px auto 28px auto;gap:18px;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);color:#fff;padding:24px;border-radius:16px}
        .hero h1{margin:0;font-size:2.1rem;font-weight:700;letter-spacing:.5px}
        .hero .sub{margin:4px 0 0 0;font-size:.85rem;opacity:.9}
        .dept-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:24px}
        .dept-card{position:relative;background:#fff;border:1px solid #e5e7eb;border-radius:20px;padding:20px 20px 60px 20px;box-shadow:0 4px 6px rgba(0,0,0,.07);display:flex;flex-direction:column;justify-content:space-between;transition:all .3s ease;transform:translateY(0)}
        .dept-card:hover{box-shadow:0 12px 32px rgba(0,0,0,.12);transform:translateY(-8px);border-color:#667eea}
        .dept-name{font-size:1.1rem;font-weight:600;color:#1f2937;margin:0 0 8px 0}
        .dept-desc{font-size:.85rem;color:#6b7280;margin:0 0 12px 0;line-height:1.4}
        .dept-count{font-size:.7rem;color:#667eea;letter-spacing:.5px;text-transform:uppercase;font-weight:500;background:#f3f4f6;padding:4px 8px;border-radius:12px;display:inline-block;margin-block-end:8px}
        .dept-actions{position:absolute;inset-inline-start:0;inset-inline-end:0;inset-block-end:0;padding:12px 18px;display:flex;justify-content:flex-end;gap:12px;border-block-start:1px solid #f3f4f6;border-radius:0 0 20px 20px;background:#fafafa}
        .dept-actions a{flex:1}
        .btn-business{background:#667eea;color:#fff;border:1px solid #667eea;padding:12px 16px;border-radius:12px;text-decoration:none;font-weight:500;text-align:center;transition:all .2s ease}
        .btn-business:hover{background:#5a67d8;border-color:#5a67d8;transform:translateY(-1px)}
        @media (max-inline-size:640px){.hero h1{font-size:1.7rem}.dept-grid{grid-template-columns:repeat(auto-fill,minmax(200px,1fr))}.dept-card{padding:18px 16px 56px 16px}}
    </style>
</head>
<body>
<%@ taglib prefix="v" tagdir="/WEB-INF/tags" %>
<nav class="main-nav">
    <div class="nav-container">
        <h1 class="nav-title"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "dashboard.businessAdmin") %></h1>
    </div>
</nav>
<div class="dashboard-container">
    <v:volunteerLayout
        titleKey="dashboard.businessAdmin"
        descKey="dashboard.businessAdminDesc"
        count="<%= deps != null ? deps.size() : 0 %>"
        backHref="college-volunteers.jsp"
        searchId="baSearch"
        searchPlaceholder="Filter departments..."
        filterCaption="Type to filter"
        variant="business"
        gridId="baDeptGrid" />
    <%
        Integer currentSize = (Integer) request.getAttribute("size");
        if (currentSize == null) currentSize = 10;
        String searchQuery = (String) request.getAttribute("searchQuery");
        if (searchQuery == null) searchQuery = "";
    %>
    <form method="get" action="business-admin" style="display:flex;gap:12px;align-items:center;flex-wrap:wrap;margin-block-end:12px">
        <label for="pageSize" style="font-size:.7rem;letter-spacing:.5px;text-transform:uppercase;color:#6b7280">Page Size</label>
        <select id="pageSize" name="size" onchange="this.form.submit()" style="padding:8px 12px;border:1px solid #d1d5db;border-radius:8px;font-size:.8rem;">
            <option value="10" <%= currentSize==10?"selected":"" %>>10</option>
            <option value="20" <%= currentSize==20?"selected":"" %>>20</option>
            <option value="30" <%= currentSize==30?"selected":"" %>>30</option>
            <option value="50" <%= currentSize==50?"selected":"" %>>50</option>
        </select>
        <input type="hidden" name="q" value="<%= searchQuery %>" />
        <noscript><button type="submit" class="btn btn-secondary">Apply</button></noscript>
    </form>
    <% Boolean emptyBusiness = (Boolean) request.getAttribute("emptyBusiness"); %>
    <div class="dept-grid" id="baDeptGrid">
        <% if (emptyBusiness != null && emptyBusiness.booleanValue()) { %>
            <div class="empty-state business" style="grid-column:1/-1;">
                <h2>💼 <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "businessAdmin.subtitle") %></h2>
                <p><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "businessAdmin.empty") %></p>
                <a href="college-volunteers.jsp" class="btn-business" style="max-inline-size:260px;">&larr; <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.back") %></a>
            </div>
        <% } else for (CstDepartment d : deps) {
            int cnt = 0;
            List<CstVolunteer> mv = members!=null?members.get(d.getId()):null;
            if(mv!=null) cnt = mv.size();
            String desc = "";
            if (d.getId() == 1001) desc = "Strategic planning and business development initiatives";
            else if (d.getId() == 1002) desc = "Budgeting, financial operations and resource management";
            else if (d.getId() == 1003) desc = "Business operations, logistics and process optimization";
            else desc = "Supporting business administration and management activities";
        %>
            <v:deptCard variant="business" id="<%= d.getId() %>" name="<%= d.getName() %>" desc="<%= desc %>" membersCount="<%= cnt %>" viewHref="cst-team-members.jsp?dept=<%= d.getId() %>" />
        <% } %>
    </div>
    <v:pagination currentPage="<%= request.getAttribute("page") %>" totalPages="<%= request.getAttribute("totalPages") %>" basePath="business-admin" size="<%= request.getAttribute("size") %>" query="<%= request.getAttribute("searchQuery")!=null? (String)request.getAttribute("searchQuery") : "" %>" />
    
</div>
</body>
</html>
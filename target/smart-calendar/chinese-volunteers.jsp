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
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "dashboard.chineseVolunteers") %> - <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "app.title") %></title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .hero{display:flex;flex-wrap:wrap;align-items:flex-end;justify-content:space-between;margin:10px auto 28px auto;gap:18px;background:linear-gradient(135deg,#f093fb 0%,#f5576c 100%);color:#fff;padding:24px;border-radius:16px}
        .hero h1{margin:0;font-size:2.1rem;font-weight:700;letter-spacing:.5px}
        .hero .sub{margin:4px 0 0 0;font-size:.85rem;opacity:.9}
        .dept-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:20px}
        .dept-card{position:relative;background:#fff;border:1px solid #e5e7eb;border-radius:24px;padding:24px 24px 64px 24px;box-shadow:0 2px 8px rgba(0,0,0,.06);display:flex;flex-direction:column;justify-content:space-between;transition:all .3s ease;overflow:hidden}
        .dept-card::before{content:'';position:absolute;inset-block-start:0;inset-inline-start:0;inset-inline-end:0;block-size:4px;background:linear-gradient(90deg,#f093fb,#f5576c,#4facfe,#00f2fe)}
        .dept-card:hover{box-shadow:0 16px 40px rgba(0,0,0,.15);transform:translateY(-6px)}
        .dept-name{font-size:1.15rem;font-weight:600;color:#1f2937;margin:0 0 10px 0;display:flex;align-items:center;gap:8px}
        .dept-name::before{content:'🎌';font-size:1.2em}
        .dept-desc{font-size:.9rem;color:#6b7280;margin:0 0 14px 0;line-height:1.5}
        .dept-stats{display:flex;gap:16px;margin-block-end:16px}
        .stat-item{display:flex;flex-direction:column;align-items:center;text-align:center}
        .stat-number{font-size:1.2rem;font-weight:700;color:#f5576c}
        .stat-label{font-size:.7rem;color:#9ca3af;text-transform:uppercase;letter-spacing:.5px;font-weight:500}
        .dept-actions{position:absolute;inset-inline-start:0;inset-inline-end:0;inset-block-end:0;padding:14px 20px;display:flex;justify-content:space-between;gap:14px;border-block-start:1px solid #f3f4f6;border-radius:0 0 24px 24px;background:linear-gradient(135deg,#fafafa,#f9f9f9)}
        .btn-chinese{background:linear-gradient(135deg,#f093fb,#f5576c);color:#fff;border:1px solid transparent;padding:12px 18px;border-radius:14px;text-decoration:none;font-weight:500;text-align:center;transition:all .2s ease;flex:1}
        .btn-chinese:hover{background:linear-gradient(135deg,#e887f1,#e54c61);transform:translateY(-1px);box-shadow:0 4px 12px rgba(245,87,108,.3)}
        @media (max-inline-size:640px){.hero h1{font-size:1.7rem}.dept-grid{grid-template-columns:repeat(auto-fill,minmax(220px,1fr))}.dept-card{padding:20px 18px 58px 18px}}
    </style>
</head>
<body>
<%@ taglib prefix="v" tagdir="/WEB-INF/tags" %>
<nav class="main-nav">
    <div class="nav-container">
        <h1 class="nav-title"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "dashboard.chineseVolunteers") %></h1>
    </div>
</nav>
<div class="dashboard-container">
    <v:volunteerLayout
        titleKey="dashboard.chineseVolunteers"
        descKey="dashboard.chineseVolunteersDesc"
        count="<%= deps != null ? deps.size() : 0 %>"
        backHref="college-volunteers.jsp"
        searchId="cnSearch"
        searchPlaceholder="Filter departments..."
        filterCaption="Filter"
        variant="chinese"
        gridId="cnDeptGrid" />
    <%
        boolean isAdmin = false;
        if (user != null && user.getRole() != null && user.getRole().equalsIgnoreCase("admin")) {
            isAdmin = true;
        }
    %>
    <% if (isAdmin) { %>
    <div style="margin-block-end:16px;display:flex;flex-wrap:wrap;gap:12px">
        <a href="add-department.jsp?variant=chinese" class="btn btn-primary" style="padding:10px 16px;border-radius:10px;font-size:.8rem;">+ <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.department.addNew") %></a>
    </div>
    <% } %>
    <%
        Integer currentSize = (Integer) request.getAttribute("size");
        if (currentSize == null) currentSize = 10;
        String searchQuery = (String) request.getAttribute("searchQuery");
        if (searchQuery == null) searchQuery = "";
    %>
    <form method="get" action="chinese-volunteers" style="display:flex;gap:12px;align-items:center;flex-wrap:wrap;margin-block-end:12px">
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
    <% Boolean emptyChinese = (Boolean) request.getAttribute("emptyChinese"); %>
    <div class="dept-grid" id="cnDeptGrid">
        <% if (emptyChinese != null && emptyChinese.booleanValue()) { %>
            <div class="empty-state chinese" style="grid-column:1/-1;">
                <h2>🀄 <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "chineseVolunteers.subtitle") %></h2>
                <p><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "chineseVolunteers.empty") %></p>
                <a href="college-volunteers.jsp" class="btn-chinese" style="max-inline-size:260px;">&larr; <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.back") %></a>
            </div>
        <% } else for (CstDepartment d : deps) {
            int cnt = 0;
            List<CstVolunteer> mv = members!=null?members.get(d.getId()):null;
            if(mv!=null) cnt = mv.size();
            String desc = "";
            String focus = "";
            if (d.getId() == 2001) {
                desc = "Dedicated tutors providing Mandarin language instruction and cultural insights";
                focus = "Language Teaching";
            } else if (d.getId() == 2002) {
                desc = "Facilitating cultural exchange programs and cross-cultural understanding";
                focus = "Cultural Bridge";
            } else if (d.getId() == 2003) {
                desc = "Supporting language learners with practical assistance and guidance";
                focus = "Language Support";
            } else {
                desc = "Supporting Chinese language learning and cultural exchange initiatives";
                focus = "Language & Culture";
            }
        %>
            <v:deptCard variant="chinese" id="<%= d.getId() %>" name="<%= d.getName() %>" desc="<%= desc %>" membersCount="<%= cnt %>" focus="<%= focus %>" viewHref="cst-team-members.jsp?dept=<%= d.getId() %>" />
        <% } %>
    </div>
    <v:pagination currentPage="<%= request.getAttribute("page") %>" totalPages="<%= request.getAttribute("totalPages") %>" basePath="chinese-volunteers" size="<%= request.getAttribute("size") %>" query="<%= request.getAttribute("searchQuery")!=null? (String)request.getAttribute("searchQuery") : "" %>" />
    
</div>
</div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>
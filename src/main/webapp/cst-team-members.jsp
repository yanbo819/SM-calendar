<%@ page import="java.util.*, com.smartcalendar.models.CstDepartment, com.smartcalendar.models.CstVolunteer, com.smartcalendar.dao.CstVolunteerDao, com.smartcalendar.dao.CstDepartmentDao" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String deptIdStr = request.getParameter("dept");
    int deptId = -1;
    if (deptIdStr != null) {
        try { deptId = Integer.parseInt(deptIdStr); } catch (Exception e) { deptId = -1; }
    }
    CstDepartment dept = null;
    List<CstVolunteer> members = Collections.emptyList();
    String errorMsg = null;
    try {
        dept = com.smartcalendar.dao.CstDepartmentDao.findById(deptId);
        if (dept != null) {
            members = com.smartcalendar.dao.CstVolunteerDao.listByDepartment(deptId);
        } else {
            errorMsg = "Department not found.";
        }
    } catch (Exception e) {
        errorMsg = "Error loading department or volunteers.";
    }
%>
<!DOCTYPE html>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.team.members.title") %></title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .member-list{display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:18px;margin-top:14px}
        .member-card{position:relative;background:#fff;border:1px solid #e5e7eb;border-radius:14px;padding:15px 14px 16px 14px;box-shadow:0 2px 4px rgba(0,0,0,.05);display:flex;flex-direction:column;align-items:center;transition:box-shadow .25s,transform .25s}
        .member-card:hover{box-shadow:0 8px 24px rgba(0,0,0,.08);transform:translateY(-4px)}
        .member-img{width:72px;height:72px;border-radius:50%;object-fit:cover;border:2px solid #f1f5f9;margin-bottom:10px}
        .member-name{font-size:.95rem;margin:0 0 4px 0;font-weight:600;color:#1f2937;text-align:center}
        .member-extra{font-size:.65rem;color:#475569;line-height:1.15;margin-bottom:3px;text-align:center}
        .contact-row{display:flex;justify-content:center;margin-top:8px}
        .badge{position:absolute;top:8px;right:8px;background:#2563eb;color:#fff;font-size:.6rem;padding:3px 6px;border-radius:6px;letter-spacing:.5px}
        .toolbar{display:flex;justify-content:space-between;align-items:center;gap:18px;margin-top:8px;flex-wrap:wrap}
        .search-box input{padding:8px 14px;font-size:.8rem;border:1px solid #e2e8f0;border-radius:8px;min-width:240px}
        .back-btn{margin:28px auto 0 auto;display:block}
        @media (max-width:640px){.member-list{grid-template-columns:repeat(auto-fill,minmax(160px,1fr))}}
    </style>
</head>
<body>
    <div class="container">
        <!-- Unified header -->
        <div style="display:flex;flex-wrap:wrap;justify-content:space-between;align-items:flex-end;margin-bottom:14px;gap:16px">
            <div style="flex:1;min-width:240px">
                <h1 style="margin:0 0 4px 0;font-size:1.85rem;font-weight:700;letter-spacing:.5px;color:#1f2937;">
                    <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.team.title") %>
                </h1>
                <h2 style="margin:0;font-size:1.15rem;font-weight:600;color:#2563eb;">
                    <%= dept != null ? dept.getName() : com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.department.unknown") %>
                </h2>
                <div style="margin-top:6px;font-size:.70rem;color:#555;">
                    <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.department.label") %>:
                    <strong><%= dept != null ? dept.getName() : com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.department.unknown") %></strong>
                    · <span id="countSpan"><%= members.size() %></span>
                    <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.members.count.label") %>
                </div>
            </div>
            <div style="display:flex;gap:8px;align-items:center;">
                <a href="cst-team" class="btn btn-secondary" style="white-space:nowrap">&larr; <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.back.departments") %></a>
            </div>
        </div>
        <!-- Removed search/filter per user request -->
        <% if (errorMsg != null) { %>
            <div style="color:#ef4444;font-weight:bold;margin-top:12px;margin-bottom:18px;"><%= errorMsg %></div>
        <% } else if (members.isEmpty()) { %>
            <div style="color:#6b7280;margin-top:12px;"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.members.empty") %></div>
        <% } else { %>
        <div class="member-list" id="memberList" style="grid-template-columns:repeat(auto-fill,minmax(320px,1fr));">
            <% for (CstVolunteer v : members) { %>
                <div class="member-card" style="flex-direction:row;align-items:center;gap:18px;padding:18px 20px;" data-name="<%= (v.getPassportName()+" "+v.getChineseName()+" "+v.getStudentId()).toLowerCase() %>">
                    <img class="member-img" style="width:84px;height:84px;margin:0" src="<%= v.getPhotoUrl()!=null && !v.getPhotoUrl().isEmpty() ? v.getPhotoUrl() : "https://via.placeholder.com/84" %>" alt="photo" />
                    <div style="flex:1;min-width:140px;display:flex;flex-direction:column;gap:4px">
                        <h3 class="member-name" style="text-align:left;font-size:1.02rem;margin:0 0 2px 0"><%= v.getPassportName()!=null?v.getPassportName():"Unknown" %></h3>
                        <% if (v.getChineseName()!=null && !v.getChineseName().isEmpty()) { %>
                           <div class="member-extra" style="text-align:left"><%= v.getChineseName() %></div>
                        <% } %>
                        <% if (v.getStudentId()!=null && !v.getStudentId().isEmpty()) { %>
                           <div class="member-extra" style="text-align:left"><strong>ID:</strong> <%= v.getStudentId() %></div>
                        <% } %>
                        <% try { if (v.getEmail()!=null && !v.getEmail().isEmpty()) { %>
                            <div class="member-extra" style="text-align:left"><strong>Email:</strong> <%= v.getEmail() %></div>
                        <% } } catch (Exception ignore) { } %>
                        <% if (v.getPhone()!=null && !v.getPhone().isEmpty()) { %>
                           <div class="member-extra" style="text-align:left"><strong><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.call") %>:</strong> <a href="tel:<%= v.getPhone() %>"><%= v.getPhone() %></a></div>
                        <% } %>
                        <a href="cst-team-member-detail.jsp?id=<%= v.getId() %>&dept=<%= deptId %>" class="btn btn-primary" style="align-self:flex-start;margin-top:4px;font-size:.7rem;padding:6px 10px;">&rarr; <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.view.members") %></a>
                    </div>
                </div>
            <% } %>
        </div>
        <% } %>
        <!-- Bottom back button removed (single back in header retained) -->
    </div>
        <!-- Filtering script removed -->
</body>
</html>

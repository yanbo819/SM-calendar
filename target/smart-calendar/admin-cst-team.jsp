<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.models.CstDepartment" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    if (user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) { response.sendRedirect("dashboard"); return; }
    List<CstDepartment> deps = (List<CstDepartment>) request.getAttribute("departments");
    if (deps == null) deps = java.util.Collections.emptyList();
%>
<!DOCTYPE html>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.admin.title") %></title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .grid{display:grid;grid-template-columns:1fr;gap:16px}
        .card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;padding:16px}
        table{inline-size:100%;border-collapse:collapse}
        th,td{border-block-end:1px solid #e5e7eb;padding:8px;text-align:start}
        .row{display:flex;gap:8px;flex-wrap:wrap}
        .row input,.row select{padding:8px;border:1px solid #e5e7eb;border-radius:8px}
        .cap{text-transform:capitalize}
        .actions{display:flex;gap:8px;align-items:center}
    </style>
</head>
<body>
<%@ include file="/WEB-INF/jspf/flash-messages.jspf" %>
<nav class="main-nav">
    <div class="nav-container">
        <h1 class="nav-title"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.admin.title") %></h1>
    </div>
</nav>
<div class="dashboard-container">
    <div class="grid">
        <div class="card">
            <h3 style="margin:0 0 10px 0"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.departments") %></h3>
            <div style="display:flex;justify-content:flex-end;margin-block-end:12px">
                <a href="admin-add-department" class="btn btn-primary" style="font-size:1.05em;padding:10px 24px;"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.department.add") %></a>
            </div>
            <div class="dept-grid" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:16px;margin-top:12px;">
                <% Map<Integer,Integer> counts = (Map<Integer,Integer>) request.getAttribute("volunteerCounts"); %>
                <% for (CstDepartment d : deps) { int c = counts!=null && counts.get(d.getId())!=null ? counts.get(d.getId()) : 0; %>
                <div class="dept-card" style="background:#fff;border:1px solid #e5e7eb;border-radius:14px;padding:14px;display:flex;flex-direction:column;gap:10px;position:relative;box-shadow:0 1px 3px rgba(0,0,0,.06);">
                    <div style="display:flex;justify-content:space-between;align-items:center;gap:8px;">
                        <input data-dept-id="<%= d.getId() %>" value="<%= d.getName() %>" class="dept-name-input" style="flex:1;padding:6px 10px;border:1px solid #e5e7eb;border-radius:8px;font-size:.95rem;" />
                        <button type="button" class="btn btn-primary btn-sm" onclick="renameDept(<%= d.getId() %>)" style="white-space:nowrap;">Save</button>
                    </div>
                    <div style="font-size:.7rem;color:#555;display:flex;justify-content:space-between;align-items:center;">
                        <span><strong><%= c %></strong> volunteers</span>
                        <div style="display:flex;gap:6px;">
                            <a class="btn btn-outline btn-sm" href="admin-volunteers.jsp?dept=<%= d.getId() %>">Manage</a>
                            <a class="btn btn-outline btn-sm" href="cst-team-members.jsp?dept=<%= d.getId() %>">Public</a>
                        </div>
                    </div>
                    <div style="display:flex;gap:6px;justify-content:space-between;margin-top:4px;">
                        <form method="post" action="admin-cst-team" onsubmit="return confirm('<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.confirmDelete") %>');" style="margin:0;">
                            <input type="hidden" name="action" value="delete-department" />
                            <input type="hidden" name="id" value="<%= d.getId() %>" />
                            <button class="btn btn-danger btn-sm" type="submit">Delete</button>
                        </form>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</div>
<div style="display:grid;place-items:center;margin-block-start:24px;margin-block-end:24px">
    <a href="admin-tools.jsp" class="btn btn-outline" style="min-inline-size:160px"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.back") %></a>
</div>
</body>
<script>
async function renameDept(id){
    const input = document.querySelector('input[data-dept-id="'+id+'"]');
    if(!input) return; const name = input.value.trim();
    if(!name){ alert('Name required'); return; }
    try {
        const fd = new URLSearchParams();
        fd.append('action','update-department');
        fd.append('id',id);
        fd.append('name',name);
        const res = await fetch('admin-cst-team',{method:'POST',headers:{'X-Requested-With':'XMLHttpRequest','Content-Type':'application/x-www-form-urlencoded'},body:fd.toString()});
        if(!res.ok){ alert('Update failed'); return; }
        const data = await res.json();
        if(data && data.ok){ input.style.background='#ecfdf5'; setTimeout(()=>{input.style.background='#fff';},800); }
    } catch(e){ alert('Network error'); }
}
</script>
</html>

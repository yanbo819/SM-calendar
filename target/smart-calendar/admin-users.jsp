<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.smartcalendar.models.User" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null) { response.sendRedirect("login.jsp"); return; }
    boolean isAdmin = me.getRole() != null && me.getRole().equalsIgnoreCase("admin");
    if (!isAdmin) { response.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }
    List<User> users = (List<User>) request.getAttribute("users");
    String loadError = (String) request.getAttribute("loadError");
%>
<!doctype html>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<%@ include file="/WEB-INF/jspf/flash-messages.jspf" %>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.users.title") %></title>
    <link rel="stylesheet" href="css/main.css" />
    <link rel="stylesheet" href="css/ui.css" />
    <style>
        .page { max-inline-size: 1100px; margin-block:20px; margin-inline:auto; padding-block:0; padding-inline:16px; }
        .header-row { display:flex; align-items:center; justify-content:space-between; gap:12px; margin-block:8px 16px; }
        .header-row h2 { margin: 0; }
        .actions { display:flex; gap:8px; flex-wrap:wrap; }
        .card { background:#fff; border:1px solid #e5e7eb; border-radius:10px; padding:16px; }
        .card + .card { margin-block-start:12px; }
        .grid-2 { display:grid; grid-template-columns: repeat(2, minmax(0,1fr)); gap:12px; }
        @media (max-width: 768px){ .grid-2 { grid-template-columns: 1fr; } }
        .inline-form{display:flex;gap:10px;align-items:flex-end;flex-wrap:wrap}
        .inline-form label{font-size:.9rem;color:#374151;display:flex;flex-direction:column;gap:6px}
        .inline-form input, .inline-form select{min-inline-size:220px}
        .toolbar { display:flex; gap:12px; align-items:center; flex-wrap:wrap; }
        .toolbar .search { position:relative; }
        .toolbar .search input { padding-inline-start:34px; }
        .toolbar .search svg { position:absolute; inset-inline-start:10px; inset-block-start:10px; color:#9ca3af; }
        table{inline-size:100%;border-collapse:separate;border-spacing:0;margin-block-start:12px}
        thead th{position:sticky;inset-block-start:0;background:#f9fafb;}
        th,td{border-bottom:1px solid #e5e7eb;padding:10px;font-size:.9rem;text-align:left}
        tbody tr:hover{background:#f9fafb}
        .badge{display:inline-block;padding:2px 8px;border-radius:12px;font-size:.75rem}
        .badge.green{background:#dcfce7;color:#166534}
        .badge.gray{background:#f3f4f6;color:#374151}
        .btn-sm{padding:6px 10px;font-size:.8rem}
        .hint { color:#6b7280; font-size:.85rem; margin-block-start:8px; }
    </style>
</head>
<body>
<%
    boolean noHeader = "1".equals(request.getParameter("noheader"));
%>
<!-- Top navigation and admin toolbar removed for minimal Manage Users page -->
<div class="page">
    <% if (loadError != null) { %>
    <div class="alert alert-error" style="max-inline-size:600px"> <%= loadError %> </div>
    <% } %>
    <div class="header-row" style="justify-content:center;flex-direction:column;text-align:center">
        <h2 style="margin:0"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.users.title") %></h2>
        <div style="margin-block-start:12px"><a href="admin-user-new.jsp" class="btn btn-primary"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.users.add") %></a></div>
    </div>

    <div class="card">
        <div class="toolbar">
            <div class="search">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                <input id="searchBox" class="form-input" placeholder="<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.users.searchPlaceholder") %>" oninput="filterRows()" />
            </div>
        </div>
    <div class="table-responsive">
    <table id="usersTable" class="table">
    <thead><tr><th><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.users.username") %></th><th><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "vol.name") %></th><th><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.users.role") %></th><th><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.users.status") %></th><th class="text-end"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.edit") %></th></tr></thead>
    <tbody>
        <% if (users != null) { for (User u : users) { %>
            <tr class="row-click" onclick="goDetail(<%= u.getUserId() %>)">
                <td><strong><%= u.getUsername() %></strong></td>
                <td><%= u.getFullName() %></td>
                <td><span class="badge <%= ("admin".equalsIgnoreCase(u.getRole())?"gray":"green") %>"><%= u.getRole() != null ? u.getRole() : "user" %></span></td>
                <td>
                    <% if (u.isActive()) { %>
                        <span class="badge green"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.users.active") %></span>
                    <% } else { %>
                        <span class="badge gray"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.users.inactive") %></span>
                    <% } %>
                </td>
                <td class="text-end" style="white-space:nowrap"><a class="btn btn-outline btn-sm" href="admin-user?id=<%= u.getUserId() %>"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.open") %></a></td>
            </tr>
        <% } } %>
        </tbody>
    </table>
    </div>
    <div class="p-2 hint"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.users.tip") %></div>
    </div>
</div>
<script>
function toggleCreate(show){
  document.getElementById('createCard').style.display = show ? 'block' : 'none';
}
function filterRows(){
  const q = (document.getElementById('searchBox').value || '').toLowerCase();
  const rows = document.querySelectorAll('#usersTable tbody tr');
  rows.forEach(r => {
    const text = r.innerText.toLowerCase();
    r.style.display = text.includes(q) ? '' : 'none';
  });
}
function togglePw(id){
    const el = document.getElementById('pwform-' + id);
    if (el) el.style.display = (el.style.display === 'none' || el.style.display === '') ? 'block' : 'none';
}
</script>
</body>
</html>

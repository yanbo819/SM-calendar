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
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin: Users</title>
    <link rel="stylesheet" href="css/main.css" />
    <link rel="stylesheet" href="css/ui.css" />
    <style>
        .page { max-inline-size: 1100px; margin: 20px auto; padding: 0 16px; }
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
        thead th{position:sticky;top:0;background:#f9fafb;}
        th,td{border-bottom:1px solid #e5e7eb;padding:10px;font-size:.9rem;text-align:left}
        tbody tr:hover{background:#f9fafb}
        .badge{display:inline-block;padding:2px 8px;border-radius:12px;font-size:.75rem}
        .badge.green{background:#dcfce7;color:#166534}
        .badge.gray{background:#f3f4f6;color:#374151}
        .btn-sm{padding:6px 10px;font-size:.8rem}
        .hint { color:#6b7280; font-size:.85rem; margin-top:8px; }
    </style>
</head>
<body>
<nav class="main-nav">
    <div class="nav-container">
        <h1 class="nav-title"><a href="dashboard.jsp">Smart Calendar</a></h1>
        <div class="nav-actions"><!-- admin toolbar below --></div>
    </div>
</nav>
<% if (isAdmin) { %>
<jsp:include page="/WEB-INF/jsp/includes/admin-toolbar.jspf" />
<% } %>
<div class="page">
    <% if (loadError != null) { %>
    <div class="alert alert-error" style="max-inline-size:600px"> <%= loadError %> </div>
    <% } %>
    <div class="header-row">
        <h2>Manage Users</h2>
        <div class="actions">
            <a href="admin-user-new.jsp" class="btn btn-primary">Add New User</a>
        </div>
    </div>

    <div class="card">
        <div class="toolbar">
            <div class="search">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                <input id="searchBox" class="form-input" placeholder="Search by name, email, or username..." oninput="filterRows()" />
            </div>
        </div>
    <div class="table-responsive">
    <table id="usersTable" class="table">
    <thead><tr><th>Username</th><th>Name</th><th>Role</th><th>Status</th><th class="text-end">View</th></tr></thead>
    <tbody>
        <% if (users != null) { for (User u : users) { %>
            <tr class="row-click" onclick="goDetail(<%= u.getUserId() %>)">
                <td><strong><%= u.getUsername() %></strong></td>
                <td><%= u.getFullName() %></td>
                <td><span class="badge <%= ("admin".equalsIgnoreCase(u.getRole())?"gray":"green") %>"><%= u.getRole() != null ? u.getRole() : "user" %></span></td>
                <td>
                    <% if (u.isActive()) { %>
                        <span class="badge green">Active</span>
                    <% } else { %>
                        <span class="badge gray">Inactive</span>
                    <% } %>
                </td>
                <td class="text-end" style="white-space:nowrap"><a class="btn btn-outline btn-sm" href="admin-user?id=<%= u.getUserId() %>">View</a></td>
            </tr>
        <% } } %>
        </tbody>
    </table>
    </div>
    <div class="p-2 hint">Tip: Click a user row to view and manage full details.</div>
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

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.smartcalendar.models.Location" %>
<%
    com.smartcalendar.models.User user = (com.smartcalendar.models.User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    boolean isAdmin = user.getRole() != null && user.getRole().equalsIgnoreCase("admin");
    if (!isAdmin) { response.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }
    List<Location> locations = (List<Location>) request.getAttribute("locations");
    // Determine current category and active button classes early (needed in header link)
    String currentCategory = (String) request.getAttribute("currentCategory");
    if (currentCategory == null) currentCategory = request.getParameter("category");
    if (currentCategory == null) currentCategory = "";
    String activeAll = currentCategory.isEmpty() ? "btn-primary" : "btn-outline";
    String activeGate = "gate".equals(currentCategory) ? "btn-primary" : "btn-outline";
    String activeHospital = "hospital".equals(currentCategory) ? "btn-primary" : "btn-outline";
    String activeImmigration = "immigration".equals(currentCategory) ? "btn-primary" : "btn-outline";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin: Manage Locations</title>
    <link rel="stylesheet" href="css/main.css" />
    <link rel="stylesheet" href="css/ui.css" />
    <style>
        .page { max-inline-size: 1100px; margin: 16px auto; padding: 0 16px; }
        .badge-cat{display:inline-block;padding:2px 6px;border-radius:6px;font-size:.65rem;background:#eef2ff;color:#3730a3;border:1px solid #c7d2fe}
        /* Unified toolbar for search, filters, and actions */
        .page-heading { margin-block: 8px 12px; }
        .toolbar-card { margin-block: 4px 18px; }
        .page-toolbar { display:flex; flex-wrap:wrap; gap:14px; align-items:center; }
        .page-toolbar section { display:flex; flex-wrap:wrap; gap:8px; align-items:center; }
        .page-toolbar .filters .btn { min-inline-size: 160px; }
        .page-toolbar .actions .btn { min-inline-size: 150px; }
        .page-toolbar input.form-input { min-inline-size: 260px; }
        @media (max-width: 760px){
            .page-toolbar { flex-direction:column; align-items:stretch; }
            .page-toolbar section { justify-content:stretch; }
            .page-toolbar input.form-input { inline-size:100%; }
        }
    </style>
</head>
<body>
<nav class="main-nav">
    <div class="nav-container">
        <h1 class="nav-title"><a href="dashboard.jsp">Smart Calendar</a></h1>
        <div class="nav-actions"></div>
    </div>
</nav>
<% if (isAdmin) { %>
<jsp:include page="/WEB-INF/jsp/includes/admin-toolbar.jspf" />
<script>
    (function(){
        var link = document.querySelector('.admin-toolbar a[href="admin-locations"]');
        if (link) link.classList.add('active');
    })();
</script>
<% } %>
<div class="form-container page">
    <div class="page-heading">
        <h2 style="margin:0">Manage Locations</h2>
        <div class="page-sub" style="color:#6b7280;font-size:.95rem">Create, edit, or remove campus and city locations.</div>
    </div>

    <div class="card toolbar-card">
        <div class="card-body">
            <div class="page-toolbar" role="toolbar" aria-label="Location management toolbar">
                <section class="search" aria-label="Search locations">
                    <input id="searchBox" class="form-input" placeholder="Search name, category, or description" />
                </section>
                <section class="filters" aria-label="Filter locations by category">
                    <a class="btn <%= activeAll %>" href="admin-locations">All</a>
                    <a class="btn <%= activeGate %>" href="admin-locations?category=gate">Colleges / Gates</a>
                    <a class="btn <%= activeHospital %>" href="admin-locations?category=hospital">Hospitals</a>
                    <a class="btn <%= activeImmigration %>" href="admin-locations?category=immigration">Police &amp; Immigration</a>
                </section>
                <section class="actions" aria-label="Location actions">
                    <a class="btn btn-primary" href="admin-location-new.jsp<%= currentCategory.isEmpty()? "" : ("?category="+currentCategory) %>">+ Add New Location</a>
                    <a class="btn btn-outline" href="dashboard.jsp">Dashboard</a>
                </section>
            </div>
        </div>
    </div>

    

    <div class="card" style="margin-block-start:12px;">
        <div class="card-body">
            <div id="locationsList" class="acc-list">
            <% if (locations != null) {
                   for (Location l : locations) { %>
                <details class="loc-acc">
                    <summary><span class="acc-title"><a href="admin-location?id=<%= l.getLocationId() %>" style="text-decoration:none;color:inherit"><%= l.getName() %></a></span></summary>
                    <div class="acc-body" style="font-size:.8rem;color:#6b7280">Click name to open detailed edit page.</div>
                </details>
            <% } } %>
            </div>
        </div>
    </div>

    <script>
    // Client-side row filtering by name/category/description
    (function(){
      const box = document.getElementById('searchBox');
      if (!box) return;
      const rows = () => Array.from(document.querySelectorAll('#locationsBody tr'));
      function norm(s){ return (s||'').toLowerCase(); }
      box.addEventListener('input', function(){
        const q = norm(box.value);
        rows().forEach(tr => {
          const t = norm(tr.textContent);
          tr.style.display = q && !t.includes(q) ? 'none' : '';
        });
      });
    })();
    </script>
</div>
</body>
</html>

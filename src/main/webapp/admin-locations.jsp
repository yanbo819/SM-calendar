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
        .header-row { display:flex; align-items:center; justify-content:space-between; gap:12px; margin-block:8px 16px; }
        .header-row h2 { margin: 0; }
        .filters { display:flex; gap:8px; flex-wrap:wrap; align-items:center; }
        .create-grid { display:grid; grid-template-columns: repeat(4, minmax(0,1fr)); gap: 10px; }
        @media (max-width: 900px){ .create-grid { grid-template-columns: repeat(2, minmax(0,1fr)); } }
        @media (max-width: 520px){ .create-grid { grid-template-columns: 1fr; } }
        .badge-cat{display:inline-block;padding:2px 6px;border-radius:6px;font-size:.65rem;background:#eef2ff;color:#3730a3;border:1px solid #c7d2fe}
        .inline-edit { display:flex; flex-wrap:wrap; gap:6px; align-items:center; }
        .inline-edit .form-control { min-inline-size: 140px; }
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
    <div class="header-row">
        <div>
            <h2>Manage Locations</h2>
            <div class="page-sub" style="color:#6b7280;font-size:.95rem">Create, edit, or remove campus and city locations.</div>
        </div>
        <div style="display:flex; gap:10px; align-items:center; flex-wrap:wrap">
            <div style="min-inline-size:240px">
                <input id="searchBox" class="form-input" placeholder="Search by name, category, or description..." />
            </div>
            <a class="btn btn-primary" href="admin-location-new.jsp<%= currentCategory.isEmpty()? "" : ("?category="+currentCategory) %>">+ Add New Location</a>
        </div>
    </div>

    <div class="filters">
        <a class="btn <%= activeAll %>" href="admin-locations">All</a>
        <a class="btn <%= activeGate %>" href="admin-locations?category=gate">Colleges / Gates</a>
        <a class="btn <%= activeHospital %>" href="admin-locations?category=hospital">Hospitals</a>
        <a class="btn <%= activeImmigration %>" href="admin-locations?category=immigration">Police &amp; Immigration</a>
    </div>

    

    <div class="card" style="margin-block-start:12px;">
        <div class="card-body">
            <div id="locationsList" class="acc-list">
            <% if (locations != null) {
                   for (Location l : locations) { %>
                <details class="loc-acc">
                    <summary><span class="acc-title"><%= l.getName() %></span></summary>
                    <div class="acc-body">
                        <form method="post" action="admin-locations" class="inline-edit" style="margin-bottom:8px">
                            <input type="hidden" name="action" value="update" />
                            <input type="hidden" name="locationId" value="<%= l.getLocationId() %>" />
                            <input type="hidden" name="returnCategory" value="<%= currentCategory %>" />
                            <div style="display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:8px;width:100%">
                                <label style="display:flex;flex-direction:column;gap:6px">Category
                                    <select class="form-control" name="category">
                                        <option value="gate" <%= "gate".equals(l.getCategory())?"selected":"" %>>Gate</option>
                                        <option value="hospital" <%= "hospital".equals(l.getCategory())?"selected":"" %>>Hospital</option>
                                        <option value="immigration" <%= "immigration".equals(l.getCategory())?"selected":"" %>>Immigration</option>
                                        <option value="other" <%= "other".equals(l.getCategory())?"selected":"" %>>Other</option>
                                    </select>
                                </label>
                                <label style="display:flex;flex-direction:column;gap:6px">Map URL
                                    <input class="form-control" type="text" name="mapUrl" value="<%= l.getMapUrl() %>" placeholder="https://" />
                                </label>
                                <label style="grid-column:1/-1;display:flex;flex-direction:column;gap:6px">Description
                                    <input class="form-control" type="text" name="description" value="<%= l.getDescription() == null ? "" : l.getDescription() %>" placeholder="Short description" />
                                </label>
                            </div>
                            <div class="form-actions" style="justify-content:space-between;margin-top:8px">
                                <label style="display:inline-flex;align-items:center;gap:8px"><input type="checkbox" name="active" <%= l.isActive()?"checked":"" %> /> Active</label>
                                <div style="display:flex;gap:8px">
                                    <button type="submit" class="btn btn-primary btn-sm">Save</button>
                                    <a class="btn btn-outline btn-sm" href="<%= l.getMapUrl() %>" target="_blank" rel="noopener">Open Map</a>
                                </div>
                            </div>
                        </form>
                        <form method="post" action="admin-locations" onsubmit="return confirm('Delete this location?');">
                            <input type="hidden" name="action" value="delete" />
                            <input type="hidden" name="locationId" value="<%= l.getLocationId() %>" />
                            <input type="hidden" name="returnCategory" value="<%= currentCategory %>" />
                            <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                        </form>
                    </div>
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

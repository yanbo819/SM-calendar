<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.smartcalendar.models.Location" %>
<%
    com.smartcalendar.models.User user = (com.smartcalendar.models.User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    boolean isAdmin = user.getRole() != null && user.getRole().equalsIgnoreCase("admin");
    if (!isAdmin) { response.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }
    List<Location> locations = (List<Location>) request.getAttribute("locations");
    String lang = (String) session.getAttribute("lang");
    if (lang == null && user.getPreferredLanguage() != null) lang = user.getPreferredLanguage();
    if (lang == null) lang = "en";
    String textDir = com.smartcalendar.utils.LanguageUtil.getTextDirection(lang);
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
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.locations") %></title>
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
<%
    boolean noHeader = "1".equals(request.getParameter("noheader"));
%>
<!-- Navigation removed for streamlined Admin Locations view -->
<!-- Admin toolbar removed -->
<div class="form-container page">
    <div class="header-row">
        <div>
            <h2 style="margin:0"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.locations") %></h2>
            <div class="page-sub" style="color:#6b7280;font-size:.95rem"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.locations") %></div>
        </div>
        <div style="display:flex; gap:10px; align-items:center; flex-wrap:wrap">
            <div style="min-inline-size:240px">
                <input id="searchBox" class="form-input" placeholder="Search..." />
            </div>
            <a class="btn btn-primary" href="admin-location-new.jsp<%= currentCategory.isEmpty()? "" : ("?category="+currentCategory) %>">+ <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.locations") %></a>
        </div>
    </div>

    <div class="filters" style="margin-block:4px 12px">
        <a class="btn <%= activeAll %>" href="admin-locations">All</a>
        <a class="btn <%= activeGate %>" href="admin-locations?category=gate">Gate</a>
        <a class="btn <%= activeHospital %>" href="admin-locations?category=hospital">Hospital</a>
        <a class="btn <%= activeImmigration %>" href="admin-locations?category=immigration">Immigration</a>
    </div>

    

    <div class="card" style="margin-block-start:12px;">
        <div class="card-body" style="padding:0">
            <table style="width:100%;border-collapse:collapse">
                <thead>
                    <tr style="background:#f3f4f6;text-align:left;font-size:.8rem;letter-spacing:.5px;text-transform:uppercase">
                        <th style="padding:10px 14px">Name</th>
                        <th style="padding:10px 14px">Category</th>
                        <th style="padding:10px 14px">Active</th>
                        <th style="padding:10px 14px">Actions</th>
                    </tr>
                </thead>
                <tbody id="locationsBody">
                <% if (locations != null) { for (Location l : locations) { %>
                    <tr>
                        <td style="padding:10px 14px;font-weight:500"><a href="admin-location?id=<%= l.getLocationId() %>" class="btn-link"><%= l.getName() %></a></td>
                        <td style="padding:10px 14px"><span style="display:inline-block;padding:4px 8px;border-radius:6px;background:#eef2ff;color:#3730a3;font-size:.7rem;font-weight:600"><%= l.getCategory() %></span></td>
                        <td style="padding:10px 14px"><%= l.isActive()?"✅":"❌" %></td>
                        <td style="padding:10px 14px;display:flex;gap:8px;flex-wrap:wrap">
                            <a href="<%= l.getMapUrl() %>" target="_blank" rel="noopener" class="btn btn-outline btn-sm">Map</a>
                            <form method="post" action="admin-locations" onsubmit="return confirm('Delete this location?');" style="display:inline">
                                <input type="hidden" name="action" value="delete" />
                                <input type="hidden" name="locationId" value="<%= l.getLocationId() %>" />
                                <input type="hidden" name="returnCategory" value="<%= currentCategory %>" />
                                <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                            </form>
                        </td>
                    </tr>
                <% } } %>
                </tbody>
            </table>
        </div>
    </div>

    <div style="margin-top:20px;display:flex;justify-content:center">
        <a href="admin-tools.jsp" class="btn btn-outline" style="min-inline-size:160px">Go Back</a>
    </div>
    <script>
        // Client-side row filtering by name/category
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

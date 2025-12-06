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
    <link rel="stylesheet" href="css/components.css" />
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
            <h2><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.locations") %></h2>
            <div class="subtext"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.locations") %></div>
        </div>
        <div class="flex-wrap-gap">
            <div class="min-240">
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
            <table class="table-full">
                <thead>
                    <tr class="table-head-row">
                        <th class="cell-pad">Name</th>
                        <th class="cell-pad">Category</th>
                        <th class="cell-pad">Active</th>
                        <th class="cell-pad">Actions</th>
                    </tr>
                </thead>
                <tbody id="locationsBody">
                <% if (locations != null) { for (Location l : locations) { %>
                    <tr>
                        <td class="cell-pad" style="font-weight:500"><a href="admin-location?id=<%= l.getLocationId() %>" class="btn-link"><%= l.getName() %></a></td>
                        <td class="cell-pad"><span class="badge-cat"><%= l.getCategory() %></span></td>
                        <td class="cell-pad"><%= l.isActive()?"✅":"❌" %></td>
                        <td class="cell-pad flex-row-wrap">
                            <a href="<%= l.getMapUrl() %>" target="_blank" rel="noopener" class="btn btn-outline btn-sm">Map</a>
                            <form method="post" action="admin-locations" onsubmit="return confirm('<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "confirm.delete.location") %>');" style="display:inline">
                                <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
<%@ include file="/WEB-INF/jspf/csrf-meta.jspf" %>
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

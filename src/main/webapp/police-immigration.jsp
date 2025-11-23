<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.models.Location" %>
<%@ page import="com.smartcalendar.dao.LocationDao" %>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<%
    // Public info page (allow anonymous)
    User user = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.policeImmigration") %></title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/locations.css">
</head>
<body>
    <nav class="main-nav">
        <div class="nav-container">
            <h1 class="nav-title"><a href="dashboard"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "app.title") %></a></h1>
            <div class="nav-actions">
                <% if (user != null) { %>
                <span class="user-welcome"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "dashboard.welcome") %> <%= user.getFullName() %>!</span>
                <% } %>
            </div>
        </div>
    </nav>

    <div class="form-container">
        <div class="form-header" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
            <div>
                <h2 class="page-title"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.policeImmigration") %></h2>
                <div class="page-sub"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.policeImmigration.desc") %></div>
            </div>
        </div>
        <div class="card">
            <div style="display:flex;justify-content:space-between;align-items:center;gap:8px;margin-bottom:8px">
                <strong><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.policeImmigration") %></strong>
                <button id="toggleSearchImm" type="button" class="btn btn-outline btn-sm"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.search") %></button>
            </div>
            <div class="search-row" id="searchRowImm" style="display:none">
                <input id="searchImm" class="search-input" type="search" placeholder="<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "search.policeImmigration.placeholder") %>" />
            </div>
            <%
                java.util.List<Location> immigration = new java.util.ArrayList<>();
                try { immigration = LocationDao.listByCategory("immigration"); } catch (Exception ignore) {}
                int iCount = immigration.size();
            %>
            <h3 class="section-heading"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.policeImmigration") %> <span class="badge"><%= iCount %></span></h3>
            <% if (iCount == 0) { %>
                <div class="empty"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "policeImmigration.empty") %></div>
            <% } %>
            <div id="accImm" class="acc-list">
                <% for (Location l : immigration) { %>
                <details class="loc-acc">
                    <summary><span class="summary-icon">🛂</span> <span class="acc-title"><%= l.getName() %></span>
                        <span class="summary-actions">
                            <% if (l.getMapUrl() != null && !l.getMapUrl().isEmpty()) { %>
                            <a class="btn btn-primary btn-sm" href="<%= l.getMapUrl() %>" target="_blank" rel="noopener"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.goLocation") %></a>
                            <% } %>
                        </span>
                    </summary>
                    <div class="acc-body">
                        <p class="acc-desc"><%= l.getDescription() %></p>
                    </div>
                </details>
                <% } %>
            </div>
        </div>
        <div style="display:grid;place-items:center;margin-top:24px">
            <a href="important-locations.jsp" class="btn btn-outline" style="min-inline-size:160px"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.back") %></a>
        </div>
    </div>
    <script>
        (function(){
            const input = document.getElementById('searchImm');
            const list = document.getElementById('accImm');
            const row = document.getElementById('searchRowImm');
            const btn = document.getElementById('toggleSearchImm');
            if (!input || !list) return;
            if (btn && row) {
                btn.addEventListener('click', () => {
                    const showing = row.style.display !== 'none';
                    row.style.display = showing ? 'none' : '';
                    if (!showing) setTimeout(() => input.focus(), 0);
                });
            }
            input.addEventListener('input', () => {
                const q = input.value.toLowerCase();
                for (const det of list.querySelectorAll('details.loc-acc')){
                    const title = det.querySelector('.acc-title')?.textContent?.toLowerCase() || '';
                    const desc = det.querySelector('.acc-desc')?.textContent?.toLowerCase() || '';
                    det.style.display = (title.includes(q) || desc.includes(q)) ? '' : 'none';
                }
            });
        })();
    </script>
</body>
</html>

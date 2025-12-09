<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.models.Location" %>
<%@ page import="com.smartcalendar.dao.LocationDao" %>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<%
    // Allow anonymous viewing
    User user = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%@ include file="/WEB-INF/jspf/app-brand.jspf" %>
    <title><%= (String)request.getAttribute("appName") %> - <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.schoolBuildings") %></title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/locations.css">
</head>
<body>
    <%@ include file="/WEB-INF/jspf/topnav.jspf" %>

    <div class="form-container">
        <div class="form-header" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
            <div>
                <h2 class="page-title"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.schoolBuildings") %></h2>
                <div class="page-sub"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.schoolBuildings.desc") %></div>
            </div>
        </div>
        <div class="card">
            <div style="display:flex;justify-content:space-between;align-items:center;gap:8px;margin-bottom:8px">
                <strong><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.schoolBuildings") %></strong>
                <button id="toggleSearchGate" type="button" class="btn btn-outline btn-sm"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.search") %></button>
            </div>
            <div class="search-row" id="searchRowGate" style="display:none">
                <input id="searchGate" class="search-input" type="search" placeholder="<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "search.schoolBuildings.placeholder") %>" />
            </div>
            <%
                java.util.List<Location> gates = new java.util.ArrayList<>();
                try { gates = LocationDao.listByCategory("gate"); } catch (Exception ignore) {}
                int gateCount = gates.size();
            %>
            <h3 class="section-heading"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.schoolBuildings") %> <span class="badge"><%= gateCount %></span></h3>
            <% if (gateCount == 0) { %>
                <div class="empty"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "schoolBuildings.empty") %></div>
            <% } %>
            <div id="accGate" class="acc-list">
                <% for (Location g : gates) { %>
                <details class="loc-acc">
                    <summary><span class="summary-icon">🚪</span> <span class="acc-title"><%= g.getName() %></span>
                        <span class="summary-actions">
                            <% if (g.getMapUrl() != null && !g.getMapUrl().isEmpty()) { %>
                            <a class="btn btn-primary btn-sm" href="<%= g.getMapUrl() %>" target="_blank" rel="noopener"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.goLocation") %></a>
                            <% } %>
                        </span>
                    </summary>
                    <div class="acc-body">
                        <p class="acc-desc"><%= g.getDescription() %></p>
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
        // Simple filter for gates/buildings
        (function(){
            const input = document.getElementById('searchGate');
            const list = document.getElementById('accGate');
            const row = document.getElementById('searchRowGate');
            const btn = document.getElementById('toggleSearchGate');
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
        <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>

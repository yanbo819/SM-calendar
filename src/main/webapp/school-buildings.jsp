<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.models.Location" %>
<%@ page import="com.smartcalendar.dao.LocationDao" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>School location, Buildings &amp; gates</title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/locations.css">
</head>
<body>
    <nav class="main-nav">
        <div class="nav-container">
            <h1 class="nav-title"><a href="dashboard.jsp">Smart Calendar</a></h1>
            <div class="nav-actions">
                <span class="user-welcome">Welcome, <%= user.getFullName() %>!</span>
                <a href="logout" class="btn btn-outline">Logout</a>
            </div>
        </div>
    </nav>

    <div class="form-container">
        <div class="form-header" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
            <div>
                <h2 class="page-title">School location, Buildings &amp; gates</h2>
                <div class="page-sub">Locations of buildings, classrooms, offices, facilities, and campus gates.</div>
            </div>
            <div style="display:flex;gap:8px;flex-wrap:wrap;">
                <a href="important-locations.jsp" class="btn btn-outline">← Important Locations</a>
                <a href="dashboard.jsp" class="btn btn-outline">Dashboard</a>
            </div>
        </div>
        <div class="card">
            <div class="search-row">
                <input id="searchGate" class="search-input" type="search" placeholder="Search school buildings & gates..." />
            </div>
            <%
                java.util.List<Location> gates = new java.util.ArrayList<>();
                try { gates = LocationDao.listByCategory("gate"); } catch (Exception ignore) {}
                int gateCount = gates.size();
            %>
            <h3 class="section-heading">Gates <span class="badge"><%= gateCount %></span></h3>
            <% if (gateCount == 0) { %>
                <div class="empty">No gates or buildings yet.</div>
            <% } %>
            <div id="accGate" class="acc-list">
                <% for (Location g : gates) { %>
                <details class="loc-acc">
                    <summary><span class="summary-icon">🚪</span> <span class="acc-title"><%= g.getName() %></span></summary>
                    <div class="acc-body">
                        <p class="acc-desc"><%= g.getDescription() %></p>
                        <div class="gate-actions" style="display:flex;gap:8px;flex-wrap:wrap">
                            <% if (g.getMapUrl() != null && !g.getMapUrl().isEmpty()) { %>
                            <a class="btn btn-primary" href="<%= g.getMapUrl() %>" target="_blank" rel="noopener">Go to location →</a>
                            <% } %>
                        </div>
                    </div>
                </details>
                <% } %>
            </div>
        </div>
    </div>
    <script>
        // Simple filter for gates/buildings
        (function(){
            const input = document.getElementById('searchGate');
            const list = document.getElementById('accGate');
            if (!input || !list) return;
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

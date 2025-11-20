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
    <title>Hospitals Information</title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/locations.css">
</head>
<body>
    <nav class="main-nav">
        <div class="nav-container">
            <h1 class="nav-title"><a href="dashboard.jsp">Smart Calendar</a></h1>
            <div class="nav-actions">
                <span class="user-welcome">Welcome, <%= user.getFullName() %>!</span>
            </div>
        </div>
    </nav>

    <div class="form-container">
        <div class="form-header" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
            <div>
                <h2 class="page-title">Hospitals Information</h2>
                <div class="page-sub">Nearby hospitals, clinics, and emergency contacts.</div>
            </div>
        </div>
        <div class="card">
            <div style="display:flex;justify-content:space-between;align-items:center;gap:8px;margin-bottom:8px">
                <strong>Hospitals</strong>
                <button id="toggleSearchHosp" type="button" class="btn btn-outline btn-sm">Search</button>
            </div>
            <div class="search-row" id="searchRowHosp" style="display:none">
                <input id="searchHosp" class="search-input" type="search" placeholder="Search hospitals..." />
            </div>
            <%
                java.util.List<Location> hospitals = new java.util.ArrayList<>();
                try { hospitals = LocationDao.listByCategory("hospital"); } catch (Exception ignore) {}
                int hCount = hospitals.size();
            %>
            <h3 class="section-heading">Hospitals <span class="badge"><%= hCount %></span></h3>
            <% if (hCount == 0) { %>
                <div class="empty">No hospitals added yet.</div>
            <% } %>
            <div id="accHosp" class="acc-list">
                <% for (Location h : hospitals) { %>
                <details class="loc-acc">
                    <summary><span class="summary-icon">🏥</span> <span class="acc-title"><%= h.getName() %></span>
                        <span class="summary-actions">
                            <% if (h.getMapUrl() != null && !h.getMapUrl().isEmpty()) { %>
                            <a class="btn btn-primary btn-sm" href="<%= h.getMapUrl() %>" target="_blank" rel="noopener">Go</a>
                            <% } %>
                        </span>
                    </summary>
                    <div class="acc-body">
                        <p class="acc-desc"><%= h.getDescription() %></p>
                    </div>
                </details>
                <% } %>
            </div>
        </div>
        <div style="display:grid;place-items:center;margin-top:24px">
            <a href="important-locations.jsp" class="btn btn-outline" style="min-inline-size:160px">Go Back</a>
        </div>
    </div>
    <script>
        // Simple client-side filter
        (function(){
            const input = document.getElementById('searchHosp');
            const list = document.getElementById('accHosp');
            const row = document.getElementById('searchRowHosp');
            const btn = document.getElementById('toggleSearchHosp');
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

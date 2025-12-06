<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%
    User user = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "important.locations.title") %></title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/locations.css">
    <style>
        .page-title{margin:0;font-size:1.5rem;font-weight:600}
    .page-sub{color:#6b7280;margin-block-start:4px}
        .card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;box-shadow:0 1px 2px rgba(0,0,0,.04);padding:24px}
        .locations-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:16px}
        .location-card{display:flex;align-items:center;gap:14px;border:1px solid #e5e7eb;border-radius:12px;padding:16px;background:#fff;text-decoration:none;color:inherit;transition:transform .15s ease, box-shadow .15s ease, border-color .15s ease}
        .location-card:hover{transform:translateY(-2px);box-shadow:0 6px 18px rgba(0,0,0,.08);border-color:#d1d5db}
        .location-icon{font-size:1.5rem;line-height:1}
        .location-text h3{margin:0 0 4px 0;font-size:1.05rem;font-weight:600}
        .location-text p{margin:0;color:#6b7280;font-size:.9rem}
    </style>
</head>
<body>
    <nav class="main-nav">
        <div class="nav-container">
            <h1 class="nav-title"><a href="dashboard"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "app.title") %></a></h1>
            <div class="nav-actions">
                <span class="user-welcome"><%= user != null ? com.smartcalendar.utils.LanguageUtil.getText(lang, "dashboard.welcome")+", "+ user.getFullName()+"!" : com.smartcalendar.utils.LanguageUtil.getText(lang, "dashboard.welcome") %></span>
            </div>
        </div>
    </nav>

    <div class="form-container">
        <div class="form-header" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
            <div>
                <h2 class="page-title"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "important.locations.title") %></h2>
                <div class="page-sub"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "important.locations.subtitle") %></div>
            </div>
        </div>

        <div class="card">
            <%
                // Keep the page robust: don't query DB here; counts shown as 0 if needed
                int countHosp = 0, countImm = 0, countGate = 0;
            %>
            <div class="locations-grid">
                <a class="location-card" href="colleges-info.jsp">
                    <span class="location-icon">🏫</span>
                    <div class="location-text">
                        <h3><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.colleges") %></h3>
                        <p><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.colleges.desc") %></p>
                    </div>
                </a>

                <a class="location-card" href="hospitals-info.jsp">
                    <span class="location-icon">🏥</span>
                    <div class="location-text">
                        <h3><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.hospitals") %> <span class="badge" style="margin-inline-start:6px"><%= countHosp %></span></h3>
                        <p><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.hospitals.desc") %></p>
                    </div>
                </a>

                <a class="location-card" href="police-immigration.jsp">
                    <span class="location-icon">🛂</span>
                    <div class="location-text">
                        <h3><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.policeImmigration") %> <span class="badge" style="margin-inline-start:6px"><%= countImm %></span></h3>
                        <p><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.policeImmigration.desc") %></p>
                    </div>
                </a>

                <a class="location-card" href="school-buildings.jsp">
                    <span class="location-icon">🏢</span>
                    <div class="location-text">
                        <h3><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.schoolBuildings") %> <span class="badge" style="margin-inline-start:6px"><%= countGate %></span></h3>
                        <p><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.schoolBuildings.desc") %></p>
                    </div>
                </a>

                <a class="location-card" href="restaurants-other.jsp">
                    <span class="location-icon">🍽️</span>
                    <div class="location-text">
                        <h3><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.restaurants") %></h3>
                        <p><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "locations.restaurants.desc") %></p>
                    </div>
                </a>
            </div>
        </div>
        <div style="display:grid;place-items:center;margin-top:24px">
            <a href="dashboard" class="btn btn-outline" style="min-inline-size:160px"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.back") %></a>
        </div>
    </div>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>

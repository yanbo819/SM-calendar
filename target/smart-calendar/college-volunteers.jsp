<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.utils.LanguageUtil" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%@ include file="/WEB-INF/jspf/app-brand.jspf" %>
    <title><%= (String)request.getAttribute("appName") %> - <%= LanguageUtil.getText(lang, "dashboard.collegeVolunteers") %></title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/dashboard.css">
</head>
<body>
    <%@ include file="/WEB-INF/jspf/topnav.jspf" %>

    <div class="dashboard-container">
        <div class="page-header" style="text-align:center;margin-block-end:24px;">
            <h2 style="color:#1f2937;font-size:2rem;font-weight:700;margin:0 0 6px 0;">
                <%= LanguageUtil.getText(lang, "dashboard.collegeVolunteers") %>
            </h2>
            <p style="color:#6b7280;font-size:1.05rem;margin:0;">
                <%= LanguageUtil.getText(lang, "dashboard.collegeVolunteersDesc") %>
            </p>
        </div>

        <div class="tiles-grid" style="grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:20px;">
            <!-- Volunteer Tile 1: CST Shining Team -->
            <a class="tile tile-face" href="cst-team">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">🤝</span>
                        <h3><%= LanguageUtil.getText(lang, "dashboard.cstTeam") %></h3>
                    </div>
                    <p class="tile-desc"><%= LanguageUtil.getText(lang, "dashboard.cstTeamDesc") %></p>
                </div>
                <span class="tile-cta"><%= LanguageUtil.getText(lang, "dashboard.openCta") %> →</span>
            </a>

            <!-- Volunteer Tile 2: Business Administration -->
            <a class="tile tile-face" href="business-admin">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">💼</span>
                        <h3><%= LanguageUtil.getText(lang, "dashboard.businessAdmin") %></h3>
                    </div>
                    <p class="tile-desc" style="font-size:.8rem;line-height:1.3;color:#4b5563;">
                        <strong><%= LanguageUtil.getText(lang, "dashboard.businessAdminDesc") %></strong><br>
                        <span style="color:#6b7280;">
                            <%= LanguageUtil.getText(lang, "businessAdmin.subtitle") %>
                        </span>
                    </p>
                </div>
                <span class="tile-cta"><%= LanguageUtil.getText(lang, "dashboard.openCta") %> →</span>
            </a>

            <!-- Volunteer Tile 3: Chinese Language Volunteers -->
            <a class="tile tile-face" href="chinese-volunteers">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">🀄</span>
                        <h3><%= LanguageUtil.getText(lang, "dashboard.chineseVolunteers") %></h3>
                    </div>
                    <p class="tile-desc" style="font-size:.8rem;line-height:1.3;color:#4b5563;">
                        <strong><%= LanguageUtil.getText(lang, "dashboard.chineseVolunteersDesc") %></strong><br>
                        <span style="color:#6b7280;">
                            <%= LanguageUtil.getText(lang, "chineseVolunteers.subtitle") %>
                        </span>
                    </p>
                </div>
                <span class="tile-cta"><%= LanguageUtil.getText(lang, "dashboard.openCta") %> →</span>
            </a>
        </div>

        <div style="display:grid;place-items:center;margin-top:24px">
            <a href="dashboard.jsp" class="btn btn-outline" style="min-inline-size:160px"><%= LanguageUtil.getText(lang, "nav.dashboard") %></a>
        </div>
    </div>

    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>
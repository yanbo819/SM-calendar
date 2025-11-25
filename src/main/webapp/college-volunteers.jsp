<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.utils.LanguageUtil" %>
<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String lang = (String) session.getAttribute("lang");
    if (lang == null && user.getPreferredLanguage() != null) lang = user.getPreferredLanguage();
    if (lang == null) lang = "en";
    String textDir = com.smartcalendar.utils.LanguageUtil.getTextDirection(lang);

    boolean isAdmin = user.getRole() != null && user.getRole().equalsIgnoreCase("admin");
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= LanguageUtil.getText(lang, "dashboard.collegeVolunteers") %> - <%= LanguageUtil.getText(lang, "app.title") %></title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <style>
        /* Consistent dashboard button styling */
        .nav-actions .btn, .tiles-grid .btn { background:#2563eb; color:#fff; border:1px solid #2563eb; }
        .nav-actions .btn.btn-outline, .tiles-grid .btn.btn-outline { background:#2563eb; }
        .nav-actions .btn:hover, .tiles-grid .btn:hover { background:#1d4ed8; border-color:#1d4ed8; }
        .nav-actions .btn.btn-outline:hover, .tiles-grid .btn.btn-outline:hover { background:#1d4ed8; }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/jspf/flash-messages.jspf" %>
    <!-- Animated background behind tiles -->
    <div class="dashboard-bg">
        <div class="orb orb-1"></div>
        <div class="orb orb-2"></div>
        <div class="orb orb-3"></div>
    </div>
    <nav class="main-nav">
        <div class="nav-container">
            <h1 class="nav-title"><%= LanguageUtil.getText(lang, "app.title") %></h1>
            <div class="nav-actions" style="display:flex;align-items:center;gap:8px;position:relative;">
                <span class="user-welcome">
                    <%= LanguageUtil.getText(lang, "dashboard.welcome") %>, <%= user.getFullName() %>!
                </span>
                <%
                    Integer notifCountAttr = (Integer) request.getAttribute("pendingNotifications");
                    int notifCount = notifCountAttr != null ? notifCountAttr : 0;
                %>
                <div id="notifWrapper" style="position:relative;">
                    <button id="notifBell" class="btn btn-outline" title="<%= LanguageUtil.getText(lang, "notif.title") %>" style="position:relative;padding:4px 10px;line-height:1;display:flex;align-items:center;gap:4px;" onclick="(function(){var d=document.getElementById('notifDropdown');d.style.display=d.style.display==='none'||d.style.display===''?'block':'none';})();">
                        <span style="font-size:1.1rem">🔔</span>
                        <% if (notifCount > 0) { %>
                        <span class="badge" style="position:absolute;inset-block-start:-4px;inset-inline-end:-4px;background:#dc3545;color:#fff;border-radius:12px;padding:2px 6px;font-size:.65rem;"><%= notifCount %></span>
                        <% } %>
                    </button>
                    <div id="notifDropdown" style="display:none;position:absolute;inset-block-start:110%;inset-inline-end:0;background:#fff;border:1px solid #ddd;border-radius:8px;min-inline-size:220px;box-shadow:0 4px 14px rgba(0,0,0,.15);padding:8px;z-index:60;">
                        <div style="font-weight:600;margin-block-end:4px;display:flex;justify-content:space-between;align-items:center;">
                            <span><%= LanguageUtil.getText(lang, "notif.title") %></span>
                            <button type="button" class="btn btn-outline btn-sm" style="padding:2px 6px;font-size:.65rem" onclick="document.getElementById('notifDropdown').style.display='none'">✕</button>
                        </div>
                        <div style="font-size:.75rem;color:#374151;padding:2px 0">
                            <% if (notifCount == 0) { %>
                                <%= LanguageUtil.getText(lang, "notif.none") %>
                            <% } else { %>
                                <%= LanguageUtil.getText(lang, "notif.haveHidden") %>
                            <% } %>
                        </div>
                    </div>
                </div>
                <form action="set-language" method="post" style="margin:0;display:flex;align-items:center;gap:4px;">
                    <select name="lang" onchange="this.form.submit()" class="form-control" style="padding:4px 8px;min-inline-size:110px;">
                        <%
                            for (String code : com.smartcalendar.utils.LanguageUtil.getSupportedLanguages()) {
                        %>
                        <option value="<%= code %>" <%= code.equals(lang)?"selected":"" %>><%= com.smartcalendar.utils.LanguageUtil.getLanguageName(code) %></option>
                        <% } %>
                    </select>
                </form>
                <button id="navMoreToggle" class="btn btn-outline" title="Menu" aria-haspopup="true" aria-expanded="false" style="padding-inline:12px">⋮</button>
                <div id="navMoreMenu" style="display:none;position:absolute;inset-block-start:100%;inset-inline-end:0;background:#fff;border:1px solid #ddd;border-radius:8px;padding:8px;min-inline-size:180px;box-shadow:0 4px 12px rgba(0,0,0,.12);z-index:50">
                    <% if (isAdmin) { %>
                        <a href="admin-tools.jsp" class="btn btn-outline" style="inline-size:100%;margin-block:4px"><%= LanguageUtil.getText(lang, "nav.adminTools") %></a>
                        <a href="face-id.jsp" class="btn btn-outline" style="inline-size:100%;margin-block:4px"><%= LanguageUtil.getText(lang, "nav.addFaceId") %></a>
                    <% } %>
                    <a href="dashboard.jsp" class="btn btn-outline" style="inline-size:100%;margin-block:4px"><%= LanguageUtil.getText(lang, "nav.dashboard") %></a>
                    <a href="logout" class="btn btn-outline" style="inline-size:100%;margin-block:4px"><%= LanguageUtil.getText(lang, "nav.logout") %></a>
                </div>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <div class="page-header" style="text-align:center;margin-block-end:32px;">
            <h2 style="color:#1f2937;font-size:2rem;font-weight:700;margin-block-end:8px;"><%= LanguageUtil.getText(lang, "dashboard.collegeVolunteers") %></h2>
            <p style="color:#6b7280;font-size:1.1rem;"><%= LanguageUtil.getText(lang, "dashboard.collegeVolunteersDesc") %></p>
            <div id="volStats" style="margin-block-start:12px;font-size:.8rem;color:#4b5563;display:flex;justify-content:center;gap:18px;flex-wrap:wrap;">
                <span data-role="stat-cst">CST: …</span>
                <span data-role="stat-business">Business: …</span>
                <span data-role="stat-chinese">Chinese: …</span>
                <span data-role="stat-total">Total: …</span>
            </div>
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
    </div>

    <script>
        // Request notification permission and load volunteer stats
        document.addEventListener('DOMContentLoaded', function() {
            // Three-dot menu toggle
            const moreToggle = document.getElementById('navMoreToggle');
            const moreMenu = document.getElementById('navMoreMenu');
            if (moreToggle && moreMenu) {
                moreToggle.addEventListener('click', function(){
                    const open = moreMenu.style.display !== 'none';
                    moreMenu.style.display = open ? 'none' : 'block';
                    moreToggle.setAttribute('aria-expanded', open ? 'false' : 'true');
                });
                document.addEventListener('click', function(e){
                    if (!moreMenu.contains(e.target) && e.target !== moreToggle) {
                        moreMenu.style.display = 'none';
                        moreToggle.setAttribute('aria-expanded','false');
                    }
                });
            }
            if ('Notification' in window && Notification.permission === 'default') {
                Notification.requestPermission();
            }
            // Fetch volunteer stats
            fetch('volunteer-stats').then(r => r.ok ? r.json() : null).then(data => {
                if(!data) return;
                const map = {
                    'stat-cst':['CST','cst'],
                    'stat-business':['Business','business'],
                    'stat-chinese':['Chinese','chinese'],
                    'stat-total':['Total','total']
                };
                Object.keys(map).forEach(k=>{
                    const el = document.querySelector('[data-role="'+k+'"]');
                    if(el) {
                        const cfg = map[k];
                        el.textContent = cfg[0] + ': ' + (data[cfg[1]]);
                    }
                });
            }).catch(()=>{});
        });
    </script>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.models.Event" %>
<%@ page import="com.smartcalendar.models.FaceConfig" %>
<%@ page import="com.smartcalendar.dao.FaceConfigDao" %>
<%@ page import="com.smartcalendar.utils.LanguageUtil" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
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
    @SuppressWarnings("unchecked") List<Event> upcomingEvents = (List<Event>) request.getAttribute("upcomingEvents");
    if (upcomingEvents == null) upcomingEvents = java.util.Collections.emptyList();
    Integer todayEventsAttr = (Integer) request.getAttribute("todayEvents");
    Integer weekEventsAttr = (Integer) request.getAttribute("weekEvents");
    Integer totalEventsAttr = (Integer) request.getAttribute("totalEvents");
    int todayEventsVal = todayEventsAttr != null ? todayEventsAttr : 0;
    int weekEventsVal = weekEventsAttr != null ? weekEventsAttr : 0;
    int totalEventsVal = totalEventsAttr != null ? totalEventsAttr : 0;
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");

    // Build Face Recognition windows JSON for client-side gating
    StringBuilder faceWinJson = new StringBuilder("[");
    try {
        java.util.List<FaceConfig> fws = FaceConfigDao.getActiveWindows();
        for (int i=0;i<fws.size();i++) {
            FaceConfig w = fws.get(i);
            faceWinJson.append("{\"day\":").append(w.getDayOfWeek())
                       .append(",\"start\":\"").append(w.getStartTime())
                       .append("\",\"end\":\"").append(w.getEndTime()).append("\"}");
            if (i < fws.size()-1) faceWinJson.append(",");
        }
    } catch (Exception ignore) { }
    faceWinJson.append("]");
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= LanguageUtil.getText(lang, "app.title") %> - <%= LanguageUtil.getText(lang, "dashboard.title") %></title>
    <%@ include file="/WEB-INF/jspf/csrf-meta.jspf" %>
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
            <h1 class="nav-title" style="display:flex;align-items:center;gap:8px;">
                <img src="images/logo-animated-pro.svg" alt="Smart Calendar" width="140" height="42" loading="eager" decoding="async" />
                <span><%= LanguageUtil.getText(lang, "app.title") %></span>
            </h1>
            <div class="nav-actions" style="display:flex;align-items:center;gap:8px;position:relative;">
                <span class="user-welcome">
                    <%= LanguageUtil.getText(lang, "dashboard.welcome") %>, <%= user.getUsername() %>!
                </span>
                <%
                    Integer notifCountAttr = (Integer) request.getAttribute("pendingNotifications");
                    int notifCount = notifCountAttr != null ? notifCountAttr : 0;
                %>
                <div id="notifWrapper" style="position:relative;">
                    <button id="notifBell" class="btn btn-outline" title="<%= LanguageUtil.getText(lang, "notif.title") %>" style="position:relative;padding:4px 10px;line-height:1;display:flex;align-items:center;gap:4px;" onclick="(function(){var d=document.getElementById('notifDropdown');d.style.display=d.style.display==='none'||d.style.display===''?'block':'none';})();">
                        <span style="font-size:1.1rem">🔔</span>
                        <% if (notifCount > 0) { %>
                        <span class="badge" style="position:absolute;top:-4px;right:-4px;background:#dc3545;color:#fff;border-radius:12px;padding:2px 6px;font-size:.65rem;"><%= notifCount %></span>
                        <% } %>
                    </button>
                    <div id="notifDropdown" style="display:none;position:absolute;top:110%;right:0;background:#fff;border:1px solid #ddd;border-radius:8px;min-width:220px;box-shadow:0 4px 14px rgba(0,0,0,.15);padding:8px;z-index:60;">
                        <div style="font-weight:600;margin-bottom:4px;display:flex;justify-content:space-between;align-items:center;">
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
                    <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
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
                    <a href="events" class="btn btn-outline" style="inline-size:100%;margin-block:4px"><%= LanguageUtil.getText(lang, "dashboard.myEvents") %></a>
                    <a href="logout" class="btn btn-outline" style="inline-size:100%;margin-block:4px"><%= LanguageUtil.getText(lang, "nav.logout") %></a>
                </div>
            </div>
        </div>
    </nav>

    <%-- Admin toolbar removed: replaced by dedicated Admin Tools page --%>

    <div class="dashboard-container">
        <div class="tiles-grid">
            <% if (isAdmin) { %>
            <div class="tile tile-admin" style="grid-column:1/-1">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">🛠️</span>
                        <h3><%= LanguageUtil.getText(lang, "dashboard.adminQuick") %></h3>
                    </div>
                    <div style="display:flex;flex-wrap:wrap;gap:8px;margin-block-start:8px">
                        <a class="btn btn-outline" href="admin-locations?category=gate"><%= LanguageUtil.getText(lang, "dashboard.collegesGates") %></a>
                        <a class="btn btn-outline" href="admin-locations?category=hospital"><%= LanguageUtil.getText(lang, "dashboard.hospitals") %></a>
                        <a class="btn btn-outline" href="admin-locations?category=immigration"><%= LanguageUtil.getText(lang, "dashboard.policeImmigration") %></a>
                        <a class="btn btn-outline" href="admin-cst-team"><%= LanguageUtil.getText(lang, "dashboard.cstTeam") %></a>
                    </div>
                </div>
            </div>
            <% } %>
            <!-- Tile 1: My Events with quick stats and next upcoming -->
            <a class="tile tile-events" href="events">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">📅</span>
                        <h3><%= LanguageUtil.getText(lang, "dashboard.myEvents") %></h3>
                    </div>
                    <div class="tile-stats">
                        <div class="stat"><span class="stat-number"><%= todayEventsVal %></span><span class="stat-label"><%= LanguageUtil.getText(lang, "dashboard.today") %></span></div>
                        <div class="stat"><span class="stat-number"><%= weekEventsVal %></span><span class="stat-label"><%= LanguageUtil.getText(lang, "dashboard.thisWeek") %></span></div>
                        <div class="stat"><span class="stat-number"><%= totalEventsVal %></span><span class="stat-label"><%= LanguageUtil.getText(lang, "dashboard.total") %></span></div>
                    </div>
                    <div class="tile-upcoming">
                        <% if (upcomingEvents.isEmpty()) { %>
                            <div class="upcoming-empty"><%= LanguageUtil.getText(lang, "dashboard.noUpcoming") %></div>
                        <% } else { Event next = upcomingEvents.get(0); %>
                            <div class="upcoming-row">
                                <div class="upcoming-when"><%= dateFormat.format(next.getEventDate()) %> · <%= timeFormat.format(next.getEventTime()) %></div>
                                <div class="upcoming-title"><%= next.getTitle() %></div>
                                <% if (next.getUserId() != user.getUserId()) { %>
                                    <form action="follow-admin-event" method="post" style="display:inline; margin-inline-start:6px;">
                                        <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
                                        <input type="hidden" name="id" value="<%= next.getEventId() %>" />
                                        <button type="submit" style="font-size:0.70em;" title="<%= LanguageUtil.getText(lang, "dashboard.addToMyEvents") %>"><%= LanguageUtil.getText(lang, "dashboard.follow") %></button>
                                    </form>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                </div>
                <span class="tile-cta"><%= LanguageUtil.getText(lang, "dashboard.openCta") %> →</span>
            </a>

            <!-- Tile 2: Create Reminder -->
            <a class="tile tile-create" href="create-event.jsp">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">➕</span>
                        <h3><%= LanguageUtil.getText(lang, "dashboard.createReminder") %></h3>
                    </div>
                    <p class="tile-desc"><%= LanguageUtil.getText(lang, "dashboard.createReminderDesc") %></p>
                </div>
                <span class="tile-cta"><%= LanguageUtil.getText(lang, "dashboard.createCta") %> →</span>
            </a>

            <!-- Tile 3: Upload Schedule -->
            <a class="tile tile-upload" href="schedule-upload.jsp">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">⬆️</span>
                        <h3><%= LanguageUtil.getText(lang, "dashboard.uploadSchedule") %></h3>
                    </div>
                    <p class="tile-desc"><%= LanguageUtil.getText(lang, "dashboard.uploadScheduleDesc") %></p>
                </div>
                <span class="tile-cta"><%= LanguageUtil.getText(lang, "dashboard.uploadCta") %> →</span>
            </a>

            <!-- Tile 4: Important Locations -->
            <a class="tile tile-colleges" href="important-locations.jsp">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">🏫</span>
                        <h3><%= LanguageUtil.getText(lang, "dashboard.importantLocations") %></h3>
                    </div>
                    <p class="tile-desc"><%= LanguageUtil.getText(lang, "dashboard.importantLocationsDesc") %></p>
                </div>
                <span class="tile-cta"><%= LanguageUtil.getText(lang, "dashboard.openCta") %> →</span>
            </a>
            <!-- Tile 5: Face ID Windows (management / scanning gated by time) -->
            <button id="faceRecTile" class="tile tile-face" type="button" title="<%= LanguageUtil.getText(lang, "dashboard.faceWindows") %>">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">🧑‍🦰</span>
                        <h3><%= LanguageUtil.getText(lang, "dashboard.faceWindows") %></h3>
                    </div>
                        <p class="tile-desc"><%= LanguageUtil.getText(lang, "dashboard.faceWindowsDesc") %></p>
                </div>
                <span class="tile-cta"><%= LanguageUtil.getText(lang, "dashboard.scanCta") %> →</span>
            </button>

            <!-- Tile 6: College Volunteers -->
            <a class="tile tile-face" href="college-volunteers.jsp">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">🤝</span>
                        <h3><%= LanguageUtil.getText(lang, "dashboard.collegeVolunteers") %></h3>
                    </div>
                    <p class="tile-desc"><%= LanguageUtil.getText(lang, "dashboard.collegeVolunteersDesc") %></p>
                </div>
                <span class="tile-cta"><%= LanguageUtil.getText(lang, "dashboard.openCta") %> →</span>
            </a>


        </div>
    </div>

    <script>
        // Request notification permission when page loads
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
                const adminToggle = document.getElementById('adminMenuToggle');
                const adminWrapper = document.getElementById('adminToolbarWrapper');
                if (adminToggle && adminWrapper) {
                    adminToggle.addEventListener('click', function(e){
                        e.stopPropagation();
                        const open = adminWrapper.style.display !== 'none';
                        adminWrapper.style.display = open ? 'none' : '';
                        adminToggle.textContent = open ? '<%= LanguageUtil.getText(lang, "nav.adminTools") %> ▾' : '<%= LanguageUtil.getText(lang, "nav.adminTools") %> ▴';
                    });
                }
            }
            if ('Notification' in window && Notification.permission === 'default') {
                Notification.requestPermission();
            }

            // Dynamic Face Recognition windows (loaded from DB)
            const FACE_WINDOWS = JSON.parse('<%= faceWinJson.toString() %>');
            function withinAllowedWindow(d) {
                const jsDay = d.getDay(); // 0=Sun
                const dayNorm = jsDay === 0 ? 7 : jsDay; // 1..7
                const minutesNow = d.getHours()*60 + d.getMinutes();
                return FACE_WINDOWS.some(w => {
                    if (w.day !== dayNorm) return false;
                    const [sh, sm, ss] = (''+w.start).split(':');
                    const [eh, em, es] = (''+w.end).split(':');
                    const startM = parseInt(sh,10)*60 + parseInt(sm,10);
                    const endM = parseInt(eh,10)*60 + parseInt(em,10);
                    return minutesNow >= startM && minutesNow < endM;
                });
            }

            // Face add button is always visible; windows gating handled on click

            // Face recognition tile handler (i18n)
            const I18N_FACE = {
                unavailable: '<%= LanguageUtil.getText(lang, "face.unavailable") %>',
                needEnroll: '<%= LanguageUtil.getText(lang, "face.needEnroll") %>',
                requesting: '<%= LanguageUtil.getText(lang, "face.requesting") %>',
                positionFace: '<%= LanguageUtil.getText(lang, "face.positionFace") %>',
                cameraDenied: '<%= LanguageUtil.getText(lang, "face.cameraDenied") %>',
                recognized: '<%= LanguageUtil.getText(lang, "face.recognized") %>',
                noEnrollment: '<%= LanguageUtil.getText(lang, "face.noEnrollment") %>',
                notRecognized: '<%= LanguageUtil.getText(lang, "face.notRecognized") %>',
                serviceError: '<%= LanguageUtil.getText(lang, "face.serviceError") %>',
                modalTitle: '<%= LanguageUtil.getText(lang, "face.modalTitle") %>',
                cancel: '<%= LanguageUtil.getText(lang, "common.cancel") %>',
                scan: '<%= LanguageUtil.getText(lang, "face.scan") %>'
            };
            const faceTile = document.getElementById('faceRecTile');
            function showTimeNotice() { alert(I18N_FACE.unavailable); }

            // Create a simple modal for camera preview and scan
            const modalHtml = `
                <div id="faceModal" class="face-modal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.6);align-items:center;justify-content:center;z-index:9999;">
                    <div class="face-modal-panel" style="background:#fff;padding:16px;border-radius:8px;max-inline-size:480px;inline-size:90%;box-shadow:0 6px 20px rgba(0,0,0,0.3);">
                        <h3 style="margin-block-start:0"><%= LanguageUtil.getText(lang, "face.modalTitle") %></h3>
                        <p id="faceStatus"><%= LanguageUtil.getText(lang, "face.requesting") %></p>
                        <video id="faceVideo" autoplay playsinline style="inline-size:100%;border-radius:6px;background:#000"></video>
                        <canvas id="faceCanvas" style="display:none"></canvas>
                        <div style="margin-block-start:8px;display:flex;gap:8px;justify-content:flex-end;">
                            <button id="faceCancel" class="btn"><%= LanguageUtil.getText(lang, "common.cancel") %></button>
                            <button id="faceScan" class="btn btn-primary"><%= LanguageUtil.getText(lang, "face.scan") %></button>
                        </div>
                    </div>
                </div>`;

            document.body.insertAdjacentHTML('beforeend', modalHtml);
            const faceModal = document.getElementById('faceModal');
            const faceVideo = document.getElementById('faceVideo');
            const faceCanvas = document.getElementById('faceCanvas');
            const faceStatus = document.getElementById('faceStatus');
            const faceCancel = document.getElementById('faceCancel');
            const faceScan = document.getElementById('faceScan');
            let mediaStream = null;

            function stopStream() {
                if (mediaStream) {
                    mediaStream.getTracks().forEach(t => t.stop());
                    mediaStream = null;
                }
                if (faceVideo) faceVideo.srcObject = null;
            }

            faceCancel.addEventListener('click', function(){
                stopStream();
                faceModal.style.display = 'none';
            });

            faceTile.addEventListener('click', async function(e){
                const now = new Date();
                if (!withinAllowedWindow(now)) {
                    showTimeNotice();
                    return;
                }

                // Require enrollment before scanning
                const hasFace = (function(){
                    try { return <%= (new Boolean(true ? (com.smartcalendar.dao.UserFaceDao.hasFace(user.getUserId())) : false)).toString() %>; } catch(e){ return false; }
                })();
                if (!hasFace) {
                    const go = confirm(I18N_FACE.needEnroll);
                    if (go) { window.location.href = 'face-id.jsp'; }
                    return;
                }

                // Try to get geolocation first (best-effort)
                let coords = null;
                if (navigator.geolocation) {
                    try {
                        coords = await new Promise((resolve, reject) => {
                            navigator.geolocation.getCurrentPosition(pos => resolve(pos.coords), err => resolve(null), { enableHighAccuracy: true, timeout: 10000 });
                        });
                    } catch(e) { coords = null; }
                }

                // Request camera
                try {
                    mediaStream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'user' }, audio: false });
                    faceVideo.srcObject = mediaStream;
                    faceStatus.textContent = I18N_FACE.positionFace;
                    faceModal.style.display = 'flex';
                } catch (err) {
                    alert(I18N_FACE.cameraDenied);
                    return;
                }

                faceScan.onclick = async function(){
                    // capture frame
                    const w = faceVideo.videoWidth || 320;
                    const h = faceVideo.videoHeight || 240;
                    faceCanvas.width = w; faceCanvas.height = h;
                    const ctx = faceCanvas.getContext('2d');
                    ctx.drawImage(faceVideo, 0, 0, w, h);
                    const dataUrl = faceCanvas.toDataURL('image/png');

                    // Stop camera
                    stopStream();
                    faceModal.style.display = 'none';

                    // Send to backend for simple recognition
                    try {
                        const res = await fetch('face-recognize', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ image: dataUrl }) });
                        const data = await res.json();
                        if (data && data.ok) {
                            alert(I18N_FACE.recognized);
                        } else if (data && data.reason === 'no_enrollment') {
                            alert(I18N_FACE.noEnrollment);
                            window.location.href = 'face-id.jsp';
                        } else {
                            alert(I18N_FACE.notRecognized);
                        }
                    } catch(err) {
                        alert(I18N_FACE.serviceError);
                    }
                };
            });
        });
    </script>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>
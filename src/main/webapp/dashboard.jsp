<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.models.Event" %>
<%@ page import="com.smartcalendar.models.FaceConfig" %>
<%@ page import="com.smartcalendar.dao.FaceConfigDao" %>
<%@ page import="com.smartcalendar.utils.LanguageUtil" %>
<%@ page import="com.smartcalendar.utils.DatabaseUtil" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String lang = "en";
    String textDir = "ltr";
    
    // Determine admin role using roles column
    boolean isAdmin = user.getRole() != null && user.getRole().equalsIgnoreCase("admin");
    // Get upcoming events for dashboard preview (include admin-published events)
    List<Event> upcomingEvents = new ArrayList<Event>();
    Connection conn = null;
    try {
        conn = DatabaseUtil.getConnection();
    String sql = "SELECT e.event_id, e.user_id, e.title, e.event_date, e.event_time, e.location, " +
            "c.category_name, c.category_color, s.subject_name " +
            "FROM events e " +
            "LEFT JOIN categories c ON e.category_id = c.category_id " +
            "LEFT JOIN subjects s ON e.subject_id = s.subject_id " +
        "WHERE e.event_date >= CURRENT_DATE AND e.is_active = TRUE AND (e.user_id = ? OR e.user_id IN (SELECT user_id FROM users WHERE role='admin')) " +
            "ORDER BY e.event_date ASC, e.event_time ASC LIMIT 5";
        
        PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, user.getUserId());
        ResultSet rs = stmt.executeQuery();
        
        while (rs.next()) {
            Event event = new Event();
            event.setEventId(rs.getInt("event_id"));
            event.setUserId(rs.getInt("user_id"));
            event.setTitle(rs.getString("title"));
            event.setEventDate(rs.getDate("event_date"));
            event.setEventTime(rs.getTime("event_time"));
            event.setLocation(rs.getString("location"));
            event.setCategoryName(rs.getString("category_name"));
            event.setCategoryColor(rs.getString("category_color"));
            event.setSubjectName(rs.getString("subject_name"));
            upcomingEvents.add(event);
        }
    } catch (SQLException e) {
        // Error fetching upcoming events: " + e.getMessage()
    } finally {
        if (conn != null) {
            try { conn.close(); } catch (SQLException e) {}
        }
    }
    
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
    <title><%= LanguageUtil.getText(lang, "app.title") %> - Dashboard</title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/dashboard.css">
</head>
<body>
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
                <button id="navMoreToggle" class="btn btn-outline" title="Menu" aria-haspopup="true" aria-expanded="false" style="padding-inline:12px">⋮</button>
                <div id="navMoreMenu" style="display:none;position:absolute;inset-block-start:100%;inset-inline-end:0;background:#fff;border:1px solid #ddd;border-radius:8px;padding:8px;min-inline-size:160px;box-shadow:0 4px 12px rgba(0,0,0,.12);z-index:50">
                    <a href="logout" class="btn btn-outline" style="inline-size:100%;margin-block:4px"><%= LanguageUtil.getText(lang, "nav.logout") %></a>
                </div>
            </div>
        </div>
    </nav>

    <%-- Unified Admin Toolbar (for admin users) --%>
        <% if (isAdmin) { %>
        <button id="adminToolbarToggle" class="btn btn-outline" style="margin:8px 16px">Admin Tools ▾</button>
        <div id="adminToolbarWrapper" style="display:none">
                <jsp:include page="/WEB-INF/jsp/includes/admin-toolbar.jspf" />
        </div>
        <script>
            (function(){
                var btn = document.getElementById('adminToolbarToggle');
                var wrap = document.getElementById('adminToolbarWrapper');
                if(btn && wrap){
                    btn.addEventListener('click', function(){
                        var open = wrap.style.display !== 'none';
                        wrap.style.display = open ? 'none' : '';
                        btn.textContent = open ? 'Admin Tools ▾' : 'Admin Tools ▴';
                    });
                }
            })();
        </script>
        <% } %>

    <div class="dashboard-container">
        <%-- Show unsent notifications for this user --%>
        <%
            List<Integer> notifIds = new ArrayList<Integer>();
            List<String> notifMsgs = new ArrayList<String>();
            Connection nConn = null;
            try {
                nConn = DatabaseUtil.getConnection();
                PreparedStatement nSel = nConn.prepareStatement("SELECT notification_id, message FROM notifications WHERE user_id = ? AND is_sent = FALSE ORDER BY notification_time DESC LIMIT 5");
                nSel.setInt(1, user.getUserId());
                ResultSet nRs = nSel.executeQuery();
                while (nRs.next()) { notifIds.add(nRs.getInt(1)); notifMsgs.add(nRs.getString(2)); }
                if (!notifIds.isEmpty()) {
        %>
    <div class="tile tile-notify" style="background:#fff3cd;border:1px solid #ffeeba;color:#856404;margin-block-end:12px;border-radius:8px;padding:12px;">
            <strong>Notifications</strong>
            <ul style="margin:6px 0 0 18px;">
                <% for (String m : notifMsgs) { %>
                    <li><%= m %></li>
                <% } %>
            </ul>
        </div>
        <%
                    // mark as sent
                    StringBuilder inClause = new StringBuilder();
                    for (int i=0;i<notifIds.size();i++) { if (i>0) inClause.append(","); inClause.append("?"); }
                    PreparedStatement nUpd = nConn.prepareStatement("UPDATE notifications SET is_sent = TRUE WHERE notification_id IN (" + inClause + ")");
                    for (int i=0;i<notifIds.size();i++) nUpd.setInt(i+1, notifIds.get(i));
                    nUpd.executeUpdate();
                }
            } catch (SQLException ignore) { } finally { if (nConn != null) try { nConn.close(); } catch (SQLException e) {} }
        %>
        <div class="tiles-grid">
            <% if (isAdmin) { %>
            <div class="tile tile-admin" style="grid-column:1/-1">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">🛠️</span>
                        <h3>Admin: Quick Manage</h3>
                    </div>
                    <div style="display:flex;flex-wrap:wrap;gap:8px;margin-block-start:8px">
                        <a class="btn btn-outline" href="admin-locations?category=gate">Colleges / Gates</a>
                        <a class="btn btn-outline" href="admin-locations?category=hospital">Hospitals</a>
                        <a class="btn btn-outline" href="admin-locations?category=immigration">Police &amp; Immigration</a>
                    </div>
                </div>
            </div>
            <% } %>
            <!-- Tile 1: My Events with quick stats and next upcoming -->
            <a class="tile tile-events" href="events.jsp">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">📅</span>
                        <h3>My Events</h3>
                    </div>
                    <div class="tile-stats">
                        <%
                            int todayEvents = 0;
                            int weekEvents = 0;
                            int totalEvents = 0;
                            Connection conn2 = null;
                            try {
                                conn2 = DatabaseUtil.getConnection();
                                PreparedStatement stmt1 = conn2.prepareStatement(
                                    "SELECT COUNT(*) FROM events WHERE user_id = ? AND event_date = CURRENT_DATE AND is_active = TRUE");
                                stmt1.setInt(1, user.getUserId());
                                ResultSet rs1 = stmt1.executeQuery();
                                if (rs1.next()) todayEvents = rs1.getInt(1);
                                PreparedStatement stmt2 = conn2.prepareStatement(
                                    "SELECT COUNT(*) FROM events WHERE user_id = ? AND event_date BETWEEN CURRENT_DATE AND DATEADD('DAY', 7, CURRENT_DATE) AND is_active = TRUE");
                                stmt2.setInt(1, user.getUserId());
                                ResultSet rs2 = stmt2.executeQuery();
                                if (rs2.next()) weekEvents = rs2.getInt(1);
                                PreparedStatement stmt3 = conn2.prepareStatement(
                                    "SELECT COUNT(*) FROM events WHERE user_id = ? AND is_active = TRUE");
                                stmt3.setInt(1, user.getUserId());
                                ResultSet rs3 = stmt3.executeQuery();
                                if (rs3.next()) totalEvents = rs3.getInt(1);
                            } catch (SQLException e) { /* ignore */ } finally { if (conn2 != null) { try { conn2.close(); } catch (SQLException e) {} } }
                        %>
                        <div class="stat"><span class="stat-number"><%= todayEvents %></span><span class="stat-label">Today</span></div>
                        <div class="stat"><span class="stat-number"><%= weekEvents %></span><span class="stat-label">This Week</span></div>
                        <div class="stat"><span class="stat-number"><%= totalEvents %></span><span class="stat-label">Total</span></div>
                    </div>
                    <div class="tile-upcoming">
                        <% if (upcomingEvents.isEmpty()) { %>
                            <div class="upcoming-empty">No upcoming events</div>
                        <% } else { Event next = upcomingEvents.get(0); %>
                            <div class="upcoming-row">
                                <div class="upcoming-when"><%= dateFormat.format(next.getEventDate()) %> · <%= timeFormat.format(next.getEventTime()) %></div>
                                <div class="upcoming-title"><%= next.getTitle() %></div>
                                <% if (next.getUserId() != user.getUserId()) { %>
                                    <form action="follow-admin-event" method="post" style="display:inline; margin-inline-start:6px;">
                                        <input type="hidden" name="id" value="<%= next.getEventId() %>" />
                                        <button type="submit" style="font-size:0.70em;" title="Add to My Events">Follow</button>
                                    </form>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                </div>
                <span class="tile-cta">Open →</span>
            </a>

            <!-- Tile 2: Create Reminder -->
            <a class="tile tile-create" href="create-event.jsp">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">➕</span>
                        <h3>Create Reminder</h3>
                    </div>
                    <p class="tile-desc">Add a new meeting, exam, course, or activity with a reminder.</p>
                </div>
                <span class="tile-cta">Create →</span>
            </a>

            <!-- Tile 3: Upload Schedule -->
            <a class="tile tile-upload" href="schedule-upload.jsp">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">⬆️</span>
                        <h3>Upload Schedule</h3>
                    </div>
                    <p class="tile-desc">Import your course schedule from CSV or iCalendar (.ics) in seconds.</p>
                </div>
                <span class="tile-cta">Upload →</span>
            </a>

            <!-- Tile 4: Important Locations -->
            <a class="tile tile-colleges" href="important-locations.jsp">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">🏫</span>
                        <h3>Important Locations</h3>
                    </div>
                    <p class="tile-desc">Find colleges, hospitals, police & immigration, schools, and restaurants.</p>
                </div>
                <span class="tile-cta">Open →</span>
            </a>
            <!-- Tile 5: Face ID Windows (management / scanning gated by time) -->
            <button id="faceRecTile" class="tile tile-face" type="button" title="Face ID Windows">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">🧑‍🦰</span>
                        <h3>Face ID Windows</h3>
                    </div>
                        <p class="tile-desc">Use Face ID during allowed windows configured by admin.</p>
                </div>
                <span class="tile-cta">Scan →</span>
            </button>
            <!-- Tile 6: Add My New Face ID (enrollment) -->
            <a class="tile tile-face-enroll" href="face-id.jsp">
                <div class="tile-content">
                    <div class="tile-header">
                        <span class="tile-icon">🧪</span>
                        <h3>Add My New Face ID</h3>
                    </div>
                    <p class="tile-desc">Register a new face ID for recognition access.</p>
                </div>
                <span class="tile-cta">Enroll →</span>
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

            // Face recognition tile handler
            const faceTile = document.getElementById('faceRecTile');
            function showTimeNotice() {
                alert('Face Recognition is not available right now (outside configured windows).');
            }

            // Create a simple modal for camera preview and scan
            const modalHtml = `
                <div id="faceModal" class="face-modal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.6);align-items:center;justify-content:center;z-index:9999;">
                    <div class="face-modal-panel" style="background:#fff;padding:16px;border-radius:8px;max-inline-size:480px;inline-size:90%;box-shadow:0 6px 20px rgba(0,0,0,0.3);">
                        <h3 style="margin-block-start:0">Face Recognition</h3>
                        <p id="faceStatus">Requesting camera and location...</p>
                        <video id="faceVideo" autoplay playsinline style="inline-size:100%;border-radius:6px;background:#000"></video>
                        <canvas id="faceCanvas" style="display:none"></canvas>
                        <div style="margin-block-start:8px;display:flex;gap:8px;justify-content:flex-end;">
                            <button id="faceCancel" class="btn">Cancel</button>
                            <button id="faceScan" class="btn btn-primary">Scan Face</button>
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
                    const go = confirm('You need to add your Face ID first. Go to enrollment now?');
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
                    faceStatus.textContent = 'Position your face in front of the camera and click Scan Face.';
                    faceModal.style.display = 'flex';
                } catch (err) {
                    alert('Unable to access camera. Please allow camera permission and try again.');
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
                            alert('Face recognized successfully.');
                        } else if (data && data.reason === 'no_enrollment') {
                            alert('No Face ID enrolled. Please add your Face ID first.');
                            window.location.href = 'face-id.jsp';
                        } else {
                            alert('Face not recognized.');
                        }
                    } catch(err) {
                        alert('Error contacting recognition service.');
                    }
                };
            });
        });
    </script>
</body>
</html>
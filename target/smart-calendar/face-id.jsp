<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
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
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.enrollTitle") %></title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;box-shadow:0 1px 2px rgba(0,0,0,.04);padding:24px}
        .page-title{margin:0;font-size:1.5rem;font-weight:600}
        .page-sub{color:#6b7280;margin-block-start:4px}
        .row{display:flex;gap:12px;flex-wrap:wrap;margin-block-start:12px}
        .btn-primary{background:#2563eb;color:#fff;border:1px solid #1d4ed8;padding:10px 14px;border-radius:8px;text-decoration:none}
        .btn-primary:hover{background:#1d4ed8}
        .muted{color:#6b7280}
        .status{margin-block-start:12px;font-size:.95rem}
        .success{color:#065f46}
        .error{color:#7f1d1d}
        code.inline{background:#f3f4f6;padding:2px 6px;border-radius:6px}
    </style>
</head>
<body>
    <!-- Navigation removed for streamlined admin face enrollment view -->

    <div class="form-container">
        <div class="form-header" style="display:flex;align-items:center;justify-content:center;gap:12px;flex-direction:column;">
            <h2 class="page-title" style="margin:0"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.enrollTitle") %></h2>
            <div class="page-sub"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.enrollSub") %></div>
        </div>
        <div class="card">
            <video id="enrollVideo" autoplay playsinline style="inline-size:100%;background:#000;border-radius:8px;aspect-ratio:4/3"></video>
            <canvas id="enrollCanvas" style="display:none"></canvas>
            <div class="row" style="justify-content:center">
                <button id="captureBtn" class="btn-primary" type="button"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.capture") %></button>
                <button id="saveBtn" class="btn btn-outline" type="button" disabled><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.save") %></button>
                <a href="admin-tools.jsp" class="btn btn-outline" style="min-inline-size:140px"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.goBack") %></a>
            </div>
            <div id="status" class="status muted"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.requesting") %></div>
        </div>

        <script>
            const statusEl = document.getElementById('status');
            const video = document.getElementById('enrollVideo');
            const canvas = document.getElementById('enrollCanvas');
            const btnCapture = document.getElementById('captureBtn');
            const btnSave = document.getElementById('saveBtn');
            let stream = null;
            let captured = null;

            (async function initCam(){
                try {
                    stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'user' }, audio: false });
                    video.srcObject = stream;
                    statusEl.textContent = '<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.centerFace") %>';
                } catch(e) {
                    statusEl.textContent = '<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.cameraError") %>';
                }
            })();

            btnCapture.addEventListener('click', function(){
                const w = video.videoWidth || 640;
                const h = video.videoHeight || 480;
                canvas.width = w; canvas.height = h;
                const ctx = canvas.getContext('2d');
                ctx.drawImage(video, 0, 0, w, h);
                captured = canvas.toDataURL('image/png');
                statusEl.textContent = '<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.captured") %>';
                btnSave.disabled = false;
            });

            async function getGeo(){
                if (!navigator.geolocation) return null;
                return new Promise(resolve => {
                    navigator.geolocation.getCurrentPosition(pos => resolve({lat:pos.coords.latitude, lon:pos.coords.longitude}), () => resolve(null), { enableHighAccuracy:true, timeout:8000 });
                });
            }

            btnSave.addEventListener('click', async function(){
                if (!captured) { alert('<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.captureFirst") %>'); return; }
                try {
                    statusEl.textContent = '<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.saving") %>';
                    const geo = await getGeo();
                    const payload = { image: captured };
                    if (geo) { payload.lat = geo.lat.toString(); payload.lon = geo.lon.toString(); }
                    const res = await fetch('enroll-face-id', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
                    const data = await res.json();
                    if (data && data.ok) {
                        statusEl.textContent = (geo ? '<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.savedWithLocation") %>' : '<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.savedWithoutLocation") %>');
                        alert('<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.saveSuccess") %>');
                    } else {
                        statusEl.textContent = '<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.saveFailed") %>';
                    }
                } catch(e) {
                    statusEl.textContent = '<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "face.saveError") %>';
                }
            });
        </script>
    </div>
</body>
</html>

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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add My New Face ID</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;box-shadow:0 1px 2px rgba(0,0,0,.04);padding:24px}
        .page-title{margin:0;font-size:1.5rem;font-weight:600}
        .page-sub{color:#6b7280;margin-top:4px}
        .row{display:flex;gap:12px;flex-wrap:wrap;margin-top:12px}
        .btn-primary{background:#2563eb;color:#fff;border:1px solid #1d4ed8;padding:10px 14px;border-radius:8px;text-decoration:none}
        .btn-primary:hover{background:#1d4ed8}
        .muted{color:#6b7280}
        .status{margin-top:12px;font-size:.95rem}
        .success{color:#065f46}
        .error{color:#7f1d1d}
        code.inline{background:#f3f4f6;padding:2px 6px;border-radius:6px}
    </style>
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
                <h2 class="page-title">Add My New Face ID</h2>
                <div class="page-sub">Use your camera to capture and save your Face ID.</div>
            </div>
            <a href="dashboard.jsp" class="btn btn-outline">← Back to Dashboard</a>
        </div>
        <div class="card">
            <video id="enrollVideo" autoplay playsinline style="inline-size:100%;background:#000;border-radius:8px;aspect-ratio:4/3"></video>
            <canvas id="enrollCanvas" style="display:none"></canvas>
            <div class="row">
                <button id="captureBtn" class="btn-primary" type="button">Capture</button>
                <button id="saveBtn" class="btn btn-outline" type="button" disabled>Save Face ID</button>
            </div>
            <div id="status" class="status muted">Requesting camera…</div>
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
                    statusEl.textContent = 'Center your face, then click Capture.';
                } catch(e) {
                    statusEl.textContent = 'Unable to access camera. Allow permission and reload.';
                }
            })();

            btnCapture.addEventListener('click', function(){
                const w = video.videoWidth || 640;
                const h = video.videoHeight || 480;
                canvas.width = w; canvas.height = h;
                const ctx = canvas.getContext('2d');
                ctx.drawImage(video, 0, 0, w, h);
                captured = canvas.toDataURL('image/png');
                statusEl.textContent = 'Captured. Click Save Face ID to store.';
                btnSave.disabled = false;
            });

            async function getGeo(){
                if (!navigator.geolocation) return null;
                return new Promise(resolve => {
                    navigator.geolocation.getCurrentPosition(pos => resolve({lat:pos.coords.latitude, lon:pos.coords.longitude}), () => resolve(null), { enableHighAccuracy:true, timeout:8000 });
                });
            }

            btnSave.addEventListener('click', async function(){
                if (!captured) { alert('Capture first.'); return; }
                try {
                    statusEl.textContent = 'Saving…';
                    const geo = await getGeo();
                    const payload = { image: captured };
                    if (geo) { payload.lat = geo.lat.toString(); payload.lon = geo.lon.toString(); }
                    const res = await fetch('enroll-face-id', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
                    const data = await res.json();
                    if (data && data.ok) {
                        statusEl.textContent = 'Saved with' + (geo? ' location.' : 'out location.') + ' You can now use Face ID Windows.';
                        alert('Face ID saved successfully.');
                    } else {
                        statusEl.textContent = 'Save failed. Try again.';
                    }
                } catch(e) {
                    statusEl.textContent = 'Error saving Face ID.';
                }
            });
        </script>
    </div>
</body>
</html>

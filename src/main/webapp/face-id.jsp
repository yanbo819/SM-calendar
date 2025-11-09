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
    <title>Face ID</title>
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
                <a href="logout" class="btn btn-outline">Logout</a>
            </div>
        </div>
    </nav>

    <div class="form-container">
        <div class="form-header" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
            <div>
                <h2 class="page-title">Face ID</h2>
                <div class="page-sub" id="gatingMessage">Allowed only Monday & Wednesday 08:00–12:00 and 12:00–17:00</div>
            </div>
            <a href="dashboard.jsp" class="btn btn-outline">← Back to Dashboard</a>
        </div>
        <div class="card">
            <p>Try the basic Face ID (WebAuthn) demo below. This uses your device’s platform authenticator (Touch ID / Face ID) if available.</p>
            <div class="row">
                <button id="btn-register" class="btn-primary" type="button" disabled>Register this device</button>
                <button id="btn-verify" class="btn btn-outline" type="button" disabled>Verify with Face ID</button>
            </div>
            <div id="status" class="status muted">Idle</div>
            <p class="page-sub" style="margin-top:12px">Notes: Works best on localhost over HTTPS-capable environments. On some browsers, a PIN or Touch ID prompt may appear instead of Face ID.</p>
        </div>

        <script>
            const $status = document.getElementById('status');
            const setStatus = (msg, cls) => {
                $status.className = 'status ' + (cls || '');
                $status.textContent = msg;
            };

            function b64ToArrayBuffer(b64url) {
                const pad = '='.repeat((4 - b64url.length % 4) % 4);
                const base64 = (b64url.replace(/-/g, '+').replace(/_/g, '/') + pad);
                const binary = atob(base64);
                const bytes = new Uint8Array(binary.length);
                for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
                return bytes.buffer;
            }

            function arrayBufferToB64url(buf) {
                const bytes = new Uint8Array(buf);
                let binary = '';
                for (let i = 0; i < bytes.byteLength; i++) binary += String.fromCharCode(bytes[i]);
                const base64 = btoa(binary);
                return base64.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/,'');
            }

            async function getChallenge(payload) {
                const res = await fetch('webauthn/challenge');
                if (!res.ok) throw new Error('Failed to get challenge');
                return res.json();
            }

            async function getAllowList() {
                const res = await fetch('webauthn/allow');
                if (!res.ok) throw new Error('Failed to get allow list');
                return res.json();
            }

            function withinAllowedWindow(d) {
                const day = d.getDay();
                if (!(day === 1 || day === 3)) return false;
                const minutes = d.getHours()*60 + d.getMinutes();
                const inFirst = minutes >= 8*60 && minutes < 12*60;
                const inSecond = minutes >= 12*60 && minutes < 17*60;
                return inFirst || inSecond;
            }

            let currentPosition = null;
            function requestLocationIfNeeded() {
                if (!navigator.geolocation) return Promise.resolve(null);
                return new Promise(resolve => {
                    navigator.geolocation.getCurrentPosition(pos => {
                        currentPosition = pos.coords;
                        resolve(currentPosition);
                    }, () => resolve(null), { enableHighAccuracy:true, timeout:8000 });
                });
            }

            async function prepareEnvironment() {
                const now = new Date();
                const allowed = withinAllowedWindow(now);
                const regBtn = document.getElementById('btn-register');
                const verBtn = document.getElementById('btn-verify');
                const msg = document.getElementById('gatingMessage');
                if (allowed) {
                    regBtn.disabled = false;
                    verBtn.disabled = false;
                    msg.textContent = 'Face ID is available now.';
                } else {
                    msg.textContent = 'Face ID unavailable (Mon & Wed 08:00–12:00 and 12:00–17:00 only).';
                }
                await requestLocationIfNeeded();
            }
            prepareEnvironment();

            document.getElementById('btn-register').addEventListener('click', async () => {
                try {
                    setStatus('Preparing registration…');
                    const { challenge, rpId } = await getChallenge();

                    const publicKey = {
                        challenge: b64ToArrayBuffer(challenge),
                        rp: { name: 'Smart Calendar', id: rpId },
                        user: {
                            id: new Uint8Array([1,2,3,4]), // demo only; server-side user id mapping not required for this minimal flow
                            name: 'user',
                            displayName: 'User'
                        },
                        pubKeyCredParams: [{ type: 'public-key', alg: -7 }],
                        authenticatorSelection: { authenticatorAttachment: 'platform', userVerification: 'preferred' },
                        timeout: 60000,
                        attestation: 'none'
                    };

                    setStatus('Prompting device to register…');
                    const cred = await navigator.credentials.create({ publicKey });
                    const rawIdB64 = arrayBufferToB64url(cred.rawId);

                    const body = { credentialId: rawIdB64 };
                    if (currentPosition) { body.latitude = currentPosition.latitude; body.longitude = currentPosition.longitude; }
                    const res = await fetch('webauthn/register', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(body)
                    });
                    const data = await res.json();
                    if (data.ok) setStatus('Device registered. You can now Verify with Face ID.', 'success');
                    else setStatus('Registration failed. Try again.', 'error');
                } catch (e) {
                    console.error(e);
                    setStatus('Registration error: ' + e.message, 'error');
                }
            });

            document.getElementById('btn-verify').addEventListener('click', async () => {
                try {
                    setStatus('Preparing verification…');
                    const [{ challenge, rpId }, allow] = await Promise.all([getChallenge(), getAllowList()]);

                    const publicKey = {
                        challenge: b64ToArrayBuffer(challenge),
                        rpId,
                        allowCredentials: allow.map(id => ({ type: 'public-key', id: b64ToArrayBuffer(id), transports: ['internal'] })),
                        userVerification: 'preferred',
                        timeout: 60000
                    };

                    if (!publicKey.allowCredentials.length) {
                        setStatus('No registered device found. Please register first.', 'error');
                        return;
                    }

                    setStatus('Prompting device to verify…');
                    const assertion = await navigator.credentials.get({ publicKey });
                    const rawIdB64 = arrayBufferToB64url(assertion.rawId);

                    const body = { credentialId: rawIdB64 };
                    if (currentPosition) { body.latitude = currentPosition.latitude; body.longitude = currentPosition.longitude; }
                    const res = await fetch('webauthn/assert', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(body)
                    });
                    const data = await res.json();
                    if (data.ok) setStatus('Face ID verified for this session.', 'success');
                    else setStatus('Verification failed. Try again or re-register.', 'error');
                } catch (e) {
                    console.error(e);
                    setStatus('Verification error: ' + e.message, 'error');
                }
            });
        </script>
    </div>
</body>
</html>

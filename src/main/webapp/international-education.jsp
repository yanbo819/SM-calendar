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
    <title>College of International Education and Social Development</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;box-shadow:0 1px 2px rgba(0,0,0,.04);padding:24px}
        .page-title{margin:0;font-size:1.5rem;font-weight:600}
        .page-sub{color:#6b7280;margin-top:4px}
        .teacher-list{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:12px;margin-top:8px}
        .teacher{border:1px solid #e5e7eb;border-radius:10px;padding:12px;background:#fff}
        .teacher img{display:block;max-inline-size:100%;height:auto;border-radius:8px;border:1px solid #e5e7eb;margin-bottom:8px;box-shadow:0 1px 2px rgba(0,0,0,.04)}
        .kv{display:flex;gap:6px}
        .kv b{min-inline-size:90px}
        .actions-bar{display:flex;gap:12px;flex-wrap:wrap;align-items:center;justify-content:center}
        @media (max-width: 520px){ .actions-bar{flex-direction:column;align-items:stretch} .actions-bar .btn{width:100%;justify-content:center} }
        .btn-icon{display:inline-flex;align-items:center;gap:6px}
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
        <div class="form-header">
            <div>
                <h2 class="page-title">🏫 College of International Education and Social Development</h2>
                <div class="page-sub">Contacts and information for International Education and Social Development.</div>
            </div>
        </div>

        <div class="card">
            <div class="teacher-list">
                <div class="teacher" data-teacher="傅廷 FU TING">
                    <img src="colleges%20teacher%20images/1-International%20Education.JPG" alt="傅廷 FU TING" loading="lazy" />
                    <div class="kv"><b>TEACHER NAME</b><span>傅廷 FU TING</span></div>
                    <div class="kv"><b>Address</b><span>Building 24, Room 210</span></div>
                    <div class="kv"><b>Phone</b><span><a href="tel:+8657982293163">0579-82293163</a></span></div>
                </div>
                <div class="teacher" data-teacher="张炜 ZHANH WEI">
                    <img src="colleges%20teacher%20images/2-International%20Education.JPG" alt="张炜 ZHANH WEI" loading="lazy" />
                    <div class="kv"><b>TEACHER NAME</b><span>张炜 ZHANH WEI</span></div>
                    <div class="kv"><b>Address</b><span>Building 24, Room 210</span></div>
                    <div class="kv"><b>Phone</b><span><a href="tel:+8657982293163">0579-82293163</a></span></div>
                </div>
            </div>
            <div class="card-footer">
                <div class="actions-bar">
                    <a href="colleges-info.jsp" class="btn btn-outline btn-icon">← <span>Back</span></a>
                    <a href="https://surl.amap.com/2x3CujMlV2Ej" target="_blank" rel="noopener noreferrer" class="btn btn-primary btn-icon">📍 <span>Go to the location</span></a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>

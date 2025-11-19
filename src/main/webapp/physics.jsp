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
    <title>College of Physics and Electronic Information Engineering</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;box-shadow:0 1px 2px rgba(0,0,0,.04);padding:24px}
        .page-title{margin:0;font-size:1.5rem;font-weight:600}
        .page-sub{color:#6b7280;margin-top:4px}
        .dept-hero{margin:8px 0 16px 0}
        .dept-hero img{display:block;max-inline-size:100%;height:auto;border-radius:12px;border:1px solid #e5e7eb;box-shadow:0 1px 2px rgba(0,0,0,.04)}
        .teacher-list{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:12px;margin-top:8px}
        .teacher{border:1px solid #e5e7eb;border-radius:10px;padding:12px;background:#fff}
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
                <h2 class="page-title">🏫 College of Physics and Electronic Information Engineering</h2>
                <div class="page-sub">Contacts and information for the Physics and EIE college.</div>
            </div>
        </div>

        <div class="card">
            <div class="dept-hero">
                <img src="colleges%20teacher%20images/College%20of%20Physics.JPG" alt="College of Physics and Electronic Information Engineering" loading="lazy" />
            </div>
            <div class="teacher-list">
                <div class="teacher" data-teacher="蒙晓云 MENG XIAO YUAN">
                    <div class="kv"><b>TEACHER NAME</b><span>蒙晓云 MENG XIAO YUAN</span></div>
                    <div class="kv"><b>Address</b><span>Building 20, Room 311</span></div>
                    <div class="kv"><b>Phone</b><span><a href="tel:+8657982298268">0579–82298268</a></span></div>
                </div>
            </div>
            <div class="card-footer">
                <div class="actions-bar">
                    <a href="colleges-info.jsp" class="btn btn-outline btn-icon">← <span>Back</span></a>
                    <a href="https://j.map.baidu.com/29/8FPk" target="_blank" rel="noopener noreferrer" class="btn btn-primary btn-icon">📍 <span>Go to the location</span></a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>

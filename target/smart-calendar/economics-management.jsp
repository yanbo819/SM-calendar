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
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "college.economics.title") %></title>
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
            <h1 class="nav-title"><a href="dashboard"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "app.title") %></a></h1>
            <div class="nav-actions">
                <span class="user-welcome"><%= user != null ? com.smartcalendar.utils.LanguageUtil.getText(lang, "dashboard.welcome")+", "+ user.getFullName()+"!" : com.smartcalendar.utils.LanguageUtil.getText(lang, "dashboard.welcome") %></span>
            </div>
        </div>
    </nav>

    <div class="form-container">
        <div class="form-header">
            <div>
                <h2 class="page-title">🏫 <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "college.economics.title") %></h2>
                <div class="page-sub"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "college.economics.subtitle") %></div>
            </div>
        </div>

        <div class="card">
            <div class="teacher-list">
                <div class="teacher" data-teacher="魏旋 WEI XUAN">
                    <img src="colleges%20teacher%20images/1-Economics%20and%20Management.JPG" alt="魏旋 WEI XUAN" loading="lazy" />
                    <div class="kv"><b><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.teacher.name") %></b><span>魏旋 WEI XUAN</span></div>
                    <div class="kv"><b><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.address") %></b><span>Building 27, Room 117</span></div>
                    <div class="kv"><b><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.phone") %></b><span><a href="tel:+8657982298526">0579-82298526</a></span></div>
                </div>
                <div class="teacher" data-teacher="傅菲 FU FEI">
                    <img src="colleges%20teacher%20images/2-Economics%20and%20Management.PNG" alt="傅菲 FU FEI" loading="lazy" />
                    <div class="kv"><b><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.teacher.name") %></b><span>傅菲 FU FEI</span></div>
                    <div class="kv"><b><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.address") %></b><span>Building 27, Room 117</span></div>
                    <div class="kv"><b><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.phone") %></b><span><a href="tel:+8657982298526">0579-82298526</a></span></div>
                </div>
            </div>
            <div class="card-footer">
                <div class="actions-bar">
                    <a href="colleges-info.jsp" class="btn btn-outline btn-icon">← <span><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.back") %></span></a>
                    <a href="https://surl.amap.com/2vSlOR33Z35t" target="_blank" rel="noopener noreferrer" class="btn btn-primary btn-icon">📍 <span><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.goLocation") %></span></a>
                </div>
            </div>
        </div>
    </div>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>

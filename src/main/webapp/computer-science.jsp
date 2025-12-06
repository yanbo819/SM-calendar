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
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "college.compsci.title") %></title>
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
            <h1 class="nav-title"><a href="dashboard"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "app.title") %></a></h1>
            <div class="nav-actions">
                <span class="user-welcome"><%= user != null ? com.smartcalendar.utils.LanguageUtil.getText(lang, "dashboard.welcome")+", "+ user.getFullName()+"!" : com.smartcalendar.utils.LanguageUtil.getText(lang, "dashboard.welcome") %></span>
            </div>
        </div>
    </nav>

    <div class="form-container">
        <div class="form-header">
            <div>
                <h2 class="page-title">🏫 <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "college.compsci.title") %></h2>
                <div class="page-sub"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "college.compsci.subtitle") %></div>
            </div>
        </div>

        <div class="card">
            <div class="dept-hero">
                <img src="colleges%20teacher%20images/Computer%20Science.JPG" alt="College of Computer Science and Technology" loading="lazy" />
            </div>
            <div class="teacher-list">
                <div class="teacher" data-teacher="彭景云 PENG JING YUN (BARRY)">
                    <div class="kv"><b><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.teacher.name") %></b><span>彭景云 PENG JING YUN (BARRY)</span></div>
                    <div class="kv"><b><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.address") %></b><span>Building 17, Room 423</span></div>
                    <div class="kv"><b><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.colleges.phone") %></b><span><a href="tel:+8657982281931">0579–8 2281931</a></span></div>
                </div>
            </div>
            <div class="card-footer">
                <div class="actions-bar">
                    <a href="colleges-info.jsp" class="btn btn-outline btn-icon">← <span><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.back") %></span></a>
                    <a href="https://map.wap.qq.com/online/h5-map-share/line.html?type=drive&cond=0&startLat=29.131843&startLng=119.638342&endLat=29.131890&endLng=119.638333&key=%E6%88%91%E7%9A%84%E4%BD%8D%E7%BD%AE%7C%7C%E6%B5%99%E6%B1%9F%E5%B8%88%E8%8C%83%E5%A4%A7%E5%AD%A6" class="btn btn-primary btn-icon" target="_blank" rel="noopener noreferrer">📍 <span><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.goLocation") %></span></a>
                </div>
            </div>
        </div>
    </div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>

<%@ page isErrorPage="true" contentType="text/html; charset=UTF-8" %>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<%@ page import="com.smartcalendar.utils.LanguageUtil" %>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <title><%= LanguageUtil.getText(lang, "app.title") %> - Not Found</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .nf-wrap{max-width:560px;margin:90px auto;padding:38px 30px;background:#fff;border:1px solid #e2e8f0;border-radius:20px;box-shadow:0 8px 22px -4px rgba(0,0,0,.12);text-align:center;font-family:system-ui,-apple-system,Segoe UI,Roboto}
        .nf-code{font-size:3.2rem;font-weight:700;margin:0;color:#6366f1}
        .nf-msg{font-size:.95rem;color:#374151;margin:10px 0 20px}
        .nf-actions a{display:inline-block;margin:0 8px;padding:10px 18px;font-size:.82rem;border-radius:10px;text-decoration:none;font-weight:600}
        .btn-home{background:#2563eb;color:#fff}
        .btn-login{background:#f1f5f9;color:#1f2937;border:1px solid #d1d5db}
    </style>
</head>
<body>
    <div class="nf-wrap">
        <div class="nf-code">404</div>
        <p class="nf-msg">The page you requested was not found.</p>
        <div class="nf-actions">
            <a href="cst-team" class="btn-home">Go Home</a>
            <a href="login.jsp" class="btn-login">Sign In</a>
        </div>
    </div>
</body>
</html>
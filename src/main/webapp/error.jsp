<%@ page isErrorPage="true" contentType="text/html; charset=UTF-8" %>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<%@ page import="com.smartcalendar.utils.LanguageUtil" %>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <title><%= LanguageUtil.getText(lang, "app.title") %> - Error</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .error-wrap{max-width:600px;margin:80px auto;padding:40px 34px;background:#fff;border:1px solid #e5e7eb;border-radius:18px;box-shadow:0 10px 28px -6px rgba(0,0,0,.12);text-align:center;font-family:system-ui,-apple-system,Segoe UI,Roboto}
        .error-code{font-size:3.5rem;font-weight:700;letter-spacing:2px;margin:0;color:#dc2626}
        .error-msg{font-size:1rem;color:#374151;margin:8px 0 22px}
        .error-actions a{display:inline-block;margin:0 8px;padding:10px 18px;font-size:.85rem;border-radius:10px;text-decoration:none;font-weight:600}
        .btn-home{background:#2563eb;color:#fff}
        .btn-login{background:#f1f5f9;color:#1f2937;border:1px solid #d1d5db}
    </style>
</head>
<body>
    <div class="error-wrap">
        <div class="error-code">500</div>
        <p class="error-msg">An unexpected error occurred.</p>
        <% if (exception != null) { %>
            <details style="text-align:left;font-size:.75rem;color:#6b7280;max-height:160px;overflow:auto;margin-bottom:18px">
                <summary style="cursor:pointer">Details</summary>
                <pre style="white-space:pre-wrap"><%= org.apache.commons.lang3.exception.ExceptionUtils.getStackTrace(exception) %></pre>
            </details>
        <% } %>
        <div class="error-actions">
            <a href="cst-team" class="btn-home">Go Home</a>
            <a href="login.jsp" class="btn-login">Sign In</a>
        </div>
    </div>
</body>
</html>
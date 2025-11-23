<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%
  String lang = "en";
  String dir = "ltr";
  try {
    if (session != null) {
      String sessionLang = (String) session.getAttribute("lang");
      if (sessionLang != null) lang = sessionLang;
    }
    if ("ar".equals(lang)) dir = "rtl";
  } catch (Exception e) {
    // Fallback to defaults
  }
  
  // Simple text lookup without LanguageUtil dependency
  String title = "Page Not Found";
  String heading = "Page Not Found";
  String message = "The page you requested could not be found.";
  String home = "Go Home";
  String or = "or";
  String signin = "Sign In";
  String hint = "Check the URL and try again.";
  
  if ("ar".equals(lang)) {
    title = "الصفحة غير موجودة";
    heading = "الصفحة غير موجودة";
    message = "الصفحة التي طلبتها غير موجودة.";
    home = "الصفحة الرئيسية";
    or = "أو";
    signin = "تسجيل الدخول";
    hint = "تحقق من عنوان URL وحاول مرة أخرى.";
  } else if ("fr".equals(lang)) {
    title = "Page non trouvée";
    heading = "Page non trouvée";
    message = "La page que vous avez demandée est introuvable.";
    home = "Accueil";
    or = "ou";
    signin = "Se connecter";
    hint = "Vérifiez l'URL et réessayez.";
  } else if ("zh".equals(lang)) {
    title = "页面未找到";
    heading = "页面未找到";
    message = "您请求的页面未找到。";
    home = "主页";
    or = "或";
    signin = "登录";
    hint = "检查网址并重试。";
  }
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= dir %>">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title><%= title %></title>
  <style>
    body{font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica,Arial,sans-serif;margin:0;display:grid;place-items:center;min-block-size:100vh;background:#0e1014;color:#eaeef4}
    .card{background:#141821;border:1px solid #232634;border-radius:16px;padding:32px;max-inline-size:520px;box-shadow:0 10px 30px rgba(0,0,0,.3)}
    h1{font-size:28px;margin:0 0 12px}
    p{color:#94a3b8;margin:0 0 16px;line-height:1.5}
    a{color:#60a5fa;text-decoration:none}
    .hint{font-size:13px;color:#8b949e}
  </style>
</head>
<body>
  <div class="card">
     <h1>404 — <%= heading %></h1>
     <p><%= message %></p>
     <p><a href="/smart-calendar/"><%= home %></a> 
       <%= or %> 
       <a href="/smart-calendar/login.jsp"><%= signin %></a>.</p>
     <p class="hint"><%= hint %></p>
  </div>
</body>
</html>

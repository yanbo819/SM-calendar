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
  String title = "Internal Server Error";
  String heading = "Internal Server Error";
  String message = "An unexpected error occurred.";
  String home = "Go Home";
  String or = "or";
  String signin = "Sign In";
  String hint = "If this problem persists, please contact support.";
  
  if ("ar".equals(lang)) {
    title = "خطأ داخلي في الخادم";
    heading = "خطأ داخلي في الخادم";
    message = "حدث خطأ غير متوقع.";
    home = "الصفحة الرئيسية";
    or = "أو";
    signin = "تسجيل الدخول";
    hint = "إذا استمرت هذه المشكلة، يرجى الاتصال بالدعم.";
  } else if ("fr".equals(lang)) {
    title = "Erreur interne du serveur";
    heading = "Erreur interne du serveur";
    message = "Une erreur inattendue s'est produite.";
    home = "Accueil";
    or = "ou";
    signin = "Se connecter";
    hint = "Si ce problème persiste, veuillez contacter le support.";
  } else if ("zh".equals(lang)) {
    title = "内部服务器错误";
    heading = "内部服务器错误";
    message = "发生了意外错误。";
    home = "主页";
    or = "或";
    signin = "登录";
    hint = "如果此问题仍然存在，请联系支持。";
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
     <h1>500 — <%= heading %></h1>
     <p><%= message %></p>
     <p><a href="/smart-calendar/"><%= home %></a> 
       <%= or %> 
       <a href="/smart-calendar/login.jsp"><%= signin %></a>.</p>
     <p class="hint"><%= hint %></p>
  </div>
</body>
</html>

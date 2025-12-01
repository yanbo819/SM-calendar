<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.utils.LanguageUtil" %>
<%
    String lang = request.getParameter("lang");
    if (lang == null) {
        lang = (String) session.getAttribute("userLanguage");
    }
    if (lang == null || !LanguageUtil.isSupportedLanguage(lang)) {
        lang = "en";
    }
    session.setAttribute("userLanguage", lang);
    
    String textDir = LanguageUtil.getTextDirection(lang);
    String errorMessage = (String) request.getAttribute("errorMessage");
    String email = (String) request.getAttribute("email");
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= LanguageUtil.getText(lang, "app.title") %> - <%= LanguageUtil.getText(lang, "login.title") %></title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/auth.css">
    <% if ("ar".equals(lang)) { %>
    <!-- rtl.css removed: English-only UI -->
    <% } %>
    <style>
        .demo-credentials {
            background: linear-gradient(135deg, #e3f2fd, #f3e5f5);
            border: 1px solid #90caf9;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 20px;
            text-align: center;
        }
        .demo-credentials h4 {
            margin: 0 0 10px 0;
            color: #1976d2;
            font-size: 14px;
        }
        .demo-credentials p {
            margin: 5px 0;
            font-size: 13px;
            color: #424242;
        }
        .demo-credentials strong {
            color: #d32f2f;
            font-family: monospace;
        }
    </style>
</head>
<body class="auth-page">
    <div class="auth-container">
        <div class="auth-header">
            <h1><%= LanguageUtil.getText(lang, "app.title") %></h1>
            <div class="language-selector">
                <select id="languageSelect" onchange="changeLanguage()">
                    <option value="en" <%= "en".equals(lang) ? "selected" : "" %>><%= LanguageUtil.getText(lang, "language.english") %></option>
                    <option value="ar" <%= "ar".equals(lang) ? "selected" : "" %>><%= LanguageUtil.getText(lang, "language.arabic") %></option>
                    <option value="zh" <%= "zh".equals(lang) ? "selected" : "" %>><%= LanguageUtil.getText(lang, "language.chinese") %></option>
                </select>
            </div>
        </div>

        <div class="auth-form-container">
            <h2><%= LanguageUtil.getText(lang, "login.title") %></h2>
            
            <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                <%= errorMessage %>
            </div>
            <% } %>

            <form method="post" action="login" class="auth-form">
                <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" required 
                           value="admin" 
                           placeholder="Enter username">
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" required 
                           value="admin"
                           placeholder="Enter password">
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary btn-full">
                        <%= LanguageUtil.getText(lang, "login.submit") %>
                    </button>
                </div>
            </form>

            <div class="auth-links">
                <p>
                    <a href="forgot-password.jsp?lang=<%= lang %>">
                        <%= LanguageUtil.getText(lang, "login.forgot_password") %>
                    </a>
                </p>
                <p>
                    <%= LanguageUtil.getText(lang, "login.no_account") %>
                    <a href="register.jsp?lang=<%= lang %>">
                        <%= LanguageUtil.getText(lang, "login.register_here") %>
                    </a>
                </p>
            </div>
        </div>
    </div>

    <script>
        function changeLanguage() {
            const lang = document.getElementById('languageSelect').value;
            window.location.href = 'login.jsp?lang=' + lang;
        }

        // Focus on username field when page loads
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('username').focus();
        });
    </script>
</body>
</html>
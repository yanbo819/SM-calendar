<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.utils.LanguageUtil" %>
<%
    // LanguageFilter sets request attributes 'lang' and 'textDir'; fall back gracefully if absent
    String lang = (String) request.getAttribute("lang");
    if (lang == null) {
        lang = (String) session.getAttribute("lang");
        if (lang == null || !LanguageUtil.isSupportedLanguage(lang)) lang = "en";
    }
    String textDir = (String) request.getAttribute("textDir");
    if (textDir == null) textDir = LanguageUtil.getTextDirection(lang);
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= LanguageUtil.getText(lang, "app.title") %> - <%= LanguageUtil.getText(lang, "login.title") %></title>
    <link rel="stylesheet" href="css/modern-auth.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
</head>
<body class="modern-auth-page">
    

    <!-- Background Animation -->
    <div class="animated-background">
        <div class="gradient-orb orb-1"></div>
        <div class="gradient-orb orb-2"></div>
        <div class="gradient-orb orb-3"></div>
    </div>

    <!-- Main Login Container -->
    <!-- Language Switcher removed as requested -->
    <div class="modern-auth-container">
        <div class="auth-card">
            <!-- Brand Section -->
            <div class="auth-brand">
                <div class="brand-logo">
                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                        <line x1="16" y1="2" x2="16" y2="6"></line>
                        <line x1="8" y1="2" x2="8" y2="6"></line>
                        <line x1="3" y1="10" x2="21" y2="10"></line>
                    </svg>
                </div>
                <h1 class="brand-title"><%= LanguageUtil.getText(lang, "app.title") %></h1>
                <p class="brand-subtitle"><%= LanguageUtil.getText(lang, "login.subtitle") %></p>
            </div>

            <!-- Error Message -->
            <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="10"></circle>
                    <line x1="15" y1="9" x2="9" y2="15"></line>
                    <line x1="9" y1="9" x2="15" y2="15"></line>
                </svg>
                <%= errorMessage %>
            </div>
            <% } %>

            <!-- Portal Toggle -->
            <div class="form-group" style="display:flex;gap:8px;justify-content:center;margin-bottom:12px;">
                <button type="button" id="userPortalBtn" class="login-btn" style="inline-size:50%;background:var(--gray-100);color:var(--gray-700);" onclick="setPortal('user')"><%= LanguageUtil.getText(lang, "login.user") %></button>
                <button type="button" id="adminPortalBtn" class="login-btn" style="inline-size:50%;background:linear-gradient(135deg, #9ca3af, #6b7280);" onclick="setPortal('admin')"><%= LanguageUtil.getText(lang, "login.admin") %></button>
            </div>

            <!-- Login Form -->
            <form method="post" action="login" class="modern-auth-form">
                <input type="hidden" id="portalField" name="portal" value="<%= request.getAttribute("portal") != null ? (String)request.getAttribute("portal") : (request.getParameter("portal") != null ? request.getParameter("portal") : "user") %>">
                <div class="form-group">
                    <div class="input-container">
                        <svg class="input-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                            <circle cx="12" cy="7" r="4"></circle>
                        </svg>
                           <input type="text" id="username" name="username" class="form-input" 
                               placeholder="<%= LanguageUtil.getText(lang, "login.username") %>" required autocomplete="username">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-container">
                        <svg class="input-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                            <circle cx="12" cy="16" r="1"></circle>
                            <path d="m7 11V7a5 5 0 0 1 10 0v4"></path>
                        </svg>
                           <input type="password" id="password" name="password" class="form-input" 
                               placeholder="<%= LanguageUtil.getText(lang, "login.password") %>" required autocomplete="current-password">
                        <button type="button" class="password-toggle" onclick="togglePasswordVisibility()">
                            <svg id="eyeIcon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                <circle cx="12" cy="12" r="3"></circle>
                            </svg>
                        </button>
                    </div>
                </div>

                <button type="submit" class="login-btn" id="submitBtn">
                    <span id="submitText"><%= LanguageUtil.getText(lang, "login.signin") %></span>
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M9 18l6-6-6-6"></path>
                    </svg>
                </button>
            </form>

            <!-- Auth Links -->
            <div class="auth-links">
                <div class="link-row">
                    <a href="register.jsp?lang=<%= lang %>" class="auth-link register-link" id="registerLink">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>
                            <circle cx="9" cy="7" r="4"></circle>
                            <path d="m19 8 2 2-2 2"></path>
                            <path d="m21 10-7.5 0"></path>
                        </svg>
                        <%= LanguageUtil.getText(lang, "login.noaccount") %> <strong><%= LanguageUtil.getText(lang, "login.createaccount") %></strong>
                    </a>
                </div>
                
                <div class="link-row">
                    <a href="forgot-password.jsp?lang=<%= lang %>" class="auth-link forgot-link">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 12l2 2 4-4"></path>
                            <path d="M21 12c-1 0-3-1-3-3s2-3 3-3 3 1 3 3-2 3-3 3"></path>
                            <path d="M3 12c1 0 3-1 3-3s-2-3-3-3-3 1-3 3 2 3 3 3"></path>
                            <path d="M12 3v6m0 6v6"></path>
                        </svg>
                        <%= LanguageUtil.getText(lang, "login.forgot") %> <strong><%= LanguageUtil.getText(lang, "login.reset") %></strong>
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Portal toggle logic
        const portalField = document.getElementById('portalField');
        const userPortalBtn = document.getElementById('userPortalBtn');
        const adminPortalBtn = document.getElementById('adminPortalBtn');
        const registerLink = document.getElementById('registerLink');
        const submitText = document.getElementById('submitText');

        function setPortal(p) {
            portalField.value = p;
            if (p === 'admin') {
                adminPortalBtn.style.background = 'linear-gradient(135deg, #6366f1, #5855eb)';
                adminPortalBtn.style.color = '#fff';
                userPortalBtn.style.background = 'var(--gray-100)';
                userPortalBtn.style.color = 'var(--gray-700)';
                if (registerLink) registerLink.style.display = 'none';
                submitText.textContent = 'Sign In (Admin)';
            } else {
                userPortalBtn.style.background = 'linear-gradient(135deg, var(--primary-color), var(--primary-hover))';
                userPortalBtn.style.color = '#fff';
                adminPortalBtn.style.background = 'var(--gray-100)';
                adminPortalBtn.style.color = 'var(--gray-700)';
                if (registerLink) registerLink.style.display = '';
                submitText.textContent = 'Sign In';
            }
        }

        // Initialize portal from server state or default
        (function(){
            const initPortal = portalField && portalField.value ? portalField.value : 'user';
            setPortal(initPortal);
        })();
        function togglePasswordVisibility() {
            const passwordInput = document.getElementById('password');
            const eyeIcon = document.getElementById('eyeIcon');
            
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                eyeIcon.innerHTML = `
                    <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                    <line x1="1" y1="1" x2="23" y2="23"></line>
                `;
            } else {
                passwordInput.type = 'password';
                eyeIcon.innerHTML = `
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                    <circle cx="12" cy="12" r="3"></circle>
                `;
            }
        }

        // Demo credentials auto-fill (optional)
        
    </script>
</body>
</html>
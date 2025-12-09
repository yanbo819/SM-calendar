<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.utils.LanguageUtil" %>
<%
    String lang = "en";
    session.setAttribute("userLanguage", lang);
    String textDir = "ltr";
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    String step = request.getParameter("step");
    if (step == null) step = "1";
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%@ include file="/WEB-INF/jspf/app-brand.jspf" %>
    <title><%= (String)request.getAttribute("appName") %> - Reset Password</title>
    <link rel="stylesheet" href="css/modern-auth.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        .step-indicator {
            display: flex;
            justify-content: center;
            align-items: center;
            margin-bottom: var(--space-6);
            gap: var(--space-4);
        }
        .step {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: var(--gray-200);
            color: var(--gray-500);
            font-weight: 600;
            font-size: var(--font-size-sm);
            position: relative;
        }
        .step.active {
            background: var(--primary-color);
            color: white;
        }
        .step.completed {
            background: var(--success-color);
            color: white;
        }
        .step-connector {
            width: 40px;
            height: 2px;
            background: var(--gray-200);
        }
        .step-connector.completed {
            background: var(--success-color);
        }
        .verification-code-input {
            display: flex;
            justify-content: center;
            gap: var(--space-2);
            margin: var(--space-4) 0;
        }
        .code-digit {
            width: 50px;
            height: 50px;
            text-align: center;
            border: 2px solid var(--gray-200);
            border-radius: var(--radius-lg);
            font-size: var(--font-size-lg);
            font-weight: 600;
            background: white;
        }
        .code-digit:focus {
            border-color: var(--primary-color);
            outline: none;
        }
        .form-step {
            display: none;
        }
        .form-step.active {
            display: block;
        }
    </style>
</head>
<body class="modern-auth-page">
    

    <!-- Background Animation -->
    <div class="animated-background">
        <div class="gradient-orb orb-1"></div>
        <div class="gradient-orb orb-2"></div>
        <div class="gradient-orb orb-3"></div>
    </div>

    <!-- Main Password Recovery Container -->
    <div class="modern-auth-container">
        <div class="auth-card">
            <!-- Brand Section -->
            <div class="auth-brand">
                <div class="brand-logo" style="display:flex;align-items:center;justify-content:center;background:transparent;box-shadow:none;width:auto;height:auto;margin-bottom:var(--space-2);">
                    <img src="images/logo-health.svg" alt="App Logo" width="168" height="168" loading="eager" decoding="async" />
                </div>
                <h1 class="brand-title">Reset Password</h1>
                <p class="brand-subtitle">Don't worry! We'll help you reset your password securely.</p>
            </div>

            <!-- Step Indicator -->
            <div class="step-indicator">
                <div class="step <%= "1".equals(step) ? "active" : ("2".equals(step) || "3".equals(step)) ? "completed" : "" %>" id="step1">1</div>
                <div class="step-connector <%= ("2".equals(step) || "3".equals(step)) ? "completed" : "" %>"></div>
                <div class="step <%= "2".equals(step) ? "active" : "3".equals(step) ? "completed" : "" %>" id="step2">2</div>
                <div class="step-connector <%= "3".equals(step) ? "completed" : "" %>"></div>
                <div class="step <%= "3".equals(step) ? "active" : "" %>" id="step3">3</div>
            </div>

            <!-- Messages -->
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

            <% if (successMessage != null) { %>
            <div class="alert alert-success">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M9 12l2 2 4-4"></path>
                    <circle cx="12" cy="12" r="10"></circle>
                </svg>
                <%= successMessage %>
            </div>
            <% } %>

            <!-- Step 1: Account Verification -->
            <div class="form-step <%= "1".equals(step) ? "active" : "" %>" id="formStep1">
                <form method="post" action="forgot-password" class="modern-auth-form">
                    <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
                    <input type="hidden" name="step" value="1">
                    
                    <div class="form-group">
                        <div class="input-container">
                            <svg class="input-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                            <input type="text" id="username" name="username" class="form-input" 
                                   placeholder="Username" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="input-container">
                            <svg class="input-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
                                <polyline points="22,6 12,13 2,6"></polyline>
                            </svg>
                            <input type="text" id="contact" name="contact" class="form-input" 
                                   placeholder="Enter your email or mobile number" required>
                        </div>
                        <small style="color: var(--gray-500); font-size: var(--font-size-xs); margin-top: var(--space-1);">
                            We'll send a verification code to this email or mobile number.
                        </small>
                    </div>

                    <button type="submit" class="login-btn">
                        <span>Send Verification Code</span>
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6"></path>
                        </svg>
                    </button>
                </form>
            </div>

            <!-- Step 2: Code Verification -->
            <div class="form-step <%= "2".equals(step) ? "active" : "" %>" id="formStep2">
                <form method="post" action="forgot-password" class="modern-auth-form">
                    <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
                    <input type="hidden" name="step" value="2">
                    <input type="hidden" name="username" value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>">
                    <input type="hidden" name="contact" value="<%= request.getParameter("contact") != null ? request.getParameter("contact") : "" %>">
                    
                    <div style="text-align: center; margin-bottom: var(--space-6);">
                        <h3 style="color: var(--gray-700); margin-bottom: var(--space-2);">Enter Verification Code</h3>
                        <p style="color: var(--gray-500); font-size: var(--font-size-sm);">
                            We sent a 6-digit code to your contact method.
                        </p>
                    </div>

                    <div class="verification-code-input">
                        <input type="text" class="code-digit" maxlength="1" name="digit1" onkeyup="moveToNext(this, 'digit2')" onkeydown="moveToPrev(this, null)">
                        <input type="text" class="code-digit" maxlength="1" name="digit2" onkeyup="moveToNext(this, 'digit3')" onkeydown="moveToPrev(this, 'digit1')">
                        <input type="text" class="code-digit" maxlength="1" name="digit3" onkeyup="moveToNext(this, 'digit4')" onkeydown="moveToPrev(this, 'digit2')">
                        <input type="text" class="code-digit" maxlength="1" name="digit4" onkeyup="moveToNext(this, 'digit5')" onkeydown="moveToPrev(this, 'digit3')">
                        <input type="text" class="code-digit" maxlength="1" name="digit5" onkeyup="moveToNext(this, 'digit6')" onkeydown="moveToPrev(this, 'digit4')">
                        <input type="text" class="code-digit" maxlength="1" name="digit6" onkeyup="moveToNext(this, null)" onkeydown="moveToPrev(this, 'digit5')">
                    </div>

                    <button type="submit" class="login-btn">
                        <span>Verify Code</span>
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6"></path>
                        </svg>
                    </button>

                    <div style="text-align: center; margin-top: var(--space-4);">
                        <a href="forgot-password.jsp?step=1&lang=<%= lang %>" style="color: var(--primary-color); text-decoration: none; font-size: var(--font-size-sm);">
                            Didn't receive the code? Try again
                        </a>
                    </div>
                </form>
            </div>

            <!-- Step 3: New Password -->
            <div class="form-step <%= "3".equals(step) ? "active" : "" %>" id="formStep3">
                <form method="post" action="forgot-password" class="modern-auth-form" onsubmit="return validateNewPassword()">
                    <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
                    <input type="hidden" name="step" value="3">
                    <input type="hidden" name="username" value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>">
                    <input type="hidden" name="verificationCode" value="<%= request.getParameter("verificationCode") != null ? request.getParameter("verificationCode") : "" %>">
                    
                    <div style="text-align: center; margin-bottom: var(--space-6);">
                        <h3 style="color: var(--gray-700); margin-bottom: var(--space-2);">Create New Password</h3>
                        <p style="color: var(--gray-500); font-size: var(--font-size-sm);">
                            Enter a strong new password for your account.
                        </p>
                    </div>

                    <div class="form-group">
                        <div class="input-container">
                            <svg class="input-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                <circle cx="12" cy="16" r="1"></circle>
                                <path d="m7 11V7a5 5 0 0 1 10 0v4"></path>
                            </svg>
                            <input type="password" id="newPassword" name="newPassword" class="form-input" 
                                   placeholder="New Password" required minlength="6">
                            <button type="button" class="password-toggle" onclick="togglePassword('newPassword')">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                    <circle cx="12" cy="12" r="3"></circle>
                                </svg>
                            </button>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="input-container">
                            <svg class="input-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                <circle cx="12" cy="16" r="1"></circle>
                                <path d="m7 11V7a5 5 0 0 1 10 0v4"></path>
                            </svg>
                            <input type="password" id="confirmNewPassword" name="confirmNewPassword" class="form-input" 
                                   placeholder="Confirm New Password" required>
                            <button type="button" class="password-toggle" onclick="togglePassword('confirmNewPassword')">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                    <circle cx="12" cy="12" r="3"></circle>
                                </svg>
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="login-btn">
                        <span>Reset Password</span>
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 12l2 2 4-4"></path>
                        </svg>
                    </button>
                </form>
            </div>

            <!-- Auth Links -->
            <div class="auth-links">
                <div class="link-row">
                    <a href="login.jsp" class="auth-link">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                            <polyline points="16,17 21,12 16,7"></polyline>
                            <line x1="21" y1="12" x2="9" y2="12"></line>
                        </svg>
                        Remember your password? <strong>Back to Sign In</strong>
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script>
        function toggleLanguageDropdown() {
            const menu = document.getElementById('languageMenu');
            menu.classList.toggle('active');
        }

        function togglePassword(inputId) {
            const input = document.getElementById(inputId);
            const button = input.nextElementSibling;
            const svg = button.querySelector('svg');
            
            if (input.type === 'password') {
                input.type = 'text';
                svg.innerHTML = `
                    <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                    <line x1="1" y1="1" x2="23" y2="23"></line>
                `;
            } else {
                input.type = 'password';
                svg.innerHTML = `
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                    <circle cx="12" cy="12" r="3"></circle>
                `;
            }
        }

        function moveToNext(current, nextFieldName) {
            if (current.value.length === 1 && nextFieldName) {
                document.getElementsByName(nextFieldName)[0].focus();
            }
        }

        function moveToPrev(current, prevFieldName) {
            if (event.key === 'Backspace' && current.value.length === 0 && prevFieldName) {
                document.getElementsByName(prevFieldName)[0].focus();
            }
        }

        function validateNewPassword() {
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmNewPassword').value;
            
            if (newPassword !== confirmPassword) {
                alert('Passwords do not match. Please check your entries.');
                return false;
            }
            
            if (newPassword.length < 6) {
                alert('Password must be at least 6 characters long.');
                return false;
            }
            
            return true;
        }

        // Close language dropdown when clicking outside
        document.addEventListener('click', function(event) {
            const dropdown = document.querySelector('.language-dropdown');
            const menu = document.getElementById('languageMenu');
            
            if (!dropdown.contains(event.target)) {
                menu.classList.remove('active');
            }
        });

        // Auto-focus first input on page load
        document.addEventListener('DOMContentLoaded', function() {
            const activeStep = document.querySelector('.form-step.active');
            if (activeStep) {
                const firstInput = activeStep.querySelector('input[type="text"], input[type="password"]');
                if (firstInput) {
                    firstInput.focus();
                }
            }
        });
    </script>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>
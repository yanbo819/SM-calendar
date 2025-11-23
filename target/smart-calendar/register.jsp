<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.utils.LanguageUtil" %>
<%
    String lang = "en";
    session.setAttribute("userLanguage", lang);
    String textDir = "ltr";
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= LanguageUtil.getText(lang, "app.title") %> - Create Account</title>
    <link rel="stylesheet" href="css/modern-auth.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        .register-form-container {
            display: flex;
            flex-direction: column;
            gap: var(--space-5);
        }
        .register-form-container .form-group {
            width: 100%;
        }
        .register-form-container .form-input {
            width: 100%;
            min-height: 52px;
            padding: var(--space-4) var(--space-4) var(--space-4) 3.2rem;
            font-size: var(--font-size-base);
        }
        .register-form-container .input-container {
            position: relative;
            width: 100%;
        }
        .strength-meter {
            margin-top: var(--space-2);
            height: 4px;
            background: var(--gray-200);
            border-radius: 2px;
            overflow: hidden;
        }
        .strength-fill {
            height: 100%;
            transition: all 0.3s ease;
            border-radius: 2px;
        }
        .strength-text {
            font-size: var(--font-size-xs);
            margin-top: var(--space-1);
            font-weight: 500;
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

    <!-- Main Registration Container -->
    <div class="modern-auth-container">
        <div class="auth-card">
            <!-- Brand Section -->
            <div class="auth-brand">
                <div class="brand-logo">
                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>
                        <circle cx="9" cy="7" r="4"></circle>
                        <path d="m19 8 2 2-2 2"></path>
                        <path d="m21 10-7.5 0"></path>
                    </svg>
                </div>
                <h1 class="brand-title">Create Account</h1>
                <p class="brand-subtitle">Join us today! Fill in the details below to get started.</p>
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

            <!-- Registration Form -->
            <form method="post" action="register" class="modern-auth-form" onsubmit="return validateRegistrationForm()">
                <div class="register-form-container">
                    <!-- Full Name -->
                    <div class="form-group">
                        <div class="input-container">
                            <svg class="input-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                            <input type="text" id="fullName" name="fullName" class="form-input" 
                                   placeholder="Full Name" required>
                        </div>
                    </div>

                    <!-- Username -->
                    <div class="form-group">
                        <div class="input-container">
                            <svg class="input-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M16 7a4 4 0 1 1-8 0 4 4 0 0 1 8 0ZM12 14a7 7 0 0 0-7 7h14a7 7 0 0 0-7-7Z"></path>
                            </svg>
                            <input type="text" id="username" name="username" class="form-input" 
                                   placeholder="Username" required>
                        </div>
                    </div>

                    <!-- Email -->
                    <div class="form-group">
                        <div class="input-container">
                            <svg class="input-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
                                <polyline points="22,6 12,13 2,6"></polyline>
                            </svg>
                            <input type="email" id="email" name="email" class="form-input" 
                                   placeholder="Email Address" required>
                        </div>
                    </div>

                    <!-- Mobile Number -->
                    <div class="form-group">
                        <div class="input-container">
                            <svg class="input-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
                            </svg>
                            <input type="tel" id="mobileNumber" name="mobileNumber" class="form-input" 
                                   placeholder="Mobile Number" required>
                        </div>
                    </div>

                    <!-- Password -->
                    <div class="form-group">
                        <div class="input-container">
                            <svg class="input-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                <circle cx="12" cy="16" r="1"></circle>
                                <path d="m7 11V7a5 5 0 0 1 10 0v4"></path>
                            </svg>
                            <input type="password" id="password" name="password" class="form-input" 
                                   placeholder="Password" required minlength="6"
                                   onkeyup="checkPasswordStrength()">
                            <button type="button" class="password-toggle" onclick="togglePassword('password')">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                    <circle cx="12" cy="12" r="3"></circle>
                                </svg>
                            </button>
                        </div>
                        <div class="strength-meter">
                            <div class="strength-fill" id="strengthFill"></div>
                        </div>
                        <div class="strength-text" id="strengthText">Password strength</div>
                    </div>

                    <!-- Confirm Password -->
                    <div class="form-group">
                        <div class="input-container">
                            <svg class="input-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                <circle cx="12" cy="16" r="1"></circle>
                                <path d="m7 11V7a5 5 0 0 1 10 0v4"></path>
                            </svg>
                            <input type="password" id="confirmPassword" name="confirmPassword" class="form-input" 
                                   placeholder="Confirm Password" required
                                   onkeyup="checkPasswordMatch()">
                            <button type="button" class="password-toggle" onclick="togglePassword('confirmPassword')">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                    <circle cx="12" cy="12" r="3"></circle>
                                </svg>
                            </button>
                        </div>
                        <div class="form-text" id="passwordMatch"></div>
                    </div>
                </div>

                <button type="submit" class="login-btn" id="createAccountBtn">
                    <span>Create Account</span>
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M9 18l6-6-6-6"></path>
                    </svg>
                </button>
            </form>

            <!-- Auth Links -->
            <div class="auth-links">
                <div class="link-row">
                    <a href="login.jsp" class="auth-link">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                            <polyline points="16,17 21,12 16,7"></polyline>
                            <line x1="21" y1="12" x2="9" y2="12"></line>
                        </svg>
                        Already have an account? <strong>Sign In</strong>
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script>
        
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

        function checkPasswordStrength() {
            const password = document.getElementById('password').value;
            const strengthFill = document.getElementById('strengthFill');
            const strengthText = document.getElementById('strengthText');
            
            let strength = 0;
            let feedback = [];

            // Length check
            if (password.length >= 8) strength += 25;
            else feedback.push('8+ characters');

            // Uppercase check
            if (/[A-Z]/.test(password)) strength += 25;
            else feedback.push('uppercase letter');

            // Lowercase check
            if (/[a-z]/.test(password)) strength += 25;
            else feedback.push('lowercase letter');

            // Number or special character check
            if (/[\d\W]/.test(password)) strength += 25;
            else feedback.push('number/symbol');

            // Update UI
            strengthFill.style.width = strength + '%';
            
            if (strength < 50) {
                strengthFill.style.background = 'var(--error-color)';
                strengthText.style.color = 'var(--error-color)';
                strengthText.textContent = 'Weak - Add: ' + feedback.join(', ');
            } else if (strength < 75) {
                strengthFill.style.background = 'var(--warning-color)';
                strengthText.style.color = 'var(--warning-color)';
                strengthText.textContent = 'Good - Add: ' + feedback.join(', ');
            } else {
                strengthFill.style.background = 'var(--success-color)';
                strengthText.style.color = 'var(--success-color)';
                strengthText.textContent = 'Strong password!';
            }
        }

        function checkPasswordMatch() {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const matchText = document.getElementById('passwordMatch');
            
            if (confirmPassword === '') {
                matchText.textContent = '';
                return;
            }
            
            if (password === confirmPassword) {
                matchText.textContent = '✓ Passwords match';
                matchText.style.color = 'var(--success-color)';
            } else {
                matchText.textContent = '✗ Passwords do not match';
                matchText.style.color = 'var(--error-color)';
            }
        }

        function validateRegistrationForm() {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (password !== confirmPassword) {
                alert('Passwords do not match. Please check your password entries.');
                return false;
            }
            
            if (password.length < 6) {
                alert('Password must be at least 6 characters long.');
                return false;
            }
            
            return true;
        }

        
    </script>
</body>
</html>
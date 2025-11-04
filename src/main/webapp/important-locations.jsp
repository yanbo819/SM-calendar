<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Important Locations</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .page-title{margin:0;font-size:1.5rem;font-weight:600}
        .page-sub{color:#6b7280;margin-top:4px}
        .card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;box-shadow:0 1px 2px rgba(0,0,0,.04);padding:24px}
        .locations-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:16px}
        .location-card{display:flex;align-items:center;gap:14px;border:1px solid #e5e7eb;border-radius:12px;padding:16px;background:#fff;text-decoration:none;color:inherit;transition:transform .15s ease, box-shadow .15s ease, border-color .15s ease}
        .location-card:hover{transform:translateY(-2px);box-shadow:0 6px 18px rgba(0,0,0,.08);border-color:#d1d5db}
        .location-icon{font-size:1.5rem;line-height:1}
        .location-text h3{margin:0 0 4px 0;font-size:1.05rem;font-weight:600}
        .location-text p{margin:0;color:#6b7280;font-size:.9rem}
    </style>
</head>
<body>
    <nav class="main-nav">
        <div class="nav-container">
            <h1 class="nav-title"><a href="dashboard.jsp">Smart Calendar</a></h1>
            <div class="nav-actions">
                <span class="user-welcome">Welcome, <%= user.getFullName() %>!</span>
                <a href="logout" class="btn btn-outline">Logout</a>
            </div>
        </div>
    </nav>

    <div class="form-container">
        <div class="form-header" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
            <div>
                <h2 class="page-title">Important Locations</h2>
                <div class="page-sub">Quick access to essential places and information around you.</div>
            </div>
            <a href="dashboard.jsp" class="btn btn-outline">← Back to Dashboard</a>
        </div>

        <div class="card">
            <div class="locations-grid">
                <a class="location-card" href="colleges-info.jsp">
                    <span class="location-icon">🏫</span>
                    <div class="location-text">
                        <h3>Colleges Info</h3>
                        <p>Universities, departments, and contacts.</p>
                    </div>
                </a>

                <a class="location-card" href="hospitals-info.jsp">
                    <span class="location-icon">🏥</span>
                    <div class="location-text">
                        <h3>Hospitals Info</h3>
                        <p>Nearby hospitals, clinics, and emergency numbers.</p>
                    </div>
                </a>

                <a class="location-card" href="police-immigration.jsp">
                    <span class="location-icon">🛂</span>
                    <div class="location-text">
                        <h3>Police & Immigration</h3>
                        <p>Police stations, immigration offices, and help lines.</p>
                    </div>
                </a>

                <a class="location-card" href="school-buildings.jsp">
                    <span class="location-icon">🏢</span>
                    <div class="location-text">
                        <h3>School location, Buildings &amp; gates</h3>
                        <p>Campus buildings, classrooms, and facilities.</p>
                    </div>
                </a>

                <a class="location-card" href="restaurants-other.jsp">
                    <span class="location-icon">🍽️</span>
                    <div class="location-text">
                        <h3>Restaurants & Others</h3>
                        <p>Food places and other helpful locations nearby.</p>
                    </div>
                </a>
            </div>
        </div>
    </div>
</body>
</html>

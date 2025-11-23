<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    boolean isAdmin = user.getRole() != null && user.getRole().equalsIgnoreCase("admin");
    if (!isAdmin) { response.sendRedirect("dashboard?error=Not+authorized"); return; }

    String dayParam = request.getParameter("day");
    String startParam = request.getParameter("start");
    String endParam = request.getParameter("end");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Add Face Recognition Window</title>
    <link rel="stylesheet" href="css/main.css" />
    <link rel="stylesheet" href="css/forms.css" />
    <style>
        .page-wrap { max-inline-size: 900px; margin: 16px auto; padding: 0 16px; }
        .card { background:#fff; border:1px solid #e5e7eb; border-radius:12px; box-shadow:0 1px 2px rgba(0,0,0,.04); padding:16px; }
        .page-title { margin:0; font-size:1.25rem; font-weight:600; }
        .page-sub { color:#6b7280; margin-block-start:4px; }
        .form-grid { display:grid; grid-template-columns:1fr; gap:12px; }
        @media (min-width:768px){ .form-grid { grid-template-columns: 1fr 1fr 1fr; } }
        .actions { display:flex; gap:10px; justify-content:center; border-top:1px dashed #e5e7eb; padding-top:16px; margin-top:8px; }
        select, input[type="text"] { inline-size:100%; }
    </style>
    <script>
        function goBack(){ window.location.href = 'admin-face-config'; }
        function validateAndSubmit(form){
            const start = form.start.value.trim();
            const end = form.end.value.trim();
            const pattern = /^[0-2][0-9]:[0-5][0-9]$/;
            if(!pattern.test(start) || !pattern.test(end)) { alert('Time format must be HH:MM'); return false; }
            if(start >= end) { alert('End time must be after start time'); return false; }
            return true;
        }
    </script>
    </head>
<body>
    <!-- Removed top navigation for cleaner standalone admin window creation -->
    <div class="page-wrap">
        <div class="form-header" style="display:flex; align-items:center; justify-content:space-between; gap:12px;">
            <div>
                <h2 class="page-title">Add Face Recognition Window</h2>
                <div class="page-sub">Choose the day and time range when Face Recognition is available.</div>
            </div>
            <!-- Removed top-right Go Back per request; bottom actions retain navigation -->
        </div>

        <form class="card" method="post" action="admin-face-config" onsubmit="return validateAndSubmit(this)">
            <input type="hidden" name="action" value="create" />
            <div class="form-grid">
                <div class="form-group">
                    <label for="dayOfWeek">Day</label>
                    <select id="dayOfWeek" name="dayOfWeek" class="form-control" required>
                        <option value="1" <%= "1".equals(dayParam)?"selected":"" %>>Monday</option>
                        <option value="2" <%= "2".equals(dayParam)?"selected":"" %>>Tuesday</option>
                        <option value="3" <%= "3".equals(dayParam)?"selected":"" %>>Wednesday</option>
                        <option value="4" <%= "4".equals(dayParam)?"selected":"" %>>Thursday</option>
                        <option value="5" <%= "5".equals(dayParam)?"selected":"" %>>Friday</option>
                        <option value="6" <%= "6".equals(dayParam)?"selected":"" %>>Saturday</option>
                        <option value="7" <%= "7".equals(dayParam)?"selected":"" %>>Sunday</option>
                    </select>
                    <div class="form-text">Pick the day of the week.</div>
                </div>
                <div class="form-group">
                    <label for="start">Start time</label>
                    <input id="start" class="form-control" type="text" name="start" placeholder="08:00" value="<%= startParam!=null?startParam:"" %>" required pattern="[0-2][0-9]:[0-5][0-9]" />
                    <div class="form-text">24-hour time, e.g. 08:00</div>
                </div>
                <div class="form-group">
                    <label for="end">End time</label>
                    <input id="end" class="form-control" type="text" name="end" placeholder="12:00" value="<%= endParam!=null?endParam:"" %>" required pattern="[0-2][0-9]:[0-5][0-9]" />
                </div>
            </div>

            <div class="actions" style="justify-content:center">
                <button type="button" class="btn btn-outline" onclick="goBack()" style="min-inline-size:160px">Go Back</button>
                <button type="submit" class="btn btn-primary" style="min-inline-size:160px">Save</button>
            </div>
        </form>
    </div>
</body>
</html>

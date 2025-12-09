<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.models.CstDepartment" %>
<%@ page import="com.smartcalendar.dao.CstDepartmentDao" %>
<%@ page import="com.smartcalendar.dao.CstVolunteerDao" %>
<%@ page import="com.smartcalendar.models.CstVolunteer" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    if (user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) { response.sendRedirect("dashboard"); return; }
    String deptIdStr = request.getParameter("dept");
    int deptId = deptIdStr != null ? Integer.parseInt(deptIdStr) : -1;
    CstDepartment dept = CstDepartmentDao.findById(deptId);
    if (dept == null) { response.sendRedirect("admin-cst-team"); return; }
    java.util.List<CstVolunteer> volunteers = CstVolunteerDao.listByDepartment(deptId);
%>
<!DOCTYPE html>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%@ include file="/WEB-INF/jspf/app-brand.jspf" %>
    <title><%= (String)request.getAttribute("appName") %> - Volunteers - <%= dept.getName() %></title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .container{max-width:900px;margin:32px auto;padding:0 16px;}
        .header-row{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:18px;}
        .vol-list{margin-bottom:32px;}
        .vol-list table{width:100%;border-collapse:collapse;}
        .vol-list th,.vol-list td{border-bottom:1px solid #e5e7eb;padding:10px;text-align:left;vertical-align:middle;}
        .actions{display:flex;gap:8px;}
        .form-section{background:#fff;border:1px solid #e5e7eb;border-radius:12px;padding:24px;max-width:500px;margin:0 auto;}
        .form-grid{display:grid;gap:14px;}
        .form-grid label{font-weight:500;}
        .form-grid input,.form-grid select{padding:8px;border:1px solid #e5e7eb;border-radius:8px;}
        .form-actions{display:flex;gap:12px;justify-content:flex-end;margin-top:18px;}
        .photo-preview{width:96px;height:96px;object-fit:cover;border-radius:50%;border:2px solid #2563eb;box-shadow:0 2px 4px rgba(0,0,0,.08);}
        .vol-card-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:16px;margin-block-start:24px;}
        .vol-card{background:#fff;border:1px solid #e5e7eb;border-radius:14px;padding:16px;display:flex;flex-direction:column;align-items:center;gap:10px;box-shadow:0 1px 3px rgba(0,0,0,.06);position:relative;}
        .vol-card h4{margin:0;font-size:1rem;font-weight:600;text-align:center;}
        .vol-meta{font-size:.7rem;color:#555;text-align:center;line-height:1.2;}
        .contact-row{display:flex;gap:8px;flex-wrap:wrap;justify-content:center;margin-top:4px;}
        .btn-sm{padding:4px 10px;font-size:.65rem;border-radius:6px;}
        .btn{padding:8px 18px;border-radius:8px;}
        .btn-primary{background:#2563eb;color:#fff;border:none;}
        .btn-outline{background:#fff;color:#2563eb;border:1px solid #2563eb;}
        .btn-danger{background:#dc2626;color:#fff;border:none;}
        .back-btn{margin-bottom:18px;}
    </style>
    <script>
    function disableBack() {
        history.pushState(null, document.title, location.href);
        window.addEventListener('popstate', function () {
            history.pushState(null, document.title, location.href);
        });
    }
    window.onload = disableBack;
    </script>
<%@ include file="/WEB-INF/jspf/csrf-meta.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/jspf/topnav.jspf" %>
<div class="container">
    <div class="header-row">
        <h2 style="margin:0">Volunteers — <%= dept.getName() %></h2>
        <a class="btn btn-primary" href="admin-add-volunteer.jsp?dept=<%= dept.getId() %>"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.volunteer.addNew") %></a>
    </div>
    <div class="vol-list">
        <h3 style="margin:0 0 12px 0;text-align:center;font-size:1.15em;color:#2563eb;"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.members") %></h3>
        <div class="vol-card-grid">
            <% for (CstVolunteer v : volunteers) { %>
                <div class="vol-card">
                    <% if (v.getPhotoUrl() != null && !v.getPhotoUrl().isEmpty()) { %>
                        <img src="<%= v.getPhotoUrl() %>" class="photo-preview" alt="Volunteer photo"/>
                    <% } else { %>
                        <div style="width:96px;height:96px;border-radius:50%;background:#e5e7eb;display:flex;align-items:center;justify-content:center;color:#6b7280;font-size:.8rem;">No Photo</div>
                    <% } %>
                    <h4><%= v.getPassportName() %></h4>
                    <div class="vol-meta">
                        <div><strong>ID:</strong> <%= v.getStudentId() %></div>
                        <div><strong>Nationality:</strong> <%= v.getNationality() %></div>
                        <div><strong>Gender:</strong> <%= v.getGender() %></div>
                        <div><strong>Phone:</strong> <%= v.getPhone() %></div>
                        <% try { if (v.getEmail() != null && !v.getEmail().isEmpty()) { %>
                            <div><strong>Email:</strong> <%= v.getEmail() %></div>
                        <% } } catch (Exception ignore) { } %>
                    </div>
                    <div class="contact-row">
                        <% if (v.getPhone() != null && !v.getPhone().isEmpty()) { %>
                            <a class="btn btn-outline btn-sm" href="tel:<%= v.getPhone() %>"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.call") %></a>
                        <% } %>
                        <% try { if (v.getEmail() != null && !v.getEmail().isEmpty()) { %>
                            <a class="btn btn-primary btn-sm" href="mailto:<%= v.getEmail() %>">Email</a>
                        <% } } catch (Exception ignore) { } %>
                    </div>
                </div>
            <% } %>
        </div>
    </div>
    <div style="display:flex;justify-content:center;margin-top:48px;padding-bottom:32px;">
        <button class="btn btn-outline" onclick="window.location.href='admin-cst-team'">Go Back</button>
    </div>
</div>
</body>
</html>

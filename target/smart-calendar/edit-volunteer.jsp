<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User,com.smartcalendar.models.CstVolunteer,com.smartcalendar.dao.CstVolunteerDao" %>
<%
 User user = (User) session.getAttribute("user");
 if (user == null) { response.sendRedirect("login.jsp"); return; }
 boolean isAdmin = user.getRole()!=null && user.getRole().equalsIgnoreCase("admin");
 if (!isAdmin) { response.sendRedirect("college-volunteers.jsp"); return; }
 int id = -1; try { id = Integer.parseInt(request.getParameter("id")); } catch(Exception ignore) {}
 CstVolunteer vol = null; try { vol = CstVolunteerDao.findById(id); } catch(Exception ignore) {}
 if (vol == null) { response.sendRedirect("college-volunteers.jsp"); return; }
 int deptId = -1; try { deptId = Integer.parseInt(request.getParameter("dept")); } catch(Exception ignore) {}
%>
<!DOCTYPE html>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
  <meta charset="UTF-8" />
  <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.volunteer.editTitle") %></title>
  <link rel="stylesheet" href="css/main.css" />
  <style>
    .wrap{max-inline-size:780px;margin:30px auto;padding:30px;background:#fff;border:1px solid #e5e7eb;border-radius:22px;box-shadow:0 6px 24px rgba(0,0,0,.06)}
    .grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:18px;margin-block:20px}
    label{display:block;font-size:.65rem;font-weight:600;letter-spacing:.5px;text-transform:uppercase;color:#374151;margin-block-end:6px}
    input{inline-size:100%;padding:10px 14px;border:1px solid #d1d5db;border-radius:12px;font-size:.85rem}
    .actions{display:flex;gap:12px;flex-wrap:wrap;margin-block-start:20px}
  </style>
</head>
<body>
<%@ include file="/WEB-INF/jspf/flash-messages.jspf" %>
<nav class="main-nav"><div class="nav-container"><h1 class="nav-title"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.volunteer.editTitle") %></h1></div></nav>
<div class="wrap">
  <form method="post" action="edit-volunteer" enctype="multipart/form-data">
    <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
    <input type="hidden" name="id" value="<%= vol.getId() %>" />
    <input type="hidden" name="dept" value="<%= deptId %>" />
    <div class="grid">
      <div>
        <label for="passportName">English Name</label>
        <input id="passportName" name="passportName" value="<%= vol.getPassportName()!=null?vol.getPassportName():"" %>" required />
      </div>
      <div>
        <label for="chineseName">Chinese Name</label>
        <input id="chineseName" name="chineseName" value="<%= vol.getChineseName()!=null?vol.getChineseName():"" %>" />
      </div>
      <div>
        <label for="nationality">Nationality</label>
        <input id="nationality" name="nationality" value="<%= vol.getNationality()!=null?vol.getNationality():"" %>" />
      </div>
      <div>
        <label for="phone">Phone</label>
        <input id="phone" name="phone" value="<%= vol.getPhone()!=null?vol.getPhone():"" %>" />
      </div>
      <div>
        <label for="email">Email</label>
        <input id="email" name="email" type="email" value="<%= vol.getEmail()!=null?vol.getEmail():"" %>" />
      </div>
      <div>
        <label for="photoFile">New Photo (optional)</label>
        <input id="photoFile" name="photoFile" type="file" accept="image/jpeg,image/png,image/webp" />
      </div>
    </div>
    <div class="actions">
      <button type="submit" class="btn btn-primary" style="padding:12px 22px;border-radius:14px"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.volunteer.saveChanges") %></button>
      <a href="cst-team-member-detail.jsp?id=<%= vol.getId() %>&dept=<%= deptId %>" class="btn btn-secondary" style="padding:12px 22px;border-radius:14px"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.back") %></a>
    </div>
  </form>
</div>
</body>
</html>

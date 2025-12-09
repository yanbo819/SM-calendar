<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    boolean isAdmin = user.getEmail() != null && user.getEmail().equals("admin@smartcalendar.com");
    if (!isAdmin) { response.sendRedirect("dashboard.jsp"); return; }
%>
<%
  String lang = (String) session.getAttribute("lang");
  if (lang == null && user.getPreferredLanguage() != null) lang = user.getPreferredLanguage();
  if (lang == null) lang = "en";
  String textDir = com.smartcalendar.utils.LanguageUtil.getTextDirection(lang);
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Admin Publish Event</title>
  <%@ include file="/WEB-INF/jspf/csrf-meta.jspf" %>
  <link rel="stylesheet" href="css/main.css" />
  <style>
    .card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;padding:24px;box-shadow:0 1px 2px rgba(0,0,0,.04)}
    .page-title{margin:0;font-size:1.4rem;font-weight:600}
    .form-grid{display:grid;gap:16px}
    @media (min-width:700px){ .form-grid{grid-template-columns:1fr 1fr} }
    .full-span{grid-column:1/-1}
    .actions{display:flex;gap:12px;justify-content:flex-end;margin-top:20px}
  </style>
</head>
<body>
<%@ include file="/WEB-INF/jspf/flash-messages.jspf" %>
  <nav class="main-nav">
    <div class="nav-container">
      <h1 class="nav-title" style="display:flex;align-items:center;gap:8px;">
        <img src="images/logo-smart.svg" alt="Smart Calendar" width="140" height="42" loading="eager" decoding="async" />
        <a href="dashboard.jsp">Smart Calendar</a>
      </h1>
      <div class="nav-actions">
        <span class="user-welcome">Admin: <%= user.getFullName() %></span>
      </div>
    </div>
  </nav>
  <% if (isAdmin) { %>
  <jsp:include page="/WEB-INF/jsp/includes/admin-toolbar.jspf" />

  <%@ include file="/WEB-INF/jspf/footer.jspf" %>
  <% } %>
  <div class="form-container">
    <div class="form-header" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
      <div>
        <h2 class="page-title"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "events.createNew") %></h2>
        <div class="page-sub" style="color:#6b7280"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "event.createPageSub") %></div>
      </div>
  <!-- toolbar provides navigation; removed per-page back button -->
    </div>
    <div class="card">
      <form method="post" action="admin-event" class="admin-event-form">
        <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
        <div class="form-grid">
          <div class="full-span">
            <label><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "events.subject") %></label>
            <input type="text" name="title" required class="form-control" />
          </div>
          <div>
            <label><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "events.fromDate") %></label>
            <input type="date" name="eventDate" required class="form-control" />
          </div>
          <div>
            <label><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "events.toDate") %></label>
            <input type="time" name="eventTime" required class="form-control" />
          </div>
          <div>
            <label>Duration (minutes)</label>
            <input type="number" name="duration" value="60" min="1" class="form-control" />
          </div>
          <div>
            <label><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "events.reminder") %></label>
            <select name="reminder" class="form-control">
              <option value="15">15</option>
              <option value="30">30</option>
              <option value="60">60</option>
              <option value="1440">1440 (1 day)</option>
            </select>
          </div>
          <div class="full-span">
            <label><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "event.locationPlaceholder") %></label>
            <input type="text" name="location" class="form-control" />
          </div>
          <div class="full-span">
            <label><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "event.descriptionPlaceholder") %></label>
            <textarea name="description" rows="4" class="form-control"></textarea>
          </div>
        </div>
        <div class="actions">
          <button type="submit" class="btn btn-primary"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "event.save") %></button>
        </div>
      </form>
    </div>
  </div>
</body>
</html>

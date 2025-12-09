<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.smartcalendar.utils.AnalyticsLog.Entry" %>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<%
    List<Entry> entries = (List<Entry>) request.getAttribute("entries");
    Object dtfObj = request.getAttribute("dtf");
    java.time.format.DateTimeFormatter dtf = (java.time.format.DateTimeFormatter) dtfObj;
    String endpointFilter = (String) request.getAttribute("endpointFilter");
    int limit = (Integer) request.getAttribute("limit");
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8" />
    <title>Analytics - <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "app.title") %></title>
    <link rel="stylesheet" href="css/main.css" />
    <style>
        .analytics-container{max-inline-size:1100px;margin:24px auto;padding-inline:16px}
        table.analytics{inline-size:100%;border-collapse:separate;border-spacing:0;font-size:.85rem}
        table.analytics th,table.analytics td{padding:8px 10px;border-block-end:1px solid #e5e7eb;text-align:start}
        table.analytics thead th{background:#f9fafb;position:sticky;inset-block-start:0;font-weight:600;font-size:.75rem;letter-spacing:.5px;text-transform:uppercase}
        .filters{display:flex;flex-wrap:wrap;gap:12px;margin-block-end:16px;align-items:flex-end}
        .filters label{font-size:.75rem;font-weight:600;color:#374151;text-transform:uppercase;letter-spacing:.5px}
        .pill{display:inline-block;padding:4px 10px;background:#eef2ff;border:1px solid #c7d2fe;border-radius:999px;font-size:.7rem;font-weight:500;color:#374151}
        .empty{padding:40px;text-align:center;border:1px dashed #d1d5db;border-radius:16px;background:#fff}
    </style>
</head>
<body>
<nav class="main-nav">
  <div class="nav-container">
    <h1 class="nav-title">Analytics</h1>
    <div class="nav-actions">
      <a href="dashboard.jsp" class="btn btn-secondary">Dashboard</a>
    </div>
  </div>
</nav>
<div class="analytics-container">
  <div class="filters">

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
    <div style="flex:1;min-inline-size:240px">
      <label for="endpoint">Endpoint</label>
      <form method="get" action="admin-analytics" style="display:flex;gap:12px;flex-wrap:wrap">
        <input type="text" id="endpoint" name="endpoint" value="<%= endpointFilter %>" placeholder="/business-admin" class="form-input" style="flex:1;min-inline-size:200px" />
        <label for="limit">Limit</label>
        <input type="number" id="limit" name="limit" value="<%= limit %>" min="1" max="500" class="form-input" style="inline-size:100px" />
        <button type="submit" class="btn btn-primary" style="align-self:flex-start">Apply</button>
      </form>
    </div>
    <div class="pill">Total fetched: <%= entries.size() %></div>
  </div>
  <% if (entries.isEmpty()) { %>
    <div class="empty">No analytics entries yet.</div>
  <% } else { %>
  <div class="table-responsive">
    <table class="analytics">
      <thead>
        <tr>
          <th>Time (UTC)</th>
          <th>User</th>
          <th>Endpoint</th>
          <th>Query</th>
        </tr>
      </thead>
      <tbody>
        <% for (Entry e : entries) { %>
          <tr>
            <td><%= dtf.format(e.timestamp) %></td>
            <td><%= e.userId %></td>
            <td><%= e.endpoint %></td>
            <td style="font-family:monospace"><%= e.query %></td>
          </tr>
        <% } %>
      </tbody>
    </table>
  </div>
  <% } %>
</div>
</body>
</html>

<%@ tag language="java" pageEncoding="UTF-8" %>
<%@ attribute name="currentPage" required="true" %>
<%@ attribute name="totalPages" required="true" %>
<%@ attribute name="basePath" required="true" %>
<%@ attribute name="query" required="false" %>
<%@ attribute name="size" required="true" %>
<%
 int current = Integer.parseInt(getJspContext().findAttribute("currentPage").toString());
 int totalPages = Integer.parseInt(getJspContext().findAttribute("totalPages").toString());
 int size = Integer.parseInt(getJspContext().findAttribute("size").toString());
 String base = (String) getJspContext().findAttribute("basePath");
 String query = (String) getJspContext().findAttribute("query");
 if (query == null) query = "";
 String qParam = query.isEmpty() ? "" : ("&q=" + java.net.URLEncoder.encode(query, "UTF-8"));
%>
<% if (totalPages > 1) { %>
<div style="margin-block:24px;display:flex;flex-wrap:wrap;gap:10px;align-items:center;justify-content:center">
    <a href="<%= base %>?page=1&size=<%= size %><%= qParam %>" style="padding:6px 12px;border:1px solid #d1d5db;border-radius:8px;text-decoration:none;font-size:.8rem;">« First</a>
    <a href="<%= base %>?page=<%= Math.max(1,current-1) %>&size=<%= size %><%= qParam %>" style="padding:6px 12px;border:1px solid #d1d5db;border-radius:8px;text-decoration:none;font-size:.8rem;">‹ Prev</a>
    <span style="padding:6px 12px;font-size:.8rem;background:#eef2ff;border:1px solid #c7d2fe;border-radius:8px;">Page <strong><%= current %></strong> / <%= totalPages %></span>
    <a href="<%= base %>?page=<%= Math.min(totalPages,current+1) %>&size=<%= size %><%= qParam %>" style="padding:6px 12px;border:1px solid #d1d5db;border-radius:8px;text-decoration:none;font-size:.8rem;">Next ›</a>
    <a href="<%= base %>?page=<%= totalPages %>&size=<%= size %><%= qParam %>" style="padding:6px 12px;border:1px solid #d1d5db;border-radius:8px;text-decoration:none;font-size:.8rem;">Last »</a>
</div>
<% } %>

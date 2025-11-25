<%@ tag language="java" pageEncoding="UTF-8" %>
<%@ attribute name="variant" required="true" %>
<%@ attribute name="id" required="true" %>
<%@ attribute name="name" required="true" %>
<%@ attribute name="desc" required="true" %>
<%@ attribute name="membersCount" required="true" %>
<%@ attribute name="focus" required="false" %>
<%@ attribute name="viewHref" required="true" %>
<%
    String lang = (String) request.getAttribute("lang");
    if (lang == null) {
        Object l = request.getSession().getAttribute("lang");
        if (l != null) lang = l.toString();
    }
    String variant = (String) getJspContext().findAttribute("variant");
    int members = Integer.parseInt(getJspContext().findAttribute("membersCount").toString());
    String name = (String) getJspContext().findAttribute("name");
    String desc = (String) getJspContext().findAttribute("desc");
    String viewHref = (String) getJspContext().findAttribute("viewHref");
    String focus = (String) getJspContext().findAttribute("focus");
    int focusAreas = 0;
    if (focus != null && !focus.isEmpty()) {
        focusAreas = focus.trim().split("\\s+").length;
    }
%>
<%
String membersLabelKey = members == 1 ? "members.label.one" : "members.label.other";
String membersLabel = com.smartcalendar.utils.LanguageUtil.getText(lang, membersLabelKey);
String focusLabelKey = focusAreas == 1 ? "focusAreas.label.one" : "focusAreas.label.other";
String focusLabel = com.smartcalendar.utils.LanguageUtil.getText(lang, focusLabelKey);
%>
<% if ("business".equals(variant)) { %>
<div class="dept-card" tabindex="0" role="group" aria-label="Department <%= name %> with <%= members %> <%= membersLabel %>">
    <div>
        <div class="dept-count"><%= members %> <%= membersLabel %></div>
        <h2 class="dept-name"><%= name %></h2>
        <p class="dept-desc"><%= desc %></p>
    </div>
    <div class="dept-actions">
        <a href="<%= viewHref %>" class="btn-business"> <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.view.members") %> </a>
    </div>
</div>
<% } else if ("chinese".equals(variant)) { %>
<div class="dept-card" tabindex="0" role="group" aria-label="Department <%= name %> with <%= members %> <%= membersLabel %>">
    <div>
        <h2 class="dept-name"><%= name %></h2>
        <p class="dept-desc"><%= desc %></p>
        <div class="dept-stats">
            <div class="stat-item">
                <div class="stat-number"><%= members %></div>
                <div class="stat-label"><%= membersLabel %></div>
            </div>
            <div class="stat-item">
                <div class="stat-number"><%= focusAreas %></div>
                <div class="stat-label"><%= focusLabel %></div>
            </div>
        </div>
    </div>
    <div class="dept-actions">
        <a href="<%= viewHref %>" class="btn-chinese"> <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.view.members") %> </a>
    </div>
</div>
<% } %>

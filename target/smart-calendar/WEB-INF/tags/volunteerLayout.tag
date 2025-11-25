<%@ tag language="java" pageEncoding="UTF-8"%>
<%@ attribute name="titleKey" required="true" %>
<%@ attribute name="descKey" required="true" %>
<%@ attribute name="count" required="true" %>
<%@ attribute name="backHref" required="true" %>
<%@ attribute name="searchId" required="true" %>
<%@ attribute name="searchPlaceholder" required="true" %>
<%@ attribute name="filterCaption" required="true" %>
<%@ attribute name="variant" required="false" %>
<%@ attribute name="gridId" required="false" %>
<%
    String lang = (String) request.getAttribute("lang");
    if (lang == null) {
        Object l = request.getSession().getAttribute("lang");
        if (l != null) lang = l.toString();
    }
    String variant = (String) getJspContext().findAttribute("variant");
    if (variant == null) variant = "default";
    String accentColor = "#536dfe";
    if ("business".equals(variant)) accentColor = "#667eea";
    else if ("chinese".equals(variant)) accentColor = "#f5576c";
%>
<div class="hero">
    <div style="flex:1;min-inline-size:260px">
        <h1><%= com.smartcalendar.utils.LanguageUtil.getText(lang, (String) getJspContext().findAttribute("titleKey")) %></h1>
        <p class="sub"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, (String) getJspContext().findAttribute("descKey")) %> · <strong><%= getJspContext().findAttribute("count") %></strong> departments</p>
    </div>
    <div style="display:flex;gap:10px;align-items:center;">
        <a href="<%= getJspContext().findAttribute("backHref") %>" class="btn btn-secondary" style="background:#fff;color:<%= accentColor %>;border:1px solid #fff;">&larr; <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.back") %></a>
    </div>
</div>
<div style="margin:0 0 20px 0;display:flex;justify-content:space-between;flex-wrap:wrap;gap:14px;align-items:center;">
    <label for="<%= getJspContext().findAttribute("searchId") %>" class="visually-hidden">Search</label>
    <input id="<%= getJspContext().findAttribute("searchId") %>" type="text" role="search" aria-label="Filter departments" placeholder="<%= getJspContext().findAttribute("searchPlaceholder") %>" style="flex:1;min-inline-size:240px;padding:11px 15px;border:1px solid #d1d5db;border-radius:12px;font-size:.85rem;" />
    <div style="font-size:.7rem;color:#6b7280;letter-spacing:.5px;text-transform:uppercase"><%= getJspContext().findAttribute("filterCaption") %></div>
</div>
<%
        String gridId = (String) getJspContext().findAttribute("gridId");
        String searchId = (String) getJspContext().findAttribute("searchId");
        if (gridId != null && searchId != null) {
%>
<script>
document.addEventListener('DOMContentLoaded', function(){
    const input = document.getElementById('<%= searchId %>');
    const grid = document.getElementById('<%= gridId %>');
    if(input && grid){
        input.addEventListener('input', function(){
            const q = input.value.trim().toLowerCase();
            grid.querySelectorAll('.dept-card').forEach(card => {
                const name = (card.querySelector('.dept-name')?.textContent||'').toLowerCase();
                const desc = (card.querySelector('.dept-desc')?.textContent||'').toLowerCase();
                if(!q || name.includes(q) || desc.includes(q)) {
                    card.style.display='';
                } else {
                    card.style.display='none';
                }
            });
        });
    }
});
</script>
<% } %>

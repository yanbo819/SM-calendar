<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.models.Event" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null) { response.sendRedirect("login.jsp"); return; }
    boolean isAdmin = me.getRole() != null && me.getRole().equalsIgnoreCase("admin");
    if (!isAdmin) { response.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }
    User target = (User) request.getAttribute("target");
    List<Event> events = (List<Event>) request.getAttribute("events");
%>
<!doctype html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin: User Detail</title>
    <link rel="stylesheet" href="css/main.css" />
    <link rel="stylesheet" href="css/ui.css" />
    <link rel="stylesheet" href="css/components.css" />
</head>
<body>
<!-- Navigation and admin toolbar removed for streamlined profile view -->
<div class="form-container" style="max-inline-size:1100px;margin:24px auto;">
    <div class="card card-pad">
        <h2 style="margin:0 0 6px">User Profile</h2>
        <div style="color:#6b7280;font-size:.9rem;margin:0 0 18px">ID #<%= target.getUserId() %> · Username: <strong><%= target.getUsername() %></strong></div>
        <div class="grid-2 mb-24">
            <div class="card-section">
                <div class="card-section-label">Full Name</div>
                <div style="font-weight:500"><%= target.getFullName() %></div>
            </div>
            <div class="card-section">
                <div class="card-section-label">Role</div>
                <div><span class="badge <%= ("admin".equalsIgnoreCase(target.getRole())?"gray":"green") %>"><%= target.getRole() %></span></div>
            </div>
            <div class="card-section">
                <div class="card-section-label">Status</div>
                <div><span class="badge <%= (target.isActive()?"green":"gray") %>"><%= target.isActive()?"Active":"Inactive" %></span></div>
            </div>
            <div class="card-section">
                <div class="card-section-label">Preferred Language</div>
                <div><%= target.getPreferredLanguage()==null?"en":target.getPreferredLanguage() %></div>
            </div>
        </div>
        <h3 style="margin:0 0 12px">Edit User</h3>
        <form method="post" action="admin-user-crud" class="grid-form-2">
            <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
            <input type="hidden" name="action" value="update" />
            <input type="hidden" name="userId" value="<%= target.getUserId() %>" />
            <label style="display:flex;flex-direction:column;gap:6px">Full Name
                <input class="form-control" name="fullName" value="<%= target.getFullName() %>" required />
            </label>
            <label style="display:flex;flex-direction:column;gap:6px">Email
                <input class="form-control" type="email" name="email" value="<%= target.getEmail() %>" required />
            </label>
            <label style="display:flex;flex-direction:column;gap:6px">Phone
                <input class="form-control" name="phone" value="<%= target.getPhoneNumber() != null ? target.getPhoneNumber() : "" %>" />
            </label>
            <label style="display:flex;flex-direction:column;gap:6px">Role
                <select class="form-control" name="role" <%= ("admin".equalsIgnoreCase(target.getRole()) ? "disabled" : "") %>>
                    <option value="user" <%= ("user".equalsIgnoreCase(target.getRole()) ? "selected" : "") %>>User</option>
                    <option value="admin" <%= ("admin".equalsIgnoreCase(target.getRole()) ? "selected" : "") %>>Admin</option>
                </select>
            </label>
            <label style="display:flex;flex-direction:column;gap:6px">Active
                <input type="checkbox" name="active" <%= target.isActive() ? "checked" : "" %> <%= ("admin".equalsIgnoreCase(target.getRole()) ? "disabled" : "") %> />
            </label>
            <label class="grid-span-all" style="display:flex;flex-direction:column;gap:6px">Reset Password
                <input class="form-control" type="password" name="password" placeholder="Leave blank to keep" />
            </label>
            <div class="grid-span-all actions-row mt-4">
                <button type="submit" class="btn btn-primary min-140"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.user.saveChanges") %></button>
                <a href="admin-users" class="btn btn-outline min-140"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.back") %></a>
            </div>
        </form>
        <% if (!"admin".equalsIgnoreCase(target.getRole())) { %>
        <div class="actions-row">
            <form method="post" action="admin-user-crud" style="display:inline">
                <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
                <input type="hidden" name="action" value="update" />
                <input type="hidden" name="userId" value="<%= target.getUserId() %>" />
                <input type="hidden" name="fullName" value="<%= target.getFullName() %>" />
                <input type="hidden" name="email" value="<%= target.getEmail() %>" />
                <input type="hidden" name="phone" value="<%= target.getPhoneNumber() %>" />
                <input type="hidden" name="role" value="<%= target.getRole() %>" />
                <input type="hidden" name="active" value="<%= !target.isActive() %>" />
                <button type="submit" class="btn btn-outline min-140"><%= target.isActive() ? "Deactivate" : "Activate" %></button>
            </form>
            <form method="post" action="admin-user-crud" style="display:inline" onsubmit="return confirm('<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.user.deleteConfirm") %>');">
                <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
                <input type="hidden" name="action" value="delete" />
                <input type="hidden" name="userId" value="<%= target.getUserId() %>" />
                <button type="submit" class="btn btn-danger min-140"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.delete") %></button>
            </form>
        </div>
        <% } %>
        <h3 style="margin:0 0 12px">Events</h3>
        <div class="table-responsive" style="margin-block-start:4px">
            <table class="table">
                <thead><tr><th>ID</th><th>Title</th><th>Date</th><th>Time</th><th>Duration</th><th>Location</th><th>Edit</th></tr></thead>
                <tbody>
                <% if (events != null) { for (Event e : events) { %>
                    <tr>
                        <td><%= e.getEventId() %></td>
                        <td><%= e.getTitle() %></td>
                        <td><%= e.getEventDate() %></td>
                        <td><%= e.getEventTime() %></td>
                        <td><%= e.getDurationMinutes() %>m</td>
                        <td><%= e.getLocation() %></td>
                        <td>
                            <form class="inline-form" method="post" action="admin-update-user-event">
                                <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
                                <input type="hidden" name="eventId" value="<%= e.getEventId() %>" />
                                <input type="hidden" name="userId" value="<%= target.getUserId() %>" />
                                <label style="display:flex;flex-direction:column;gap:4px;font-size:.7rem">Date
                                    <input class="form-control" type="date" name="eventDate" value="<%= e.getEventDate() %>" required />
                                </label>
                                <label style="display:flex;flex-direction:column;gap:4px;font-size:.7rem">Time
                                    <input class="form-control" type="time" name="eventTime" value="<%= e.getEventTime() != null ? e.getEventTime().toString().substring(0,5) : "" %>" required />
                                </label>
                                <button type="submit" class="btn btn-outline btn-sm">Save</button>
                            </form>
                        </td>
                    </tr>
                <% } } %>
                </tbody>
            </table>
        </div>
    </div>
</div>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>

    </body>
    </html>

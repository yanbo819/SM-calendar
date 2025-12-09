<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartcalendar.models.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title><%= com.smartcalendar.utils.LanguageUtil.getText("en", "admin.department.addNewTitle") %></title>
    <style>
        .form-container {
            max-width: 400px;
            margin: 40px auto;
            padding: 2em;
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        .form-container h2 {
            text-align: center;
            margin-bottom: 1.5em;
        }
        .form-group {
            margin-bottom: 1.2em;
        }
        label {
            display: block;
            margin-bottom: 0.5em;
            font-weight: 500;
        }
        input[type="text"] {
            width: 100%;
            padding: 0.7em;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 1em;
        }
        .actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        button, .back-link {
            padding: 0.7em 1.5em;
            border: none;
            border-radius: 4px;
            background: #1976d2;
            color: #fff;
            font-size: 1em;
            cursor: pointer;
            text-decoration: none;
        }
        .back-link {
            background: #888;
        }
        button:hover, .back-link:hover {
            background: #125ea2;
        }
    </style>
</head>
<body>
<div class="form-container">
    <h2><%= com.smartcalendar.utils.LanguageUtil.getText("en", "admin.department.addNewTitle") %></h2>
    <form method="post" action="admin-add-department">
        <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
        <div class="form-group">
            <label for="name"><%= com.smartcalendar.utils.LanguageUtil.getText("en", "admin.volunteer.departmentLabel") %> Name</label>
            <input type="text" id="name" name="name" required maxlength="150">
        </div>
        <div class="form-group">
            <label for="leader_name">Leader Name</label>
            <input type="text" id="leader_name" name="leader_name" maxlength="150">
        </div>
        <div class="form-group">
            <label for="leader_phone">Leader Phone</label>
            <input type="text" id="leader_phone" name="leader_phone" maxlength="40">
        </div>
        <div class="actions">
            <a href="admin-cst-team" class="back-link"><%= com.smartcalendar.utils.LanguageUtil.getText("en", "common.back") %></a>
            <button type="submit"><%= com.smartcalendar.utils.LanguageUtil.getText("en", "admin.department.addButton") %></button>
        </div>
    </form>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

</body>
</html>

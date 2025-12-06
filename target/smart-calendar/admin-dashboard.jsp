<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
	<meta charset="UTF-8">
	<title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.dashboard") %></title>
	<link rel="stylesheet" href="css/main.css">
</head>
<body>
	<div class="container">
		<h2><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.dashboard") %></h2>
	</div>
	<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>

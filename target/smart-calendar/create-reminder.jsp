<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Redirect to create-event page with reminder category (Personal category)
    response.sendRedirect("create-event.jsp?category=4&reminder=true");
%>
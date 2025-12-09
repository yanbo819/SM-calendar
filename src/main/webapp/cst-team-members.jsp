<%@ page import="java.util.*, com.smartcalendar.models.CstDepartment, com.smartcalendar.models.CstVolunteer, com.smartcalendar.dao.CstVolunteerDao, com.smartcalendar.dao.CstDepartmentDao" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String deptIdStr = request.getParameter("dept");
    int deptId = -1;
    if (deptIdStr != null && !deptIdStr.isBlank()) {
        try { deptId = Integer.parseInt(deptIdStr.trim()); } catch (Exception e) { deptId = -1; }
    }
    CstDepartment dept = null;
    List<CstVolunteer> members = Collections.emptyList();
    String errorMsg = null;
    if (deptId <= 0) {
        errorMsg = "Invalid department parameter.";
    } else {
        try {
            dept = com.smartcalendar.dao.CstDepartmentDao.findById(deptId);
            if (dept != null) {
                members = com.smartcalendar.dao.CstVolunteerDao.listByDepartment(deptId);
            } else {
                errorMsg = "Department not found.";
            }
        } catch (Exception e) {
            errorMsg = "Error loading department or volunteers.";
        }
    }
    boolean isAdmin = false;
    com.smartcalendar.models.User u = (com.smartcalendar.models.User) session.getAttribute("user");
    if (u != null && u.getRole() != null && u.getRole().equalsIgnoreCase("admin")) isAdmin = true;
    request.setAttribute("deptId", deptId);
    request.setAttribute("dept", dept);
    request.setAttribute("members", members);
    request.setAttribute("errorMsg", errorMsg);
    request.setAttribute("isAdmin", isAdmin);
%>
<!DOCTYPE html>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <%@ include file="/WEB-INF/jspf/app-brand.jspf" %>
    <title><%= (String)request.getAttribute("appName") %> - <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.team.members.title") %></title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/layout.css">
    <link rel="stylesheet" href="css/team-members.css">
</head>
<body>
    <%@ include file="/WEB-INF/jspf/topnav.jspf" %>
    <%@ include file="/WEB-INF/jspf/flash-messages.jspf" %>
    <div class="container">
        <!-- Unified header -->
        <div class="page-header-flex">
            <div class="page-header-block">
                <h1 class="page-header-title">
                    <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.team.title") %>
                </h1>
                <h2 class="page-header-sub">
                    <%= dept != null ? dept.getName() : com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.department.unknown") %>
                </h2>
                <div class="page-header-meta">
                    <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.department.label") %>:
                    <strong><%= dept != null ? dept.getName() : com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.department.unknown") %></strong>
                    · <span id="countSpan"><%= members.size() %></span>
                    <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.members.count.label") %>
                </div>
            </div>
            <div class="back-link-wrap">
                <a href="cst-team" class="btn btn-secondary" style="white-space:nowrap">&larr; <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.back.departments") %></a>
            </div>
        </div>
        <!-- Removed search/filter per user request -->
        <c:choose>
            <c:when test="${not empty errorMsg}">
                <div class="error-msg">${errorMsg}</div>
            </c:when>
            <c:when test="${empty members}">
                <div class="empty-msg"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.members.empty") %></div>
                <c:if test="${isAdmin and not empty dept}">
                    <a href="add-volunteer.jsp?dept=<%= dept != null ? dept.getId() : -1 %>" class="btn btn-primary add-volunteer-btn">+ <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.volunteer.addNew") %></a>
                </c:if>
            </c:when>
            <c:otherwise>
                <div class="member-list" id="memberList">
                    <c:forEach var="v" items="${members}">
                        <t:volunteerCard id="${v.id}" passportName="${empty v.passportName ? 'Unknown' : v.passportName}" chineseName="${v.chineseName}" studentId="${v.studentId}" email="${v.email}" phone="${v.phone}" photoUrl="${v.photoUrl}" deptId="${deptId}" />
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
        <!-- Bottom back button removed (single back in header retained) -->
    </div>
        <!-- Filtering script removed -->
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>

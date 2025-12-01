<%@ tag description="Volunteer card display" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ attribute name="id" required="true" %>
<%@ attribute name="passportName" required="true" %>
<%@ attribute name="chineseName" required="false" %>
<%@ attribute name="studentId" required="false" %>
<%@ attribute name="email" required="false" %>
<%@ attribute name="phone" required="false" %>
<%@ attribute name="photoUrl" required="false" %>
<%@ attribute name="deptId" required="true" %>
<%
    // Compute displayPhoto including thumbnail resolution; exposed as tag attribute for EL usage.
    String photo = (String) jspContext.getAttribute("photoUrl");
    String displayPhoto = photo;
    if (photo != null && !photo.isEmpty()) {
        int dot = photo.lastIndexOf('.');
        if (dot > 0) {
            String ext = photo.substring(dot+1).toLowerCase(java.util.Locale.ROOT);
            String thumbExt = "webp".equals(ext)?"png":ext;
            String thumbCandidate = photo.substring(0,dot) + "_thumb." + thumbExt;
            java.nio.file.Path realThumb = java.nio.file.Path.of(application.getRealPath("/"+thumbCandidate));
            if (java.nio.file.Files.exists(realThumb)) {
                displayPhoto = thumbCandidate;
            }
        }
    }
    jspContext.setAttribute("displayPhoto", displayPhoto);
%>
<div class="member-card row-layout" data-name="${passportName}">
    <img class="member-img large" src="${empty displayPhoto ? 'https://via.placeholder.com/84' : displayPhoto}" alt="photo" />
    <div class="member-content">
        <h3 class="member-name left">${passportName}</h3>
        <c:if test="${not empty chineseName}">
            <div class="member-extra left">${chineseName}</div>
        </c:if>
        <c:if test="${not empty studentId}">
            <div class="member-extra left"><strong>ID:</strong> ${studentId}</div>
        </c:if>
        <c:if test="${not empty email}">
            <div class="member-extra left"><strong>Email:</strong> ${email}</div>
        </c:if>
        <c:if test="${not empty phone}">
            <div class="member-extra left"><strong>Call:</strong> <a href="tel:${phone}">${phone}</a></div>
        </c:if>
        <a href="cst-team-member-detail.jsp?id=${id}&dept=${deptId}" class="btn btn-primary member-view-btn">&rarr; View</a>
    </div>
</div>
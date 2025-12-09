<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="com.smartcalendar.models.CollegeTeacher" %>
<%
    Object userObj = session.getAttribute("user");
    if (userObj == null) { response.sendRedirect("login.jsp"); return; }
    com.smartcalendar.models.User user = (com.smartcalendar.models.User) userObj;
    if (user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) { response.sendRedirect("dashboard"); return; }
    Map<String, List<CollegeTeacher>> teacherGroups = (Map<String, List<CollegeTeacher>>) request.getAttribute("teacherGroups");
    String loadError = (String) request.getAttribute("loadError");
%>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.manage.title") %></title>
    <link rel="stylesheet" href="css/main.css" />
    <style>
        body{background:#f8fafc;font-family:system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto}
        .container{max-inline-size:1100px;margin:0 auto;padding:32px 20px;display:grid;gap:28px}
        h1{margin:0;font-size:1.75rem;font-weight:600}
        .groups{display:grid;gap:20px}
        .group{background:#fff;border:1px solid #e5e7eb;border-radius:14px;padding:20px;box-shadow:0 1px 2px rgba(0,0,0,.04)}
        .group-header{display:flex;align-items:center;justify-content:space-between;gap:14px;margin:0 0 12px 0}
        .teachers{display:grid;gap:10px;margin-top:4px}
        .teacher-row{display:flex;align-items:center;gap:10px;background:#f1f5f9;padding:10px 12px;border-radius:10px}
        .teacher-row form{display:flex;align-items:center;gap:8px;margin:0}
        input[type=text]{border:1px solid #e5e7eb;border-radius:8px;padding:8px 10px;background:#fff;min-inline-size:220px}
        input[type=text]:focus{outline:none;border-color:#6366f1;box-shadow:0 0 0 3px rgba(99,102,241,.15)}
        .inline-actions{display:flex;gap:6px}
        .add-form{display:flex;flex-wrap:wrap;gap:10px;margin-top:6px}
        .btn-small{padding:8px 12px;border:1px solid #e5e7eb;border-radius:8px;background:#fff;font-size:.8rem;cursor:pointer}
        .btn-small.primary{background:#6366f1;color:#fff;border-color:#6366f1}
        .btn-small.danger{background:#dc2626;color:#fff;border-color:#dc2626}
        .btn-small:hover{filter:brightness(.95)}
        .top-bar{display:flex;flex-wrap:wrap;align-items:center;gap:12px}
        .global-add{background:#fff;border:1px solid #e5e7eb;border-radius:14px;padding:16px;display:grid;gap:12px}
        .notice{font-size:.8rem;color:#64748b}
        .toast{position:fixed;top:20px;right:20px;padding:14px 18px;border-radius:10px;background:#10b981;color:#fff;font-size:.9rem;box-shadow:0 4px 12px rgba(0,0,0,.15);opacity:0;transition:opacity .3s;z-index:9999}
        .toast.show{opacity:1}
        .toast.error{background:#ef4444}
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h1><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.manage.title") %></h1>
            <a href="colleges-info.jsp" class="btn btn-outline"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.manage.backColleges") %></a>
            <a href="admin-tools.jsp" class="btn btn-outline"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.manage.backTools") %></a>
        </div>
        <% if (loadError != null) { %>
            <div style="color:#b91c1c;background:#fee2e2;padding:12px;border-radius:8px"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.loadError") %> <%= loadError %></div>
        <% } %>
        <div class="global-add">
            <h2 style="margin:0;font-size:1.15rem"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.manage.addNew") %></h2>
            <form method="post" action="admin-college-teachers" style="display:flex;flex-wrap:wrap;gap:10px">
                <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
                <input type="hidden" name="action" value="add-teacher" />
                <input type="text" name="college_name" placeholder="<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.manage.collegeName") %>" required />
                <input type="text" name="teacher_name" placeholder="<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.manage.teacherName") %>" required />
                <button type="submit" class="btn-small primary"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.manage.addTeacher") %></button>
            </form>
            <div class="notice"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.manage.notice") %></div>
        </div>
        <div class="groups">
            <% if (teacherGroups != null && !teacherGroups.isEmpty()) { %>
                <% for (Map.Entry<String, List<CollegeTeacher>> e : teacherGroups.entrySet()) { %>
                    <div class="group">
                        <div class="group-header">
                            <h3 style="margin:0;font-size:1.1rem"><%= e.getKey() %></h3>
                            <form method="post" action="admin-college-teachers" style="display:flex;gap:8px;flex-wrap:wrap">
                                <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
                                <input type="hidden" name="action" value="add-teacher" />
                                <input type="hidden" name="college_name" value="<%= e.getKey() %>" />
                                <input type="text" name="teacher_name" placeholder="<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.manage.newTeacher") %>" required />
                                <button type="submit" class="btn-small primary">+ <%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.manage.addTeacher") %></button>
                            </form>
                        </div>
                        <div class="teachers">
                            <% for (CollegeTeacher ct : e.getValue()) { %>
                                <div class="teacher-row">
                                    <form method="post" action="admin-college-teachers">
                                        <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
                                        <input type="hidden" name="action" value="update-teacher" />
                                        <input type="hidden" name="id" value="<%= ct.getId() %>" />
                                        <input type="text" name="teacher_name" value="<%= ct.getTeacherName() %>" />
                                        <div class="inline-actions">
                                            <button type="submit" class="btn-small primary"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.manage.save") %></button>
                                        </div>
                                    </form>
                                    <form method="post" action="admin-college-teachers" onsubmit="return confirm('<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "confirm.delete.teacher") %>')">
                                        <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
                                        <input type="hidden" name="action" value="delete-teacher" />
                                        <input type="hidden" name="id" value="<%= ct.getId() %>" />
                                        <button type="submit" class="btn-small danger"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.manage.delete") %></button>
                                    </form>
                                </div>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            <% } else { %>
                <div style="font-size:.85rem;color:#64748b"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.manage.noTeachers") %></div>
            <% } %>
        </div>
    </div>
    <div id="toast" class="toast"></div>
    <script>
    // Localized fallback messages (in case server omits message)
    const MSG_ADD = '<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.msg.addSuccess") %>';
    const MSG_UPDATE = '<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.msg.updateSuccess") %>';
    const MSG_DELETE = '<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.msg.deleteSuccess") %>';
    const MSG_EMPTY = '<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.msg.emptyFields") %>';
    const MSG_INVALID = '<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.msg.invalidId") %>';
    const MSG_SERVER = '<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.teachers.msg.serverError") %>';
    (function(){
        const toast = document.getElementById('toast');
        function showToast(msg, isError) {
            toast.textContent = msg;
            toast.className = 'toast show' + (isError ? ' error' : '');
            setTimeout(() => toast.classList.remove('show'), 3000);
        }

        // AJAX form submission
        document.addEventListener('submit', function(e) {
            const form = e.target;
            if (!form.matches('form[action="admin-college-teachers"]')) return;
            e.preventDefault();
            const formData = new FormData(form);
            fetch('admin-college-teachers', {
                method: 'POST',
                headers: { 'X-Requested-With': 'XMLHttpRequest' },
                body: formData
            })
            .then(r => r.ok ? r.json() : Promise.reject('Server error'))
            .then(data => {
                if (data.ok) {
                    const action = formData.get('action');
                    if (action === 'delete-teacher') {
                        form.closest('.teacher-row').remove();
                        showToast(data.message || MSG_DELETE, false);
                    } else if (action === 'add-teacher') {
                        // reload to show new grouping
                        location.reload();
                    } else if (action === 'update-teacher') {
                        showToast(data.message || MSG_UPDATE, false);
                    }
                } else {
                    showToast(data.message || MSG_SERVER, true);
                }
            })
            .catch(() => showToast(MSG_SERVER, true));
        });
    })();
    </script>
        <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>
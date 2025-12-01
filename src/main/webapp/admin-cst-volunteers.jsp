<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%@ page import="java.util.*" %>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.models.CstDepartment" %>
<%@ page import="com.smartcalendar.models.CstVolunteer" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRole()==null || !user.getRole().equalsIgnoreCase("admin")) { response.sendRedirect("login.jsp"); return; }
    CstDepartment d = (CstDepartment) request.getAttribute("department");
    List<CstVolunteer> vs = (List<CstVolunteer>) request.getAttribute("volunteers");
    boolean noheader = "1".equals(request.getParameter("noheader"));
%>
<%@ include file="/WEB-INF/jspf/lang-init.jspf" %>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Manage Volunteers - <%= d.getName() %></title>
<link rel="stylesheet" href="css/main.css">
<style>
    .container{max-inline-size:1000px;margin:0 auto;padding:16px}
    .grid{display:grid;gap:16px}
    .cards{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:16px}
    .card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;padding:16px}
    .label{font-size:12px;color:#6b7280;margin-block-end:4px}
    .photo{inline-size:96px;block-size:96px;border-radius:50%;object-fit:cover;border:1px solid #e5e7eb}
    .photo-lg{inline-size:240px;block-size:240px;border-radius:8px;object-fit:cover;border:1px solid #e5e7eb;background:#f3f4f6}
    .btn-row{display:flex;gap:8px;justify-content:flex-end;margin-block-start:8px}
    .row{display:flex;gap:8px;flex-wrap:wrap}
    .row input,.row select{padding:8px;border:1px solid #e5e7eb;border-radius:8px}
    .input-lg{padding:12px 14px;font-size:16px}
    .toolbar{display:flex;justify-content:space-between;align-items:center;gap:8px;margin-block:8px 16px}
    .hint{color:#6b7280;font-size:13px}
</style>
</head>
<body>
<%@ include file="/WEB-INF/jspf/flash-messages.jspf" %>
<% if (!noheader) { %>
<nav class="main-nav"><div class="nav-container"><h1 class="nav-title">Manage Volunteers</h1></div></nav>
<nav class="main-nav"><div class="nav-container"><h1 class="nav-title"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.admin.volunteers.title") %></h1></div></nav>
<% } %>
<div class="container">
    <h2 style="margin:0 0 8px 0">Department: <%= d.getName() %></h2>
        <h2 style="margin:0 0 8px 0"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "cst.department") %>: <%= d.getName() %></h2>
        <div class="toolbar">
        <div></div>
        <div style="display:flex;gap:8px">
            <a href="#members" class="btn btn-outline">Our Members</a>
                <a href="#members" class="btn btn-outline"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.members") %></a>
        </div>
    </div>
    <!-- Add New Volunteer removed from this page. Use Add Member flow elsewhere. -->
    <div style="display:grid;grid-template-columns:320px 1fr;gap:18px;margin-block-start:12px;">
        <div class="card" style="padding:12px;">
            <h3 style="margin:0 0 8px 0;">Members</h3>
                <h3 style="margin:0 0 8px 0;"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.members") %></h3>
            <div style="display:grid;gap:8px;max-block-size:64vh;overflow:auto;padding-block-start:6px;">
                <% int idx = 0; for (CstVolunteer v : vs) { %>
                    <button type="button" class="btn btn-outline" style="text-align:start;justify-content:flex-start;font-size:1.02em;padding:10px 14px;display:flex;align-items:center;gap:10px;" onclick="showVolunteerDetail(<%= v.getId() %>)">
                        <img src="<%= v.getPhotoUrl()!=null? v.getPhotoUrl() : "https://via.placeholder.com/240" %>" alt="photo" style="inline-size:40px;block-size:40px;border-radius:50%;object-fit:cover;border:1px solid #e5e7eb;"/>
                        <div style="display:flex;flex-direction:column;align-items:flex-start">
                            <strong><%= v.getPassportName()!=null?v.getPassportName():"Unnamed" %></strong>
                            <span style="color:#666;font-size:0.9em;"><%= v.getChineseName()!=null?v.getChineseName():"" %></span>
                        </div>
                    </button>
                <% idx++; } %>
            </div>
        </div>
        <div id="volunteerDetailContainer" class="card" style="min-height:320px;">
            <div style="display:grid;place-items:center;padding:28px;color:#6b7280">Select a member to view and edit their information.</div>
                <div style="display:grid;place-items:center;padding:28px;color:#6b7280"><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "vol.update.success") %></div>
        </div>
    </div>
    <script>
    function previewAddPhoto(event) {
        const [file] = event.target.files;
        if (file) {
            const reader = new FileReader();
            reader.onload = e => {
                document.getElementById('addPhotoPreview').src = e.target.result;
            };
            reader.readAsDataURL(file);
        }
    }
    </script>
    <!-- members list is shown in the left column above; removed duplicate block -->
    <script>
    // Store departmentId as a JS variable
    const departmentId = <%= d.getId() %>;
    // Store all volunteer data in a JS object for quick lookup
    const volunteers = [
        <% for (CstVolunteer v : vs) { %>{
            id: <%= v.getId() %>,
            passportName: "<%= v.getPassportName()!=null?v.getPassportName().replace("\"","\\\""):"" %>",
            chineseName: "<%= v.getChineseName()!=null?v.getChineseName().replace("\"","\\\""):"" %>",
            studentId: "<%= v.getStudentId()!=null?v.getStudentId().replace("\"","\\\""):"" %>",
            phone: "<%= v.getPhone()!=null?v.getPhone().replace("\"","\\\""):"" %>",
            gender: "<%= v.getGender()!=null?v.getGender():"" %>",
            nationality: "<%= v.getNationality()!=null?v.getNationality().replace("\"","\\\""):"" %>",
            photoUrl: "<%= v.getPhotoUrl()!=null?v.getPhotoUrl().replace("\"","\\\""):"" %>"
        },<% } %>
    ];
    function showVolunteerDetail(id) {
        const v = volunteers.find(x => x.id === id);
        if (!v) return;
        let html = `<div class='card' style='margin-block-start:8px;'>
            <form method='post' action='admin-cst-volunteers' enctype='multipart/form-data' style='display:grid;gap:12px;'>
                <%@ include file="/WEB-INF/jspf/csrf-token.jspf" %>
                <input type='hidden' name='action' value='update' />
                <input type='hidden' name='id' value='${v.id}' />
                <input type='hidden' name='department_id' value='${departmentId}' />
                <div style='display:flex;flex-direction:column;align-items:center;gap:8px;'>
                    <img class='photo-lg' src='${v.photoUrl || "https://via.placeholder.com/240"}' alt='Volunteer photo' style='inline-size:240px;block-size:240px;' />
                    <label class='label' for='photo_file' style='margin-block-end:2px;'>Upload New Photo</label>
                        <label class='label' for='photo_file' style='margin-bottom:2px;'><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.uploadPhoto") %></label>
                    <input style='padding:6px 10px;font-size:15px;border-radius:6px;inline-size:260px;' type='file' id='photo_file' name='photo_file' accept='image/*' />
                </div>
                <div style='display:grid;gap:8px;grid-template-columns:1fr 1fr;align-items:end;'>
                    <div style='display:grid;gap:2px;'>
                        <label class='label' for='passport_name'>Passport name</label>
                            <label class='label' for='passport_name'><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "vol.passportName") %></label>
                        <input style='padding:7px 10px;font-size:15px;border-radius:6px;' name='passport_name' id='passport_name' value='${v.passportName}' required />
                    </div>
                    <div style='display:grid;gap:2px;'>
                        <label class='label' for='chinese_name'>Chinese name</label>
                            <label class='label' for='chinese_name'><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "vol.chineseName") %></label>
                        <input style='padding:7px 10px;font-size:15px;border-radius:6px;' name='chinese_name' id='chinese_name' value='${v.chineseName}' />
                    </div>
                    <div style='display:grid;gap:2px;'>
                        <label class='label' for='student_id'>Student ID</label>
                            <label class='label' for='student_id'><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "vol.studentId") %></label>
                        <input style='padding:7px 10px;font-size:15px;border-radius:6px;' name='student_id' id='student_id' value='${v.studentId}' />
                    </div>
                    <div style='display:grid;gap:2px;'>
                        <label class='label' for='phone'>Phone</label>
                            <label class='label' for='phone'><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "vol.phone") %></label>
                        <input style='padding:7px 10px;font-size:15px;border-radius:6px;' name='phone' id='phone' value='${v.phone}' />
                    </div>
                    <div style='display:grid;gap:2px;'>
                        <label class='label' for='gender'>Gender</label>
                            <label class='label' for='gender'><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "vol.gender") %></label>
                        <select style='padding:7px 10px;font-size:15px;border-radius:6px;' name='gender' id='gender'>
                            <option value='Male' ${v.gender==="Male"?"selected":""}>Male</option>
                            <option value='Female' ${v.gender==="Female"?"selected":""}>Female</option>
                        </select>
                    </div>
                    <div style='display:grid;gap:2px;'>
                        <label class='label' for='nationality'>Nationality</label>
                            <label class='label' for='nationality'><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "vol.nationality") %></label>
                        <input style='padding:7px 10px;font-size:15px;border-radius:6px;' name='nationality' id='nationality' value='${v.nationality}' />
                    </div>
                </div>
                <div style='display:flex;justify-content:space-between;align-items:center;margin-block-start:8px;gap:10px;'>
                    <button class='btn btn-primary' type='submit' style='flex:1;'>Save</button>
                    <button class='btn btn-danger' type='button' style='flex:1;' onclick='deleteVolunteer(${v.id})'>Delete</button>
                        <button class='btn btn-primary' type='submit' style='flex:1;'><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.save") %></button>
                        <button class='btn btn-danger' type='button' style='flex:1;' onclick='deleteVolunteer(${v.id})'><%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.delete") %></button>
                </div>
            </form>
        </div>`;
        document.getElementById('volunteerDetailContainer').innerHTML = html;
    }
    function deleteVolunteer(id) {
        if (!confirm('<%= com.smartcalendar.utils.LanguageUtil.getText(lang, "common.confirmDelete") %>')) return;
        const form = document.createElement('form');
        form.method = 'post';
        form.action = 'admin-cst-volunteers';
        form.innerHTML = `<input type='hidden' name='action' value='delete'/><input type='hidden' name='id' value='${id}'/><input type='hidden' name='department_id' value='${departmentId}'/>`;
        document.body.appendChild(form);
        form.submit();
    }
    </script>
    <!-- bottom Go Back removed to declutter; kept in-form Go Back button -->
</div>
</body>
</html>

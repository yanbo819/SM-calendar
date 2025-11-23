<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    boolean isAdmin = user.getRole() != null && user.getRole().equalsIgnoreCase("admin");
%>
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Colleges Information</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;box-shadow:0 1px 2px rgba(0,0,0,.04);padding:24px}
        .page-title{margin:0;font-size:1.5rem;font-weight:600}
        .page-sub{color:#6b7280;margin-top:4px}
        .toolbar{display:flex;gap:12px;flex-wrap:wrap;margin:12px 0}
        .toolbar .search{flex:1 1 260px;position:relative}
        .toolbar input{inline-size:100%;padding:10px 12px;border:1px solid #e5e7eb;border-radius:10px}
        .accordion{border:1px solid #e5e7eb;border-radius:12px;overflow:hidden}
        .accordion-item+.accordion-item{border-top:1px solid #e5e7eb}
        .accordion-header{display:flex;justify-content:space-between;align-items:center;inline-size:100%;padding:14px 16px;background:#f9fafb;border:0;cursor:pointer;text-align:left;font-weight:600}
    .accordion-header.nav-only{cursor:pointer; text-decoration:none; color:inherit}
    .accordion-header.nav-only:hover{background:#f3f4f6}
        .accordion-header:focus{outline:3px solid rgba(83,109,254,.25)}
        .accordion-header .label{display:flex;align-items:center;gap:10px}
        .accordion-header .chev{transition:transform .15s ease;color:#6b7280}
        .accordion-header[aria-expanded="true"] .chev{transform:rotate(90deg)}
        .accordion-panel{display:none;padding:14px}
        .accordion-panel.active{display:block}
    .panel-actions{display:flex;gap:8px;flex-wrap:wrap;margin:0 0 10px 0}
        .teacher-list{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:12px;margin-top:8px}
        .teacher{border:1px solid #e5e7eb;border-radius:10px;padding:12px;background:#fff}
        .teacher h4{margin:0 0 6px 0;font-size:1.05rem}
    .dept-hero{margin:4px 0 12px 0}
    .dept-hero img{display:block;max-inline-size:100%;height:auto;border-radius:10px;border:1px solid #e5e7eb;box-shadow:0 1px 2px rgba(0,0,0,.04)}
    .teacher img{display:block;max-inline-size:100%;height:auto;border-radius:8px;border:1px solid #e5e7eb;margin-bottom:8px;box-shadow:0 1px 2px rgba(0,0,0,.04)}
        .kv{display:flex;gap:6px}
        .kv b{min-inline-size:74px}
        .muted{color:#6b7280}
        .hidden{display:none !important}
        @media (max-width: 640px){ .accordion-header{padding:12px} }
    </style>
</head>
<body>
    <nav class="main-nav">
        <div class="nav-container">
            <h1 class="nav-title"><a href="dashboard">Smart Calendar</a></h1>
            <div class="nav-actions">
                <span class="user-welcome">Welcome, <%= user.getFullName() %>!</span>
            </div>
        </div>
    </nav>

    <div class="form-container">
        <div class="form-header" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
            <div>
                <h2 class="page-title">Colleges Information</h2>
                <div class="page-sub">This page will list colleges and helpful links. Send content to populate it.</div>
            </div>
        </div>
        <div class="card">
            <div class="toolbar">
                <div class="search">
                    <input id="searchBox" type="search" placeholder="Search by college or teacher name..." />
                </div>
                     <% if (isAdmin) { %>
                         <a href="admin-college-teachers" class="btn btn-primary" style="white-space:nowrap;font-size:.75rem;padding:10px 14px;">Manage Teachers</a>
                     <% } %>
            </div>

            <div class="accordion" id="collegeList">
                <div class="accordion-item" data-college="College of Physics and Electronic Information Engineering" data-teachers="蒙晓云 MENG XIAO YUAN">
                    <a class="accordion-header nav-only" href="physics.jsp">
                        <span class="label">College of Physics and Electronic Information Engineering</span>
                        <span class="chev" aria-hidden="true">↗</span>
                    </a>
                    <div class="teacher-inline" style="padding:8px 16px 14px 16px;border-top:1px solid #e5e7eb;background:#fff">
                        <strong style="font-size:.7rem;letter-spacing:.5px;color:#475569;display:block;margin:0 0 6px 0;text-transform:uppercase">Teachers</strong>
                        <div class="teacher-tags" style="display:flex;flex-wrap:wrap;gap:6px"></div>
                    </div>
                </div>

                <div class="accordion-item" data-college="College of Computer Science and Technology" data-teachers="">
                    <a class="accordion-header nav-only" href="computer-science.jsp">
                        <span class="label">College of Computer Science and Technology</span>
                        <span class="chev" aria-hidden="true">↗</span>
                    </a>
                    <div class="teacher-inline" style="padding:8px 16px 14px 16px;border-top:1px solid #e5e7eb;background:#fff">
                        <strong style="font-size:.7rem;letter-spacing:.5px;color:#475569;display:block;margin:0 0 6px 0;text-transform:uppercase">Teachers</strong>
                        <div class="teacher-tags" style="display:flex;flex-wrap:wrap;gap:6px"></div>
                    </div>
                </div>

                <div class="accordion-item" data-college="College of Economics and Management" data-teachers="魏旋 WEI XUAN|傅菲 FU FEI">
                    <a class="accordion-header nav-only" href="economics-management.jsp">
                        <span class="label">College of Economics and Management</span>
                        <span class="chev" aria-hidden="true">↗</span>
                    </a>
                    <div class="teacher-inline" style="padding:8px 16px 14px 16px;border-top:1px solid #e5e7eb;background:#fff">
                        <strong style="font-size:.7rem;letter-spacing:.5px;color:#475569;display:block;margin:0 0 6px 0;text-transform:uppercase">Teachers</strong>
                        <div class="teacher-tags" style="display:flex;flex-wrap:wrap;gap:6px"></div>
                    </div>
                </div>

                <div class="accordion-item" data-college="College of International Education and Social Development" data-teachers="傅廷 FU TING|张炜 ZHANH WEI">
                    <a class="accordion-header nav-only" href="international-education.jsp">
                        <span class="label">College of International Education and Social Development</span>
                        <span class="chev" aria-hidden="true">↗</span>
                    </a>
                    <div class="teacher-inline" style="padding:8px 16px 14px 16px;border-top:1px solid #e5e7eb;background:#fff">
                        <strong style="font-size:.7rem;letter-spacing:.5px;color:#475569;display:block;margin:0 0 6px 0;text-transform:uppercase">Teachers</strong>
                        <div class="teacher-tags" style="display:flex;flex-wrap:wrap;gap:6px"></div>
                    </div>
                </div>
            </div>

            <script>
                (function(){
                    const list = document.getElementById('collegeList');
                    const headers = list.querySelectorAll('.accordion-header:not(.nav-only)');
                    const panels = list.querySelectorAll('.accordion-panel');
                          const items = list.querySelectorAll('.accordion-item');
                          // Populate teacher tags
                          items.forEach(it => {
                              const tagWrap = it.querySelector('.teacher-tags');
                              if(!tagWrap) return;
                              const raw = it.getAttribute('data-teachers') || '';
                              const teachers = raw.split('|').map(t=>t.trim()).filter(Boolean);
                              if(teachers.length === 0){ tagWrap.innerHTML = '<span style="font-size:.6rem;color:#94a3b8">No teachers listed</span>'; return; }
                              teachers.forEach(t => {
                                  const span = document.createElement('span');
                                  span.textContent = t;
                                  span.style.background = '#f1f5f9';
                                  span.style.border = '1px solid #e2e8f0';
                                  span.style.padding = '4px 8px';
                                  span.style.borderRadius = '8px';
                                  span.style.fontSize = '.6rem';
                                  span.style.color = '#334155';
                                  tagWrap.appendChild(span);
                              });
                          });
                    const search = document.getElementById('searchBox');

                    // Toggle accordion
                    headers.forEach(h => {
                        h.addEventListener('click', () => {
                            const expanded = h.getAttribute('aria-expanded') === 'true';
                            // collapse all
                            headers.forEach(x => x.setAttribute('aria-expanded','false'));
                            panels.forEach(p => p.classList.remove('active'));
                            if (!expanded) {
                                h.setAttribute('aria-expanded','true');
                                h.nextElementSibling.classList.add('active');
                            }
                        });
                    });

                    // Filter by college or teacher
                    function norm(s){ return (s||'').toString().toLowerCase().replace(/\s+/g,' ').trim(); }
                    function applyFilter(){
                        const q = norm(search.value);
                        items.forEach(it => {
                            const college = norm(it.dataset.college);
                            const tAttr = it.getAttribute('data-teachers') || '';
                            const teachers = tAttr.split('|').map(norm).filter(Boolean);
                            const match = q.length === 0 || college.includes(q) || teachers.some(t=>t.includes(q));
                            it.classList.toggle('hidden', !match);
                        });
                    }
                    search.addEventListener('input', applyFilter);
                    applyFilter();
                })();
            </script>
        </div>
        <div style="display:grid;place-items:center;margin-top:24px">
            <a href="important-locations.jsp" class="btn btn-outline" style="min-inline-size:160px">Go Back</a>
        </div>
    </div>
</body>
</html>

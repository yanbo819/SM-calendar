<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartcalendar.models.User" %>
<%@ page import="com.smartcalendar.utils.LanguageUtil" %>
<%@ page import="com.smartcalendar.utils.DatabaseUtil" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String lang = "en";
    String textDir = "ltr";
    String errorMessage = (String) request.getAttribute("errorMessage");
    
    // Get form values for repopulation on error
    String title = (String) request.getAttribute("title");
    String categoryId = (String) request.getAttribute("categoryId");
    if ((categoryId == null || categoryId.isEmpty()) && request.getParameter("category") != null) {
        categoryId = request.getParameter("category");
    }
    String subjectName = (String) request.getAttribute("subjectName");
    String existingSubjectId = (String) request.getAttribute("existingSubjectId");
    String description = (String) request.getAttribute("description");
    String eventDate = (String) request.getAttribute("eventDate");
    String eventTime = (String) request.getAttribute("eventTime");
    String duration = (String) request.getAttribute("duration");
    String location = (String) request.getAttribute("location");
    String notes = (String) request.getAttribute("notes");
    String reminderMinutes = (String) request.getAttribute("reminderMinutes");
    String reminder2Val = (String) request.getAttribute("reminder2");
    String reminder3Val = (String) request.getAttribute("reminder3");
%>
<!DOCTYPE html>
<html lang="<%= lang %>" dir="<%= textDir %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= LanguageUtil.getText(lang, "app.title") %> - Create Event</title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/forms.css">
    <style>
        /* Lightweight page-local styling to improve layout & clarity */
        .card {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 12px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.04);
            padding: 24px;
        }
        .page-title { margin: 0; font-size: 1.5rem; font-weight: 600; }
        .page-subtitle { color: #6b7280; margin-top: 4px; }
        .sections { display: grid; gap: 20px; }
        .section { display: grid; gap: 12px; }
        .section h3 { margin: 0; font-size: 1rem; font-weight: 600; color: #374151; }
        .form-grid { display: grid; grid-template-columns: 1fr; gap: 12px; }
        @media (min-width: 768px) { .form-grid.cols-2 { grid-template-columns: 1fr 1fr; } }
        .btn-chip { border: 1px solid #e5e7eb; background: #fafafa; padding: 8px 12px; border-radius: 999px; cursor: pointer; font-size: .9rem; }
        .btn-chip.active { background: #eef2ff; border-color: #6366f1; color: #3730a3; }
        .hint { color: #6b7280; font-size: .85rem; }
        .actions { display: flex; gap: 10px; justify-content: flex-end; border-top: 1px dashed #e5e7eb; padding-top: 16px; margin-top: 8px; }
    </style>
</head>
<body>
    <nav class="main-nav">
        <div class="nav-container">
            <h1 class="nav-title">
                <a href="dashboard.jsp"><%= LanguageUtil.getText(lang, "app.title") %></a>
            </h1>
            <div class="nav-actions">
                <span class="user-welcome">
                    <%= LanguageUtil.getText(lang, "dashboard.welcome") %>, <%= user.getFullName() %>!
                </span>
                <a href="logout" class="btn btn-outline">
                    <%= LanguageUtil.getText(lang, "nav.logout") %>
                </a>
            </div>
        </div>
    </nav>

    <div class="form-container">
        <div class="form-header" style="display:flex; align-items:center; justify-content:space-between; gap:12px;">
            <div>
                <h2 class="page-title">Create New Reminder</h2>
                <div class="page-subtitle">Choose a type, add subject, time, and a reminder. You can always edit later.</div>
            </div>
            <a href="dashboard.jsp" class="btn btn-outline">← Back to Dashboard</a>
        </div>

        <% if (errorMessage != null) { %>
        <div class="alert alert-error">
            <%= errorMessage %>
        </div>
        <% } %>

        <form method="post" action="create-event" class="event-form card">
            <div class="sections">
                <!-- Type -->
                <div class="section">
                    <h3>Type</h3>
                    <div class="quick-types" style="display:flex; gap:8px; flex-wrap:wrap">
                        <button type="button" class="btn btn-chip" data-type="Meeting">Meeting</button>
                        <button type="button" class="btn btn-chip" data-type="Course">Course</button>
                        <button type="button" class="btn btn-chip" data-type="Exam">Exam</button>
                        <button type="button" class="btn btn-chip" data-type="Activity">Activity</button>
                        <button type="button" class="btn btn-chip" data-type="Face ID">Face ID</button>
                        <button type="button" class="btn btn-chip" data-type="Others">Others</button>
                    </div>
                    <div class="hint">Pick a type to help categorize this reminder. You can change it later.</div>
                </div>

                <!-- Details: Subject, Location, Reminder before (1-3), Notes -->
                <div class="section">
                    <h3>Details</h3>
                    <div class="form-grid cols-2">
                        <input type="text" id="title" name="title" required maxlength="255"
                               value="<%= title != null ? title : "" %>"
                               placeholder="Subject (required)">
                        <input type="text" id="location" name="location" maxlength="255"
                               value="<%= location != null ? location : "" %>"
                               placeholder="Location (optional)">
                    </div>

                    <div class="form-grid cols-2">
                        <select id="reminder1" name="reminder1" class="form-control" required>
                            <option value="">Reminder before (required)</option>
                            <option value="5" <%= "5".equals(reminderMinutes) ? "selected" : "" %>>5 minutes</option>
                            <option value="15" <%= reminderMinutes == null || "15".equals(reminderMinutes) ? "selected" : "" %>>15 minutes</option>
                            <option value="30" <%= "30".equals(reminderMinutes) ? "selected" : "" %>>30 minutes</option>
                            <option value="60" <%= "60".equals(reminderMinutes) ? "selected" : "" %>>1 hour</option>
                            <option value="1440" <%= "1440".equals(reminderMinutes) ? "selected" : "" %>>1 day</option>
                        </select>
                        <select id="reminder2" name="reminder2" class="form-control">
                            <option value="">+ Add another reminder</option>
                            <option value="5" <%= "5".equals(reminder2Val) ? "selected" : "" %>>5 minutes</option>
                            <option value="15" <%= "15".equals(reminder2Val) ? "selected" : "" %>>15 minutes</option>
                            <option value="30" <%= "30".equals(reminder2Val) ? "selected" : "" %>>30 minutes</option>
                            <option value="60" <%= "60".equals(reminder2Val) ? "selected" : "" %>>1 hour</option>
                            <option value="1440" <%= "1440".equals(reminder2Val) ? "selected" : "" %>>1 day</option>
                        </select>
                    </div>
                    <div class="form-grid cols-2">
                        <select id="reminder3" name="reminder3" class="form-control">
                            <option value="">+ Add third reminder</option>
                            <option value="5" <%= "5".equals(reminder3Val) ? "selected" : "" %>>5 minutes</option>
                            <option value="15" <%= "15".equals(reminder3Val) ? "selected" : "" %>>15 minutes</option>
                            <option value="30" <%= "30".equals(reminder3Val) ? "selected" : "" %>>30 minutes</option>
                            <option value="60" <%= "60".equals(reminder3Val) ? "selected" : "" %>>1 hour</option>
                            <option value="1440" <%= "1440".equals(reminder3Val) ? "selected" : "" %>>1 day</option>
                        </select>
                        <textarea id="notes" name="notes" rows="3" maxlength="1000" placeholder="Notes (optional)"><%= notes != null ? notes : "" %></textarea>
                    </div>
                </div>

                <!-- When: date & time only -->
                <div class="section">
                    <h3>When</h3>
                    <div class="form-grid cols-2">
                        <input type="date" id="eventDate" name="eventDate" required
                               value="<%= eventDate != null ? eventDate : "" %>">
                        <input type="time" id="eventTime" name="eventTime" required
                               value="<%= eventTime != null ? eventTime : "" %>">
                    </div>
                </div>

                <!-- Hidden category chooser populated for mapping quick types -->
                <div class="section" style="display:none">
                    <select id="categoryId" name="categoryId" class="form-control">
                            <option value=""><%= LanguageUtil.getText(lang, "event.category") %></option>
                            <%
                                Connection conn = null;
                                try {
                                    conn = DatabaseUtil.getConnection();
                                    PreparedStatement stmt = conn.prepareStatement("SELECT category_id, category_name, category_color FROM categories ORDER BY category_name");
                                    ResultSet rs = stmt.executeQuery();
                                    while (rs.next()) {
                                        String selected = String.valueOf(rs.getInt("category_id")).equals(categoryId) ? "selected" : "";
                            %>
                                <option value="<%= rs.getInt("category_id") %>" <%= selected %> data-name="<%= rs.getString("category_name") %>">
                                    <%= rs.getString("category_name") %>
                                </option>
                            <%
                                    }
                                } catch (SQLException e) {
                                    // Error fetching categories
                                } finally {
                                    if (conn != null) { try { conn.close(); } catch (SQLException e) {} }
                                }
                            %>
                        </select>
                </div>

                <!-- Extra -->
                <div class="section">
                    <h3>Notes</h3>
                    <textarea id="notes" name="notes" rows="3" maxlength="1000" placeholder="Notes (optional)"><%= notes != null ? notes : "" %></textarea>
                </div>

                <div class="actions">
                    <a href="dashboard.jsp" class="btn btn-secondary">Cancel</a>
                    <button type="submit" class="btn btn-primary">Create Reminder</button>
                </div>
            </div>
        </form>
    </div>

    <script>
        // Quick type chips map to categories by name if present
        document.addEventListener('DOMContentLoaded', function() {
            const chips = document.querySelectorAll('.btn-chip');
            const catSelect = document.getElementById('categoryId');
            chips.forEach(chip => {
                chip.addEventListener('click', () => {
                    const type = chip.getAttribute('data-type');
                    if (!catSelect) return;
                    let found = false;
                    Array.from(catSelect.options).forEach(opt => {
                        if (opt.dataset && opt.dataset.name && opt.dataset.name.toLowerCase() === type.toLowerCase()) {
                            opt.selected = true; found = true;
                        }
                    });
                    if (!found) catSelect.selectedIndex = 0; // leave unassigned if not found
                    // Visually mark selection
                    chips.forEach(c => c.classList.remove('active'));
                    chip.classList.add('active');
                });
            });

            // Initialize active chip based on preselected category (e.g., via URL param)
            if (catSelect) {
                const selected = catSelect.options[catSelect.selectedIndex];
                if (selected && selected.dataset && selected.dataset.name) {
                    const match = Array.from(chips).find(c => c.getAttribute('data-type').toLowerCase() === selected.dataset.name.toLowerCase());
                    if (match) {
                        chips.forEach(c => c.classList.remove('active'));
                        match.classList.add('active');
                    }
                }
            }
        });

        // Set minimum date to today
        document.addEventListener('DOMContentLoaded', function() {
            const today = new Date().toISOString().split('T')[0];
            document.getElementById('eventDate').setAttribute('min', today);
            
            // Set default time if not set
            const eventTimeInput = document.getElementById('eventTime');
            if (!eventTimeInput.value) {
                const now = new Date();
                const hours = String(now.getHours()).padStart(2, '0');
                const minutes = String(Math.ceil(now.getMinutes() / 15) * 15).padStart(2, '0');
                eventTimeInput.value = hours + ':' + (minutes === '60' ? '00' : minutes);
            }
        });

        // Ensure first reminder also maps to legacy reminderMinutes for backend compatibility
        document.querySelector('form.event-form').addEventListener('submit', function() {
            const r1 = document.getElementById('reminder1');
            let legacy = document.createElement('input');
            legacy.type = 'hidden';
            legacy.name = 'reminderMinutes';
            legacy.value = r1 && r1.value ? r1.value : '';
            this.appendChild(legacy);
        });
    </script>
</body>
</html>
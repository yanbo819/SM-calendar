package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import com.smartcalendar.dao.CollegeTeacherDao;
import com.smartcalendar.models.CollegeTeacher;
import com.smartcalendar.models.User;
import com.smartcalendar.utils.LanguageUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/admin-college-teachers"})
public class AdminCollegeTeachersServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.sendRedirect("login.jsp"); return; }
        if (user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) { resp.sendRedirect("dashboard"); return; }
        try {
            Map<String, List<CollegeTeacher>> groups = CollegeTeacherDao.groupedByCollege();
            req.setAttribute("teacherGroups", groups);
        } catch (SQLException e) {
            req.setAttribute("loadError", e.getMessage());
        }
        req.getRequestDispatcher("admin-college-teachers.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.sendRedirect("login.jsp"); return; }
        if (user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) { resp.sendRedirect("dashboard"); return; }
        String action = req.getParameter("action");
        String lang = (String) req.getSession().getAttribute("lang");
        if (lang == null) lang = "en";
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"));
        try {
            if ("add-teacher".equals(action)) {
                String college = req.getParameter("college_name");
                String teacher = req.getParameter("teacher_name");
                if (college == null || teacher == null || college.trim().isEmpty() || teacher.trim().isEmpty()) {
                    if (isAjax) { writeJson(resp, 400, jsonMsg(false, LanguageUtil.getText(lang, "admin.teachers.msg.emptyFields"))); return; }
                } else {
                    CollegeTeacherDao.insert(college.trim(), teacher.trim());
                    if (isAjax) { writeJson(resp, 200, jsonMsg(true, LanguageUtil.getText(lang, "admin.teachers.msg.addSuccess"))); return; }
                }
            } else if ("update-teacher".equals(action)) {
                try {
                    int id = Integer.parseInt(req.getParameter("id"));
                    String teacher = req.getParameter("teacher_name");
                    if (teacher == null || teacher.trim().isEmpty()) {
                        if (isAjax) { writeJson(resp, 400, jsonMsg(false, LanguageUtil.getText(lang, "admin.teachers.msg.emptyFields"))); return; }
                    } else {
                        boolean ok = CollegeTeacherDao.update(id, teacher.trim());
                        if (isAjax) {
                            if (ok) {
                                writeJson(resp, 200, jsonMsg(true, LanguageUtil.getText(lang, "admin.teachers.msg.updateSuccess"))); 
                            } else {
                                writeJson(resp, 400, jsonMsg(false, LanguageUtil.getText(lang, "admin.teachers.msg.invalidId"))); 
                            }
                            return;
                        }
                    }
                } catch (NumberFormatException nfe) {
                    if (isAjax) { writeJson(resp, 400, jsonMsg(false, LanguageUtil.getText(lang, "admin.teachers.msg.invalidId"))); return; }
                }
            } else if ("delete-teacher".equals(action)) {
                try {
                    int id = Integer.parseInt(req.getParameter("id"));
                    boolean ok = CollegeTeacherDao.delete(id);
                    if (isAjax) {
                        if (ok) {
                            writeJson(resp, 200, jsonMsg(true, LanguageUtil.getText(lang, "admin.teachers.msg.deleteSuccess"))); 
                        } else {
                            writeJson(resp, 400, jsonMsg(false, LanguageUtil.getText(lang, "admin.teachers.msg.invalidId"))); 
                        }
                        return;
                    }
                } catch (NumberFormatException nfe) {
                    if (isAjax) { writeJson(resp, 400, jsonMsg(false, LanguageUtil.getText(lang, "admin.teachers.msg.invalidId"))); return; }
                }
            }
        } catch (Throwable e) { // broader catch to avoid unresolved dependency warnings
            if (isAjax) { writeJson(resp, 500, jsonMsg(false, LanguageUtil.getText(lang, "admin.teachers.msg.serverError"))); return; }
        }
        if (!isAjax) resp.sendRedirect("admin-college-teachers");
    }

    private void writeJson(HttpServletResponse resp, int status, String json) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write(json);
    }

    private String jsonMsg(boolean ok, String message) {
        StringBuilder sb = new StringBuilder();
        sb.append('{').append("\"ok\":").append(ok).append(',');
        sb.append("\"message\":\"").append(escape(message)).append("\"}");
        return sb.toString();
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
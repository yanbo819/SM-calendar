package com.smartcalendar.servlets;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;
import java.util.List;

import com.smartcalendar.dao.CstDepartmentDao;
import com.smartcalendar.dao.CstVolunteerDao;
import com.smartcalendar.models.CstDepartment;
import com.smartcalendar.models.CstVolunteer;
import com.smartcalendar.models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet(urlPatterns = {"/admin-cst-volunteers"})
@MultipartConfig
public class AdminCstVolunteersServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.sendRedirect("login.jsp"); return; }
        if (user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) { resp.sendRedirect("dashboard.jsp"); return; }
        String deptStr = req.getParameter("dept");
        int deptId = 0;
        try { deptId = Integer.parseInt(deptStr); } catch (Exception ignored) {}
        if (deptId <= 0) { resp.sendRedirect("admin-cst-team"); return; }
        try {
            CstDepartment d = CstDepartmentDao.findById(deptId);
            if (d == null) { resp.sendRedirect("admin-cst-team"); return; }
            List<com.smartcalendar.models.CstVolunteer> vs = CstVolunteerDao.listByDepartment(deptId);
            req.setAttribute("department", d);
            req.setAttribute("volunteers", vs);
            req.getRequestDispatcher("admin-cst-volunteers.jsp").forward(req, resp);
        } catch (SQLException e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) { resp.sendRedirect("login.jsp"); return; }
        String action = req.getParameter("action");
        int deptId = Integer.parseInt(req.getParameter("department_id"));
        try {
            if ("add".equals(action)) {
                CstVolunteer v = buildVolunteer(req);
                v.setDepartmentId(deptId);
                int newId = CstVolunteerDao.insertReturningId(v);
                String saved = handlePhotoUpload(req, newId);
                if (saved != null) {
                    v.setId(newId);
                    v.setPhotoUrl(saved);
                    CstVolunteerDao.update(v);
                }
            } else if ("update".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                CstVolunteer existing = CstVolunteerDao.findById(id);
                CstVolunteer v = buildVolunteer(req);
                v.setId(id);
                v.setDepartmentId(deptId);
                String saved = handlePhotoUpload(req, id);
                if (saved != null) {
                    v.setPhotoUrl(saved);
                } else if (existing != null) {
                    v.setPhotoUrl(existing.getPhotoUrl());
                }
                CstVolunteerDao.update(v);
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                CstVolunteerDao.delete(id);
            }
        } catch (Exception ignored) {}
        resp.sendRedirect("admin-cst-volunteers?dept=" + deptId + "&noheader=1");
    }

    private CstVolunteer buildVolunteer(HttpServletRequest req) {
        CstVolunteer v = new CstVolunteer();
        v.setPassportName(req.getParameter("passport_name"));
        v.setChineseName(req.getParameter("chinese_name"));
        v.setStudentId(req.getParameter("student_id"));
        v.setPhone(req.getParameter("phone"));
        v.setGender(req.getParameter("gender"));
        v.setNationality(req.getParameter("nationality"));
        // photo_url no longer provided in form; keep null here and preserve existing on update
        v.setActive(true);
        return v;
    }

    private String handlePhotoUpload(HttpServletRequest req, int id) {
        try {
            Part part = req.getPart("photo_file");
            if (part == null || part.getSize() == 0) return null;
            String fileName = part.getSubmittedFileName();
            String ext = "";
            int dot = fileName.lastIndexOf('.');
            if (dot > 0) ext = fileName.substring(dot);
            String relDir = "/uploads/cst";
            String absDir = getServletContext().getRealPath(relDir);
            if (absDir == null) return null; // container may not allow; skip
            File dir = new File(absDir);
            if (!dir.exists()) dir.mkdirs();
            String newName = "vol_" + id + ext;
            File dest = new File(dir, newName);
            try (var in = part.getInputStream()) {
                Files.copy(in, dest.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }
            String relPath = (relDir + "/" + newName).replaceFirst("^/", "");
            // store relPath in DB
            CstVolunteer v = new CstVolunteer();
            v.setId(id);
            v.setDepartmentId(Integer.parseInt(req.getParameter("department_id")));
            v.setPhotoUrl(relPath);
            // slim update: reuse update method with only photo set could overwrite; safer to return relPath
            return relPath;
        } catch (Exception e) {
            return null;
        }
    }
}

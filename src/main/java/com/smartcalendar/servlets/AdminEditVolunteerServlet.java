package com.smartcalendar.servlets;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

import com.smartcalendar.dao.CstVolunteerDao;
import com.smartcalendar.models.CstVolunteer;
import com.smartcalendar.models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet(name = "AdminEditVolunteerServlet", urlPatterns = {"/admin-edit-volunteer"})
@MultipartConfig
public class AdminEditVolunteerServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) {
            resp.sendRedirect("login.jsp");
            return;
        }
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            int deptId = Integer.parseInt(req.getParameter("dept"));
            CstVolunteer v = CstVolunteerDao.findById(id);
            if (v == null) {
                resp.sendRedirect("admin-cst-volunteers?dept=" + deptId);
                return;
            }
            v.setPassportName(req.getParameter("passportName"));
            v.setChineseName(req.getParameter("chineseName"));
            v.setStudentId(req.getParameter("studentId"));
            v.setPhone(req.getParameter("phone"));
            v.setGender(req.getParameter("gender"));
            v.setNationality(req.getParameter("nationality"));
            // Handle photo upload
            Part photoPart = req.getPart("photo_file");
            if (photoPart != null && photoPart.getSize() > 0) {
                String uploadsDir = req.getServletContext().getRealPath("/uploads/cst");
                File uploads = new File(uploadsDir);
                if (!uploads.exists()) uploads.mkdirs();
                String submitted = photoPart.getSubmittedFileName();
                String ext = "";
                int dotIdx = submitted.lastIndexOf('.');
                if (dotIdx > 0 && dotIdx < submitted.length() - 1) {
                    ext = submitted.substring(dotIdx);
                }
                String fileName = "volunteer_" + id + ext;
                File file = new File(uploads, fileName);
                Files.copy(photoPart.getInputStream(), file.toPath(), StandardCopyOption.REPLACE_EXISTING);
                v.setPhotoUrl("uploads/cst/" + fileName);
            }
            CstVolunteerDao.update(v);
            resp.sendRedirect("cst-team-member-detail.jsp?id=" + id + "&dept=" + deptId);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("admin-cst-volunteers?error=1");
        }
    }
}

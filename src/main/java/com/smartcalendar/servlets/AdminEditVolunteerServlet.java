package com.smartcalendar.servlets;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.smartcalendar.dao.CstVolunteerDao;
import com.smartcalendar.models.CstVolunteer;
import com.smartcalendar.models.User;
import com.smartcalendar.utils.LanguageUtil;

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
    private static final Logger LOGGER = Logger.getLogger(AdminEditVolunteerServlet.class.getName());
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) {
            resp.sendRedirect("login.jsp");
            return;
        }
        String lang = (String) req.getSession().getAttribute("lang");
        if (lang == null) lang = "en";
        int id;
        int deptId;
        try {
            id = Integer.parseInt(req.getParameter("id"));
            deptId = Integer.parseInt(req.getParameter("dept"));
        } catch (NumberFormatException nfe) {
            LOGGER.log(Level.WARNING, "Invalid volunteer id or department id", nfe);
            req.getSession().setAttribute("flashError", LanguageUtil.getText(lang, "vol.update.error"));
            resp.sendRedirect("admin-cst-volunteers?error=invalid");
            return;
        }
        try {
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
            Part photoPart = req.getPart("photo_file");
            if (photoPart != null && photoPart.getSize() > 0) {
                String contentType = photoPart.getContentType();
                if (contentType == null || !contentType.startsWith("image/")) {
                    req.getSession().setAttribute("flashError", LanguageUtil.getText(lang, "vol.photo.invalidType"));
                    resp.sendRedirect("admin-cst-volunteers?dept=" + deptId + "&error=invalidType");
                    return;
                }
                String submitted = photoPart.getSubmittedFileName();
                String ext = "";
                int dotIdx = submitted != null ? submitted.lastIndexOf('.') : -1;
                if (dotIdx > 0 && dotIdx < submitted.length() - 1) {
                    ext = submitted.substring(dotIdx).toLowerCase();
                }
                if (!ext.matches("\\.(jpe?g|png|webp|gif)")) {
                    req.getSession().setAttribute("flashError", LanguageUtil.getText(lang, "vol.photo.invalidExtension"));
                    resp.sendRedirect("admin-cst-volunteers?dept=" + deptId + "&error=invalidExt");
                    return;
                }
                SecureRandom rnd = new SecureRandom();
                String fileName = "volunteer_" + id + "_" + System.currentTimeMillis() + "_" + Integer.toHexString(rnd.nextInt(0xFFFF)) + ext;
                String uploadsDir = req.getServletContext().getRealPath("/uploads/cst");
                File uploads = new File(uploadsDir);
                if (!uploads.exists() && !uploads.mkdirs()) {
                    LOGGER.log(Level.SEVERE, "Failed to create uploads directory: {0}", uploadsDir);
                    req.getSession().setAttribute("flashError", LanguageUtil.getText(lang, "vol.update.error"));
                    resp.sendRedirect("admin-cst-volunteers?dept=" + deptId + "&error=dir");
                    return;
                }
                File file = new File(uploads, fileName);
                try (InputStream in = photoPart.getInputStream()) {
                    Files.copy(in, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }
                v.setPhotoUrl("uploads/cst/" + fileName);
            }
            CstVolunteerDao.update(v);
            LOGGER.log(Level.FINE, "Volunteer updated: id={0}, dept={1}", new Object[]{id, deptId});
            req.getSession().setAttribute("flashSuccess", LanguageUtil.getText(lang, "vol.update.success"));
            resp.sendRedirect("cst-team-member-detail.jsp?id=" + id + "&dept=" + deptId);
        } catch (SQLException sqle) {
            LOGGER.log(Level.SEVERE, "SQL error updating volunteer", sqle);
            req.getSession().setAttribute("flashError", LanguageUtil.getText(lang, "vol.update.error"));
            resp.sendRedirect("admin-cst-volunteers?dept=" + deptId + "&error=sql");
        } catch (IOException ioe) {
            LOGGER.log(Level.SEVERE, "IO error updating volunteer", ioe);
            req.getSession().setAttribute("flashError", LanguageUtil.getText(lang, "vol.update.error"));
            resp.sendRedirect("admin-cst-volunteers?dept=" + deptId + "&error=io");
        } catch (ServletException se) {
            LOGGER.log(Level.SEVERE, "Servlet error updating volunteer", se);
            req.getSession().setAttribute("flashError", LanguageUtil.getText(lang, "vol.update.error"));
            resp.sendRedirect("admin-cst-volunteers?dept=" + deptId + "&error=servlet");
        } catch (RuntimeException re) {
            LOGGER.log(Level.SEVERE, "Runtime error updating volunteer", re);
            req.getSession().setAttribute("flashError", LanguageUtil.getText(lang, "vol.update.error"));
            resp.sendRedirect("admin-cst-volunteers?dept=" + deptId + "&error=runtime");
        }
    }
}

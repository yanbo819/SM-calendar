package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Locale;

import com.smartcalendar.dao.CstVolunteerDao;
import com.smartcalendar.models.CstVolunteer;
import com.smartcalendar.models.User;
import com.smartcalendar.utils.ImageUploadUtil;
import com.smartcalendar.utils.LanguageUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet(urlPatterns = {"/edit-volunteer"})
@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class EditVolunteerServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || user.getRole()==null || !user.getRole().equalsIgnoreCase("admin")) {
            resp.sendRedirect("login.jsp");
            return;
        }
        int id = -1; try { id = Integer.parseInt(req.getParameter("id")); } catch(Exception ignore) {}
        int deptId = -1; try { deptId = Integer.parseInt(req.getParameter("dept")); } catch(Exception ignore) {}
        if (id <= 0) { resp.sendRedirect("college-volunteers.jsp"); return; }
        CstVolunteer existing; try { existing = CstVolunteerDao.findById(id); } catch (SQLException e) { existing = null; }
        if (existing == null) { resp.sendRedirect("college-volunteers.jsp"); return; }
        String passportName = req.getParameter("passportName");
        if (passportName == null || passportName.trim().isEmpty()) {
            req.getSession().setAttribute("flashError", "Missing name");
            resp.sendRedirect("edit-volunteer.jsp?id=" + id + "&dept=" + deptId + "&error=name");
            return;
        }
        String email = req.getParameter("email");
        if (email != null && !email.isEmpty()) {
            String lower = email.toLowerCase(Locale.ROOT);
            if (!lower.matches("^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$")) {
                String lang = (String) req.getSession().getAttribute("lang"); if (lang==null) lang="en";
                req.getSession().setAttribute("flashError", LanguageUtil.getText(lang, "admin.volunteer.invalidEmail"));
                resp.sendRedirect("edit-volunteer.jsp?id=" + id + "&dept=" + deptId + "&error=email");
                return;
            }
        }
        existing.setPassportName(passportName.trim());
        existing.setChineseName(trim(req.getParameter("chineseName")));
        existing.setNationality(trim(req.getParameter("nationality")));
        existing.setPhone(trim(req.getParameter("phone")));
        existing.setEmail(trim(email));
        // photo update optional
        try {
            Part photoPart = req.getPart("photoFile");
            String newPath = ImageUploadUtil.storeVolunteerImage(photoPart, req);
            if (newPath != null) existing.setPhotoUrl(newPath);
        } catch (IOException ioEx) {
            // Error message already set; redirect back to form
            resp.sendRedirect("edit-volunteer.jsp?id=" + id + "&dept=" + deptId + "&error=img");
            return;
        }
        try {
            CstVolunteerDao.update(existing);
            String lang = (String) req.getSession().getAttribute("lang"); if (lang == null) lang = "en";
            req.getSession().setAttribute("flashSuccess", com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.volunteer.editSuccess"));
            // Analytics logging for edit
            com.smartcalendar.utils.AnalyticsLog.log(user.getUsername(), "/edit-volunteer", "id=" + id + "&deptId=" + deptId);
        } catch (SQLException e) {
            String lang = (String) req.getSession().getAttribute("lang"); if (lang == null) lang = "en";
            req.getSession().setAttribute("flashError", com.smartcalendar.utils.LanguageUtil.getText(lang, "vol.update.error"));
        }
        resp.sendRedirect("cst-team-member-detail.jsp?id=" + id + "&dept=" + deptId);
    }
    private String trim(String s){ return s==null?null:s.trim(); }
}

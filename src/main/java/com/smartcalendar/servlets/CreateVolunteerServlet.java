package com.smartcalendar.servlets;

import java.io.IOException;
// Removed unused imports after refactor
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

@WebServlet(urlPatterns = {"/create-volunteer"})
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // 5MB
public class CreateVolunteerServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || user.getRole()==null || !user.getRole().equalsIgnoreCase("admin")) {
            resp.sendRedirect("login.jsp");
            return;
        }
        String deptIdStr = req.getParameter("deptId");
        int deptId = -1;
        try { deptId = Integer.parseInt(deptIdStr); } catch(Exception ignored) {}
        if (deptId <= 0) { resp.sendRedirect("college-volunteers.jsp"); return; }
        String passportName = req.getParameter("passportName");
        if (passportName == null || passportName.trim().isEmpty()) {
            resp.sendRedirect("add-volunteer.jsp?dept=" + deptId + "&error=name");
            return;
        }
        // Basic email validation
        String email = param(req,"email");
        if (email != null && !email.isEmpty()) {
            String lower = email.toLowerCase(Locale.ROOT);
            if (!lower.matches("^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$")) {
                String lang = (String) req.getSession().getAttribute("lang"); if (lang==null) lang="en";
                req.getSession().setAttribute("flashError", LanguageUtil.getText(lang, "admin.volunteer.invalidEmail"));
                resp.sendRedirect("add-volunteer.jsp?dept=" + deptId + "&error=email");
                return;
            }
        }
        CstVolunteer v = new CstVolunteer();
        v.setDepartmentId(deptId);
        v.setPassportName(passportName.trim());
        v.setChineseName(param(req,"chineseName"));
        v.setNationality(param(req,"nationality"));
        v.setPhone(param(req,"phone"));
        v.setEmail(email);
        // Secure image upload
        String photoPath = null;
        try {
            Part photoPart = req.getPart("photoFile");
            photoPath = ImageUploadUtil.storeVolunteerImage(photoPart, req);
        } catch (IOException ioEx) {
            // Error message already set in session by util
            resp.sendRedirect("add-volunteer.jsp?dept=" + deptId + "&error=img");
            return;
        }
        v.setPhotoUrl(photoPath);
        v.setActive(true);
        try {
            CstVolunteerDao.insert(v);
            String lang = (String) req.getSession().getAttribute("lang");
            if (lang == null) lang = "en";
            String msg = com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.volunteer.createSuccess");
            req.getSession().setAttribute("flashSuccess", msg);
        } catch (SQLException e) {
            String lang = (String) req.getSession().getAttribute("lang");
            if (lang == null) lang = "en";
            String err = com.smartcalendar.utils.LanguageUtil.getText(lang, "vol.update.error");
            req.getSession().setAttribute("flashError", err);
            resp.sendRedirect("add-volunteer.jsp?dept=" + deptId + "&error=db");
            return;
        }
        resp.sendRedirect("cst-team-members.jsp?dept=" + deptId);
    }
    private String param(HttpServletRequest req, String k) {
        String v = req.getParameter(k);
        return v==null?null:v.trim();
    }
}

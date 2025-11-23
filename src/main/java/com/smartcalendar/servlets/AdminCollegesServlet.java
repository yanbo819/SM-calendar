package com.smartcalendar.servlets;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.smartcalendar.dao.CollegeDao;
import com.smartcalendar.models.College;
import com.smartcalendar.models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet(name = "AdminCollegesServlet", urlPatterns = {"/admin-colleges"})
@MultipartConfig
public class AdminCollegesServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AdminCollegesServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) {
            resp.sendRedirect("login.jsp");
            return;
        }
        List<College> colleges = CollegeDao.listAll();
        req.setAttribute("colleges", colleges);
        req.getRequestDispatcher("admin-colleges.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) {
            resp.sendRedirect("login.jsp");
            return;
        }
        String idStr = req.getParameter("id");
        int id;
        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException nfe) {
            LOGGER.log(Level.WARNING, "Invalid college id: {0}", idStr);
            resp.sendRedirect("admin-colleges?error=invalidId");
            return;
        }
        College c = CollegeDao.findById(id);
        if (c == null) {
            resp.sendRedirect("admin-colleges?error=notFound");
            return;
        }
        c.setName(req.getParameter("name"));
        c.setAddress(req.getParameter("address"));
        c.setPhone(req.getParameter("phone"));
        c.setTeacherName(req.getParameter("teacherName"));

        Part photoPart = req.getPart("teacherPhoto");
        if (photoPart != null && photoPart.getSize() > 0) {
            try {
                String uploadsDir = req.getServletContext().getRealPath("/uploads/colleges");
                File uploads = new File(uploadsDir);
                if (!uploads.exists()) uploads.mkdirs();
                String submitted = photoPart.getSubmittedFileName();
                String ext = "";
                int dotIdx = submitted.lastIndexOf('.');
                if (dotIdx > 0 && dotIdx < submitted.length() - 1) ext = submitted.substring(dotIdx);
                String fileName = "teacher_" + id + ext;
                File file = new File(uploads, fileName);
                Files.copy(photoPart.getInputStream(), file.toPath(), StandardCopyOption.REPLACE_EXISTING);
                c.setTeacherPhotoUrl("uploads/colleges/" + fileName);
            } catch (IOException io) {
                LOGGER.log(Level.SEVERE, "Failed to store teacher photo for college id=" + id, io);
                resp.sendRedirect("admin-colleges?error=photo");
                return;
            }
        }
        CollegeDao.update(c);
        resp.sendRedirect("admin-colleges?success=1");
    }
}

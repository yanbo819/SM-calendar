package com.smartcalendar.servlets;

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
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.List;

@WebServlet(name = "AdminCollegesServlet", urlPatterns = {"/admin-colleges"})
@MultipartConfig
public class AdminCollegesServlet extends HttpServlet {
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
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            College c = CollegeDao.findById(id);
            if (c == null) {
                resp.sendRedirect("admin-colleges");
                return;
            }
            c.setName(req.getParameter("name"));
            c.setAddress(req.getParameter("address"));
            c.setPhone(req.getParameter("phone"));
            c.setTeacherName(req.getParameter("teacherName"));
            // Handle teacher photo upload
            Part photoPart = req.getPart("teacherPhoto");
            if (photoPart != null && photoPart.getSize() > 0) {
                String uploadsDir = req.getServletContext().getRealPath("/uploads/colleges");
                File uploads = new File(uploadsDir);
                if (!uploads.exists()) uploads.mkdirs();
                String ext = photoPart.getSubmittedFileName().substring(photoPart.getSubmittedFileName().lastIndexOf('.'));
                String fileName = "teacher_" + id + ext;
                File file = new File(uploads, fileName);
                Files.copy(photoPart.getInputStream(), file.toPath(), StandardCopyOption.REPLACE_EXISTING);
                c.setTeacherPhotoUrl("uploads/colleges/" + fileName);
            }
            CollegeDao.update(c);
            resp.sendRedirect("admin-colleges");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("admin-colleges?error=1");
        }
    }
}

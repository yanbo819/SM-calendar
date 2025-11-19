package com.smartcalendar.servlets;

import java.io.IOException;
import java.util.List;

import com.smartcalendar.dao.UserFaceDao;
import com.smartcalendar.models.FaceEnrollment;
import com.smartcalendar.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/admin-face-enrollments"})
public class AdminFaceEnrollmentsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        if (user == null || user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) {
            resp.sendRedirect("login.jsp");
            return;
        }
        try {
            List<FaceEnrollment> faces = UserFaceDao.listEnrollments();
            req.setAttribute("faces", faces);
        } catch (Exception e) {
            req.setAttribute("loadError", "Unable to load face enrollments");
        }
        req.getRequestDispatcher("admin-face-enrollments.jsp").forward(req, resp);
    }
}

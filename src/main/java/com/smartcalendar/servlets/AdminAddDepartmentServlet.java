package com.smartcalendar.servlets;

import java.io.IOException;

import com.smartcalendar.dao.CstDepartmentDao;
import com.smartcalendar.models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/admin-add-department"})
public class AdminAddDepartmentServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) {
            resp.sendRedirect("login.jsp");
            return;
        }
        req.getRequestDispatcher("admin-add-department.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) {
            resp.sendRedirect("login.jsp");
            return;
        }
        String name = req.getParameter("name");
        String leaderName = req.getParameter("leader_name");
        String leaderPhone = req.getParameter("leader_phone");
        if (name != null && !name.trim().isEmpty()) {
            try {
                CstDepartmentDao.insert(name.trim(),
                        leaderName == null ? "" : leaderName.trim(),
                        leaderPhone == null ? "" : leaderPhone.trim());
            } catch (Exception ignored) {}
        }
        resp.sendRedirect("admin-cst-team");
    }
}

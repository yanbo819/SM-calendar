package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.SQLException;

import com.smartcalendar.dao.CstDepartmentDao;
import com.smartcalendar.models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/create-department"})
public class CreateDepartmentServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || user.getRole()==null || !user.getRole().equalsIgnoreCase("admin")) {
            resp.sendRedirect("login.jsp");
            return;
        }
        String name = req.getParameter("name");
        String leaderName = req.getParameter("leaderName");
        String leaderPhone = req.getParameter("leaderPhone");
        String variant = req.getParameter("variant");
        if (name == null || name.trim().isEmpty()) {
            resp.sendRedirect("add-department.jsp?variant=" + (variant!=null?variant:"generic") + "&error=name");
            return;
        }
        try {
            CstDepartmentDao.insert(name.trim(), leaderName!=null?leaderName.trim():null, leaderPhone!=null?leaderPhone.trim():null);
            req.getSession().setAttribute("flashSuccess", "Department created successfully.");
        } catch (SQLException e) {
            req.getSession().setAttribute("flashError", "Failed to create department.");
            resp.sendRedirect("add-department.jsp?variant=" + (variant!=null?variant:"generic") + "&error=db");
            return;
        }
        if ("business".equals(variant)) {
            resp.sendRedirect("business-admin");
        } else if ("chinese".equals(variant)) {
            resp.sendRedirect("chinese-volunteers");
        } else {
            resp.sendRedirect("college-volunteers.jsp");
        }
    }
}

package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.smartcalendar.dao.CstDepartmentDao;
import com.smartcalendar.dao.CstVolunteerDao;
import com.smartcalendar.models.CstDepartment;
import com.smartcalendar.models.CstVolunteer;
import com.smartcalendar.models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/cst-team"})
public class CstTeamServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.sendRedirect("login.jsp"); return; }
        try {
            List<CstDepartment> deps = CstDepartmentDao.listAll();
            Map<Integer, List<CstVolunteer>> members = new HashMap<>();
            for (CstDepartment d : deps) {
                members.put(d.getId(), CstVolunteerDao.listByDepartment(d.getId()));
            }
            req.setAttribute("departments", deps);
            req.setAttribute("members", members);
            req.getRequestDispatcher("cst-team.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}

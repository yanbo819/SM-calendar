package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

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

@WebServlet(urlPatterns = {"/admin-cst-team"})
public class AdminCstTeamServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.sendRedirect("login.jsp"); return; }
        if (user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) { resp.sendRedirect("dashboard.jsp"); return; }
        try {
            List<CstDepartment> deps = CstDepartmentDao.listAll();
            req.setAttribute("departments", deps);
            req.getRequestDispatcher("admin-cst-team.jsp").forward(req, resp);
        } catch (SQLException e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) { resp.sendRedirect("login.jsp"); return; }
        String action = req.getParameter("action");
        try {
            if ("add-department".equals(action)) {
                String name = req.getParameter("name");
                String leaderName = req.getParameter("leader_name");
                String leaderPhone = req.getParameter("leader_phone");
                if (name != null && !name.trim().isEmpty()) {
                    CstDepartmentDao.insert(name.trim(),
                            leaderName == null ? "" : leaderName.trim(),
                            leaderPhone == null ? "" : leaderPhone.trim());
                }
            } else if ("update-department".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                String name = req.getParameter("name");
                String leaderName = req.getParameter("leader_name");
                String leaderPhone = req.getParameter("leader_phone");
                if (name != null && !name.trim().isEmpty()) {
                    CstDepartmentDao.update(id, name.trim(),
                            leaderName == null ? "" : leaderName.trim(),
                            leaderPhone == null ? "" : leaderPhone.trim());
                }
            } else if ("delete-department".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                CstDepartmentDao.delete(id);
            } else if ("add-volunteer".equals(action)) {
                CstVolunteer v = buildVolunteerFromReq(req);
                CstVolunteerDao.insert(v);
            } else if ("update-volunteer".equals(action)) {
                CstVolunteer v = buildVolunteerFromReq(req);
                v.setId(Integer.parseInt(req.getParameter("id")));
                CstVolunteerDao.update(v);
            } else if ("delete-volunteer".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                CstVolunteerDao.delete(id);
            }
        } catch (Exception ignored) { }
        resp.sendRedirect("admin-cst-team");
    }

    private CstVolunteer buildVolunteerFromReq(HttpServletRequest req) {
        CstVolunteer v = new CstVolunteer();
        v.setDepartmentId(Integer.parseInt(req.getParameter("department_id")));
        v.setPhone(req.getParameter("phone"));
        v.setStudentId(req.getParameter("student_id"));
        v.setPassportName(req.getParameter("passport_name"));
        v.setChineseName(req.getParameter("chinese_name"));
        v.setGender(req.getParameter("gender"));
        v.setNationality(req.getParameter("nationality"));
        v.setPhotoUrl(req.getParameter("photo_url"));
        v.setActive(true);
        return v;
    }
}

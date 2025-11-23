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
import com.smartcalendar.utils.DatabaseUtil;

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
            // Attempt lightweight schema patch for missing email column
            try (var conn = DatabaseUtil.getConnection(); var stmt = conn.createStatement()) {
                try { stmt.executeUpdate("ALTER TABLE cst_volunteers ADD COLUMN email VARCHAR(255)"); } catch (SQLException ignore) {}
            } catch (SQLException ignore) {}
            List<CstDepartment> deps = CstDepartmentDao.listAll();
            Map<Integer,Integer> volunteerCounts = new HashMap<>();
            for (CstDepartment d : deps) {
                int count = 0;
                try { count = CstVolunteerDao.listByDepartment(d.getId()).size(); } catch (SQLException ignored) {}
                volunteerCounts.put(d.getId(), count);
            }
            req.setAttribute("departments", deps);
            req.setAttribute("volunteerCounts", volunteerCounts);
            req.getRequestDispatcher("admin-cst-team.jsp").forward(req, resp);
        } catch (SQLException e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || user.getRole() == null || !user.getRole().equalsIgnoreCase("admin")) { resp.sendRedirect("login.jsp"); return; }
        String action = req.getParameter("action");
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"));
        resp.setCharacterEncoding("UTF-8");
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
                if (isAjax) { writeJson(resp, 200, "{\"ok\":true}"); return; }
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
                if (isAjax) { writeJson(resp, 200, "{\"ok\":true,\"id\":"+id+",\"name\":\""+escapeJson(name)+"\"}"); return; }
            } else if ("delete-department".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                CstDepartmentDao.delete(id);
                if (isAjax) { writeJson(resp, 200, "{\"ok\":true,\"deleted\":"+id+"}"); return; }
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
        if (!isAjax) resp.sendRedirect("admin-cst-team");
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

    private void writeJson(HttpServletResponse resp, int status, String json) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write(json);
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}

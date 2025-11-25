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
import com.smartcalendar.utils.DepartmentFilterUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/business-admin"})
public class BusinessAdminServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.sendRedirect("login.jsp"); return; }
        try {
            List<CstDepartment> allDeps = CstDepartmentDao.listAll();
            List<CstDepartment> businessDeps = DepartmentFilterUtil.filterBusiness(allDeps);
            String q = req.getParameter("q");
            if (q != null && !q.trim().isEmpty()) {
                String qNorm = q.trim().toLowerCase();
                businessDeps.removeIf(d -> d.getName() == null || !d.getName().toLowerCase().contains(qNorm));
                req.setAttribute("searchQuery", q);
            }
            // pagination parameters
            int page = 1; int size = 10;
            try { page = Math.max(1, Integer.parseInt(req.getParameter("page"))); } catch (Exception ignore) {}
            try { size = Math.max(1, Math.min(50, Integer.parseInt(req.getParameter("size")))); } catch (Exception ignore) {}
            int total = businessDeps.size();
            int totalPages = (int) Math.ceil(total / (double) size);
            if (page > totalPages && totalPages > 0) page = totalPages;
            int from = (page - 1) * size;
            int to = Math.min(from + size, total);
            List<CstDepartment> paged = businessDeps.subList(from, to);
            Map<Integer, List<CstVolunteer>> members = new HashMap<>();
            for (CstDepartment d : paged) {
                members.put(d.getId(), CstVolunteerDao.listByDepartment(d.getId()));
            }
            if (businessDeps.isEmpty()) {
                req.setAttribute("emptyBusiness", Boolean.TRUE);
            }
            req.setAttribute("departments", paged);
            req.setAttribute("page", page);
            req.setAttribute("size", size);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("totalCount", total);
            req.setAttribute("hasNext", page < totalPages);
            req.setAttribute("hasPrev", page > 1);
            // analytics logging
            String userId = user.getUsername();
            String queryParams = "q=" + (q!=null?q:"") + "&page=" + page + "&size=" + size;
            com.smartcalendar.utils.AnalyticsLog.log(userId, "/business-admin", queryParams);
            req.setAttribute("members", members);
            req.getRequestDispatcher("business-admin.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
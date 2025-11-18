package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Time;
import java.util.List;

import com.smartcalendar.dao.FaceConfigDao;
import com.smartcalendar.models.FaceConfig;
import com.smartcalendar.models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/admin-face-config"})
public class FaceConfigServlet extends HttpServlet {
    private boolean isAdmin(User user) {
        if (user == null) return false;
        return "admin".equalsIgnoreCase(user.getRole());
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (!isAdmin(user)) { resp.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }
        try {
            List<FaceConfig> windows = FaceConfigDao.getActiveWindows();
            req.setAttribute("windows", windows);
            req.getRequestDispatcher("/admin-face-config.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Failed to load face config", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (!isAdmin(user)) { resp.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }

        String action = req.getParameter("action");
        if (action == null) { resp.sendRedirect("admin-face-config?error=Missing+action"); return; }
        try {
            switch (action) {
                case "create": {
                    int day = Integer.parseInt(req.getParameter("dayOfWeek"));
                    Time start = Time.valueOf(req.getParameter("start") + ":00");
                    Time end = Time.valueOf(req.getParameter("end") + ":00");
                    FaceConfig fc = new FaceConfig();
                    fc.setDayOfWeek(day);
                    fc.setStartTime(start);
                    fc.setEndTime(end);
                    fc.setActive(true);
                    FaceConfigDao.insert(fc);
                    break;
                }
                case "update": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    int uDay = Integer.parseInt(req.getParameter("dayOfWeek"));
                    Time uStart = Time.valueOf(req.getParameter("start") + ":00");
                    Time uEnd = Time.valueOf(req.getParameter("end") + ":00");
                    String activeParam = req.getParameter("active");
                    boolean active = (activeParam == null) ? true : ("on".equals(activeParam) || "true".equalsIgnoreCase(activeParam));
                    FaceConfig up = new FaceConfig();
                    up.setId(id);
                    up.setDayOfWeek(uDay);
                    up.setStartTime(uStart);
                    up.setEndTime(uEnd);
                    up.setActive(active);
                    FaceConfigDao.update(up);
                    break;
                }
                case "delete": {
                    int delId = Integer.parseInt(req.getParameter("id"));
                    FaceConfigDao.delete(delId);
                    break;
                }
                default: {
                    resp.sendRedirect("admin-face-config?error=Unknown+action");
                    return;
                }
            }
        } catch (SQLException | IllegalArgumentException ex) {
            resp.sendRedirect("admin-face-config?error=Operation+failed");
            return;
        }
        resp.sendRedirect("admin-face-config?success=Done");
    }
}

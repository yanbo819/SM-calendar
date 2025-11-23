package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Time;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

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
    private static final Logger LOG = Logger.getLogger(FaceConfigServlet.class.getName());
    private boolean isAdmin(User user) {
        if (user == null) return false;
        return "admin".equalsIgnoreCase(user.getRole());
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (!isAdmin(user)) { resp.sendRedirect("dashboard?error=Not+authorized"); return; }
        try {
            List<FaceConfig> windows = FaceConfigDao.getActiveWindows();
            req.setAttribute("windows", windows);
            req.getRequestDispatcher("/admin-face-config.jsp").forward(req, resp);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Failed to load face config windows", e);
            resp.sendRedirect("admin-face-config?error=Failed+to+load+face+config");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (!isAdmin(user)) { resp.sendRedirect("dashboard?error=Not+authorized"); return; }

        String action = req.getParameter("action");
        if (action == null) { resp.sendRedirect("admin-face-config?error=Missing+action"); return; }
        try {
            switch (action) {
                case "create": {
                    String dayParam = req.getParameter("dayOfWeek");
                    String startParam = req.getParameter("start");
                    String endParam = req.getParameter("end");
                    if (dayParam == null || startParam == null || endParam == null) {
                        resp.sendRedirect("admin-face-config?error=Missing+parameters");
                    }
                    int day = Integer.parseInt(dayParam);
                    Time start = Time.valueOf(normalizeTime(startParam));
                    Time end = Time.valueOf(normalizeTime(endParam));
                    FaceConfig fc = new FaceConfig();
                    fc.setDayOfWeek(day);
                    fc.setStartTime(start);
                    fc.setEndTime(end);
                    fc.setActive(true);
                    FaceConfigDao.insert(fc);
                    break;
                }
                case "update": {
                    String idParam = req.getParameter("id");
                    String uDayParam = req.getParameter("dayOfWeek");
                    String uStartParam = req.getParameter("start");
                    String uEndParam = req.getParameter("end");
                    if (idParam == null || uDayParam == null || uStartParam == null || uEndParam == null) {
                        resp.sendRedirect("admin-face-config?error=Missing+parameters");
                    }
                    int id = Integer.parseInt(idParam);
                    int uDay = Integer.parseInt(uDayParam);
                    Time uStart = Time.valueOf(normalizeTime(uStartParam));
                    Time uEnd = Time.valueOf(normalizeTime(uEndParam));
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
                }
            }
        } catch (SQLException | IllegalArgumentException ex) {
            LOG.log(Level.WARNING, "Face config operation failed", ex);
            String msg = "Operation+failed";
            if (ex instanceof IllegalArgumentException) msg = "Invalid+time+format";
            resp.sendRedirect("admin-face-config?error=" + msg);
        } finally {
            // no-op; could add audit logging here later
        }
        resp.sendRedirect("admin-face-config?success=Done");
    }

    // Accepts "HH:mm" or "H:mm" or "HH:mm:ss" and returns "HH:mm:ss" for Time.valueOf
    private static String normalizeTime(String t) {
        if (t == null) throw new IllegalArgumentException("time is null");
        t = t.trim();
        if (t.matches("^\\d{1,2}:\\d{2}$")) return (t.length() == 4 ? "0" + t : t) + ":00";
        if (t.matches("^\\d{1,2}:\\d{2}:\\d{2}$")) return (t.length() == 7 ? "0" + t : t);
        throw new IllegalArgumentException("Invalid time: " + t);
    }
}

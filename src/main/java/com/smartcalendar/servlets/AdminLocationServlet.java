package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import com.smartcalendar.dao.LocationDao;
import com.smartcalendar.models.Location;
import com.smartcalendar.models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/admin-locations"})
public class AdminLocationServlet extends HttpServlet {
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
            String category = req.getParameter("category");
            List<Location> list;
            if (category != null && !category.trim().isEmpty()) {
                list = LocationDao.listByCategory(category.trim());
            } else {
                list = LocationDao.listAll();
            }
            req.setAttribute("locations", list);
            req.setAttribute("currentCategory", category);
            req.getRequestDispatcher("/admin-locations.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Failed to load locations", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (!isAdmin(user)) { resp.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }

        String action = req.getParameter("action");
        if (action == null) { resp.sendRedirect("admin-locations?error=Missing+action"); return; }
        try {
            switch (action) {
                case "create":
                    Location l = new Location();
                    l.setName(req.getParameter("name"));
                    l.setCategory(req.getParameter("category"));
                    l.setDescription(req.getParameter("description"));
                    l.setMapUrl(req.getParameter("mapUrl"));
                    l.setActive("on".equals(req.getParameter("active")) || "true".equalsIgnoreCase(req.getParameter("active")));
                    LocationDao.insert(l);
                    break;
                case "update":
                    Location upd = new Location();
                    upd.setLocationId(Integer.parseInt(req.getParameter("locationId")));
                    upd.setName(req.getParameter("name"));
                    upd.setCategory(req.getParameter("category"));
                    upd.setDescription(req.getParameter("description"));
                    upd.setMapUrl(req.getParameter("mapUrl"));
                    upd.setActive("on".equals(req.getParameter("active")) || "true".equalsIgnoreCase(req.getParameter("active")));
                    LocationDao.update(upd);
                    break;
                case "delete":
                    int id = Integer.parseInt(req.getParameter("locationId"));
                    LocationDao.delete(id);
                    break;
                default:
                    resp.sendRedirect("admin-locations?error=Unknown+action");
                    return;
            }
        } catch (SQLException | NumberFormatException ex) {
            resp.sendRedirect("admin-locations?error=Operation+failed");
            return;
        }
        resp.sendRedirect("admin-locations?success=Done");
    }
}

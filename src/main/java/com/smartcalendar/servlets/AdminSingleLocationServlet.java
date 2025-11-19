package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.SQLException;

import com.smartcalendar.dao.LocationDao;
import com.smartcalendar.models.Location;
import com.smartcalendar.models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/admin-location"})
public class AdminSingleLocationServlet extends HttpServlet {
    private boolean isAdmin(User user){ return user != null && user.getRole() != null && user.getRole().equalsIgnoreCase("admin"); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (!isAdmin(user)) { resp.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }
        String idStr = req.getParameter("id");
        if (idStr == null) { resp.sendRedirect("admin-locations?error=Missing+id"); return; }
        try {
            int id = Integer.parseInt(idStr);
            Location loc = LocationDao.findById(id);
            if (loc == null) { resp.sendRedirect("admin-locations?error=Not+found"); return; }
            req.setAttribute("location", loc);
            req.getRequestDispatcher("admin-location-detail.jsp").forward(req, resp);
        } catch (NumberFormatException | SQLException e) {
            resp.sendRedirect("admin-locations?error=Invalid+id");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (!isAdmin(user)) { resp.sendRedirect("dashboard.jsp?error=Not+authorized"); return; }
        String action = req.getParameter("action");
        String idStr = req.getParameter("locationId");
        if (action == null || idStr == null) { resp.sendRedirect("admin-locations?error=Missing+params"); return; }
        try {
            int id = Integer.parseInt(idStr);
            if ("save".equals(action)) {
                Location l = LocationDao.findById(id);
                if (l == null) { resp.sendRedirect("admin-locations?error=Not+found"); return; }
                l.setName(req.getParameter("name"));
                l.setCategory(req.getParameter("category"));
                l.setDescription(req.getParameter("description"));
                l.setMapUrl(req.getParameter("mapUrl"));
                l.setActive("on".equals(req.getParameter("active")) || "true".equalsIgnoreCase(req.getParameter("active")));
                LocationDao.update(l);
                resp.sendRedirect("admin-location?id=" + id + "&success=Saved");
            } else if ("delete".equals(action)) {
                LocationDao.delete(id);
                resp.sendRedirect("admin-locations?success=Deleted");
            } else {
                resp.sendRedirect("admin-location?id=" + id + "&error=Unknown+action");
            }
        } catch (NumberFormatException | SQLException e) {
            resp.sendRedirect("admin-locations?error=Operation+failed");
        }
    }
}

package com.smartcalendar.servlets;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
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
        String category = req.getParameter("category");
        try {
            List<Location> list;
            if (category != null && !category.trim().isEmpty()) {
                list = LocationDao.listByCategory(category.trim());
            } else {
                list = LocationDao.listAll();
            }
            req.setAttribute("locations", list);
        } catch (SQLException e) {
            // Log and continue with empty list so the page still renders
            req.setAttribute("loadError", "Unable to load locations");
            req.setAttribute("locations", java.util.Collections.emptyList());
        }
        req.setAttribute("currentCategory", category);
        req.getRequestDispatcher("/admin-locations.jsp").forward(req, resp);
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

        String returnCategory = req.getParameter("returnCategory");
        String categoryForRedirect = null;
        if (returnCategory != null && !returnCategory.trim().isEmpty()) {
            categoryForRedirect = returnCategory.trim();
        } else if ("create".equals(action) || "update".equals(action)) {
            String postedCat = req.getParameter("category");
            if (postedCat != null && !postedCat.trim().isEmpty()) {
                categoryForRedirect = postedCat.trim();
            }
        }

        StringBuilder redirect = new StringBuilder("admin-locations");
        boolean hasQuery = false;
        if (categoryForRedirect != null) {
            redirect.append("?category=")
                    .append(URLEncoder.encode(categoryForRedirect, StandardCharsets.UTF_8));
            hasQuery = true;
        }
        redirect.append(hasQuery ? "&" : "?").append("success=Done");
        resp.sendRedirect(redirect.toString());
    }
}

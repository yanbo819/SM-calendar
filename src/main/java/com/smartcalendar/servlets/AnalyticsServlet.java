package com.smartcalendar.servlets;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

import com.smartcalendar.models.User;
import com.smartcalendar.utils.AnalyticsLog;
import com.smartcalendar.utils.AnalyticsLog.Entry;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/admin-analytics"})
public class AnalyticsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.sendRedirect("login.jsp"); return; }
        int limit = 100;
        try { limit = Math.max(1, Math.min(500, Integer.parseInt(req.getParameter("limit")))); } catch (Exception ignore) {}
        String endpointFilter = req.getParameter("endpoint");
        if (endpointFilter != null && endpointFilter.trim().isEmpty()) endpointFilter = null;
        List<Entry> recent = AnalyticsLog.recent(limit);
        if (endpointFilter != null) {
            final String ef = endpointFilter.trim();
            recent = recent.stream().filter(e -> e.endpoint.equals(ef)).collect(Collectors.toList());
        }
        req.setAttribute("entries", recent);
        req.setAttribute("limit", limit);
        req.setAttribute("endpointFilter", endpointFilter != null ? endpointFilter : "");
        req.setAttribute("dtf", DateTimeFormatter.ISO_INSTANT);
        req.getRequestDispatcher("admin-analytics.jsp").forward(req, resp);
    }
}

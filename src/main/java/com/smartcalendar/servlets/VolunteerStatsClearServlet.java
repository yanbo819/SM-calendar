package com.smartcalendar.servlets;

import java.io.IOException;

import com.smartcalendar.models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/admin/volunteer-stats-clear"})
public class VolunteerStatsClearServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        handle(req, resp);
        
    }
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        handle(req, resp);
    }
    private void handle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.sendRedirect("login.jsp"); return; }
        long ageMs = System.currentTimeMillis() - getCacheTimestamp();
        VolunteerStatsServlet.clearCache();
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write("{\"cleared\":true,\"previousAgeMs\":" + ageMs + "}");
    }
    private long getCacheTimestamp() {
        try {
            java.lang.reflect.Field f = VolunteerStatsServlet.class.getDeclaredField("cacheTimestamp");
            f.setAccessible(true);
            return f.getLong(null);
        } catch (Exception e) {
            return 0L;
        }
    }
}

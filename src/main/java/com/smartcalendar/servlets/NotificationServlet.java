package com.smartcalendar.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import java.util.stream.Collectors;

import com.smartcalendar.dao.NotificationDao;
import com.smartcalendar.models.Notification;
import com.smartcalendar.models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/notifications"})
public class NotificationServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json");
            resp.getWriter().write("{\"error\":\"unauthorized\"}");
            return;
        }
        try {
            List<Notification> due = NotificationDao.listDueForUser(user.getUserId());
            NotificationDao.markSent(due.stream().map(Notification::getNotificationId).collect(Collectors.toList()));
            List<Notification> upcoming = NotificationDao.listUpcomingForUser(user.getUserId(), 5);
            resp.setContentType("application/json");
            PrintWriter out = resp.getWriter();
            out.write("{\"due\":[");
            for (int i = 0; i < due.size(); i++) {
                Notification n = due.get(i);
                if (i>0) out.write(',');
                out.write(toJson(n));
            }
            out.write("],\"upcoming\":[");
            for (int i = 0; i < upcoming.size(); i++) {
                Notification n = upcoming.get(i);
                if (i>0) out.write(',');
                out.write(toJson(n));
            }
            out.write("]}");
        } catch (SQLException e) {
            resp.setStatus(500);
            resp.setContentType("application/json");
            resp.getWriter().write("{\"error\":\"db_failure\"}");
        }
    }

    private String esc(String s){
        return s == null ? "" : s.replace("\\", "\\\\").replace("\"","\\\"");
    }
    private String toJson(Notification n){
        return "{\"id\":"+n.getNotificationId()+",\"eventId\":"+(n.getEventId()==null?"null":n.getEventId())+",\"message\":\""+esc(n.getMessage())+"\",\"time\":\""+n.getNotificationTime()+"\"}";
    }
}

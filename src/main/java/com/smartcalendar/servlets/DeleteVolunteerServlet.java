package com.smartcalendar.servlets;

import java.io.IOException;
import java.sql.SQLException;

import com.smartcalendar.dao.CstVolunteerDao;
import com.smartcalendar.models.CstVolunteer;
import com.smartcalendar.models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/delete-volunteer"})
public class DeleteVolunteerServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || user.getRole()==null || !user.getRole().equalsIgnoreCase("admin")) {
            resp.sendRedirect("login.jsp");
            return;
        }
        int id = -1; try { id = Integer.parseInt(req.getParameter("id")); } catch(Exception ignore) {}
        int deptId = -1; try { deptId = Integer.parseInt(req.getParameter("dept")); } catch(Exception ignore) {}
        if (id <= 0) { resp.sendRedirect("college-volunteers.jsp"); return; }
        CstVolunteer v = null; try { v = CstVolunteerDao.findById(id); } catch(SQLException e){ v=null; }
        String lang = (String) req.getSession().getAttribute("lang"); if (lang == null) lang = "en";
        if (v == null) {
            req.getSession().setAttribute("flashError", com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.volunteer.deleteError"));
            resp.sendRedirect("cst-team-members.jsp?dept=" + deptId);
            return;
        }
        v.setActive(false); // soft delete
        try {
            CstVolunteerDao.update(v);
            req.getSession().setAttribute("flashSuccess", com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.volunteer.deleteSuccess"));
        } catch(SQLException e){
            req.getSession().setAttribute("flashError", com.smartcalendar.utils.LanguageUtil.getText(lang, "admin.volunteer.deleteError"));
        }
        resp.sendRedirect("cst-team-members.jsp?dept=" + deptId);
    }
}

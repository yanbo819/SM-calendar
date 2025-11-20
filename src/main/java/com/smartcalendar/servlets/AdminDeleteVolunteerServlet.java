package com.smartcalendar.servlets;

import com.smartcalendar.dao.CstVolunteerDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "AdminDeleteVolunteerServlet", urlPatterns = {"/admin-delete-volunteer"})
public class AdminDeleteVolunteerServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");
        String deptIdStr = request.getParameter("dept");
        int id = -1;
        int deptId = -1;
        if (idStr != null) {
            try { id = Integer.parseInt(idStr); } catch (Exception e) { id = -1; }
        }
        if (deptIdStr != null) {
            try { deptId = Integer.parseInt(deptIdStr); } catch (Exception e) { deptId = -1; }
        }
        if (id > 0) {
            try {
                CstVolunteerDao.delete(id);
            } catch (Exception e) {
                // Optionally log error
            }
        }
        if (deptId > 0) {
            response.sendRedirect("cst-team-members.jsp?dept=" + deptId);
        } else {
            response.sendRedirect("cst-team.jsp");
        }
    }
}

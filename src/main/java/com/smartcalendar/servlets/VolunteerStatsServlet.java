package com.smartcalendar.servlets;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.smartcalendar.dao.CstDepartmentDao;
import com.smartcalendar.models.CstDepartment;
import com.smartcalendar.models.User;
import com.smartcalendar.utils.DepartmentFilterUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/volunteer-stats"})
public class VolunteerStatsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    // Simple in-memory cache (non-clustered) with short TTL
    private static volatile String cachedJson;
    private static volatile long cacheTimestamp = 0L;
    private static final long TTL_MS = 10_000; // 10 seconds

    // Allows other admin endpoints to invalidate the cache
    public static void clearCache() {
        cachedJson = null;
        cacheTimestamp = 0L;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.setStatus(302); resp.sendRedirect("login.jsp"); return; }
        resp.setContentType("application/json;charset=UTF-8");
        try {
            long now = System.currentTimeMillis();
            String localCache = cachedJson; // read volatile reference
            if (localCache != null && (now - cacheTimestamp) < TTL_MS) {
                resp.getWriter().write(localCache);
                return;
            }
            List<CstDepartment> all = CstDepartmentDao.listAll();
            int cstCount = all.size(); // all departments considered CST group baseline
            int businessCount = DepartmentFilterUtil.filterBusiness(all).size();
            int chineseCount = DepartmentFilterUtil.filterChinese(all).size();
            Map<String, Object> json = new HashMap<>();
            json.put("cst", cstCount);
            json.put("business", businessCount);
            json.put("chinese", chineseCount);
            json.put("total", all.size());
            StringBuilder sb = new StringBuilder("{");
            sb.append("\"cst\":").append(cstCount).append(',');
            sb.append("\"business\":").append(businessCount).append(',');
            sb.append("\"chinese\":").append(chineseCount).append(',');
            sb.append("\"total\":").append(all.size());
            sb.append('}');
            String result = sb.toString();
            cachedJson = result; // update cache
            cacheTimestamp = now;
            resp.getWriter().write(result);
        } catch (Exception e) {
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"stats_failed\"}");
        }
    }
}

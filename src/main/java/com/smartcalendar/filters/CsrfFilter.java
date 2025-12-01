package com.smartcalendar.filters;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Simple CSRF protection filter.
 * Generates a token per session and validates it on state-changing POST requests.
 * Excludes GET/HEAD and login/register pages from enforcement if token missing (bootstrap case).
 */
public class CsrfFilter implements Filter {
    private static final String TOKEN_ATTR = "csrfToken";
    private static final SecureRandom RNG = new SecureRandom();

    @Override
    public void init(FilterConfig filterConfig) { }

    private String generateToken() {
        byte[] bytes = new byte[32];
        RNG.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private boolean isSafeMethod(String m){
        return m == null || m.equalsIgnoreCase("GET") || m.equalsIgnoreCase("HEAD") || m.equalsIgnoreCase("OPTIONS");
    }

    private boolean isExemptPath(String path){
        if (path == null) return true;
        // Allow initial acquisition of token on auth and static resource pages.
        return path.endsWith("login.jsp") || path.endsWith("register.jsp") || path.endsWith("forgot-password.jsp") || path.contains("/css/") || path.contains("/images/") || path.contains("/js/");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        if (!(request instanceof HttpServletRequest) || !(response instanceof HttpServletResponse)) {
            chain.doFilter(request, response);
            return;
        }
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(true);
        String method = req.getMethod();
        String path = req.getRequestURI();

        // Ensure a token exists.
        String sessionToken = (String) session.getAttribute(TOKEN_ATTR);
        if (sessionToken == null) {
            sessionToken = generateToken();
            session.setAttribute(TOKEN_ATTR, sessionToken);
        }

        if (!isSafeMethod(method)) {
            // Validate token for mutating requests.
            String formToken = req.getParameter("csrfToken");
            if (formToken == null || !formToken.equals(sessionToken)) {
                // Permit exemption paths for first load only.
                if (!isExemptPath(path)) {
                    resp.setStatus(403);
                    resp.setContentType("text/plain;charset=UTF-8");
                    resp.getWriter().write("CSRF validation failed");
                    return;
                }
            }
        }
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() { }
}

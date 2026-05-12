package com.busbooking.filter;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Filter that protects all admin URLs (/admin/*).
 * If the admin is not logged in, redirects to the admin login page.
 */
@WebFilter("/admin/*")
public class AdminAuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // No initialization required
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        // Check if admin is logged in
        boolean isLoggedIn = (session != null && session.getAttribute("admin") != null);

        // Get the login URI
        String loginURI = req.getContextPath() + "/admin/login";

        // Check if the current request is for the login page itself
        boolean isLoginRequest = req.getRequestURI().equals(loginURI);

        // Check if the request is for static resources (CSS, JS, images)
        boolean isStaticResource = req.getRequestURI().startsWith(req.getContextPath() + "/css/") ||
                                   req.getRequestURI().startsWith(req.getContextPath() + "/js/") ||
                                   req.getRequestURI().startsWith(req.getContextPath() + "/images/");

        if (isLoggedIn || isLoginRequest || isStaticResource) {
            // Allow the request to proceed
            chain.doFilter(request, response);
        } else {
            // Not logged in – redirect to login page with expired parameter
            res.sendRedirect(loginURI + "?expired=true");
        }
    }

    @Override
    public void destroy() {
        // No cleanup required
    }
}
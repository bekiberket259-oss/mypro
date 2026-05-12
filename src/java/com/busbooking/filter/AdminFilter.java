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
 * Authentication filter that protects all URLs under /admin/.
 * If the user is not logged in as an admin, they are redirected to the login page.
 */
@WebFilter("/admin/*")
public class AdminFilter implements Filter {

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

        // Allow static resources (CSS, JS, images) to load without authentication
        boolean isStaticResource = req.getRequestURI().matches(".*\\.(css|js|png|jpg|jpeg|gif|ico|woff2?|svg)$");

        if (isLoggedIn || isLoginRequest || isStaticResource) {
            // User is authenticated or requesting the login page or a static resource
            chain.doFilter(request, response);
        } else {
            // Not authenticated – redirect to login page with expired parameter
            res.sendRedirect(loginURI + "?expired=true");
        }
    }

    @Override
    public void destroy() {
        // No cleanup required
    }
}
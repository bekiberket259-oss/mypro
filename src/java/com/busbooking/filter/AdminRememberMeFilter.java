package com.busbooking.filter;

import com.busbooking.dao.AdminDAO;
import com.busbooking.model.Admin;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Calendar;

@WebFilter("/*")
public class AdminRememberMeFilter implements Filter {

    private static final int COOKIE_MAX_AGE_DAYS = 30;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Nothing to initialize
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Only act if no admin is already in session
        HttpSession session = httpRequest.getSession(false);
        if (session == null || session.getAttribute("admin") == null) {
            Cookie[] cookies = httpRequest.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("admin_remember_token".equals(cookie.getName())) {
                        String token = cookie.getValue();
                        if (token != null && !token.isEmpty()) {
                            AdminDAO adminDAO = new AdminDAO();
                            try {
                                Admin admin = adminDAO.getAdminByRememberToken(token);
                                if (admin != null) {
                                    // Auto-login: create a new session for the admin
                                    session = httpRequest.getSession(true);
                                    session.setAttribute("admin", admin);
                                    session.setAttribute("role", "admin");
                                    session.setMaxInactiveInterval(30 * 60);

                                    // Renew the token in the database and cookie
                                    Calendar cal = Calendar.getInstance();
                                    cal.add(Calendar.DATE, COOKIE_MAX_AGE_DAYS);
                                    Timestamp newExpiry = new Timestamp(cal.getTimeInMillis());
                                    adminDAO.setRememberToken(admin.getAdminId(), token, newExpiry);

                                    Cookie renewedCookie = new Cookie("admin_remember_token", token);
                                    renewedCookie.setMaxAge(60 * 60 * 24 * COOKIE_MAX_AGE_DAYS);
                                    renewedCookie.setHttpOnly(true);
                                    renewedCookie.setPath("/");
                                    httpResponse.addCookie(renewedCookie);

                                } else {
                                    // Invalid or expired token – delete the cookie
                                    Cookie deleteCookie = new Cookie("admin_remember_token", "");
                                    deleteCookie.setMaxAge(0);
                                    deleteCookie.setPath("/");
                                    httpResponse.addCookie(deleteCookie);
                                }
                            } catch (Exception e) {
                                // Database error – remove the offending cookie
                                Cookie deleteCookie = new Cookie("admin_remember_token", "");
                                deleteCookie.setMaxAge(0);
                                deleteCookie.setPath("/");
                                httpResponse.addCookie(deleteCookie);
                            }
                        }
                        break; // only one admin_remember_token cookie expected
                    }
                }
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Nothing to clean up
    }
}
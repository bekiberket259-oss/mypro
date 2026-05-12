package com.busbooking.filter;

import com.busbooking.dao.UserDAO;
import com.busbooking.model.User;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Calendar;

@WebFilter("/*")
public class RememberMeFilter implements Filter {

    private static final int COOKIE_MAX_AGE_DAYS = 30;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // No initialization required
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Check if user is already logged in via session
        HttpSession session = httpRequest.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            // No active session – try to auto‑login using the remember‑me cookie
            Cookie[] cookies = httpRequest.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("remember_token".equals(cookie.getName())) {
                        String token = cookie.getValue();
                        if (token != null && !token.isEmpty()) {
                            UserDAO userDAO = new UserDAO();
                            try {
                                User user = userDAO.getUserByRememberToken(token);
                                if (user != null) {
                                    // Create a new session for the user
                                    session = httpRequest.getSession(true);
                                    session.setAttribute("user", user);
                                    session.setAttribute("role", "user");
                                    session.setAttribute("userId", user.getUserId());
                                    session.setAttribute("userName", user.getFullName());
                                    session.setMaxInactiveInterval(30 * 60); // 30 minutes

                                    // Renew the token and cookie for another 30 days
                                    Calendar cal = Calendar.getInstance();
                                    cal.add(Calendar.DATE, COOKIE_MAX_AGE_DAYS);
                                    Timestamp newExpiry = new Timestamp(cal.getTimeInMillis());
                                    userDAO.setRememberToken(user.getUserId(), token, newExpiry);

                                    Cookie renewedCookie = new Cookie("remember_token", token);
                                    renewedCookie.setMaxAge(60 * 60 * 24 * COOKIE_MAX_AGE_DAYS);
                                    renewedCookie.setHttpOnly(true);
                                    renewedCookie.setPath("/");
                                    httpResponse.addCookie(renewedCookie);

                                } else {
                                    // Invalid or expired token – delete the cookie
                                    Cookie deleteCookie = new Cookie("remember_token", "");
                                    deleteCookie.setMaxAge(0);
                                    deleteCookie.setPath("/");
                                    httpResponse.addCookie(deleteCookie);
                                }
                            } catch (Exception e) {
                                // If DB error, remove cookie to prevent repeated failures
                                Cookie deleteCookie = new Cookie("remember_token", "");
                                deleteCookie.setMaxAge(0);
                                deleteCookie.setPath("/");
                                httpResponse.addCookie(deleteCookie);
                            }
                        }
                        break; // Only one remember_token cookie expected
                    }
                }
            }
        }

        // Continue the request
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // No cleanup required
    }
}
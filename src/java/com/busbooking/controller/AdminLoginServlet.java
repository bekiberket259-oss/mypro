package com.busbooking.controller;

import com.busbooking.dao.AdminDAO;
import com.busbooking.model.Admin;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.security.SecureRandom;
import java.sql.Timestamp;
import java.util.Base64;
import java.util.Calendar;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/admin/login")
public class AdminLoginServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminLoginServlet.class.getName());
    private static final int REMEMBER_ME_DAYS = 30;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("admin") != null) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }
        request.getRequestDispatcher("/views/admin/admin_login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");   // "on" if checked

        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Username and password are required.");
            request.getRequestDispatcher("/views/admin/admin_login.jsp").forward(request, response);
            return;
        }

        username = username.trim();
        password = password.trim();

        AdminDAO adminDAO = new AdminDAO();
        try {
            Admin admin = adminDAO.login(username, password);
            if (admin != null) {
                // Invalidate any existing admin session (optional but clean)
                HttpSession oldSession = request.getSession(false);
                if (oldSession != null) {
                    oldSession.invalidate();
                }

                HttpSession session = request.getSession(true);
                session.setAttribute("admin", admin);
                session.setAttribute("role", "admin");
                session.setMaxInactiveInterval(30 * 60);  // 30 minutes

                // ---------- Remember Me ----------
                if ("on".equals(remember)) {
                    SecureRandom secureRandom = new SecureRandom();
                    byte[] randomBytes = new byte[32];
                    secureRandom.nextBytes(randomBytes);
                    String token = Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);

                    Calendar cal = Calendar.getInstance();
                    cal.add(Calendar.DATE, REMEMBER_ME_DAYS);
                    Timestamp expiry = new Timestamp(cal.getTimeInMillis());

                    adminDAO.setRememberToken(admin.getAdminId(), token, expiry);

                    Cookie rememberCookie = new Cookie("admin_remember_token", token);
                    rememberCookie.setMaxAge(60 * 60 * 24 * REMEMBER_ME_DAYS);
                    rememberCookie.setHttpOnly(true);
                    rememberCookie.setPath("/");
                    response.addCookie(rememberCookie);
                }
                // ---------------------------------

                LOGGER.log(Level.INFO, "Admin logged in: {0}", username);
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                LOGGER.log(Level.WARNING, "Failed admin login attempt for: {0}", username);
                request.setAttribute("error", "Invalid username or password.");
                request.setAttribute("username", username);
                request.getRequestDispatcher("/views/admin/admin_login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error during admin login", e);
            request.setAttribute("error", "System error. Please try again later.");
            request.getRequestDispatcher("/views/admin/admin_login.jsp").forward(request, response);
        }
    }
}
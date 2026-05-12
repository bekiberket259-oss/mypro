package com.busbooking.controller;

import com.busbooking.dao.AdminDAO;
import com.busbooking.dao.UserDAO;
import com.busbooking.model.Admin;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LogoutServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession(false);

        if (session != null) {
            String role = (String) session.getAttribute("role");
            Object userIdObj = session.getAttribute("userId");
            Object adminIdObj = session.getAttribute("adminId");
            Object adminObj = session.getAttribute("admin");   // if you store the Admin object

            // ---------- Clear user "Remember Me" ----------
            if ("user".equals(role) && userIdObj != null) {
                try {
                    UserDAO userDAO = new UserDAO();
                    userDAO.clearRememberToken((Integer) userIdObj);
                } catch (Exception e) {
                    LOGGER.log(Level.WARNING, "Failed to clear user remember token: {0}", userIdObj);
                }
                // Delete user cookie
                Cookie deleteUserCookie = new Cookie("remember_token", "");
                deleteUserCookie.setMaxAge(0);
                deleteUserCookie.setPath("/");
                response.addCookie(deleteUserCookie);
            }

            // ---------- Clear admin "Remember Me" ----------
            if ("admin".equals(role)) {
                Integer adminId = null;
                if (adminIdObj instanceof Integer) {
                    adminId = (Integer) adminIdObj;
                } else if (adminObj instanceof Admin) {
                    adminId = ((Admin) adminObj).getAdminId();
                }

                if (adminId != null) {
                    try {
                        AdminDAO adminDAO = new AdminDAO();
                        adminDAO.clearRememberToken(adminId);
                    } catch (Exception e) {
                        LOGGER.log(Level.WARNING, "Failed to clear admin remember token: {0}", adminId);
                    }
                }

                // Delete admin cookie
                Cookie deleteAdminCookie = new Cookie("admin_remember_token", "");
                deleteAdminCookie.setMaxAge(0);
                deleteAdminCookie.setPath("/");
                response.addCookie(deleteAdminCookie);
            }

            // Log the logout event
            if ("admin".equals(role)) {
                LOGGER.log(Level.INFO, "Admin logged out: ID={0}", 
                    adminIdObj != null ? adminIdObj : (adminObj != null ? ((Admin) adminObj).getAdminId() : "unknown"));
            } else if ("user".equals(role)) {
                LOGGER.log(Level.INFO, "User logged out: ID={0}", userIdObj);
            } else {
                LOGGER.log(Level.INFO, "Anonymous session invalidated");
            }

            // Invalidate the session
            session.invalidate();

            // Create a new temporary session for the logout message
            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("logoutMessage", "You have been successfully logged out.");

            // Redirect to the correct login page
            String redirectUrl;
            if ("admin".equals(role)) {
                redirectUrl = request.getContextPath() + "/admin/login?logout=true";
            } else {
                redirectUrl = request.getContextPath() + "/login?logout=true";
            }
            response.sendRedirect(redirectUrl);
        } else {
            // No session – go home
            response.sendRedirect(request.getContextPath() + "/");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
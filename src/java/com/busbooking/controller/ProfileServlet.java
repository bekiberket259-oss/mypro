package com.busbooking.controller;

import com.busbooking.dao.UserDAO;
import com.busbooking.model.User;
import com.busbooking.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ProfileServlet.class.getName());
    private static final String PROFILE_VIEW = "/views/profile.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        request.setAttribute("user", user);
        request.getRequestDispatcher(PROFILE_VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User sessionUser = (User) session.getAttribute("user");
        String action = request.getParameter("action");

        try {
            if ("updateProfile".equals(action)) {
                updateProfile(request, response, sessionUser);
            } else if ("changePassword".equals(action)) {
                changePassword(request, response, sessionUser);
            } else {
                response.sendRedirect(request.getContextPath() + "/profile");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in ProfileServlet", e);
            session.setAttribute("error", "A database error occurred. Please try again.");
            response.sendRedirect(request.getContextPath() + "/profile");
        }
    }

    private void updateProfile(HttpServletRequest request, HttpServletResponse response, User sessionUser)
            throws SQLException, IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");

        if (isNullOrEmpty(fullName) || isNullOrEmpty(email) || isNullOrEmpty(phone)) {
            request.getSession().setAttribute("error", "All fields are required.");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        // Validate email format
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            request.getSession().setAttribute("error", "Please enter a valid email address.");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        // Validate phone (Ethiopian format)
        if (!phone.matches("^09[0-9]{8}$")) {
            request.getSession().setAttribute("error", "Phone number must be in Ethiopian format (09xxxxxxxx).");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        UserDAO userDAO = new UserDAO();
        User existingUser = userDAO.getUserByEmail(email.trim().toLowerCase());
        if (existingUser != null && existingUser.getUserId() != sessionUser.getUserId()) {
            request.getSession().setAttribute("error", "Email is already registered by another user.");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        sessionUser.setFullName(fullName.trim());
        sessionUser.setEmail(email.trim().toLowerCase());
        sessionUser.setPhone(phone.trim());

        boolean updated = userDAO.updateUser(sessionUser);
        if (updated) {
            request.getSession().setAttribute("user", sessionUser);
            request.getSession().setAttribute("success", "Profile updated successfully.");
        } else {
            request.getSession().setAttribute("error", "Failed to update profile.");
        }
        response.sendRedirect(request.getContextPath() + "/profile");
    }

    private void changePassword(HttpServletRequest request, HttpServletResponse response, User sessionUser)
            throws SQLException, IOException {
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (isNullOrEmpty(currentPassword) || isNullOrEmpty(newPassword) || isNullOrEmpty(confirmPassword)) {
            request.getSession().setAttribute("error", "All password fields are required.");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.getSession().setAttribute("error", "New passwords do not match.");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        if (newPassword.length() < 6) {
            request.getSession().setAttribute("error", "Password must be at least 6 characters.");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        UserDAO userDAO = new UserDAO();
        User fullUser = userDAO.getUserById(sessionUser.getUserId());

        if (!PasswordUtil.checkPassword(currentPassword, fullUser.getPassword())) {
            request.getSession().setAttribute("error", "Current password is incorrect.");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        boolean changed = userDAO.changePassword(sessionUser.getUserId(), newPassword);
        if (changed) {
            request.getSession().setAttribute("success", "Password changed successfully.");
        } else {
            request.getSession().setAttribute("error", "Failed to change password.");
        }
        response.sendRedirect(request.getContextPath() + "/profile");
    }

    private boolean isNullOrEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }
}
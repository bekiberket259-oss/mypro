package com.busbooking.controller;

import com.busbooking.dao.UserDAO;
import com.busbooking.model.User;
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

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    
    private static final Logger LOGGER = Logger.getLogger(LoginServlet.class.getName());
    private static final String LOGIN_VIEW = "/views/login.jsp";
    private static final String DASHBOARD_URL = "dashboard";
    private static final int REMEMBER_ME_DAYS = 30;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        HttpSession session = request.getSession(false);
        
        // If user already logged in, redirect to dashboard
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect(DASHBOARD_URL);
            return;
        }
        
        // Success messages from registration or logout
        String registered = request.getParameter("registered");
        if ("true".equals(registered)) {
            request.setAttribute("success", "Registration successful! Please login.");
        }
        String logout = request.getParameter("logout");
        if ("true".equals(logout)) {
            request.setAttribute("success", "You have been logged out successfully.");
        }
        
        request.getRequestDispatcher(LOGIN_VIEW).forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");   // "on" if checked
        
        // Basic validation
        if (email == null || email.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Email and password are required.");
            request.getRequestDispatcher(LOGIN_VIEW).forward(request, response);
            return;
        }
        
        email = email.trim().toLowerCase();
        password = password.trim();
        
        UserDAO userDAO = new UserDAO();
        
        try {
            User user = userDAO.login(email, password);
            
            if (user != null) {
                // Invalidate any existing session
                HttpSession oldSession = request.getSession(false);
                if (oldSession != null) {
                    oldSession.invalidate();
                }
                
                HttpSession session = request.getSession(true);
                session.setAttribute("user", user);
                session.setAttribute("role", "user");
                session.setAttribute("userId", user.getUserId());
                session.setAttribute("userName", user.getFullName());
                session.setMaxInactiveInterval(30 * 60);
                
                // ----- REMEMBER ME -----
                if ("on".equals(remember)) {
                    // Generate a secure random token
                    SecureRandom secureRandom = new SecureRandom();
                    byte[] randomBytes = new byte[32];
                    secureRandom.nextBytes(randomBytes);
                    String token = Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
                    
                    // Set expiry 30 days from now
                    Calendar cal = Calendar.getInstance();
                    cal.add(Calendar.DATE, REMEMBER_ME_DAYS);
                    Timestamp expiry = new Timestamp(cal.getTimeInMillis());
                    
                    // Store the token in the database
                    userDAO.setRememberToken(user.getUserId(), token, expiry);
                    
                    // Create a persistent cookie
                    Cookie rememberCookie = new Cookie("remember_token", token);
                    rememberCookie.setMaxAge(60 * 60 * 24 * REMEMBER_ME_DAYS); // seconds
                    rememberCookie.setHttpOnly(true);
                    rememberCookie.setPath("/");
                    response.addCookie(rememberCookie);
                }
                // -------------------------
                
                LOGGER.log(Level.INFO, "User logged in: {0} ({1})", 
                           new Object[]{user.getEmail(), user.getUserId()});
                
                response.sendRedirect(DASHBOARD_URL);
                
            } else {
                LOGGER.log(Level.WARNING, "Failed login attempt for email: {0}", email);
                request.setAttribute("error", "Invalid email or password.");
                request.setAttribute("email", email);
                request.getRequestDispatcher(LOGIN_VIEW).forward(request, response);
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error during login", e);
            request.setAttribute("error", "System error. Please try again later.");
            request.setAttribute("email", email);
            request.getRequestDispatcher(LOGIN_VIEW).forward(request, response);
        }
    }
}
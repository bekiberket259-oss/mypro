package com.busbooking.controller;

import com.busbooking.dao.UserDAO;
import com.busbooking.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Pattern;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    
    private static final Logger LOGGER = Logger.getLogger(RegisterServlet.class.getName());
    private static final String REGISTER_VIEW = "/views/register.jsp";
    private static final String LOGIN_VIEW = "/views/login.jsp";
    
    // Email regex pattern
    private static final Pattern EMAIL_PATTERN = 
        Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    
    // Ethiopian phone number pattern (starts with 09, followed by 8 digits)
    private static final Pattern PHONE_PATTERN = 
        Pattern.compile("^09[0-9]{8}$");
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Set character encoding
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        HttpSession session = request.getSession(false);
        
        // If user already logged in, redirect to dashboard
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect("dashboard");
            return;
        }
        
        // Forward to registration page
        request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Set character encoding
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        // Get parameters
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String phone = request.getParameter("phone");
        
        // Preserve form data for re-display
        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);
        
        // ========== VALIDATION ==========
        
        // 1. Required fields
        if (isNullOrEmpty(fullName) || isNullOrEmpty(email) || 
            isNullOrEmpty(password) || isNullOrEmpty(confirmPassword) || 
            isNullOrEmpty(phone)) {
            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
            return;
        }
        
        // 2. Trim inputs
        fullName = fullName.trim();
        email = email.trim().toLowerCase();
        password = password.trim();
        confirmPassword = confirmPassword.trim();
        phone = phone.trim();
        
        // 3. Full name length
        if (fullName.length() < 3 || fullName.length() > 100) {
            request.setAttribute("error", "Full name must be between 3 and 100 characters.");
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
            return;
        }
        
        // 4. Email format
        if (!EMAIL_PATTERN.matcher(email).matches()) {
            request.setAttribute("error", "Please enter a valid email address.");
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
            return;
        }
        
        // 5. Password strength (min 6 chars, at least one letter and one number)
        if (password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters long.");
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
            return;
        }
        
        if (!password.matches(".*[A-Za-z].*") || !password.matches(".*[0-9].*")) {
            request.setAttribute("error", "Password must contain at least one letter and one number.");
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
            return;
        }
        
        // 6. Password confirmation
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
            return;
        }
        
        // 7. Phone validation (Ethiopian format)
        if (!PHONE_PATTERN.matcher(phone).matches()) {
            request.setAttribute("error", "Phone number must be in Ethiopian format (e.g., 0912345678).");
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
            return;
        }
        
        // ========== BUSINESS LOGIC ==========
        
        UserDAO userDAO = new UserDAO();
        
        try {
            // Check if email already exists
            if (userDAO.isEmailExists(email)) {
                request.setAttribute("error", "Email address is already registered. Please login or use another email.");
                request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
                return;
            }
            
            // Create user object
            User user = new User(fullName, email, password, phone);
            
            // Register user
            if (userDAO.registerUser(user)) {
                LOGGER.log(Level.INFO, "New user registered: {0}", email);
                
                // Optionally auto-login or redirect with success message
                // Here we redirect to login with a success parameter
                response.sendRedirect(request.getContextPath() + "/views/login.jsp?registered=true");
                
            } else {
                LOGGER.log(Level.WARNING, "Registration failed for email: {0}", email);
                request.setAttribute("error", "Registration failed. Please try again.");
                request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error during registration", e);
            request.setAttribute("error", "A system error occurred. Please try again later.");
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
        }
    }
    
    /**
     * Helper method to check if a string is null or empty.
     */
    private boolean isNullOrEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }
}
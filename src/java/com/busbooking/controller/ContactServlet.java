package com.busbooking.controller;

import com.busbooking.dao.ContactMessageDAO;
import com.busbooking.model.ContactMessage;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/contact")
public class ContactServlet extends HttpServlet {

    private ContactMessageDAO dao = new ContactMessageDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Simply show the contact form (contact.jsp)
        request.getRequestDispatcher("/views/contact.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get form parameters
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String subject = request.getParameter("subject");
        String message = request.getParameter("message");

        // Basic validation
        if (name == null || name.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            message == null || message.trim().isEmpty()) {

            request.setAttribute("error", "All fields (Name, Email, Message) are required.");
            request.getRequestDispatcher("/views/contact.jsp").forward(request, response);
            return;
        }

        // Create ContactMessage object
        ContactMessage msg = new ContactMessage();
        msg.setName(name.trim());
        msg.setEmail(email.trim());
        msg.setSubject(subject != null ? subject.trim() : null);
        msg.setMessage(message.trim());

        // Save to database
        boolean saved = dao.saveMessage(msg);
        if (saved) {
            request.setAttribute("success", "Your message has been sent. We'll get back to you soon.");
        } else {
            request.setAttribute("error", "Failed to send message. Please try again later.");
        }

        // Forward back to contact.jsp (so the user sees the result)
        request.getRequestDispatcher("/views/contact.jsp").forward(request, response);
    }
}
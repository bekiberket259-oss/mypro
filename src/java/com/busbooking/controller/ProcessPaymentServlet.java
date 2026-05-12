package com.busbooking.controller;

import com.busbooking.dao.BookingDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/process_payment")
public class ProcessPaymentServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ProcessPaymentServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Check if user is logged in
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get parameters from the payment form
        String bookingId = request.getParameter("bookingId");
        String paymentMethod = request.getParameter("method");
        String phoneNumber = request.getParameter("phone"); // For Telebirr

        // If bookingId is not in form, try to get from session
        if (bookingId == null || bookingId.trim().isEmpty()) {
            bookingId = (String) session.getAttribute("lastBookingId");
        }

        // Validate booking ID
        if (bookingId == null || bookingId.trim().isEmpty()) {
            LOGGER.log(Level.WARNING, "Payment attempted without booking ID");
            session.setAttribute("error", "No booking found. Please start a new booking.");
            response.sendRedirect(request.getContextPath() + "/search");
            return;
        }

        // Simulate payment processing (always successful in this demo)
        LOGGER.log(Level.INFO, "Payment simulated for booking: {0}, Method: {1}",
                   new Object[]{bookingId, paymentMethod});

        // Confirm the booking: change status from PENDING to CONFIRMED
        try {
            BookingDAO bookingDAO = new BookingDAO();
            boolean confirmed = bookingDAO.confirmBooking(bookingId);
            if (confirmed) {
                // Success: booking is now CONFIRMED
                session.setAttribute("success", "Payment successful! Your booking is confirmed.");
                session.setAttribute("paymentMethod", paymentMethod);
                session.setAttribute("paymentStatus", "SUCCESS");

                // Clear temporary session data
                session.removeAttribute("paymentAmount");
                session.removeAttribute("paymentRoute");
                session.removeAttribute("paymentSeats");

                // Redirect to confirmation/ticket page
                response.sendRedirect(request.getContextPath() + "/confirmation?bookingId=" + bookingId);
            } else {
                // Booking was not in PENDING status (maybe already confirmed or cancelled)
                LOGGER.log(Level.WARNING, "Booking confirmation failed for ID: {0} – status not PENDING", bookingId);
                session.setAttribute("error", "Booking could not be confirmed. It may have already been processed.");
                response.sendRedirect(request.getContextPath() + "/dashboard");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error during payment confirmation for booking: " + bookingId, e);
            session.setAttribute("error", "A system error occurred while processing your payment. Please try again.");
            response.sendRedirect(request.getContextPath() + "/dashboard");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // GET requests are not allowed for payment processing
        response.sendRedirect(request.getContextPath() + "/");
    }
}
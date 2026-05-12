package com.busbooking.controller;

import com.busbooking.dao.BookingDAO;
import com.busbooking.dao.SeatDAO;
import com.busbooking.model.Booking;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/payBooking")
public class PayBookingServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PayBookingServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 1. Validate booking ID
        String bookingId = request.getParameter("bookingId");
        if (bookingId == null || bookingId.trim().isEmpty()) {
            session.setAttribute("error", "No booking ID provided.");
            response.sendRedirect(request.getContextPath() + "/mybookings");
            return;
        }

        try {
            BookingDAO bookingDAO = new BookingDAO();
            Booking booking = bookingDAO.getBookingById(bookingId);

            // 2. Only allow payment for PENDING bookings
            if (booking == null || !"PENDING".equalsIgnoreCase(booking.getStatus())) {
                session.setAttribute("error", "Booking not found or is not in pending state.");
                response.sendRedirect(request.getContextPath() + "/mybookings");
                return;
            }

            // 3. Get seat numbers (SeatDAO already has getSeatsByBookingId)
            SeatDAO seatDAO = new SeatDAO();
            List<String> seatNumbers = seatDAO.getSeatsByBookingId(bookingId);

            // 4. Set session attributes exactly as BookingServlet does after a new booking
            session.setAttribute("lastBookingId", booking.getBookingId());
            session.setAttribute("paymentAmount", booking.getTotalFare());
            session.setAttribute("paymentRoute", booking.getSource() + " → " + booking.getDestination());
            session.setAttribute("paymentSeats", String.join(", ", seatNumbers));

            // 5. Forward to payment.jsp (the same payment page you already have)
            request.getRequestDispatcher("/views/payment.jsp").forward(request, response);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error loading booking for payment", e);
            session.setAttribute("error", "Unable to process payment. Please try again.");
            response.sendRedirect(request.getContextPath() + "/mybookings");
        }
    }
}
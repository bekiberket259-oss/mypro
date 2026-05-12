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

@WebServlet("/confirmation")
public class ConfirmationServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ConfirmationServlet.class.getName());
    private static final String CONFIRMATION_VIEW = "/views/confirmation.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String bookingId = request.getParameter("bookingId");
        if (bookingId == null || bookingId.trim().isEmpty()) {
            // Try to get from session as fallback
            bookingId = (String) session.getAttribute("lastBookingId");
        }

        if (bookingId == null || bookingId.trim().isEmpty()) {
            session.setAttribute("error", "No booking found.");
            response.sendRedirect(request.getContextPath() + "/mybookings");
            return;
        }

        bookingId = bookingId.trim();

        try {
            BookingDAO bookingDAO = new BookingDAO();
            Booking booking = bookingDAO.getBookingById(bookingId);

            if (booking == null) {
                session.setAttribute("error", "Booking not found.");
                response.sendRedirect(request.getContextPath() + "/mybookings");
                return;
            }

            SeatDAO seatDAO = new SeatDAO();
            List<String> seatNumbers = seatDAO.getSeatsByBookingId(bookingId);
            booking.setSeatNumbers(seatNumbers);

            request.setAttribute("booking", booking);
            request.setAttribute("seatNumbers", seatNumbers);

            // Clear payment session attributes after use (optional)
            session.removeAttribute("paymentAmount");
            session.removeAttribute("paymentRoute");
            session.removeAttribute("paymentSeats");

            request.getRequestDispatcher(CONFIRMATION_VIEW).forward(request, response);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error loading confirmation for booking: " + bookingId, e);
            session.setAttribute("error", "Unable to load confirmation. Please check your bookings.");
            response.sendRedirect(request.getContextPath() + "/mybookings");
        }
    }
}

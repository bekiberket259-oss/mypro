package com.busbooking.controller;

import com.busbooking.dao.BookingDAO;
import com.busbooking.dao.SeatDAO;
import com.busbooking.model.Booking;
import com.busbooking.model.User;
import com.busbooking.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/cancelBooking")
public class CancelBookingServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CancelBookingServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // GET requests are not allowed for cancellation; redirect to my bookings page
        response.sendRedirect(request.getContextPath() + "/mybookings");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Set character encoding
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String bookingId = request.getParameter("bookingId");

        // Basic validation
        if (bookingId == null || bookingId.trim().isEmpty()) {
            session.setAttribute("error", "Invalid booking ID.");
            response.sendRedirect(request.getContextPath() + "/mybookings");
            return;
        }

        bookingId = bookingId.trim();

        BookingDAO bookingDAO = new BookingDAO();
        SeatDAO seatDAO = new SeatDAO();

        try {
            // Fetch the booking to verify ownership and status
            Booking booking = bookingDAO.getBookingById(bookingId);

            if (booking == null) {
                session.setAttribute("error", "Booking not found.");
                response.sendRedirect(request.getContextPath() + "/mybookings");
                return;
            }

            // Security: Ensure the booking belongs to the logged-in user
            if (booking.getUserId() != user.getUserId()) {
                LOGGER.log(Level.WARNING, "User {0} attempted to cancel booking {1} belonging to another user",
                        new Object[]{user.getUserId(), bookingId});
                session.setAttribute("error", "You are not authorized to cancel this booking.");
                response.sendRedirect(request.getContextPath() + "/mybookings");
                return;
            }

            // Business rule: Cannot cancel already cancelled or expired bookings
            if ("CANCELLED".equalsIgnoreCase(booking.getStatus())) {
                session.setAttribute("error", "This booking is already cancelled.");
                response.sendRedirect(request.getContextPath() + "/mybookings");
                return;
            }

            if ("EXPIRED".equalsIgnoreCase(booking.getStatus())) {
                session.setAttribute("error", "This booking has expired and cannot be cancelled.");
                response.sendRedirect(request.getContextPath() + "/mybookings");
                return;
            }

            // Business rule: Cannot cancel past travel dates
            LocalDate travelDate = booking.getTravelDate().toLocalDate();
            if (travelDate.isBefore(LocalDate.now())) {
                session.setAttribute("error", "Past bookings cannot be cancelled.");
                response.sendRedirect(request.getContextPath() + "/mybookings");
                return;
            }

            // Perform cancellation with seat release (transactional)
            boolean cancelled = cancelBookingWithSeatRelease(bookingId);

            if (cancelled) {
                LOGGER.log(Level.INFO, "Booking {0} cancelled by user {1}",
                        new Object[]{bookingId, user.getUserId()});
                session.setAttribute("success", "Booking " + bookingId + " has been cancelled successfully.");
            } else {
                session.setAttribute("error", "Cancellation failed. Please try again.");
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error cancelling booking " + bookingId, e);
            session.setAttribute("error", "A system error occurred during cancellation.");
        }

        response.sendRedirect(request.getContextPath() + "/mybookings");
    }

    /**
     * Cancels the booking and releases the associated seats in a single transaction.
     * 
     * @param bookingId the booking ID to cancel
     * @return true if successful, false otherwise
     */
    private boolean cancelBookingWithSeatRelease(String bookingId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);  // Start transaction

            BookingDAO bookingDAO = new BookingDAO();
            SeatDAO seatDAO = new SeatDAO();

            // 1. Update booking status to CANCELLED
            boolean bookingCancelled = bookingDAO.cancelBooking(conn, bookingId);
            if (!bookingCancelled) {
                conn.rollback();
                return false;
            }

            // 2. Release all seats associated with this booking
            boolean seatsReleased = seatDAO.releaseSeatsByBooking(conn, bookingId);
            if (!seatsReleased) {
                conn.rollback();
                return false;
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Transaction failed during cancellation of booking " + bookingId, e);
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Rollback failed", ex);
            }
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing connection", e);
            }
        }
    }
}
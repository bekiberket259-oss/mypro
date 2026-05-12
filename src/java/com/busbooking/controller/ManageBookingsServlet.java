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

@WebServlet("/admin/bookings")
public class ManageBookingsServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ManageBookingsServlet.class.getName());
    private static final String MANAGE_BOOKINGS_VIEW = "/views/admin/manage_bookings.jsp";
    private static final String VIEW_BOOKING_VIEW = "/views/admin/view_booking.jsp";
    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "view":
                    viewBooking(request, response);
                    break;
                default:
                    listBookings(request, response);
                    break;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in ManageBookingsServlet", e);
            request.getSession().setAttribute("error", "A database error occurred. Please try again.");
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
            return;
        }

        try {
            if ("cancel".equals(action)) {
                cancelBooking(request, response);
            } else if ("updateStatus".equals(action)) {
                updateBookingStatus(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/bookings");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error processing booking action", e);
            request.getSession().setAttribute("error", "Could not process your request.");
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
        }
    }

    /**
     * Lists all bookings with optional filters, search, and pagination.
     * Also fetches seat numbers for each booking.
     */
    private void listBookings(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            } catch (NumberFormatException ignored) {}
        }

        String statusFilter = request.getParameter("status");
        String searchTerm = request.getParameter("search");

        BookingDAO bookingDAO = new BookingDAO();
        List<Booking> bookings = bookingDAO.getAllBookings((page - 1) * PAGE_SIZE, PAGE_SIZE, statusFilter, searchTerm);
        int totalBookings = bookingDAO.getTotalBookingCount(statusFilter, searchTerm);
        int totalPages = (int) Math.ceil((double) totalBookings / PAGE_SIZE);
        if (totalPages == 0) totalPages = 1;

        // ✅ 为每个预订加载座位号
        SeatDAO seatDAO = new SeatDAO();
        for (Booking booking : bookings) {
            List<String> seats = seatDAO.getSeatsByBookingId(booking.getBookingId());
            booking.setSeatNumbers(seats);
        }

        request.setAttribute("bookings", bookings);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalBookings", totalBookings);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("searchTerm", searchTerm);

        request.getRequestDispatcher(MANAGE_BOOKINGS_VIEW).forward(request, response);
    }

    /**
     * Displays detailed information for a single booking.
     */
    private void viewBooking(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        String bookingId = request.getParameter("id");
        if (bookingId == null || bookingId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
            return;
        }

        bookingId = bookingId.trim();

        BookingDAO bookingDAO = new BookingDAO();
        Booking booking = bookingDAO.getBookingById(bookingId);

        if (booking == null) {
            request.getSession().setAttribute("error", "Booking not found.");
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
            return;
        }

        SeatDAO seatDAO = new SeatDAO();
        List<String> seatNumbers = seatDAO.getSeatsByBookingId(bookingId);
        booking.setSeatNumbers(seatNumbers);

        request.setAttribute("booking", booking);
        request.setAttribute("seatNumbers", seatNumbers);

        request.getRequestDispatcher(VIEW_BOOKING_VIEW).forward(request, response);
    }

    /**
     * Cancels a booking (admin override). Releases seats and updates status.
     */
    private void cancelBooking(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        String bookingId = request.getParameter("bookingId");
        if (bookingId == null || bookingId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
            return;
        }

        bookingId = bookingId.trim();

        BookingDAO bookingDAO = new BookingDAO();
        Booking booking = bookingDAO.getBookingById(bookingId);

        if (booking == null) {
            request.getSession().setAttribute("error", "Booking not found.");
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
            return;
        }

        if ("CANCELLED".equals(booking.getStatus()) || "EXPIRED".equals(booking.getStatus())) {
            request.getSession().setAttribute("error", "Booking is already " + booking.getStatus().toLowerCase() + ".");
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
            return;
        }

        boolean cancelled = bookingDAO.cancelBooking(bookingId);
        if (cancelled) {
            request.getSession().setAttribute("success", "Booking " + bookingId + " cancelled successfully.");
        } else {
            request.getSession().setAttribute("error", "Failed to cancel booking.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/bookings");
    }

    /**
     * Updates the status of a booking (e.g., mark as EXPIRED).
     */
    private void updateBookingStatus(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        String bookingId = request.getParameter("bookingId");
        String newStatus = request.getParameter("newStatus");

        if (bookingId == null || bookingId.trim().isEmpty() || newStatus == null || newStatus.trim().isEmpty()) {
            request.getSession().setAttribute("error", "Invalid request.");
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
            return;
        }

        bookingId = bookingId.trim();
        newStatus = newStatus.trim();

        BookingDAO bookingDAO = new BookingDAO();
        boolean updated = bookingDAO.updateBookingStatus(bookingId, newStatus);
        if (updated) {
            request.getSession().setAttribute("success", "Booking status updated to " + newStatus + ".");
        } else {
            request.getSession().setAttribute("error", "Failed to update booking status.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/bookings");
    }
}
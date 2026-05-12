package com.busbooking.controller;

import com.busbooking.dao.BookingDAO;
import com.busbooking.dao.SeatDAO;
import com.busbooking.model.Booking;
import com.busbooking.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/mybookings")
public class MyBookingsServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(MyBookingsServlet.class.getName());
    private static final int PAGE_SIZE = 10; // Number of bookings per page
    private static final String VIEW_PATH = "/views/mybookings.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Authentication check
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        int page = 1;

        // Parse page parameter
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        BookingDAO bookingDAO = new BookingDAO();
        SeatDAO seatDAO = new SeatDAO();

        try {
            // Get total count for pagination
            int totalBookings = bookingDAO.getUserBookingCount(user.getUserId());
            int totalPages = (int) Math.ceil((double) totalBookings / PAGE_SIZE);
            if (totalPages == 0) totalPages = 1;

            // Ensure page is within valid range
            if (page > totalPages) page = totalPages;

            int offset = (page - 1) * PAGE_SIZE;

            // Fetch user's bookings for current page
            List<Booking> bookings = bookingDAO.getUserBookings(user.getUserId(), offset, PAGE_SIZE);

            // Populate seat numbers for each booking
            for (Booking booking : bookings) {
                List<String> seatNumbers = seatDAO.getSeatsByBookingId(booking.getBookingId());
                booking.setSeatNumbers(seatNumbers);
            }

            // Set request attributes
            request.setAttribute("bookings", bookings);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalBookings", totalBookings);

            LOGGER.log(Level.INFO, "User {0} viewed bookings page {1}", new Object[]{user.getUserId(), page});

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching bookings for user " + user.getUserId(), e);
            session.setAttribute("error", "Unable to load your bookings. Please try again later.");
        }

        request.getRequestDispatcher(VIEW_PATH).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // POST requests are not used for viewing, redirect to GET
        doGet(request, response);
    }
}
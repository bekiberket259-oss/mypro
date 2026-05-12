package com.busbooking.controller;

import com.busbooking.dao.BookingDAO;
import com.busbooking.dao.SeatDAO;
import com.busbooking.model.Booking;
import com.busbooking.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/dashboard")
public class UserDashboardServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(UserDashboardServlet.class.getName());
    private static final String DASHBOARD_VIEW = "/views/dashboard.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        BookingDAO bookingDAO = new BookingDAO();
        SeatDAO seatDAO = new SeatDAO();

        try {
            // ----- Statistics -----
            int totalBookings = bookingDAO.getUserBookingCount(user.getUserId());
            int upcomingBookings = bookingDAO.getUpcomingBookingsCount(user.getUserId());
            int pendingBookings = bookingDAO.getBookingCountByStatusAndUser("PENDING", user.getUserId());
            double totalSpent = bookingDAO.getTotalSpentByUser(user.getUserId());

            request.setAttribute("totalBookings", totalBookings);
            request.setAttribute("upcomingBookings", upcomingBookings);
            request.setAttribute("pendingBookings", pendingBookings);
            request.setAttribute("totalSpent", totalSpent);

            // ----- Recent 5 bookings -----
            List<Booking> recentBookings = bookingDAO.getUserBookings(user.getUserId(), 0, 5);
            for (Booking booking : recentBookings) {
                List<String> seatNumbers = seatDAO.getSeatsByBookingId(booking.getBookingId());
                booking.setSeatNumbers(seatNumbers);
            }
            request.setAttribute("recentUserBookings", recentBookings);

            // Update last login timestamp in session (display only)
            session.setAttribute("lastLogin", new java.util.Date());

            LOGGER.log(Level.INFO, "User dashboard loaded for user ID: {0}", user.getUserId());

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error loading user dashboard", e);
            request.setAttribute("error", "Unable to load dashboard data. Please try again later.");
        }

        request.getRequestDispatcher(DASHBOARD_VIEW).forward(request, response);
    }
}
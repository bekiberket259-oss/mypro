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

@WebServlet("/viewTicket")
public class ViewTicketServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ViewTicketServlet.class.getName());
    private static final String TICKET_VIEW = "/views/ticket.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String bookingId = request.getParameter("bookingId");

        if (bookingId == null || bookingId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/mybookings");
            return;
        }

        bookingId = bookingId.trim();

        try {
            BookingDAO bookingDAO = new BookingDAO();
            Booking booking = bookingDAO.getBookingById(bookingId);

            // Security: ensure the booking belongs to the logged-in user
            if (booking == null || booking.getUserId() != user.getUserId()) {
                session.setAttribute("error", "Booking not found or access denied.");
                response.sendRedirect(request.getContextPath() + "/mybookings");
                return;
            }

            SeatDAO seatDAO = new SeatDAO();
            List<String> seatNumbers = seatDAO.getSeatsByBookingId(bookingId);
            booking.setSeatNumbers(seatNumbers);

            request.setAttribute("booking", booking);
            request.setAttribute("seatNumbers", seatNumbers);
            request.getRequestDispatcher(TICKET_VIEW).forward(request, response);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching ticket: " + bookingId, e);
            session.setAttribute("error", "Unable to load ticket. Please try again.");
            response.sendRedirect(request.getContextPath() + "/mybookings");
        }
    }
}
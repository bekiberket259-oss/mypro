package com.busbooking.controller;

import com.busbooking.dao.BookingDAO;
import com.busbooking.dao.RouteDAO;
import com.busbooking.dao.SeatDAO;
import com.busbooking.model.Booking;
import com.busbooking.model.Route;
import com.busbooking.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/booking")
public class BookingServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(BookingServlet.class.getName());
    private static final String BOOKING_VIEW = "/views/booking.jsp";
    private static final String LOGIN_URL = "/login";
    private static final String SEARCH_URL = "/search";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + LOGIN_URL);
            return;
        }

        String routeIdStr = request.getParameter("routeId");
        String travelDateStr = request.getParameter("date");

        if (isNullOrEmpty(routeIdStr) || isNullOrEmpty(travelDateStr)) {
            response.sendRedirect(request.getContextPath() + SEARCH_URL);
            return;
        }

        try {
            int routeId = Integer.parseInt(routeIdStr);
            Date travelDate = Date.valueOf(travelDateStr);

            if (travelDate.toLocalDate().isBefore(LocalDate.now())) {
                request.setAttribute("error", "Cannot book for past dates.");
                response.sendRedirect(request.getContextPath() + SEARCH_URL);
                return;
            }

            RouteDAO routeDAO = new RouteDAO();
            Route route = routeDAO.getRouteById(routeId);

            if (route == null) {
                request.setAttribute("error", "Route not found.");
                response.sendRedirect(request.getContextPath() + SEARCH_URL);
                return;
            }

            SeatDAO seatDAO = new SeatDAO();
            List<String> bookedSeats = seatDAO.getBookedSeats(routeId, travelDate);
            int totalSeats = route.getTotalSeats();

            request.setAttribute("route", route);
            request.setAttribute("travelDate", travelDateStr);
            request.setAttribute("bookedSeatsList", bookedSeats);
            request.setAttribute("totalSeats", totalSeats);

            User user = (User) session.getAttribute("user");
            request.setAttribute("passengerName", user.getFullName());
            request.setAttribute("passengerEmail", user.getEmail());
            request.setAttribute("passengerPhone", user.getPhone());

            request.getRequestDispatcher(BOOKING_VIEW).forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid route ID format.");
            response.sendRedirect(request.getContextPath() + SEARCH_URL);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Invalid date format.");
            response.sendRedirect(request.getContextPath() + SEARCH_URL);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading booking page", e);
            request.setAttribute("error", "Unable to load booking page.");
            response.sendRedirect(request.getContextPath() + SEARCH_URL);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + LOGIN_URL);
            return;
        }

        User user = (User) session.getAttribute("user");
        String routeIdStr = request.getParameter("routeId");
        String travelDateStr = request.getParameter("travelDate");
        String[] selectedSeats = request.getParameterValues("seats");
        String passengerName = request.getParameter("passengerName");
        String passengerEmail = request.getParameter("passengerEmail");
        String passengerPhone = request.getParameter("passengerPhone");

        if (isNullOrEmpty(routeIdStr) || isNullOrEmpty(travelDateStr) ||
                selectedSeats == null || selectedSeats.length == 0 ||
                isNullOrEmpty(passengerName) || isNullOrEmpty(passengerEmail) || isNullOrEmpty(passengerPhone)) {
            request.setAttribute("error", "All fields are required and at least one seat must be selected.");
            forwardWithData(request, response, routeIdStr, travelDateStr, passengerName, passengerEmail, passengerPhone);
            return;
        }

        try {
            int routeId = Integer.parseInt(routeIdStr);
            Date travelDate = Date.valueOf(travelDateStr);
            List<String> seatList = Arrays.asList(selectedSeats);

            if (travelDate.toLocalDate().isBefore(LocalDate.now())) {
                request.setAttribute("error", "Cannot book for past dates.");
                forwardWithData(request, response, routeIdStr, travelDateStr, passengerName, passengerEmail, passengerPhone);
                return;
            }

            if (!passengerEmail.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
                request.setAttribute("error", "Invalid email address.");
                forwardWithData(request, response, routeIdStr, travelDateStr, passengerName, passengerEmail, passengerPhone);
                return;
            }

            if (!passengerPhone.matches("^09[0-9]{8}$")) {
                request.setAttribute("error", "Phone number must be in Ethiopian format (09xxxxxxxx).");
                forwardWithData(request, response, routeIdStr, travelDateStr, passengerName, passengerEmail, passengerPhone);
                return;
            }

            RouteDAO routeDAO = new RouteDAO();
            Route route = routeDAO.getRouteById(routeId);
            if (route == null) {
                request.setAttribute("error", "Selected route does not exist.");
                forwardWithData(request, response, routeIdStr, travelDateStr, passengerName, passengerEmail, passengerPhone);
                return;
            }

            SeatDAO seatDAO = new SeatDAO();
            for (String seat : seatList) {
                if (!seatDAO.isSeatAvailable(routeId, travelDate, seat)) {
                    request.setAttribute("error", "Seat " + seat + " is no longer available.");
                    forwardWithData(request, response, routeIdStr, travelDateStr, passengerName, passengerEmail, passengerPhone);
                    return;
                }
            }

            double totalFare = route.getFare() * seatList.size();

            Booking booking = new Booking();
            booking.setUserId(user.getUserId());
            booking.setRouteId(routeId);
            booking.setTravelDate(travelDate);
            booking.setPassengerName(passengerName.trim());
            booking.setPassengerEmail(passengerEmail.trim().toLowerCase());
            booking.setPassengerPhone(passengerPhone.trim());
            booking.setTotalFare(totalFare);
            booking.setStatus("CONFIRMED");   // Payment simulation will keep it confirmed

            BookingDAO bookingDAO = new BookingDAO();
            String bookingId = bookingDAO.createBooking(booking, seatList);

            if (bookingId != null) {
                // Store payment information in session for payment.jsp
                session.setAttribute("lastBookingId", bookingId);
                session.setAttribute("paymentAmount", totalFare);
                session.setAttribute("paymentRoute", route.getSource() + " → " + route.getDestination());
                session.setAttribute("paymentSeats", String.join(", ", seatList));

                LOGGER.log(Level.INFO, "Booking created: {0} by user {1}", new Object[]{bookingId, user.getUserId()});

                // Redirect to payment page (not confirmation yet)
                response.sendRedirect(request.getContextPath() + "/views/payment.jsp");
            } else {
                request.setAttribute("error", "Booking failed due to a system error.");
                forwardWithData(request, response, routeIdStr, travelDateStr, passengerName, passengerEmail, passengerPhone);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid route ID format.");
            forwardWithData(request, response, routeIdStr, travelDateStr, passengerName, passengerEmail, passengerPhone);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Invalid date format.");
            forwardWithData(request, response, routeIdStr, travelDateStr, passengerName, passengerEmail, passengerPhone);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Booking error", e);
            request.setAttribute("error", "An unexpected error occurred.");
            forwardWithData(request, response, routeIdStr, travelDateStr, passengerName, passengerEmail, passengerPhone);
        }
    }

    private void forwardWithData(HttpServletRequest request, HttpServletResponse response,
                                 String routeIdStr, String travelDateStr,
                                 String passengerName, String passengerEmail, String passengerPhone)
            throws ServletException, IOException {
        request.setAttribute("routeId", routeIdStr);
        request.setAttribute("travelDate", travelDateStr);
        request.setAttribute("passengerName", passengerName);
        request.setAttribute("passengerEmail", passengerEmail);
        request.setAttribute("passengerPhone", passengerPhone);

        if (routeIdStr != null && travelDateStr != null) {
            try {
                int routeId = Integer.parseInt(routeIdStr);
                Date travelDate = Date.valueOf(travelDateStr);
                RouteDAO routeDAO = new RouteDAO();
                Route route = routeDAO.getRouteById(routeId);
                if (route != null) {
                    request.setAttribute("route", route);
                    SeatDAO seatDAO = new SeatDAO();
                    List<String> bookedSeats = seatDAO.getBookedSeats(routeId, travelDate);
                    request.setAttribute("bookedSeatsList", bookedSeats);
                    request.setAttribute("totalSeats", route.getTotalSeats());
                }
            } catch (Exception ignored) {}
        }
        request.getRequestDispatcher(BOOKING_VIEW).forward(request, response);
    }

    private boolean isNullOrEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }
}
package com.busbooking.controller;

import com.busbooking.dao.RouteDAO;
import com.busbooking.model.Route;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/search")
public class SearchServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(SearchServlet.class.getName());

    // ✅ Correct paths (inside /views/)
    private static final String SEARCH_VIEW = "/views/search.jsp";
    private static final String INDEX_VIEW = "/views/index.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // 🔹 Get parameters
        String from = request.getParameter("from");
        String to = request.getParameter("to");
        String dateStr = request.getParameter("date");

        String minFareStr = request.getParameter("minFare");
        String maxFareStr = request.getParameter("maxFare");
        String busType = request.getParameter("busType");

        // 🔥 CASE 1: Open search page WITHOUT parameters
        if (from == null && to == null && dateStr == null) {
            request.getRequestDispatcher(SEARCH_VIEW).forward(request, response);
            return;
        }

        // 🔹 Preserve values (for form refill)
        request.setAttribute("from", from);
        request.setAttribute("to", to);
        request.setAttribute("date", dateStr);
        request.setAttribute("minFare", minFareStr);
        request.setAttribute("maxFare", maxFareStr);
        request.setAttribute("busType", busType);

        // ---------- VALIDATION ----------

        // Required fields
        if (isNullOrEmpty(from) || isNullOrEmpty(to) || isNullOrEmpty(dateStr)) {
            request.setAttribute("error", "All search fields are required.");
            request.getRequestDispatcher(SEARCH_VIEW).forward(request, response);
            return;
        }

        from = from.trim();
        to = to.trim();
        dateStr = dateStr.trim();

        // Date validation
        Date travelDate;
        try {
            travelDate = Date.valueOf(dateStr);
            LocalDate selectedDate = travelDate.toLocalDate();
            LocalDate today = LocalDate.now();

            if (selectedDate.isBefore(today)) {
                request.setAttribute("error", "Travel date cannot be in the past.");
                request.getRequestDispatcher(SEARCH_VIEW).forward(request, response);
                return;
            }

            if (selectedDate.isAfter(today.plusMonths(3))) {
                request.setAttribute("error", "Bookings allowed only up to 3 months ahead.");
                request.getRequestDispatcher(SEARCH_VIEW).forward(request, response);
                return;
            }

        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Invalid date format (YYYY-MM-DD).");
            request.getRequestDispatcher(SEARCH_VIEW).forward(request, response);
            return;
        }

        // Same source/destination
        if (from.equalsIgnoreCase(to)) {
            request.setAttribute("error", "Source and destination cannot be the same.");
            request.getRequestDispatcher(SEARCH_VIEW).forward(request, response);
            return;
        }

        // ---------- OPTIONAL FILTERS ----------

        Double minFare = null;
        Double maxFare = null;

        try {
            if (!isNullOrEmpty(minFareStr)) {
                minFare = Double.parseDouble(minFareStr);
                if (minFare < 0) throw new NumberFormatException();
            }

            if (!isNullOrEmpty(maxFareStr)) {
                maxFare = Double.parseDouble(maxFareStr);
                if (maxFare < 0) throw new NumberFormatException();
            }

            if (minFare != null && maxFare != null && minFare > maxFare) {
                request.setAttribute("error", "Min fare cannot be greater than max fare.");
                request.getRequestDispatcher(SEARCH_VIEW).forward(request, response);
                return;
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid fare values.");
            request.getRequestDispatcher(SEARCH_VIEW).forward(request, response);
            return;
        }

        // ---------- SEARCH DATABASE ----------

        RouteDAO routeDAO = new RouteDAO();

        try {
            List<Route> routes = routeDAO.searchRoutes(from, to, travelDate, minFare, maxFare, busType);

            request.setAttribute("routes", routes);
            request.setAttribute("resultCount", routes.size());

            LOGGER.log(Level.INFO,
                    "Search: from={0}, to={1}, date={2}, results={3}",
                    new Object[]{from, to, dateStr, routes.size()});

            request.getRequestDispatcher(SEARCH_VIEW).forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Search error", e);
            request.setAttribute("error", "Search failed. Try again.");
            request.getRequestDispatcher(SEARCH_VIEW).forward(request, response);
        }
    }

    private boolean isNullOrEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }
}
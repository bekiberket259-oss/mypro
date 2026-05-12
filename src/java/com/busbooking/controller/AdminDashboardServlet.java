package com.busbooking.controller;

import com.busbooking.dao.*;
import com.busbooking.model.Booking;
import com.busbooking.model.Bus;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminDashboardServlet.class.getName());
    private static final String DASHBOARD_VIEW = "/views/admin/admin_dashboard.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // No session check needed – AdminFilter already ensures admin is authenticated

        try {
            // Initialize DAOs
            UserDAO userDAO = new UserDAO();
            BusDAO busDAO = new BusDAO();
            RouteDAO routeDAO = new RouteDAO();
            BookingDAO bookingDAO = new BookingDAO();

            // ========== SUMMARY STATISTICS ==========
            int totalUsers = userDAO.getTotalUsers();
            int totalBuses = busDAO.getTotalBuses();
            int activeBuses = busDAO.getActiveBusesCount();
            int totalRoutes = routeDAO.getTotalRoutes();
            int activeRoutes = routeDAO.getActiveRoutesCount();
            int totalBookings = bookingDAO.getTotalBookings();
            int confirmedBookings = bookingDAO.getBookingCountByStatus("CONFIRMED");
            double totalRevenue = bookingDAO.getTotalRevenue();

            request.setAttribute("totalUsers", totalUsers);
            request.setAttribute("totalBuses", totalBuses);
            request.setAttribute("activeBuses", activeBuses);
            request.setAttribute("totalRoutes", totalRoutes);
            request.setAttribute("activeRoutes", activeRoutes);
            request.setAttribute("totalBookings", totalBookings);
            request.setAttribute("confirmedBookings", confirmedBookings);
            request.setAttribute("totalRevenue", totalRevenue);

            // ========== CHART DATA: DAILY REVENUE (LAST 7 DAYS) ==========
            List<String> dailyLabels = new ArrayList<>();
            List<Double> dailyRevenueData = bookingDAO.getDailyRevenueLast7Days();

            // Generate labels for the last 7 days (newest last)
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.DAY_OF_YEAR, -6); // Start from 6 days ago
            SimpleDateFormat sdf = new SimpleDateFormat("MMM dd");
            for (int i = 0; i < 7; i++) {
                dailyLabels.add(sdf.format(cal.getTime()));
                cal.add(Calendar.DAY_OF_YEAR, 1);
            }
            // Pad with zeros if revenue list is shorter
            while (dailyRevenueData.size() < 7) {
                dailyRevenueData.add(0.0);
            }

            // Convert to JSON using Gson
            Gson gson = new Gson();
            request.setAttribute("dailyLabelsJson", gson.toJson(dailyLabels));
            request.setAttribute("dailyRevenueJson", gson.toJson(dailyRevenueData));

            // ========== CHART DATA: REVENUE PER BUS ==========
            List<Bus> allBuses = busDAO.getActiveBuses();
            List<String> busNames = new ArrayList<>();
            for (Bus bus : allBuses) {
                busNames.add(bus.getBusName() + " (" + bus.getBusNumber() + ")");
            }
            List<Double> busRevenueData = bookingDAO.getRevenuePerBus();
            // Pad with zeros if necessary
            while (busRevenueData.size() < busNames.size()) {
                busRevenueData.add(0.0);
            }

            request.setAttribute("busNamesJson", gson.toJson(busNames));
            request.setAttribute("busRevenueJson", gson.toJson(busRevenueData));

            // ========== RECENT BOOKINGS (FOR TABLE) ==========
            List<Booking> recentBookings = bookingDAO.getAllBookings(0, 5, null, null);
            request.setAttribute("recentBookings", recentBookings);

            LOGGER.log(Level.INFO, "Admin dashboard loaded successfully");

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error loading admin dashboard", e);
            request.getSession().setAttribute("error", "Unable to load dashboard data. Please try again later.");
        }

        request.getRequestDispatcher(DASHBOARD_VIEW).forward(request, response);
    }
}
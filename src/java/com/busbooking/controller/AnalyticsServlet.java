package com.busbooking.controller;

import com.busbooking.dao.BookingDAO;
import com.busbooking.dao.BusDAO;
import com.busbooking.dao.RouteDAO;
import com.busbooking.dao.UserDAO;
import com.busbooking.model.Bus;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/admin/analytics")
public class AnalyticsServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AnalyticsServlet.class.getName());
    private static final String ANALYTICS_VIEW = "/views/admin/analytics.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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
            double totalRevenue = bookingDAO.getTotalRevenue();

            request.setAttribute("totalUsers", totalUsers);
            request.setAttribute("totalBuses", totalBuses);
            request.setAttribute("activeBuses", activeBuses);
            request.setAttribute("totalRoutes", totalRoutes);
            request.setAttribute("activeRoutes", activeRoutes);
            request.setAttribute("totalBookings", totalBookings);
            request.setAttribute("totalRevenue", totalRevenue);

            Gson gson = new Gson();

            // ========== DAILY REVENUE (LAST 30 DAYS – FULL RANGE) ==========
            List<Map<String, Object>> dailyData = bookingDAO.getDailyRevenueLast30DaysFull();
            List<String> dailyLabels = new ArrayList<>();
            List<Double> dailyRevenueData = new ArrayList<>();
            for (Map<String, Object> day : dailyData) {
                dailyLabels.add(day.get("date").toString());
                dailyRevenueData.add((Double) day.get("revenue"));
            }
            request.setAttribute("dailyLabelsJson", gson.toJson(dailyLabels));
            request.setAttribute("dailyRevenueJson", gson.toJson(dailyRevenueData));

            // ========== MONTHLY REVENUE (LAST 12 MONTHS – FULL RANGE) ==========
            List<Map<String, Object>> monthlyData = bookingDAO.getMonthlyRevenueLast12MonthsFull();
            List<String> monthlyLabels = new ArrayList<>();
            List<Double> monthlyRevenueData = new ArrayList<>();
            for (Map<String, Object> month : monthlyData) {
                monthlyLabels.add(month.get("month").toString());
                monthlyRevenueData.add((Double) month.get("revenue"));
            }
            request.setAttribute("monthlyLabelsJson", gson.toJson(monthlyLabels));
            request.setAttribute("monthlyRevenueJson", gson.toJson(monthlyRevenueData));

            // ========== REVENUE PER BUS ==========
            List<Bus> allBuses = busDAO.getActiveBuses();
            List<String> busNames = new ArrayList<>();
            for (Bus bus : allBuses) {
                busNames.add(bus.getBusName() + " (" + bus.getBusNumber() + ")");
            }
            List<Double> busRevenueData = bookingDAO.getRevenuePerBus();
            while (busRevenueData.size() < busNames.size()) {
                busRevenueData.add(0.0);
            }
            request.setAttribute("busNamesJson", gson.toJson(busNames));
            request.setAttribute("busRevenueJson", gson.toJson(busRevenueData));

            // ========== TOP ROUTES BY BOOKINGS ==========
            List<Map<String, Object>> topRoutes = bookingDAO.getTopRoutesByBookings(5);
            request.setAttribute("topRoutes", topRoutes);

            LOGGER.log(Level.INFO, "Analytics dashboard loaded successfully");

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error loading analytics", e);
            request.getSession().setAttribute("error", "Unable to load analytics data. Please try again later.");
        }

        request.getRequestDispatcher(ANALYTICS_VIEW).forward(request, response);
    }
}
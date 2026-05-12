package com.busbooking.controller;

import com.busbooking.dao.RouteDAO;
import com.busbooking.dao.BusDAO;
import com.busbooking.model.Route;
import com.busbooking.model.Bus;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;                 // <-- ADDED
import java.sql.SQLException;
import java.sql.Time;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/admin/routes")
public class ManageRoutesServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ManageRoutesServlet.class.getName());
    private static final String MANAGE_ROUTES_VIEW = "/views/admin/manage_routes.jsp";
    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "add":
                case "edit":
                    showEditForm(request, response);
                    break;
                case "delete":
                    deleteRoute(request, response);
                    break;
                default:
                    listRoutes(request, response);
                    break;
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doGet", e);
            request.getSession().setAttribute("error", "Database error occurred.");
            response.sendRedirect(request.getContextPath() + "/admin/routes");

        } catch (NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "Invalid number format in doGet", e);
            request.getSession().setAttribute("error", "Invalid input format.");
            response.sendRedirect(request.getContextPath() + "/admin/routes");

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error in doGet", e);
            request.getSession().setAttribute("error", "Something went wrong.");
            response.sendRedirect(request.getContextPath() + "/admin/routes");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "save";

        try {
            switch (action) {
                case "save":
                    saveRoute(request, response);
                    break;
                case "update":
                    updateRoute(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin/routes");
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doPost", e);
            request.getSession().setAttribute("error", "Database error while saving route.");
            response.sendRedirect(request.getContextPath() + "/admin/routes");

        } catch (ParseException e) {
            LOGGER.log(Level.SEVERE, "Date/Time parsing error in doPost", e);
            request.getSession().setAttribute("error", "Invalid date or time format (use yyyy-MM-dd for date, HH:mm for time).");
            response.sendRedirect(request.getContextPath() + "/admin/routes");

        } catch (NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "Number format error in doPost", e);
            request.getSession().setAttribute("error", "Invalid number input.");
            response.sendRedirect(request.getContextPath() + "/admin/routes");

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error in doPost", e);
            request.getSession().setAttribute("error", "Operation failed.");
            response.sendRedirect(request.getContextPath() + "/admin/routes");
        }
    }

    // ================= LIST ROUTES =================
    private void listRoutes(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        int page = 1;
        String pageParam = request.getParameter("page");

        if (pageParam != null) {
            try {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            } catch (NumberFormatException ignored) {}
        }

        RouteDAO routeDAO = new RouteDAO();
        BusDAO busDAO = new BusDAO();

        List<Route> routes = routeDAO.getRoutesWithPagination((page - 1) * PAGE_SIZE, PAGE_SIZE);
        List<Bus> buses = busDAO.getActiveBuses();

        int totalRoutes = routeDAO.getTotalRoutes();
        int totalPages = (int) Math.ceil((double) totalRoutes / PAGE_SIZE);
        if (totalPages == 0) totalPages = 1;

        request.setAttribute("routes", routes != null ? routes : new ArrayList<>());
        request.setAttribute("buses", buses != null ? buses : new ArrayList<>());
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRoutes", totalRoutes);

        request.getRequestDispatcher(MANAGE_ROUTES_VIEW).forward(request, response);
    }

    // ================= SHOW FORM =================
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        BusDAO busDAO = new BusDAO();
        request.setAttribute("buses", busDAO.getActiveBuses());

        String idParam = request.getParameter("id");

        if (idParam != null && !idParam.isEmpty()) {
            int routeId = Integer.parseInt(idParam);

            RouteDAO routeDAO = new RouteDAO();
            Route route = routeDAO.getRouteById(routeId);

            if (route != null) {
                request.setAttribute("route", route);
                request.setAttribute("isEdit", true);
            } else {
                request.getSession().setAttribute("error", "Route not found.");
                response.sendRedirect(request.getContextPath() + "/admin/routes");
                return;
            }
        } else {
            request.setAttribute("isEdit", false);
        }

        request.getRequestDispatcher(MANAGE_ROUTES_VIEW).forward(request, response);
    }

    // ================= SAVE ROUTE =================
    private void saveRoute(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ParseException {

        String source = request.getParameter("source");
        String destination = request.getParameter("destination");
        String travelDateStr = request.getParameter("travelDate");        // <-- NEW
        String departureTimeStr = request.getParameter("departureTime");
        String arrivalTimeStr = request.getParameter("arrivalTime");
        String duration = request.getParameter("duration");
        String fareStr = request.getParameter("fare");
        String distanceStr = request.getParameter("distance");
        String busIdStr = request.getParameter("busId");
        String isActive = request.getParameter("isActive");

        // Validate required fields (including travel date)
        if (isNullOrEmpty(source) || isNullOrEmpty(destination) ||
            isNullOrEmpty(travelDateStr) ||                               // <-- NEW
            isNullOrEmpty(departureTimeStr) || isNullOrEmpty(arrivalTimeStr) ||
            isNullOrEmpty(fareStr) || isNullOrEmpty(busIdStr)) {

            request.getSession().setAttribute("error", "All required fields must be filled (including travel date).");
            response.sendRedirect(request.getContextPath() + "/admin/routes?action=add");
            return;
        }

        // Parse travel date
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        Date travelDate = new Date(dateFormat.parse(travelDateStr).getTime());

        // Parse times
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
        Time departureTime = new Time(timeFormat.parse(departureTimeStr).getTime());
        Time arrivalTime = new Time(timeFormat.parse(arrivalTimeStr).getTime());

        Route route = new Route();
        route.setSource(source.trim());
        route.setDestination(destination.trim());
        route.setTravelDate(travelDate);                                  // <-- NEW
        route.setDepartureTime(departureTime);
        route.setArrivalTime(arrivalTime);
        route.setDuration(duration);
        route.setFare(Double.parseDouble(fareStr));
        route.setDistance(isNullOrEmpty(distanceStr) ? 0 : Integer.parseInt(distanceStr));
        route.setBusId(Integer.parseInt(busIdStr));
        route.setActive("on".equals(isActive));

        new RouteDAO().addRoute(route);

        request.getSession().setAttribute("success", "Route added successfully.");
        response.sendRedirect(request.getContextPath() + "/admin/routes");
    }

    // ================= UPDATE ROUTE =================
    private void updateRoute(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ParseException {

        String routeIdStr = request.getParameter("routeId");
        int routeId = Integer.parseInt(routeIdStr);

        // Parse travel date
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        Date travelDate = new Date(dateFormat.parse(request.getParameter("travelDate")).getTime());

        // Parse times
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
        Time departureTime = new Time(timeFormat.parse(request.getParameter("departureTime")).getTime());
        Time arrivalTime = new Time(timeFormat.parse(request.getParameter("arrivalTime")).getTime());

        Route route = new Route();
        route.setRouteId(routeId);
        route.setSource(request.getParameter("source"));
        route.setDestination(request.getParameter("destination"));
        route.setTravelDate(travelDate);                                  // <-- NEW
        route.setDepartureTime(departureTime);
        route.setArrivalTime(arrivalTime);
        route.setDuration(request.getParameter("duration"));
        route.setFare(Double.parseDouble(request.getParameter("fare")));
        route.setDistance(Integer.parseInt(request.getParameter("distance")));
        route.setBusId(Integer.parseInt(request.getParameter("busId")));
        route.setActive("on".equals(request.getParameter("isActive")));

        new RouteDAO().updateRoute(route);

        request.getSession().setAttribute("success", "Route updated successfully.");
        response.sendRedirect(request.getContextPath() + "/admin/routes");
    }

    // ================= DELETE ROUTE =================
    private void deleteRoute(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        int routeId = Integer.parseInt(request.getParameter("id"));

        RouteDAO dao = new RouteDAO();

        if (dao.hasBookings(routeId)) {
            request.getSession().setAttribute("error", "Cannot delete route – it has bookings.");
        } else {
            dao.deleteRoute(routeId);
            request.getSession().setAttribute("success", "Route deleted successfully.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/routes");
    }

    private boolean isNullOrEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }
}
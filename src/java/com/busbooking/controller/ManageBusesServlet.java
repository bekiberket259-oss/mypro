package com.busbooking.controller;

import com.busbooking.dao.BusDAO;
import com.busbooking.model.Bus;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/admin/buses")
public class ManageBusesServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ManageBusesServlet.class.getName());
    private static final String MANAGE_BUSES_VIEW = "/views/admin/manage_buses.jsp";
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
                    deleteBus(request, response);
                    break;
                default:
                    listBuses(request, response);
                    break;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in ManageBusesServlet", e);
            request.getSession().setAttribute("error", "A database error occurred. Please try again.");
            response.sendRedirect(request.getContextPath() + "/admin/buses");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "save";

        try {
            if ("save".equals(action)) {
                saveBus(request, response);
            } else if ("update".equals(action)) {
                updateBus(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/buses");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while saving bus", e);
            request.getSession().setAttribute("error", "Could not save bus. Please check your input.");
            response.sendRedirect(request.getContextPath() + "/admin/buses");
        }
    }

    /**
     * Displays the list of buses with pagination.
     */
    private void listBuses(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            } catch (NumberFormatException ignored) {}
        }

        BusDAO busDAO = new BusDAO();
        List<Bus> buses = busDAO.getBusesWithPagination((page - 1) * PAGE_SIZE, PAGE_SIZE);
        int totalBuses = busDAO.getTotalBuses();
        int totalPages = (int) Math.ceil((double) totalBuses / PAGE_SIZE);
        if (totalPages == 0) totalPages = 1;

        request.setAttribute("buses", buses);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalBuses", totalBuses);

        request.getRequestDispatcher(MANAGE_BUSES_VIEW).forward(request, response);
    }

    /**
     * Shows the form for adding a new bus or editing an existing one.
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.isEmpty()) {
            int busId = Integer.parseInt(idParam);
            BusDAO busDAO = new BusDAO();
            Bus bus = busDAO.getBusById(busId);
            if (bus != null) {
                request.setAttribute("bus", bus);
                request.setAttribute("isEdit", true);
            } else {
                request.getSession().setAttribute("error", "Bus not found.");
                response.sendRedirect(request.getContextPath() + "/admin/buses");
                return;
            }
        } else {
            request.setAttribute("isEdit", false);
        }

        request.getRequestDispatcher(MANAGE_BUSES_VIEW).forward(request, response);
    }

    /**
     * Saves a new bus to the database.
     */
    private void saveBus(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        String busNumber = request.getParameter("busNumber");
        String busName = request.getParameter("busName");
        String busType = request.getParameter("busType");
        String totalSeatsStr = request.getParameter("totalSeats");

        // Basic validation
        if (isNullOrEmpty(busNumber) || isNullOrEmpty(busName) || isNullOrEmpty(busType) || isNullOrEmpty(totalSeatsStr)) {
            request.getSession().setAttribute("error", "All fields are required.");
            response.sendRedirect(request.getContextPath() + "/admin/buses?action=add");
            return;
        }

        int totalSeats = Integer.parseInt(totalSeatsStr);
        if (totalSeats <= 0) {
            request.getSession().setAttribute("error", "Total seats must be a positive number.");
            response.sendRedirect(request.getContextPath() + "/admin/buses?action=add");
            return;
        }

        Bus bus = new Bus();
        bus.setBusNumber(busNumber.trim());
        bus.setBusName(busName.trim());
        bus.setBusType(busType);
        bus.setTotalSeats(totalSeats);
        bus.setActive(true);

        BusDAO busDAO = new BusDAO();
        if (busDAO.isBusNumberExists(busNumber.trim())) {
            request.getSession().setAttribute("error", "Bus number already exists.");
            response.sendRedirect(request.getContextPath() + "/admin/buses?action=add");
            return;
        }

        boolean added = busDAO.addBus(bus);
        if (added) {
            request.getSession().setAttribute("success", "Bus added successfully.");
        } else {
            request.getSession().setAttribute("error", "Failed to add bus.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/buses");
    }

    /**
     * Updates an existing bus.
     */
    private void updateBus(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        String busIdStr = request.getParameter("busId");
        String busNumber = request.getParameter("busNumber");
        String busName = request.getParameter("busName");
        String busType = request.getParameter("busType");
        String totalSeatsStr = request.getParameter("totalSeats");
        String isActive = request.getParameter("isActive");

        if (isNullOrEmpty(busIdStr) || isNullOrEmpty(busNumber) || isNullOrEmpty(busName) ||
            isNullOrEmpty(busType) || isNullOrEmpty(totalSeatsStr)) {
            request.getSession().setAttribute("error", "All fields are required.");
            response.sendRedirect(request.getContextPath() + "/admin/buses?action=edit&id=" + busIdStr);
            return;
        }

        int busId = Integer.parseInt(busIdStr);
        int totalSeats = Integer.parseInt(totalSeatsStr);
        boolean active = "on".equals(isActive) || "true".equals(isActive);

        Bus bus = new Bus();
        bus.setBusId(busId);
        bus.setBusNumber(busNumber.trim());
        bus.setBusName(busName.trim());
        bus.setBusType(busType);
        bus.setTotalSeats(totalSeats);
        bus.setActive(active);

        BusDAO busDAO = new BusDAO();
        boolean updated = busDAO.updateBus(bus);
        if (updated) {
            request.getSession().setAttribute("success", "Bus updated successfully.");
        } else {
            request.getSession().setAttribute("error", "Failed to update bus.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/buses");
    }

    /**
     * Soft‑deletes a bus (sets is_active = 0) after checking for related routes.
     */
    private void deleteBus(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/buses");
            return;
        }

        int busId = Integer.parseInt(idParam);
        BusDAO busDAO = new BusDAO();

        // Prevent deletion if bus has active routes
        if (busDAO.hasRoutes(busId)) {
            request.getSession().setAttribute("error", "Cannot delete bus – it is assigned to one or more routes.");
        } else {
            boolean deleted = busDAO.deleteBus(busId);
            if (deleted) {
                request.getSession().setAttribute("success", "Bus deleted successfully.");
            } else {
                request.getSession().setAttribute("error", "Failed to delete bus.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/buses");
    }

    private boolean isNullOrEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }
}
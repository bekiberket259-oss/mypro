package com.busbooking.controller;

import com.busbooking.dao.RouteDAO;
import com.busbooking.model.Route;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet that provides route data for the admin map page.
 * It reads active routes from the database (SELECT only) and forwards to map.jsp.
 */
@WebServlet("/admin/map")
public class MapServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(MapServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            RouteDAO routeDAO = new RouteDAO();
            // Retrieve only active routes (is_active = 1)
            List<Route> routes = routeDAO.getActiveRoutes();
            request.setAttribute("routes", routes);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error loading routes for map", e);
            request.setAttribute("error", "Could not load route data. Please try again later.");
        }
        // Forward to the map JSP page
        request.getRequestDispatcher("/views/admin/map.jsp").forward(request, response);
    }
}
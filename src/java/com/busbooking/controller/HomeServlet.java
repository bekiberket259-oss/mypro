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

@WebServlet("") // Root URL: /BusTicketBookingSystem/
public class HomeServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(HomeServlet.class.getName());
    private static final String HOME_VIEW = "/views/index.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            RouteDAO routeDAO = new RouteDAO();
            
            // Get the 6 most recent active routes for the "Popular Routes" section
            List<Route> popularRoutes = routeDAO.getPopularRoutes(6);
            request.setAttribute("popularRoutes", popularRoutes);
            
            LOGGER.log(Level.INFO, "Loaded {0} popular routes for homepage", popularRoutes.size());
            
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Database error while fetching popular routes for homepage", e);
            // The page will still display, just without popular routes
        }

        request.getRequestDispatcher(HOME_VIEW).forward(request, response);
    }
}
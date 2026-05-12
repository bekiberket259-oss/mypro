package com.busbooking.controller;  

import com.busbooking.dao.BookingDAO;
import com.busbooking.dao.SeatDAO;
import com.busbooking.dao.UserDAO;
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

@WebServlet("/admin/users")
public class ManageUsersServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ManageUsersServlet.class.getName());
    private static final String MANAGE_USERS_VIEW = "/views/admin/manage_users.jsp";
    private static final String VIEW_USER_VIEW = "/views/admin/view_user.jsp";
    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "view":
                    viewUser(request, response);
                    break;
                case "delete":
                    deleteUser(request, response);
                    break;
                default:
                    listUsers(request, response);
                    break;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in ManageUsersServlet", e);
            request.getSession().setAttribute("error", "A database error occurred. Please try again.");
            response.sendRedirect(request.getContextPath() + "/admin/users");
        }
    }

    /**
     * Lists all users with pagination and optional search.
     */
    private void listUsers(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            } catch (NumberFormatException ignored) {}
        }

        String searchTerm = request.getParameter("search");

        UserDAO userDAO = new UserDAO();
        List<User> users;
        int totalUsers;

        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            // You'll need to add this method to UserDAO or use a filter
            users = userDAO.searchUsers(searchTerm.trim(), (page - 1) * PAGE_SIZE, PAGE_SIZE);
            totalUsers = userDAO.getSearchResultCount(searchTerm.trim());
        } else {
            users = userDAO.getUsersWithPagination((page - 1) * PAGE_SIZE, PAGE_SIZE);
            totalUsers = userDAO.getTotalUsers();
        }

        int totalPages = (int) Math.ceil((double) totalUsers / PAGE_SIZE);
        if (totalPages == 0) totalPages = 1;

        request.setAttribute("users", users);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("searchTerm", searchTerm);

        request.getRequestDispatcher(MANAGE_USERS_VIEW).forward(request, response);
    }

    /**
     * Displays detailed information for a single user along with their booking history.
     */
    private void viewUser(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        String userIdParam = request.getParameter("id");
        if (userIdParam == null || userIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        int userId = Integer.parseInt(userIdParam);
        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserById(userId);
        if (user == null) {
            request.getSession().setAttribute("error", "User not found.");
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        // Fetch user's booking history
        BookingDAO bookingDAO = new BookingDAO();
        List<Booking> userBookings = bookingDAO.getUserBookings(userId, 0, 100); // limit to 100 bookings
        SeatDAO seatDAO = new SeatDAO();
        for (Booking booking : userBookings) {
            List<String> seatNumbers = seatDAO.getSeatsByBookingId(booking.getBookingId());
            booking.setSeatNumbers(seatNumbers);
        }

        request.setAttribute("user", user);
        request.setAttribute("userBookings", userBookings);

        request.getRequestDispatcher(VIEW_USER_VIEW).forward(request, response);
    }

    /**
     * Deletes a user (and cascades to bookings via foreign key).
     */
    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        String userIdParam = request.getParameter("id");
        if (userIdParam == null || userIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        int userId = Integer.parseInt(userIdParam);
        UserDAO userDAO = new UserDAO();
        boolean deleted = userDAO.deleteUser(userId);
        if (deleted) {
            request.getSession().setAttribute("success", "User deleted successfully.");
        } else {
            request.getSession().setAttribute("error", "Failed to delete user.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}








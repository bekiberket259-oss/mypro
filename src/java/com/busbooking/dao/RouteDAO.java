package com.busbooking.dao;

import com.busbooking.model.Route;
import com.busbooking.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RouteDAO {

    // ==================== CREATE ====================
    
    public boolean addRoute(Route route) throws SQLException {
        String sql = "INSERT INTO routes (source, destination, travel_date, departure_time, arrival_time, duration, fare, distance, bus_id, is_active) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, route.getSource());
            stmt.setString(2, route.getDestination());
            stmt.setDate(3, route.getTravelDate());
            stmt.setTime(4, route.getDepartureTime());
            stmt.setTime(5, route.getArrivalTime());
            stmt.setString(6, route.getDuration());
            stmt.setDouble(7, route.getFare());
            stmt.setInt(8, route.getDistance());
            stmt.setInt(9, route.getBusId());
            stmt.setBoolean(10, route.isActive());
            return stmt.executeUpdate() > 0;
        }
    }

    // ==================== READ ====================
    
    public Route getRouteById(int routeId) throws SQLException {
        String sql = "SELECT r.*, b.bus_name, b.bus_number, b.bus_type, b.total_seats FROM routes r " +
                     "JOIN buses b ON r.bus_id = b.bus_id WHERE r.route_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, routeId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return extractRouteFromResultSet(rs);
            }
        }
        return null;
    }

    public List<Route> getAllRoutes() throws SQLException {
        List<Route> routes = new ArrayList<>();
        String sql = "SELECT r.*, b.bus_name, b.bus_number, b.bus_type, b.total_seats FROM routes r " +
                     "JOIN buses b ON r.bus_id = b.bus_id ORDER BY r.route_id DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                routes.add(extractRouteFromResultSet(rs));
            }
        }
        return routes;
    }

    public List<Route> getActiveRoutes() throws SQLException {
        List<Route> routes = new ArrayList<>();
        String sql = "SELECT r.*, b.bus_name, b.bus_number, b.bus_type, b.total_seats FROM routes r " +
                     "JOIN buses b ON r.bus_id = b.bus_id WHERE r.is_active = 1 ORDER BY r.route_id DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                routes.add(extractRouteFromResultSet(rs));
            }
        }
        return routes;
    }

    /**
     * Returns the most recent active routes (used for "Popular Destinations").
     */
    public List<Route> getPopularRoutes(int limit) throws SQLException {
        List<Route> routes = new ArrayList<>();
        String sql = "SELECT r.*, b.bus_name, b.bus_number, b.bus_type, b.total_seats " +
                     "FROM routes r JOIN buses b ON r.bus_id = b.bus_id " +
                     "WHERE r.is_active = 1 ORDER BY r.route_id DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                routes.add(extractRouteFromResultSet(rs));
            }
        }
        return routes;
    }

    public List<Route> getRoutesWithPagination(int offset, int limit) throws SQLException {
        List<Route> routes = new ArrayList<>();
        String sql = "SELECT r.*, b.bus_name, b.bus_number, b.bus_type, b.total_seats FROM routes r " +
                     "JOIN buses b ON r.bus_id = b.bus_id ORDER BY r.route_id DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            stmt.setInt(2, offset);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                routes.add(extractRouteFromResultSet(rs));
            }
        }
        return routes;
    }

    /**
     * Enhanced search with optional price range and bus type filter.
     */
    public List<Route> searchRoutes(String source, String destination, Date travelDate, 
                                    Double minFare, Double maxFare, String busType) throws SQLException {
        List<Route> routes = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT r.*, b.bus_name, b.bus_number, b.bus_type, b.total_seats FROM routes r " +
            "JOIN buses b ON r.bus_id = b.bus_id " +
            "WHERE r.source LIKE ? AND r.destination LIKE ? AND r.is_active = 1"
        );
        
        List<Object> params = new ArrayList<>();
        params.add("%" + source + "%");
        params.add("%" + destination + "%");
        
        if (travelDate != null) {
            sql.append(" AND r.travel_date = ?");
            params.add(travelDate);
        }
        if (minFare != null && minFare > 0) {
            sql.append(" AND r.fare >= ?");
            params.add(minFare);
        }
        if (maxFare != null && maxFare > 0) {
            sql.append(" AND r.fare <= ?");
            params.add(maxFare);
        }
        if (busType != null && !busType.isEmpty()) {
            sql.append(" AND b.bus_type = ?");
            params.add(busType);
        }
        
        sql.append(" ORDER BY r.departure_time");
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    stmt.setString(i + 1, (String) param);
                } else if (param instanceof Double) {
                    stmt.setDouble(i + 1, (Double) param);
                } else if (param instanceof Date) {
                    stmt.setDate(i + 1, (Date) param);
                }
            }
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                routes.add(extractRouteFromResultSet(rs));
            }
        }
        return routes;
    }

    // Legacy search method for backward compatibility
    public List<Route> searchRoutes(String source, String destination, Date travelDate) throws SQLException {
        return searchRoutes(source, destination, travelDate, null, null, null);
    }

    // ==================== UPDATE ====================
    
    public boolean updateRoute(Route route) throws SQLException {
        String sql = "UPDATE routes SET source = ?, destination = ?, travel_date = ?, departure_time = ?, arrival_time = ?, " +
                     "duration = ?, fare = ?, distance = ?, bus_id = ?, is_active = ? WHERE route_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, route.getSource());
            stmt.setString(2, route.getDestination());
            stmt.setDate(3, route.getTravelDate());
            stmt.setTime(4, route.getDepartureTime());
            stmt.setTime(5, route.getArrivalTime());
            stmt.setString(6, route.getDuration());
            stmt.setDouble(7, route.getFare());
            stmt.setInt(8, route.getDistance());
            stmt.setInt(9, route.getBusId());
            stmt.setBoolean(10, route.isActive());
            stmt.setInt(11, route.getRouteId());
            return stmt.executeUpdate() > 0;
        }
    }

    // ==================== DELETE ====================
    
    /**
     * Soft delete: sets is_active = 0.
     */
    public boolean deleteRoute(int routeId) throws SQLException {
        String sql = "UPDATE routes SET is_active = 0 WHERE route_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, routeId);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Hard delete (use with caution – only if no bookings exist).
     */
    public boolean hardDeleteRoute(int routeId) throws SQLException {
        String sql = "DELETE FROM routes WHERE route_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, routeId);
            return stmt.executeUpdate() > 0;
        }
    }

    // ==================== STATISTICS ====================
    
    public int getTotalRoutes() throws SQLException {
        String sql = "SELECT COUNT(*) FROM routes";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public int getActiveRoutesCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM routes WHERE is_active = 1";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    /**
     * Checks if a route has any bookings.
     */
    public boolean hasBookings(int routeId) throws SQLException {
        String sql = "SELECT booking_id FROM bookings WHERE route_id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, routeId);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }

    // ==================== VALIDATION ====================
    
    /**
     * Checks for duplicate route (same source, destination, bus, departure time AND travel date).
     */
    public boolean isRouteExists(String source, String destination, int busId, Time departureTime, Date travelDate) throws SQLException {
        String sql = "SELECT route_id FROM routes WHERE source = ? AND destination = ? AND bus_id = ? AND departure_time = ? AND travel_date = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, source);
            stmt.setString(2, destination);
            stmt.setInt(3, busId);
            stmt.setTime(4, departureTime);
            stmt.setDate(5, travelDate);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }

    // ==================== HELPER METHOD ====================
    
    private Route extractRouteFromResultSet(ResultSet rs) throws SQLException {
        Route route = new Route();
        route.setRouteId(rs.getInt("route_id"));
        route.setSource(rs.getString("source"));
        route.setDestination(rs.getString("destination"));
        route.setTravelDate(rs.getDate("travel_date"));
        route.setDepartureTime(rs.getTime("departure_time"));
        route.setArrivalTime(rs.getTime("arrival_time"));
        route.setDuration(rs.getString("duration"));
        route.setFare(rs.getDouble("fare"));
        route.setDistance(rs.getInt("distance"));
        route.setBusId(rs.getInt("bus_id"));
        route.setActive(rs.getBoolean("is_active"));
        
        // Joined bus fields (may be null if query didn't join)
        try {
            route.setBusName(rs.getString("bus_name"));
            route.setBusNumber(rs.getString("bus_number"));
            route.setBusType(rs.getString("bus_type"));
            route.setTotalSeats(rs.getInt("total_seats"));
        } catch (SQLException ignored) {
            // Fields not present in query – ignore
        }
        return route;
    }
}
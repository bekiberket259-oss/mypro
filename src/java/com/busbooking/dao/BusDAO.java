package com.busbooking.dao;

import com.busbooking.model.Bus;
import com.busbooking.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BusDAO {

    // ==================== CREATE ====================
    
    public boolean addBus(Bus bus) throws SQLException {
        String sql = "INSERT INTO buses (bus_number, bus_name, bus_type, total_seats, is_active) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, bus.getBusNumber());
            stmt.setString(2, bus.getBusName());
            stmt.setString(3, bus.getBusType());
            stmt.setInt(4, bus.getTotalSeats());
            stmt.setBoolean(5, bus.isActive());
            return stmt.executeUpdate() > 0;
        }
    }

    // ==================== READ ====================
    
    public Bus getBusById(int busId) throws SQLException {
        String sql = "SELECT * FROM buses WHERE bus_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, busId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return extractBusFromResultSet(rs);
            }
        }
        return null;
    }

    public List<Bus> getAllBuses() throws SQLException {
        List<Bus> buses = new ArrayList<>();
        String sql = "SELECT * FROM buses ORDER BY bus_id DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                buses.add(extractBusFromResultSet(rs));
            }
        }
        return buses;
    }

    public List<Bus> getActiveBuses() throws SQLException {
        List<Bus> buses = new ArrayList<>();
        String sql = "SELECT * FROM buses WHERE is_active = 1 ORDER BY bus_id DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                buses.add(extractBusFromResultSet(rs));
            }
        }
        return buses;
    }

    public List<Bus> getBusesWithPagination(int offset, int limit) throws SQLException {
        List<Bus> buses = new ArrayList<>();
        String sql = "SELECT * FROM buses ORDER BY bus_id DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            stmt.setInt(2, offset);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                buses.add(extractBusFromResultSet(rs));
            }
        }
        return buses;
    }

    // ==================== UPDATE ====================
    
    public boolean updateBus(Bus bus) throws SQLException {
        String sql = "UPDATE buses SET bus_number = ?, bus_name = ?, bus_type = ?, total_seats = ?, is_active = ? WHERE bus_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, bus.getBusNumber());
            stmt.setString(2, bus.getBusName());
            stmt.setString(3, bus.getBusType());
            stmt.setInt(4, bus.getTotalSeats());
            stmt.setBoolean(5, bus.isActive());
            stmt.setInt(6, bus.getBusId());
            return stmt.executeUpdate() > 0;
        }
    }

    // ==================== DELETE ====================
    
    /**
     * Soft delete: sets is_active = 0 instead of actually deleting.
     * This prevents foreign key constraint violations with routes.
     */
    public boolean deleteBus(int busId) throws SQLException {
        String sql = "UPDATE buses SET is_active = 0 WHERE bus_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, busId);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Hard delete (use with caution – only if no related routes exist).
     */
    public boolean hardDeleteBus(int busId) throws SQLException {
        String sql = "DELETE FROM buses WHERE bus_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, busId);
            return stmt.executeUpdate() > 0;
        }
    }

    // ==================== STATISTICS ====================
    
    public int getTotalBuses() throws SQLException {
        String sql = "SELECT COUNT(*) FROM buses";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public int getActiveBusesCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM buses WHERE is_active = 1";
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
     * Checks if a bus has any associated routes.
     * @return true if routes exist, false otherwise.
     */
    public boolean hasRoutes(int busId) throws SQLException {
        String sql = "SELECT route_id FROM routes WHERE bus_id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, busId);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }

    // ==================== VALIDATION ====================
    
    public boolean isBusNumberExists(String busNumber) throws SQLException {
        String sql = "SELECT bus_id FROM buses WHERE bus_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, busNumber);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }

    // ==================== HELPER METHOD ====================
    
    private Bus extractBusFromResultSet(ResultSet rs) throws SQLException {
        Bus bus = new Bus();
        bus.setBusId(rs.getInt("bus_id"));
        bus.setBusNumber(rs.getString("bus_number"));
        bus.setBusName(rs.getString("bus_name"));
        bus.setBusType(rs.getString("bus_type"));
        bus.setTotalSeats(rs.getInt("total_seats"));
        bus.setActive(rs.getBoolean("is_active"));
        return bus;
    }
}
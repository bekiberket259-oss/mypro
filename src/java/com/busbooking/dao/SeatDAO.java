package com.busbooking.dao;

import com.busbooking.model.Seat;
import com.busbooking.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SeatDAO {

    // ==================== LOCK MANAGEMENT ====================
    
    public void clearExpiredLocks() throws SQLException {
        String sql = "DELETE FROM seat_locks WHERE expires_at < NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.executeUpdate();
        }
    }

    public boolean lockSeat(int routeId, Date travelDate, String seatNumber, int userId) throws SQLException {
        clearExpiredLocks();
        String sql = "INSERT INTO seat_locks (route_id, travel_date, seat_number, user_id, expires_at) " +
                     "VALUES (?, ?, ?, ?, DATE_ADD(NOW(), INTERVAL 10 MINUTE))";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, routeId);
            stmt.setDate(2, travelDate);
            stmt.setString(3, seatNumber);
            stmt.setInt(4, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLIntegrityConstraintViolationException e) {
            return false;
        }
    }

    public void releaseLocks(int userId, int routeId, Date travelDate) throws SQLException {
        String sql = "DELETE FROM seat_locks WHERE user_id = ? AND route_id = ? AND travel_date = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, routeId);
            stmt.setDate(3, travelDate);
            stmt.executeUpdate();
        }
    }

    public List<String> getLockedSeatsForUser(int userId, int routeId, Date travelDate) throws SQLException {
        clearExpiredLocks();
        List<String> lockedSeats = new ArrayList<>();
        String sql = "SELECT seat_number FROM seat_locks WHERE user_id = ? AND route_id = ? AND travel_date = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, routeId);
            stmt.setDate(3, travelDate);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                lockedSeats.add(rs.getString("seat_number"));
            }
        }
        return lockedSeats;
    }

    // ==================== AVAILABILITY ====================
    
    public boolean isSeatAvailable(int routeId, Date travelDate, String seatNumber) throws SQLException {
        clearExpiredLocks();
        
        String bookSql = "SELECT is_booked FROM seats WHERE route_id = ? AND travel_date = ? AND seat_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(bookSql)) {
            stmt.setInt(1, routeId);
            stmt.setDate(2, travelDate);
            stmt.setString(3, seatNumber);
            ResultSet rs = stmt.executeQuery();
            if (rs.next() && rs.getBoolean("is_booked")) {
                return false;
            }
        }
        
        String lockSql = "SELECT lock_id FROM seat_locks WHERE route_id = ? AND travel_date = ? AND seat_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(lockSql)) {
            stmt.setInt(1, routeId);
            stmt.setDate(2, travelDate);
            stmt.setString(3, seatNumber);
            ResultSet rs = stmt.executeQuery();
            return !rs.next();
        }
    }

    // ==================== SEAT STATUS ====================
    
    public List<Seat> getSeatStatus(int routeId, Date travelDate) throws SQLException {
        clearExpiredLocks();
        List<Seat> seats = new ArrayList<>();
        int totalSeats = getTotalSeatsForRoute(routeId);
        if (totalSeats == 0) return seats;
        
        List<String> bookedSeats = getBookedSeats(routeId, travelDate);
        List<String> lockedSeats = new ArrayList<>();
        String lockSql = "SELECT seat_number FROM seat_locks WHERE route_id = ? AND travel_date = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(lockSql)) {
            stmt.setInt(1, routeId);
            stmt.setDate(2, travelDate);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                lockedSeats.add(rs.getString("seat_number"));
            }
        }
        
        for (int i = 1; i <= totalSeats; i++) {
            String seatNum = String.valueOf(i);
            Seat seat = new Seat();
            seat.setRouteId(routeId);
            seat.setTravelDate(travelDate);
            seat.setSeatNumber(seatNum);
            seat.setBooked(bookedSeats.contains(seatNum) || lockedSeats.contains(seatNum));
            seats.add(seat);
        }
        return seats;
    }

    private int getTotalSeatsForRoute(int routeId) throws SQLException {
        String sql = "SELECT b.total_seats FROM routes r JOIN buses b ON r.bus_id = b.bus_id WHERE r.route_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, routeId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("total_seats");
            }
        }
        return 0;
    }

    public List<String> getBookedSeats(int routeId, Date travelDate) throws SQLException {
        List<String> booked = new ArrayList<>();
        String sql = "SELECT seat_number FROM seats WHERE route_id = ? AND travel_date = ? AND is_booked = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, routeId);
            stmt.setDate(2, travelDate);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                booked.add(rs.getString("seat_number"));
            }
        }
        return booked;
    }

    // ==================== BOOKING OPERATIONS ====================
    
    public boolean insertBookedSeats(String bookingId, int routeId, Date travelDate, 
                                     List<String> seatNumbers, Connection conn) throws SQLException {
        String sql = "INSERT INTO seats (booking_id, route_id, travel_date, seat_number, is_booked, booked_at) " +
                     "VALUES (?, ?, ?, ?, 1, NOW())";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            for (String seat : seatNumbers) {
                stmt.setString(1, bookingId);
                stmt.setInt(2, routeId);
                stmt.setDate(3, travelDate);
                stmt.setString(4, seat);
                stmt.addBatch();
            }
            int[] results = stmt.executeBatch();
            for (int i : results) if (i <= 0) return false;
            return true;
        }
    }

    /**
     * Retrieves all seat numbers associated with a booking.
     */
    public List<String> getSeatsByBookingId(String bookingId) throws SQLException {
        List<String> seats = new ArrayList<>();
        String sql = "SELECT seat_number FROM seats WHERE booking_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, bookingId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                seats.add(rs.getString("seat_number"));
            }
        }
        return seats;
    }

    public boolean cancelSeatsForBooking(String bookingId) throws SQLException {
        String sql = "UPDATE seats SET is_booked = 0, booking_id = NULL WHERE booking_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, bookingId);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Releases all seats associated with a booking using an existing connection.
     * This method is intended to be called within a transaction.
     *
     * @param conn      active database connection (transaction managed by caller)
     * @param bookingId the booking ID whose seats should be released
     * @return true if the update executed successfully (even if zero rows affected)
     * @throws SQLException if a database error occurs
     */
    public boolean releaseSeatsByBooking(Connection conn, String bookingId) throws SQLException {
        String sql = "UPDATE seats SET is_booked = 0, booking_id = NULL WHERE booking_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, bookingId);
            stmt.executeUpdate();
            return true;
        }
    }

    // ==================== ADMIN ====================
    
    public int getBookedSeatCount(int routeId, Date travelDate) throws SQLException {
        String sql = "SELECT COUNT(*) FROM seats WHERE route_id = ? AND travel_date = ? AND is_booked = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, routeId);
            stmt.setDate(2, travelDate);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public boolean deleteSeatsForRoute(int routeId) throws SQLException {
        String sql = "DELETE FROM seats WHERE route_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, routeId);
            return stmt.executeUpdate() > 0;
        }
    }
}

package com.busbooking.dao;

import com.busbooking.model.Booking;
import com.busbooking.util.BookingIdGenerator;
import com.busbooking.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BookingDAO {

    // ==================== CREATE ====================
    
    public String createBooking(Booking booking, List<String> seatNumbers) throws SQLException {
        Connection conn = null;
        String bookingId = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            bookingId = BookingIdGenerator.generateBookingId();

            String bookingSql = "INSERT INTO bookings (booking_id, user_id, route_id, travel_date, passenger_name, passenger_email, passenger_phone, total_fare, status) " +
                               "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')";
            try (PreparedStatement stmt = conn.prepareStatement(bookingSql)) {
                stmt.setString(1, bookingId);
                stmt.setInt(2, booking.getUserId());
                stmt.setInt(3, booking.getRouteId());
                stmt.setDate(4, booking.getTravelDate());
                stmt.setString(5, booking.getPassengerName());
                stmt.setString(6, booking.getPassengerEmail());
                stmt.setString(7, booking.getPassengerPhone());
                stmt.setDouble(8, booking.getTotalFare());
                stmt.executeUpdate();
            }

            SeatDAO seatDAO = new SeatDAO();
            boolean seatsInserted = seatDAO.insertBookedSeats(bookingId, booking.getRouteId(), booking.getTravelDate(), seatNumbers, conn);
            if (!seatsInserted) {
                conn.rollback();
                return null;
            }

            seatDAO.releaseLocks(booking.getUserId(), booking.getRouteId(), booking.getTravelDate());
            conn.commit();
            return bookingId;

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw e;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    public boolean confirmBooking(String bookingId) throws SQLException {
        String sql = "UPDATE bookings SET status = 'CONFIRMED' WHERE booking_id = ? AND status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, bookingId);
            return stmt.executeUpdate() > 0;
        }
    }

    // ==================== READ ====================
    
    public Booking getBookingById(String bookingId) throws SQLException {
        String sql = "SELECT b.*, r.source, r.destination, r.departure_time, r.arrival_time, r.fare, " +
                     "bus.bus_name, bus.bus_number, bus.bus_type " +
                     "FROM bookings b " +
                     "JOIN routes r ON b.route_id = r.route_id " +
                     "JOIN buses bus ON r.bus_id = bus.bus_id " +
                     "WHERE b.booking_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, bookingId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return extractBookingFromResultSet(rs);
            }
        }
        return null;
    }

    public List<Booking> getUserBookings(int userId, int offset, int limit) throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT b.*, r.source, r.destination, r.departure_time, r.arrival_time, r.fare, " +
                     "bus.bus_name, bus.bus_number, bus.bus_type " +
                     "FROM bookings b " +
                     "JOIN routes r ON b.route_id = r.route_id " +
                     "JOIN buses bus ON r.bus_id = bus.bus_id " +
                     "WHERE b.user_id = ? " +
                     "ORDER BY b.booking_date DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, limit);
            stmt.setInt(3, offset);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                bookings.add(extractBookingFromResultSet(rs));
            }
        }
        return bookings;
    }

    public int getUserBookingCount(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM bookings WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public List<Booking> getAllBookings(int offset, int limit, String statusFilter, String searchTerm) throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT b.*, r.source, r.destination, r.departure_time, r.arrival_time, r.fare, " +
            "bus.bus_name, bus.bus_number, bus.bus_type, u.full_name as user_name " +
            "FROM bookings b " +
            "JOIN routes r ON b.route_id = r.route_id " +
            "JOIN buses bus ON r.bus_id = bus.bus_id " +
            "JOIN users u ON b.user_id = u.user_id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND b.status = ?");
            params.add(statusFilter);
        }
        if (searchTerm != null && !searchTerm.isEmpty()) {
            sql.append(" AND (b.booking_id LIKE ? OR b.passenger_name LIKE ? OR b.passenger_email LIKE ? OR u.full_name LIKE ?)");
            String term = "%" + searchTerm + "%";
            params.add(term);
            params.add(term);
            params.add(term);
            params.add(term);
        }
        sql.append(" ORDER BY b.booking_date DESC LIMIT ? OFFSET ?");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object param : params) {
                stmt.setString(idx++, param.toString());
            }
            stmt.setInt(idx++, limit);
            stmt.setInt(idx++, offset);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                bookings.add(extractBookingFromResultSet(rs));
            }
        }
        return bookings;
    }

    public int getTotalBookingCount(String statusFilter, String searchTerm) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM bookings b JOIN users u ON b.user_id = u.user_id WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND b.status = ?");
            params.add(statusFilter);
        }
        if (searchTerm != null && !searchTerm.isEmpty()) {
            sql.append(" AND (b.booking_id LIKE ? OR b.passenger_name LIKE ? OR b.passenger_email LIKE ? OR u.full_name LIKE ?)");
            String term = "%" + searchTerm + "%";
            params.add(term);
            params.add(term);
            params.add(term);
            params.add(term);
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object param : params) {
                stmt.setString(idx++, param.toString());
            }
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    // ==================== UPDATE ====================
    
    /**
     * Cancel a booking without a provided connection (standalone).
     */
    public boolean cancelBooking(String bookingId) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            String updateBooking = "UPDATE bookings SET status = 'CANCELLED' WHERE booking_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateBooking)) {
                stmt.setString(1, bookingId);
                stmt.executeUpdate();
            }
            
            String updateSeats = "UPDATE seats SET is_booked = 0, booking_id = NULL WHERE booking_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateSeats)) {
                stmt.setString(1, bookingId);
                stmt.executeUpdate();
            }
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) conn.rollback();
            throw e;
        } finally {
            if (conn != null) conn.close();
        }
    }

    /**
     * Cancel a booking using an existing connection (part of a transaction).
     * FIX: Now also cancels PENDING bookings, not just CONFIRMED.
     */
    public boolean cancelBooking(Connection conn, String bookingId) throws SQLException {
        String updateBooking = "UPDATE bookings SET status = 'CANCELLED' WHERE booking_id = ? AND status IN ('PENDING', 'CONFIRMED')";
        try (PreparedStatement stmt = conn.prepareStatement(updateBooking)) {
            stmt.setString(1, bookingId);
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        }
    }

    public boolean updateBookingStatus(String bookingId, String status) throws SQLException {
        String sql = "UPDATE bookings SET status = ? WHERE booking_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setString(2, bookingId);
            return stmt.executeUpdate() > 0;
        }
    }

    // ==================== STATISTICS / ANALYTICS ====================
    
    public int getTotalBookings() throws SQLException {
        String sql = "SELECT COUNT(*) FROM bookings";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public double getTotalRevenue() throws SQLException {
        String sql = "SELECT SUM(total_fare) FROM bookings WHERE status = 'CONFIRMED'";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getDouble(1);
        }
        return 0.0;
    }

    public List<Double> getDailyRevenueLast7Days() throws SQLException {
        List<Double> revenue = new ArrayList<>();
        String sql = "SELECT DATE(booking_date) as day, SUM(total_fare) as revenue " +
                     "FROM bookings WHERE status = 'CONFIRMED' " +
                     "GROUP BY DATE(booking_date) ORDER BY day DESC LIMIT 7";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                revenue.add(rs.getDouble("revenue"));
            }
        }
        java.util.Collections.reverse(revenue);
        return revenue;
    }

    public List<Double> getDailyRevenueLast30Days() throws SQLException {
        List<Double> revenue = new ArrayList<>();
        String sql = "SELECT DATE(booking_date) as day, SUM(total_fare) as revenue " +
                     "FROM bookings WHERE status = 'CONFIRMED' " +
                     "AND booking_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) " +
                     "GROUP BY DATE(booking_date) ORDER BY day";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                revenue.add(rs.getDouble("revenue"));
            }
        }
        return revenue;
    }

    /**
     * Returns daily revenue for the last 30 days including every single day
     * (even those with zero revenue). Result ordered oldest -> newest.
     * Uses Java to generate the date sequence – works on any MySQL version.
     */
    public List<Map<String, Object>> getDailyRevenueLast30DaysFull() throws SQLException {
        // Generate the last 30 days in Java
        List<LocalDate> days = new ArrayList<>();
        LocalDate today = LocalDate.now();
        for (int i = 29; i >= 0; i--) {
            days.add(today.minusDays(i));
        }

        // Fetch actual revenue grouped by day
        String sql = "SELECT DATE(booking_date) as day, COALESCE(SUM(total_fare), 0) as revenue " +
                     "FROM bookings WHERE status = 'CONFIRMED' " +
                     "AND booking_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) " +
                     "GROUP BY DATE(booking_date)";
        Map<LocalDate, Double> revenueMap = new HashMap<>();
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                LocalDate date = rs.getDate("day").toLocalDate();
                revenueMap.put(date, rs.getDouble("revenue"));
            }
        }

        // Build ordered result with zero fill
        List<Map<String, Object>> result = new ArrayList<>();
        for (LocalDate date : days) {
            Map<String, Object> map = new HashMap<>();
            map.put("date", date.toString()); // "2026-04-01"
            map.put("revenue", revenueMap.getOrDefault(date, 0.0));
            result.add(map);
        }
        return result;
    }

    public List<Double> getMonthlyRevenueLast6Months() throws SQLException {
        List<Double> revenue = new ArrayList<>();
        String sql = "SELECT DATE_FORMAT(booking_date, '%Y-%m') as month, SUM(total_fare) as revenue " +
                     "FROM bookings WHERE status = 'CONFIRMED' " +
                     "AND booking_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) " +
                     "GROUP BY month ORDER BY month";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                revenue.add(rs.getDouble("revenue"));
            }
        }
        return revenue;
    }

    /**
     * Returns monthly revenue for the last 12 months including months with zero revenue.
     * Result ordered oldest -> newest.
     * Uses Java to generate the month sequence – works on any MySQL version.
     */
    public List<Map<String, Object>> getMonthlyRevenueLast12MonthsFull() throws SQLException {
        // Generate the last 12 months in Java
        List<YearMonth> months = new ArrayList<>();
        YearMonth current = YearMonth.now();
        for (int i = 11; i >= 0; i--) {
            months.add(current.minusMonths(i));
        }

        // Fetch actual revenue grouped by month
        String sql = "SELECT DATE_FORMAT(booking_date, '%Y-%m') as month, COALESCE(SUM(total_fare), 0) as revenue " +
                     "FROM bookings WHERE status = 'CONFIRMED' " +
                     "AND booking_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH) " +
                     "GROUP BY month";
        Map<YearMonth, Double> revenueMap = new HashMap<>();
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                String monthStr = rs.getString("month");
                YearMonth ym = YearMonth.parse(monthStr);
                revenueMap.put(ym, rs.getDouble("revenue"));
            }
        }

        // Build ordered result with zero fill
        List<Map<String, Object>> result = new ArrayList<>();
        for (YearMonth ym : months) {
            Map<String, Object> map = new HashMap<>();
            map.put("month", ym.toString()); // "2026-04"
            map.put("revenue", revenueMap.getOrDefault(ym, 0.0));
            result.add(map);
        }
        return result;
    }

    public List<Double> getRevenuePerBus() throws SQLException {
        List<Double> revenue = new ArrayList<>();
        String sql = "SELECT bus.bus_id, SUM(b.total_fare) as revenue " +
                     "FROM bookings b " +
                     "JOIN routes r ON b.route_id = r.route_id " +
                     "JOIN buses bus ON r.bus_id = bus.bus_id " +
                     "WHERE b.status = 'CONFIRMED' GROUP BY bus.bus_id";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                revenue.add(rs.getDouble("revenue"));
            }
        }
        return revenue;
    }

    public List<Map<String, Object>> getTopRoutesByBookings(int limit) throws SQLException {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT r.source, r.destination, COUNT(b.booking_id) as booking_count " +
                     "FROM bookings b JOIN routes r ON b.route_id = r.route_id " +
                     "WHERE b.status = 'CONFIRMED' " +
                     "GROUP BY r.route_id ORDER BY booking_count DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("source", rs.getString("source"));
                row.put("destination", rs.getString("destination"));
                row.put("bookingCount", rs.getInt("booking_count"));
                result.add(row);
            }
        }
        return result;
    }

    public int getBookingCountByStatus(String status) throws SQLException {
        String sql = "SELECT COUNT(*) FROM bookings WHERE status = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int getUpcomingBookingsCount(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM bookings WHERE user_id = ? AND status = 'CONFIRMED' AND travel_date >= CURDATE()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int getBookingCountByStatusAndUser(String status, int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM bookings WHERE user_id = ? AND status = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setString(2, status);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public double getTotalSpentByUser(int userId) throws SQLException {
        String sql = "SELECT SUM(total_fare) FROM bookings WHERE user_id = ? AND status = 'CONFIRMED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                double total = rs.getDouble(1);
                return rs.wasNull() ? 0.0 : total;
            }
        }
        return 0.0;
    }

    // ==================== HELPER ====================
    
    private Booking extractBookingFromResultSet(ResultSet rs) throws SQLException {
        Booking b = new Booking();
        b.setBookingId(rs.getString("booking_id"));
        b.setUserId(rs.getInt("user_id"));
        b.setRouteId(rs.getInt("route_id"));
        b.setBookingDate(rs.getTimestamp("booking_date"));
        b.setTravelDate(rs.getDate("travel_date"));
        b.setPassengerName(rs.getString("passenger_name"));
        b.setPassengerEmail(rs.getString("passenger_email"));
        b.setPassengerPhone(rs.getString("passenger_phone"));
        b.setTotalFare(rs.getDouble("total_fare"));
        b.setStatus(rs.getString("status"));
        
        try {
            b.setSource(rs.getString("source"));
            b.setDestination(rs.getString("destination"));
            b.setDepartureTime(rs.getTime("departure_time"));
            b.setArrivalTime(rs.getTime("arrival_time"));
            b.setFare(rs.getDouble("fare"));
            b.setBusName(rs.getString("bus_name"));
            b.setBusNumber(rs.getString("bus_number"));
            b.setBusType(rs.getString("bus_type"));
        } catch (SQLException ignored) { }
        
        return b;
    }
}
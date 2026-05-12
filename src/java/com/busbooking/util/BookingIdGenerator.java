package com.busbooking.util;

import java.sql.*;
import java.time.Year;

public class BookingIdGenerator {

    /**
     * Generates a unique booking ID using a database sequence.
     * Format: BT-YYYY-XXXX (where XXXX is auto-incrementing per year)
     */
    public static String generateBookingId() throws SQLException {
        int currentYear = Year.now().getValue();
        int nextNumber = getNextSequenceNumber(currentYear);
        return String.format("BT-%d-%04d", currentYear, nextNumber);
    }

    private static int getNextSequenceNumber(int year) throws SQLException {
        Connection conn = null;
        PreparedStatement updateStmt = null;
        PreparedStatement selectStmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Try to update existing row
            String updateSql = "UPDATE booking_sequence SET last_number = last_number + 1 WHERE year = ?";
            updateStmt = conn.prepareStatement(updateSql);
            updateStmt.setInt(1, year);
            int rowsAffected = updateStmt.executeUpdate();

            if (rowsAffected == 0) {
                // Year row didn't exist, insert it with starting value 1
                String insertSql = "INSERT INTO booking_sequence (year, last_number) VALUES (?, 1)";
                try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                    insertStmt.setInt(1, year);
                    insertStmt.executeUpdate();
                }
                conn.commit();
                return 1;
            } else {
                // Read the updated value
                String selectSql = "SELECT last_number FROM booking_sequence WHERE year = ?";
                selectStmt = conn.prepareStatement(selectSql);
                selectStmt.setInt(1, year);
                rs = selectStmt.executeQuery();
                if (rs.next()) {
                    int nextNumber = rs.getInt("last_number");
                    conn.commit();
                    return nextNumber;
                } else {
                    conn.rollback();
                    throw new SQLException("Failed to retrieve sequence number for year " + year);
                }
            }
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (selectStmt != null) try { selectStmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (updateStmt != null) try { updateStmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}
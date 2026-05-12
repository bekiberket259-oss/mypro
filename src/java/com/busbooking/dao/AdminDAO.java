package com.busbooking.dao;

import com.busbooking.model.Admin;
import com.busbooking.util.DBConnection;
import com.busbooking.util.PasswordUtil;
import java.sql.*;
import java.util.Calendar;

public class AdminDAO {

    // ==================== AUTHENTICATION ====================
    
    /**
     * Authenticates an admin by username and password.
     * @return Admin object if successful, null otherwise.
     */
    public Admin login(String username, String password) throws SQLException {
        String sql = "SELECT * FROM admin WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                String hashedPassword = rs.getString("password");
                if (PasswordUtil.checkPassword(password, hashedPassword)) {
                    return extractAdminFromResultSet(rs);
                }
            }
        }
        return null;
    }

    // ==================== CRUD OPERATIONS (OPTIONAL) ====================
    
    /**
     * Retrieves an admin by their ID.
     */
    public Admin getAdminById(int adminId) throws SQLException {
        String sql = "SELECT * FROM admin WHERE admin_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, adminId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return extractAdminFromResultSet(rs);
            }
        }
        return null;
    }

    /**
     * Updates an admin's profile information (full name, email).
     */
    public boolean updateAdminProfile(Admin admin) throws SQLException {
        String sql = "UPDATE admin SET full_name = ?, email = ? WHERE admin_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, admin.getFullName());
            stmt.setString(2, admin.getEmail());
            stmt.setInt(3, admin.getAdminId());
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Changes an admin's password (requires old password verification separately).
     */
    public boolean changePassword(int adminId, String newPassword) throws SQLException {
        String sql = "UPDATE admin SET password = ? WHERE admin_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, PasswordUtil.hashPassword(newPassword));
            stmt.setInt(2, adminId);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Checks if a username already exists (useful for creating new admins).
     */
    public boolean isUsernameExists(String username) throws SQLException {
        String sql = "SELECT admin_id FROM admin WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }

    /**
     * Creates a new admin account.
     */
    public boolean createAdmin(Admin admin) throws SQLException {
        String sql = "INSERT INTO admin (username, password, full_name, email) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, admin.getUsername());
            stmt.setString(2, PasswordUtil.hashPassword(admin.getPassword()));
            stmt.setString(3, admin.getFullName());
            stmt.setString(4, admin.getEmail());
            return stmt.executeUpdate() > 0;
        }
    }

    // ==================== REMEMBER ME (TOKEN MANAGEMENT) ====================

    /**
     * Store or update a remember-me token for an admin with an expiry date.
     */
    public void setRememberToken(int adminId, String token, Timestamp expiry) throws SQLException {
        String sql = "UPDATE admin SET remember_token = ?, remember_expiry = ? WHERE admin_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, token);
            stmt.setTimestamp(2, expiry);
            stmt.setInt(3, adminId);
            stmt.executeUpdate();
        }
    }

    /**
     * Retrieve an Admin if the token is valid and not expired, otherwise null.
     */
    public Admin getAdminByRememberToken(String token) throws SQLException {
        String sql = "SELECT * FROM admin WHERE remember_token = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, token);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Timestamp expiry = rs.getTimestamp("remember_expiry");
                if (expiry != null && expiry.after(new java.util.Date())) {
                    return extractAdminFromResultSet(rs);
                }
            }
        }
        return null;
    }

    /**
     * Clear the remember-me token for an admin (on logout).
     */
    public void clearRememberToken(int adminId) throws SQLException {
        String sql = "UPDATE admin SET remember_token = NULL, remember_expiry = NULL WHERE admin_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, adminId);
            stmt.executeUpdate();
        }
    }

    // ==================== HELPER METHOD ====================
    
    private Admin extractAdminFromResultSet(ResultSet rs) throws SQLException {
        Admin admin = new Admin();
        admin.setAdminId(rs.getInt("admin_id"));
        admin.setUsername(rs.getString("username"));
        admin.setPassword(rs.getString("password")); // Hashed
        admin.setFullName(rs.getString("full_name"));
        admin.setEmail(rs.getString("email"));
        return admin;
    }
}
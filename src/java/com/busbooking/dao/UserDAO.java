package com.busbooking.dao;

import com.busbooking.model.User;
import com.busbooking.util.DBConnection;
import com.busbooking.util.PasswordUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

public class UserDAO {

    // ==================== REGISTRATION & LOGIN ====================

    public boolean registerUser(User user) throws SQLException {
        String sql = "INSERT INTO users (full_name, email, password, phone) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, user.getFullName());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, PasswordUtil.hashPassword(user.getPassword()));
            stmt.setString(4, user.getPhone());
            return stmt.executeUpdate() > 0;
        }
    }

    public User login(String email, String password) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                String hashedPassword = rs.getString("password");
                if (PasswordUtil.checkPassword(password, hashedPassword)) {
                    return extractUserFromResultSet(rs);
                }
            }
        }
        return null;
    }

    // ==================== CRUD OPERATIONS ====================

    public User getUserById(int userId) throws SQLException {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return extractUserFromResultSet(rs);
            }
        }
        return null;
    }

    public User getUserByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return extractUserFromResultSet(rs);
            }
        }
        return null;
    }

    public List<User> getAllUsers() throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                users.add(extractUserFromResultSet(rs));
            }
        }
        return users;
    }

    public List<User> getUsersWithPagination(int offset, int limit) throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            stmt.setInt(2, offset);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                users.add(extractUserFromResultSet(rs));
            }
        }
        return users;
    }

    public boolean updateUser(User user) throws SQLException {
        String sql = "UPDATE users SET full_name = ?, email = ?, phone = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, user.getFullName());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPhone());
            stmt.setInt(4, user.getUserId());
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean deleteUser(int userId) throws SQLException {
        String sql = "DELETE FROM users WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean changePassword(int userId, String newPassword) throws SQLException {
        String sql = "UPDATE users SET password = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, PasswordUtil.hashPassword(newPassword));
            stmt.setInt(2, userId);
            return stmt.executeUpdate() > 0;
        }
    }

    // ==================== SEARCH ====================

    /**
     * Searches users by full name or email with pagination.
     */
    public List<User> searchUsers(String searchTerm, int offset, int limit) throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE full_name LIKE ? OR email LIKE ? ORDER BY created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            String term = "%" + searchTerm + "%";
            stmt.setString(1, term);
            stmt.setString(2, term);
            stmt.setInt(3, limit);
            stmt.setInt(4, offset);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                users.add(extractUserFromResultSet(rs));
            }
        }
        return users;
    }

    /**
     * Returns total count of users matching the search term.
     */
    public int getSearchResultCount(String searchTerm) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE full_name LIKE ? OR email LIKE ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            String term = "%" + searchTerm + "%";
            stmt.setString(1, term);
            stmt.setString(2, term);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    // ==================== VALIDATION ====================
    
    public boolean isEmailExists(String email) throws SQLException {
        String sql = "SELECT user_id FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }

    // ==================== STATISTICS ====================
    
    public int getTotalUsers() throws SQLException {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    // ==================== REMEMBER ME (TOKEN MANAGEMENT) ====================

    /**
     * Store or update a remember‑me token for a user with an expiry date.
     */
    public void setRememberToken(int userId, String token, Timestamp expiry) throws SQLException {
        String sql = "UPDATE users SET remember_token = ?, remember_expiry = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, token);
            stmt.setTimestamp(2, expiry);
            stmt.setInt(3, userId);
            stmt.executeUpdate();
        }
    }

    /**
     * Retrieve a User if the token is valid and not expired, otherwise null.
     */
    public User getUserByRememberToken(String token) throws SQLException {
        String sql = "SELECT * FROM users WHERE remember_token = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, token);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Timestamp expiry = rs.getTimestamp("remember_expiry");
                if (expiry != null && expiry.after(new java.util.Date())) {
                    return extractUserFromResultSet(rs);
                }
            }
        }
        return null;
    }

    /**
     * Clear the remember‑me token for a user (on logout).
     */
    public void clearRememberToken(int userId) throws SQLException {
        String sql = "UPDATE users SET remember_token = NULL, remember_expiry = NULL WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        }
    }

    // ==================== HELPER METHOD ====================
    
    private User extractUserFromResultSet(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPassword(rs.getString("password")); // Hashed password
        user.setPhone(rs.getString("phone"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        return user;
    }
}
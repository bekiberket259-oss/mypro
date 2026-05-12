package com.busbooking.dao;

import com.busbooking.model.ContactMessage;
import com.busbooking.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ContactMessageDAO {

    // Save a new contact message
    public boolean saveMessage(ContactMessage msg) {
        String sql = "INSERT INTO contact_messages (name, email, subject, message) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, msg.getName());
            ps.setString(2, msg.getEmail());
            ps.setString(3, msg.getSubject());
            ps.setString(4, msg.getMessage());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get count of unread messages
    public int getUnreadCount() {
        String sql = "SELECT COUNT(*) FROM contact_messages WHERE is_read = FALSE";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Get all messages, most recent first
    public List<ContactMessage> getAllMessages() {
        List<ContactMessage> list = new ArrayList<>();
        String sql = "SELECT * FROM contact_messages ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                list.add(extractMessageFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Get a single message by ID
    public ContactMessage getMessageById(int id) {
        String sql = "SELECT * FROM contact_messages WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return extractMessageFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Mark a message as read
    public boolean markAsRead(int id) {
        String sql = "UPDATE contact_messages SET is_read = TRUE WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Delete a message by ID
    public boolean deleteMessage(int id) {
        String sql = "DELETE FROM contact_messages WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Helper method to extract ContactMessage from ResultSet
    private ContactMessage extractMessageFromResultSet(ResultSet rs) throws SQLException {
        ContactMessage msg = new ContactMessage();
        msg.setId(rs.getInt("id"));
        msg.setName(rs.getString("name"));
        msg.setEmail(rs.getString("email"));
        msg.setSubject(rs.getString("subject"));
        msg.setMessage(rs.getString("message"));
        msg.setRead(rs.getBoolean("is_read"));
        msg.setCreatedAt(rs.getTimestamp("created_at"));
        return msg;
    }
}
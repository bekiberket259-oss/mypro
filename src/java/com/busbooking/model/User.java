package com.busbooking.model;

import java.sql.Timestamp;

public class User {
    private int userId;
    private String fullName;
    private String email;
    private String password;
    private String phone;
    private String role;           // ADDED: role (admin/user)
    private Timestamp createdAt;

    // Default constructor
    public User() {}

    // Constructor without userId and role (for registration)
    public User(String fullName, String email, String password, String phone) {
        this.fullName = fullName;
        this.email = email;
        this.password = password;
        this.phone = phone;
        this.role = "admin";        // default role
    }

    // Getters and Setters
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getRole() { return role; }        // ADDED
    public void setRole(String role) { this.role = role; }  // ADDED

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
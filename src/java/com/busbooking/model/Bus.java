package com.busbooking.model;

public class Bus {
    private int busId;
    private String busNumber;
    private String busName;
    private String busType;      // Standard, Sleeper, Volvo, AC, Non-AC
    private int totalSeats;
    private boolean isActive;

    // Default constructor
    public Bus() {}

    // Constructor for new bus insertion (without busId)
    public Bus(String busNumber, String busName, String busType, int totalSeats, boolean isActive) {
        this.busNumber = busNumber;
        this.busName = busName;
        this.busType = busType;
        this.totalSeats = totalSeats;
        this.isActive = isActive;
    }

    // Full constructor
    public Bus(int busId, String busNumber, String busName, String busType, int totalSeats, boolean isActive) {
        this.busId = busId;
        this.busNumber = busNumber;
        this.busName = busName;
        this.busType = busType;
        this.totalSeats = totalSeats;
        this.isActive = isActive;
    }

    // Getters and Setters
    public int getBusId() {
        return busId;
    }

    public void setBusId(int busId) {
        this.busId = busId;
    }

    public String getBusNumber() {
        return busNumber;
    }

    public void setBusNumber(String busNumber) {
        this.busNumber = busNumber;
    }

    public String getBusName() {
        return busName;
    }

    public void setBusName(String busName) {
        this.busName = busName;
    }

    public String getBusType() {
        return busType;
    }

    public void setBusType(String busType) {
        this.busType = busType;
    }

    public int getTotalSeats() {
        return totalSeats;
    }

    public void setTotalSeats(int totalSeats) {
        this.totalSeats = totalSeats;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    @Override
    public String toString() {
        return "Bus [busId=" + busId + ", busNumber=" + busNumber + ", busName=" + busName 
                + ", busType=" + busType + ", totalSeats=" + totalSeats + ", isActive=" + isActive + "]";
    }
}
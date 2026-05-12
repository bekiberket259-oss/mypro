package com.busbooking.model;

import java.sql.Date;
import java.sql.Timestamp;

public class Seat {
    private int seatId;
    private String bookingId;        // Null if not booked
    private int routeId;
    private Date travelDate;
    private String seatNumber;
    private boolean isBooked;
    private Timestamp bookedAt;      // When the seat was booked

    // Default constructor
    public Seat() {}

    // Constructor for new seat (without seatId)
    public Seat(String bookingId, int routeId, Date travelDate, String seatNumber,
                boolean isBooked, Timestamp bookedAt) {
        this.bookingId = bookingId;
        this.routeId = routeId;
        this.travelDate = travelDate;
        this.seatNumber = seatNumber;
        this.isBooked = isBooked;
        this.bookedAt = bookedAt;
    }

    // Full constructor
    public Seat(int seatId, String bookingId, int routeId, Date travelDate,
                String seatNumber, boolean isBooked, Timestamp bookedAt) {
        this.seatId = seatId;
        this.bookingId = bookingId;
        this.routeId = routeId;
        this.travelDate = travelDate;
        this.seatNumber = seatNumber;
        this.isBooked = isBooked;
        this.bookedAt = bookedAt;
    }

    // Getters and Setters
    public int getSeatId() {
        return seatId;
    }

    public void setSeatId(int seatId) {
        this.seatId = seatId;
    }

    public String getBookingId() {
        return bookingId;
    }

    public void setBookingId(String bookingId) {
        this.bookingId = bookingId;
    }

    public int getRouteId() {
        return routeId;
    }

    public void setRouteId(int routeId) {
        this.routeId = routeId;
    }

    public Date getTravelDate() {
        return travelDate;
    }

    public void setTravelDate(Date travelDate) {
        this.travelDate = travelDate;
    }

    public String getSeatNumber() {
        return seatNumber;
    }

    public void setSeatNumber(String seatNumber) {
        this.seatNumber = seatNumber;
    }

    public boolean isBooked() {
        return isBooked;
    }

    public void setBooked(boolean booked) {
        isBooked = booked;
    }

    public Timestamp getBookedAt() {
        return bookedAt;
    }

    public void setBookedAt(Timestamp bookedAt) {
        this.bookedAt = bookedAt;
    }

    @Override
    public String toString() {
        return "Seat [seatId=" + seatId + ", bookingId=" + bookingId + ", routeId=" + routeId
                + ", travelDate=" + travelDate + ", seatNumber=" + seatNumber
                + ", isBooked=" + isBooked + ", bookedAt=" + bookedAt + "]";
    }
}
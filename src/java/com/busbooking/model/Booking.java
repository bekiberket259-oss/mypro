package com.busbooking.model;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.List;

public class Booking {
    // Database fields
    private String bookingId;
    private int userId;
    private int routeId;
    private Timestamp bookingDate;
    private Date travelDate;
    private String passengerName;
    private String passengerEmail;
    private String passengerPhone;
    private double totalFare;
    private String status;        // PENDING, CONFIRMED, CANCELLED, EXPIRED

    // Joined fields (from routes and buses tables)
    private String source;
    private String destination;
    private Time departureTime;
    private Time arrivalTime;
    private String duration;
    private double fare;           // per‑seat fare (from routes)
    private String busName;
    private String busNumber;
    private String busType;
    private int totalSeats;

    // Non‑database field (populated separately)
    private List<String> seatNumbers;

    // Default constructor
    public Booking() {}

    // Constructor for new booking creation (without bookingId and bookingDate)
    public Booking(int userId, int routeId, Date travelDate, String passengerName,
                   String passengerEmail, String passengerPhone, double totalFare, String status) {
        this.userId = userId;
        this.routeId = routeId;
        this.travelDate = travelDate;
        this.passengerName = passengerName;
        this.passengerEmail = passengerEmail;
        this.passengerPhone = passengerPhone;
        this.totalFare = totalFare;
        this.status = status;
    }

    // Full constructor
    public Booking(String bookingId, int userId, int routeId, Timestamp bookingDate,
                   Date travelDate, String passengerName, String passengerEmail,
                   String passengerPhone, double totalFare, String status) {
        this.bookingId = bookingId;
        this.userId = userId;
        this.routeId = routeId;
        this.bookingDate = bookingDate;
        this.travelDate = travelDate;
        this.passengerName = passengerName;
        this.passengerEmail = passengerEmail;
        this.passengerPhone = passengerPhone;
        this.totalFare = totalFare;
        this.status = status;
    }

    // ==================== Getters and Setters ====================

    public String getBookingId() {
        return bookingId;
    }

    public void setBookingId(String bookingId) {
        this.bookingId = bookingId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getRouteId() {
        return routeId;
    }

    public void setRouteId(int routeId) {
        this.routeId = routeId;
    }

    public Timestamp getBookingDate() {
        return bookingDate;
    }

    public void setBookingDate(Timestamp bookingDate) {
        this.bookingDate = bookingDate;
    }

    public Date getTravelDate() {
        return travelDate;
    }

    public void setTravelDate(Date travelDate) {
        this.travelDate = travelDate;
    }

    public String getPassengerName() {
        return passengerName;
    }

    public void setPassengerName(String passengerName) {
        this.passengerName = passengerName;
    }

    public String getPassengerEmail() {
        return passengerEmail;
    }

    public void setPassengerEmail(String passengerEmail) {
        this.passengerEmail = passengerEmail;
    }

    public String getPassengerPhone() {
        return passengerPhone;
    }

    public void setPassengerPhone(String passengerPhone) {
        this.passengerPhone = passengerPhone;
    }

    public double getTotalFare() {
        return totalFare;
    }

    public void setTotalFare(double totalFare) {
        this.totalFare = totalFare;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    // Joined fields getters/setters
    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public Time getDepartureTime() {
        return departureTime;
    }

    public void setDepartureTime(Time departureTime) {
        this.departureTime = departureTime;
    }

    public Time getArrivalTime() {
        return arrivalTime;
    }

    public void setArrivalTime(Time arrivalTime) {
        this.arrivalTime = arrivalTime;
    }

    public String getDuration() {
        return duration;
    }

    public void setDuration(String duration) {
        this.duration = duration;
    }

    public double getFare() {
        return fare;
    }

    public void setFare(double fare) {
        this.fare = fare;
    }

    public String getBusName() {
        return busName;
    }

    public void setBusName(String busName) {
        this.busName = busName;
    }

    public String getBusNumber() {
        return busNumber;
    }

    public void setBusNumber(String busNumber) {
        this.busNumber = busNumber;
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

    // Non‑database field
    public List<String> getSeatNumbers() {
        return seatNumbers;
    }

    public void setSeatNumbers(List<String> seatNumbers) {
        this.seatNumbers = seatNumbers;
    }

    @Override
    public String toString() {
        return "Booking [bookingId=" + bookingId + ", userId=" + userId + ", routeId=" + routeId
                + ", travelDate=" + travelDate + ", passengerName=" + passengerName
                + ", totalFare=" + totalFare + ", status=" + status + "]";
    }
}
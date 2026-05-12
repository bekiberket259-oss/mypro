package com.busbooking.model;

import java.sql.Date;
import java.sql.Time;

public class Route {
    private int routeId;
    private String source;
    private String destination;
    private Date travelDate;          // <-- NEW FIELD
    private Time departureTime;
    private Time arrivalTime;
    private String duration;
    private double fare;
    private int distance;
    private int busId;
    private boolean isActive;
    
    // Joined fields from buses table
    private String busName;
    private String busNumber;
    private String busType;
    private int totalSeats;

    // Default constructor
    public Route() {}

    // Constructor for new route insertion (without routeId)
    public Route(String source, String destination, Date travelDate, Time departureTime, 
                 Time arrivalTime, String duration, double fare, int distance, 
                 int busId, boolean isActive) {
        this.source = source;
        this.destination = destination;
        this.travelDate = travelDate;
        this.departureTime = departureTime;
        this.arrivalTime = arrivalTime;
        this.duration = duration;
        this.fare = fare;
        this.distance = distance;
        this.busId = busId;
        this.isActive = isActive;
    }

    // Full constructor
    public Route(int routeId, String source, String destination, Date travelDate, 
                 Time departureTime, Time arrivalTime, String duration, double fare, 
                 int distance, int busId, boolean isActive) {
        this.routeId = routeId;
        this.source = source;
        this.destination = destination;
        this.travelDate = travelDate;
        this.departureTime = departureTime;
        this.arrivalTime = arrivalTime;
        this.duration = duration;
        this.fare = fare;
        this.distance = distance;
        this.busId = busId;
        this.isActive = isActive;
    }

    // Getters and Setters
    public int getRouteId() { return routeId; }
    public void setRouteId(int routeId) { this.routeId = routeId; }

    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }

    public String getDestination() { return destination; }
    public void setDestination(String destination) { this.destination = destination; }

    public Date getTravelDate() { return travelDate; }          // <-- NEW
    public void setTravelDate(Date travelDate) { this.travelDate = travelDate; }

    public Time getDepartureTime() { return departureTime; }
    public void setDepartureTime(Time departureTime) { this.departureTime = departureTime; }

    public Time getArrivalTime() { return arrivalTime; }
    public void setArrivalTime(Time arrivalTime) { this.arrivalTime = arrivalTime; }

    public String getDuration() { return duration; }
    public void setDuration(String duration) { this.duration = duration; }

    public double getFare() { return fare; }
    public void setFare(double fare) { this.fare = fare; }

    public int getDistance() { return distance; }
    public void setDistance(int distance) { this.distance = distance; }

    public int getBusId() { return busId; }
    public void setBusId(int busId) { this.busId = busId; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    // Joined fields getters/setters
    public String getBusName() { return busName; }
    public void setBusName(String busName) { this.busName = busName; }

    public String getBusNumber() { return busNumber; }
    public void setBusNumber(String busNumber) { this.busNumber = busNumber; }

    public String getBusType() { return busType; }
    public void setBusType(String busType) { this.busType = busType; }

    public int getTotalSeats() { return totalSeats; }
    public void setTotalSeats(int totalSeats) { this.totalSeats = totalSeats; }

    @Override
    public String toString() {
        return "Route [routeId=" + routeId + ", source=" + source + ", destination=" + destination
                + ", travelDate=" + travelDate + ", departureTime=" + departureTime 
                + ", arrivalTime=" + arrivalTime + ", duration=" + duration + ", fare=" + fare 
                + ", distance=" + distance + ", busId=" + busId + ", isActive=" + isActive + "]";
    }
}
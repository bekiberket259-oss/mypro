<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="header.jsp" %>

<c:if test="${empty route}">
    <div class="error-container">
        <h2><i class="fas fa-exclamation-triangle"></i> Route Not Found</h2>
        <p>The selected route is no longer available or does not exist.</p>
        <a href="${pageContext.request.contextPath}/search" class="btn-primary">
            <i class="fas fa-arrow-left"></i> Back to Search
        </a>
    </div>
</c:if>

<c:if test="${not empty route}">
    <%-- Progress Indicator --%>
    <div class="booking-progress">
        <div class="progress-step active">
            <span class="step-number">1</span>
            <span class="step-label">Search</span>
        </div>
        <div class="progress-step active">
            <span class="step-number">2</span>
            <span class="step-label">Select Seats</span>
        </div>
        <div class="progress-step">
            <span class="step-number">3</span>
            <span class="step-label">Payment</span>
        </div>
        <div class="progress-step">
            <span class="step-number">4</span>
            <span class="step-label">Confirmation</span>
        </div>
    </div>

    <div class="booking-container">
        <%-- Left Column: Seat Map & Journey Details --%>
        <div class="seat-section card">
            <div class="journey-header">
                <div class="route-title">
                    <h2><c:out value="${route.source}"/> → <c:out value="${route.destination}"/></h2>
                    <p class="journey-meta">
                        <i class="far fa-calendar-alt"></i> 
                        <fmt:parseDate value="${param.date}" pattern="yyyy-MM-dd" var="travelDateParsed"/>
                        <fmt:formatDate value="${travelDateParsed}" pattern="EEEE, MMMM d, yyyy"/>
                        <span class="separator">|</span>
                        <i class="far fa-clock"></i> Departure: 
                        <fmt:formatDate value="${route.departureTime}" pattern="hh:mm a"/>
                        <span class="separator">|</span>
                        <i class="fas fa-tag"></i> ETB <fmt:formatNumber value="${route.fare}" pattern="#,##0.00"/> / seat
                    </p>
                </div>
                <a href="${pageContext.request.contextPath}/search?from=${param.from}&to=${param.to}&date=${param.date}" 
                   class="btn-back">
                    <i class="fas fa-arrow-left"></i> Modify Search
                </a>
            </div>

            <%-- Driver Indicator --%>
            <div class="driver-indicator">
                <i class="fas fa-steering-wheel"></i> Driver Cabin
            </div>

            <%-- Seat Legend --%>
            <div class="seat-legend">
                <div class="legend-item">
                    <span class="seat-icon available"></span> Available
                </div>
                <div class="legend-item">
                    <span class="seat-icon selected"></span> Selected
                </div>
                <div class="legend-item">
                    <span class="seat-icon booked"></span> Booked
                </div>
            </div>

            <%-- 
                Bus Seat Map with 2+2 layout and central aisle.
                The grid uses 5 columns: left seats (2fr), aisle (30px), right seats (2fr).
                We generate seats in groups of 4: seat, seat, aisle, seat, seat.
            --%>
            <div class="seat-map" id="seatMap">
                <c:set var="total" value="${route.totalSeats}" />
                <c:forEach var="rowStart" begin="1" step="4" end="${total}">
                    <%-- Left side seats (first two of the row) --%>
                    <c:forEach var="i" begin="0" end="1">
                        <c:set var="seatNumber" value="${rowStart + i}" />
                        <c:if test="${seatNumber <= total}">
                            <c:set var="seatStr" value="${seatNumber}"/>
                            <c:set var="isBooked" value="${fn:contains(bookedSeatsList, seatStr)}"/>
                            <div class="seat ${isBooked ? 'booked' : 'available'}" 
                                 data-seat="${seatStr}"
                                 title="Seat ${seatStr} ${isBooked ? '(Booked)' : ''}"
                                 <c:if test="${isBooked}">data-booked="true"</c:if>>
                                <c:out value="${seatStr}"/>
                            </div>
                        </c:if>
                    </c:forEach>

                    <%-- Aisle column (always present, even if fewer seats) --%>
                    <div class="aisle"></div>

                    <%-- Right side seats (next two of the row) --%>
                    <c:forEach var="i" begin="2" end="3">
                        <c:set var="seatNumber" value="${rowStart + i}" />
                        <c:if test="${seatNumber <= total}">
                            <c:set var="seatStr" value="${seatNumber}"/>
                            <c:set var="isBooked" value="${fn:contains(bookedSeatsList, seatStr)}"/>
                            <div class="seat ${isBooked ? 'booked' : 'available'}" 
                                 data-seat="${seatStr}"
                                 title="Seat ${seatStr} ${isBooked ? '(Booked)' : ''}"
                                 <c:if test="${isBooked}">data-booked="true"</c:if>>
                                <c:out value="${seatStr}"/>
                            </div>
                        </c:if>
                    </c:forEach>
                </c:forEach>
            </div>

            <p class="bus-layout-hint">
                <i class="fas fa-info-circle"></i> Click on an available seat to select/deselect.
            </p>
        </div>

        <%-- Right Column: Booking Summary & Passenger Form (Sticky) --%>
        <div class="summary-section">
            <div class="card sticky-summary">
                <h3>Booking Summary</h3>
                <div class="summary-details">
                    <div class="summary-row">
                        <span>Selected Seats:</span>
                        <span id="selectedSeatsDisplay">No seats selected</span>
                    </div>
                    <div class="summary-row">
                        <span>Seats Count:</span>
                        <span id="seatCount">0</span>
                    </div>
                    <div class="summary-row">
                        <span>Price per seat:</span>
                        <span>ETB <fmt:formatNumber value="${route.fare}" pattern="#,##0.00"/></span>
                    </div>
                    <div class="summary-row total">
                        <span>Total Fare:</span>
                        <span id="totalFare">ETB 0.00</span>
                    </div>
                </div>

                <form action="${pageContext.request.contextPath}/booking" method="post" id="bookingForm">
                    <input type="hidden" name="routeId" value="<c:out value='${route.routeId}'/>">
                    <input type="hidden" name="travelDate" value="<c:out value='${param.date}'/>">
                    <input type="hidden" name="seats" id="selectedSeatsInput">

                    <h4><i class="fas fa-user-circle"></i> Passenger Details</h4>
                    <div class="form-group">
                        <label for="passengerName"><i class="fas fa-user"></i> Full Name</label>
                        <input type="text" id="passengerName" name="passengerName" 
                               placeholder="Enter your full name" 
                               value="<c:out value='${sessionScope.user.fullName}'/>" required>
                    </div>
                    <div class="form-group">
                        <label for="passengerEmail"><i class="fas fa-envelope"></i> Email</label>
                        <input type="email" id="passengerEmail" name="passengerEmail" 
                               placeholder="you@example.com" 
                               value="<c:out value='${sessionScope.user.email}'/>" required>
                    </div>
                    <div class="form-group">
                        <label for="passengerPhone"><i class="fas fa-phone"></i> Phone (09xxxxxxxx)</label>
                        <input type="tel" id="passengerPhone" name="passengerPhone" 
                               placeholder="0912345678" pattern="09[0-9]{8}" 
                               value="<c:out value='${sessionScope.user.phone}'/>" required>
                    </div>

                    <button type="submit" id="proceedBtn" class="btn-success">
                        <i class="fas fa-lock"></i> Continue to Payment
                    </button>
                    <p class="secure-text"><i class="fas fa-shield-alt"></i> Your data is secure</p>
                </form>
            </div>
        </div>
    </div>
</c:if>

<!-- Hidden data for JavaScript -->
<script>
    var routeFare = ${route.fare};
    var totalSeats = ${route.totalSeats};
    var bookedSeatsArray = [
        <c:forEach var="seat" items="${bookedSeatsList}" varStatus="status">
            "${seat}"<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];
    var contextPath = "${pageContext.request.contextPath}";
</script>
<script src="${pageContext.request.contextPath}/js/booking.js"></script>

<style>
    /* ==== Enhanced Progress Bar ==== */
    .booking-progress {
        display: flex;
        justify-content: space-between;
        margin-bottom: 2rem;
        background: white;
        padding: 1.5rem 2rem;
        border-radius: 16px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        position: relative;
    }
    .booking-progress::before {
        content: '';
        position: absolute;
        top: 42px;
        left: 10%;
        width: 80%;
        height: 3px;
        background: #e5e7eb;
        z-index: 0;
    }
    .progress-step {
        display: flex;
        flex-direction: column;
        align-items: center;
        color: #9ca3af;
        position: relative;
        z-index: 1;
        background: white;
        padding: 0 10px;
    }
    .progress-step.active .step-number {
        background: #2563eb;
        color: white;
        border-color: #2563eb;
    }
    .progress-step.active .step-label {
        color: #1f2937;
        font-weight: 600;
    }
    .step-number {
        width: 35px;
        height: 35px;
        border-radius: 50%;
        border: 2px solid #d1d5db;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 0.5rem;
        background: white;
        font-weight: 600;
    }

    /* ==== Page Background Depth ==== */
    body {
        background: #f8fafc;
    }

    /* ==== Driver Indicator ==== */
    .driver-indicator {
        text-align: center;
        font-weight: 600;
        color: #4b5563;
        margin: 0 0 1.5rem 0;
        padding: 0.5rem;
        background: #f1f5f9;
        border-radius: 30px;
        font-size: 0.9rem;
    }
    .driver-indicator i {
        margin-right: 0.5rem;
        color: #2563eb;
    }

    /* ==== Seat Map with 2+2 Layout and Aisle ==== */
    .seat-map {
        display: grid;
        grid-template-columns: repeat(2, 1fr) 30px repeat(2, 1fr);
        gap: 12px;
        justify-content: center;
        margin: 2rem auto;
        max-width: 450px;
    }
    .aisle {
        background: transparent;
        pointer-events: none;
    }
    .seat {
        width: 100%;
        aspect-ratio: 1 / 1;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 12px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s ease;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        color: white;
    }
    .seat.available {
        background: #16a34a;
    }
    .seat.available:hover {
        transform: scale(1.05);
        background: #15803d;
    }
    .seat.selected {
        background: #f59e0b;
        box-shadow: 0 0 0 3px rgba(245, 158, 11, 0.3);
        animation: pop 0.2s ease;
    }
    .seat.booked {
        background: #dc2626;
        cursor: not-allowed;
        opacity: 0.8;
        pointer-events: none;
    }

    @keyframes pop {
        0% { transform: scale(1); }
        50% { transform: scale(1.2); }
        100% { transform: scale(1); }
    }

    /* Seat Legend */
    .seat-legend {
        display: flex;
        gap: 1.5rem;
        justify-content: center;
        margin-bottom: 0.5rem;
    }
    .legend-item {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        font-size: 0.875rem;
        color: #4b5563;
    }
    .seat-icon {
        width: 20px;
        height: 20px;
        border-radius: 6px;
    }
    .seat-icon.available { background: #16a34a; }
    .seat-icon.selected { background: #f59e0b; }
    .seat-icon.booked { background: #dc2626; }

    /* Summary Enhancements */
    .summary-row.total {
        font-size: 1.4rem;
        font-weight: 700;
        color: #16a34a;
        border-bottom: none;
        padding-top: 1rem;
    }
    .summary-section h4 {
        margin-top: 1.5rem;
        border-top: 1px solid #e5e7eb;
        padding-top: 1.5rem;
    }

    /* Button Stronger CTA */
    .btn-success {
        width: 100%;
        padding: 0.9rem;
        background: #2563eb;
        color: white;
        border: none;
        border-radius: 12px;
        font-weight: 600;
        font-size: 1.1rem;
        letter-spacing: 0.5px;
        cursor: pointer;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 0.5rem;
    }
    .btn-success:hover {
        background: #1e40af;
        transform: translateY(-2px);
        box-shadow: 0 10px 15px -3px rgba(37, 99, 235, 0.2);
    }
    .btn-success:disabled {
        opacity: 0.7;
        transform: none;
        cursor: not-allowed;
    }

    /* Trust microcopy */
    .secure-text {
        text-align: center;
        color: #6b7280;
        font-size: 0.8rem;
        margin-top: 0.75rem;
    }
    .secure-text i {
        color: #10b981;
        margin-right: 0.25rem;
    }

    /* Mobile Refinements */
    @media (max-width: 768px) {
        .booking-container {
            flex-direction: column;
        }
        .seat-map {
            grid-template-columns: repeat(2, 1fr) 20px repeat(2, 1fr);
            gap: 8px;
            max-width: 100%;
        }
        .seat {
            width: 100%;
            font-size: 0.9rem;
        }
        .journey-header {
            flex-direction: column;
            gap: 1rem;
        }
        .booking-progress {
            flex-wrap: wrap;
            gap: 1rem;
        }
        .booking-progress::before {
            display: none;
        }
    }
    @media (max-width: 480px) {
        .seat {
            font-size: 0.75rem;
        }
        .seat-map {
            gap: 6px;
        }
    }

    /* Reuse existing card styles */
    .card {
        background: white;
        border-radius: 20px;
        padding: 1.5rem;
        box-shadow: 0 10px 25px -5px rgba(0,0,0,0.05);
        border: 1px solid #f0f2f5;
    }
    .sticky-summary {
        position: sticky;
        top: 20px;
    }
    .booking-container {
        display: flex;
        gap: 2rem;
        align-items: flex-start;
    }
    .seat-section {
        flex: 2;
    }
    .summary-section {
        flex: 1;
    }
    .journey-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 1.5rem;
        padding-bottom: 1rem;
        border-bottom: 1px solid #eef2f6;
    }
    .route-title h2 {
        margin-bottom: 0.5rem;
    }
    .journey-meta {
        color: #6b7280;
    }
    .separator {
        margin: 0 0.75rem;
        color: #d1d5db;
    }
    .btn-back {
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        color: #2563eb;
        text-decoration: none;
        font-weight: 500;
        padding: 0.5rem 1rem;
        background: #eff6ff;
        border-radius: 30px;
        transition: background 0.2s;
    }
    .btn-back:hover {
        background: #dbeafe;
    }
    .summary-details {
        margin: 1.5rem 0;
    }
    .summary-row {
        display: flex;
        justify-content: space-between;
        padding: 0.75rem 0;
        border-bottom: 1px dashed #e5e7eb;
    }
    .form-group {
        margin-bottom: 1.25rem;
    }
    .form-group label {
        display: block;
        margin-bottom: 0.5rem;
        font-weight: 500;
        color: #374151;
    }
    .form-group input {
        width: 100%;
        padding: 0.75rem 1rem;
        border: 1px solid #d1d5db;
        border-radius: 10px;
        font-size: 1rem;
        transition: border-color 0.2s;
    }
    .form-group input:focus {
        outline: none;
        border-color: #2563eb;
        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
    }
    .bus-layout-hint {
        text-align: center;
        color: #6b7280;
        font-size: 0.875rem;
        margin-top: 1rem;
    }
</style>

<%@ include file="footer.jsp" %>

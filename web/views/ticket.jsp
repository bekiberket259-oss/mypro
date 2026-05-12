<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="header.jsp" %>

<c:if test="${empty booking}">
    <div class="error-container">
        <h2><i class="fas fa-exclamation-triangle"></i> Ticket Not Found</h2>
        <p>The requested ticket could not be found.</p>
        <a href="${pageContext.request.contextPath}/mybookings" class="btn-primary">
            <i class="fas fa-arrow-left"></i> Back to My Bookings
        </a>
    </div>
</c:if>

<c:if test="${not empty booking}">
<div class="boarding-pass-wrapper">
    <div class="boarding-pass">
        <%-- Left side (main info) --%>
        <div class="pass-main">
            <div class="pass-header">
                <div class="brand-section">
                    <h1 class="brand-name">BusTicket</h1>
                    <span class="brand-tagline">Your Journey, Our Priority</span>
                </div>
                <div class="status-section">
                    <span class="status-badge ${fn:toLowerCase(booking.status)}">
                        <c:out value="${booking.status}"/>
                    </span>
                    <span class="boarding-pass-label">BOARDING PASS</span>
                </div>
            </div>

            <div class="route-display">
                <div class="route-city">
                    <span class="city-code"><c:out value="${fn:substring(booking.source,0,3)}"/></span>
                    <span class="city-name"><c:out value="${booking.source}"/></span>
                </div>
                <div class="route-arrow">
                    <i class="fas fa-arrow-right"></i>
                </div>
                <div class="route-city">
                    <span class="city-code"><c:out value="${fn:substring(booking.destination,0,3)}"/></span>
                    <span class="city-name"><c:out value="${booking.destination}"/></span>
                </div>
            </div>

            <div class="time-info">
                <div class="time-block">
                    <span class="time-label">Departure</span>
                    <span class="time-value">
                        <fmt:formatDate value="${booking.departureTime}" pattern="hh:mm a"/>
                    </span>
                </div>
                <div class="time-block">
                    <span class="time-label">Arrival</span>
                    <span class="time-value">
                        <fmt:formatDate value="${booking.arrivalTime}" pattern="hh:mm a"/>
                    </span>
                </div>
                <div class="time-block">
                    <span class="time-label">Date</span>
                    <span class="time-value">
                        <fmt:formatDate value="${booking.travelDate}" pattern="dd MMM yyyy"/>
                    </span>
                </div>
            </div>

            <div class="details-grid">
                <div class="detail-item">
                    <span class="detail-label">Passenger</span>
                    <span class="detail-value"><c:out value="${booking.passengerName}"/></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Bus</span>
                    <span class="detail-value"><c:out value="${booking.busName}"/></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Seats</span>
                    <span class="detail-value">
                        <c:forEach var="seat" items="${seatNumbers}" varStatus="loop">
                            ${seat}${!loop.last ? ', ' : ''}
                        </c:forEach>
                    </span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Fare</span>
                    <span class="detail-value fare-amount">ETB <fmt:formatNumber value="${booking.totalFare}" pattern="#,##0.00"/></span>
                </div>
            </div>

            <div class="notice">
                <i class="fas fa-clock"></i>
                <span>Arrive 30 minutes early with valid ID.</span>
            </div>
        </div>

        <%-- Right side (tear-off strip with barcode) --%>
        <div class="pass-tear">
            <div class="tear-header">
                <span class="tear-brand">BusTicket</span>
                <span class="tear-status">${booking.status}</span>
            </div>
            <div class="tear-route">
                <span><c:out value="${booking.source}"/> → <c:out value="${booking.destination}"/></span>
                <span><fmt:formatDate value="${booking.travelDate}" pattern="dd/MM/yyyy"/></span>
            </div>
            <div class="tear-passenger">
                <c:out value="${booking.passengerName}"/> | Seat(s): 
                <c:forEach var="seat" items="${seatNumbers}" varStatus="loop">
                    ${seat}${!loop.last ? ',' : ''}
                </c:forEach>
            </div>
            <div class="barcode-container">
                <i class="fas fa-barcode"></i>
                <span class="booking-id"><c:out value="${booking.bookingId}"/></span>
            </div>
            <div class="tear-footer">
                <fmt:formatDate value="${booking.departureTime}" pattern="hh:mm a"/>
            </div>
            <div class="perforation"></div>
        </div>
    </div>

    <%-- Action Buttons --%>
    <div class="action-buttons">
        <button class="btn-print" onclick="window.print()">
            <i class="fas fa-print"></i> Print
        </button>
        <a href="${pageContext.request.contextPath}/mybookings" class="btn-back">
            <i class="fas fa-arrow-left"></i> My Bookings
        </a>
        <c:if test="${booking.status == 'CONFIRMED'}">
            <form action="${pageContext.request.contextPath}/cancelBooking" method="post" class="cancel-form">
                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                <button type="submit" class="btn-cancel" onclick="return confirm('Cancel this booking?')">
                    <i class="fas fa-times"></i> Cancel
                </button>
            </form>
        </c:if>
    </div>
</div>
</c:if>

<style>
    .boarding-pass-wrapper {
        max-width: 780px;
        margin: 2.5rem auto;
        padding: 0 1.5rem;
        font-family: 'Inter', sans-serif;
    }

    .boarding-pass {
        display: flex;
        background: #ffffff;
        border-radius: 24px;
        box-shadow: 0 20px 35px -8px rgba(0,0,0,0.15), 0 5px 10px -4px rgba(0,0,0,0.05);
        overflow: hidden;
        border: 1px solid rgba(0,0,0,0.04);
        margin-bottom: 2rem;
    }

    .pass-main {
        flex: 2;
        padding: 2rem 1.8rem;
        background: linear-gradient(145deg, #ffffff 0%, #fafcff 100%);
    }

    .pass-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 2rem;
    }

    .brand-section {
        display: flex;
        flex-direction: column;
    }

    .brand-name {
        font-size: 2rem;
        font-weight: 800;
        color: #1e293b;
        line-height: 1.1;
        letter-spacing: -0.5px;
    }

    .brand-tagline {
        font-size: 0.75rem;
        color: #6b7280;
        letter-spacing: 0.3px;
        margin-top: 2px;
    }

    .status-section {
        display: flex;
        flex-direction: column;
        align-items: flex-end;
        gap: 6px;
    }

    .status-badge {
        display: inline-block;
        padding: 0.25rem 1rem;
        border-radius: 30px;
        font-size: 0.7rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .status-badge.confirmed { background: #d1fae5; color: #065f46; }
    .status-badge.pending { background: #fef3c7; color: #92400e; }
    .status-badge.cancelled { background: #fee2e2; color: #991b1b; }

    .boarding-pass-label {
        font-size: 0.6rem;
        font-weight: 700;
        color: #9ca3af;
        letter-spacing: 2px;
        text-transform: uppercase;
    }

    /* Route display */
    .route-display {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 1.8rem;
    }

    .route-city {
        text-align: center;
        min-width: 100px;
    }

    .city-code {
        display: block;
        font-size: 2rem;
        font-weight: 800;
        color: #1e293b;
        line-height: 1;
    }

    .city-name {
        font-size: 0.85rem;
        color: #64748b;
        font-weight: 500;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .route-arrow {
        color: #2563eb;
        font-size: 1.8rem;
        opacity: 0.7;
    }

    /* Time info */
    .time-info {
        display: flex;
        gap: 2rem;
        margin-bottom: 2rem;
        padding-bottom: 1.5rem;
        border-bottom: 2px dashed #e2e8f0;
    }

    .time-block {
        display: flex;
        flex-direction: column;
    }

    .time-label {
        font-size: 0.7rem;
        text-transform: uppercase;
        color: #6b7280;
        letter-spacing: 0.5px;
        margin-bottom: 4px;
    }

    .time-value {
        font-size: 1.1rem;
        font-weight: 700;
        color: #1e293b;
    }

    /* Details grid */
    .details-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 1.2rem 1.8rem;
        margin-bottom: 1.8rem;
    }

    .detail-item {
        display: flex;
        flex-direction: column;
    }

    .detail-label {
        font-size: 0.7rem;
        text-transform: uppercase;
        color: #6b7280;
        letter-spacing: 0.5px;
        margin-bottom: 2px;
    }

    .detail-value {
        font-size: 1rem;
        font-weight: 600;
        color: #1e293b;
    }

    .fare-amount {
        color: #16a34a;
        font-weight: 700;
    }

    /* Notice */
    .notice {
        background: #f8fafc;
        border-radius: 12px;
        padding: 0.8rem 1.2rem;
        display: flex;
        align-items: center;
        gap: 0.8rem;
        color: #475569;
        font-size: 0.85rem;
        border: 1px solid #e2e8f0;
    }

    .notice i {
        color: #f59e0b;
        font-size: 1rem;
    }

    /* Tear-off strip */
    .pass-tear {
        flex: 1;
        background: #f1f5f9;
        padding: 1.5rem 1.2rem;
        display: flex;
        flex-direction: column;
        position: relative;
        border-left: 2px dashed #cbd5e1;
    }

    .perforation {
        position: absolute;
        left: -8px;
        top: 0;
        bottom: 0;
        width: 14px;
        background: repeating-linear-gradient(
            to bottom,
            transparent,
            transparent 8px,
            #ffffff 8px,
            #ffffff 16px
        );
        border-radius: 0 8px 8px 0;
    }

    .tear-header {
        display: flex;
        justify-content: space-between;
        margin-bottom: 1.2rem;
    }

    .tear-brand {
        font-weight: 700;
        color: #1e293b;
        font-size: 1rem;
    }

    .tear-status {
        font-size: 0.7rem;
        font-weight: 700;
        text-transform: uppercase;
        background: white;
        padding: 0.2rem 0.6rem;
        border-radius: 20px;
    }

    .tear-route {
        display: flex;
        flex-direction: column;
        font-size: 0.9rem;
        font-weight: 600;
        color: #1e293b;
        margin-bottom: 0.8rem;
    }

    .tear-route span:last-child {
        font-size: 0.75rem;
        color: #64748b;
        font-weight: 400;
    }

    .tear-passenger {
        font-size: 0.8rem;
        color: #334155;
        margin-bottom: 1.5rem;
        padding-bottom: 0.8rem;
        border-bottom: 1px solid #cbd5e1;
    }

    .barcode-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        margin: auto 0 1rem;
    }

    .barcode-container i {
        font-size: 3.5rem;
        color: #1e293b;
        margin-bottom: 0.25rem;
    }

    .booking-id {
        font-family: 'Courier New', monospace;
        font-weight: 700;
        font-size: 1rem;
        letter-spacing: 2px;
        color: #0f172a;
    }

    .tear-footer {
        font-size: 1.1rem;
        font-weight: 700;
        color: #1e293b;
        text-align: right;
    }

    /* Action buttons */
    .action-buttons {
        display: flex;
        gap: 0.8rem;
        justify-content: center;
        flex-wrap: wrap;
    }

    .btn-print, .btn-back, .btn-cancel {
        padding: 0.8rem 1.6rem;
        border-radius: 40px;
        font-weight: 600;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        cursor: pointer;
        border: none;
        font-size: 0.9rem;
        transition: all 0.2s;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }

    .btn-print {
        background: #2563eb;
        color: white;
    }

    .btn-print:hover {
        background: #1d4ed8;
        transform: translateY(-1px);
        box-shadow: 0 6px 12px -3px rgba(37,99,235,0.2);
    }

    .btn-back {
        background: white;
        color: #1f2937;
        border: 1px solid #d1d5db;
    }

    .btn-back:hover {
        background: #f9fafb;
    }

    .btn-cancel {
        background: #dc2626;
        color: white;
    }

    .btn-cancel:hover {
        background: #b91c1c;
    }

    .cancel-form {
        display: inline;
    }

    /* Print styles */
    @media print {
        header, footer, .navbar, .action-buttons, .footer {
            display: none !important;
        }
        .boarding-pass {
            box-shadow: none;
            border: 1px solid #000;
        }
        body {
            background: white;
        }
    }

    /* Mobile */
    @media (max-width: 640px) {
        .boarding-pass {
            flex-direction: column;
        }
        .pass-tear {
            border-left: none;
            border-top: 2px dashed #cbd5e1;
        }
        .perforation {
            display: none;
        }
        .route-display {
            flex-wrap: wrap;
            justify-content: center;
            gap: 0.5rem;
        }
        .route-arrow {
            transform: rotate(90deg);
        }
        .time-info {
            flex-wrap: wrap;
            gap: 1rem;
        }
        .details-grid {
            grid-template-columns: 1fr;
        }
    }
</style>

<%@ include file="footer.jsp" %>
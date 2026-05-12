<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Booking - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* CRITICAL LAYOUT FIXES */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #f8fafc; overflow-x: hidden; }
        .admin-layout { display: flex; min-height: 100vh; position: relative; }
        .admin-sidebar { position: fixed !important; left: 0; top: 0; height: 100vh; width: 280px; z-index: 1000; overflow-y: auto; }
        .admin-main {
            flex: 1; margin-left: 280px; padding: 2rem; width: calc(100% - 280px);
            max-width: 100%; background: #f8fafc; transition: margin-left 0.3s ease; overflow-x: auto;
            display: block !important; visibility: visible !important; opacity: 1 !important; min-height: 400px;
        }
        .admin-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; flex-wrap: wrap; gap: 1rem; }
        .admin-header h1 { font-size: 2rem; font-weight: 700; color: #1f2937; display: flex; align-items: center; gap: 0.75rem; }
        .admin-header h1 i { color: #2563eb; }

        /* Detail Card */
        .detail-card { background: white; border-radius: 20px; padding: 1.5rem; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); border: 1px solid #f0f2f5; }
        .card-header { display: flex; justify-content: space-between; align-items: center; padding-bottom: 1.5rem; margin-bottom: 1.5rem; border-bottom: 1px solid #e5e7eb; flex-wrap: wrap; gap: 1rem; }
        .header-left { display: flex; align-items: center; gap: 1.5rem; flex-wrap: wrap; }
        .header-left h2 { font-size: 1.5rem; color: #1f2937; word-break: break-word; }
        .header-left code { background: #f3f4f6; padding: 0.2rem 0.5rem; border-radius: 8px; font-size: 1rem; }
        .header-actions { display: flex; gap: 1rem; flex-wrap: wrap; }
        .detail-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 1.5rem; }
        .detail-section { background: #fafbfc; border-radius: 16px; padding: 1.25rem; border: 1px solid #eef2f6; }
        .detail-section h3 { font-size: 1.1rem; margin-bottom: 1rem; color: #374151; display: flex; align-items: center; gap: 0.5rem; }
        .detail-section h3 i { color: #2563eb; width: 20px; }
        .info-table { width: 100%; table-layout: fixed; }
        .info-table th, .info-table td { padding: 0.5rem 0; vertical-align: top; word-break: break-word; }
        .info-table th { text-align: left; font-weight: 500; color: #6b7280; width: 120px; }
        .info-table td { color: #1f2937; font-weight: 500; }
        .total-fare { font-size: 1.2rem; font-weight: 700; color: #16a34a; }
        .seat-tag { display: inline-block; background: #e0e7ff; color: #1e40af; padding: 0.2rem 0.6rem; border-radius: 20px; font-size: 0.85rem; font-weight: 600; margin-right: 0.3rem; margin-bottom: 0.2rem; }
        .action-footer { margin-top: 2rem; padding-top: 1.5rem; border-top: 1px solid #e5e7eb; }

        /* Status Badge */
        .status-badge { padding: 0.3rem 1rem; border-radius: 30px; font-size: 0.8rem; font-weight: 600; text-transform: uppercase; white-space: nowrap; }
        .status-badge.confirmed { background: #d1fae5; color: #065f46; }
        .status-badge.pending { background: #fef3c7; color: #92400e; }
        .status-badge.cancelled { background: #fee2e2; color: #991b1b; }
        .status-badge.expired { background: #f3f4f6; color: #6b7280; }

        /* Buttons */
        .btn-secondary { display: inline-flex; align-items: center; gap: 0.5rem; padding: 0.7rem 1.5rem; background: white; color: #1f2937; border: 1px solid #d1d5db; border-radius: 40px; font-weight: 600; text-decoration: none; cursor: pointer; transition: all 0.2s; white-space: nowrap; }
        .btn-secondary:hover { background: #f3f4f6; transform: translateY(-2px); }
        .btn-danger { background: #dc2626; color: white; border: none; padding: 0.7rem 1.25rem; border-radius: 10px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 0.5rem; transition: background 0.2s; white-space: nowrap; }
        .btn-danger:hover { background: #b91c1c; }
        .btn-warning { background: #f59e0b; color: white; border: none; padding: 0.7rem 1.25rem; border-radius: 10px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 0.5rem; transition: background 0.2s; white-space: nowrap; }
        .btn-warning:hover { background: #d97706; }

        /* Alerts */
        .alert { padding: 1rem 1.25rem; border-radius: 14px; margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.75rem; }
        .alert-danger { background: #fee2e2; color: #991b1b; }
        .alert-success { background: #d1fae5; color: #065f46; }

        /* Responsive */
        @media (max-width: 992px) {
            .admin-main { margin-left: 0 !important; width: 100% !important; padding: 1.5rem; }
            .admin-sidebar { transform: translateX(-100%); transition: transform 0.3s ease; }
            .admin-sidebar.active { transform: translateX(0); }
        }
        @media (max-width: 768px) {
            .detail-grid { grid-template-columns: 1fr; }
            .card-header { flex-direction: column; align-items: flex-start; }
            .admin-header { flex-direction: column; align-items: flex-start; }
            .btn-secondary, .btn-danger, .btn-warning { width: 100%; justify-content: center; }
        }
    </style>
</head>
<body class="admin-dashboard-body">
<div class="admin-layout">
    <jsp:include page="/views/admin/sidebar.jsp" />

    <main class="admin-main">
        <div class="admin-header">
            <h1><i class="fas fa-ticket-alt"></i> Booking Details</h1>
            <a href="${pageContext.request.contextPath}/admin/bookings" class="btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to Bookings
            </a>
        </div>

        <c:if test="${empty booking}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle"></i> Booking not found. (ID: ${param.id})
            </div>
        </c:if>

        <c:if test="${not empty booking}">
            <%-- Flash Messages --%>
            <c:if test="${not empty sessionScope.success}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> <c:out value="${sessionScope.success}"/>
                    <c:remove var="success" scope="session"/>
                </div>
            </c:if>
            <c:if test="${not empty sessionScope.error}">
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-circle"></i> <c:out value="${sessionScope.error}"/>
                    <c:remove var="error" scope="session"/>
                </div>
            </c:if>

            <div class="detail-card">
                <div class="card-header">
                    <div class="header-left">
                        <h2>Booking <code><c:out value="${booking.bookingId}"/></code></h2>
                        <span class="status-badge ${fn:toLowerCase(booking.status)}">
                            <c:out value="${booking.status}"/>
                        </span>
                    </div>
                    <div class="header-actions">
                        <c:if test="${booking.status == 'CONFIRMED' || booking.status == 'PENDING'}">
                            <button class="btn-danger" onclick="confirmCancel()">
                                <i class="fas fa-ban"></i> Cancel Booking
                            </button>
                        </c:if>
                        <c:if test="${booking.status == 'CONFIRMED' && booking.travelDate < currentDate}">
                            <button class="btn-warning" onclick="markAsExpired()">
                                <i class="fas fa-clock"></i> Mark as Expired
                            </button>
                        </c:if>
                    </div>
                </div>

                <div class="detail-grid">
                    <div class="detail-section">
                        <h3><i class="fas fa-user"></i> Passenger Information</h3>
                        <table class="info-table">
                            <tr><th>Name:</th><td><c:out value="${booking.passengerName}"/></td></tr>
                            <tr><th>Email:</th><td><c:out value="${booking.passengerEmail}"/></td></tr>
                            <tr><th>Phone:</th><td><c:out value="${booking.passengerPhone}"/></td></tr>
                        </table>
                    </div>

                    <div class="detail-section">
                        <h3><i class="fas fa-route"></i> Journey Details</h3>
                        <table class="info-table">
                            <tr><th>Route:</th><td><c:out value="${booking.source}"/> → <c:out value="${booking.destination}"/></td></tr>
                            <tr><th>Travel Date:</th><td><fmt:formatDate value="${booking.travelDate}" pattern="EEEE, MMMM d, yyyy"/></td></tr>
                            <tr><th>Departure:</th><td><fmt:formatDate value="${booking.departureTime}" pattern="hh:mm a"/></td></tr>
                            <tr><th>Arrival:</th><td><fmt:formatDate value="${booking.arrivalTime}" pattern="hh:mm a"/></td></tr>
                        </table>
                    </div>

                    <div class="detail-section">
                        <h3><i class="fas fa-bus"></i> Bus & Seats</h3>
                        <table class="info-table">
                            <tr><th>Bus:</th><td><c:out value="${booking.busName}"/> (${booking.busType})</td></tr>
                            <tr><th>Seats:</th><td>
                                <c:forEach var="seat" items="${seatNumbers}" varStatus="loop">
                                    <span class="seat-tag">${seat}</span><c:if test="${!loop.last}"> </c:if>
                                </c:forEach>
                                (${fn:length(seatNumbers)} seat${fn:length(seatNumbers) != 1 ? 's' : ''})
                            </td></tr>
                        </table>
                    </div>

                    <div class="detail-section">
                        <h3><i class="fas fa-credit-card"></i> Payment Summary</h3>
                        <table class="info-table">
                            <tr><th>Fare per seat:</th><td>ETB <fmt:formatNumber value="${booking.fare}" pattern="#,##0.00"/></td></tr>
                            <tr><th>Total Fare:</th><td class="total-fare">ETB <fmt:formatNumber value="${booking.totalFare}" pattern="#,##0.00"/></td></tr>
                            <tr><th>Booking Date:</th><td><fmt:formatDate value="${booking.bookingDate}" pattern="dd MMM yyyy, hh:mm a"/></td></tr>
                        </table>
                    </div>
                </div>

                <div class="action-footer">
                    <a href="${pageContext.request.contextPath}/admin/bookings" class="btn-secondary">
                        <i class="fas fa-arrow-left"></i> Back
                    </a>
                </div>
            </div>
        </c:if>
    </main>
</div>

<%-- Hidden forms for POST actions --%>
<form id="cancelForm" action="${pageContext.request.contextPath}/admin/bookings" method="post" style="display: none;">
    <input type="hidden" name="action" value="cancel">
    <input type="hidden" name="bookingId" value="<c:out value='${booking.bookingId}'/>">
</form>
<form id="expiredForm" action="${pageContext.request.contextPath}/admin/bookings" method="post" style="display: none;">
    <input type="hidden" name="action" value="updateStatus">
    <input type="hidden" name="newStatus" value="EXPIRED">
    <input type="hidden" name="bookingId" value="<c:out value='${booking.bookingId}'/>">
</form>

<script>
    function confirmCancel() {
        if (confirm('Are you sure you want to cancel this booking? This will release the seats and cannot be undone.')) {
            document.getElementById('cancelForm').submit();
        }
    }
    function markAsExpired() {
        if (confirm('Mark this booking as EXPIRED? This cannot be undone.')) {
            document.getElementById('expiredForm').submit();
        }
    }
</script>
</body>
</html>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="header.jsp" %>

<%-- Redirect if not logged in --%>
<c:if test="${empty sessionScope.user}">
    <c:redirect url="${pageContext.request.contextPath}/login"/>
</c:if>

<%-- Background Wrapper with Gradient + Image --%>
<div class="bookings-background">
    <div class="bookings-container">
        <div class="page-header">
            <h1><i class="fas fa-ticket-alt"></i> My Bookings</h1>
            <p>View and manage all your bus ticket bookings</p>
        </div>

        <%-- Flash messages --%>
        <c:if test="${not empty sessionScope.success}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> ${sessionScope.success}
            </div>
            <c:remove var="success" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.error}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle"></i> ${sessionScope.error}
            </div>
            <c:remove var="error" scope="session"/>
        </c:if>

        <c:choose>
            <c:when test="${empty bookings}">
                <%-- Empty State --%>
                <div class="empty-state">
                    <div class="empty-icon">
                        <i class="fas fa-ticket-alt"></i>
                    </div>
                    <h2>No bookings yet</h2>
                    <p>You haven't made any bookings. Start your journey today!</p>
                    <a href="${pageContext.request.contextPath}/search" class="btn-primary">
                        <i class="fas fa-search"></i> Search Buses
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <%-- Bookings List --%>
                <div class="bookings-list">
                    <c:forEach var="booking" items="${bookings}">
                        <div class="booking-card">
                            <div class="booking-header">
                                <div class="booking-id">
                                    <span class="label">Booking ID:</span>
                                    <span class="value"><c:out value="${booking.bookingId}"/></span>
                                </div>
                                <div class="booking-status">
                                    <span class="status-badge ${fn:toLowerCase(booking.status)}">
                                        <span class="status-dot"></span>
                                        <c:out value="${booking.status}"/>
                                    </span>
                                </div>
                            </div>

                            <div class="booking-body">
                                <div class="route-info">
                                    <div class="route-line">
                                        <span class="city"><c:out value="${booking.source}"/></span>
                                        <span class="arrow"><i class="fas fa-arrow-right"></i></span>
                                        <span class="city"><c:out value="${booking.destination}"/></span>
                                    </div>
                                    <div class="travel-date">
                                        <i class="far fa-calendar-alt"></i>
                                        <fmt:formatDate value="${booking.travelDate}" pattern="EEEE, MMMM d, yyyy"/>
                                    </div>
                                </div>

                                <div class="booking-details">
                                    <div class="detail-item">
                                        <i class="fas fa-bus"></i>
                                        <span><c:out value="${booking.busName}"/> (${booking.busType})</span>
                                    </div>
                                    <div class="detail-item">
                                        <i class="far fa-clock"></i>
                                        <span><fmt:formatDate value="${booking.departureTime}" pattern="hh:mm a"/></span>
                                    </div>
                                    <div class="detail-item">
                                        <i class="fas fa-chair"></i>
                                        <span><c:out value="${fn:length(booking.seatNumbers)}"/> seat(s): 
                                            <c:forEach var="seat" items="${booking.seatNumbers}" varStatus="loop">
                                                ${seat}<c:if test="${!loop.last}">, </c:if>
                                            </c:forEach>
                                        </span>
                                    </div>
                                    <div class="detail-item fare">
                                        <i class="fas fa-tag"></i>
                                        <span>ETB <fmt:formatNumber value="${booking.totalFare}" pattern="#,##0.00"/></span>
                                    </div>
                                </div>

                                <div class="booking-footer">
                                    <div class="booking-date">
                                        <i class="far fa-clock"></i> Booked on: 
                                        <fmt:formatDate value="${booking.bookingDate}" pattern="dd MMM yyyy, hh:mm a"/>
                                    </div>
                                    <div class="booking-actions">
                                        <!-- View button (always visible) -->
                                        <a href="${pageContext.request.contextPath}/viewTicket?bookingId=${booking.bookingId}" 
                                           class="btn-icon" title="View Ticket">
                                            <i class="fas fa-eye"></i> View
                                        </a>
                                        <!-- Pay button for pending bookings -->
                                        <c:if test="${booking.status == 'PENDING'}">
                                            <a href="${pageContext.request.contextPath}/payBooking?bookingId=${booking.bookingId}" 
                                               class="btn-icon btn-pay" title="Pay Now">
                                                <i class="fas fa-credit-card"></i> Pay
                                            </a>
                                            <!-- Cancel button for pending bookings (NEW) -->
                                            <form action="${pageContext.request.contextPath}/cancelBooking" method="post" 
                                                  style="display: inline;" 
                                                  onsubmit="return confirm('Cancel this pending booking?');">
                                                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                                <button type="submit" class="btn-icon btn-danger" title="Cancel Booking">
                                                    <i class="fas fa-times"></i> Cancel
                                                </button>
                                            </form>
                                        </c:if>
                                        <!-- Cancel button only for confirmed bookings -->
                                        <c:if test="${booking.status == 'CONFIRMED'}">
                                            <form action="${pageContext.request.contextPath}/cancelBooking" method="post" 
                                                  style="display: inline;" 
                                                  onsubmit="return confirm('Are you sure you want to cancel this booking?');">
                                                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                                <button type="submit" class="btn-icon btn-danger" title="Cancel Booking">
                                                    <i class="fas fa-times"></i> Cancel
                                                </button>
                                            </form>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <%-- Pagination --%>
                <c:if test="${totalPages > 1}">
                    <div class="pagination">
                        <c:if test="${currentPage > 1}">
                            <a href="?page=${currentPage - 1}" class="page-link">
                                <i class="fas fa-chevron-left"></i> Prev
                            </a>
                        </c:if>
                        
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <a href="?page=${i}" class="page-link ${i == currentPage ? 'active' : ''}">${i}</a>
                        </c:forEach>
                        
                        <c:if test="${currentPage < totalPages}">
                            <a href="?page=${currentPage + 1}" class="page-link">
                                Next <i class="fas fa-chevron-right"></i>
                            </a>
                        </c:if>
                    </div>
                </c:if>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<style>
    /* ===== BACKGROUND WRAPPER ===== */
    .bookings-background {
        min-height: calc(100vh - 140px);
        background: linear-gradient(135deg, rgba(37, 99, 235, 0.2), rgba(255, 255, 255, 0.85)),
                    url('https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=1600&auto=format&fit=crop') center/cover no-repeat;
        background-attachment: fixed;
        padding: 2rem 0;
    }

    .bookings-container { max-width: 1000px; margin: 0 auto; padding: 2rem 1.5rem; }
    
    /* Cards with glass effect for readability */
    .empty-state, .booking-card {
        background: rgba(255, 255, 255, 0.9) !important;
        backdrop-filter: blur(4px);
        border: 1px solid rgba(255, 255, 255, 0.3);
    }

    .page-header { margin-bottom: 2rem; }
    .page-header h1 { font-size: 2rem; color: #1f2937; display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.5rem; }
    .page-header h1 i { color: #2563eb; }
    .page-header p { color: #4b5563; font-weight: 500; }
    
    .alert { padding: 1rem 1.25rem; border-radius: 16px; margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.75rem; }
    .alert-success { background: rgba(209, 250, 229, 0.9); color: #065f46; backdrop-filter: blur(4px); }
    .alert-danger { background: rgba(254, 226, 226, 0.9); color: #991b1b; backdrop-filter: blur(4px); }
    
    .empty-state { text-align: center; padding: 4rem 2rem; border-radius: 24px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
    .empty-icon { font-size: 4rem; color: #d1d5db; margin-bottom: 1.5rem; }
    .empty-state h2 { color: #374151; margin-bottom: 0.5rem; }
    .empty-state p { color: #6b7280; margin-bottom: 1.5rem; }
    
    .btn-primary { display: inline-flex; align-items: center; gap: 0.5rem; background: #2563eb; color: white; padding: 0.75rem 1.75rem; border-radius: 40px; text-decoration: none; font-weight: 600; transition: all 0.2s; }
    .btn-primary:hover { background: #1d4ed8; transform: translateY(-2px); }
    
    .bookings-list { display: flex; flex-direction: column; gap: 1.5rem; }
    .booking-card { border-radius: 20px; padding: 1.5rem; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); transition: transform 0.2s, box-shadow 0.2s; }
    .booking-card:hover { transform: translateY(-2px); box-shadow: 0 12px 20px -8px rgba(0,0,0,0.1); background: rgba(255, 255, 255, 1) !important; }
    
    .booking-header { display: flex; justify-content: space-between; align-items: center; padding-bottom: 1rem; margin-bottom: 1rem; border-bottom: 1px solid rgba(229, 231, 235, 0.6); }
    .booking-id .label { font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.5px; color: #6b7280; margin-right: 0.5rem; }
    .booking-id .value { font-family: 'Courier New', monospace; font-weight: 600; color: #1f2937; }
    
    .status-badge { display: inline-flex; align-items: center; gap: 6px; padding: 0.3rem 1rem; border-radius: 40px; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; }
    .status-badge .status-dot { width: 8px; height: 8px; border-radius: 50%; }
    .status-badge.confirmed { background: #d1fae5; color: #065f46; }
    .status-badge.confirmed .status-dot { background: #10b981; }
    .status-badge.pending { background: #fef3c7; color: #92400e; }
    .status-badge.pending .status-dot { background: #f59e0b; }
    .status-badge.cancelled { background: #fee2e2; color: #991b1b; }
    .status-badge.cancelled .status-dot { background: #ef4444; }
    .status-badge.expired { background: #f3f4f6; color: #6b7280; }
    .status-badge.expired .status-dot { background: #9ca3af; }
    
    .route-info { margin-bottom: 1.25rem; }
    .route-line { display: flex; align-items: center; gap: 1rem; margin-bottom: 0.5rem; }
    .route-line .city { font-size: 1.2rem; font-weight: 600; color: #1f2937; }
    .route-line .arrow { color: #9ca3af; }
    .travel-date { color: #6b7280; font-size: 0.9rem; }
    
    .booking-details { display: grid; grid-template-columns: repeat(2, 1fr); gap: 1rem; padding: 1rem 0; border-top: 1px solid rgba(240, 242, 245, 0.6); border-bottom: 1px solid rgba(240, 242, 245, 0.6); margin-bottom: 1rem; }
    .detail-item { display: flex; align-items: center; gap: 0.75rem; color: #4b5563; }
    .detail-item i { width: 20px; color: #2563eb; }
    .detail-item.fare { color: #16a34a; font-weight: 600; }
    
    .booking-footer { display: flex; justify-content: space-between; align-items: center; }
    .booking-date { color: #6b7280; font-size: 0.85rem; }
    .booking-actions { display: flex; gap: 0.75rem; flex-wrap: wrap; }
    
    .btn-icon { display: inline-flex; align-items: center; gap: 0.5rem; padding: 0.5rem 1rem; background: rgba(243, 244, 246, 0.9); color: #4b5563; border: none; border-radius: 30px; font-size: 0.85rem; font-weight: 500; text-decoration: none; cursor: pointer; transition: all 0.2s; }
    .btn-icon:hover { background: #e5e7eb; color: #1f2937; }
    .btn-danger { background: rgba(254, 226, 226, 0.9); color: #dc2626; }
    .btn-danger:hover { background: #fecaca; color: #b91c1c; }
    
    /* Pay button */
    .btn-pay {
        background: #f59e0b;
        color: white;
        border: 1px solid #f59e0b;
    }
    .btn-pay:hover {
        background: #d97706;
        color: white;
    }
    
    .pagination { display: flex; justify-content: center; gap: 0.5rem; margin-top: 2.5rem; }
    .page-link { display: inline-flex; align-items: center; justify-content: center; min-width: 40px; height: 40px; padding: 0 0.75rem; background: rgba(255, 255, 255, 0.9); backdrop-filter: blur(4px); border: 1px solid #e5e7eb; border-radius: 10px; color: #4b5563; text-decoration: none; font-weight: 500; transition: all 0.2s; }
    .page-link:hover { background: #f3f4f6; border-color: #d1d5db; }
    .page-link.active { background: #2563eb; color: white; border-color: #2563eb; }
    
    @media (max-width: 640px) {
        .booking-details { grid-template-columns: 1fr; gap: 0.75rem; }
        .booking-footer { flex-direction: column; gap: 1rem; align-items: flex-start; }
        .booking-actions { width: 100%; justify-content: flex-end; }
        .route-line .city { font-size: 1rem; }
    }
</style>

<%@ include file="footer.jsp" %>
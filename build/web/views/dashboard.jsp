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
<div class="dashboard-background">
    <div class="dashboard-container">
        <%-- Welcome Header with Glassmorphism --%>
        <div class="welcome-section">
            <div class="welcome-text">
                <h1>Welcome back, <span class="user-name"><c:out value="${sessionScope.user.fullName}"/></span>!</h1>
                <p>Manage your bookings and discover new journeys.</p>
                <c:if test="${not empty sessionScope.lastLogin}">
                    <p class="last-login">
                        <i class="far fa-clock"></i> Last login: 
                        <fmt:formatDate value="${sessionScope.lastLogin}" pattern="dd MMM yyyy 'at' hh:mm a"/>
                    </p>
                </c:if>
            </div>
            <div class="welcome-actions">
                <a href="${pageContext.request.contextPath}/search" class="btn-primary">
                    <i class="fas fa-search"></i> Book New Trip
                </a>
            </div>
        </div>

        <%-- Stats Cards with Soft Gradients (instant values, no animation) --%>
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue"><i class="fas fa-ticket-alt"></i></div>
                <div class="stat-info">
                    <h3>${totalBookings}</h3>
                    <p>Total Bookings</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green"><i class="fas fa-calendar-check"></i></div>
                <div class="stat-info">
                    <h3>${upcomingBookings}</h3>
                    <p>Upcoming Trips</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon amber"><i class="fas fa-clock"></i></div>
                <div class="stat-info">
                    <h3>${pendingBookings}</h3>
                    <p>Pending</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon purple"><i class="fas fa-wallet"></i></div>
                <div class="stat-info">
                    <h3>ETB <fmt:formatNumber value="${totalSpent}" pattern="#,##0.00"/></h3>
                    <p>Total Spent</p>
                </div>
            </div>
        </div>

        <%-- Quick Actions --%>
        <div class="quick-actions">
            <a href="${pageContext.request.contextPath}/search" class="action-card">
                <span class="action-icon"><i class="fas fa-bus"></i></span>
                <span>Find Buses</span>
            </a>
            <a href="${pageContext.request.contextPath}/mybookings" class="action-card">
                <span class="action-icon"><i class="fas fa-history"></i></span>
                <span>Booking History</span>
            </a>
            <a href="${pageContext.request.contextPath}/profile" class="action-card">
                <span class="action-icon"><i class="fas fa-user-cog"></i></span>
                <span>My Profile</span>
            </a>
            <a href="${pageContext.request.contextPath}/support" class="action-card">
                <span class="action-icon"><i class="fas fa-headset"></i></span>
                <span>Support</span>
            </a>
        </div>

        <%-- Recent Bookings Section --%>
        <div class="recent-bookings">
            <div class="section-header">
                <h2><i class="fas fa-clock"></i> Recent Bookings</h2>
                <a href="${pageContext.request.contextPath}/mybookings" class="view-all">
                    View All <i class="fas fa-arrow-right"></i>
                </a>
            </div>

            <c:choose>
                <c:when test="${empty recentUserBookings}">
                    <%-- Beautiful Empty State --%>
                    <div class="empty-state">
                        <div class="empty-icon">
                            <i class="fas fa-ticket-alt"></i>
                        </div>
                        <h3>No bookings yet</h3>
                        <p>You haven't made any bookings. Start your first journey!</p>
                        <a href="${pageContext.request.contextPath}/search" class="btn-primary">Search Buses</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="booking-list">
                        <c:forEach var="booking" items="${recentUserBookings}">
                            <div class="booking-item">
                                <div class="booking-route">
                                    <div class="route-line-display">
                                        <span class="source"><c:out value="${booking.source}"/></span>
                                        <span class="arrow"><i class="fas fa-arrow-right"></i></span>
                                        <span class="destination"><c:out value="${booking.destination}"/></span>
                                    </div>
                                    <div class="booking-meta">
                                        <span class="booking-id">ID: <c:out value="${booking.bookingId}"/></span>
                                        <span class="travel-date">
                                            <i class="far fa-calendar"></i> 
                                            <fmt:formatDate value="${booking.travelDate}" pattern="dd MMM yyyy"/>
                                        </span>
                                    </div>
                                </div>
                                <div class="booking-details">
                                    <div class="seats-info">
                                        <i class="fas fa-chair"></i> 
                                        <c:out value="${fn:length(booking.seatNumbers)}"/> seat(s)
                                    </div>
                                    <div class="fare-info">
                                        ETB <fmt:formatNumber value="${booking.totalFare}" pattern="#,##0.00"/>
                                    </div>
                                </div>
                                <div class="booking-status">
                                    <span class="status-badge ${fn:toLowerCase(booking.status)}">
                                        <span class="status-dot"></span>
                                        <c:out value="${booking.status}"/>
                                    </span>
                                    <div class="booking-actions">
                                        <c:if test="${booking.status == 'CONFIRMED'}">
                                            <a href="${pageContext.request.contextPath}/viewTicket?bookingId=${booking.bookingId}" 
                                               class="btn-icon" title="View Ticket">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <form action="${pageContext.request.contextPath}/cancelBooking" method="post" 
                                                  style="display: inline;" 
                                                  onsubmit="return confirm('Cancel this booking?');">
                                                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                                <button type="submit" class="btn-icon" title="Cancel Booking">
                                                    <i class="fas fa-times"></i>
                                                </button>
                                            </form>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<style>
    /* ===== BACKGROUND WRAPPER WITH GRADIENT + IMAGE ===== */
    .dashboard-background {
        min-height: calc(100vh - 140px);
        background: linear-gradient(135deg, rgba(37, 99, 235, 0.2), rgba(255, 255, 255, 0.85)),
                    url('https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=1600&auto=format&fit=crop') center/cover no-repeat;
        background-attachment: fixed;
        padding: 2rem 0;
    }

    /* ===== DASHBOARD CONTAINER (semi-transparent base) ===== */
    .dashboard-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 2rem;
    }

    /* Make cards slightly more opaque for readability */
    .stat-card, .action-card, .recent-bookings, .booking-item, .empty-state {
        background: rgba(255, 255, 255, 0.9) !important;
        backdrop-filter: blur(4px);
    }

    /* Glassmorphism Welcome Section */
    .welcome-section {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 2.5rem;
        background: linear-gradient(135deg, rgba(37, 99, 235, 0.9), rgba(30, 64, 175, 0.85));
        backdrop-filter: blur(10px);
        padding: 2rem 2.5rem;
        border-radius: 32px;
        color: white;
        border: 1px solid rgba(255, 255, 255, 0.2);
        box-shadow: 0 20px 35px -8px rgba(37, 99, 235, 0.25);
    }

    .welcome-text h1 {
        font-size: 2rem;
        margin-bottom: 0.5rem;
        font-weight: 600;
        text-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }

    .user-name {
        color: #fbbf24;
    }

    .welcome-text p {
        opacity: 0.95;
        font-size: 1.1rem;
    }

    .last-login {
        margin-top: 0.75rem;
        font-size: 0.9rem;
        opacity: 0.8;
    }

    .welcome-actions .btn-primary {
        background: white;
        color: #2563eb;
        padding: 0.75rem 1.75rem;
        border-radius: 40px;
        font-weight: 600;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        transition: all 0.3s ease;
        box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
    }

    .welcome-actions .btn-primary:hover {
        transform: translateY(-3px);
        box-shadow: 0 12px 25px rgba(0, 0, 0, 0.2);
        color: #1e40af;
    }

    /* Stats Cards */
    .stats-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 1.5rem;
        margin-bottom: 2.5rem;
    }

    .stat-card {
        padding: 1.5rem;
        border-radius: 24px;
        display: flex;
        align-items: center;
        gap: 1.25rem;
        box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
        border: 1px solid rgba(240, 242, 245, 0.5);
        transition: all 0.3s ease;
    }

    .stat-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 8px 10px -6px rgba(0,0,0,0.02);
        border-color: #dbeafe;
    }

    .stat-icon {
        width: 60px;
        height: 60px;
        border-radius: 18px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.9rem;
        box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    }

    .stat-icon.blue { background: linear-gradient(135deg, #dbeafe, #bfdbfe); color: #2563eb; }
    .stat-icon.green { background: linear-gradient(135deg, #dcfce7, #bbf7d0); color: #16a34a; }
    .stat-icon.amber { background: linear-gradient(135deg, #fef3c7, #fde68a); color: #f59e0b; }
    .stat-icon.purple { background: linear-gradient(135deg, #f3e8ff, #e9d5ff); color: #7c3aed; }

    .stat-info h3 {
        font-size: 1.9rem;
        font-weight: 700;
        color: #1f2937;
        margin-bottom: 0.25rem;
    }

    .stat-info p {
        color: #6b7280;
        font-size: 0.9rem;
        font-weight: 500;
    }

    /* Quick Actions */
    .quick-actions {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 1rem;
        margin-bottom: 2.5rem;
    }

    .action-card {
        padding: 1.5rem 1rem;
        border-radius: 20px;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 0.75rem;
        text-decoration: none;
        color: #374151;
        border: 1px solid rgba(229, 231, 235, 0.6);
        transition: all 0.3s ease;
    }

    .action-card:hover {
        border-color: #2563eb;
        background: rgba(255, 255, 255, 1) !important;
        transform: translateY(-5px);
        box-shadow: 0 12px 20px -8px rgba(37, 99, 235, 0.15);
    }

    .action-icon {
        width: 52px;
        height: 52px;
        background: linear-gradient(135deg, #eff6ff, #dbeafe);
        border-radius: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.8rem;
        color: #2563eb;
        transition: all 0.3s ease;
    }

    .action-card:hover .action-icon {
        background: #2563eb;
        color: white;
        transform: scale(1.05);
    }

    /* Recent Bookings */
    .recent-bookings {
        border-radius: 28px;
        padding: 1.75rem;
        box-shadow: 0 8px 20px -6px rgba(0,0,0,0.05);
        border: 1px solid rgba(240, 242, 245, 0.5);
    }

    .section-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 1.5rem;
    }

    .section-header h2 {
        font-size: 1.5rem;
        color: #1f2937;
        display: flex;
        align-items: center;
        gap: 0.75rem;
    }

    .section-header h2 i {
        color: #2563eb;
    }

    .view-all {
        color: #2563eb;
        text-decoration: none;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 0.5rem;
        transition: all 0.2s ease;
    }

    .view-all:hover {
        color: #1e40af;
        gap: 0.75rem;
    }

    /* Booking Items */
    .booking-list {
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }

    .booking-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 1.25rem 1.5rem;
        border-radius: 18px;
        border: 1px solid rgba(238, 242, 246, 0.6);
        transition: all 0.3s ease;
    }

    .booking-item:hover {
        background: rgba(255, 255, 255, 1) !important;
        transform: translateY(-4px);
        box-shadow: 0 12px 20px -8px rgba(0,0,0,0.08);
        border-color: #dbeafe;
    }

    .booking-route { flex: 2; }
    .route-line-display {
        display: flex;
        align-items: center;
        gap: 1rem;
        margin-bottom: 0.5rem;
        font-size: 1.05rem;
    }
    .source, .destination { font-weight: 600; color: #1f2937; }
    .arrow { color: #9ca3af; }
    .booking-meta {
        display: flex;
        gap: 1.5rem;
        font-size: 0.85rem;
        color: #6b7280;
    }

    .booking-details {
        flex: 1;
        display: flex;
        justify-content: space-around;
    }
    .seats-info, .fare-info {
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }
    .fare-info { font-weight: 600; color: #16a34a; }

    .booking-status {
        display: flex;
        align-items: center;
        gap: 1.2rem;
    }

    /* Status Badge */
    .status-badge {
        padding: 0.35rem 1rem;
        border-radius: 40px;
        font-size: 0.8rem;
        font-weight: 600;
        text-transform: uppercase;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .status-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        display: inline-block;
    }
    .status-badge.confirmed { background: #d1fae5; color: #065f46; }
    .status-badge.confirmed .status-dot { background: #10b981; }
    .status-badge.pending { background: #fef3c7; color: #92400e; }
    .status-badge.pending .status-dot { background: #f59e0b; }
    .status-badge.cancelled { background: #fee2e2; color: #991b1b; }
    .status-badge.cancelled .status-dot { background: #ef4444; }

    .booking-actions { display: flex; gap: 0.5rem; }
    .btn-icon {
        background: white;
        border: 1px solid #e5e7eb;
        width: 38px;
        height: 38px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #4b5563;
        cursor: pointer;
        transition: all 0.2s ease;
        text-decoration: none;
    }
    .btn-icon:hover { background: #2563eb; color: white; border-color: #2563eb; transform: scale(1.05); }

    /* Empty State */
    .empty-state {
        text-align: center;
        padding: 4rem 2rem;
        border-radius: 24px;
    }
    .empty-icon {
        font-size: 5rem;
        color: #cbd5e1;
        margin-bottom: 1.2rem;
        opacity: 0.7;
    }
    .empty-state h3 { color: #1e293b; margin-bottom: 0.5rem; }
    .empty-state p { color: #64748b; margin-bottom: 1.8rem; }

    /* Mobile Fixes */
    @media (max-width: 768px) {
        .dashboard-container { padding: 0 1rem; }
        .welcome-section { flex-direction: column; text-align: center; gap: 1.5rem; padding: 1.5rem; }
        .stats-grid { grid-template-columns: repeat(2, 1fr); }
        .quick-actions { grid-template-columns: repeat(2, 1fr); }
        .booking-item { flex-direction: column; align-items: stretch; gap: 1rem; }
        .booking-route, .booking-details, .booking-status { width: 100%; }
        .booking-details { justify-content: flex-start; gap: 1.5rem; }
        .booking-status { justify-content: space-between; }
    }

    @media (max-width: 480px) {
        .stats-grid { grid-template-columns: 1fr; }
        .quick-actions { grid-template-columns: 1fr; }
    }
</style>

<%@ include file="footer.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - BusTicket</title>
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
</head>
<body class="admin-dashboard-body">
    <div class="admin-layout">
        <%-- Sidebar Navigation --%>
        <%@ include file="sidebar.jsp" %>
        
        <%-- Main Content --%>
        <main class="admin-main">
            <div class="admin-header">
                <h1><i class="fas fa-tachometer-alt"></i> Dashboard</h1>
                <div class="admin-date">
                    <i class="far fa-calendar-alt"></i> 
                    <span id="currentDate"></span>
                </div>
            </div>

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

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon blue"><i class="fas fa-users"></i></div>
                    <div class="stat-info">
                        <h3><c:out value="${totalUsers != null ? totalUsers : 0}"/></h3>
                        <p>Total Users</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green"><i class="fas fa-bus"></i></div>
                    <div class="stat-info">
                        <h3><c:out value="${totalBuses != null ? totalBuses : 0}"/></h3>
                        <p>Total Buses</p>
                        <small><c:out value="${activeBuses != null ? activeBuses : 0}"/> active</small>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon amber"><i class="fas fa-route"></i></div>
                    <div class="stat-info">
                        <h3><c:out value="${totalRoutes != null ? totalRoutes : 0}"/></h3>
                        <p>Total Routes</p>
                        <small><c:out value="${activeRoutes != null ? activeRoutes : 0}"/> active</small>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon purple"><i class="fas fa-ticket-alt"></i></div>
                    <div class="stat-info">
                        <h3><c:out value="${totalBookings != null ? totalBookings : 0}"/></h3>
                        <p>Total Bookings</p>
                        <small><c:out value="${confirmedBookings != null ? confirmedBookings : 0}"/> confirmed</small>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon teal"><i class="fas fa-dollar-sign"></i></div>
                    <div class="stat-info">
                        <h3>ETB <fmt:formatNumber value="${totalRevenue != null ? totalRevenue : 0}" pattern="#,##0"/></h3>
                        <p>Total Revenue</p>
                    </div>
                </div>
            </div>

            <div class="charts-row">
                <div class="chart-card">
                    <h3><i class="fas fa-chart-line"></i> Daily Revenue (Last 7 Days)</h3>
                    <canvas id="dailyRevenueChart"></canvas>
                    <div id="dailyNoData" class="no-data-message" style="display: none;">
                        <i class="fas fa-chart-bar"></i> No revenue data available
                    </div>
                </div>
                <div class="chart-card">
                    <h3><i class="fas fa-chart-pie"></i> Revenue by Bus</h3>
                    <canvas id="busRevenueChart"></canvas>
                    <div id="busNoData" class="no-data-message" style="display: none;">
                        <i class="fas fa-chart-pie"></i> No bus revenue data available
                    </div>
                </div>
            </div>

            <div class="recent-bookings">
                <div class="section-header">
                    <h3><i class="fas fa-clock"></i> Recent Bookings</h3>
                    <a href="${pageContext.request.contextPath}/admin/bookings" class="view-all">
                        View All <i class="fas fa-arrow-right"></i>
                    </a>
                </div>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Booking ID</th>
                                <th>Passenger</th>
                                <th>Route</th>
                                <th>Travel Date</th>
                                <th>Amount</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty recentBookings}">
                                    <tr><td colspan="7" class="empty-table">No recent bookings found.</td></tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="booking" items="${recentBookings}">
                                        <tr>
                                            <td><code><c:out value="${booking.bookingId}"/></code></td>
                                            <td><c:out value="${booking.passengerName}"/></td>
                                            <td><c:out value="${booking.source}"/> → <c:out value="${booking.destination}"/></td>
                                            <td><fmt:formatDate value="${booking.travelDate}" pattern="dd MMM yyyy"/></td>
                                            <td>ETB <fmt:formatNumber value="${booking.totalFare}" pattern="#,##0.00"/></td>
                                            <td>
                                                <span class="status-badge ${fn:toLowerCase(booking.status)}">
                                                    <c:out value="${booking.status}"/>
                                                </span>
                                            </td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/admin/bookings?view=${booking.bookingId}" 
                                                   class="btn-icon" title="View Details">
                                                    <i class="fas fa-eye"></i>
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

    <%-- Safe JSON data injection --%>
    <script>
        window.dashboardData = {
            dailyLabels: <c:out value="${dailyLabelsJson}" escapeXml="false" default="[]" />,
            dailyRevenue: <c:out value="${dailyRevenueJson}" escapeXml="false" default="[]" />,
            busNames: <c:out value="${busNamesJson}" escapeXml="false" default="[]" />,
            busRevenue: <c:out value="${busRevenueJson}" escapeXml="false" default="[]" />
        };
    </script>

    <script src="${pageContext.request.contextPath}/js/admin-dashboard.js"></script>
</body>
</html>
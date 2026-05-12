<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Bookings - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* ===== CRITICAL LAYOUT FIXES ===== */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Inter', sans-serif;
            background: #f8fafc;
            overflow-x: hidden;
        }
        .admin-layout {
            display: flex;
            min-height: 100vh;
            position: relative;
        }
        .admin-sidebar {
            position: fixed !important;
            left: 0;
            top: 0;
            height: 100vh;
            width: 280px;
            z-index: 1000;
            overflow-y: auto;
        }
        .admin-main {
            flex: 1;
            margin-left: 280px;
            padding: 2rem;
            width: calc(100% - 280px);
            max-width: 100%;
            background: #f8fafc;
            transition: margin-left 0.3s ease;
            overflow-x: auto;
        }
        .admin-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
        }
        .admin-header h1 {
            font-size: 2rem;
            font-weight: 700;
            color: #1f2937;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .admin-header h1 i {
            color: #2563eb;
        }

        /* Filter Bar */
        .filter-bar {
            background: white;
            border-radius: 16px;
            padding: 1rem 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
            border: 1px solid #eef2f6;
        }
        .filter-form {
            display: flex;
            align-items: flex-end;
            gap: 1.5rem;
            flex-wrap: wrap;
        }
        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }
        .filter-group label {
            font-size: 0.8rem;
            font-weight: 600;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .filter-select, .filter-input {
            padding: 0.6rem 1rem;
            border: 1.5px solid #e5e7eb;
            border-radius: 10px;
            font-size: 0.95rem;
            min-width: 180px;
            background: white;
        }
        .search-group .filter-input {
            min-width: 250px;
        }
        .btn-sm {
            padding: 0.6rem 1.25rem;
            font-size: 0.9rem;
        }
        .results-summary {
            margin-bottom: 1rem;
            color: #6b7280;
        }

        /* Table */
        .table-responsive {
            overflow-x: auto;
            background: white;
            border-radius: 20px;
            padding: 0;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            border: 1px solid #f0f2f5;
        }
        .data-table {
            width: 100%;
            border-collapse: collapse;
        }
        .data-table th {
            text-align: left;
            padding: 0.9rem 1rem;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #6b7280;
            border-bottom: 1px solid #e5e7eb;
            background: #f9fafb;
            white-space: nowrap;
        }
        .data-table td {
            padding: 1rem;
            font-size: 0.9rem;
            color: #1f2937;
            border-bottom: 1px solid #f0f2f5;
            white-space: nowrap;
        }
        .data-table tbody tr:hover {
            background: #fafbfc;
        }
        .empty-table {
            text-align: center !important;
            color: #9ca3af !important;
            padding: 3rem !important;
        }

        /* Status Badges */
        .status-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 30px;
            font-size: 0.7rem;
            font-weight: 600;
            text-transform: uppercase;
        }
        .status-badge.confirmed { background: #d1fae5; color: #065f46; }
        .status-badge.pending { background: #fef3c7; color: #92400e; }
        .status-badge.cancelled { background: #fee2e2; color: #991b1b; }
        .status-badge.expired { background: #f3f4f6; color: #6b7280; }

        /* Action Buttons */
        .action-group {
            display: flex;
            gap: 0.5rem;
        }
        .btn-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 36px;
            height: 36px;
            background: #f3f4f6;
            color: #4b5563;
            border: 1px solid #e5e7eb;
            border-radius: 10px;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-icon:hover {
            background: #2563eb;
            color: white;
            border-color: #2563eb;
        }
        .btn-danger {
            background: #fee2e2;
            color: #dc2626;
            border-color: #fecaca;
        }
        .btn-danger:hover {
            background: #dc2626;
            color: white;
        }
        .btn-warning {
            background: #fef3c7;
            color: #92400e;
            border-color: #fde68a;
        }
        .btn-warning:hover {
            background: #f59e0b;
            color: white;
        }

        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            gap: 0.5rem;
            margin-top: 2rem;
        }
        .page-link {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 40px;
            height: 40px;
            padding: 0 0.75rem;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 10px;
            color: #4b5563;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.2s;
        }
        .page-link:hover {
            background: #f3f4f6;
        }
        .page-link.active {
            background: #2563eb;
            color: white;
            border-color: #2563eb;
        }

        /* Alerts */
        .alert {
            padding: 1rem 1.25rem;
            border-radius: 14px;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .alert-success {
            background: #d1fae5;
            color: #065f46;
        }
        .alert-danger {
            background: #fee2e2;
            color: #991b1b;
        }

        /* Responsive */
        @media (max-width: 992px) {
            .admin-main {
                margin-left: 0 !important;
                width: 100% !important;
                padding: 1.5rem;
            }
            .admin-sidebar {
                transform: translateX(-100%);
                transition: transform 0.3s ease;
            }
            .admin-sidebar.active {
                transform: translateX(0);
            }
        }
        @media (max-width: 768px) {
            .filter-form {
                flex-direction: column;
                align-items: stretch;
            }
            .filter-select, .filter-input {
                width: 100%;
            }
            .admin-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 0.75rem;
            }
        }
    </style>
</head>
<body class="admin-dashboard-body">
<div class="admin-layout">
    <%@ include file="sidebar.jsp" %>

    <main class="admin-main">
        <div class="admin-header">
            <h1><i class="fas fa-ticket-alt"></i> Manage Bookings</h1>
        </div>

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

        <%-- Filter & Search Bar --%>
        <div class="filter-bar">
            <form action="${pageContext.request.contextPath}/admin/bookings" method="get" class="filter-form">
                <div class="filter-group">
                    <label for="statusFilter">Status:</label>
                    <select id="statusFilter" name="status" class="filter-select">
                        <option value="">All</option>
                        <option value="CONFIRMED" ${statusFilter == 'CONFIRMED' ? 'selected' : ''}>Confirmed</option>
                        <option value="PENDING" ${statusFilter == 'PENDING' ? 'selected' : ''}>Pending</option>
                        <option value="CANCELLED" ${statusFilter == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                        <option value="EXPIRED" ${statusFilter == 'EXPIRED' ? 'selected' : ''}>Expired</option>
                    </select>
                </div>
                <div class="filter-group search-group">
                    <label for="search">Search:</label>
                    <input type="text" id="search" name="search" placeholder="Booking ID, passenger, email..." 
                           value="<c:out value='${searchTerm}'/>" class="filter-input">
                </div>
                <button type="submit" class="btn-primary btn-sm">
                    <i class="fas fa-filter"></i> Apply
                </button>
                <a href="${pageContext.request.contextPath}/admin/bookings" class="btn-secondary btn-sm">
                    <i class="fas fa-times"></i> Clear
                </a>
            </form>
        </div>

        <%-- Results Summary --%>
        <div class="results-summary">
            <p><i class="fas fa-list"></i> Found <strong>${totalBookings}</strong> booking(s)</p>
        </div>

        <%-- Bookings Table --%>
        <div class="table-responsive">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Booking ID</th>
                        <th>Passenger</th>
                        <th>Route</th>
                        <th>Travel Date</th>
                        <th>Seats</th>
                        <th>Amount</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty bookings}">
                            <tr><td colspan="8" class="empty-table">No bookings found.</td></tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="booking" items="${bookings}">
                                <tr>
                                    <td><code><c:out value="${booking.bookingId}"/></code></td>
                                    <td>
                                        <c:out value="${booking.passengerName}"/><br>
                                        <small><c:out value="${booking.passengerEmail}"/></small>
                                    </td>
                                    <td><c:out value="${booking.source}"/> → <c:out value="${booking.destination}"/></td>
                                    <td><fmt:formatDate value="${booking.travelDate}" pattern="dd MMM yyyy"/></td>
                                    <td><c:out value="${fn:length(booking.seatNumbers)}"/> seat(s)</td>
                                    <td>ETB <fmt:formatNumber value="${booking.totalFare}" pattern="#,##0.00"/></td>
                                    <td>
                                        <span class="status-badge ${fn:toLowerCase(booking.status)}">
                                            <c:out value="${booking.status}"/>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="action-group">
                                            <a href="${pageContext.request.contextPath}/admin/bookings?action=view&id=${booking.bookingId}" 
                                               class="btn-icon" title="View Details">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <c:if test="${booking.status == 'CONFIRMED' || booking.status == 'PENDING'}">
                                                <button class="btn-icon btn-danger" 
                                                        onclick="confirmCancel('${booking.bookingId}')" title="Cancel Booking">
                                                    <i class="fas fa-ban"></i>
                                                </button>
                                            </c:if>
                                            <c:if test="${booking.status == 'CONFIRMED' && booking.travelDate < currentDate}">
                                                <button class="btn-icon btn-warning" 
                                                        onclick="markAsExpired('${booking.bookingId}')" title="Mark as Expired">
                                                    <i class="fas fa-clock"></i>
                                                </button>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <%-- Pagination --%>
        <c:if test="${totalPages > 1}">
            <div class="pagination">
                <c:if test="${currentPage > 1}">
                    <a href="?page=${currentPage - 1}&status=${statusFilter}&search=${searchTerm}" class="page-link">
                        <i class="fas fa-chevron-left"></i>
                    </a>
                </c:if>
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <a href="?page=${i}&status=${statusFilter}&search=${searchTerm}" 
                       class="page-link ${i == currentPage ? 'active' : ''}">${i}</a>
                </c:forEach>
                <c:if test="${currentPage < totalPages}">
                    <a href="?page=${currentPage + 1}&status=${statusFilter}&search=${searchTerm}" class="page-link">
                        <i class="fas fa-chevron-right"></i>
                    </a>
                </c:if>
            </div>
        </c:if>
    </main>
</div>

<%-- Hidden forms for POST actions --%>
<form id="cancelForm" action="${pageContext.request.contextPath}/admin/bookings" method="post" style="display: none;">
    <input type="hidden" name="action" value="cancel">
    <input type="hidden" name="bookingId" id="cancelBookingId">
</form>
<form id="expiredForm" action="${pageContext.request.contextPath}/admin/bookings" method="post" style="display: none;">
    <input type="hidden" name="action" value="updateStatus">
    <input type="hidden" name="newStatus" value="EXPIRED">
    <input type="hidden" name="bookingId" id="expiredBookingId">
</form>

<script>
    function confirmCancel(bookingId) {
        if (confirm('Are you sure you want to cancel this booking? This will release the seats.')) {
            document.getElementById('cancelBookingId').value = bookingId;
            document.getElementById('cancelForm').submit();
        }
    }

    function markAsExpired(bookingId) {
        if (confirm('Mark this booking as EXPIRED?')) {
            document.getElementById('expiredBookingId').value = bookingId;
            document.getElementById('expiredForm').submit();
        }
    }

    // Highlight rows on hover (ES5)
    var rows = document.querySelectorAll('.data-table tbody tr');
    for (var i = 0; i < rows.length; i++) {
        rows[i].addEventListener('mouseenter', function() {
            this.classList.add('hover');
        });
        rows[i].addEventListener('mouseleave', function() {
            this.classList.remove('hover');
        });
    }
</script>
</body>
</html>
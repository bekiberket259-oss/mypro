<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View User - Admin</title>
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
            overflow-x: hidden;
        }
        .admin-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
            flex-wrap: wrap;
            gap: 1rem;
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

        /* Profile Card */
        .detail-card {
            background: white;
            border-radius: 20px;
            padding: 1.5rem;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            border: 1px solid #f0f2f5;
            margin-bottom: 2rem;
        }
        .profile-header {
            display: flex;
            align-items: center;
            gap: 2rem;
            flex-wrap: wrap;
        }
        .profile-avatar {
            font-size: 5rem;
            color: #2563eb;
        }
        .profile-info h2 {
            font-size: 1.8rem;
            color: #1f2937;
            margin-bottom: 0.5rem;
            word-break: break-word;
        }
        .profile-info p {
            color: #6b7280;
            margin-bottom: 0.25rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            flex-wrap: wrap;
        }
        .profile-actions {
            margin-left: auto;
        }

        /* Booking History Section */
        .booking-history-section {
            background: white;
            border-radius: 20px;
            padding: 1.5rem;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            border: 1px solid #f0f2f5;
        }
        .booking-history-section h3 {
            font-size: 1.3rem;
            color: #1f2937;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        /* Table */
        .table-responsive {
            overflow-x: auto;
            border-radius: 16px;
        }
        .data-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 600px;
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

        /* Status Badge */
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

        /* Buttons */
        .btn-secondary {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.7rem 1.5rem;
            background: white;
            color: #1f2937;
            border: 1px solid #d1d5db;
            border-radius: 40px;
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s;
            white-space: nowrap;
        }
        .btn-secondary:hover {
            background: #f3f4f6;
            transform: translateY(-2px);
        }
        .btn-danger {
            background: #dc2626;
            color: white;
            border: none;
            padding: 0.7rem 1.5rem;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: background 0.2s;
            white-space: nowrap;
        }
        .btn-danger:hover {
            background: #b91c1c;
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

        /* Alerts */
        .alert {
            padding: 1rem 1.25rem;
            border-radius: 14px;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .alert-danger {
            background: #fee2e2;
            color: #991b1b;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 3rem;
            color: #9ca3af;
        }
        .empty-state i {
            font-size: 3rem;
            margin-bottom: 1rem;
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
            .profile-header {
                flex-direction: column;
                align-items: flex-start;
                text-align: left;
            }
            .profile-actions {
                margin-left: 0;
                width: 100%;
            }
            .btn-danger {
                width: 100%;
                justify-content: center;
            }
            .admin-header {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>
<body class="admin-dashboard-body">
<div class="admin-layout">
    <%@ include file="sidebar.jsp" %>

    <main class="admin-main">
        <div class="admin-header">
            <h1><i class="fas fa-user"></i> User Details</h1>
            <a href="${pageContext.request.contextPath}/admin/users" class="btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to Users
            </a>
        </div>

        <c:if test="${empty user}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle"></i> User not found.
            </div>
        </c:if>

        <c:if test="${not empty user}">
            <%-- User Profile Card --%>
            <div class="detail-card">
                <div class="profile-header">
                    <div class="profile-avatar">
                        <i class="fas fa-user-circle"></i>
                    </div>
                    <div class="profile-info">
                        <h2><c:out value="${user.fullName}"/></h2>
                        <p class="user-email"><i class="fas fa-envelope"></i> <c:out value="${user.email}"/></p>
                        <p class="user-phone"><i class="fas fa-phone"></i> <c:out value="${user.phone}"/></p>
                        <p class="user-joined"><i class="fas fa-calendar-alt"></i> Joined: <fmt:formatDate value="${user.createdAt}" pattern="MMMM d, yyyy"/></p>
                    </div>
                    <div class="profile-actions">
                        <button class="btn-danger" onclick="confirmDelete()">
                            <i class="fas fa-trash"></i> Delete User
                        </button>
                    </div>
                </div>
            </div>

            <%-- Booking History Section --%>
            <div class="booking-history-section">
                <h3><i class="fas fa-ticket-alt"></i> Booking History</h3>
                
                <c:choose>
                    <c:when test="${empty userBookings}">
                        <div class="empty-state">
                            <i class="fas fa-ticket-alt"></i>
                            <p>No bookings found for this user.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Booking ID</th>
                                        <th>Route</th>
                                        <th>Travel Date</th>
                                        <th>Seats</th>
                                        <th>Amount</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="booking" items="${userBookings}">
                                        <tr>
                                            <td><code><c:out value="${booking.bookingId}"/></code></td>
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
                                                <a href="${pageContext.request.contextPath}/admin/bookings?action=view&id=${booking.bookingId}" 
                                                   class="btn-icon" title="View Booking">
                                                    <i class="fas fa-eye"></i>
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:if>
    </main>
</div>

<%-- Hidden Delete Form --%>
<form id="deleteForm" action="${pageContext.request.contextPath}/admin/users" method="get" style="display: none;">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="id" value="<c:out value='${user.userId}'/>">
</form>

<script>
    function confirmDelete() {
        if (confirm('Are you sure you want to delete this user? This action cannot be undone and will also delete all their bookings.')) {
            document.getElementById('deleteForm').submit();
        }
    }
</script>
</body>
</html>


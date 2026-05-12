<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Routes - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* ===== CRITICAL LAYOUT FIXES ===== */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #f8fafc; overflow-x: hidden; }
        .admin-layout { display: flex; min-height: 100vh; position: relative; }
        .admin-sidebar { position: fixed !important; left: 0; top: 0; height: 100vh; width: 280px; z-index: 1000; overflow-y: auto; }
        .admin-main { flex: 1; margin-left: 280px; padding: 2rem; width: calc(100% - 280px); max-width: 100%; background: #f8fafc; transition: margin-left 0.3s ease; overflow-x: auto; }
        .admin-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; }
        .admin-header h1 { font-size: 2rem; font-weight: 700; color: #1f2937; display: flex; align-items: center; gap: 0.75rem; }
        .admin-header h1 i { color: #2563eb; }
        .table-responsive { overflow-x: auto; background: white; border-radius: 20px; padding: 0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); border: 1px solid #f0f2f5; }
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table th { text-align: left; padding: 0.9rem 1rem; font-size: 0.8rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; color: #6b7280; border-bottom: 1px solid #e5e7eb; background: #f9fafb; white-space: nowrap; }
        .data-table td { padding: 1rem; font-size: 0.9rem; color: #1f2937; border-bottom: 1px solid #f0f2f5; white-space: nowrap; }
        .data-table tbody tr:hover { background: #fafbfc; }
        .empty-table { text-align: center !important; color: #9ca3af !important; padding: 3rem !important; }
        .status-badge { display: inline-block; padding: 0.25rem 0.75rem; border-radius: 30px; font-size: 0.7rem; font-weight: 600; text-transform: uppercase; }
        .status-badge.active { background: #d1fae5; color: #065f46; }
        .status-badge.inactive { background: #fee2e2; color: #991b1b; }
        .action-group { display: flex; gap: 0.5rem; }
        .btn-icon { display: inline-flex; align-items: center; justify-content: center; width: 36px; height: 36px; background: #f3f4f6; color: #4b5563; border: 1px solid #e5e7eb; border-radius: 10px; text-decoration: none; cursor: pointer; transition: all 0.2s; }
        .btn-icon:hover { background: #2563eb; color: white; border-color: #2563eb; }
        .btn-danger { background: #fee2e2; color: #dc2626; border-color: #fecaca; }
        .btn-danger:hover { background: #dc2626; color: white; }
        .pagination { display: flex; justify-content: center; gap: 0.5rem; margin-top: 2rem; }
        .page-link { display: inline-flex; align-items: center; justify-content: center; min-width: 40px; height: 40px; padding: 0 0.75rem; background: white; border: 1px solid #e5e7eb; border-radius: 10px; color: #4b5563; text-decoration: none; font-weight: 500; transition: all 0.2s; }
        .page-link:hover { background: #f3f4f6; }
        .page-link.active { background: #2563eb; color: white; border-color: #2563eb; }
        .alert { padding: 1rem 1.25rem; border-radius: 14px; margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.75rem; }
        .alert-success { background: #d1fae5; color: #065f46; }
        .alert-danger { background: #fee2e2; color: #991b1b; }
        .error-message-block { color: #ef4444; padding: 1rem; background: #fee2e2; border-radius: 12px; margin-bottom: 1.5rem; }
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); backdrop-filter: blur(4px); align-items: center; justify-content: center; z-index: 1000; }
        .modal-content { background: white; border-radius: 24px; padding: 2rem; width: 90%; max-width: 650px; max-height: 90vh; overflow-y: auto; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25); }
        .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
        .modal-header h2 { font-size: 1.5rem; color: #1f2937; }
        .close-btn { background: none; border: none; font-size: 1.8rem; cursor: pointer; color: #6b7280; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
        .form-group { margin-bottom: 1.25rem; }
        .form-group label { display: block; margin-bottom: 0.5rem; font-weight: 500; color: #374151; }
        .form-group input, .form-group select { width: 100%; padding: 0.75rem 1rem; border: 1.5px solid #e5e7eb; border-radius: 12px; font-size: 1rem; background: white; }
        .modal-actions { display: flex; gap: 1rem; justify-content: flex-end; margin-top: 2rem; }
        @media (max-width: 992px) { .admin-main { margin-left: 0 !important; width: 100% !important; padding: 1.5rem; } .admin-sidebar { transform: translateX(-100%); transition: transform 0.3s ease; } .admin-sidebar.active { transform: translateX(0); } }
        @media (max-width: 768px) { .admin-header { flex-direction: column; align-items: flex-start; gap: 0.75rem; } .form-row { grid-template-columns: 1fr; } }
    </style>
</head>
<body class="admin-dashboard-body">
<div class="admin-layout">
    <%@ include file="sidebar.jsp" %>

    <main class="admin-main">
        <div class="admin-header">
            <h1><i class="fas fa-route"></i> Manage Routes</h1>
            <button class="btn-primary" onclick="openAddModal()">
                <i class="fas fa-plus"></i> Add New Route
            </button>
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

        <%-- Additional error display block (safety) --%>
        <c:if test="${not empty error}">
            <div class="error-message-block">
                <i class="fas fa-exclamation-triangle"></i> <c:out value="${error}"/>
            </div>
        </c:if>

        <div class="table-responsive">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Source</th>
                        <th>Destination</th>
                        <th>Travel Date</th>
                        <th>Departure</th>
                        <th>Arrival</th>
                        <th>Fare (ETB)</th>
                        <th>Bus</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty routes}">
                            <tr><td colspan="10" class="empty-table">No routes found.</td></tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="route" items="${routes}">
                                <tr>
                                    <td><c:out value="${route.routeId}"/></td>
                                    <td><c:out value="${route.source}"/></td>
                                    <td><c:out value="${route.destination}"/></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty route.travelDate}">
                                                <fmt:formatDate value="${route.travelDate}" pattern="dd MMM yyyy"/>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge inactive">Not Set</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><fmt:formatDate value="${route.departureTime}" pattern="hh:mm a"/></td>
                                    <td><fmt:formatDate value="${route.arrivalTime}" pattern="hh:mm a"/></td>
                                    <td>ETB <fmt:formatNumber value="${route.fare}" pattern="#,##0.00"/></td>
                                    <td><c:out value="${route.busName}"/> (${route.busNumber})</td>
                                    <td>
                                        <span class="status-badge ${route.active ? 'active' : 'inactive'}">
                                            <c:out value="${route.active ? 'Active' : 'Inactive'}"/>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="action-group">
                                            <button class="btn-icon" onclick="openEditModal(
                                                '${route.routeId}',
                                                '${fn:escapeXml(route.source)}',
                                                '${fn:escapeXml(route.destination)}',
                                                '<fmt:formatDate value="${route.travelDate}" pattern="yyyy-MM-dd"/>',
                                                '<fmt:formatDate value="${route.departureTime}" pattern="HH:mm"/>',
                                                '<fmt:formatDate value="${route.arrivalTime}" pattern="HH:mm"/>',
                                                '${fn:escapeXml(route.duration)}',
                                                ${route.fare},
                                                ${route.distance},
                                                ${route.busId},
                                                ${route.active}
                                            )" title="Edit">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <a href="${pageContext.request.contextPath}/admin/routes?action=delete&id=${route.routeId}"
                                               class="btn-icon btn-danger"
                                               onclick="return confirm('Delete this route?')" title="Delete">
                                                <i class="fas fa-trash"></i>
                                            </a>
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
                    <a href="?page=${currentPage - 1}" class="page-link"><i class="fas fa-chevron-left"></i></a>
                </c:if>
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <a href="?page=${i}" class="page-link ${i == currentPage ? 'active' : ''}">${i}</a>
                </c:forEach>
                <c:if test="${currentPage < totalPages}">
                    <a href="?page=${currentPage + 1}" class="page-link"><i class="fas fa-chevron-right"></i></a>
                </c:if>
            </div>
        </c:if>
    </main>
</div>

<%-- Add/Edit Route Modal --%>
<div id="routeModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2 id="modalTitle">Add New Route</h2>
            <button class="close-btn" onclick="closeModal()">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/admin/routes" method="post" id="routeForm">
            <input type="hidden" name="action" id="formAction" value="save">
            <input type="hidden" name="routeId" id="routeId">
            
            <div class="form-row">
                <div class="form-group">
                    <label for="source">Source City *</label>
                    <input type="text" id="source" name="source" required maxlength="100">
                </div>
                <div class="form-group">
                    <label for="destination">Destination City *</label>
                    <input type="text" id="destination" name="destination" required maxlength="100">
                </div>
            </div>

            <%-- New Travel Date Field --%>
            <div class="form-row">
                <div class="form-group">
                    <label for="travelDate">Travel Date *</label>
                    <input type="date" id="travelDate" name="travelDate" required>
                </div>
                <div class="form-group">
                    <!-- spacer for alignment -->
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="departureTime">Departure Time *</label>
                    <input type="time" id="departureTime" name="departureTime" required>
                </div>
                <div class="form-group">
                    <label for="arrivalTime">Arrival Time *</label>
                    <input type="time" id="arrivalTime" name="arrivalTime" required>
                </div>
            </div>

            <div class="form-group">
                <label for="duration">Duration (e.g., "5h 30m")</label>
                <input type="text" id="duration" name="duration" placeholder="e.g., 5h 30m">
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="fare">Fare (ETB) *</label>
                    <input type="number" step="0.01" id="fare" name="fare" required>
                </div>
                <div class="form-group">
                    <label for="distance">Distance (km)</label>
                    <input type="number" id="distance" name="distance" placeholder="Optional">
                </div>
            </div>

            <div class="form-group">
                <label for="busId">Assign Bus *</label>
                <select id="busId" name="busId" required>
                    <option value="">-- Select Bus --</option>
                    <c:forEach var="bus" items="${buses}">
                        <option value="${bus.busId}">${bus.busName} (${bus.busNumber}) - ${bus.busType}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-group">
                <label>
                    <input type="checkbox" name="isActive" id="isActive" checked> Active
                </label>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">Cancel</button>
                <button type="submit" class="btn-primary">Save Route</button>
            </div>
        </form>
    </div>
</div>

<script>
    var modal = document.getElementById('routeModal');
    
    // Helper to get today's date in yyyy-MM-dd format
    function getTodayStr() {
        var now = new Date();
        var year = now.getFullYear();
        var month = String(now.getMonth() + 1).padStart(2, '0');
        var day = String(now.getDate()).padStart(2, '0');
        return year + '-' + month + '-' + day;
    }
    
    // Helper to get tomorrow's date in yyyy-MM-dd format
    function getTomorrowStr() {
        var tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        var year = tomorrow.getFullYear();
        var month = String(tomorrow.getMonth() + 1).padStart(2, '0');
        var day = String(tomorrow.getDate()).padStart(2, '0');
        return year + '-' + month + '-' + day;
    }
    
    function openAddModal() {
        document.getElementById('modalTitle').textContent = 'Add New Route';
        document.getElementById('formAction').value = 'save';
        document.getElementById('routeId').value = '';
        document.getElementById('source').value = '';
        document.getElementById('destination').value = '';
        document.getElementById('travelDate').value = getTomorrowStr(); // default to tomorrow
        document.getElementById('travelDate').min = getTodayStr();      // cannot select past dates
        document.getElementById('departureTime').value = '';
        document.getElementById('arrivalTime').value = '';
        document.getElementById('duration').value = '';
        document.getElementById('fare').value = '';
        document.getElementById('distance').value = '';
        document.getElementById('busId').value = '';
        document.getElementById('isActive').checked = true;
        modal.style.display = 'flex';
    }
    
    function openEditModal(id, source, destination, travelDate, departureTime, arrivalTime, duration, fare, distance, busId, active) {
        document.getElementById('modalTitle').textContent = 'Edit Route';
        document.getElementById('formAction').value = 'update';
        document.getElementById('routeId').value = id;
        document.getElementById('source').value = source;
        document.getElementById('destination').value = destination;
        document.getElementById('travelDate').value = travelDate;   // yyyy-MM-dd format
        // Do NOT set min on edit – allow existing past dates, but prevent changing to past? 
        // For safety, we can set min to empty or remove it to avoid restriction
        document.getElementById('travelDate').removeAttribute('min');
        document.getElementById('departureTime').value = departureTime.substring(0,5);
        document.getElementById('arrivalTime').value = arrivalTime.substring(0,5);
        document.getElementById('duration').value = duration || '';
        document.getElementById('fare').value = fare;
        document.getElementById('distance').value = distance || '';
        document.getElementById('busId').value = busId;
        document.getElementById('isActive').checked = (active === 'true' || active === true);
        modal.style.display = 'flex';
    }
    
    function closeModal() {
        modal.style.display = 'none';
    }
    
    window.onclick = function(event) {
        if (event.target === modal) {
            closeModal();
        }
    }
    
    // Auto-open modal if redirected with action=add or action=edit (from servlet)
    <c:if test="${not empty param.action && (param.action == 'add' || param.action == 'edit')}">
        <c:choose>
            <c:when test="${param.action == 'edit' && not empty route}">
                openEditModal(
                    '${route.routeId}',
                    '${fn:escapeXml(route.source)}',
                    '${fn:escapeXml(route.destination)}',
                    '<fmt:formatDate value="${route.travelDate}" pattern="yyyy-MM-dd"/>',
                    '<fmt:formatDate value="${route.departureTime}" pattern="HH:mm"/>',
                    '<fmt:formatDate value="${route.arrivalTime}" pattern="HH:mm"/>',
                    '${fn:escapeXml(route.duration)}',
                    ${route.fare},
                    ${route.distance},
                    ${route.busId},
                    ${route.active}
                );
            </c:when>
            <c:otherwise>
                openAddModal();
            </c:otherwise>
        </c:choose>
    </c:if>
</script>
</body>
</html>
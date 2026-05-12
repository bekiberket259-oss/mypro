<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Buses - Admin</title>
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
        .status-badge.active {
            background: #d1fae5;
            color: #065f46;
        }
        .status-badge.inactive {
            background: #fee2e2;
            color: #991b1b;
        }

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

        /* Modal */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            backdrop-filter: blur(4px);
            align-items: center;
            justify-content: center;
            z-index: 1000;
        }
        .modal-content {
            background: white;
            border-radius: 24px;
            padding: 2rem;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
        }
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        .modal-header h2 {
            font-size: 1.5rem;
            color: #1f2937;
        }
        .close-btn {
            background: none;
            border: none;
            font-size: 1.8rem;
            cursor: pointer;
            color: #6b7280;
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
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 0.75rem 1rem;
            border: 1.5px solid #e5e7eb;
            border-radius: 12px;
            font-size: 1rem;
        }
        .modal-actions {
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
            margin-top: 2rem;
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
            <h1><i class="fas fa-bus"></i> Manage Buses</h1>
            <button class="btn-primary" onclick="openAddModal()">
                <i class="fas fa-plus"></i> Add New Bus
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

        <div class="table-responsive">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Bus Number</th>
                        <th>Bus Name</th>
                        <th>Type</th>
                        <th>Total Seats</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty buses}">
                            <tr><td colspan="7" class="empty-table">No buses found.</td></tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="bus" items="${buses}">
                                <tr>
                                    <td><c:out value="${bus.busId}"/></td>
                                    <td><c:out value="${bus.busNumber}"/></td>
                                    <td><c:out value="${bus.busName}"/></td>
                                    <td><c:out value="${bus.busType}"/></td>
                                    <td><c:out value="${bus.totalSeats}"/></td>
                                    <td>
                                        <span class="status-badge ${bus.active ? 'active' : 'inactive'}">
                                            <c:out value="${bus.active ? 'Active' : 'Inactive'}"/>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="action-group">
                                            <button class="btn-icon" onclick="openEditModal('${bus.busId}','${bus.busNumber}','${bus.busName}','${bus.busType}',${bus.totalSeats},${bus.active})" title="Edit">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <a href="${pageContext.request.contextPath}/admin/buses?action=delete&id=${bus.busId}"
                                               class="btn-icon btn-danger"
                                               onclick="return confirm('Delete this bus?')" title="Delete">
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

<%-- Add/Edit Bus Modal --%>
<div id="busModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2 id="modalTitle">Add New Bus</h2>
            <button class="close-btn" onclick="closeModal()">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/admin/buses" method="post" id="busForm">
            <input type="hidden" name="action" id="formAction" value="save">
            <input type="hidden" name="busId" id="busId">
            
            <div class="form-group">
                <label for="busNumber">Bus Number *</label>
                <input type="text" id="busNumber" name="busNumber" required maxlength="20">
            </div>
            <div class="form-group">
                <label for="busName">Bus Name *</label>
                <input type="text" id="busName" name="busName" required maxlength="100">
            </div>
            <div class="form-group">
                <label for="busType">Bus Type *</label>
                <select id="busType" name="busType" required>
                    <option value="Standard">Standard</option>
                    <option value="Sleeper">Sleeper</option>
                    <option value="Volvo">Volvo</option>
                    <option value="AC">AC</option>
                    <option value="Non-AC">Non-AC</option>
                </select>
            </div>
            <div class="form-group">
                <label for="totalSeats">Total Seats *</label>
                <input type="number" id="totalSeats" name="totalSeats" min="1" required>
            </div>
            <div class="form-group">
                <label>
                    <input type="checkbox" name="isActive" id="isActive" checked> Active
                </label>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">Cancel</button>
                <button type="submit" class="btn-primary">Save Bus</button>
            </div>
        </form>
    </div>
</div>

<script>
    var modal = document.getElementById('busModal');
    
    function openAddModal() {
        document.getElementById('modalTitle').textContent = 'Add New Bus';
        document.getElementById('formAction').value = 'save';
        document.getElementById('busId').value = '';
        document.getElementById('busNumber').value = '';
        document.getElementById('busName').value = '';
        document.getElementById('busType').value = 'Standard';
        document.getElementById('totalSeats').value = '40';
        document.getElementById('isActive').checked = true;
        modal.style.display = 'flex';
    }
    
    function openEditModal(id, number, name, type, seats, active) {
        document.getElementById('modalTitle').textContent = 'Edit Bus';
        document.getElementById('formAction').value = 'update';
        document.getElementById('busId').value = id;
        document.getElementById('busNumber').value = number;
        document.getElementById('busName').value = name;
        document.getElementById('busType').value = type;
        document.getElementById('totalSeats').value = seats;
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
    
    <c:if test="${not empty param.action && (param.action == 'add' || param.action == 'edit')}">
        modal.style.display = 'flex';
    </c:if>
</script>
</body>
</html>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users - Admin</title>
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
        .admin-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; }
        .admin-header h1 { font-size: 2rem; font-weight: 700; color: #1f2937; display: flex; align-items: center; gap: 0.75rem; }
        .admin-header h1 i { color: #2563eb; }

        /* Filter Bar */
        .filter-bar {
            background: white;
            border-radius: 16px;
            padding: 1rem 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
            border: 1px solid #eef2f6;
        }
        .filter-form { display: flex; align-items: flex-end; gap: 1.5rem; flex-wrap: wrap; }
        .filter-group { display: flex; flex-direction: column; gap: 0.5rem; }
        .filter-group label {
            font-size: 0.8rem;
            font-weight: 600;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .filter-input {
            padding: 0.6rem 1rem;
            border: 1.5px solid #e5e7eb;
            border-radius: 10px;
            font-size: 0.95rem;
            min-width: 250px;
            background: white;
        }
        .btn-sm { padding: 0.6rem 1.25rem; font-size: 0.9rem; }
        .results-summary { margin-bottom: 1rem; color: #6b7280; }

        /* Table */
        .table-responsive {
            overflow-x: auto;
            background: white;
            border-radius: 20px;
            padding: 0;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            border: 1px solid #f0f2f5;
        }
        .data-table { width: 100%; border-collapse: collapse; }
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
        .data-table tbody tr:hover { background: #fafbfc; }
        .empty-table { text-align: center !important; color: #9ca3af !important; padding: 3rem !important; }

        /* Action Buttons */
        .action-group { display: flex; gap: 0.5rem; }
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
        .btn-icon:hover { background: #2563eb; color: white; border-color: #2563eb; }
        .btn-danger { background: #fee2e2; color: #dc2626; border-color: #fecaca; }
        .btn-danger:hover { background: #dc2626; color: white; }

        /* Pagination */
        .pagination { display: flex; justify-content: center; gap: 0.5rem; margin-top: 2rem; }
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
        .page-link:hover { background: #f3f4f6; }
        .page-link.active { background: #2563eb; color: white; border-color: #2563eb; }

        /* Alerts */
        .alert {
            padding: 1rem 1.25rem;
            border-radius: 14px;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .alert-success { background: #d1fae5; color: #065f46; }
        .alert-danger { background: #fee2e2; color: #991b1b; }

        /* Responsive */
        @media (max-width: 992px) {
            .admin-main { margin-left: 0 !important; width: 100% !important; padding: 1.5rem; }
            .admin-sidebar { transform: translateX(-100%); transition: transform 0.3s ease; }
            .admin-sidebar.active { transform: translateX(0); }
        }
        @media (max-width: 768px) {
            .filter-form { flex-direction: column; align-items: stretch; }
            .filter-input { width: 100%; }
            .admin-header { flex-direction: column; align-items: flex-start; gap: 0.75rem; }
        }
    </style>
</head>
<body class="admin-dashboard-body">
<div class="admin-layout">
    <jsp:include page="/views/admin/sidebar.jsp" />

    <main class="admin-main">
        <div class="admin-header">
            <h1><i class="fas fa-users"></i> Manage Users</h1>
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

        <%-- Search Bar --%>
        <div class="filter-bar">
            <form action="${pageContext.request.contextPath}/admin/users" method="get" class="filter-form">
                <div class="filter-group">
                    <label for="search">Search by Name or Email:</label>
                    <input type="text" id="search" name="search" placeholder="Enter name or email..." 
                           value="<c:out value='${param.search}'/>" class="filter-input">
                </div>
                <button type="submit" class="btn-primary btn-sm">
                    <i class="fas fa-search"></i> Search
                </button>
                <a href="${pageContext.request.contextPath}/admin/users" class="btn-secondary btn-sm">
                    <i class="fas fa-times"></i> Clear
                </a>
            </form>
        </div>

        <%-- Results Summary --%>
        <div class="results-summary">
            <p><i class="fas fa-users"></i> Total Users: <strong>${totalUsers}</strong></p>
        </div>

        <%-- Users Table --%>
        <div class="table-responsive">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Registered On</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty users}">
                            <tr><td colspan="6" class="empty-table">No users found.</td></tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="user" items="${users}">
                                <tr>
                                    <td><c:out value="${user.userId}"/></td>
                                    <td><c:out value="${user.fullName}"/></td>
                                    <td><c:out value="${user.email}"/></td>
                                    <td><c:out value="${user.phone}"/></td>
                                    <td><fmt:formatDate value="${user.createdAt}" pattern="dd MMM yyyy"/></td>
                                    <td>
                                        <div class="action-group">
                                            <a href="${pageContext.request.contextPath}/admin/users?action=view&id=${user.userId}" 
                                               class="btn-icon" title="View Details">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <button class="btn-icon btn-danger" 
                                                    onclick="confirmDelete('${user.userId}', '<c:out value="${user.fullName}"/>')" 
                                                    title="Delete User">
                                                <i class="fas fa-trash"></i>
                                            </button>
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
                    <a href="?page=${currentPage - 1}&search=${param.search}" class="page-link">
                        <i class="fas fa-chevron-left"></i>
                    </a>
                </c:if>
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <a href="?page=${i}&search=${param.search}" 
                       class="page-link ${i == currentPage ? 'active' : ''}">${i}</a>
                </c:forEach>
                <c:if test="${currentPage < totalPages}">
                    <a href="?page=${currentPage + 1}&search=${param.search}" class="page-link">
                        <i class="fas fa-chevron-right"></i>
                    </a>
                </c:if>
            </div>
        </c:if>
    </main>
</div>

<%-- Hidden Delete Form --%>
<form id="deleteForm" action="${pageContext.request.contextPath}/admin/users" method="get" style="display: none;">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="id" id="deleteUserId">
</form>

<script>
    function confirmDelete(userId, userName) {
        if (confirm('Are you sure you want to delete user "' + userName + '"?\nThis action cannot be undone.')) {
            document.getElementById('deleteUserId').value = userId;
            document.getElementById('deleteForm').submit();
        }
    }
</script>
</body>
</html>
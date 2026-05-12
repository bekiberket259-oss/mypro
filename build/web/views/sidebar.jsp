<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- Get current URI for active link detection --%>
<c:set var="currentURI" value="${pageContext.request.servletPath}" />

<aside class="admin-sidebar" id="adminSidebar">
    <div class="sidebar-header">
        <div class="admin-profile">
            <div class="admin-avatar">
                <i class="fas fa-user-shield"></i>
            </div>
            <div class="admin-info">
                <h3>${sessionScope.admin.fullName}</h3>
                <span>Administrator</span>
            </div>
        </div>
    </div>

    <ul class="sidebar-nav">
        <li class="nav-item ${fn:contains(currentURI, 'dashboard') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/dashboard">
                <i class="fas fa-tachometer-alt"></i>
                <span>Dashboard</span>
            </a>
        </li>
        
        <li class="nav-item ${fn:contains(currentURI, 'buses') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/buses">
                <i class="fas fa-bus"></i>
                <span>Manage Buses</span>
            </a>
        </li>
        
        <li class="nav-item ${fn:contains(currentURI, 'routes') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/routes">
                <i class="fas fa-route"></i>
                <span>Manage Routes</span>
            </a>
        </li>
        
        <li class="nav-item ${fn:contains(currentURI, 'bookings') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/bookings">
                <i class="fas fa-ticket-alt"></i>
                <span>Manage Bookings</span>
            </a>
        </li>
        
        <li class="nav-item ${fn:contains(currentURI, 'users') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/users">
                <i class="fas fa-users"></i>
                <span>Manage Users</span>
            </a>
        </li>
        
        <li class="nav-item ${fn:contains(currentURI, 'analytics') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/analytics">
                <i class="fas fa-chart-bar"></i>
                <span>Analytics</span>
            </a>
        </li>
        
        <li class="nav-divider"></li>
        
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/logout">
                <i class="fas fa-sign-out-alt"></i>
                <span>Logout</span>
            </a>
        </li>
    </ul>
    
    <div class="sidebar-footer">
        <p><i class="far fa-clock"></i> <%= new java.text.SimpleDateFormat("MMM dd, yyyy").format(new java.util.Date()) %></p>
    </div>
</aside>

<!-- Mobile Toggle Button (placed here for convenience, can be moved to header) -->
<button class="sidebar-toggle" id="sidebarToggle">
    <i class="fas fa-bars"></i>
</button>
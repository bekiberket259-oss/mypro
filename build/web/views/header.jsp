<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BusTicket - Online Bus Booking</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/favicon.ico">

    <style>
        .navbar {
            background: #1e3a8a;   /* Deep blue */
            padding: 0.8rem 2rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
        }

        /* ALL links inside navbar become white */
        .navbar a {
            color: #ffffff !important;
            text-decoration: none;
            font-weight: 500;
            transition: opacity 0.2s;
        }
        .navbar a:hover {
            opacity: 0.85;
            color: #ffffff !important;
        }

        /* Brand */
        .nav-brand a {
            font-size: 1.5rem;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #ffffff !important;
        }

        /* Menu items */
        .nav-menu {
            list-style: none;
            display: flex;
            align-items: center;
            gap: 1.5rem;
            margin: 0;
            padding: 0;
        }
        .nav-menu li {
            display: flex;
            align-items: center;
        }
        .nav-menu li a {
            color: #ffffff !important;
            font-size: 0.95rem;
            padding: 0.4rem 0.6rem;
            border-radius: 8px;
            display: flex;
            align-items: center;
            gap: 0.4rem;
        }
        .nav-menu li a:hover {
            background: rgba(255,255,255,0.15);
            color: #ffffff !important;
        }

        /* User name pill */
        .nav-user span {
            color: #ffffff !important;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.4rem 0.6rem;
            border-radius: 8px;
            background: rgba(255,255,255,0.1);
        }

        /* Admin link special styling */
        .admin-link {
            background: rgba(255,255,255,0.2) !important;
            border-radius: 8px;
            padding: 0.4rem 0.8rem !important;
            font-weight: 600;
            color: #ffffff !important;
        }

        /* Hamburger toggle */
        .nav-toggle {
            display: none;
            color: #ffffff;
            font-size: 1.5rem;
            cursor: pointer;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .nav-menu {
                flex-direction: column;
                width: 100%;
                display: none;
                gap: 0.75rem;
                padding: 1rem 0;
            }
            .nav-menu.active {
                display: flex;
            }
            .nav-toggle {
                display: block;
            }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-brand">
            <a href="${pageContext.request.contextPath}/">
                <i class="fas fa-bus"></i> BusTicket
            </a>
        </div>
        <div class="nav-toggle" id="navToggle">
            <i class="fas fa-bars"></i>
        </div>
        <ul class="nav-menu" id="navMenu">
            <li><a href="${pageContext.request.contextPath}/"><i class="fas fa-home"></i> Home</a></li>

            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <li><a href="${pageContext.request.contextPath}/explore"><i class="fas fa-map-marked-alt"></i> Explore Ethiopia</a></li>
                    <li><a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                    <li><a href="${pageContext.request.contextPath}/mybookings"><i class="fas fa-ticket-alt"></i> My Bookings</a></li>
                    <li class="nav-user"><span><i class="fas fa-user-circle"></i> <c:out value="${sessionScope.user.fullName}" /></span></li>
                    <li><a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
                </c:when>
                <c:when test="${not empty sessionScope.admin}">
                    <li><a href="${pageContext.request.contextPath}/explore"><i class="fas fa-map-marked-alt"></i> Explore Ethiopia</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fas fa-tachometer-alt"></i> Admin Panel</a></li>
                    <li class="nav-user"><span><i class="fas fa-user-shield"></i> <c:out value="${sessionScope.admin.fullName}" /></span></li>
                    <li><a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
                </c:when>
                <c:otherwise>
                    <li><a href="${pageContext.request.contextPath}/login"><i class="fas fa-sign-in-alt"></i> Login</a></li>
                    <li><a href="${pageContext.request.contextPath}/register"><i class="fas fa-user-plus"></i> Register</a></li>
                </c:otherwise>
            </c:choose>

            <li>
                <a href="${pageContext.request.contextPath}/admin/login" class="admin-link">
                    <i class="fas fa-user-shield"></i> Admin
                </a>
            </li>
        </ul>
    </nav>

    <%-- Flash Messages --%>
    <c:if test="${not empty sessionScope.success}">
        <div class="alert alert-success"><i class="fas fa-check-circle"></i> <c:out value="${sessionScope.success}"/></div>
        <c:remove var="success" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.error}">
        <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> <c:out value="${sessionScope.error}"/></div>
        <c:remove var="error" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.warning}">
        <div class="alert alert-warning"><i class="fas fa-exclamation-triangle"></i> <c:out value="${sessionScope.warning}"/></div>
        <c:remove var="warning" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.info}">
        <div class="alert alert-info"><i class="fas fa-info-circle"></i> <c:out value="${sessionScope.info}"/></div>
        <c:remove var="info" scope="session"/>
    </c:if>

    <main>
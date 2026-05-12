<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - BusTicket</title>
    
    <!-- External CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body class="admin-login-body">
    <div class="auth-container">
        <%-- Decorative Background Blur Circles --%>
        <div class="bg-blur-circle circle-1"></div>
        <div class="bg-blur-circle circle-2"></div>
        <div class="bg-blur-circle circle-3"></div>

        <div class="auth-card">
            <%-- Brand Logo --%>
            <div class="brand-logo">
                <i class="fas fa-user-shield"></i>
                <span>Admin Portal</span>
            </div>

            <div class="auth-header">
                <h1>Admin Login</h1>
                <p>Secure access for authorized personnel only</p>
            </div>

            <%-- Display error message from servlet --%>
            <c:if test="${not empty error}">
                <div class="alert alert-danger shake">
                    <i class="fas fa-exclamation-circle"></i> <c:out value="${error}"/>
                </div>
            </c:if>

            <%-- Display success message (e.g., after logout) --%>
            <c:if test="${not empty success}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> <c:out value="${success}"/>
                </div>
            </c:if>
            
            <%-- Check for logout parameter --%>
            <c:if test="${param.logout == 'true'}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> You have been logged out successfully.
                </div>
            </c:if>

            <%-- Check for session expired parameter --%>
            <c:if test="${param.expired == 'true'}">
                <div class="alert alert-warning">
                    <i class="fas fa-clock"></i> Your session has expired. Please login again.
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/admin/login" method="post" class="auth-form" id="adminLoginForm">
                <div class="form-group">
                    <label for="username">Username</label>
                    <div class="input-group">
                        <i class="fas fa-user-cog"></i>
                        <input type="text" id="username" name="username" 
                               placeholder="Enter admin username" 
                               value="<c:out value='${username}'/>" 
                               required autofocus>
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <div class="input-group">
                        <i class="fas fa-lock"></i>
                        <input type="password" id="password" name="password" 
                               placeholder="••••••••" required>
                        <i class="fas fa-eye toggle-password" id="togglePassword"></i>
                    </div>
                </div>

                <div class="form-options">
                    <label class="checkbox-label">
                        <input type="checkbox" name="remember"> Remember me
                    </label>
                    <!-- Forgot Password link removed -->
                </div>

                <button type="submit" class="btn-auth" id="loginButton">
                    <i class="fas fa-sign-in-alt"></i> <span>Sign In</span>
                </button>
            </form>

            <div class="auth-footer">
                <a href="${pageContext.request.contextPath}/" class="back-home">
                    <i class="fas fa-arrow-left"></i> Back to Home
                </a>
            </div>
        </div>
    </div>

    <!-- External JavaScript -->
    <script src="${pageContext.request.contextPath}/js/admin-login.js"></script>
</body>
</html>
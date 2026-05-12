<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="header.jsp" %>

<c:if test="${empty sessionScope.user}">
    <c:redirect url="${pageContext.request.contextPath}/login"/>
</c:if>

<%-- Full‑page background (same as other pages) --%>
<div class="profile-background">
    <div class="profile-container">
        <div class="profile-card">
            <h1><i class="fas fa-user-circle"></i> My Profile</h1>
            <p>View and update your account information.</p>

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

            <%-- Profile Update Form --%>
            <form action="${pageContext.request.contextPath}/profile" method="post" class="profile-form">
                <input type="hidden" name="action" value="updateProfile">
                
                <div class="form-group">
                    <label for="fullName"><i class="fas fa-user"></i> Full Name</label>
                    <input type="text" id="fullName" name="fullName" 
                           value="<c:out value='${sessionScope.user.fullName}'/>" required>
                </div>
                <div class="form-group">
                    <label for="email"><i class="fas fa-envelope"></i> Email Address</label>
                    <input type="email" id="email" name="email" 
                           value="<c:out value='${sessionScope.user.email}'/>" required>
                </div>
                <div class="form-group">
                    <label for="phone"><i class="fas fa-phone"></i> Phone Number</label>
                    <input type="tel" id="phone" name="phone" 
                           value="<c:out value='${sessionScope.user.phone}'/>" pattern="09[0-9]{8}" required>
                    <small>Ethiopian format: 09xxxxxxxx</small>
                </div>
                <button type="submit" class="btn-primary">
                    <i class="fas fa-save"></i> Update Profile
                </button>
            </form>

            <hr class="divider">

            <%-- Password Change Form --%>
            <h2><i class="fas fa-lock"></i> Change Password</h2>
            <form action="${pageContext.request.contextPath}/profile" method="post" class="profile-form">
                <input type="hidden" name="action" value="changePassword">
                
                <div class="form-group">
                    <label for="currentPassword"><i class="fas fa-key"></i> Current Password</label>
                    <input type="password" id="currentPassword" name="currentPassword" required>
                </div>
                <div class="form-group">
                    <label for="newPassword"><i class="fas fa-lock"></i> New Password</label>
                    <input type="password" id="newPassword" name="newPassword" minlength="6" required>
                    <small>At least 6 characters</small>
                </div>
                <div class="form-group">
                    <label for="confirmPassword"><i class="fas fa-lock"></i> Confirm New Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" minlength="6" required>
                </div>
                <button type="submit" class="btn-primary">
                    <i class="fas fa-key"></i> Change Password
                </button>
            </form>

            <div class="profile-footer">
                <a href="${pageContext.request.contextPath}/dashboard" class="btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to Dashboard
                </a>
            </div>
        </div>
    </div>
</div>

<style>
    /* ===== BACKGROUND with gradient + bus image ===== */
    .profile-background {
        min-height: calc(100vh - 140px);      /* adjust if header/footer height differs */
        background: linear-gradient(135deg, rgba(37, 99, 235, 0.2), rgba(255, 255, 255, 0.85)),
                    url('https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=1600&auto=format&fit=crop') center/cover no-repeat;
        background-attachment: fixed;
        padding: 3rem 0;
    }

    .profile-container {
        max-width: 600px;
        margin: 0 auto;
        padding: 0 1.5rem;
    }

    .profile-card {
        background: white;
        border-radius: 24px;
        padding: 2rem;
        box-shadow: 0 10px 30px rgba(0,0,0,0.08);
        border: 1px solid #f0f2f5;
    }
    .profile-card h1 {
        font-size: 2rem;
        color: #1f2937;
        margin-bottom: 0.5rem;
        display: flex;
        align-items: center;
        gap: 0.75rem;
    }
    .profile-card h1 i {
        color: #2563eb;
    }
    .profile-card h2 {
        font-size: 1.5rem;
        color: #1f2937;
        margin: 1.5rem 0 1rem;
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }
    .profile-card p {
        color: #6b7280;
        margin-bottom: 1.5rem;
    }
    .alert {
        padding: 1rem;
        border-radius: 12px;
        margin-bottom: 1.5rem;
        display: flex;
        align-items: center;
        gap: 0.75rem;
    }
    .alert-success { background: #d1fae5; color: #065f46; }
    .alert-danger { background: #fee2e2; color: #991b1b; }
    .form-group {
        margin-bottom: 1.5rem;
    }
    .form-group label {
        display: block;
        margin-bottom: 0.5rem;
        font-weight: 500;
        color: #374151;
    }
    .form-group input {
        width: 100%;
        padding: 0.75rem 1rem;
        border: 1.5px solid #e5e7eb;
        border-radius: 12px;
        font-size: 1rem;
        transition: border-color 0.2s;
    }
    .form-group input:focus {
        outline: none;
        border-color: #2563eb;
        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
    }
    .form-group small {
        display: block;
        margin-top: 0.25rem;
        color: #6b7280;
        font-size: 0.8rem;
    }
    .btn-primary {
        background: #2563eb;
        color: white;
        border: none;
        padding: 0.75rem 1.5rem;
        border-radius: 12px;
        font-weight: 600;
        font-size: 1rem;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        transition: background 0.2s;
    }
    .btn-primary:hover { background: #1d4ed8; }
    .btn-secondary {
        background: white;
        color: #1f2937;
        border: 1px solid #d1d5db;
        padding: 0.75rem 1.5rem;
        border-radius: 12px;
        font-weight: 600;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        transition: background 0.2s;
    }
    .btn-secondary:hover { background: #f3f4f6; }
    .divider {
        margin: 2rem 0;
        border: none;
        border-top: 1px solid #e5e7eb;
    }
    .profile-footer {
        margin-top: 2rem;
    }
    @media (max-width: 480px) {
        .profile-card { padding: 1.5rem; }
        .profile-background { padding: 2rem 0; }
    }
</style>

<%@ include file="footer.jsp" %>
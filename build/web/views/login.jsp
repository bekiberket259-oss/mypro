<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="header.jsp" %>

<div class="auth-container">
    <%-- Decorative Background Blur Circles --%>
    <div class="bg-blur-circle circle-1"></div>
    <div class="bg-blur-circle circle-2"></div>
    <div class="bg-blur-circle circle-3"></div>

    <div class="auth-card">
        <%-- Brand Logo --%>
        <div class="brand-logo">
            <i class="fas fa-bus"></i>
            <span>BusTicket</span>
        </div>

        <div class="auth-header">
            <h1>Welcome Back</h1>
            <p>Sign in to your account to continue</p>
        </div>

        <%-- Display error message from servlet --%>
        <c:if test="${not empty error}">
            <div class="alert alert-danger shake">
                <i class="fas fa-exclamation-circle"></i> <c:out value="${error}"/>
            </div>
        </c:if>

        <%-- Display success message (e.g., after registration) --%>
        <c:if test="${not empty success}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <c:out value="${success}"/>
            </div>
        </c:if>
        
        <%-- Check for registration success parameter --%>
        <c:if test="${param.registered == 'true'}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> Registration successful! Please login.
            </div>
        </c:if>
        
        <%-- Check for logout parameter --%>
        <c:if test="${param.logout == 'true'}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> You have been logged out successfully.
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/login" method="post" class="auth-form" id="loginForm">
            <div class="form-group">
                <label for="email">Email Address</label>
                <div class="input-group">
                    <i class="fas fa-envelope"></i>
                    <input type="email" id="email" name="email" 
                           placeholder="you@example.com" 
                           value="<c:out value='${email}'/>" 
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
            <p>Don't have an account? 
                <a href="${pageContext.request.contextPath}/register">Create one</a>
            </p>
            <a href="${pageContext.request.contextPath}/" class="back-home">
                <i class="fas fa-arrow-left"></i> Back to Home
            </a>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Auto-focus email input
        var emailInput = document.getElementById('email');
        if (emailInput) emailInput.focus();
        
        // Show/Hide Password Toggle
        var togglePassword = document.getElementById('togglePassword');
        var passwordInput = document.getElementById('password');
        if (togglePassword && passwordInput) {
            togglePassword.addEventListener('click', function() {
                var type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
                passwordInput.setAttribute('type', type);
                this.classList.toggle('fa-eye');
                this.classList.toggle('fa-eye-slash');
            });
        }
        
        // Loading state on form submit
        var form = document.getElementById('loginForm');
        var btn = document.getElementById('loginButton');
        var btnSpan = btn.querySelector('span');
        if (form && btn) {
            form.addEventListener('submit', function() {
                btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> <span>Signing in...</span>';
                btn.disabled = true;
            });
        }
    });
</script>

<style>
    /* Auth Container with Premium Background */
    .auth-container {
        min-height: calc(100vh - 140px);
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 2rem 1.5rem;
        position: relative;
        overflow: hidden;
        background: linear-gradient(135deg, rgba(37, 99, 235, 0.2), rgba(255, 255, 255, 0.85)),
                    url('https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=1600&auto=format&fit=crop') center/cover no-repeat;
    }

    /* Decorative Blur Circles */
    .bg-blur-circle {
        position: absolute;
        border-radius: 50%;
        background: rgba(37, 99, 235, 0.12);
        filter: blur(80px);
        z-index: 0;
    }

    .circle-1 {
        width: 400px;
        height: 400px;
        top: -100px;
        left: -100px;
    }

    .circle-2 {
        width: 350px;
        height: 350px;
        bottom: -80px;
        right: -80px;
        background: rgba(16, 185, 129, 0.1);
    }

    .circle-3 {
        width: 250px;
        height: 250px;
        top: 40%;
        right: 15%;
        background: rgba(245, 158, 11, 0.08);
    }

    /* Auth Card with Hover Lift */
    .auth-card {
        max-width: 440px;
        width: 100%;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(12px);
        border-radius: 32px;
        padding: 2.5rem 2.2rem;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.15);
        border: 1px solid rgba(255, 255, 255, 0.3);
        position: relative;
        z-index: 10;
        transition: transform 0.25s ease, box-shadow 0.25s ease;
        animation: fadeInUp 0.6s ease;
    }

    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .auth-card:hover {
        transform: translateY(-6px);
        box-shadow: 0 35px 60px -15px rgba(0, 0, 0, 0.2);
    }

    /* Brand Logo */
    .brand-logo {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 0.5rem;
        margin-bottom: 1rem;
        font-size: 1.8rem;
        font-weight: 700;
        color: #2563eb;
    }

    .brand-logo i {
        font-size: 2rem;
    }

    .auth-header {
        text-align: center;
        margin-bottom: 2rem;
    }

    .auth-header h1 {
        font-size: 1.8rem;
        font-weight: 700;
        color: #1f2937;
        margin-bottom: 0.5rem;
    }

    .auth-header p {
        color: #6b7280;
        font-size: 0.95rem;
    }

    /* Alerts with Shake Animation on Error */
    .alert {
        padding: 0.75rem 1rem;
        border-radius: 12px;
        margin-bottom: 1.5rem;
        display: flex;
        align-items: center;
        gap: 0.5rem;
        font-size: 0.9rem;
        backdrop-filter: blur(4px);
    }

    .alert-danger {
        background: rgba(254, 226, 226, 0.9);
        color: #991b1b;
        border-left: 4px solid #ef4444;
    }

    .alert-danger.shake {
        animation: shake 0.4s ease;
    }

    @keyframes shake {
        0%, 100% { transform: translateX(0); }
        20% { transform: translateX(-6px); }
        40% { transform: translateX(6px); }
        60% { transform: translateX(-3px); }
        80% { transform: translateX(3px); }
    }

    .alert-success {
        background: rgba(209, 250, 229, 0.9);
        color: #065f46;
        border-left: 4px solid #10b981;
    }

    /* Form */
    .auth-form .form-group {
        margin-bottom: 1.25rem;
    }

    .auth-form label {
        display: block;
        margin-bottom: 0.5rem;
        font-weight: 500;
        color: #374151;
        font-size: 0.9rem;
    }

    /* Input Group with Icon Inside */
    .input-group {
        position: relative;
    }

    .input-group i {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #9ca3af;
        font-size: 1rem;
        transition: color 0.2s;
        z-index: 2;
    }

    .input-group .toggle-password {
        left: auto;
        right: 14px;
        cursor: pointer;
        z-index: 3;
    }

    .input-group .toggle-password:hover {
        color: #2563eb;
    }

    .input-group input {
        width: 100%;
        padding: 0.9rem 2.5rem;
        border: 1.5px solid #e5e7eb;
        border-radius: 16px;
        font-size: 1rem;
        background: rgba(255, 255, 255, 0.8);
        transition: border-color 0.2s, box-shadow 0.2s, transform 0.2s, background 0.2s;
    }

    .input-group input:focus {
        outline: none;
        border-color: #2563eb;
        box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
        background: white;
        transform: scale(1.01);
    }

    .input-group input:focus ~ i {
        color: #2563eb;
    }

    .form-options {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 1.8rem;
        font-size: 0.9rem;
    }

    .checkbox-label {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        color: #4b5563;
        cursor: pointer;
    }

    .checkbox-label input {
        width: auto;
        accent-color: #2563eb;
    }

    .forgot-link {
        color: #2563eb;
        text-decoration: none;
        font-weight: 500;
        transition: color 0.2s;
    }

    .forgot-link:hover {
        text-decoration: underline;
    }

    /* Login Button */
    .btn-auth {
        width: 100%;
        padding: 0.95rem;
        background: #2563eb;
        color: white;
        border: none;
        border-radius: 16px;
        font-weight: 600;
        font-size: 1rem;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 0.5rem;
        cursor: pointer;
        transition: all 0.25s ease;
        box-shadow: 0 10px 20px -5px rgba(37, 99, 235, 0.3);
        position: relative;
        overflow: hidden;
    }

    .btn-auth:hover {
        background: #1d4ed8;
        transform: translateY(-2px);
        box-shadow: 0 15px 25px -6px rgba(37, 99, 235, 0.4);
        letter-spacing: 0.5px;
    }

    .btn-auth:active {
        transform: scale(0.98);
    }

    .btn-auth:disabled {
        opacity: 0.8;
        cursor: not-allowed;
        transform: none;
    }

    .auth-footer {
        margin-top: 2rem;
        text-align: center;
        color: #6b7280;
    }

    .auth-footer a {
        color: #2563eb;
        text-decoration: none;
        font-weight: 600;
    }

    .auth-footer a:hover {
        text-decoration: underline;
    }

    .back-home {
        display: inline-block;
        margin-top: 1rem;
        font-size: 0.9rem;
        color: #6b7280 !important;
        font-weight: 400 !important;
        transition: color 0.2s;
    }

    .back-home i {
        margin-right: 0.25rem;
    }

    .back-home:hover {
        color: #2563eb !important;
    }

    /* Mobile Optimization */
    @media (max-width: 480px) {
        .auth-container {
            padding: 1rem;
        }
        .auth-card {
            padding: 2rem 1.5rem;
            border-radius: 24px;
        }
        .auth-header h1 {
            font-size: 1.6rem;
        }
        .brand-logo {
            font-size: 1.5rem;
        }
        .btn-auth {
            font-size: 0.95rem;
        }
        .circle-1, .circle-2, .circle-3 {
            width: 200px;
            height: 200px;
        }
    }
</style>

<%@ include file="footer.jsp" %>

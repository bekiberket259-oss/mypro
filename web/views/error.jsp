<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="header.jsp" %>

<%-- Determine error severity class based on error code --%>
<c:choose>
    <c:when test="${errorCode == '404'}">
        <c:set var="severityClass" value="warning"/>
        <c:set var="errorTitle" value="Page Not Found"/>
        <c:set var="defaultMessage" value="The page you are looking for doesn't exist or has been moved."/>
    </c:when>
    <c:when test="${errorCode == '403'}">
        <c:set var="severityClass" value="warning"/>
        <c:set var="errorTitle" value="Access Denied"/>
        <c:set var="defaultMessage" value="You don't have permission to access this resource."/>
    </c:when>
    <c:when test="${errorCode == '500'}">
        <c:set var="severityClass" value="error"/>
        <c:set var="errorTitle" value="Server Error"/>
        <c:set var="defaultMessage" value="We're experiencing technical difficulties. Please try again later."/>
    </c:when>
    <c:when test="${errorCode == '503'}">
        <c:set var="severityClass" value="error"/>
        <c:set var="errorTitle" value="Service Unavailable"/>
        <c:set var="defaultMessage" value="The service is temporarily unavailable. Please check back soon."/>
    </c:when>
    <c:otherwise>
        <c:set var="severityClass" value="error"/>
        <c:set var="errorTitle" value="Oops! Something went wrong"/>
        <c:set var="defaultMessage" value="An unexpected error occurred. Please try again later."/>
    </c:otherwise>
</c:choose>

<div class="error-container">
    <div class="error-card ${severityClass}">
        <div class="error-icon">
            <c:choose>
                <c:when test="${severityClass == 'warning'}">
                    <i class="fas fa-exclamation-circle"></i>
                </c:when>
                <c:otherwise>
                    <i class="fas fa-times-circle"></i>
                </c:otherwise>
            </c:choose>
        </div>
        
        <h1><c:out value="${errorTitle}"/></h1>
        
        <c:choose>
            <c:when test="${not empty errorMessage}">
                <p class="error-message"><c:out value="${errorMessage}"/></p>
            </c:when>
            <c:when test="${not empty param.message}">
                <p class="error-message"><c:out value="${param.message}"/></p>
            </c:when>
            <c:otherwise>
                <p class="error-message"><c:out value="${defaultMessage}"/></p>
            </c:otherwise>
        </c:choose>
        
        <c:if test="${not empty errorCode}">
            <div class="error-code">Error Code: <c:out value="${errorCode}"/></div>
        </c:if>
        
        <%-- Request Tracking ID (for production debugging) --%>
        <c:if test="${not empty requestId}">
            <div class="request-id">
                <i class="fas fa-fingerprint"></i> Request ID: <c:out value="${requestId}"/>
            </div>
        </c:if>
        
        <div class="error-actions">
            <a href="${pageContext.request.contextPath}/" class="btn-primary">
                <i class="fas fa-home"></i> Go Home
            </a>
            
            <%-- Smart back button: goes back only if history length > 1, else to dashboard --%>
            <a href="javascript:void(0)" 
               onclick="if(window.history.length > 1) { window.history.back(); } else { location.href='${pageContext.request.contextPath}/dashboard'; }" 
               class="btn-secondary">
                <i class="fas fa-arrow-left"></i> Go Back
            </a>
            
            <button onclick="location.reload()" class="btn-outline">
                <i class="fas fa-sync-alt"></i> Try Again
            </button>
            
            <a href="${pageContext.request.contextPath}/contact" class="btn-outline">
                <i class="fas fa-headset"></i> Support
            </a>
        </div>
    </div>
</div>

<style>
    /* ===== ERROR PAGE STYLES (All colors hardcoded) ===== */
    .error-container {
        min-height: 70vh;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 2rem 1.5rem;
        background: #f8fafc;
    }

    .error-card {
        max-width: 550px;
        width: 100%;
        background: white;
        border-radius: 32px;
        padding: 3rem 2.5rem;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.1);
        text-align: center;
        border: 1px solid #f0f2f5;
        animation: fadeInUp 0.5s ease;
        border-top: 6px solid #ef4444; /* default error color */
    }

    .error-card.warning {
        border-top-color: #f59e0b;
    }

    .error-card.error {
        border-top-color: #ef4444;
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

    .error-icon {
        font-size: 5rem;
        margin-bottom: 1.5rem;
        animation: pulse 2s infinite;
    }

    .error-card.warning .error-icon {
        color: #f59e0b;
    }

    .error-card.error .error-icon {
        color: #ef4444;
    }

    @keyframes pulse {
        0% { transform: scale(1); }
        50% { transform: scale(1.05); }
        100% { transform: scale(1); }
    }

    .error-card h1 {
        font-size: 2rem;
        font-weight: 700;
        color: #1f2937;
        margin-bottom: 1rem;
    }

    .error-message {
        color: #6b7280;
        font-size: 1.1rem;
        margin-bottom: 1rem;
        line-height: 1.6;
    }

    .error-code {
        background: #f3f4f6;
        display: inline-block;
        padding: 0.3rem 1rem;
        border-radius: 30px;
        font-family: 'Courier New', monospace;
        font-size: 0.9rem;
        color: #4b5563;
        margin-bottom: 0.5rem;
    }

    .request-id {
        font-size: 0.8rem;
        color: #9ca3af;
        margin-bottom: 1.5rem;
        font-family: 'Courier New', monospace;
    }

    .request-id i {
        margin-right: 0.25rem;
    }

    .error-actions {
        display: flex;
        gap: 0.75rem;
        justify-content: center;
        flex-wrap: wrap;
    }

    .btn-primary,
    .btn-secondary,
    .btn-outline {
        padding: 0.75rem 1.5rem;
        border-radius: 40px;
        font-weight: 600;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        transition: all 0.2s;
        cursor: pointer;
        border: none;
        font-size: 1rem;
    }

    .btn-primary {
        background: #2563eb;
        color: white;
        box-shadow: 0 8px 16px -4px rgba(37, 99, 235, 0.25);
    }

    .btn-primary:hover {
        background: #1d4ed8;
        transform: translateY(-2px);
        box-shadow: 0 12px 20px -6px rgba(37, 99, 235, 0.35);
    }

    .btn-secondary {
        background: white;
        color: #1f2937;
        border: 1px solid #d1d5db;
    }

    .btn-secondary:hover {
        background: #f3f4f6;
        transform: translateY(-2px);
    }

    .btn-outline {
        background: transparent;
        color: #2563eb;
        border: 1px solid #2563eb;
    }

    .btn-outline:hover {
        background: #eff6ff;
        transform: translateY(-2px);
    }

    @media (max-width: 480px) {
        .error-card {
            padding: 2rem 1.5rem;
        }
        .error-card h1 {
            font-size: 1.6rem;
        }
        .error-actions {
            flex-direction: column;
        }
        .btn-primary,
        .btn-secondary,
        .btn-outline {
            justify-content: center;
        }
    }
</style>

<%@ include file="footer.jsp" %>
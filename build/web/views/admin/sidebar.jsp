<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="currentURI" value="${pageContext.request.servletPath}" />

<aside class="admin-sidebar" id="adminSidebar">
    <div class="sidebar-header">
        <div class="admin-profile">
            <div class="admin-avatar">
                <i class="fas fa-user-shield"></i>
            </div>
            <div class="admin-info">
                <h3><c:out value="${sessionScope.admin.fullName}"/></h3>
                <span class="admin-role">Administrator</span>
                <span class="admin-status"><span class="status-dot"></span> Online</span>
            </div>
        </div>
    </div>

    <ul class="sidebar-nav">
        <li class="nav-title">MAIN</li>
        
        <li class="nav-item ${fn:contains(currentURI, 'dashboard') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/dashboard">
                <i class="fas fa-tachometer-alt"></i>
                <span>Dashboard</span>
            </a>
        </li>
        
        <li class="nav-title">MANAGEMENT</li>
        
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
                <c:if test="${not empty pendingBookingsCount}">
                    <span class="badge">${pendingBookingsCount}</span>
                </c:if>
            </a>
        </li>
        
        <li class="nav-item ${fn:contains(currentURI, 'users') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/users">
                <i class="fas fa-users"></i>
                <span>Manage Users</span>
            </a>
        </li>
        
        <li class="nav-title">INSIGHTS</li>
        
        <li class="nav-item ${fn:contains(currentURI, 'analytics') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/analytics">
                <i class="fas fa-chart-bar"></i>
                <span>Analytics</span>
            </a>
        </li>
        
        <li class="nav-item ${fn:contains(currentURI, 'map') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/map">
                <i class="fas fa-map-marked-alt"></i>
                <span>Route Map</span>
            </a>
        </li>

        <li class="nav-divider"></li>

        <li class="nav-title">COMMUNICATION</li>

        <!-- NOTIFICATION / MESSAGES ITEM -->
        <li class="nav-item ${fn:contains(currentURI, 'messages') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/messages" id="messagesLink">
                <i class="fas fa-bell"></i>
                <span>Messages</span>
                <span id="notif-badge" class="badge" style="display: none;">0</span>
            </a>
        </li>
        
        <li class="nav-divider"></li>
        
        <li class="nav-item logout-item">
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

<button class="sidebar-toggle" id="sidebarToggle">
    <i class="fas fa-bars"></i>
</button>

<style>
    /* ===== PREMIUM SIDEBAR STYLES ===== */
    .admin-sidebar {
        width: 280px;
        background: rgba(15, 23, 42, 0.95);
        backdrop-filter: blur(12px);
        color: #f3f4f6;
        height: 100vh;
        position: fixed;
        left: 0;
        top: 0;
        display: flex;
        flex-direction: column;
        transition: width 0.3s ease;
        z-index: 1000;
        overflow-y: auto;
        border-right: 1px solid rgba(255, 255, 255, 0.1);
        box-shadow: 4px 0 20px rgba(0, 0, 0, 0.1);
    }

    /* Collapsed state */
    .admin-sidebar.collapsed {
        width: 80px;
    }
    .admin-sidebar.collapsed span:not(.badge),
    .admin-sidebar.collapsed .admin-info,
    .admin-sidebar.collapsed .nav-title,
    .admin-sidebar.collapsed .sidebar-footer p {
        display: none;
    }
    .admin-sidebar.collapsed .nav-item a {
        justify-content: center;
        padding: 0.75rem;
    }
    .admin-sidebar.collapsed .nav-item i {
        margin-right: 0;
    }

    /* Sidebar Header */
    .sidebar-header {
        padding: 2rem 1.5rem;
        border-bottom: 1px solid rgba(255, 255, 255, 0.08);
    }
    .admin-profile {
        display: flex;
        align-items: center;
        gap: 1rem;
    }
    .admin-avatar {
        width: 50px;
        height: 50px;
        background: linear-gradient(135deg, #2563eb, #1d4ed8);
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
        box-shadow: 0 6px 15px rgba(37, 99, 235, 0.3);
    }
    .admin-info h3 {
        font-size: 1rem;
        margin: 0 0 0.25rem 0;
        color: white;
        font-weight: 600;
    }
    .admin-role {
        font-size: 0.75rem;
        color: #9ca3af;
        display: block;
    }
    .admin-status {
        font-size: 0.7rem;
        color: #10b981;
        display: flex;
        align-items: center;
        gap: 4px;
        margin-top: 4px;
    }
    .status-dot {
        width: 6px;
        height: 6px;
        background: #10b981;
        border-radius: 50%;
        display: inline-block;
        animation: pulse 1.5s infinite;
    }
    @keyframes pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.5; }
    }

    /* Navigation */
    .sidebar-nav {
        list-style: none;
        padding: 1.5rem 0.75rem;
        margin: 0;
        flex: 1;
    }
    .nav-title {
        font-size: 0.65rem;
        text-transform: uppercase;
        letter-spacing: 1px;
        color: #6b7280;
        margin: 1rem 0 0.5rem 1rem;
        font-weight: 600;
    }
    .nav-item {
        margin: 0.2rem 0;
        transition: all 0.25s ease;
        border-radius: 12px;
    }
    .nav-item a {
        display: flex;
        align-items: center;
        gap: 0.75rem;
        padding: 0.7rem 1rem;
        color: #d1d5db;
        text-decoration: none;
        border-radius: 12px;
        transition: all 0.2s;
        position: relative;
    }
    .nav-item i {
        width: 24px;
        text-align: center;
        font-size: 1.1rem;
        background: rgba(255, 255, 255, 0.06);
        padding: 8px;
        border-radius: 10px;
        transition: all 0.2s;
    }
    .nav-item span {
        font-weight: 500;
        font-size: 0.9rem;
    }
    .nav-item:hover {
        background: rgba(255, 255, 255, 0.05);
        transform: translateX(5px);
    }
    .nav-item:hover i {
        background: #2563eb;
        color: white;
    }
    .nav-item.active {
        background: linear-gradient(135deg, #2563eb, #1d4ed8);
        box-shadow: 0 6px 15px rgba(37, 99, 235, 0.3);
    }
    .nav-item.active a {
        color: white;
    }
    .nav-item.active i {
        background: transparent;
        color: white;
    }

    /* Badge */
    .badge {
        background: #ef4444;
        color: white;
        font-size: 0.65rem;
        font-weight: 600;
        padding: 2px 8px;
        border-radius: 50px;
        margin-left: auto;
        box-shadow: 0 2px 5px rgba(239, 68, 68, 0.3);
    }

    /* Logout Item */
    .logout-item a {
        color: #f87171 !important;
    }
    .logout-item:hover {
        background: rgba(239, 68, 68, 0.1) !important;
    }
    .logout-item:hover i {
        background: #ef4444 !important;
        color: white !important;
    }

    /* Divider */
    .nav-divider {
        height: 1px;
        background: rgba(255, 255, 255, 0.08);
        margin: 1rem 0.5rem;
    }

    /* Sidebar Footer */
    .sidebar-footer {
        padding: 1rem 1.5rem;
        border-top: 1px solid rgba(255, 255, 255, 0.08);
        font-size: 0.75rem;
        color: #6b7280;
    }

    /* Toggle Button */
    .sidebar-toggle {
        position: fixed;
        top: 1rem;
        left: 1rem;
        z-index: 1001;
        background: #1e293b;
        color: white;
        border: none;
        padding: 0.5rem 0.75rem;
        border-radius: 10px;
        cursor: pointer;
        display: none;
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
        transition: background 0.2s;
    }
    .sidebar-toggle:hover {
        background: #2563eb;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .admin-sidebar {
            transform: translateX(-100%);
        }
        .admin-sidebar.active {
            transform: translateX(0);
        }
        .sidebar-toggle {
            display: block;
        }
        .admin-main {
            margin-left: 0 !important;
        }
    }
</style>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    // ========== NOTIFICATION SYSTEM WITH WEB SPEECH ==========
    let lastUnreadCount = -1;

    function updateNotificationBadge() {
        $.get("${pageContext.request.contextPath}/admin/messages?action=unreadCount", function(data) {
            let count = data.unreadCount;
            let badge = $("#notif-badge");
            if (count > 0) {
                badge.text(count).show();
            } else {
                badge.hide();
            }
            // Speak if new message arrived (count increased)
            if (count > 0 && lastUnreadCount !== -1 && count > lastUnreadCount) {
                try {
                    var utterance = new SpeechSynthesisUtterance("New message");
                    utterance.volume = 0.5;
                    window.speechSynthesis.speak(utterance);
                } catch(e) {
                    console.log("Speech not supported");
                }
            }
            lastUnreadCount = count;
        }).fail(function() {
            console.log("Failed to fetch unread count");
        });
    }

    $(document).ready(function() {
        updateNotificationBadge();
        setInterval(updateNotificationBadge, 10000);
    });
</script>

<!-- Mobile sidebar toggle script (unchanged) -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        var toggleBtn = document.getElementById('sidebarToggle');
        var sidebar = document.getElementById('adminSidebar');
        
        if (toggleBtn && sidebar) {
            toggleBtn.addEventListener('click', function() {
                sidebar.classList.toggle('active');
            });
            
            document.addEventListener('click', function(e) {
                if (window.innerWidth <= 768) {
                    if (!sidebar.contains(e.target) && !toggleBtn.contains(e.target)) {
                        sidebar.classList.remove('active');
                    }
                }
            });
        }
    });
</script>
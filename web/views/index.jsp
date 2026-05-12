<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="header.jsp" %>

<!-- Hero Section with Search Form -->
<section class="hero-section">
    <div class="hero-overlay"></div>
    <div class="hero-content">
        <h1 class="hero-title">Discover Your Next Adventure</h1>
        <p class="hero-subtitle">Book bus tickets across Ethiopia with ease, comfort, and the best prices.</p>
        
        <!-- Search Form -->
        <div class="search-card">
            <form action="${pageContext.request.contextPath}/search" method="get" class="search-form">
                <div class="form-row">
                    <div class="form-group">
                        <label><i class="fas fa-map-marker-alt"></i> From</label>
                        <input type="text" name="from" placeholder="Departure City" 
                               value="<c:out value='${from}'/>" 
                               pattern="[A-Za-z\s]{2,50}" 
                               title="Letters and spaces only (2-50 characters)" required>
                    </div>
                    <div class="form-group">
                        <label><i class="fas fa-map-marker-alt"></i> To</label>
                        <input type="text" name="to" placeholder="Destination City" 
                               value="<c:out value='${to}'/>" 
                               pattern="[A-Za-z\s]{2,50}" 
                               title="Letters and spaces only (2-50 characters)" required>
                    </div>
                    <div class="form-group">
                        <label><i class="fas fa-calendar-alt"></i> Date</label>
                        <input type="date" name="date" id="travelDate" 
                               value="<c:out value='${date}'/>" required>
                    </div>
                    <div class="form-group">
                        <button type="submit" class="btn-search">
                            <i class="fas fa-search"></i> Search Buses
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</section>

<!-- Popular Routes Section (DYNAMIC FROM DATABASE) -->
<section class="popular-routes">
    <div class="container">
        <div class="section-header">
            <h2>Popular Destinations</h2>
            <p>Explore our most booked routes with comfortable buses and great prices.</p>
        </div>
        
        <c:choose>
            <c:when test="${empty popularRoutes}">
                <div class="no-routes-message">
                    <i class="fas fa-info-circle"></i>
                    <p>No popular routes available at the moment. Please check back later!</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="routes-grid">
                    <c:forEach var="route" items="${popularRoutes}">
                        <div class="route-card">
                            <div class="route-image">
                                <img src="images/routes/${route.routeId}.jpg" 
                                     onerror="this.src='https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=400'" 
                                     alt="${route.source} to ${route.destination}" loading="lazy">
                            </div>
                            <div class="route-details">
                                <h3><c:out value="${route.source}"/> → <c:out value="${route.destination}"/></h3>
                                <p class="route-meta">
                                    <i class="far fa-clock"></i> ${route.duration} • 
                                    <i class="fas fa-tag"></i> from <c:out value="${route.fare}"/> ETB
                                </p>
                                <%-- 直接跳转到座位选择页面，日期默认为明天 --%>
                                <c:set var="tomorrow" value="<%= java.time.LocalDate.now().plusDays(1) %>" />
                                <a href="${pageContext.request.contextPath}/booking?routeId=${route.routeId}&date=${tomorrow}" 
                                   class="btn-route">Book Now <i class="fas fa-arrow-right"></i></a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<!-- Why Choose Us Section -->
<section class="features-section">
    <div class="container">
        <div class="section-header">
            <h2>Why Choose BusTicket?</h2>
            <p>We make your journey comfortable, safe, and hassle-free.</p>
        </div>
        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon"><i class="fas fa-shield-alt"></i></div>
                <h3>Safe & Secure</h3>
                <p>All our buses are regularly maintained and drivers are professionally trained.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon"><i class="fas fa-tag"></i></div>
                <h3>Best Prices</h3>
                <p>We offer competitive fares and seasonal discounts on all routes.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon"><i class="fas fa-headset"></i></div>
                <h3>24/7 Support</h3>
                <p>Our customer service team is always ready to assist you.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon"><i class="fas fa-wifi"></i></div>
                <h3>Free Wi-Fi</h3>
                <p>Stay connected throughout your journey with complimentary Wi-Fi.</p>
            </div>
        </div>
    </div>
</section>

<!-- Special Offer Banner -->
<section class="offer-section">
    <div class="container">
        <div class="offer-banner">
            <div class="offer-content">
                <span class="offer-badge">Limited Time Offer</span>
                <h2>Get 15% Off Your First Booking</h2>
                <p>Use code <strong>WELCOME15</strong> at checkout</p>
                <c:if test="${empty sessionScope.user}">
                    <a href="${pageContext.request.contextPath}/register" class="btn-offer">Sign Up Now</a>
                </c:if>
            </div>
            <div class="offer-image">
                <img src="https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=400" alt="Bus" loading="lazy">
            </div>
        </div>
    </div>
</section>

<!-- App Download Section -->
<section class="app-section">
    <div class="container">
        <div class="app-content">
            <h2>Download Our Mobile App</h2>
            <p>Book tickets, track your bus, and get exclusive app-only offers.</p>
            <div class="app-buttons">
                <a href="#" class="app-btn"><i class="fab fa-google-play"></i> Google Play</a>
                <a href="#" class="app-btn"><i class="fab fa-apple"></i> App Store</a>
            </div>
        </div>
    </div>
</section>

<!-- Loading Spinner -->
<div id="searchSpinner" class="spinner-overlay" style="display: none;">
    <div class="spinner"></div>
    <p>Searching for buses...</p>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        var today = new Date();
        today.setHours(0, 0, 0, 0);
        var dateInput = document.getElementById('travelDate');
        if (dateInput) {
            dateInput.min = today.toISOString().split('T')[0];
            if (!dateInput.value) {
                var tomorrow = new Date();
                tomorrow.setDate(tomorrow.getDate() + 1);
                tomorrow.setHours(0, 0, 0, 0);
                dateInput.value = tomorrow.toISOString().split('T')[0];
            }
        }
        
        var searchForm = document.querySelector('.search-form');
        var spinner = document.getElementById('searchSpinner');
        if (searchForm) {
            searchForm.addEventListener('submit', function() {
                spinner.style.display = 'flex';
            });
        }
    });
</script>

<style>
    .hero-section {
        min-height: 85vh;
        background: url('https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=1600') center/cover no-repeat;
        display: flex;
        align-items: center;
        justify-content: center;
        position: relative;
        margin-top: -70px;
        padding-top: 70px;
    }
    .hero-overlay {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(135deg, rgba(37, 99, 235, 0.9), rgba(30, 64, 175, 0.85));
    }
    .hero-content {
        position: relative;
        text-align: center;
        color: white;
        max-width: 1000px;
        padding: 2rem;
        z-index: 2;
    }
    .hero-title { font-size: 3.5rem; font-weight: 700; margin-bottom: 1rem; text-shadow: 0 2px 10px rgba(0,0,0,0.2); }
    .hero-subtitle { font-size: 1.25rem; margin-bottom: 2.5rem; opacity: 0.95; }
    .search-card { background: white; border-radius: 20px; padding: 2rem; box-shadow: 0 20px 40px rgba(0,0,0,0.15); }
    .search-form .form-row { display: grid; grid-template-columns: 1fr 1fr 1fr auto; gap: 1rem; align-items: end; }
    .search-form .form-group { text-align: left; }
    .search-form label { display: block; font-size: 0.875rem; font-weight: 600; color: #4b5563; margin-bottom: 0.5rem; }
    .search-form label i { margin-right: 0.5rem; color: #2563eb; }
    .search-form input { width: 100%; padding: 0.75rem 1rem; border: 1px solid #e5e7eb; border-radius: 10px; font-size: 1rem; transition: border-color 0.3s, box-shadow 0.3s; }
    .search-form input:focus { outline: none; border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1); }
    .btn-search { background: #2563eb; color: white; border: none; padding: 0.75rem 2rem; border-radius: 10px; font-size: 1rem; font-weight: 600; cursor: pointer; transition: background 0.3s; white-space: nowrap; }
    .btn-search:hover { background: #1e40af; }
    .container { max-width: 1200px; margin: 0 auto; padding: 0 2rem; }
    .section-header { text-align: center; margin-bottom: 3rem; }
    .section-header h2 { font-size: 2.5rem; color: #1f2937; margin-bottom: 0.5rem; }
    .section-header p { color: #6b7280; font-size: 1.125rem; }
    .popular-routes { padding: 5rem 0; background: #f9fafb; }
    .routes-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 2rem; }
    .route-card { background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.05); transition: transform 0.3s, box-shadow 0.3s; border: 1px solid rgba(0,0,0,0.02); }
    .route-card:hover { transform: translateY(-5px); box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); }
    .route-image img { width: 100%; height: 200px; object-fit: cover; }
    .route-details { padding: 1.5rem; }
    .route-details h3 { font-size: 1.25rem; margin-bottom: 0.5rem; color: #1f2937; }
    .route-meta { color: #6b7280; margin-bottom: 1rem; }
    .btn-route { display: inline-block; color: #2563eb; font-weight: 600; text-decoration: none; transition: color 0.3s; }
    .btn-route:hover { color: #1e40af; }
    .btn-route i { margin-left: 0.5rem; transition: transform 0.3s; }
    .btn-route:hover i { transform: translateX(5px); }
    .features-section { padding: 5rem 0; background: white; }
    .features-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 2rem; }
    .feature-card { text-align: center; padding: 2rem 1.5rem; border-radius: 16px; background: #f9fafb; transition: background 0.3s; }
    .feature-card:hover { background: #eef2ff; }
    .feature-icon { width: 70px; height: 70px; background: #2563eb; color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 1.5rem; font-size: 1.75rem; }
    .feature-card h3 { margin-bottom: 0.75rem; color: #1f2937; }
    .feature-card p { color: #6b7280; line-height: 1.6; }
    .offer-section { padding: 4rem 0; background: linear-gradient(135deg, #1e40af, #3b82f6); }
    .offer-banner { display: flex; align-items: center; justify-content: space-between; gap: 2rem; }
    .offer-content { color: white; }
    .offer-badge { display: inline-block; background: rgba(255,255,255,0.2); padding: 0.5rem 1rem; border-radius: 30px; font-size: 0.875rem; font-weight: 600; margin-bottom: 1rem; }
    .offer-content h2 { font-size: 2.5rem; margin-bottom: 1rem; }
    .offer-content p { font-size: 1.25rem; margin-bottom: 2rem; }
    .btn-offer { display: inline-block; background: white; color: #2563eb; padding: 0.75rem 2rem; border-radius: 10px; text-decoration: none; font-weight: 600; transition: transform 0.3s; }
    .btn-offer:hover { transform: scale(1.05); }
    .offer-image img { max-width: 300px; border-radius: 16px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2); }
    .app-section { padding: 5rem 0; background: #f9fafb; text-align: center; }
    .app-content h2 { font-size: 2.5rem; margin-bottom: 1rem; }
    .app-buttons { margin-top: 2rem; display: flex; gap: 1rem; justify-content: center; }
    .app-btn { display: inline-flex; align-items: center; gap: 0.75rem; background: #1f2937; color: white; padding: 0.75rem 2rem; border-radius: 10px; text-decoration: none; font-weight: 500; transition: background 0.3s; }
    .app-btn:hover { background: #111827; }
    .no-routes-message { text-align: center; padding: 3rem; background: #f9fafb; border-radius: 16px; color: #6b7280; }
    .no-routes-message i { font-size: 3rem; color: #2563eb; margin-bottom: 1rem; opacity: 0.6; }
    .spinner-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); backdrop-filter: blur(4px); display: flex; flex-direction: column; justify-content: center; align-items: center; z-index: 9999; color: white; }
    .spinner { width: 50px; height: 50px; border: 5px solid rgba(255,255,255,0.3); border-radius: 50%; border-top-color: white; animation: spin 1s linear infinite; margin-bottom: 1rem; }
    @keyframes spin { to { transform: rotate(360deg); } }
    @media (max-width: 768px) {
        .hero-title { font-size: 2.5rem; }
        .search-form .form-row { grid-template-columns: 1fr; }
        .btn-search { width: 100%; }
        .offer-banner { flex-direction: column; text-align: center; }
        .section-header h2 { font-size: 2rem; }
    }
</style>

<%@ include file="footer.jsp" %>
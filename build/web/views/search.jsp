<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="header.jsp" %>

<!-- Search Context Summary -->
<div class="search-summary">
    <div class="summary-content">
        <h2>
            <i class="fas fa-search"></i> 
            Buses from <strong><c:out value="${param.from}" /></strong> 
            to <strong><c:out value="${param.to}" /></strong>
        </h2>
        <p class="travel-date">
            <i class="far fa-calendar-alt"></i> 
            <fmt:parseDate value="${param.date}" pattern="yyyy-MM-dd" var="parsedDate" />
            <fmt:formatDate value="${parsedDate}" pattern="EEEE, MMMM d, yyyy" />
        </p>
        <a href="${pageContext.request.contextPath}/" class="btn-modify">
            <i class="fas fa-edit"></i> Modify Search
        </a>
    </div>
    <div class="result-stats">
        <c:choose>
            <c:when test="${not empty routes}">
                <span class="result-count"><i class="fas fa-bus"></i> ${fn:length(routes)} bus(es) found</span>
            </c:when>
            <c:otherwise>
                <span class="result-count">No buses found</span>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- Filter & Sort Bar – only shown when there are routes -->
<c:if test="${not empty routes}">
<div class="filter-bar">
    <div class="filter-options">
        <label><i class="fas fa-filter"></i> Filter:</label>
        <select id="busTypeFilter" class="filter-select">
            <option value="all">All Bus Types</option>
            <option value="AC">AC</option>
            <option value="Non-AC">Non-AC</option>
            <option value="Sleeper">Sleeper</option>
            <option value="Volvo">Volvo</option>
        </select>
        
        <label><i class="fas fa-sort"></i> Sort by:</label>
        <select id="sortSelect" class="filter-select">
            <option value="departure">Departure Time (Earliest)</option>
            <option value="price">Price (Low to High)</option>
            <option value="duration">Duration (Shortest)</option>
            <option value="seats">Available Seats</option>
        </select>
    </div>
    <div class="filter-actions">
        <button id="applyFilterBtn" class="btn-filter" type="button" onclick="filterAndSort();">Apply</button>
        <button id="resetFilterBtn" class="btn-reset" type="button" onclick="resetFilters();">Reset</button>
    </div>
</div>
</c:if>

<!-- Main Results Section -->
<c:choose>
    <c:when test="${empty routes}">
        <div class="no-results">
            <div class="no-results-icon">
                <i class="fas fa-bus"></i>
            </div>
            <h3>No buses available for this route</h3>
            <p>We couldn't find any buses matching your search criteria.</p>
            <div class="suggestions">
                <p><i class="fas fa-lightbulb"></i> Suggestions:</p>
                <ul>
                    <li>Try a different travel date</li>
                    <li>Check the spelling of city names</li>
                    <li>Remove any applied filters</li>
                </ul>
            </div>
            <a href="${pageContext.request.contextPath}/" class="btn-primary">
                <i class="fas fa-arrow-left"></i> Back to Search
            </a>
        </div>
    </c:when>
    <c:otherwise>
        <div class="route-results">
            <c:forEach var="route" items="${routes}">
                <c:set var="availableSeats" value="${route.totalSeats - fn:length(bookedSeatsMap[route.routeId])}" />
                <div class="route-card" 
                     data-bus-type="${route.busType}" 
                     data-fare="${route.fare}" 
                     data-departure="${route.departureTime.time}" 
                     data-duration="${route.duration}"
                     data-available-seats="${availableSeats}">
                    
                    <div class="route-main">
                        <div class="bus-operator">
                            <div class="operator-avatar">
                                <i class="fas fa-bus"></i>
                            </div>
                            <div class="operator-details">
                                <h3><c:out value="${route.busName}" /></h3>
                                <span class="bus-type-badge ${fn:toLowerCase(route.busType)}">
                                    <c:out value="${route.busType}" />
                                </span>
                                <div class="rating">
                                    <span class="stars">★★★★☆</span>
                                    <span>4.2 (120 reviews)</span>
                                </div>
                            </div>
                        </div>
                        
                        <div class="journey-details">
                            <div class="time-block">
                                <span class="time-main">
                                    <fmt:formatDate value="${route.departureTime}" pattern="hh:mm a" />
                                </span>
                                <span class="time-label">Departure</span>
                            </div>
                            <div class="duration-block">
                                <span class="duration"><i class="far fa-clock"></i> <c:out value="${route.duration}" /></span>
                                <div class="route-line">
                                    <span class="dot start"></span>
                                    <span class="line"></span>
                                    <span class="dot end"></span>
                                </div>
                                <span class="stops">Direct</span>
                            </div>
                            <div class="time-block">
                                <span class="time-main">
                                    <fmt:formatDate value="${route.arrivalTime}" pattern="hh:mm a" />
                                </span>
                                <span class="time-label">Arrival</span>
                            </div>
                        </div>
                        
                        <div class="route-meta">
                            <span class="source"><c:out value="${route.source}" /></span>
                            <i class="fas fa-arrow-right"></i>
                            <span class="destination"><c:out value="${route.destination}" /></span>
                        </div>
                    </div>
                    
                    <div class="route-action">
                        <div class="price-section">
                            <span class="fare-amount">ETB <fmt:formatNumber value="${route.fare}" pattern="#,##0.00" /></span>
                            <span class="per-seat">per seat</span>
                            <c:if test="${route.fare <= 350}">
                                <span class="badge best-price">Best Price</span>
                            </c:if>
                            <c:if test="${route.departureTime.hours < 10}">
                                <span class="badge early-bird">Early Bird</span>
                            </c:if>
                        </div>
                        
                        <div class="seats-info">
                            <div class="seats-available ${availableSeats <= 5 ? 'low-seats' : ''}">
                                <i class="fas fa-chair"></i> 
                                <c:out value="${availableSeats}" /> seats left
                            </div>
                            <c:if test="${availableSeats <= 5 && availableSeats > 0}">
                                <span class="warning-badge">Only few seats left!</span>
                            </c:if>
                            <c:if test="${availableSeats == 0}">
                                <span class="sold-out-badge">Sold Out</span>
                            </c:if>
                        </div>
                        
                        <c:choose>
                            <c:when test="${availableSeats > 0}">
                                <form action="${pageContext.request.contextPath}/booking" method="get" 
                                      onsubmit="this.querySelector('button').disabled=true;">
                                    <input type="hidden" name="routeId" value="${route.routeId}">
                                    <input type="hidden" name="date" value="${param.date}">
                                    <button type="submit" class="btn-select-seats">
                                        <i class="fas fa-ticket-alt"></i> Select Seats
                                    </button>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <button class="btn-sold-out" disabled>
                                    <i class="fas fa-times-circle"></i> Sold Out
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:forEach>
        </div>
        
        <c:if test="${totalPages > 1}">
            <div class="pagination-container">
                <ul class="pagination">
                    <c:if test="${currentPage > 1}">
                        <li><a href="?from=${param.from}&to=${param.to}&date=${param.date}&page=${currentPage - 1}">
                            <i class="fas fa-chevron-left"></i> Prev
                        </a></li>
                    </c:if>
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="${i == currentPage ? 'active' : ''}">
                            <a href="?from=${param.from}&to=${param.to}&date=${param.date}&page=${i}">${i}</a>
                        </li>
                    </c:forEach>
                    <c:if test="${currentPage < totalPages}">
                        <li><a href="?from=${param.from}&to=${param.to}&date=${param.date}&page=${currentPage + 1}">
                            Next <i class="fas fa-chevron-right"></i>
                        </a></li>
                    </c:if>
                </ul>
            </div>
        </c:if>
    </c:otherwise>
</c:choose>

<!-- Loading Spinner -->
<div id="searchSpinner" class="spinner-overlay" style="display: none; pointer-events: none;">
    <div class="spinner"></div>
    <p>Searching for buses...</p>
</div>

<script>
    // Global functions for filter/sort (ES5 compatible)
    function filterAndSort() {
        console.log('filterAndSort called');
        
        var busTypeFilter = document.getElementById('busTypeFilter');
        var sortSelect = document.getElementById('sortSelect');
        var resultsContainer = document.querySelector('.route-results');
        
        if (!resultsContainer) {
            console.warn('No .route-results container found – nothing to filter/sort.');
            return;
        }
        
        if (!busTypeFilter || !sortSelect) {
            console.error('Missing filter or sort select elements.');
            return;
        }
        
        var selectedType = busTypeFilter.value;
        var sortBy = sortSelect.value;
        
        var allCards = document.querySelectorAll('.route-card');
        var cardsArray = Array.prototype.slice.call(allCards);
        
        // 1) Filter by bus type
        for (var i = 0; i < cardsArray.length; i++) {
            var card = cardsArray[i];
            var busType = card.getAttribute('data-bus-type');
            if (selectedType === 'all' || busType === selectedType) {
                card.style.display = '';
            } else {
                card.style.display = 'none';
            }
        }
        
        // 2) Collect visible cards
        var visibleCards = [];
        for (var i = 0; i < cardsArray.length; i++) {
            if (cardsArray[i].style.display !== 'none') {
                visibleCards.push(cardsArray[i]);
            }
        }
        
        // 3) Sort visible cards
        visibleCards.sort(function(a, b) {
            if (sortBy === 'price') {
                var fareA = parseFloat(a.getAttribute('data-fare')) || 0;
                var fareB = parseFloat(b.getAttribute('data-fare')) || 0;
                return fareA - fareB;
            } else if (sortBy === 'departure') {
                var depA = parseInt(a.getAttribute('data-departure')) || 0;
                var depB = parseInt(b.getAttribute('data-departure')) || 0;
                return depA - depB;
            } else if (sortBy === 'duration') {
                var durA = a.getAttribute('data-duration') || '';
                var durB = b.getAttribute('data-duration') || '';
                return durA.localeCompare(durB);
            } else if (sortBy === 'seats') {
                var seatsA = parseInt(a.getAttribute('data-available-seats')) || 0;
                var seatsB = parseInt(b.getAttribute('data-available-seats')) || 0;
                return seatsB - seatsA;
            }
            return 0;
        });
        
        // 4) Reorder DOM
        for (var i = 0; i < visibleCards.length; i++) {
            resultsContainer.appendChild(visibleCards[i]);
        }
        
        console.log('Filter/sort completed. Visible cards:', visibleCards.length);
    }
    
    function resetFilters() {
        console.log('resetFilters called');
        var busTypeFilter = document.getElementById('busTypeFilter');
        var sortSelect = document.getElementById('sortSelect');
        if (busTypeFilter) busTypeFilter.value = 'all';
        if (sortSelect) sortSelect.value = 'departure';
        filterAndSort();
    }
    
    // Ensure functions are globally available (they already are)
    document.addEventListener('DOMContentLoaded', function() {
        console.log('DOM ready – filter buttons have inline onclick, no extra attachment needed.');
        // Spinner on forms
        var forms = document.querySelectorAll('form');
        for (var i = 0; i < forms.length; i++) {
            forms[i].addEventListener('submit', function() {
                var spinner = document.getElementById('searchSpinner');
                if (spinner) spinner.style.display = 'flex';
            });
        }
    });
</script>

<style>
    /* Force buttons to be clickable */
    .btn-filter, .btn-reset {
        pointer-events: auto !important;
        cursor: pointer !important;
        z-index: 999 !important;
        position: relative;
    }
    .filter-bar {
        position: relative;
        z-index: 5;
    }
    /* (keep all your existing styles below – unchanged) */
    .search-summary {
        background: white;
        border-radius: 12px;
        padding: 1.5rem 2rem;
        margin-bottom: 1.5rem;
        box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        display: flex;
        justify-content: space-between;
        align-items: center;
        border: 1px solid #eef2f6;
    }
    .summary-content h2 { margin-bottom: 0.25rem; color: #1f2937; }
    .travel-date { color: #6b7280; }
    .btn-modify { display: inline-block; margin-top: 0.5rem; color: #2563eb; text-decoration: none; font-weight: 500; }
    .result-stats .result-count { font-size: 1.1rem; font-weight: 600; color: #2563eb; }
    .filter-bar {
        background: white;
        border-radius: 12px;
        padding: 1rem 1.5rem;
        margin-bottom: 1.5rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
        box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        border: 1px solid #eef2f6;
    }
    .filter-select {
        padding: 0.5rem 2rem 0.5rem 1rem;
        border-radius: 8px;
        border: 1px solid #d1d5db;
        margin: 0 0.5rem 0 0.25rem;
        background: white;
    }
    .btn-filter, .btn-reset {
        padding: 0.5rem 1.5rem;
        border-radius: 8px;
        border: none;
        font-weight: 500;
        margin-left: 0.5rem;
    }
    .btn-filter { background: #2563eb; color: white; }
    .btn-reset { background: #f3f4f6; color: #4b5563; }
    .route-results { display: flex; flex-direction: column; gap: 1.25rem; }
    .route-card {
        background: white;
        border-radius: 16px;
        padding: 1.5rem;
        box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
        display: flex;
        justify-content: space-between;
        align-items: center;
        transition: all 0.2s ease;
        border: 1px solid #f0f2f5;
    }
    .route-card:hover { box-shadow: 0 10px 25px -5px rgba(0,0,0,0.1); transform: translateY(-2px); }
    .route-main { flex: 2; }
    .bus-operator { display: flex; align-items: center; gap: 1rem; margin-bottom: 1.25rem; }
    .operator-avatar {
        width: 48px;
        height: 48px;
        background: #e0e7ff;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #2563eb;
        font-size: 1.5rem;
    }
    .operator-details h3 { margin-bottom: 0.25rem; }
    .bus-type-badge {
        background: #e5e7eb;
        padding: 0.2rem 0.8rem;
        border-radius: 30px;
        font-size: 0.75rem;
        font-weight: 600;
        margin-right: 0.75rem;
    }
    .journey-details { display: flex; align-items: center; gap: 2rem; margin-bottom: 0.75rem; }
    .time-main { font-size: 1.25rem; font-weight: 600; color: #1f2937; }
    .time-label { display: block; font-size: 0.75rem; color: #6b7280; }
    .duration-block { text-align: center; }
    .route-line { display: flex; align-items: center; margin: 0.25rem 0; }
    .dot { width: 8px; height: 8px; background: #9ca3af; border-radius: 50%; }
    .line { flex: 1; height: 2px; background: #d1d5db; margin: 0 8px; }
    .route-action { text-align: right; min-width: 200px; }
    .fare-amount { font-size: 1.75rem; font-weight: 700; color: #2563eb; }
    .badge {
        display: inline-block;
        background: #fef3c7;
        color: #92400e;
        padding: 0.2rem 0.6rem;
        border-radius: 20px;
        font-size: 0.7rem;
        font-weight: 600;
        margin-top: 0.25rem;
    }
    .badge.best-price { background: #d1fae5; color: #065f46; }
    .seats-info { margin: 1rem 0; }
    .seats-available.low-seats { color: #dc2626; font-weight: 600; }
    .warning-badge {
        background: #fee2e2;
        color: #b91c1c;
        padding: 0.2rem 0.6rem;
        border-radius: 20px;
        font-size: 0.7rem;
        margin-left: 0.5rem;
    }
    .btn-select-seats {
        background: #2563eb;
        color: white;
        border: none;
        padding: 0.75rem 1.5rem;
        border-radius: 8px;
        font-weight: 600;
        cursor: pointer;
        width: 100%;
        transition: background 0.2s;
    }
    .btn-select-seats:hover { background: #1e40af; }
    .btn-sold-out {
        background: #e5e7eb;
        color: #6b7280;
        border: none;
        padding: 0.75rem 1.5rem;
        border-radius: 8px;
        font-weight: 600;
        width: 100%;
        cursor: not-allowed;
    }
    .no-results {
        text-align: center;
        padding: 4rem 2rem;
        background: white;
        border-radius: 24px;
        box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
    }
    .no-results-icon { font-size: 4rem; color: #9ca3af; margin-bottom: 1.5rem; }
    .pagination-container { margin-top: 2rem; display: flex; justify-content: center; }
    .pagination { display: flex; gap: 0.5rem; list-style: none; padding: 0; }
    .pagination li a {
        display: block;
        padding: 0.5rem 1rem;
        background: white;
        border-radius: 8px;
        text-decoration: none;
        color: #4b5563;
        border: 1px solid #e5e7eb;
    }
    .pagination li.active a { background: #2563eb; color: white; border-color: #2563eb; }
    @media (max-width: 768px) {
        .route-card { flex-direction: column; align-items: stretch; }
        .route-action { text-align: left; margin-top: 1.5rem; }
        .journey-details { flex-wrap: wrap; gap: 1rem; }
        .search-summary { flex-direction: column; align-items: flex-start; gap: 1rem; }
        .filter-bar { flex-direction: column; align-items: stretch; gap: 1rem; }
        .filter-options { display: flex; flex-wrap: wrap; gap: 0.5rem; }
    }
</style>

<%@ include file="footer.jsp" %>
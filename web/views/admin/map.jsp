<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Route Map - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <!-- Leaflet CSS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <!-- Leaflet MiniMap -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet-minimap@3.6.1/dist/Control.MiniMap.min.css" />
    <!-- Leaflet PolylineDecorator -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet-polylinedecorator@1.6.0/dist/leaflet.polylinedecorator.css" />
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #f8fafc; overflow-x: hidden; }
        .admin-layout { display: flex; min-height: 100vh; position: relative; }
        .admin-sidebar { position: fixed !important; left: 0; top: 0; height: 100vh; width: 280px; z-index: 1000; overflow-y: auto; }
        .admin-main {
            flex: 1; margin-left: 280px; padding: 2rem; width: calc(100% - 280px);
            max-width: 100%; background: #f8fafc; transition: margin-left 0.3s ease;
        }
        .admin-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; flex-wrap: wrap; }
        .admin-header h1 { font-size: 2rem; font-weight: 700; color: #1f2937; display: flex; align-items: center; gap: 0.75rem; }
        .stats-badge {
            background: #2563eb; color: white; padding: 0.3rem 1rem; border-radius: 30px;
            font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 0.5rem;
        }
        .map-container { 
            padding: 1.5rem; background: white; border-radius: 20px; 
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); 
        }
        #map { height: 600px; width: 100%; border-radius: 16px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        .search-box { display: flex; gap: 0.5rem; margin-bottom: 1rem; }
        .search-box input { 
            flex: 1; padding: 0.75rem 1rem; border: 1px solid #d1d5db; 
            border-radius: 12px; font-size: 0.95rem; 
        }
        .search-box button { 
            padding: 0.75rem 1.5rem; background: #2563eb; color: white; 
            border: none; border-radius: 12px; cursor: pointer; font-weight: 500; 
        }
        .search-box button:hover { background: #1d4ed8; }
        .route-legend { margin-top: 1rem; display: flex; gap: 1.5rem; flex-wrap: wrap; }
        .legend-item { display: flex; align-items: center; gap: 0.5rem; }
        .marker-dot { width: 12px; height: 12px; border-radius: 50%; }
        .marker-dot.origin { background: #10b981; border: 2px solid white; box-shadow: 0 0 0 2px #10b981; }
        .marker-dot.destination { background: #ef4444; border: 2px solid white; box-shadow: 0 0 0 2px #ef4444; }
        .alert { padding: 1rem; border-radius: 14px; margin-bottom: 1.5rem; }
        .alert-danger { background: #fee2e2; color: #991b1b; }
        .loading-overlay {
            position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: rgba(255,255,255,0.9);
            display: flex; align-items: center; justify-content: center; z-index: 2000; border-radius: 16px;
        }
        .animation-toggle-btn {
            background: #e5e7eb; border: none; padding: 0.3rem 1rem; border-radius: 20px;
            font-size: 0.9rem; cursor: pointer; margin-left: 1rem;
        }
        .dark-toggle { margin-left: auto; }
        @media (max-width: 992px) {
            .admin-main { margin-left: 0 !important; width: 100% !important; padding: 1.5rem; }
            .admin-sidebar { transform: translateX(-100%); transition: transform 0.3s ease; }
            .admin-sidebar.active { transform: translateX(0); }
        }
    </style>
</head>
<body>
<div class="admin-layout">
    <jsp:include page="/views/admin/sidebar.jsp" />
    <main class="admin-main">
        <div class="admin-header">
            <h1><i class="fas fa-map-marked-alt"></i> Route Map</h1>
            <div style="display: flex; gap: 1rem; align-items: center;">
                <div class="stats-badge"><i class="fas fa-road"></i> <span id="routeCount">0</span> routes</div>
                <div class="stats-badge"><i class="fas fa-bus"></i> <span id="activeBuses">0</span> active buses</div>
                <button class="btn-icon dark-toggle" onclick="toggleDarkMode()" title="Toggle map layer">
                    <i class="fas fa-moon"></i>
                </button>
            </div>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ${error}</div>
        </c:if>

        <!-- Loading overlay -->
        <div id="loadingOverlay" class="loading-overlay" style="display: none;">
            <div><i class="fas fa-spinner fa-spin"></i> Loading routes...</div>
        </div>

        <div class="map-container">
            <!-- Search bar -->
            <div class="search-box">
                <input type="text" id="citySearch" placeholder="Source city..." list="cityList">
                <input type="text" id="destSearch" placeholder="Destination (optional)" list="cityList">
                <datalist id="cityList"></datalist>
                <button onclick="searchRoute()"><i class="fas fa-search"></i> Find</button>
                <button onclick="clearSearch()" title="Clear"><i class="fas fa-times"></i></button>
                <button id="toggleAnimationBtn" onclick="toggleAnimation()" class="animation-toggle-btn">
                    <i class="fas fa-play"></i> Start Animation
                </button>
            </div>
            <div id="searchMessage" style="min-height: 24px; font-size: 0.9rem; color: #2563eb; margin-bottom: 0.5rem;"></div>

            <!-- Map -->
            <div id="map" style="position: relative;"></div>

            <!-- Legend -->
            <div class="route-legend">
                <div class="legend-item"><span class="marker-dot origin"></span> Departure</div>
                <div class="legend-item"><span class="marker-dot destination"></span> Arrival</div>
                
            </div>
        </div>
    </main>
</div>

<!-- Leaflet JS -->
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<!-- MiniMap -->
<script src="https://unpkg.com/leaflet-minimap@3.6.1/dist/Control.MiniMap.min.js"></script>
<!-- PolylineDecorator -->
<script src="https://unpkg.com/leaflet-polylinedecorator@1.6.0/dist/leaflet.polylinedecorator.js"></script>

<script>
    // ====================== CONFIGURATION ======================
    const CITY_COORDS = {
        'Addis Ababa': [9.03, 38.74], 'Bahir Dar': [11.6, 37.38], 'Jimma': [7.67, 36.83],
        'Hawassa': [7.06, 38.48], 'Dire Dawa': [9.59, 41.86], 'Mekele': [13.5, 39.47],
        'Gondar': [12.6, 37.47], 'Dessie': [11.13, 39.63], 'Harar': [9.31, 42.13],
        'Arba Minch': [6.03, 37.55], 'Debre Markos': [10.35, 37.73], 'Debre Birhan': [9.68, 39.53],
        'Adama': [8.54, 39.27], 'Shashamane': [7.2, 38.6], 'Nekemte': [9.08, 36.55],
        'Assosa': [10.07, 34.53], 'Gambella': [8.25, 34.58], 'Jijiga': [9.35, 42.8],
        'Semera': [11.79, 41.01], 'Woldia': [11.83, 39.6], 'Hosanna': [7.55, 37.85],
        'Dilla': [6.41, 38.31], 'Mizan Teferi': [6.99, 35.58]
    };

    // Routes from server
    const rawRoutes = [
        <c:forEach var="route" items="${routes}" varStatus="loop">
            {
                source: "${route.source}",
                destination: "${route.destination}",
                busName: "${route.busName}",
                busType: "${route.busType}"
            }<c:if test="${!loop.last}">,</c:if>
        </c:forEach>
    ];

    // ====================== GLOBAL VARIABLES ======================
    let map, minimap;
    let baseLayer, satelliteLayer, currentLayer;
    let routePolylines = [];
    let allRoutesData = [];
    let cityMarkers = {};
    let animationInterval = null;
    let isAnimating = false;
    let animatedMarkers = [];
    const animationSpeedBase = 50;

    // ====================== INIT MAP ======================
    function initMap() {
        let lastView = localStorage.getItem('mapLastView');
        let center = [9.145, 40.4897];
        let zoom = 6;
        if (lastView) {
            try {
                let parsed = JSON.parse(lastView);
                center = parsed.center || center;
                zoom = parsed.zoom || zoom;
            } catch(e) {}
        }

        map = L.map('map').setView(center, zoom);

        satelliteLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
            attribution: 'Tiles © Esri'
        });
        baseLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap'
        });

        satelliteLayer.addTo(map);
        currentLayer = 'satellite';

        minimap = new L.Control.MiniMap(baseLayer, { toggleDisplay: true, position: 'bottomright' }).addTo(map);

        map.on('moveend', saveMapView);
        map.on('zoomend', saveMapView);

        let datalist = document.getElementById('cityList');
        Object.keys(CITY_COORDS).sort().forEach(city => {
            let opt = document.createElement('option');
            opt.value = city;
            datalist.appendChild(opt);
        });

        processRoutesData();
        renderAll();
        updateStats();
    }

    function saveMapView() {
        let center = map.getCenter();
        let zoom = map.getZoom();
        localStorage.setItem('mapLastView', JSON.stringify({ center: [center.lat, center.lng], zoom: zoom }));
    }

    // ====================== ROUTE PROCESSING ======================
    function processRoutesData() {
        let routeMap = new Map();
        let sourceBuses = {};
        let destinationBuses = {};

        rawRoutes.forEach(r => {
            if (!r.source || !r.destination) return;
            let key = r.source + '|' + r.destination;
            if (!routeMap.has(key)) {
                routeMap.set(key, {
                    source: r.source,
                    destination: r.destination,
                    buses: []
                });
            }
            let busInfo = (r.busName || 'Unknown') + ' (' + (r.busType || 'Standard') + ')';
            let entry = routeMap.get(key);
            if (!entry.buses.includes(busInfo)) {
                entry.buses.push(busInfo);
            }
        });

        allRoutesData = Array.from(routeMap.values());

        // Build source/destination bus collections for markers
        let srcBuses = {}, destBuses = {};
        rawRoutes.forEach(r => {
            if (!r.source || !r.destination) return;
            let busInfo = (r.busName || 'Unknown') + ' (' + (r.busType || 'Standard') + ')';
            if (!srcBuses[r.source]) srcBuses[r.source] = new Set();
            if (!destBuses[r.destination]) destBuses[r.destination] = new Set();
            srcBuses[r.source].add(busInfo);
            destBuses[r.destination].add(busInfo);
        });
        window.sourceBuses = srcBuses;
        window.destinationBuses = destBuses;
    }

    // ====================== RENDERING ======================
    function renderAll() {
        // Clear existing layers
        routePolylines.forEach(item => {
            map.removeLayer(item.polyline);
            if (item.decorator) map.removeLayer(item.decorator);
        });
        routePolylines = [];
        Object.values(cityMarkers).forEach(m => map.removeLayer(m));
        cityMarkers = {};

        let drawnOrigins = new Set();
        let drawnDestinations = new Set();

        allRoutesData.forEach(route => {
            let srcCoords = CITY_COORDS[route.source];
            let destCoords = CITY_COORDS[route.destination];
            if (!srcCoords || !destCoords) return;

            // Determine color based on first bus type (simplified)
            let firstBus = route.buses[0] || '';
            let color = '#2563eb'; // default
            if (firstBus.toLowerCase().includes('luxury') || firstBus.toLowerCase().includes('vip')) color = '#fbbf24';
            else if (firstBus.toLowerCase().includes('minibus')) color = '#8b5cf6';
            let dashArray = firstBus.toLowerCase().includes('minibus') ? '5,5' : null;

            let polyline = L.polyline([srcCoords, destCoords], {
                color: color, weight: 4, opacity: 0.8, dashArray: dashArray
            }).addTo(map);

            let decorator = L.polylineDecorator(polyline, {
                patterns: [{
                    offset: '10%', repeat: '80px',
                    symbol: L.Symbol.arrowHead({ pixelSize: 12, polygon: false, pathOptions: { stroke: true, color: '#333', weight: 2 } })
                }]
            }).addTo(map);

            let dist = getDistanceFromLatLonInKm(srcCoords[0], srcCoords[1], destCoords[0], destCoords[1]);
            let distStr = dist.toFixed(1) + ' km';

            let busesHtml = route.buses.map(b => `<div>🚌 ${b}</div>`).join('');
            let popupContent = `
                <div style="font-family:Inter,sans-serif; min-width:200px;">
                    <h4 style="margin:0 0 8px;">🚏 ${route.source} → ${route.destination}</h4>
                    ${busesHtml}
                    <hr style="margin:8px 0;">
                    <div>📏 Distance: ${distStr}</div>
                </div>
            `;
            polyline.bindPopup(popupContent, { maxWidth: 300 });

            polyline.on('mouseover', function(e) {
                this.setStyle({ weight: 6, color: '#000' });
                this.bindTooltip(`<b>${route.source} → ${route.destination}</b><br>${route.buses.length} bus(es)`, { sticky: true });
                this.openTooltip();
            });
            polyline.on('mouseout', function() {
                this.setStyle({ weight: 4, color: color });
                this.unbindTooltip();
            });

            polyline.on('click', function() {
                routePolylines.forEach(item => item.polyline.setStyle({ weight: 4, color: item.color }));
                this.setStyle({ weight: 6, color: '#000' });
                map.fitBounds(this.getBounds(), { padding: [50, 50] });
            });

            routePolylines.push({ polyline, decorator, color, source: route.source, destination: route.destination, buses: route.buses, distance: distStr });

            // Add city markers
            if (!drawnOrigins.has(route.source)) {
                let marker = L.marker(srcCoords, {
                    icon: L.divIcon({ html: '<div style="background:#10b981; width:14px; height:14px; border-radius:50%; border:2px solid white; box-shadow:0 0 0 3px #10b981;"></div>', iconSize: [14,14] })
                }).addTo(map);
                let srcBuses = window.sourceBuses[route.source] || new Set();
                let popupText = `<b>${route.source}</b><br>Departure point<br><br>`;
                if (srcBuses.size) popupText += '<u>Buses from here:</u><br>' + Array.from(srcBuses).join('<br>');
                marker.bindPopup(popupText);
                cityMarkers['src_'+route.source] = marker;
                drawnOrigins.add(route.source);
            }
            if (!drawnDestinations.has(route.destination)) {
                let marker = L.marker(destCoords, {
                    icon: L.divIcon({ html: '<div style="background:#ef4444; width:14px; height:14px; border-radius:50%; border:2px solid white; box-shadow:0 0 0 3px #ef4444;"></div>', iconSize: [14,14] })
                }).addTo(map);
                let destBuses = window.destinationBuses[route.destination] || new Set();
                let popupText = `<b>${route.destination}</b><br>Arrival point<br><br>`;
                if (destBuses.size) popupText += '<u>Buses to here:</u><br>' + Array.from(destBuses).join('<br>');
                marker.bindPopup(popupText);
                cityMarkers['dest_'+route.destination] = marker;
                drawnDestinations.add(route.destination);
            }
        });

        updateStats();
    }

    function getDistanceFromLatLonInKm(lat1, lon1, lat2, lon2) {
        let R = 6371;
        let dLat = (lat2-lat1)*Math.PI/180;
        let dLon = (lon2-lon1)*Math.PI/180;
        let a = Math.sin(dLat/2)**2 + Math.cos(lat1*Math.PI/180)*Math.cos(lat2*Math.PI/180)*Math.sin(dLon/2)**2;
        return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    }

    function updateStats() {
        document.getElementById('routeCount').innerText = routePolylines.length;
        let totalBuses = rawRoutes.filter(r => r.source && r.destination).length;
        document.getElementById('activeBuses').innerText = totalBuses;
    }

    // ====================== SEARCH ======================
    window.searchRoute = function() {
        let src = document.getElementById('citySearch').value.trim();
        let dest = document.getElementById('destSearch').value.trim();
        let msgDiv = document.getElementById('searchMessage');
        if (!src) {
            msgDiv.innerHTML = '<i class="fas fa-info-circle"></i> Please enter source city.';
            return;
        }
        if (!CITY_COORDS[src]) {
            msgDiv.innerHTML = '<i class="fas fa-exclamation-triangle"></i> Source city not found.';
            return;
        }
        let found = routePolylines.filter(item => item.source === src && (dest === '' || item.destination === dest));
        if (found.length === 0) {
            msgDiv.innerHTML = '<i class="fas fa-info-circle"></i> No matching routes.';
            return;
        }
        let first = found[0];
        first.polyline.setStyle({ weight: 6, color: '#000' });
        map.fitBounds(first.polyline.getBounds(), { padding: [50,50] });
        msgDiv.innerHTML = `<i class="fas fa-check-circle" style="color:#10b981;"></i> Found ${found.length} route(s).`;
    };

    window.clearSearch = function() {
        document.getElementById('citySearch').value = '';
        document.getElementById('destSearch').value = '';
        document.getElementById('searchMessage').innerHTML = '';
        renderAll();
    };

    // ====================== ANIMATION ======================
    function startAnimation() {
        if (isAnimating) return;
        isAnimating = true;
        document.getElementById('toggleAnimationBtn').innerHTML = '<i class="fas fa-stop"></i> Stop Animation';
        let busIcon = L.divIcon({ html: '<i class="fas fa-bus" style="font-size: 24px; color: #1e3a8a;"></i>', iconSize: [24,24] });

        animatedMarkers = [];
        routePolylines.forEach(item => {
            let coords = [CITY_COORDS[item.source], CITY_COORDS[item.destination]];
            if (!coords[0] || !coords[1]) return;
            let distance = parseFloat(item.distance) || 100;
            let speed = Math.max(0.002, 0.01 * (200 / distance));
            let marker = L.marker(coords[0], { icon: busIcon }).addTo(map);
            marker.bindPopup(`🚌 ${item.buses.join(', ')}`);
            animatedMarkers.push({
                marker, coords, progress: 0, direction: 1,
                speed: speed,
                item: item
            });
        });

        animationInterval = setInterval(() => {
            animatedMarkers.forEach(am => {
                let prog = am.progress + am.direction * am.speed;
                let dir = am.direction;
                if (prog >= 1) { prog = 1; dir = -1; }
                else if (prog <= 0) { prog = 0; dir = 1; }
                am.progress = prog; am.direction = dir;
                let lat = am.coords[0][0] + (am.coords[1][0] - am.coords[0][0]) * prog;
                let lng = am.coords[0][1] + (am.coords[1][1] - am.coords[0][1]) * prog;
                am.marker.setLatLng([lat, lng]);
            });
        }, animationSpeedBase);
    }

    function stopAnimation() {
        if (animationInterval) clearInterval(animationInterval);
        animatedMarkers.forEach(am => map.removeLayer(am.marker));
        animatedMarkers = [];
        isAnimating = false;
        document.getElementById('toggleAnimationBtn').innerHTML = '<i class="fas fa-play"></i> Start Animation';
    }

    window.toggleAnimation = () => isAnimating ? stopAnimation() : startAnimation();

    // ====================== DARK MODE TOGGLE ======================
    window.toggleDarkMode = function() {
        if (currentLayer === 'satellite') {
            map.removeLayer(satelliteLayer);
            baseLayer.addTo(map);
            currentLayer = 'street';
            document.querySelector('.dark-toggle i').className = 'fas fa-sun';
        } else {
            map.removeLayer(baseLayer);
            satelliteLayer.addTo(map);
            currentLayer = 'satellite';
            document.querySelector('.dark-toggle i').className = 'fas fa-moon';
        }
    };

    // ====================== INIT ======================
    window.onload = function() {
        document.getElementById('loadingOverlay').style.display = 'flex';
        setTimeout(() => {
            initMap();
            document.getElementById('loadingOverlay').style.display = 'none';
        }, 100);
    };

    window.addEventListener('beforeunload', () => { if (animationInterval) clearInterval(animationInterval); });
</script>
</body>
</html>

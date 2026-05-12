<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="header.jsp" %>

<div class="explore-container">
    <div class="explore-header">
        <h1><i class="fas fa-mountain"></i> Explore Ethiopia</h1>
        <p>Discover the breathtaking beauty, history, and culture of Ethiopia – the Land of Origins.</p>
    </div>

    <div class="attractions-grid">
        <!-- 1. Lalibela -->
        <div class="attraction-card">
            <div class="attraction-image">
                <img src="${pageContext.request.contextPath}/images/ethiopia/lalibela.jpg" 
                     alt="Lalibela Churches" loading="lazy"
                     onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'attraction-image-placeholder\'><i class=\'fas fa-church\'></i></div>'">
            </div>
            <div class="attraction-info">
                <h3>Lalibela</h3>
                <p>Famous for its 11 monolithic rock‑hewn churches, often called the "Eighth Wonder of the World".</p>
            </div>
        </div>
        <!-- 2. Simien Mountains -->
        <div class="attraction-card">
            <div class="attraction-image">
                <img src="${pageContext.request.contextPath}/images/ethiopia/simien.jpg" 
                     alt="Simien Mountains" loading="lazy"
                     onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'attraction-image-placeholder\'><i class=\'fas fa-mountain\'></i></div>'">
            </div>
            <div class="attraction-info">
                <h3>Simien Mountains</h3>
                <p>A UNESCO World Heritage Site with dramatic peaks, deep valleys, and unique wildlife.</p>
            </div>
        </div>
        <!-- 3. Danakil Depression -->
        <div class="attraction-card">
            <div class="attraction-image">
                <img src="${pageContext.request.contextPath}/images/ethiopia/danakil.jpg" 
                     alt="Danakil Depression" loading="lazy"
                     onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'attraction-image-placeholder\'><i class=\'fas fa-fire\'></i></div>'">
            </div>
            <div class="attraction-info">
                <h3>Danakil Depression</h3>
                <p>One of the hottest and lowest places on Earth, known for colourful hydrothermal fields.</p>
            </div>
        </div>
        <!-- 4. Axum -->
        <div class="attraction-card">
            <div class="attraction-image">
                <img src="${pageContext.request.contextPath}/images/ethiopia/axum.jpg" 
                     alt="Axum Obelisks" loading="lazy"
                     onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'attraction-image-placeholder\'><i class=\'fas fa-landmark\'></i></div>'">
            </div>
            <div class="attraction-info">
                <h3>Axum</h3>
                <p>Ancient capital of the Aksumite Empire, home to towering obelisks.</p>
            </div>
        </div>
        <!-- 5. Gondar -->
        <div class="attraction-card">
            <div class="attraction-image">
                <img src="${pageContext.request.contextPath}/images/ethiopia/gondar.jpg" 
                     alt="Fasil Ghebbi, Gondar" loading="lazy"
                     onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'attraction-image-placeholder\'><i class=\'fas fa-castle\'></i></div>'">
            </div>
            <div class="attraction-info">
                <h3>Gondar</h3>
                <p>Known as the "Camelot of Africa", featuring the magnificent Fasil Ghebbi castle complex.</p>
            </div>
        </div>
        <!-- 6. Bale Mountains -->
        <div class="attraction-card">
            <div class="attraction-image">
                <img src="${pageContext.request.contextPath}/images/ethiopia/bale.jpg" 
                     alt="Bale Mountains" loading="lazy"
                     onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'attraction-image-placeholder\'><i class=\'fas fa-tree\'></i></div>'">
            </div>
            <div class="attraction-info">
                <h3>Bale Mountains</h3>
                <p>A paradise for hikers, with endemic species like the Ethiopian wolf.</p>
            </div>
        </div>
        <!-- 7. Lake Tana -->
        <div class="attraction-card">
            <div class="attraction-image">
                <img src="${pageContext.request.contextPath}/images/ethiopia/tanatana.jpg" 
                     alt="Lake Tana" loading="lazy"
                     onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'attraction-image-placeholder\'><i class=\'fas fa-water\'></i></div>'">
            </div>
            <div class="attraction-info">
                <h3>Lake Tana</h3>
                <p>Ethiopia’s largest lake, dotted with ancient island monasteries.</p>
            </div>
        </div>
        <!-- 8. Harar Jugol -->
        <div class="attraction-card">
            <div class="attraction-image">
                <img src="${pageContext.request.contextPath}/images/ethiopia/harar.jpg" 
                     alt="Harar Jugol" loading="lazy"
                     onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'attraction-image-placeholder\'><i class=\'fas fa-city\'></i></div>'">
            </div>
            <div class="attraction-info">
                <h3>Harar Jugol</h3>
                <p>A walled city with 82 mosques and vibrant markets, considered the fourth holiest city in Islam.</p>
            </div>
        </div>
        <!-- 9. Omo Valley -->
        <div class="attraction-card">
            <div class="attraction-image">
                <img src="${pageContext.request.contextPath}/images/ethiopia/omo.jpg" 
                     alt="Omo Valley" loading="lazy"
                     onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'attraction-image-placeholder\'><i class=\'fas fa-users\'></i></div>'">
            </div>
            <div class="attraction-info">
                <h3>Omo Valley</h3>
                <p>A cultural mosaic of diverse indigenous tribes, known for unique traditions.</p>
            </div>
        </div>
        <!-- 10. Sof Omar Caves -->
        <div class="attraction-card">
            <div class="attraction-image">
                <img src="${pageContext.request.contextPath}/images/ethiopia/sofomar.jpg" 
                     alt="Sof Omar Caves" loading="lazy"
                     onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'attraction-image-placeholder\'><i class=\'fas fa-cave\'></i></div>'">
            </div>
            <div class="attraction-info">
                <h3>Sof Omar Caves</h3>
                <p>One of the largest and most spectacular cave systems in the world.</p>
            </div>
        </div>
        <!-- 11. Tiya (NEW) -->
        <div class="attraction-card">
            <div class="attraction-image">
                <img src="${pageContext.request.contextPath}/images/ethiopia/tiya.jpg" 
                     alt="Tiya Stelae" loading="lazy"
                     onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'attraction-image-placeholder\'><i class=\'fas fa-monument\'></i></div>'">
            </div>
            <div class="attraction-info">
                <h3>Tiya</h3>
                <p>A UNESCO World Heritage site with mysterious medieval stelae, carved with ancient symbols.</p>
            </div>
        </div>
        <!-- 12. Blue Nile Falls (NEW) -->
        <div class="attraction-card">
            <div class="attraction-image">
                <img src="${pageContext.request.contextPath}/images/ethiopia/bluenile.jpg" 
                     alt="Blue Nile Falls" loading="lazy"
                     onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'attraction-image-placeholder\'><i class=\'fas fa-water\'></i></div>'">
            </div>
            <div class="attraction-info">
                <h3>Blue Nile Falls</h3>
                <p>Known locally as "Tis Abay" (Smoking Water), a spectacular waterfall on the Blue Nile river.</p>
            </div>
        </div>
    </div>
</div>

<style>
    /* Same styles as before – no changes needed */
    .explore-container {
        max-width: 1400px;
        margin: 2rem auto;
        padding: 0 1.5rem;
    }
    .explore-header {
        text-align: center;
        margin-bottom: 3rem;
    }
    .explore-header h1 {
        font-size: 2.5rem;
        color: #1f2937;
        margin-bottom: 0.5rem;
    }
    .explore-header h1 i {
        color: #2563eb;
        margin-right: 0.5rem;
    }
    .explore-header p {
        color: #6b7280;
        font-size: 1.1rem;
    }
    .attractions-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
        gap: 2rem;
    }
    .attraction-card {
        background: white;
        border-radius: 20px;
        overflow: hidden;
        box-shadow: 0 10px 15px -3px rgba(0,0,0,0.05);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        border: 1px solid #f0f2f5;
    }
    .attraction-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
    }
    .attraction-image {
        height: 200px;
        overflow: hidden;
    }
    .attraction-image img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.3s ease;
    }
    .attraction-card:hover .attraction-image img {
        transform: scale(1.05);
    }
    .attraction-image-placeholder {
        height: 200px;
        background: linear-gradient(135deg, #2563eb, #1e40af);
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 4rem;
    }
    .attraction-info {
        padding: 1.5rem;
    }
    .attraction-info h3 {
        font-size: 1.3rem;
        margin-bottom: 0.5rem;
        color: #1f2937;
    }
    .attraction-info p {
        color: #4b5563;
        line-height: 1.5;
    }
    @media (max-width: 768px) {
        .attractions-grid {
            grid-template-columns: 1fr;
        }
        .explore-header h1 { font-size: 2rem; }
    }
</style>

<%@ include file="footer.jsp" %>
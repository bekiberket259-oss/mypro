<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="header.jsp" %>

<%-- Full‑page background (same as dashboard & contact) --%>
<div class="about-background">
    <div class="about-container">
        <div class="about-card">
            <div class="about-header">
                <i class="fas fa-bus"></i>
                <h1>About BusTicket</h1>
            </div>
            <p class="about-tagline">Your trusted partner for comfortable and safe bus travel across Ethiopia.</p>
            
            <div class="about-content">
                <p>Founded in 2026, BusTicket is Ethiopia's leading online bus booking platform. We connect travelers with reliable bus operators, offering a seamless booking experience from search to ticket confirmation.</p>
                
                <h2><i class="fas fa-bullseye"></i> Our Mission</h2>
                <p>To make bus travel accessible, convenient, and secure for every Ethiopian.</p>
                
                <h2><i class="fas fa-eye"></i> Our Vision</h2>
                <p>To become the most trusted transportation network in East Africa.</p>
                
                <h2><i class="fas fa-phone-alt"></i> Contact Us</h2>
                <ul class="contact-list">
                    <li><i class="fas fa-envelope"></i> support@busticket.com</li>
                    <li><i class="fas fa-phone"></i> +251 912 345 678</li>
                    <li><i class="fas fa-map-marker-alt"></i> Bole Road, Addis Ababa, Ethiopia</li>
                </ul>
            </div>
            
            <div class="about-footer">
                <a href="${pageContext.request.contextPath}/" class="btn-primary">
                    <i class="fas fa-arrow-left"></i> Back to Home
                </a>
            </div>
        </div>
    </div>
</div>

<style>
    /* ===== BACKGROUND with gradient + bus image ===== */
    .about-background {
        min-height: calc(100vh - 140px);       /* adjust if header/footer height differs */
        background: linear-gradient(135deg, rgba(37, 99, 235, 0.2), rgba(255, 255, 255, 0.85)),
                    url('https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=1600&auto=format&fit=crop') center/cover no-repeat;
        background-attachment: fixed;
        padding: 3rem 0;
    }

    /* ── Container & Card (unchanged styling, now over the background) ── */
    .about-container {
        max-width: 800px;
        margin: 0 auto;
        padding: 0 1.5rem;
    }

    .about-card {
        background: white;
        border-radius: 28px;
        padding: 2.5rem;
        box-shadow: 0 20px 40px -12px rgba(0,0,0,0.1);
        border: 1px solid #f0f2f5;
    }

    .about-header {
        text-align: center;
        margin-bottom: 1.5rem;
    }
    .about-header i {
        font-size: 3.5rem;
        color: #2563eb;
        margin-bottom: 0.5rem;
    }
    .about-header h1 {
        font-size: 2.5rem;
        color: #1f2937;
    }

    .about-tagline {
        text-align: center;
        font-size: 1.2rem;
        color: #6b7280;
        margin-bottom: 2rem;
        font-style: italic;
    }

    .about-content p {
        color: #374151;
        line-height: 1.7;
        margin-bottom: 1.5rem;
    }
    .about-content h2 {
        font-size: 1.5rem;
        color: #1f2937;
        margin: 2rem 0 1rem;
        display: flex;
        align-items: center;
        gap: 0.75rem;
    }
    .about-content h2 i {
        color: #2563eb;
        width: 24px;
    }

    .contact-list {
        list-style: none;
        padding: 0;
    }
    .contact-list li {
        padding: 0.5rem 0;
        display: flex;
        align-items: center;
        gap: 0.75rem;
        color: #374151;
    }
    .contact-list i {
        color: #2563eb;
        width: 20px;
    }

    .about-footer {
        margin-top: 2.5rem;
        text-align: center;
    }

    .btn-primary {
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        background: #2563eb;
        color: white;
        padding: 0.75rem 2rem;
        border-radius: 40px;
        text-decoration: none;
        font-weight: 600;
        transition: all 0.2s;
    }
    .btn-primary:hover {
        background: #1d4ed8;
        transform: translateY(-2px);
    }

    @media (max-width: 600px) {
        .about-background {
            padding: 2rem 0;
        }
        .about-card {
            padding: 1.5rem;
        }
        .about-header h1 {
            font-size: 2rem;
        }
    }
</style>

<%@ include file="footer.jsp" %>
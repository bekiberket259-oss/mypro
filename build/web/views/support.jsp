<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="header.jsp" %>

<%-- Full‑page background (same as other pages) --%>
<div class="support-background">
    <div class="support-container">
        <div class="support-card">
            <div class="support-header">
                <i class="fas fa-headset"></i>
                <h1>Customer Support</h1>
            </div>
            <p class="support-subtitle">We're here to help you 24/7</p>

            <div class="support-content">
                <div class="support-section">
                    <h2><i class="fas fa-phone-alt"></i> Call Us</h2>
                    <p><strong>+251 912 345 678</strong></p>
                    <p>Available 24 hours a day, 7 days a week</p>
                </div>

                <div class="support-section">
                    <h2><i class="fas fa-envelope"></i> Email Us</h2>
                    <p><strong>support@busticket.com</strong></p>
                    <p>We'll respond within 2 hours</p>
                </div>

                <div class="support-section">
                    <h2><i class="fab fa-whatsapp"></i> WhatsApp</h2>
                    <p><strong>+251 912 345 678</strong></p>
                    <p>Chat with our support team instantly</p>
                </div>

                <div class="support-section">
                    <h2><i class="fas fa-map-marker-alt"></i> Visit Us</h2>
                    <p>Bole Road, Addis Ababa, Ethiopia</p>
                    <p>Monday - Friday, 8:00 AM - 8:00 PM</p>
                </div>
            </div>

            <div class="support-footer">
                <a href="${pageContext.request.contextPath}/dashboard" class="btn-primary">
                    <i class="fas fa-arrow-left"></i> Back to Dashboard
                </a>
            </div>
        </div>
    </div>
</div>

<style>
    /* ===== BACKGROUND with gradient + bus image ===== */
    .support-background {
        min-height: calc(100vh - 140px);      /* adjust if header/footer height differs */
        background: linear-gradient(135deg, rgba(37, 99, 235, 0.2), rgba(255, 255, 255, 0.85)),
                    url('https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=1600&auto=format&fit=crop') center/cover no-repeat;
        background-attachment: fixed;
        padding: 3rem 0;
    }

    /* ── Container & Card (unchanged, now over the background) ── */
    .support-container {
        max-width: 900px;
        margin: 0 auto;
        padding: 0 1.5rem;
    }

    .support-card {
        background: white;
        border-radius: 28px;
        padding: 2.5rem;
        box-shadow: 0 20px 40px -12px rgba(0,0,0,0.1);
        border: 1px solid #f0f2f5;
    }

    .support-header {
        text-align: center;
        margin-bottom: 1rem;
    }
    .support-header i {
        font-size: 3.5rem;
        color: #2563eb;
        margin-bottom: 0.5rem;
    }
    .support-header h1 {
        font-size: 2.5rem;
        color: #1f2937;
    }

    .support-subtitle {
        text-align: center;
        font-size: 1.1rem;
        color: #6b7280;
        margin-bottom: 2.5rem;
    }

    .support-content {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 2rem;
    }

    .support-section {
        background: #fafbfc;
        border-radius: 20px;
        padding: 1.5rem;
        border: 1px solid #eef2f6;
    }
    .support-section h2 {
        font-size: 1.3rem;
        color: #1f2937;
        margin-bottom: 1rem;
        display: flex;
        align-items: center;
        gap: 0.75rem;
    }
    .support-section h2 i {
        color: #2563eb;
        width: 24px;
    }
    .support-section p {
        color: #374151;
        line-height: 1.7;
        margin-bottom: 0.5rem;
    }
    .support-section strong {
        font-size: 1.2rem;
        color: #2563eb;
    }

    .support-footer {
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
        .support-background {
            padding: 2rem 0;
        }
        .support-content {
            grid-template-columns: 1fr;
        }
        .support-card {
            padding: 1.5rem;
        }
        .support-header h1 {
            font-size: 2rem;
        }
    }
</style>

<%@ include file="footer.jsp" %>
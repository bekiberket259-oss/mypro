<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="header.jsp" %>

<%-- Full‑page background (same as dashboard, contact, about) --%>
<div class="faq-background">
    <div class="faq-container">
        <div class="faq-card">
            <div class="faq-header">
                <i class="fas fa-question-circle"></i>
                <h1>Frequently Asked Questions</h1>
            </div>
            <p class="faq-subtitle">Find answers to common questions about our bus booking service.</p>

            <div class="faq-content">
                <div class="faq-item">
                    <h2><i class="fas fa-ticket-alt"></i> How do I book a ticket?</h2>
                    <p>Use the search form on the homepage, select your route and date, choose seats, and complete the payment simulation.</p>
                </div>
                <div class="faq-item">
                    <h2><i class="fas fa-credit-card"></i> Is my payment secure?</h2>
                    <p>This is a simulation project. No real payments are processed. In a production environment, we would use industry‑standard encryption.</p>
                </div>
                <div class="faq-item">
                    <h2><i class="fas fa-ban"></i> Can I cancel my booking?</h2>
                    <p>Yes, confirmed bookings can be cancelled from "My Bookings" page. Refunds are subject to our refund policy.</p>
                </div>
                <div class="faq-item">
                    <h2><i class="fas fa-chair"></i> How do I choose my seat?</h2>
                    <p>After selecting a bus, you will see an interactive seat map. Click on available (green) seats to select them.</p>
                </div>
                <div class="faq-item">
                    <h2><i class="fas fa-print"></i> Do I need to print my ticket?</h2>
                    <p>You can print the ticket or show the digital version on your phone. Both are accepted.</p>
                </div>
                <div class="faq-item">
                    <h2><i class="fas fa-clock"></i> What time should I arrive?</h2>
                    <p>Please arrive at the departure point at least 30 minutes before the scheduled departure time.</p>
                </div>
            </div>

            <div class="faq-footer">
                <a href="${pageContext.request.contextPath}/" class="btn-primary">
                    <i class="fas fa-arrow-left"></i> Back to Home
                </a>
            </div>
        </div>
    </div>
</div>

<style>
    /* ===== BACKGROUND with gradient + bus image ===== */
    .faq-background {
        min-height: calc(100vh - 140px);        /* adjust if header/footer height differs */
        background: linear-gradient(135deg, rgba(37, 99, 235, 0.2), rgba(255, 255, 255, 0.85)),
                    url('https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=1600&auto=format&fit=crop') center/cover no-repeat;
        background-attachment: fixed;
        padding: 3rem 0;
    }

    /* ── Container & Card (unchanged styling, now over the background) ── */
    .faq-container {
        max-width: 800px;
        margin: 0 auto;
        padding: 0 1.5rem;
    }

    .faq-card {
        background: white;
        border-radius: 28px;
        padding: 2.5rem;
        box-shadow: 0 20px 40px -12px rgba(0,0,0,0.1);
        border: 1px solid #f0f2f5;
    }

    .faq-header {
        text-align: center;
        margin-bottom: 1rem;
    }
    .faq-header i {
        font-size: 3rem;
        color: #2563eb;
        margin-bottom: 0.5rem;
    }
    .faq-header h1 {
        font-size: 2.2rem;
        color: #1f2937;
    }

    .faq-subtitle {
        text-align: center;
        color: #6b7280;
        margin-bottom: 2.5rem;
    }

    .faq-item {
        margin-bottom: 2rem;
        border-bottom: 1px solid #f0f2f5;
        padding-bottom: 1.5rem;
    }
    .faq-item:last-child {
        border-bottom: none;
    }
    .faq-item h2 {
        font-size: 1.3rem;
        color: #1f2937;
        margin-bottom: 0.5rem;
        display: flex;
        align-items: center;
        gap: 0.75rem;
    }
    .faq-item h2 i {
        color: #2563eb;
        width: 24px;
    }
    .faq-item p {
        color: #374151;
        line-height: 1.7;
        margin-left: 2.5rem;
    }

    .faq-footer {
        margin-top: 2rem;
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
        .faq-background {
            padding: 2rem 0;
        }
        .faq-card {
            padding: 1.5rem;
        }
        .faq-header h1 {
            font-size: 1.8rem;
        }
    }
</style>

<%@ include file="footer.jsp" %>
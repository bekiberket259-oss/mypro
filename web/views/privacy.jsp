<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="header.jsp" %>

<%-- Full‑page background (same as other pages) --%>
<div class="legal-background">
    <div class="legal-container">
        <div class="legal-card">
            <div class="legal-header">
                <i class="fas fa-shield-alt"></i>
                <h1>Privacy Policy</h1>
            </div>
            <p class="last-updated">Last updated: April 2026</p>
            
            <div class="legal-content">
                <h2>1. Information We Collect</h2>
                <p>We collect personal information you provide during registration and booking, including name, email, phone number, and payment details.</p>
                
                <h2>2. How We Use Your Information</h2>
                <p>Your information is used to process bookings, send confirmations, provide customer support, and improve our services.</p>
                
                <h2>3. Data Security</h2>
                <p>We implement industry‑standard security measures to protect your personal data. All passwords are encrypted using BCrypt.</p>
                
                <h2>4. Third‑Party Sharing</h2>
                <p>We do not sell or rent your personal information. Data may be shared with bus operators solely for fulfilling your booking.</p>
                
                <h2>5. Cookies</h2>
                <p>We use cookies to enhance your browsing experience and remember your preferences.</p>
                
                <h2>6. Your Rights</h2>
                <p>You can access, update, or delete your personal information by contacting us.</p>
                
                <h2>7. Contact</h2>
                <p>For privacy concerns, email us at <a href="mailto:privacy@busticket.com">privacy@busticket.com</a>.</p>
            </div>
            
            <div class="legal-footer">
                <a href="${pageContext.request.contextPath}/" class="btn-primary">
                    <i class="fas fa-arrow-left"></i> Back to Home
                </a>
            </div>
        </div>
    </div>
</div>

<style>
    /* ===== BACKGROUND with gradient + bus image ===== */
    .legal-background {
        min-height: calc(100vh - 140px);        /* adjust if header/footer height differs */
        background: linear-gradient(135deg, rgba(37, 99, 235, 0.2), rgba(255, 255, 255, 0.85)),
                    url('https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=1600&auto=format&fit=crop') center/cover no-repeat;
        background-attachment: fixed;
        padding: 3rem 0;
    }

    /* ── Container & Card (unchanged styling, now over the background) ── */
    .legal-container {
        max-width: 800px;
        margin: 0 auto;
        padding: 0 1.5rem;
    }

    .legal-card {
        background: white;
        border-radius: 28px;
        padding: 2.5rem;
        box-shadow: 0 20px 40px -12px rgba(0,0,0,0.1);
        border: 1px solid #f0f2f5;
    }

    .legal-header {
        text-align: center;
        margin-bottom: 1rem;
    }
    .legal-header i {
        font-size: 3rem;
        color: #2563eb;
        margin-bottom: 0.5rem;
    }
    .legal-header h1 {
        font-size: 2.2rem;
        color: #1f2937;
    }

    .last-updated {
        text-align: center;
        color: #6b7280;
        font-size: 0.9rem;
        margin-bottom: 2rem;
    }

    .legal-content h2 {
        font-size: 1.3rem;
        color: #1f2937;
        margin: 1.8rem 0 0.8rem;
    }
    .legal-content p {
        color: #374151;
        line-height: 1.7;
        margin-bottom: 1rem;
    }

    .legal-footer {
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
        .legal-background {
            padding: 2rem 0;
        }
        .legal-card {
            padding: 1.5rem;
        }
        .legal-header h1 {
            font-size: 1.8rem;
        }
    }
</style>

<%@ include file="footer.jsp" %>
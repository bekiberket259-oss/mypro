<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="header.jsp" %>

<%-- Background Wrapper with Gradient + Image --%>
<div class="contact-background">
    <div class="contact-container">
        <div class="contact-card">
            <div class="contact-header">
                <i class="fas fa-headset"></i>
                <h1>Contact Us</h1>
            </div>
            <p class="contact-tagline">We're here to help with any questions or concerns.</p>

            <!-- Display success or error messages -->
            <c:if test="${not empty success}">
                <div class="alert success">
                    <i class="fas fa-check-circle"></i> ${success}
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert error">
                    <i class="fas fa-exclamation-circle"></i> ${error}
                </div>
            </c:if>

            <div class="contact-content">
                <div class="contact-info">
                    <h2><i class="fas fa-info-circle"></i> Customer Support</h2>
                    <ul class="info-list">
                        <li><i class="fas fa-phone-alt"></i> <strong>Phone:</strong> +251 912 345 678</li>
                        <li><i class="fas fa-envelope"></i> <strong>Email:</strong> support@busticket.com</li>
                        <li><i class="fas fa-map-marker-alt"></i> <strong>Address:</strong> Bole Road, Addis Ababa, Ethiopia</li>
                        <li><i class="far fa-clock"></i> <strong>Hours:</strong> 24/7 Customer Support</li>
                    </ul>
                </div>

                <div class="contact-form">
                    <h2><i class="fas fa-paper-plane"></i> Send us a message</h2>
                    <form action="${pageContext.request.contextPath}/contact" method="post">
                        <div class="form-group">
                            <label for="name">Your Name *</label>
                            <input type="text" id="name" name="name" placeholder="Enter your name" required>
                        </div>
                        <div class="form-group">
                            <label for="email">Email Address *</label>
                            <input type="email" id="email" name="email" placeholder="you@example.com" required>
                        </div>
                        <div class="form-group">
                            <label for="subject">Subject (optional)</label>
                            <input type="text" id="subject" name="subject" placeholder="What is this about?">
                        </div>
                        <div class="form-group">
                            <label for="message">Message *</label>
                            <textarea id="message" name="message" rows="5" placeholder="Type your message here..." required></textarea>
                        </div>
                        <button type="submit" class="btn-primary">
                            <i class="fas fa-paper-plane"></i> Send Message
                        </button>
                    </form>
                </div>
            </div>

            <div class="contact-footer">
                <a href="${pageContext.request.contextPath}/" class="btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to Home
                </a>
            </div>
        </div>
    </div>
</div>

<style>
    /* ===== BACKGROUND WRAPPER ===== */
    .contact-background {
        min-height: calc(100vh - 140px);      /* Adjust if header/footer height differs */
        background: linear-gradient(135deg, rgba(37, 99, 235, 0.2), rgba(255, 255, 255, 0.85)),
                    url('https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=1600&auto=format&fit=crop') center/cover no-repeat;
        background-attachment: fixed;
        padding: 3rem 0;                      /* Vertical spacing for the card */
    }

    .contact-container {
        max-width: 1000px;
        margin: 0 auto;
        padding: 0 1.5rem;
    }

    .contact-card {
        background: white;
        border-radius: 28px;
        padding: 2.5rem;
        box-shadow: 0 20px 40px -12px rgba(0,0,0,0.1);
        border: 1px solid #f0f2f5;
    }

    .contact-header {
        text-align: center;
        margin-bottom: 1.5rem;
    }
    .contact-header i {
        font-size: 3.5rem;
        color: #2563eb;
        margin-bottom: 0.5rem;
    }
    .contact-header h1 {
        font-size: 2.5rem;
        color: #1f2937;
    }
    .contact-tagline {
        text-align: center;
        font-size: 1.1rem;
        color: #6b7280;
        margin-bottom: 2.5rem;
    }

    .alert {
        padding: 1rem;
        border-radius: 12px;
        margin-bottom: 1.5rem;
        display: flex;
        align-items: center;
        gap: 0.75rem;
        font-weight: 500;
    }
    .alert.success {
        background: #d1fae5;
        color: #065f46;
        border-left: 4px solid #10b981;
    }
    .alert.error {
        background: #fee2e2;
        color: #991b1b;
        border-left: 4px solid #ef4444;
    }

    .contact-content {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 2.5rem;
    }
    .contact-info h2, .contact-form h2 {
        font-size: 1.4rem;
        color: #1f2937;
        margin-bottom: 1.5rem;
        display: flex;
        align-items: center;
        gap: 0.75rem;
    }
    .contact-info h2 i, .contact-form h2 i {
        color: #2563eb;
        width: 24px;
    }
    .info-list {
        list-style: none;
        padding: 0;
    }
    .info-list li {
        padding: 0.75rem 0;
        display: flex;
        align-items: center;
        gap: 1rem;
        color: #374151;
        border-bottom: 1px solid #f0f2f5;
    }
    .info-list li i {
        color: #2563eb;
        width: 20px;
        text-align: center;
    }

    .form-group {
        margin-bottom: 1.5rem;
    }
    .form-group label {
        display: block;
        margin-bottom: 0.5rem;
        font-weight: 500;
        color: #374151;
    }
    .form-group input, .form-group textarea {
        width: 100%;
        padding: 0.75rem 1rem;
        border: 1.5px solid #e5e7eb;
        border-radius: 12px;
        font-size: 1rem;
        transition: border-color 0.2s;
        font-family: inherit;
    }
    .form-group input:focus, .form-group textarea:focus {
        outline: none;
        border-color: #2563eb;
        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
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
        border: none;
        cursor: pointer;
        transition: all 0.2s;
        font-size: 1rem;
    }
    .btn-primary:hover {
        background: #1d4ed8;
        transform: translateY(-2px);
    }

    .btn-secondary {
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        background: white;
        color: #1f2937;
        padding: 0.75rem 2rem;
        border-radius: 40px;
        text-decoration: none;
        font-weight: 600;
        border: 1px solid #d1d5db;
        transition: all 0.2s;
    }
    .btn-secondary:hover {
        background: #f3f4f6;
    }

    .contact-footer {
        margin-top: 2.5rem;
        text-align: center;
    }

    @media (max-width: 768px) {
        .contact-background {
            padding: 2rem 0;
        }
        .contact-content {
            grid-template-columns: 1fr;
            gap: 2rem;
        }
        .contact-card {
            padding: 1.5rem;
        }
        .contact-header h1 {
            font-size: 2rem;
        }
    }
</style>

<%@ include file="footer.jsp" %>
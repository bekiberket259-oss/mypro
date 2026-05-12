<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    </main> <!-- Closes the <main> tag opened in header.jsp -->

    <!-- Footer Section -->
    <footer class="footer">
        <div class="footer-content">
            <div class="footer-section">
                <h3><i class="fas fa-bus"></i> BusTicket</h3>
                <p>Your trusted partner for comfortable and safe bus travel across Ethiopia.</p>
                <div class="social-links">
                    <a href="#" aria-label="Facebook"><i class="fab fa-facebook-f"></i></a>
                    <a href="#" aria-label="Twitter"><i class="fab fa-twitter"></i></a>
                    <a href="#" aria-label="Instagram"><i class="fab fa-instagram"></i></a>
                    <a href="#" aria-label="LinkedIn"><i class="fab fa-linkedin-in"></i></a>
                </div>
            </div>
            
            <div class="footer-section">
                <h4>Quick Links</h4>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/">Home</a></li>
                    <li><a href="${pageContext.request.contextPath}/search">Search Buses</a></li>
                    <li><a href="${pageContext.request.contextPath}/mybookings">My Bookings</a></li>
                    <li><a href="${pageContext.request.contextPath}/about">About Us</a></li>
                    <li><a href="${pageContext.request.contextPath}/contact">Contact</a></li>
                </ul>
            </div>
            
            <div class="footer-section">
                <h4>Customer Support</h4>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/faq">FAQ</a></li>
                    <li><a href="${pageContext.request.contextPath}/terms">Terms of Service</a></li>
                    <li><a href="${pageContext.request.contextPath}/privacy">Privacy Policy</a></li>
                    <li><a href="${pageContext.request.contextPath}/refund">Refund Policy</a></li>
                </ul>
            </div>
            
            <div class="footer-section">
                <h4>Contact Info</h4>
                <ul class="contact-info">
                    <li><i class="fas fa-phone-alt"></i> +251 912 345 678</li>
                    <li><i class="fas fa-envelope"></i> support@busticket.com</li>
                    <li><i class="fas fa-map-marker-alt"></i> Bole Road, Addis Ababa, Ethiopia</li>
                    <li><i class="far fa-clock"></i> 24/7 Customer Support</li>
                </ul>
            </div>
        </div>
        
        <div class="footer-bottom">
            <p>&copy; 2026 BusTicket. All rights reserved.</p>
            <p class="footer-credit">Made with <i class="fas fa-heart" style="color: #ef4444;"></i> for safe travels</p>
        </div>
    </footer>

    <!-- Back to Top Button -->
    <button id="backToTop" class="back-to-top" title="Back to Top">
        <i class="fas fa-arrow-up"></i>
    </button>

    <!-- Global JavaScript -->
    <script src="${pageContext.request.contextPath}/js/script.js"></script>
    
    <!-- Page-specific JavaScript can be included after this line -->
</body>
</html>

<%-- Footer styling with corrected white text --%>
<style>
    .footer {
        background: #1e3a8a;
        color: #ffffff;
        padding: 4rem 2rem 1rem;
        margin-top: 3rem;
    }
    .footer a {
        color: #dbeafe;
        transition: color 0.2s;
    }
    .footer a:hover {
        color: #ffffff;
    }
    .footer h3, .footer h4 {
        color: #ffffff;
    }
    .footer p {
        color: #ffffff;          /* Ensures description text is white */
    }
    .footer .social-links a {
        background: rgba(255,255,255,0.15);
        color: #ffffff;
        width: 36px;
        height: 36px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        margin-right: 0.5rem;
        transition: background 0.2s;
    }
    .footer .social-links a:hover {
        background: rgba(255,255,255,0.25);
    }
    .footer .contact-info li i {
        color: #93c5fd;
        margin-right: 0.5rem;
    }
    .footer-bottom {
        border-top: 1px solid rgba(255,255,255,0.2);
        margin-top: 2rem;
        padding-top: 1.5rem;
        text-align: center;
        font-size: 0.9rem;
        color: #cbd5e1;
    }
    .footer-bottom p {
        margin: 0.3rem 0;
        color: #ffffff;          /* Makes copyright text pure white */
    }
    .footer ul {
        list-style: none;
        padding: 0;
    }
    .footer ul li {
        margin-bottom: 0.5rem;
    }
    .footer-content {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 2rem;
        max-width: 1200px;
        margin: 0 auto;
    }
    @media (max-width: 600px) {
        .footer-content {
            grid-template-columns: 1fr;
        }
    }
</style>
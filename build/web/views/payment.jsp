<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="header.jsp" %>

<%-- Retrieve booking summary from session (set by BookingServlet) --%>
<c:set var="bookingId" value="${sessionScope.lastBookingId}" />
<c:set var="totalFare" value="${sessionScope.paymentAmount}" />
<c:set var="routeInfo" value="${sessionScope.paymentRoute}" />
<c:set var="seatList" value="${sessionScope.paymentSeats}" />

<%-- Background Wrapper with Gradient + Image --%>
<div class="payment-background">
    <div class="payment-wrapper">
        <div class="payment-card">
            <%-- Back button --%>
            <a href="${pageContext.request.contextPath}/booking?routeId=${param.routeId}&date=${param.date}" class="back-link">
                <i class="fas fa-arrow-left"></i> Back to Seats
            </a>

            <h2 class="payment-title">
                <i class="fas fa-lock"></i> Secure Payment
            </h2>

            <%-- Mini Booking Summary --%>
            <div class="booking-summary-mini">
                <div class="summary-row highlight">
                    <span class="summary-label">Route</span>
                    <span class="summary-value"><c:out value="${routeInfo}" /></span>
                </div>
                <div class="summary-row">
                    <span class="summary-label">Seats</span>
                    <span class="summary-value"><c:out value="${seatList}" /></span>
                </div>
                <div class="summary-row">
                    <span class="summary-label">Booking ID</span>
                    <span class="summary-value"><c:out value="${bookingId}" /></span>
                </div>
            </div>

            <%-- Prominent Total Amount --%>
            <div class="payment-amount">
                <span class="amount-label">Total Amount</span>
                <span class="amount-value">
                    ETB <fmt:formatNumber value="${totalFare}" pattern="#,##0.00" />
                </span>
            </div>

            <form action="${pageContext.request.contextPath}/process_payment" method="post" id="paymentForm">
                <input type="hidden" name="bookingId" value="<c:out value='${bookingId}'/>">

                <div class="payment-methods">
                    <label class="payment-option">
                        <input type="radio" name="method" value="Telebirr" checked>
                        <span class="option-content">
                            <i class="fas fa-mobile-alt"></i>
                            <span class="option-text">Telebirr</span>
                        </span>
                    </label>
                    <label class="payment-option">
                        <input type="radio" name="method" value="Card">
                        <span class="option-content">
                            <i class="far fa-credit-card"></i>
                            <span class="option-text">Credit / Debit Card</span>
                        </span>
                    </label>
                    <label class="payment-option">
                        <input type="radio" name="method" value="PayPal">
                        <span class="option-content">
                            <i class="fab fa-paypal"></i>
                            <span class="option-text">PayPal</span>
                        </span>
                    </label>
                </div>

                <%-- Telebirr Phone Field --%>
                <div id="telebirrFields" class="payment-field" style="display: block;">
                    <label for="telebirrPhone">
                        <i class="fas fa-phone"></i> Ethiopian Phone Number
                    </label>
                    <input type="tel" id="telebirrPhone" name="phone" 
                           placeholder="09xxxxxxxx" pattern="09[0-9]{8}" 
                           value="<c:out value='${sessionScope.user.phone}'/>" required>
                    <div class="field-error" id="phoneError"></div>
                    <p class="field-hint">Enter your Telebirr registered number</p>
                </div>

                <%-- Card Fields --%>
                <div id="cardFields" class="payment-field" style="display: none;">
                    <label for="cardNumber"><i class="far fa-credit-card"></i> Card Number</label>
                    <input type="text" id="cardNumber" name="cardNumber" placeholder="1234 5678 9012 3456" disabled>
                    <div class="card-row">
                        <input type="text" name="expiry" placeholder="MM/YY" disabled>
                        <input type="text" name="cvv" placeholder="CVV" disabled>
                    </div>
                    <p class="field-hint">Demo: No real card data is processed</p>
                </div>

                <%-- PayPal Fields --%>
                <div id="paypalFields" class="payment-field" style="display: none;">
                    <p class="paypal-message">
                        <i class="fab fa-paypal"></i> You will be redirected to PayPal to complete your payment.
                    </p>
                </div>

                <button type="submit" id="payButton" class="btn-pay">
                    <i class="fas fa-lock"></i> Pay ETB <fmt:formatNumber value="${totalFare}" pattern="#,##0.00" />
                </button>

                <p class="secure-text">
                    <i class="fas fa-shield-alt"></i> Secure checkout • Demo only • No real transaction
                </p>
            </form>
        </div>
    </div>
</div>

<!-- Loading Overlay -->
<div id="loadingOverlay" class="loading-overlay" style="display: none;">
    <div class="loading-spinner">
        <i class="fas fa-spinner fa-pulse"></i>
        <p>Processing payment...</p>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        var paymentForm = document.getElementById('paymentForm');
        var payButton = document.getElementById('payButton');
        var methodRadios = document.querySelectorAll('input[name="method"]');
        var telebirrFields = document.getElementById('telebirrFields');
        var cardFields = document.getElementById('cardFields');
        var paypalFields = document.getElementById('paypalFields');
        var phoneInput = document.getElementById('telebirrPhone');
        var phoneError = document.getElementById('phoneError');
        var loadingOverlay = document.getElementById('loadingOverlay');

        function updateActiveOption() {
            var selectedMethod = document.querySelector('input[name="method"]:checked').value;
            var options = document.querySelectorAll('.payment-option');
            for (var i = 0; i < options.length; i++) {
                options[i].classList.remove('active');
            }
            for (var i = 0; i < options.length; i++) {
                var radio = options[i].querySelector('input');
                if (radio && radio.value === selectedMethod) {
                    options[i].classList.add('active');
                    break;
                }
            }
        }

        function updatePaymentFields() {
            var selectedMethod = document.querySelector('input[name="method"]:checked').value;
            
            var fields = [telebirrFields, cardFields, paypalFields];
            for (var i = 0; i < fields.length; i++) {
                var field = fields[i];
                field.style.opacity = '0';
                field.style.transform = 'translateY(10px)';
                setTimeout((function(f) {
                    return function() {
                        if (f.style.opacity === '0') {
                            f.style.display = 'none';
                        }
                    };
                })(field), 200);
            }
            
            var allInputs = document.querySelectorAll('.payment-field input');
            for (var i = 0; i < allInputs.length; i++) {
                allInputs[i].disabled = true;
            }
            
            var activeField;
            if (selectedMethod === 'Telebirr') activeField = telebirrFields;
            else if (selectedMethod === 'Card') activeField = cardFields;
            else if (selectedMethod === 'PayPal') activeField = paypalFields;
            
            if (activeField) {
                activeField.style.display = 'block';
                activeField.offsetHeight;
                activeField.style.opacity = '1';
                activeField.style.transform = 'translateY(0)';
                var activeInputs = activeField.querySelectorAll('input');
                for (var i = 0; i < activeInputs.length; i++) {
                    activeInputs[i].disabled = false;
                }
            }
            
            phoneError.textContent = '';
            phoneInput.classList.remove('input-error');
            updateActiveOption();
        }

        for (var i = 0; i < methodRadios.length; i++) {
            methodRadios[i].addEventListener('change', updatePaymentFields);
        }

        paymentForm.addEventListener('submit', function(e) {
            var selectedMethod = document.querySelector('input[name="method"]:checked').value;
            var isValid = true;
            
            if (selectedMethod === 'Telebirr') {
                var phoneRegex = /^09[0-9]{8}$/;
                if (!phoneRegex.test(phoneInput.value)) {
                    e.preventDefault();
                    phoneError.textContent = 'Please enter a valid Ethiopian phone number (09xxxxxxxx).';
                    phoneInput.classList.add('input-error');
                    isValid = false;
                } else {
                    phoneError.textContent = '';
                    phoneInput.classList.remove('input-error');
                }
            }
            
            if (isValid) {
                loadingOverlay.style.display = 'flex';
                payButton.disabled = true;
                payButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
            }
        });

        phoneInput.addEventListener('input', function() {
            if (this.value.length > 0 && !this.value.match(/^09[0-9]{8}$/)) {
                phoneError.textContent = 'Phone must start with 09 and have 10 digits.';
                this.classList.add('input-error');
            } else {
                phoneError.textContent = '';
                this.classList.remove('input-error');
            }
        });

        updatePaymentFields();
        document.querySelector('.payment-card').style.animation = 'fadeInUp 0.4s ease';
    });
</script>

<style>
    /* ===== BACKGROUND WRAPPER ===== */
    .payment-background {
        min-height: calc(100vh - 140px);
        background: linear-gradient(135deg, rgba(37, 99, 235, 0.2), rgba(255, 255, 255, 0.85)),
                    url('https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=1600&auto=format&fit=crop') center/cover no-repeat;
        background-attachment: fixed;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 2rem 0;
    }

    /* Make card semi-transparent with blur */
    .payment-card {
        background: rgba(255, 255, 255, 0.95) !important;
        backdrop-filter: blur(8px);
        border: 1px solid rgba(255, 255, 255, 0.3);
    }

    .booking-summary-mini {
        background: rgba(249, 250, 251, 0.7) !important;
        backdrop-filter: blur(4px);
    }

    .payment-option {
        background: rgba(249, 250, 251, 0.7) !important;
        backdrop-filter: blur(4px);
    }

    .payment-option.active {
        background: rgba(239, 246, 255, 0.9) !important;
    }

    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(15px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .payment-wrapper {
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 2rem;
        width: 100%;
    }

    .payment-card {
        max-width: 480px;
        width: 100%;
        border-radius: 24px;
        padding: 2rem;
        box-shadow: 0 20px 35px -8px rgba(0, 0, 0, 0.1);
        animation: fadeInUp 0.4s ease;
    }

    .back-link {
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        color: #6b7280;
        text-decoration: none;
        font-size: 0.9rem;
        margin-bottom: 1.5rem;
        transition: color 0.2s;
    }

    .back-link:hover {
        color: #2563eb;
    }

    .payment-title {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        font-size: 1.5rem;
        color: #1f2937;
        margin-bottom: 1.5rem;
    }

    .payment-title i {
        color: #2563eb;
    }

    .booking-summary-mini {
        border-radius: 16px;
        padding: 1.25rem;
        margin-bottom: 1.5rem;
        border: 1px solid rgba(229, 231, 235, 0.5);
    }

    .summary-row {
        display: flex;
        justify-content: space-between;
        padding: 0.4rem 0;
    }

    .summary-row.highlight .summary-value {
        font-weight: 700;
        color: #2563eb;
    }

    .summary-label {
        color: #6b7280;
        font-size: 0.9rem;
    }

    .summary-value {
        font-weight: 600;
        color: #1f2937;
    }

    .payment-amount {
        text-align: center;
        margin-bottom: 2rem;
        border-top: 1px solid rgba(229, 231, 235, 0.5);
        padding-top: 1.5rem;
    }

    .amount-label {
        display: block;
        font-size: 0.9rem;
        text-transform: uppercase;
        letter-spacing: 1px;
        color: #6b7280;
        margin-bottom: 0.5rem;
    }

    .amount-value {
        font-size: 2.8rem;
        font-weight: 700;
        color: #16a34a;
        letter-spacing: 1px;
    }

    .payment-methods {
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
        margin-bottom: 1.5rem;
    }

    .payment-option {
        display: flex;
        align-items: center;
        padding: 1rem 1.25rem;
        border: 2px solid rgba(229, 231, 235, 0.8);
        border-radius: 14px;
        cursor: pointer;
        transition: all 0.2s ease;
    }

    .payment-option:active {
        transform: scale(0.98);
    }

    .payment-option:hover {
        border-color: #bdd3ff;
        background: rgba(240, 247, 255, 0.9) !important;
    }

    .payment-option.active {
        border-color: #2563eb;
        box-shadow: 0 4px 12px rgba(37, 99, 235, 0.1);
    }

    .payment-option input {
        margin-right: 1rem;
        accent-color: #2563eb;
        width: 18px;
        height: 18px;
    }

    .option-content {
        display: flex;
        align-items: center;
        gap: 1rem;
        flex: 1;
    }

    .option-content i {
        font-size: 1.4rem;
        color: #2563eb;
        width: 28px;
        text-align: center;
    }

    .option-text {
        font-weight: 500;
        color: #1f2937;
    }

    .payment-field {
        margin-bottom: 1.5rem;
        transition: opacity 0.2s ease, transform 0.2s ease;
        opacity: 0;
        transform: translateY(10px);
    }

    .payment-field label {
        display: block;
        margin-bottom: 0.5rem;
        font-weight: 500;
        color: #374151;
    }

    .payment-field input {
        width: 100%;
        padding: 0.9rem 1rem;
        border: 1.5px solid #e5e7eb;
        border-radius: 12px;
        font-size: 1rem;
        transition: border-color 0.2s, box-shadow 0.2s;
        background: rgba(255, 255, 255, 0.9);
    }

    .payment-field input:focus {
        outline: none;
        border-color: #2563eb;
        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
        background: white;
    }

    .payment-field input.input-error {
        border-color: #ef4444;
    }

    .field-error {
        color: #ef4444;
        font-size: 0.8rem;
        margin-top: 0.25rem;
        min-height: 1.2rem;
    }

    .card-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 0.75rem;
        margin-top: 0.75rem;
    }

    .field-hint {
        font-size: 0.8rem;
        color: #6b7280;
        margin-top: 0.5rem;
    }

    .paypal-message {
        background: rgba(239, 246, 255, 0.9);
        backdrop-filter: blur(4px);
        padding: 1rem;
        border-radius: 12px;
        text-align: center;
        color: #2563eb;
    }

    .btn-pay {
        width: 100%;
        padding: 1rem;
        background: #2563eb;
        color: white;
        border: none;
        border-radius: 14px;
        font-weight: 600;
        font-size: 1.1rem;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 0.75rem;
        cursor: pointer;
        transition: all 0.2s;
        box-shadow: 0 8px 16px -4px rgba(37, 99, 235, 0.25);
    }

    .btn-pay:hover {
        background: #1e40af;
        transform: translateY(-2px);
        box-shadow: 0 12px 20px -6px rgba(37, 99, 235, 0.35);
    }

    .btn-pay:disabled {
        background: #9ca3af;
        opacity: 0.7;
        transform: none;
        cursor: not-allowed;
        box-shadow: none;
    }

    .secure-text {
        text-align: center;
        font-size: 0.8rem;
        color: #6b7280;
        margin-top: 1.25rem;
    }

    .secure-text i {
        color: #10b981;
        margin-right: 0.25rem;
    }

    .loading-overlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(255, 255, 255, 0.85);
        backdrop-filter: blur(4px);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
    }

    .loading-spinner {
        background: white;
        padding: 2rem 3rem;
        border-radius: 20px;
        box-shadow: 0 20px 35px -8px rgba(0,0,0,0.15);
        text-align: center;
    }

    .loading-spinner i {
        font-size: 3rem;
        color: #2563eb;
        margin-bottom: 1rem;
    }

    .loading-spinner p {
        color: #4b5563;
        font-weight: 500;
    }

    @media (max-width: 480px) {
        .payment-wrapper {
            padding: 1rem;
        }
        .payment-card {
            padding: 1.5rem;
        }
        .payment-title {
            font-size: 1.3rem;
        }
        .amount-value {
            font-size: 2rem;
        }
        .option-content {
            gap: 0.5rem;
        }
    }
</style>

<%@ include file="footer.jsp" %>
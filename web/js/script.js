/**
 * Global JavaScript - BusTicket Booking System
 * ES5 compatible version for NetBeans 8
 */

document.addEventListener('DOMContentLoaded', function() {

    // =============================================
    // MOBILE NAVIGATION TOGGLE
    // =============================================
    var navToggle = document.getElementById('navToggle');
    var navMenu = document.getElementById('navMenu');
    
    if (navToggle && navMenu) {
        navToggle.addEventListener('click', function() {
            navMenu.classList.toggle('active');
            var icon = this.querySelector('i');
            if (icon) {
                icon.classList.toggle('fa-bars');
                icon.classList.toggle('fa-times');
            }
        });

        // Close menu when clicking outside
        document.addEventListener('click', function(e) {
            if (!navToggle.contains(e.target) && !navMenu.contains(e.target)) {
                navMenu.classList.remove('active');
                var icon = navToggle.querySelector('i');
                if (icon) {
                    icon.classList.add('fa-bars');
                    icon.classList.remove('fa-times');
                }
            }
        });
    }

    // =============================================
    // FLASH MESSAGES AUTO-DISMISS (FIXED ES5)
    // =============================================
    var alerts = document.querySelectorAll('.alert');
    for (var i = 0; i < alerts.length; i++) {
        (function(alert) {
            // Add close button if not present
            if (!alert.querySelector('.close-alert')) {
                var closeBtn = document.createElement('button');
                closeBtn.className = 'close-alert';
                closeBtn.innerHTML = '&times;';
                closeBtn.setAttribute('aria-label', 'Close');
                closeBtn.addEventListener('click', function() {
                    alert.style.opacity = '0';
                    setTimeout(function() {
                        alert.remove();
                    }, 300);
                });
                alert.appendChild(closeBtn);
            }
            
            // Auto-dismiss success messages after 5 seconds
            if (alert.classList.contains('alert-success')) {
                setTimeout(function() {
                    alert.style.opacity = '0';
                    setTimeout(function() {
                        alert.remove();
                    }, 300);
                }, 5000);
            }
        })(alerts[i]);
    }

    // =============================================
    // FORM VALIDATION HELPERS
    // =============================================
    var forms = document.querySelectorAll('form[data-validate]');
    for (var f = 0; f < forms.length; f++) {
        forms[f].addEventListener('submit', function(e) {
            var isValid = true;
            var inputs = this.querySelectorAll('input[required], select[required], textarea[required]');
            
            for (var j = 0; j < inputs.length; j++) {
                var input = inputs[j];
                if (!input.value.trim()) {
                    isValid = false;
                    input.classList.add('input-error');
                    
                    var errorMsg = input.parentNode.querySelector('.field-error');
                    if (!errorMsg) {
                        errorMsg = document.createElement('span');
                        errorMsg.className = 'field-error';
                        input.parentNode.appendChild(errorMsg);
                    }
                    errorMsg.textContent = 'This field is required';
                } else {
                    input.classList.remove('input-error');
                    var errorMsg = input.parentNode.querySelector('.field-error');
                    if (errorMsg) errorMsg.remove();
                }
            }
            
            if (!isValid) {
                e.preventDefault();
            }
        });
    }

    // Real-time validation on blur
    var requiredInputs = document.querySelectorAll('input[required], select[required]');
    for (var k = 0; k < requiredInputs.length; k++) {
        requiredInputs[k].addEventListener('blur', function() {
            if (!this.value.trim()) {
                this.classList.add('input-error');
            } else {
                this.classList.remove('input-error');
                var errorMsg = this.parentNode.querySelector('.field-error');
                if (errorMsg) errorMsg.remove();
            }
        });
    }

    // =============================================
    // CONFIRMATION DIALOGS (for links/buttons)
    // =============================================
    var confirmEls = document.querySelectorAll('[data-confirm]');
    for (var c = 0; c < confirmEls.length; c++) {
        confirmEls[c].addEventListener('click', function(e) {
            var message = this.getAttribute('data-confirm') || 'Are you sure?';
            if (!confirm(message)) {
                e.preventDefault();
                e.stopPropagation();
            }
        });
    }

    // =============================================
    // DISABLE SUBMIT BUTTON ON FORM SUBMIT (Prevent double submission)
    // =============================================
    var allForms = document.querySelectorAll('form:not([data-no-disable])');
    for (var fm = 0; fm < allForms.length; fm++) {
        allForms[fm].addEventListener('submit', function() {
            var submitBtn = this.querySelector('button[type="submit"]');
            if (submitBtn && !submitBtn.disabled) {
                submitBtn.disabled = true;
                var originalText = submitBtn.innerHTML;
                submitBtn.setAttribute('data-original-text', originalText);
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
            }
        });
    }

    // =============================================
    // DATE INPUT MIN/MAX DEFAULTS
    // =============================================
    var dateInputs = document.querySelectorAll('input[type="date"]');
    for (var d = 0; d < dateInputs.length; d++) {
        var input = dateInputs[d];
        if (!input.hasAttribute('min')) {
            var today = new Date();
            today.setHours(0, 0, 0, 0);
            input.min = today.toISOString().split('T')[0];
        }
    }

    // =============================================
    // SMOOTH SCROLL FOR ANCHOR LINKS
    // =============================================
    var anchorLinks = document.querySelectorAll('a[href^="#"]:not([href="#"])');
    for (var a = 0; a < anchorLinks.length; a++) {
        anchorLinks[a].addEventListener('click', function(e) {
            var targetId = this.getAttribute('href');
            var targetEl = document.querySelector(targetId);
            if (targetEl) {
                e.preventDefault();
                targetEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });
    }

    // =============================================
    // BACK TO TOP BUTTON (if present)
    // =============================================
    var backToTopBtn = document.getElementById('backToTop');
    if (backToTopBtn) {
        window.addEventListener('scroll', function() {
            if (window.scrollY > 300) {
                backToTopBtn.classList.add('visible');
            } else {
                backToTopBtn.classList.remove('visible');
            }
        });
        
        backToTopBtn.addEventListener('click', function() {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        });
    }

    // =============================================
    // LOGOUT CONFIRMATION (if using direct links)
    // =============================================
    var logoutLinks = document.querySelectorAll('a[href*="logout"]');
    for (var lo = 0; lo < logoutLinks.length; lo++) {
        logoutLinks[lo].addEventListener('click', function(e) {
            if (!confirm('Are you sure you want to log out?')) {
                e.preventDefault();
            }
        });
    }

}); // End DOMContentLoaded

// =============================================
// GLOBAL FUNCTIONS (ES5 compatible)
// =============================================

/**
 * Format currency (Ethiopian Birr)
 */
window.formatCurrency = function(amount) {
    return 'ETB ' + parseFloat(amount).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
};

/**
 * Debounce function for search inputs
 */
window.debounce = function(func, wait) {
    var timeout;
    return function() {
        var context = this;
        var args = arguments;
        clearTimeout(timeout);
        timeout = setTimeout(function() {
            func.apply(context, args);
        }, wait);
    };
};

/**
 * Shows a toast notification
 */
window.showToast = function(message, type) {
    type = type || 'info';
    var toast = document.createElement('div');
    toast.className = 'toast toast-' + type;
    
    var iconClass = 'info-circle';
    if (type === 'success') iconClass = 'check-circle';
    else if (type === 'error') iconClass = 'exclamation-circle';
    
    toast.innerHTML = '<i class="fas fa-' + iconClass + '"></i> ' + message;
    document.body.appendChild(toast);
    
    setTimeout(function() {
        toast.classList.add('show');
    }, 10);
    
    setTimeout(function() {
        toast.classList.remove('show');
        setTimeout(function() {
            toast.remove();
        }, 300);
    }, 4000);
};

/**
 * Confirmation dialog that returns a Promise (for async use)
 * Note: Promise may not be supported in very old browsers, but most modern ones do.
 */
window.confirmAsync = function(message) {
    return new Promise(function(resolve) {
        resolve(confirm(message));
    });
};

/**
 * Disables a button and shows a spinner
 */
window.setButtonLoading = function(btn, isLoading) {
    if (isLoading) {
        btn.setAttribute('data-original-text', btn.innerHTML);
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Loading...';
        btn.disabled = true;
    } else {
        var originalText = btn.getAttribute('data-original-text');
        if (originalText) {
            btn.innerHTML = originalText;
            btn.removeAttribute('data-original-text');
        }
        btn.disabled = false;
    }
};

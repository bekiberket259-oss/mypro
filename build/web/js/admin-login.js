/**
 * Admin Login Page JavaScript
 * Handles auto‑focus, password visibility toggle, and form loading state.
 */

document.addEventListener('DOMContentLoaded', function() {
    // Auto‑focus username input
    var usernameInput = document.getElementById('username');
    if (usernameInput) {
        usernameInput.focus();
    }

    // Show/Hide Password Toggle
    var togglePassword = document.getElementById('togglePassword');
    var passwordInput = document.getElementById('password');
    if (togglePassword && passwordInput) {
        togglePassword.addEventListener('click', function() {
            // Toggle password field type
            var type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordInput.setAttribute('type', type);
            
            // Toggle eye icon
            this.classList.toggle('fa-eye');
            this.classList.toggle('fa-eye-slash');
        });
    }

    // Loading state on form submit (prevents double submission)
    var form = document.getElementById('adminLoginForm');
    var loginButton = document.getElementById('loginButton');
    if (form && loginButton) {
        form.addEventListener('submit', function() {
            loginButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> <span>Signing in...</span>';
            loginButton.disabled = true;
        });
    }
});
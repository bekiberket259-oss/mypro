/**
 * booking.js – Bus Seat Selection & Booking
 * 
 * Handles:
 * - Multiple seat selection (toggle on click)
 * - Real‑time summary updates (seat count, total fare)
 * - Validation before submission
 * - Integration with JSP server‑side data
 */

(function() {
  'use strict';

  // --------------------------------------------------------------------
  // 1. Configuration & Global Variables (from JSP)
  // --------------------------------------------------------------------
  var ROUTE_FARE = typeof routeFare !== 'undefined' ? routeFare : 0;
  var BOOKED_SEATS = typeof bookedSeatsArray !== 'undefined' ? bookedSeatsArray : [];

  // DOM Elements
  var seatMap = document.getElementById('seatMap');
  var selectedSeatsDisplay = document.getElementById('selectedSeatsDisplay');
  var seatCountSpan = document.getElementById('seatCount');
  var totalFareSpan = document.getElementById('totalFare');
  var selectedSeatsInput = document.getElementById('selectedSeatsInput');
  var bookingForm = document.getElementById('bookingForm');
  var proceedBtn = document.getElementById('proceedBtn');

  // State
  var selectedSeats = new Set(); // stores seat numbers as strings

  // --------------------------------------------------------------------
  // 2. Helper Functions
  // --------------------------------------------------------------------

  /**
   * Update the summary panel (seat list, count, total fare)
   */
  function updateSummary() {
    var seatArray = Array.from(selectedSeats).sort(function(a, b) {
      return Number(a) - Number(b);
    });
    var count = seatArray.length;
    var total = count * ROUTE_FARE;

    // Update display
    if (count === 0) {
      selectedSeatsDisplay.textContent = 'No seats selected';
    } else {
      selectedSeatsDisplay.textContent = seatArray.join(', ');
    }
    seatCountSpan.textContent = count;
    totalFareSpan.textContent = 'ETB ' + total.toFixed(2);

    // Update hidden input for form submission
    selectedSeatsInput.value = seatArray.join(',');

    // Enable/disable proceed button
    proceedBtn.disabled = (count === 0);
  }

  /**
   * Check if a seat is booked (from server‑side data)
   */
  function isSeatBooked(seatNumber) {
    return BOOKED_SEATS.indexOf(String(seatNumber)) !== -1;
  }

  /**
   * Toggle seat selection
   */
  function toggleSeat(seatElement, seatNumber) {
    // Ignore if booked
    if (seatElement.classList.contains('booked')) return;

    var seatStr = String(seatNumber);

    if (selectedSeats.has(seatStr)) {
      // Deselect
      selectedSeats.delete(seatStr);
      seatElement.classList.remove('selected');
      seatElement.classList.add('available');
    } else {
      // Select
      selectedSeats.add(seatStr);
      seatElement.classList.remove('available');
      seatElement.classList.add('selected');
    }

    updateSummary();
  }

  // --------------------------------------------------------------------
  // 3. Initialize Seat Map
  // --------------------------------------------------------------------
  function initSeatMap() {
    if (!seatMap) return;

    // Get all seat elements
    var seats = seatMap.querySelectorAll('.seat');

    for (var i = 0; i < seats.length; i++) {
      var seat = seats[i];
      var seatNumber = seat.getAttribute('data-seat');
      if (!seatNumber) continue;

      // Ensure booked seats have correct class and are non‑interactive
      if (isSeatBooked(seatNumber)) {
        seat.classList.add('booked');
        seat.classList.remove('available', 'selected');
        seat.style.pointerEvents = 'none';
      } else {
        // Ensure available class and pointer events
        seat.classList.add('available');
        seat.style.pointerEvents = 'auto';
      }

      // Add click listener
      seat.addEventListener('click', (function(seatEl, seatNum) {
        return function(e) {
          e.stopPropagation();
          toggleSeat(seatEl, seatNum);
        };
      })(seat, seatNumber));
    }

    // Initial summary update (in case any seats are pre‑selected via session)
    updateSummary();
  }

  // --------------------------------------------------------------------
  // 4. Form Validation
  // --------------------------------------------------------------------
  function validateForm(event) {
    var nameInput = document.getElementById('passengerName');
    var emailInput = document.getElementById('passengerEmail');
    var phoneInput = document.getElementById('passengerPhone');
    var name = nameInput ? nameInput.value.trim() : '';
    var email = emailInput ? emailInput.value.trim() : '';
    var phone = phoneInput ? phoneInput.value.trim() : '';
    var selectedCount = selectedSeats.size;

    var errors = [];

    if (selectedCount === 0) {
      errors.push('Please select at least one seat.');
    }

    if (name === '') {
      errors.push('Full name is required.');
    } else if (name.length < 2) {
      errors.push('Name must be at least 2 characters.');
    }

    var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (email === '') {
      errors.push('Email address is required.');
    } else if (!emailRegex.test(email)) {
      errors.push('Please enter a valid email address.');
    }

    // Ethiopian phone pattern: 09 followed by 8 digits
    var phoneRegex = /^09\d{8}$/;
    if (phone === '') {
      errors.push('Phone number is required.');
    } else if (!phoneRegex.test(phone)) {
      errors.push('Phone must be 10 digits starting with 09 (e.g., 0912345678).');
    }

    if (errors.length > 0) {
      event.preventDefault();
      alert(errors.join('\n'));
      return false;
    }
    return true;
  }

  // --------------------------------------------------------------------
  // 5. Attach Event Listeners
  // --------------------------------------------------------------------
  function bindEvents() {
    if (bookingForm) {
      bookingForm.addEventListener('submit', validateForm);
    }
  }

  // --------------------------------------------------------------------
  // 6. Start Everything
  // --------------------------------------------------------------------
  function init() {
    initSeatMap();
    bindEvents();
  }

  // Run when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

})();
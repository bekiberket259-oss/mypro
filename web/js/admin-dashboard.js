/**
 * Admin Dashboard JavaScript
 * Handles chart rendering, date display, and data visualization.
 */

document.addEventListener('DOMContentLoaded', function() {
    // Set current date in the header
    var dateElement = document.getElementById('currentDate');
    if (dateElement) {
        dateElement.textContent = new Date().toLocaleDateString('en-US', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
    }

    // Retrieve data safely injected by JSP via window.dashboardData
    var data = window.dashboardData || {};
    var dailyLabels = data.dailyLabels || [];
    var dailyRevenue = data.dailyRevenue || [];
    var busNames = data.busNames || [];
    var busRevenue = data.busRevenue || [];

    // Daily Revenue Bar Chart
    var dailyCanvas = document.getElementById('dailyRevenueChart');
    var dailyNoData = document.getElementById('dailyNoData');
    if (dailyCanvas && dailyLabels.length > 0 && dailyRevenue.length > 0) {
        var ctx = dailyCanvas.getContext('2d');
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: dailyLabels,
                datasets: [{
                    label: 'Revenue (ETB)',
                    data: dailyRevenue,
                    backgroundColor: '#2563eb',
                    borderRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: { beginAtZero: true, grid: { color: '#e5e7eb' } },
                    x: { grid: { display: false } }
                }
            }
        });
    } else if (dailyNoData) {
        dailyNoData.style.display = 'flex';
        if (dailyCanvas) dailyCanvas.style.display = 'none';
    }

    // Revenue by Bus Pie Chart
    var busCanvas = document.getElementById('busRevenueChart');
    var busNoData = document.getElementById('busNoData');
    if (busCanvas && busNames.length > 0 && busRevenue.length > 0) {
        var ctx = busCanvas.getContext('2d');
        new Chart(ctx, {
            type: 'pie',
            data: {
                labels: busNames,
                datasets: [{
                    data: busRevenue,
                    backgroundColor: ['#2563eb', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899'],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'bottom', labels: { boxWidth: 12, padding: 15 } }
                }
            }
        });
    } else if (busNoData) {
        busNoData.style.display = 'flex';
        if (busCanvas) busCanvas.style.display = 'none';
    }
});

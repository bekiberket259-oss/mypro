<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        .admin-layout { display: flex; min-height: 100vh; background: #f8fafc; }
        .admin-main {
            flex: 1; padding: 2rem; margin-left: 280px; transition: margin-left 0.3s ease;
            width: calc(100% - 280px); max-width: 100%; overflow-x: auto;
        }
        .admin-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; }
        .admin-header h1 { font-size: 2rem; font-weight: 700; color: #1f2937; display: flex; align-items: center; gap: 0.75rem; }
        .admin-header h1 i { color: #2563eb; }
        .admin-date { color: #6b7280; font-size: 0.95rem; background: white; padding: 0.5rem 1rem; border-radius: 30px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
        .stats-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 1.5rem; margin-bottom: 2.5rem; }
        .stat-card {
            background: white; padding: 1.5rem 1.25rem; border-radius: 20px; display: flex;
            align-items: center; gap: 1rem; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.03);
            border: 1px solid #f0f2f5; transition: transform 0.2s, box-shadow 0.2s;
        }
        .stat-card:hover { transform: translateY(-3px); box-shadow: 0 12px 20px -8px rgba(0,0,0,0.08); }
        .stat-icon { width: 55px; height: 55px; border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; }
        .stat-icon.blue { background: #dbeafe; color: #2563eb; }
        .stat-icon.green { background: #dcfce7; color: #16a34a; }
        .stat-icon.amber { background: #fef3c7; color: #f59e0b; }
        .stat-icon.purple { background: #f3e8ff; color: #7c3aed; }
        .stat-icon.teal { background: #ccfbf1; color: #0d9488; }
        .stat-info h3 { font-size: 1.8rem; font-weight: 700; color: #1f2937; margin-bottom: 0.25rem; line-height: 1.2; }
        .stat-info p { color: #6b7280; font-size: 0.9rem; font-weight: 500; }
        .charts-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; margin-bottom: 2rem; }
        .chart-card {
            background: white; border-radius: 20px; padding: 1.5rem;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.03); border: 1px solid #f0f2f5;
            height: 380px; display: flex; flex-direction: column;
        }
        .chart-card h3 { margin-bottom: 1rem; color: #374151; font-size: 1.1rem; display: flex; align-items: center; gap: 0.5rem; }
        .chart-card canvas { flex: 1; max-height: 300px; width: 100% !important; }
        .no-data-message { flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: center; color: #9ca3af; }
        .no-data-message i { font-size: 2.5rem; margin-bottom: 0.5rem; opacity: 0.6; }
        .table-responsive { overflow-x: auto; max-height: 280px; }
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table th {
            text-align: left; padding: 0.9rem 1rem; font-size: 0.8rem; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.5px; color: #6b7280;
            border-bottom: 1px solid #e5e7eb; background: #f9fafb; position: sticky; top: 0;
        }
        .data-table td { padding: 1rem; font-size: 0.9rem; color: #1f2937; border-bottom: 1px solid #f0f2f5; }
        .empty-table { text-align: center; color: #9ca3af; padding: 2rem; }
        @media (max-width: 1200px) { .stats-grid { grid-template-columns: repeat(3, 1fr); } }
        @media (max-width: 992px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
            .charts-row { grid-template-columns: 1fr; }
            .admin-main { margin-left: 0; width: 100%; padding: 1.5rem; }
        }
        @media (max-width: 768px) {
            .stats-grid { grid-template-columns: 1fr; }
            .admin-header { flex-direction: column; align-items: flex-start; gap: 0.75rem; }
        }
    </style>
</head>
<body class="admin-dashboard-body">
<div class="admin-layout">
    <%@ include file="sidebar.jsp" %>

    <main class="admin-main">
        <div class="admin-header">
            <h1><i class="fas fa-chart-pie"></i> Analytics & Reports</h1>
            <div class="admin-date">
                <i class="far fa-calendar-alt"></i>
                <span id="currentDate"></span>
            </div>
        </div>

        <%-- Flash Messages --%>
        <c:if test="${not empty sessionScope.error}">
            <div class="alert alert-danger" style="margin-bottom:1rem; background:#fee2e2; color:#991b1b; padding:0.75rem 1rem; border-radius:12px;">
                <i class="fas fa-exclamation-circle"></i> <c:out value="${sessionScope.error}"/>
                <c:remove var="error" scope="session"/>
            </div>
        </c:if>

        <%-- Summary KPI Cards --%>
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue"><i class="fas fa-users"></i></div>
                <div class="stat-info">
                    <h3><c:out value="${totalUsers}"/></h3>
                    <p>Total Users</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green"><i class="fas fa-bus"></i></div>
                <div class="stat-info">
                    <h3><c:out value="${activeBuses}"/>/<c:out value="${totalBuses}"/></h3>
                    <p>Active Buses</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon amber"><i class="fas fa-route"></i></div>
                <div class="stat-info">
                    <h3><c:out value="${activeRoutes}"/>/<c:out value="${totalRoutes}"/></h3>
                    <p>Active Routes</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon purple"><i class="fas fa-ticket-alt"></i></div>
                <div class="stat-info">
                    <h3><c:out value="${totalBookings}"/></h3>
                    <p>Total Bookings</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon teal"><i class="fas fa-dollar-sign"></i></div>
                <div class="stat-info">
                    <h3>ETB <fmt:formatNumber value="${totalRevenue}" pattern="#,##0"/></h3>
                    <p>Total Revenue</p>
                </div>
            </div>
        </div>

        <%-- Charts Row 1 --%>
        <div class="charts-row">
            <div class="chart-card">
                <h3><i class="fas fa-chart-line"></i> Daily Revenue (Last 30 Days)</h3>
                <canvas id="dailyRevenueChart"></canvas>
                <div id="dailyNoData" class="no-data-message" style="display: none;">
                    <i class="fas fa-chart-bar"></i> No revenue data available
                </div>
            </div>
            <div class="chart-card">
                <h3><i class="fas fa-chart-bar"></i> Monthly Revenue (Last 12 Months)</h3>
                <canvas id="monthlyRevenueChart"></canvas>
                <div id="monthlyNoData" class="no-data-message" style="display: none;">
                    <i class="fas fa-chart-bar"></i> No monthly data available
                </div>
            </div>
        </div>

        <%-- Charts Row 2 --%>
        <div class="charts-row">
            <div class="chart-card">
                <h3><i class="fas fa-chart-pie"></i> Revenue by Bus</h3>
                <canvas id="busRevenueChart"></canvas>
                <div id="busNoData" class="no-data-message" style="display: none;">
                    <i class="fas fa-chart-pie"></i> No bus revenue data available
                </div>
            </div>
            <div class="chart-card">
                <h3><i class="fas fa-trophy"></i> Top Routes by Bookings</h3>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Route</th>
                                <th>Bookings</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty topRoutes}">
                                    <tr><td colspan="3" class="empty-table">No data available</td></tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="route" items="${topRoutes}" varStatus="loop">
                                        <tr>
                                            <td>${loop.index + 1}</td>
                                            <td><c:out value="${route.source}"/> → <c:out value="${route.destination}"/></td>
                                            <td><strong><c:out value="${route.bookingCount}"/></strong></td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
    window.analyticsData = {
        dailyLabels: <c:out value="${dailyLabelsJson}" escapeXml="false" default="[]" />,
        dailyRevenue: <c:out value="${dailyRevenueJson}" escapeXml="false" default="[]" />,
        monthlyLabels: <c:out value="${monthlyLabelsJson}" escapeXml="false" default="[]" />,
        monthlyRevenue: <c:out value="${monthlyRevenueJson}" escapeXml="false" default="[]" />,
        busNames: <c:out value="${busNamesJson}" escapeXml="false" default="[]" />,
        busRevenue: <c:out value="${busRevenueJson}" escapeXml="false" default="[]" />
    };
</script>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('currentDate').textContent = new Date().toLocaleDateString('en-US', {
            weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
        });

        var data = window.analyticsData || {};

        function formatDailyLabel(isoDate) {
            var d = new Date(isoDate + 'T00:00:00');
            return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
        }

        function formatMonthLabel(monthStr) {
            var parts = monthStr.split('-');
            if (parts.length === 2) {
                var year = parts[0];
                var monthNum = parseInt(parts[1], 10);
                var monthName = new Date(year, monthNum - 1).toLocaleDateString('en-US', { month: 'short' });
                return monthName + ' ' + year;
            }
            return monthStr;
        }

        // Daily Revenue Chart
        var dailyCtx = document.getElementById('dailyRevenueChart')?.getContext('2d');
        if (dailyCtx && data.dailyLabels?.length > 0 && data.dailyRevenue?.length > 0) {
            var formattedDailyLabels = data.dailyLabels.map(formatDailyLabel);
            new Chart(dailyCtx, {
                type: 'line',
                data: {
                    labels: formattedDailyLabels,
                    datasets: [{
                        label: 'Revenue (ETB)',
                        data: data.dailyRevenue,
                        borderColor: '#2563eb',
                        backgroundColor: 'rgba(37, 99, 235, 0.1)',
                        borderWidth: 2,
                        fill: true,
                        tension: 0.3,
                        pointBackgroundColor: '#2563eb'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } }
                }
            });
        } else {
            document.getElementById('dailyNoData').style.display = 'flex';
            document.getElementById('dailyRevenueChart').style.display = 'none';
        }

        // Monthly Revenue Chart
        var monthlyCtx = document.getElementById('monthlyRevenueChart')?.getContext('2d');
        if (monthlyCtx && data.monthlyLabels?.length > 0 && data.monthlyRevenue?.length > 0) {
            var formattedMonthlyLabels = data.monthlyLabels.map(formatMonthLabel);
            new Chart(monthlyCtx, {
                type: 'bar',
                data: {
                    labels: formattedMonthlyLabels,
                    datasets: [{
                        label: 'Revenue (ETB)',
                        data: data.monthlyRevenue,
                        backgroundColor: '#10b981',
                        borderRadius: 8,
                        barPercentage: 0.5,
                        categoryPercentage: 0.8
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } }
                }
            });
        } else {
            document.getElementById('monthlyNoData').style.display = 'flex';
            document.getElementById('monthlyRevenueChart').style.display = 'none';
        }

        // Revenue per Bus Chart
        var busCtx = document.getElementById('busRevenueChart')?.getContext('2d');
        if (busCtx && data.busNames?.length > 0 && data.busRevenue?.length > 0) {
            new Chart(busCtx, {
                type: 'doughnut',
                data: {
                    labels: data.busNames,
                    datasets: [{
                        data: data.busRevenue,
                        backgroundColor: ['#2563eb', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#06b6d4', '#f97316'],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'bottom', labels: { boxWidth: 12, padding: 15 } }
                    },
                    cutout: '60%'
                }
            });
        } else {
            document.getElementById('busNoData').style.display = 'flex';
            document.getElementById('busRevenueChart').style.display = 'none';
        }
    });
</script>
</body>
</html>
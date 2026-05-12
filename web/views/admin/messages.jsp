<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.busbooking.model.ContactMessage" %>
<%
    List<ContactMessage> messages = (List<ContactMessage>) request.getAttribute("messages");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Contact Messages</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        /* Full page bus background */
        body {
            background: url('${pageContext.request.contextPath}/images/bus-bg.jpg') no-repeat center center fixed;
            background-size: cover;
            position: relative;
        }
        /* Semi-transparent overlay for better readability */
        body::before {
            content: "";
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: -1;
        }
        .messages-container {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 1rem;
        }
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
        }
        .page-header h1 {
            font-size: 1.8rem;
            color: white;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            text-shadow: 1px 1px 2px rgba(0,0,0,0.5);
        }
        .page-header h1 i {
            color: #facc15;
        }
        .btn-secondary {
            background: rgba(255,255,255,0.9);
            padding: 0.5rem 1rem;
            border-radius: 40px;
            text-decoration: none;
            color: #1f2937;
            font-weight: 500;
        }
        .message-table {
            width: 100%;
            border-collapse: collapse;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .message-table th, .message-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #e5e7eb;
        }
        .message-table th {
            background: #2563eb;
            color: white;
            font-weight: 600;
        }
        .unread-row {
            background: #eff6ff;
            font-weight: 500;
        }
        .btn-sm {
            padding: 4px 12px;
            border-radius: 20px;
            text-decoration: none;
            font-size: 0.8rem;
            display: inline-block;
            margin-right: 5px;
        }
        .btn-view {
            background: #2563eb;
            color: white;
        }
        .btn-delete {
            background: #ef4444;
            color: white;
        }
        .empty-state {
            text-align: center;
            padding: 3rem;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
        }
        .empty-state i {
            font-size: 4rem;
            color: #9ca3af;
            margin-bottom: 1rem;
        }
    </style>
</head>
<body>
    <div class="messages-container">
        <div class="page-header">
            <h1><i class="fas fa-envelope"></i> Contact Messages</h1>
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn-secondary">Back to Dashboard</a>
        </div>

        <% if (messages == null || messages.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-inbox"></i>
                <h3>No messages yet</h3>
                <p>When customers contact you, their messages will appear here.</p>
            </div>
        <% } else { %>
            <table class="message-table">
                <thead>
                    <tr>
                        <th>ID</th><th>Name</th><th>Email</th><th>Subject</th><th>Date</th><th>Status</th><th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (ContactMessage msg : messages) { %>
                        <tr class="<%= !msg.isRead() ? "unread-row" : "" %>">
                            <td><%= msg.getId() %></td>
                            <td><%= msg.getName() %></td>
                            <td><%= msg.getEmail() %></td>
                            <td><%= msg.getSubject() != null ? msg.getSubject() : "-" %></td>
                            <td><%= msg.getCreatedAt() %></td>
                            <td><%= msg.isRead() ? "Read" : "<strong>Unread</strong>" %></td>
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/messages?action=view&id=<%= msg.getId() %>" class="btn-sm btn-view">View</a>
                                <a href="${pageContext.request.contextPath}/admin/messages?action=delete&id=<%= msg.getId() %>" class="btn-sm btn-delete" onclick="return confirm('Delete this message?')">Delete</a>
                               </div>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>
    </div>
</body>
</html>
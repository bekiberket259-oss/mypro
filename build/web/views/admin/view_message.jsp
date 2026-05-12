<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.busbooking.model.ContactMessage" %>
<%
    ContactMessage msg = (ContactMessage) request.getAttribute("message");
    if (msg == null) {
        response.sendRedirect(request.getContextPath() + "/admin/messages");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>View Message</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        /* Full page bus background */
        body {
            background: url('${pageContext.request.contextPath}/images/bus-bg.jpg') no-repeat center center fixed;
            background-size: cover;
            position: relative;
        }
        /* Semi-transparent overlay */
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
        .message-container {
            max-width: 900px;
            margin: 2rem auto;
            padding: 0 1.5rem;
        }
        .message-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 24px;
            box-shadow: 0 10px 25px -5px rgba(0,0,0,0.05);
            overflow: hidden;
        }
        .message-header {
            background: linear-gradient(135deg, #2563eb, #1e40af);
            color: white;
            padding: 1.5rem 2rem;
        }
        .message-header h1 {
            margin: 0 0 0.25rem 0;
            font-size: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .message-body {
            padding: 2rem;
        }
        .info-row {
            display: flex;
            margin-bottom: 1rem;
            padding-bottom: 0.75rem;
            border-bottom: 1px solid #e5e7eb;
        }
        .info-label {
            width: 100px;
            font-weight: 600;
            color: #4b5563;
        }
        .info-value {
            flex: 1;
            color: #1f2937;
        }
        .message-text {
            background: #f9fafb;
            border-radius: 16px;
            padding: 1.5rem;
            margin-top: 1.5rem;
            white-space: pre-wrap;
        }
        .action-buttons {
            display: flex;
            gap: 1rem;
            margin-top: 2rem;
            justify-content: flex-end;
        }
        .btn-secondary, .btn-danger {
            padding: 0.6rem 1.2rem;
            border-radius: 40px;
            text-decoration: none;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }
        .btn-secondary {
            background: #e5e7eb;
            color: #1f2937;
        }
        .btn-danger {
            background: #ef4444;
            color: white;
        }
    </style>
</head>
<body>
    <div class="message-container">
        <div class="message-card">
            <div class="message-header">
                <h1><i class="fas fa-envelope"></i> Message from <%= msg.getName() %></h1>
                <div><i class="far fa-calendar-alt"></i> Received: <%= msg.getCreatedAt() %></div>
            </div>
            <div class="message-body">
                <div class="info-row">
                    <div class="info-label">Name:</div>
                    <div class="info-value"><%= msg.getName() %></div>
                </div>
                <div class="info-row">
                    <div class="info-label">Email:</div>
                    <div class="info-value"><%= msg.getEmail() %></div>
                </div>
                <div class="info-row">
                    <div class="info-label">Subject:</div>
                    <div class="info-value"><%= msg.getSubject() != null ? msg.getSubject() : "No subject" %></div>
                </div>
                <div class="message-text">
                    <strong>Message:</strong><br>
                    <%= msg.getMessage().replace("\n", "<br>") %>
                </div>
                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/admin/messages" class="btn-secondary">Back to Messages</a>
                    <a href="${pageContext.request.contextPath}/admin/messages?action=delete&id=<%= msg.getId() %>" class="btn-danger" onclick="return confirm('Delete this message?')">Delete</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
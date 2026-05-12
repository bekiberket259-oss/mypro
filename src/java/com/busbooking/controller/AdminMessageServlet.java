package com.busbooking.controller;

import com.busbooking.dao.ContactMessageDAO;
import com.busbooking.model.ContactMessage;
import com.google.gson.Gson;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/admin/messages")
public class AdminMessageServlet extends HttpServlet {

    private ContactMessageDAO dao = new ContactMessageDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("unreadCount".equals(action)) {
            int count = dao.getUnreadCount();
            resp.setContentType("application/json");
            PrintWriter out = resp.getWriter();
            out.print("{\"unreadCount\": " + count + "}");
            out.flush();
            return;
        } else if ("view".equals(action)) {
            String idParam = req.getParameter("id");
            if (idParam != null && !idParam.isEmpty()) {
                int id = Integer.parseInt(idParam);
                ContactMessage msg = dao.getMessageById(id);
                if (msg != null && !msg.isRead()) {
                    dao.markAsRead(id);
                }
                req.setAttribute("message", msg);
                req.getRequestDispatcher("/views/admin/view_message.jsp").forward(req, resp);
                return;
            }
        } else if ("delete".equals(action)) {
            String idParam = req.getParameter("id");
            if (idParam != null && !idParam.isEmpty()) {
                dao.deleteMessage(Integer.parseInt(idParam));
            }
            resp.sendRedirect(req.getContextPath() + "/admin/messages");
            return;
        }

        List<ContactMessage> messages = dao.getAllMessages();
        req.setAttribute("messages", messages);
        req.getRequestDispatcher("/views/admin/messages.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
}
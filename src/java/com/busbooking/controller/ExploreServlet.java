package com.busbooking.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/explore")
public class ExploreServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Restrict to logged-in users (optional)
        if (req.getSession().getAttribute("user") == null && req.getSession().getAttribute("admin") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        // Forward to explore.jsp (adjust path if needed)
        req.getRequestDispatcher("/views/explore.jsp").forward(req, resp);
    }
}
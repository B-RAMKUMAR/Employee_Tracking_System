package com.employeetimetracker.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private Connection connection;

    public void init() throws ServletException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/EmployeeTimeTracker", "root", "Ram@24");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try (PreparedStatement statement = connection
                .prepareStatement("SELECT * FROM users WHERE email = ? AND password = ?")) {
            statement.setString(1, email);
            statement.setString(2, password);
            ResultSet rs = statement.executeQuery();

            if (rs.next()) {
                String role = rs.getString("role");
                HttpSession session = request.getSession();
                session.setAttribute("userId", rs.getInt("id"));
                session.setAttribute("name", rs.getString("name"));
                session.setAttribute("role", role);
                session.setAttribute("email", email);

                if ("admin".equalsIgnoreCase(role)) {
                    response.sendRedirect("AdminDashboardServlet"); // Redirect to admin dashboard
                } else {
                    response.sendRedirect("DashboardServlet"); // Redirect to user dashboard
                }
            } else {
                response.sendRedirect("login.jsp?error=Invalid email or password");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    public void destroy() {
        try {
            if (connection != null) {
                connection.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

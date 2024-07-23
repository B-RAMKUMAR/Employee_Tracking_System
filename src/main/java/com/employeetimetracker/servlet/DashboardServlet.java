package com.employeetimetracker.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Date;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {
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

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("email") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");
        Integer userId = (Integer) session.getAttribute("userId");

        String sql = "SELECT * FROM tasks WHERE user_id = ?";
        if ("Admin".equals(role)) {
            sql = "SELECT * FROM tasks";
        }

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            if (!"Admin".equals(role)) {
                statement.setInt(1, userId);
            }
            ResultSet rs = statement.executeQuery();
            request.setAttribute("tasks", rs);

            String action = request.getParameter("action");
            if ("editTask".equals(action)) {
                Integer taskId = Integer.parseInt(request.getParameter("taskId"));
                sql = "SELECT * FROM tasks WHERE id = ?";
                try (PreparedStatement editStatement = connection.prepareStatement(sql)) {
                    editStatement.setInt(1, taskId);
                    ResultSet editRs = editStatement.executeQuery();
                    if (editRs.next()) {
                        request.setAttribute("editTask", true);
                        request.setAttribute("editTaskId", taskId);
                        request.setAttribute("editProject", editRs.getString("project"));
                        request.setAttribute("editTaskDate", editRs.getDate("task_date").toString());
                        request.setAttribute("editStartTime", editRs.getTime("start_time").toString().substring(0, 5));
                        request.setAttribute("editEndTime", editRs.getTime("end_time").toString().substring(0, 5));
                        request.setAttribute("editTaskCategory", editRs.getString("task_category"));
                        request.setAttribute("editDescription", editRs.getString("description"));
                    }
                } catch (SQLException e) {
                    throw new ServletException(e);
                }
            }

            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("email") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("addTask".equals(action)) {
            String project = request.getParameter("project");
            String taskDateStr = request.getParameter("taskDate");
            Date taskDate = null;
            try {
                taskDate = parseDate(taskDateStr);
            } catch (ServletException e) {
                // Handle exception, e.g., display an error message
                e.printStackTrace(); // Or log the error
                response.sendRedirect("error.jsp"); // Redirect to an error page
                return;
            }
            Time startTime = Time.valueOf(request.getParameter("startTime") + ":00"); // Adjusting format
            Time endTime = Time.valueOf(request.getParameter("endTime") + ":00"); // Adjusting format
            String taskCategory = request.getParameter("taskCategory");
            String description = request.getParameter("description");
            Integer userId = (Integer) session.getAttribute("userId");

            try (PreparedStatement statement = connection.prepareStatement(
                    "INSERT INTO tasks (user_id, project, task_date, start_time, end_time, task_category, description) VALUES (?, ?, ?, ?, ?, ?, ?)")) {
                statement.setInt(1, userId);
                statement.setString(2, project);
                statement.setDate(3, taskDate);
                statement.setTime(4, startTime);
                statement.setTime(5, endTime);
                statement.setString(6, taskCategory);
                statement.setString(7, description);
                statement.executeUpdate();
            } catch (SQLException e) {
                throw new ServletException(e);
            }
        } else if ("editTask".equals(action)) {
            Integer taskId = Integer.parseInt(request.getParameter("taskId"));
            String project = request.getParameter("project");
            String taskDateStr = request.getParameter("taskDate");
            Date taskDate = null;
            try {
                taskDate = parseDate(taskDateStr);
            } catch (ServletException e) {
                // Handle exception, e.g., display an error message
                e.printStackTrace(); // Or log the error
                response.sendRedirect("error.jsp"); // Redirect to an error page
                return;
            }
            Time startTime = Time.valueOf(request.getParameter("startTime") + ":00"); // Adjusting format
            Time endTime = Time.valueOf(request.getParameter("endTime") + ":00"); // Adjusting format
            String taskCategory = request.getParameter("taskCategory");
            String description = request.getParameter("description");

            try (PreparedStatement statement = connection.prepareStatement(
                    "UPDATE tasks SET project = ?, task_date = ?, start_time = ?, end_time = ?, task_category = ?, description = ? WHERE id = ?")) {
                statement.setString(1, project);
                statement.setDate(2, taskDate);
                statement.setTime(3, startTime);
                statement.setTime(4, endTime);
                statement.setString(5, taskCategory);
                statement.setString(6, description);
                statement.setInt(7, taskId);
                statement.executeUpdate();
            } catch (SQLException e) {
                throw new ServletException(e);
            }
        } else if ("deleteTask".equals(action)) {
            Integer taskId = Integer.parseInt(request.getParameter("taskId"));

            try (PreparedStatement statement = connection.prepareStatement("DELETE FROM tasks WHERE id = ?")) {
                statement.setInt(1, taskId);
                statement.executeUpdate();
            } catch (SQLException e) {
                throw new ServletException(e);
            }
        }

        response.sendRedirect("DashboardServlet");
    }

    public void destroy() {
        try {
            if (connection != null) {
                connection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private Date parseDate(String dateStr) throws ServletException {
        if (dateStr == null || dateStr.isEmpty()) {
            throw new ServletException("Task date cannot be null or empty");
        }
        try {
            return Date.valueOf(dateStr);
        } catch (IllegalArgumentException e) {
            throw new ServletException("Invalid date format. Please use yyyy-mm-dd format for date.");
        }
    }
}

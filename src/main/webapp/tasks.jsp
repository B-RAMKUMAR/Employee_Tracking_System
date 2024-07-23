<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.Date" %>
<%@ page import="java.sql.Time" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    HttpSession sessionObj = request.getSession(false); // Renamed variable to avoid conflict
    if (sessionObj == null || sessionObj.getAttribute("email") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String action = (String) request.getAttribute("action");
    ResultSet tasks = (ResultSet) request.getAttribute("tasks");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Task Management</title>
</head>
<body>
    <h1>Task Management</h1>

    <h2>Add Task</h2>
    <form action="DashboardServlet" method="post">
        <input type="hidden" name="action" value="addTask">
        <label for="project">Project:</label>
        <input type="text" id="project" name="project" required>
        <br>
        <label for="taskDate">Date:</label>
        <input type="date" id="taskDate" name="taskDate" required>
        <br>
        <label for="startTime">Start Time:</label>
        <input type="time" id="startTime" name="startTime" required>
        <br>
        <label for="endTime">End Time:</label>
        <input type="time" id="endTime" name="endTime" required>
        <br>
        <label for="taskCategory">Task Category:</label>
        <input type="text" id="taskCategory" name="taskCategory" required>
        <br>
        <label for="description">Description:</label><br>
        <textarea id="description" name="description" rows="4" cols="50" required></textarea>
        <br>
        <button type="submit">Add Task</button>
    </form>

    <h2>Edit Task</h2>
    <form action="DashboardServlet" method="post">
        <input type="hidden" name="action" value="editTask">
        <label for="taskId">Task ID:</label>
        <input type="text" id="taskId" name="taskId" required>
        <br>
        <label for="project">Project:</label>
        <input type="text" id="project" name="project" required>
        <br>
        <label for="taskDate">Date:</label>
        <input type="date" id="taskDate" name="taskDate" required>
        <br>
        <label for="startTime">Start Time:</label>
        <input type="time" id="startTime" name="startTime" required>
        <br>
        <label for="endTime">End Time:</label>
        <input type="time" id="endTime" name="endTime" required>
        <br>
        <label for="taskCategory">Task Category:</label>
        <input type="text" id="taskCategory" name="taskCategory" required>
        <br>
        <label for="description">Description:</label><br>
        <textarea id="description" name="description" rows="4" cols="50" required></textarea>
        <br>
        <button type="submit">Edit Task</button>
    </form>

    <h2>Tasks List</h2>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Project</th>
            <th>Date</th>
            <th>Start Time</th>
            <th>End Time</th>
            <th>Task Category</th>
            <th>Description</th>
            <th>Action</th>
        </tr>
        <%
            while (tasks.next()) {
        %>
        <tr>
            <td><%= tasks.getInt("id") %></td>
            <td><%= tasks.getString("project") %></td>
            <td><%= tasks.getDate("task_date") %></td>
            <td><%= tasks.getTime("start_time") %></td>
            <td><%= tasks.getTime("end_time") %></td>
            <td><%= tasks.getString("task_category") %></td>
            <td><%= tasks.getString("description") %></td>
            <td>
                <form action="DashboardServlet" method="post">
                    <input type="hidden" name="action" value="editForm">
                    <input type="hidden" name="taskId" value="<%= tasks.getInt("id") %>">
                    <button type="submit">Edit</button>
                </form>
                <form action="DashboardServlet" method="post">
                    <input type="hidden" name="action" value="deleteTask">
                    <input type="hidden" name="taskId" value="<%= tasks.getInt("id") %>">
                    <button type="submit">Delete</button>
                </form>
            </td>
        </tr>
        <%
            }
        %>
    </table>
</body>
</html>

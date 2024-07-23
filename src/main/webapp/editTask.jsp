<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.Date" %>
<%@ page import="java.sql.Time" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Task</title>
</head>
<body>
    <h1>Edit Task</h1>
    
    <form action="DashboardServlet" method="post">
        <input type="hidden" name="action" value="editTask">
        
        <%
            ResultSet task = (ResultSet) request.getAttribute("task");
            if (task.next()) {
                int taskId = task.getInt("id");
                String project = task.getString("project");
                Date taskDate = task.getDate("task_date");
                Time startTime = task.getTime("start_time");
                Time endTime = task.getTime("end_time");
                String taskCategory = task.getString("task_category");
                String description = task.getString("description");
        %>
        
        <input type="hidden" name="taskId" value="<%= taskId %>">
        
        <label for="project">Project:</label>
        <input type="text" id="project" name="project" value="<%= project %>" required><br>
        
        <label for="taskDate">Date:</label>
        <input type="date" id="taskDate" name="taskDate" value="<%= taskDate %>" required><br>
        
        <label for="startTime">Start Time:</label>
        <input type="time" id="startTime" name="startTime" value="<%= startTime %>" required><br>
        
        <label for="endTime">End Time:</label>
        <input type="time" id="endTime" name="endTime" value="<%= endTime %>" required><br>
        
        <label for="taskCategory">Task Category:</label>
        <input type="text" id="taskCategory" name="taskCategory" value="<%= taskCategory %>" required><br>
        
        <label for="description">Description:</label><br>
        <textarea id="description" name="description" rows="4" cols="50" required><%= description %></textarea><br>
        
        <button type="submit">Save Changes</button>
        
        <%
            }
        %>
    </form>
</body>
</html>

<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.Date" %>
<%@ page import="java.sql.Time" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Employee Time Tracker - Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f0f0;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 1000px; /* Increased width */
            margin: auto;
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        h1 {
            text-align: center;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        table, th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: center;
        }
        th {
            background-color: #f2f2f2;
        }
        form {
            display: inline-block;
            margin-bottom: 0;
            vertical-align: top; /* Align forms vertically */
        }
        form button {
            padding: 8px 16px;
            background-color: #4CAF50;
            color: white;
            border: none;
            cursor: pointer;
            border-radius: 4px;
            font-size: 14px;
        }
        form button:hover {
            background-color: #45a049;
        }
        form input[type="text"],
        form input[type="date"],
        form input[type="time"],
        form textarea {
            width: calc(100% - 20px);
            padding: 8px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 14px;
        }
        .error-message {
            color: red;
            margin-top: 10px;
        }
        .login-btn {
            background-color: #007bff;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            float: right;
            margin-top: -50px;
        }
    </style>
    <script>
        function validateTimeRange(startTime, endTime) {
            const start = new Date(`2000-01-01 ${startTime}`).getTime();
            const end = new Date(`2000-01-01 ${endTime}`).getTime();
            const maxDiff = 8 * 60 * 60 * 1000; // 8 hours in milliseconds

            return (end - start <= maxDiff);
        }

        function validateForm() {
            const startTime = document.getElementById('startTime').value;
            const endTime = document.getElementById('endTime').value;

            if (!validateTimeRange(startTime, endTime)) {
                alert('The time difference between Start Time and End Time should not exceed 8 hours.');
                return false; // Prevent form submission
            }
            return true; // Allow form submission
        }
    </script>
</head>
<body>
    <div class="container">
        <button class="login-btn" onclick="location.href='login.jsp';">Logout</button>
        <h1>Welcome, <%= session.getAttribute("name") %></h1>
        <h2>Your Tasks</h2>
        
        <!-- Task List -->
        <table>
            <thead>
                <tr>
                    <th>Project</th>
                    <th>Date</th>
                    <th>Start Time</th>
                    <th>End Time</th>
                    <th>Task Category</th>
                    <th>Description</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% 
                ResultSet tasks = (ResultSet) request.getAttribute("tasks");
                while (tasks.next()) {
                    int taskId = tasks.getInt("id");
                    String project = tasks.getString("project");
                    Date taskDate = tasks.getDate("task_date");
                    Time startTime = tasks.getTime("start_time");
                    Time endTime = tasks.getTime("end_time");
                    String taskCategory = tasks.getString("task_category");
                    String description = tasks.getString("description");
                %>
                <tr>
                    <td><%= project %></td>
                    <td><%= taskDate %></td>
                    <td><%= startTime %></td>
                    <td><%= endTime %></td>
                    <td><%= taskCategory %></td>
                    <td><%= description %></td>
                    <td>
                        <form action="DashboardServlet" method="get">
                            <input type="hidden" name="taskId" value="<%= taskId %>">
                            <input type="hidden" name="action" value="editTask">
                            <button type="submit">Edit</button>
                        </form>
                        <form action="DashboardServlet" method="post" onsubmit="return confirm('Are you sure you want to delete this task?');">
                            <input type="hidden" name="taskId" value="<%= taskId %>">
                            <input type="hidden" name="action" value="deleteTask">
                            <button type="submit">Delete</button>
                        </form>
                    </td>
                </tr>
                <% 
                }
                %>
            </tbody>
        </table>

        <!-- Add Task Form -->
        <div style="display: inline-block; vertical-align: top; width: 45%;">
            <h2>Add Task</h2>
            <form action="DashboardServlet" method="post" onsubmit="return validateForm();">
                <input type="hidden" name="action" value="addTask">
                <label for="project">Project:</label>
                <input type="text" id="project" name="project" required><br>

                <label for="taskDate">Date (yyyy-mm-dd):</label>
                <input type="date" id="taskDate" name="taskDate" required><br>

                <label for="startTime">Start Time (HH:mm):</label>
                <input type="time" id="startTime" name="startTime" required><br>

                <label for="endTime">End Time (HH:mm):</label>
                <input type="time" id="endTime" name="endTime" required><br>

                <label for="taskCategory">Task Category:</label>
                <input type="text" id="taskCategory" name="taskCategory" required><br>

                <label for="description">Description:</label>
                <textarea id="description" name="description" required></textarea><br>

                <button type="submit">Submit</button>
            </form>
        </div>

        <!-- Edit Task Form -->
        <% if (request.getAttribute("editTask") != null) { %>
            <div style="display: inline-block; vertical-align: top; width: 45%;">
                <h2>Edit Task</h2>
                <form action="DashboardServlet" method="post" onsubmit="return validateForm();">
                    <input type="hidden" name="action" value="editTask">
                    <input type="hidden" name="taskId" value="<%= request.getAttribute("editTaskId") %>">
                    <label for="editProject">Project:</label>
                    <input type="text" id="editProject" name="project" value="<%= request.getAttribute("editProject") %>" required><br>

                    <label for="editTaskDate">Date (yyyy-mm-dd):</label>
                    <input type="date" id="editTaskDate" name="taskDate" value="<%= request.getAttribute("editTaskDate") %>" required><br>

                    <label for="editStartTime">Start Time (HH:mm):</label>
                    <input type="time" id="editStartTime" name="startTime" value="<%= request.getAttribute("editStartTime") %>" required><br>

                    <label for="editEndTime">End Time (HH:mm):</label>
                    <input type="time" id="editEndTime" name="endTime" value="<%= request.getAttribute("editEndTime") %>" required><br>

                    <label for="editTaskCategory">Task Category:</label>
                    <input type="text" id="editTaskCategory" name="taskCategory" value="<%= request.getAttribute("editTaskCategory") %>" required><br>

                    <label for="editDescription">Description:</label>
                    <textarea id="editDescription" name="description" required><%= request.getAttribute("editDescription") %></textarea><br>

                    <button type="submit">Update</button>
                </form>
            </div>
        <% } %>
    </div>
</body>
</html>

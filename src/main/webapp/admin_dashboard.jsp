<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard</title>
    <!-- Include jQuery and Chart.js libraries -->
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/jquery/dist/jquery.min.js"></script>
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/chart.js/dist/Chart.min.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
        }
        .view-buttons {
            margin: 20px 0;
        }
        .view-buttons form {
            display: inline;
        }
        .view-buttons button {
            background-color: #4CAF50;
            border: none;
            color: white;
            padding: 10px 20px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 16px;
            margin: 4px 2px;
            cursor: pointer;
            border-radius: 5px;
            transition: background-color 0.3s ease;
        }
        .view-buttons button:hover {
            background-color: #45a049;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
        }
        th {
            background-color: #f2f2f2;
        }
        .chart-container {
            width: 60%;
            margin: auto;
        }
        .logout-btn {
            text-align: right;
            margin-top: 10px;
        }
        .logout-btn form {
            display: inline-block;
        }
        .logout-btn button {
            background-color: #f44336;
            border: none;
            color: white;
            padding: 10px 20px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 16px;
            cursor: pointer;
            border-radius: 5px;
            transition: background-color 0.3s ease;
        }
        .logout-btn button:hover {
            background-color: #d32f2f;
        }
    </style>
</head>
<body>
    <div class="logout-btn">
        <form action="login.jsp" method="post">
            <button type="submit">Logout</button>
        </form>
    </div>

    <h1>Welcome to Admin Dashboard</h1>

    <h2>View Options</h2>
    <div class="view-buttons">
        <form method="get" action="AdminDashboardServlet">
            <input type="hidden" name="view" value="daily" />
            <button type="submit">Daily</button>
        </form>
        <form method="get" action="AdminDashboardServlet">
            <input type="hidden" name="view" value="weekly" />
            <button type="submit">Weekly</button>
        </form>
        <form method="get" action="AdminDashboardServlet">
            <input type="hidden" name="view" value="monthly" />
            <button type="submit">Monthly</button>
        </form>
        <form method="get" action="AdminDashboardServlet">
            <input type="hidden" name="view" value="yearly" />
            <button type="submit">Yearly</button>
        </form>
    </div>

    <h2>Tasks</h2>
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>User ID</th>
                <th>Project</th>
                <th>Task Date</th>
                <th>Start Time</th>
                <th>End Time</th>
                <th>Task Category</th>
                <th>Description</th>
                <th>Created By</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="task" items="${tasks}">
                <tr>
                    <td>${task.id}</td>
                    <td>${task.userId}</td>
                    <td>${task.project}</td>
                    <td>${task.taskDate}</td>
                    <td>${task.startTime}</td>
                    <td>${task.endTime}</td>
                    <td>${task.taskCategory}</td>
                    <td>${task.description}</td>
                    <td>${task.creatorName}</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <h2>Project Summaries</h2>
    <table>
        <thead>
            <tr>
                <th>Project Name</th>
                <th>Total Time (minutes)</th>
                <th>Creators</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="summary" items="${projectSummaries.values()}">
                <tr>
                    <td>${summary.projectName}</td>
                    <td>${summary.totalTime}</td>
                    <td>
                        <c:forEach var="creator" items="${summary.creators}">
                            ${creator} <br />
                        </c:forEach>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <h2>Project Time Distribution</h2>
    <div class="chart-container">
        <canvas id="projectPieChart"></canvas>
    </div>

    <h2>Task Distribution by Employee</h2>
    <div class="chart-container">
        <canvas id="employeePieChart"></canvas>
    </div>

    <script>
        $(document).ready(function() {
            var projectNames = [];
            var projectTimes = [];
            var employeeNames = [];
            var employeeTimes = [];

            <c:forEach var="summary" items="${projectSummaries.values()}">
                projectNames.push("${summary.projectName}");
                projectTimes.push(${summary.totalTime});
            </c:forEach>

            <c:forEach var="employee" items="${taskDistributionByEmployee}">
                employeeNames.push("${employee.key}");
                employeeTimes.push(${employee.value});
            </c:forEach>

            var ctxProject = document.getElementById('projectPieChart').getContext('2d');
            var projectPieChart = new Chart(ctxProject, {
                type: 'pie',
                data: {
                    labels: projectNames,
                    datasets: [{
                        label: 'Time Spent (minutes)',
                        data: projectTimes,
                        backgroundColor: [
                            '#FF6384',
                            '#36A2EB',
                            '#FFCE56',
                            '#4BC0C0',
                            '#9966FF',
                            '#FF9F40'
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'top',
                        },
                        tooltip: {
                            callbacks: {
                                label: function(tooltipItem) {
                                    var value = projectTimes[tooltipItem.dataIndex];
                                    var total = projectTimes.reduce((a, b) => a + b, 0);
                                    var percentage = ((value / total) * 100).toFixed(2);
                                    return projectNames[tooltipItem.dataIndex] + ': ' + value + ' minutes (' + percentage + '%)';
                                }
                            }
                        }
                    }
                }
            });

            var ctxEmployee = document.getElementById('employeePieChart').getContext('2d');
            var employeePieChart = new Chart(ctxEmployee, {
                type: 'pie',
                data: {
                    labels: employeeNames,
                    datasets: [{
                        label: 'Task Time (minutes)',
                        data: employeeTimes,
                        backgroundColor: [
                            '#FF6384',
                            '#36A2EB',
                            '#FFCE56',
                            '#4BC0C0',
                            '#9966FF',
                            '#FF9F40'
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'top',
                        },
                        tooltip: {
                            callbacks: {
                                label: function(tooltipItem) {
                                    var value = employeeTimes[tooltipItem.dataIndex];
                                    var total = employeeTimes.reduce((a, b) => a + b, 0);
                                    var percentage = ((value / total) * 100).toFixed(2);
                                    return employeeNames[tooltipItem.dataIndex] + ': ' + value + ' minutes (' + percentage + '%)';
                                }
                            }
                        }
                    }
                }
            });
        });
    </script>
</body>
</html>

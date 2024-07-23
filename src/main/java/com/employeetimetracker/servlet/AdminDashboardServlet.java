package com.employeetimetracker.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.employeetimetracker.model.Task;

@WebServlet("/AdminDashboardServlet")
public class AdminDashboardServlet extends HttpServlet {
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

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("email") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        List<Task> tasks = new ArrayList<>();
        Map<String, ProjectSummary> projectSummaries = new HashMap<>();
        Map<String, Long> taskDistributionByEmployee = new HashMap<>();

        String view = request.getParameter("view");
        if (view == null) {
            view = "daily"; // Set default view to "daily" if view parameter is null
        }

        Date startDate = null;
        Date endDate = new Date(System.currentTimeMillis());

        switch (view) {
            case "daily":
                startDate = getStartDateForDaily();
                break;
            case "weekly":
                startDate = getStartDateForWeekly();
                break;
            case "monthly":
                startDate = getStartDateForMonthly();
                break;
            case "yearly":
                startDate = getStartDateForYearly();
                break;
            default:
                startDate = getStartDateForDaily();
                break;
        }

        try {
            tasks = fetchTasks(startDate, endDate);
            projectSummaries = calculateProjectSummaries(tasks);
            taskDistributionByEmployee = calculateTaskDistributionByEmployee(tasks);
        } catch (SQLException e) {
            throw new ServletException("Failed to fetch data", e);
        }

        request.setAttribute("tasks", tasks);
        request.setAttribute("projectSummaries", projectSummaries);
        request.setAttribute("taskDistributionByEmployee", taskDistributionByEmployee);

        request.getRequestDispatcher("admin_dashboard.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Handle any specific actions if needed
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

    private Date getStartDateForDaily() {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_MONTH, -1);
        return new Date(cal.getTimeInMillis());
    }

    private Date getStartDateForWeekly() {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.WEEK_OF_YEAR, -1);
        return new Date(cal.getTimeInMillis());
    }

    private Date getStartDateForMonthly() {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MONTH, -1);
        return new Date(cal.getTimeInMillis());
    }

    private Date getStartDateForYearly() {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.YEAR, -1);
        return new Date(cal.getTimeInMillis());
    }

    private List<Task> fetchTasks(Date startDate, Date endDate) throws SQLException {
        List<Task> tasks = new ArrayList<>();
        String sql = "SELECT tasks.*, users.name AS creatorName " +
                     "FROM tasks " +
                     "INNER JOIN users ON tasks.user_id = users.id " +
                     "WHERE task_date BETWEEN ? AND ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setDate(1, startDate);
            statement.setDate(2, endDate);
            ResultSet rs = statement.executeQuery();
            while (rs.next()) {
                Task task = new Task();
                task.setId(rs.getInt("id"));
                task.setUserId(rs.getInt("user_id"));
                task.setProject(rs.getString("project"));
                task.setTaskDate(rs.getDate("task_date"));
                task.setStartTime(rs.getTime("start_time"));
                task.setEndTime(rs.getTime("end_time"));
                task.setTaskCategory(rs.getString("task_category"));
                task.setDescription(rs.getString("description"));
                task.setCreatorName(rs.getString("creatorName"));
                tasks.add(task);
            }
        }
        return tasks;
    }

    private Map<String, ProjectSummary> calculateProjectSummaries(List<Task> tasks) {
        Map<String, ProjectSummary> projectSummaries = new HashMap<>();
        for (Task task : tasks) {
            String projectName = task.getProject();
            long taskDuration = calculateDuration(task.getStartTime(), task.getEndTime());
            String creatorName = task.getCreatorName();

            if (projectSummaries.containsKey(projectName)) {
                ProjectSummary summary = projectSummaries.get(projectName);
                summary.setTotalTime(summary.getTotalTime() + taskDuration);
                if (!summary.getCreators().contains(creatorName)) {
                    summary.addCreator(creatorName);
                }
            } else {
                ProjectSummary summary = new ProjectSummary();
                summary.setProjectName(projectName);
                summary.setTotalTime(taskDuration);
                summary.addCreator(creatorName);
                projectSummaries.put(projectName, summary);
            }
        }
        return projectSummaries;
    }

    private Map<String, Long> calculateTaskDistributionByEmployee(List<Task> tasks) {
        Map<String, Long> distributionMap = new HashMap<>();
        for (Task task : tasks) {
            String creatorName = task.getCreatorName(); // Assuming creatorName is the employee name
            long timeSpent = calculateDuration(task.getStartTime(), task.getEndTime());
            distributionMap.put(creatorName, distributionMap.getOrDefault(creatorName, 0L) + timeSpent);
        }
        return distributionMap;
    }

    private long calculateDuration(Time startTime, Time endTime) {
        long diffInMillies = endTime.getTime() - startTime.getTime();
        return diffInMillies / (1000 * 60); // return duration in minutes
    }

    public class ProjectSummary {
        private String projectName;
        private long totalTime;
        private List<String> creators;

        public ProjectSummary() {
            creators = new ArrayList<>();
        }

        public String getProjectName() {
            return projectName;
        }

        public void setProjectName(String projectName) {
            this.projectName = projectName;
        }

        public long getTotalTime() {
            return totalTime;
        }

        public void setTotalTime(long totalTime) {
            this.totalTime = totalTime;
        }

        public List<String> getCreators() {
            return creators;
        }

        public void addCreator(String creatorName) {
            this.creators.add(creatorName);
        }
    }
}

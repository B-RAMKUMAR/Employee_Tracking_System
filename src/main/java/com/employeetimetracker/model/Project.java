package com.employeetimetracker.model;

import java.util.List;

public class Project {
    private int id;
    private String name;
    private String createdBy;
    private List<String> assignedEmployees; // List of names of employees assigned to this project

    // Constructors
    public Project() {
    }

    public Project(int id, String name, String createdBy, List<String> assignedEmployees) {
        this.id = id;
        this.name = name;
        this.createdBy = createdBy;
        this.assignedEmployees = assignedEmployees;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }

    public List<String> getAssignedEmployees() {
        return assignedEmployees;
    }

    public void setAssignedEmployees(List<String> assignedEmployees) {
        this.assignedEmployees = assignedEmployees;
    }

    // toString method for debugging or logging purposes
    @Override
    public String toString() {
        return "Project [id=" + id + ", name=" + name + ", createdBy=" + createdBy + ", assignedEmployees=" + assignedEmployees + "]";
    }
}

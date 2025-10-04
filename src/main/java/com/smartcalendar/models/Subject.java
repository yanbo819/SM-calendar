package com.smartcalendar.models;

import java.sql.Timestamp;

/**
 * Subject model class representing reusable subjects for events
 */
public class Subject {
    private int subjectId;
    private int userId;
    private String subjectName;
    private Timestamp createdAt;

    // Constructors
    public Subject() {}

    public Subject(int userId, String subjectName) {
        this.userId = userId;
        this.subjectName = subjectName;
    }

    // Getters and Setters
    public int getSubjectId() {
        return subjectId;
    }

    public void setSubjectId(int subjectId) {
        this.subjectId = subjectId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getSubjectName() {
        return subjectName;
    }

    public void setSubjectName(String subjectName) {
        this.subjectName = subjectName;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "Subject{" +
                "subjectId=" + subjectId +
                ", userId=" + userId +
                ", subjectName='" + subjectName + '\'' +
                '}';
    }
}
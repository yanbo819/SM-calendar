package com.smartcalendar.models;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

/**
 * Event model class representing a calendar event or reminder
 */
public class Event {
    private int eventId;
    private int userId;
    private int categoryId;
    private int subjectId;
    private String title;
    private String description;
    private Date eventDate;
    private Time eventTime;
    private int durationMinutes;
    private String location;
    private String notes;
    private int reminderMinutesBefore;
    private boolean isRecurring;
    private String recurringPattern;
    private Date recurringEndDate;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean isActive;
    
    // Additional fields for joined data
    private String categoryName;
    private String categoryColor;
    private String subjectName;

    // Constructors
    public Event() {}

    public Event(int userId, String title, Date eventDate, Time eventTime) {
        this.userId = userId;
        this.title = title;
        this.eventDate = eventDate;
        this.eventTime = eventTime;
        this.durationMinutes = 60; // default 1 hour
        this.reminderMinutesBefore = 15; // default 15 minutes
        this.isRecurring = false;
        this.isActive = true;
    }

    // Getters and Setters
    public int getEventId() {
        return eventId;
    }

    public void setEventId(int eventId) {
        this.eventId = eventId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public int getSubjectId() {
        return subjectId;
    }

    public void setSubjectId(int subjectId) {
        this.subjectId = subjectId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Date getEventDate() {
        return eventDate;
    }

    public void setEventDate(Date eventDate) {
        this.eventDate = eventDate;
    }

    public Time getEventTime() {
        return eventTime;
    }

    public void setEventTime(Time eventTime) {
        this.eventTime = eventTime;
    }

    public int getDurationMinutes() {
        return durationMinutes;
    }

    public void setDurationMinutes(int durationMinutes) {
        this.durationMinutes = durationMinutes;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public int getReminderMinutesBefore() {
        return reminderMinutesBefore;
    }

    public void setReminderMinutesBefore(int reminderMinutesBefore) {
        this.reminderMinutesBefore = reminderMinutesBefore;
    }

    public boolean isRecurring() {
        return isRecurring;
    }

    public void setRecurring(boolean recurring) {
        isRecurring = recurring;
    }

    public String getRecurringPattern() {
        return recurringPattern;
    }

    public void setRecurringPattern(String recurringPattern) {
        this.recurringPattern = recurringPattern;
    }

    public Date getRecurringEndDate() {
        return recurringEndDate;
    }

    public void setRecurringEndDate(Date recurringEndDate) {
        this.recurringEndDate = recurringEndDate;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getCategoryColor() {
        return categoryColor;
    }

    public void setCategoryColor(String categoryColor) {
        this.categoryColor = categoryColor;
    }

    public String getSubjectName() {
        return subjectName;
    }

    public void setSubjectName(String subjectName) {
        this.subjectName = subjectName;
    }

    @Override
    public String toString() {
        return "Event{" +
                "eventId=" + eventId +
                ", userId=" + userId +
                ", title='" + title + '\'' +
                ", eventDate=" + eventDate +
                ", eventTime=" + eventTime +
                ", categoryName='" + categoryName + '\'' +
                ", isActive=" + isActive +
                '}';
    }
}
package com.smartcalendar.models;

import java.sql.Timestamp;

public class Notification {
    private int notificationId;
    private Integer eventId; // nullable
    private int userId;
    private String message;
    private Timestamp notificationTime;
    private boolean sent;
    private Timestamp createdAt;

    public int getNotificationId() { return notificationId; }
    public void setNotificationId(int notificationId) { this.notificationId = notificationId; }
    public Integer getEventId() { return eventId; }
    public void setEventId(Integer eventId) { this.eventId = eventId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public Timestamp getNotificationTime() { return notificationTime; }
    public void setNotificationTime(Timestamp notificationTime) { this.notificationTime = notificationTime; }
    public boolean isSent() { return sent; }
    public void setSent(boolean sent) { this.sent = sent; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}

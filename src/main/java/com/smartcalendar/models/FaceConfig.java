package com.smartcalendar.models;

import java.sql.Time;
import java.sql.Timestamp;

public class FaceConfig {
    private int id;
    private int dayOfWeek; // 1=Mon .. 7=Sun
    private Time startTime;
    private Time endTime;
    private boolean active;
    private Timestamp createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(int dayOfWeek) { this.dayOfWeek = dayOfWeek; }
    public Time getStartTime() { return startTime; }
    public void setStartTime(Time startTime) { this.startTime = startTime; }
    public Time getEndTime() { return endTime; }
    public void setEndTime(Time endTime) { this.endTime = endTime; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}

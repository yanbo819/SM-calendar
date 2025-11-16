package com.smartcalendar.models;

import java.sql.Timestamp;

public class Location {
    private int locationId;
    private String name;
    private String category; // gate, hospital, immigration, other
    private String description;
    private String mapUrl;
    private boolean active;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public int getLocationId() { return locationId; }
    public void setLocationId(int locationId) { this.locationId = locationId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getMapUrl() { return mapUrl; }
    public void setMapUrl(String mapUrl) { this.mapUrl = mapUrl; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}

package com.smartcalendar.models;

import java.sql.Timestamp;

/**
 * User model class representing a user in the Smart Calendar system
 */
public class User {
    private int userId;
    private String email;
    private String phoneNumber;
    private String fullName;
    private String passwordHash;
    private String preferredLanguage;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean isActive;

    // Constructors
    public User() {}

    public User(String email, String fullName, String passwordHash, String preferredLanguage) {
        this.email = email;
        this.fullName = fullName;
        this.passwordHash = passwordHash;
        this.preferredLanguage = preferredLanguage;
        this.isActive = true;
    }

    // Getters and Setters
    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getPreferredLanguage() {
        return preferredLanguage;
    }

    public void setPreferredLanguage(String preferredLanguage) {
        this.preferredLanguage = preferredLanguage;
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

    @Override
    public String toString() {
        return "User{" +
                "userId=" + userId +
                ", email='" + email + '\'' +
                ", fullName='" + fullName + '\'' +
                ", preferredLanguage='" + preferredLanguage + '\'' +
                ", isActive=" + isActive +
                '}';
    }
}
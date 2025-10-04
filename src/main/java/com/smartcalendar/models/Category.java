package com.smartcalendar.models;

/**
 * Category model class representing event categories
 */
public class Category {
    private int categoryId;
    private String categoryName;
    private String categoryColor;
    private boolean isSystemCategory;

    // Constructors
    public Category() {}

    public Category(String categoryName, String categoryColor) {
        this.categoryName = categoryName;
        this.categoryColor = categoryColor;
        this.isSystemCategory = false;
    }

    // Getters and Setters
    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
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

    public boolean isSystemCategory() {
        return isSystemCategory;
    }

    public void setSystemCategory(boolean systemCategory) {
        isSystemCategory = systemCategory;
    }

    @Override
    public String toString() {
        return "Category{" +
                "categoryId=" + categoryId +
                ", categoryName='" + categoryName + '\'' +
                ", categoryColor='" + categoryColor + '\'' +
                ", isSystemCategory=" + isSystemCategory +
                '}';
    }
}
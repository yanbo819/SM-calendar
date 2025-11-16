package com.smartcalendar.dao;

import com.smartcalendar.models.Location;
import com.smartcalendar.utils.DatabaseUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LocationDao {
    public static List<Location> listByCategory(String category) throws SQLException {
        List<Location> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT location_id, name, category, description, map_url, is_active, created_at, updated_at FROM locations WHERE category = ? AND is_active = TRUE ORDER BY name")) {
            ps.setString(1, category);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Location l = map(rs);
                list.add(l);
            }
        }
        return list;
    }

    public static List<Location> listAll() throws SQLException {
        List<Location> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT location_id, name, category, description, map_url, is_active, created_at, updated_at FROM locations ORDER BY category, name")) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public static void insert(Location l) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("INSERT INTO locations (name, category, description, map_url, is_active) VALUES (?,?,?,?,?)")) {
            ps.setString(1, l.getName());
            ps.setString(2, l.getCategory());
            ps.setString(3, l.getDescription());
            ps.setString(4, l.getMapUrl());
            ps.setBoolean(5, l.isActive());
            ps.executeUpdate();
        }
    }

    public static void update(Location l) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE locations SET name=?, category=?, description=?, map_url=?, is_active=? , updated_at=CURRENT_TIMESTAMP WHERE location_id=?")) {
            ps.setString(1, l.getName());
            ps.setString(2, l.getCategory());
            ps.setString(3, l.getDescription());
            ps.setString(4, l.getMapUrl());
            ps.setBoolean(5, l.isActive());
            ps.setInt(6, l.getLocationId());
            ps.executeUpdate();
        }
    }

    public static void delete(int id) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM locations WHERE location_id=?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private static Location map(ResultSet rs) throws SQLException {
        Location l = new Location();
        l.setLocationId(rs.getInt("location_id"));
        l.setName(rs.getString("name"));
        l.setCategory(rs.getString("category"));
        l.setDescription(rs.getString("description"));
        l.setMapUrl(rs.getString("map_url"));
        l.setActive(rs.getBoolean("is_active"));
        l.setCreatedAt(rs.getTimestamp("created_at"));
        l.setUpdatedAt(rs.getTimestamp("updated_at"));
        return l;
    }
}

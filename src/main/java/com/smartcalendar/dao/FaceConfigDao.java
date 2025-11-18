package com.smartcalendar.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.smartcalendar.models.FaceConfig;
import com.smartcalendar.utils.DatabaseUtil;

public class FaceConfigDao {
    public static List<FaceConfig> getActiveWindows() throws SQLException {
        List<FaceConfig> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT id, day_of_week, start_time, end_time, is_active, created_at FROM face_config WHERE is_active = TRUE ORDER BY day_of_week, start_time")) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public static void insert(FaceConfig fc) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("INSERT INTO face_config (day_of_week, start_time, end_time, is_active) VALUES (?,?,?,?)")) {
            ps.setInt(1, fc.getDayOfWeek());
            ps.setTime(2, fc.getStartTime());
            ps.setTime(3, fc.getEndTime());
            ps.setBoolean(4, fc.isActive());
            ps.executeUpdate();
        }
    }

    public static void update(FaceConfig fc) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE face_config SET day_of_week=?, start_time=?, end_time=?, is_active=? WHERE id=?")) {
            ps.setInt(1, fc.getDayOfWeek());
            ps.setTime(2, fc.getStartTime());
            ps.setTime(3, fc.getEndTime());
            ps.setBoolean(4, fc.isActive());
            ps.setInt(5, fc.getId());
            ps.executeUpdate();
        }
    }

    public static void delete(int id) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM face_config WHERE id=?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private static FaceConfig map(ResultSet rs) throws SQLException {
        FaceConfig fc = new FaceConfig();
        fc.setId(rs.getInt("id"));
        fc.setDayOfWeek(rs.getInt("day_of_week"));
        fc.setStartTime(rs.getTime("start_time"));
        fc.setEndTime(rs.getTime("end_time"));
        fc.setActive(rs.getBoolean("is_active"));
        fc.setCreatedAt(rs.getTimestamp("created_at"));
        return fc;
    }
}

package com.smartcalendar.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.smartcalendar.models.FaceEnrollment;
import com.smartcalendar.utils.DatabaseUtil;

public class UserFaceDao {
    public static boolean hasFace(int userId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM user_faces WHERE user_id = ?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    public static void upsertFace(int userId, byte[] imageBytes, String phash) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection()) {
            // Try update first
            try (PreparedStatement upd = conn.prepareStatement("UPDATE user_faces SET image = ?, phash = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?")) {
                upd.setBytes(1, imageBytes);
                upd.setString(2, phash);
                upd.setInt(3, userId);
                int n = upd.executeUpdate();
                if (n > 0) return;
            }
            // Insert if not exists
            try (PreparedStatement ins = conn.prepareStatement("INSERT INTO user_faces (user_id, image, phash) VALUES (?,?,?)")) {
                ins.setInt(1, userId);
                ins.setBytes(2, imageBytes);
                ins.setString(3, phash);
                ins.executeUpdate();
            }
        }
    }

    public static String getPHash(int userId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT phash FROM user_faces WHERE user_id = ?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getString(1) : null; }
        }
    }

    public static byte[] getImage(int userId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT image FROM user_faces WHERE user_id = ?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getBytes(1) : null; }
        }
    }

    public static List<FaceEnrollment> listEnrollments() throws SQLException {
        String sql = "SELECT u.user_id, u.full_name, u.username, f.created_at, f.updated_at, a.latitude, a.longitude, a.created_at AS attempt_time " +
                "FROM user_faces f JOIN users u ON f.user_id = u.user_id " +
                "LEFT JOIN faceid_attempts a ON a.id = (SELECT id FROM faceid_attempts fa WHERE fa.user_id = f.user_id AND fa.action='register' ORDER BY fa.created_at DESC LIMIT 1) " +
                "ORDER BY COALESCE(attempt_time, f.created_at) DESC";
        List<FaceEnrollment> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                FaceEnrollment fe = new FaceEnrollment();
                fe.setUserId(rs.getInt(1));
                fe.setFullName(rs.getString(2));
                fe.setUsername(rs.getString(3));
                fe.setCreatedAt(rs.getTimestamp(4));
                fe.setUpdatedAt(rs.getTimestamp(5));
                fe.setLatitude(rs.getObject(6) != null ? rs.getDouble(6) : null);
                fe.setLongitude(rs.getObject(7) != null ? rs.getDouble(7) : null);
                fe.setAttemptTime(rs.getTimestamp(8));
                list.add(fe);
            }
        }
        return list;
    }
}

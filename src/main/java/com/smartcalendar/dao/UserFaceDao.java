package com.smartcalendar.dao;

import java.sql.*;
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

    public static void upsertFace(int userId, byte[] imageBytes, String phash, Double lat, Double lon) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection()) {
            // Try update first
            try (PreparedStatement upd = conn.prepareStatement("UPDATE user_faces SET image = ?, phash = ?, latitude = ?, longitude = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?")) {
                upd.setBytes(1, imageBytes);
                upd.setString(2, phash);
                if (lat != null) upd.setDouble(3, lat); else upd.setNull(3, java.sql.Types.DOUBLE);
                if (lon != null) upd.setDouble(4, lon); else upd.setNull(4, java.sql.Types.DOUBLE);
                upd.setInt(5, userId);
                int n = upd.executeUpdate();
                if (n > 0) return;
            }
            // Insert if not exists
            try (PreparedStatement ins = conn.prepareStatement("INSERT INTO user_faces (user_id, image, phash, latitude, longitude) VALUES (?,?,?,?,?)")) {
                ins.setInt(1, userId);
                ins.setBytes(2, imageBytes);
                ins.setString(3, phash);
                if (lat != null) ins.setDouble(4, lat); else ins.setNull(4, java.sql.Types.DOUBLE);
                if (lon != null) ins.setDouble(5, lon); else ins.setNull(5, java.sql.Types.DOUBLE);
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
        String sql = "SELECT u.user_id, u.full_name, u.username, f.created_at, f.updated_at, f.latitude, f.longitude FROM user_faces f JOIN users u ON f.user_id = u.user_id ORDER BY f.created_at DESC";
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
                list.add(fe);
            }
        }
        return list;
    }
}

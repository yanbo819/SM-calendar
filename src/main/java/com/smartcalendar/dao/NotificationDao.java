package com.smartcalendar.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import com.smartcalendar.models.Notification;
import com.smartcalendar.utils.DatabaseUtil;

public class NotificationDao {

    public static List<Notification> listDueForUser(int userId) throws SQLException {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT notification_id, event_id, user_id, message, notification_time, is_sent, created_at " +
                     "FROM notifications WHERE user_id=? AND is_sent=FALSE AND notification_time <= CURRENT_TIMESTAMP ORDER BY notification_time";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public static List<Notification> listUpcomingForUser(int userId, int limit) throws SQLException {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT notification_id, event_id, user_id, message, notification_time, is_sent, created_at " +
                     "FROM notifications WHERE user_id=? AND is_sent=FALSE AND notification_time > CURRENT_TIMESTAMP ORDER BY notification_time LIMIT ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public static void markSent(List<Integer> ids) throws SQLException {
        if (ids == null || ids.isEmpty()) return;
        StringBuilder sb = new StringBuilder("UPDATE notifications SET is_sent=TRUE WHERE notification_id IN (");
        for (int i = 0; i < ids.size(); i++) {
            if (i > 0) sb.append(',');
            sb.append('?');
        }
        sb.append(')');
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sb.toString())) {
            for (int i = 0; i < ids.size(); i++) ps.setInt(i + 1, ids.get(i));
            ps.executeUpdate();
        }
    }

    public static void create(Integer eventId, int userId, String message, Timestamp notificationTime) throws SQLException {
        String sql = "INSERT INTO notifications (event_id, user_id, message, notification_time) VALUES (?,?,?,?)";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            if (eventId == null) ps.setNull(1, Types.INTEGER); else ps.setInt(1, eventId);
            ps.setInt(2, userId);
            ps.setString(3, message);
            ps.setTimestamp(4, notificationTime);
            ps.executeUpdate();
        }
    }

    private static Notification map(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setNotificationId(rs.getInt("notification_id"));
        int ev = rs.getInt("event_id");
        n.setEventId(rs.wasNull() ? null : ev);
        n.setUserId(rs.getInt("user_id"));
        n.setMessage(rs.getString("message"));
        n.setNotificationTime(rs.getTimestamp("notification_time"));
        n.setSent(rs.getBoolean("is_sent"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        return n;
    }
}

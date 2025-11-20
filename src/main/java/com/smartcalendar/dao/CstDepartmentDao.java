package com.smartcalendar.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.smartcalendar.models.CstDepartment;
import com.smartcalendar.utils.DatabaseUtil;

public class CstDepartmentDao {
    public static List<CstDepartment> listAll() throws SQLException {
        List<CstDepartment> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT id, name, leader_name, leader_phone, created_at FROM cst_departments ORDER BY name")) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public static CstDepartment findById(int id) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT id, name, leader_name, leader_phone, created_at FROM cst_departments WHERE id=?")) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        }
        return null;
    }

    public static void insert(String name, String leaderName, String leaderPhone) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("INSERT INTO cst_departments (name, leader_name, leader_phone) VALUES (?, ?, ?)")) {
            ps.setString(1, name);
            ps.setString(2, leaderName);
            ps.setString(3, leaderPhone);
            ps.executeUpdate();
        }
    }

    public static void update(int id, String name, String leaderName, String leaderPhone) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE cst_departments SET name=?, leader_name=?, leader_phone=? WHERE id=?")) {
            ps.setString(1, name);
            ps.setString(2, leaderName);
            ps.setString(3, leaderPhone);
            ps.setInt(4, id);
            ps.executeUpdate();
        }
    }

    public static void delete(int id) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM cst_departments WHERE id=?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private static CstDepartment map(ResultSet rs) throws SQLException {
        CstDepartment d = new CstDepartment();
        d.setId(rs.getInt("id"));
        d.setName(rs.getString("name"));
        d.setLeaderName(rs.getString("leader_name"));
        d.setLeaderPhone(rs.getString("leader_phone"));
        d.setCreatedAt(rs.getTimestamp("created_at"));
        return d;
    }
}

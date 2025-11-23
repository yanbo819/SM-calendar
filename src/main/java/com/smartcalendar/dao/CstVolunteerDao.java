package com.smartcalendar.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.smartcalendar.models.CstVolunteer;
import com.smartcalendar.utils.DatabaseUtil;

public class CstVolunteerDao {
    public static List<CstVolunteer> listByDepartment(int departmentId) throws SQLException {
        List<CstVolunteer> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT id, department_id, phone, student_id, passport_name, chinese_name, gender, nationality, email, photo_url, is_active, created_at FROM cst_volunteers WHERE department_id=? AND is_active=TRUE ORDER BY created_at DESC")) {
            ps.setInt(1, departmentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public static void insert(CstVolunteer v) throws SQLException {
        String sql = "INSERT INTO cst_volunteers (department_id, phone, student_id, passport_name, chinese_name, gender, nationality, email, photo_url, is_active) VALUES (?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, v.getDepartmentId());
            ps.setString(2, v.getPhone());
            ps.setString(3, v.getStudentId());
            ps.setString(4, v.getPassportName());
            ps.setString(5, v.getChineseName());
            ps.setString(6, v.getGender());
            ps.setString(7, v.getNationality());
            ps.setString(8, v.getEmail());
            ps.setString(9, v.getPhotoUrl());
            ps.setBoolean(10, v.isActive());
            ps.executeUpdate();
        }
    }

    public static int insertReturningId(CstVolunteer v) throws SQLException {
        String sql = "INSERT INTO cst_volunteers (department_id, phone, student_id, passport_name, chinese_name, gender, nationality, email, photo_url, is_active) VALUES (?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, v.getDepartmentId());
            ps.setString(2, v.getPhone());
            ps.setString(3, v.getStudentId());
            ps.setString(4, v.getPassportName());
            ps.setString(5, v.getChineseName());
            ps.setString(6, v.getGender());
            ps.setString(7, v.getNationality());
            ps.setString(8, v.getEmail());
            ps.setString(9, v.getPhotoUrl());
            ps.setBoolean(10, v.isActive());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    public static void update(CstVolunteer v) throws SQLException {
        String sql = "UPDATE cst_volunteers SET department_id=?, phone=?, student_id=?, passport_name=?, chinese_name=?, gender=?, nationality=?, email=?, photo_url=?, is_active=? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, v.getDepartmentId());
            ps.setString(2, v.getPhone());
            ps.setString(3, v.getStudentId());
            ps.setString(4, v.getPassportName());
            ps.setString(5, v.getChineseName());
            ps.setString(6, v.getGender());
            ps.setString(7, v.getNationality());
            ps.setString(8, v.getEmail());
            ps.setString(9, v.getPhotoUrl());
            ps.setBoolean(10, v.isActive());
            ps.setInt(11, v.getId());
            ps.executeUpdate();
        }
    }

    public static void delete(int id) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM cst_volunteers WHERE id=?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    public static CstVolunteer findById(int id) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT id, department_id, phone, student_id, passport_name, chinese_name, gender, nationality, email, photo_url, is_active, created_at FROM cst_volunteers WHERE id=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    private static CstVolunteer map(ResultSet rs) throws SQLException {
        CstVolunteer v = new CstVolunteer();
        v.setId(rs.getInt("id"));
        v.setDepartmentId(rs.getInt("department_id"));
        v.setPhone(rs.getString("phone"));
        v.setStudentId(rs.getString("student_id"));
        v.setPassportName(rs.getString("passport_name"));
        v.setChineseName(rs.getString("chinese_name"));
        v.setGender(rs.getString("gender"));
        v.setNationality(rs.getString("nationality"));
        try { v.setEmail(rs.getString("email")); } catch (SQLException ignore) { v.setEmail(null); }
        v.setPhotoUrl(rs.getString("photo_url"));
        v.setActive(rs.getBoolean("is_active"));
        v.setCreatedAt(rs.getTimestamp("created_at"));
        return v;
    }
}

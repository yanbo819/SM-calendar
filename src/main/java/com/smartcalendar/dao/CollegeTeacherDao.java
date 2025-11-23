package com.smartcalendar.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.smartcalendar.models.CollegeTeacher;
import com.smartcalendar.utils.DatabaseUtil;

public class CollegeTeacherDao {

    private static void ensureTable() throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             Statement st = conn.createStatement()) {
            st.executeUpdate("CREATE TABLE IF NOT EXISTS college_teachers (" +
                    "id INT PRIMARY KEY AUTO_INCREMENT," +
                    "college_name VARCHAR(255) NOT NULL," +
                    "teacher_name VARCHAR(255) NOT NULL," +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                    ")");
            try {
                st.executeUpdate("CREATE INDEX IF NOT EXISTS idx_college_name ON college_teachers(college_name)");
            } catch (SQLException ignored) {
                // Index creation failure is non-fatal
            }
        }
    }

    public static List<CollegeTeacher> listAll() throws SQLException {
        ensureTable();
        List<CollegeTeacher> list = new ArrayList<>();
        String sql = "SELECT id, college_name, teacher_name FROM college_teachers ORDER BY college_name, teacher_name";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                CollegeTeacher ct = new CollegeTeacher();
                ct.setId(rs.getInt(1));
                ct.setCollegeName(rs.getString(2));
                ct.setTeacherName(rs.getString(3));
                list.add(ct);
            }
        }
        return list;
    }

    public static void insert(String college, String teacher) throws SQLException {
        ensureTable();
        String sql = "INSERT INTO college_teachers (college_name, teacher_name) VALUES (?,?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, college);
            ps.setString(2, teacher);
            ps.executeUpdate();
        }
    }

    public static boolean update(int id, String teacher) throws SQLException {
        ensureTable();
        String sql = "UPDATE college_teachers SET teacher_name=? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, teacher);
            ps.setInt(2, id);
            return ps.executeUpdate() == 1;
        }
    }

    public static boolean delete(int id) throws SQLException {
        ensureTable();
        String sql = "DELETE FROM college_teachers WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() == 1;
        }
    }

    public static Map<String, List<CollegeTeacher>> groupedByCollege() throws SQLException {
        List<CollegeTeacher> all = listAll();
        Map<String, List<CollegeTeacher>> map = new LinkedHashMap<>();
        for (CollegeTeacher ct : all) {
            map.computeIfAbsent(ct.getCollegeName(), k -> new ArrayList<>()).add(ct);
        }
        return map;
    }
}
package com.smartcalendar.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.smartcalendar.models.College;

public class CollegeDao {
    public static List<College> listAll() {
        List<College> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM colleges")) {
            while (rs.next()) {
                College c = new College();
                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                c.setAddress(rs.getString("address"));
                c.setPhone(rs.getString("phone"));
                c.setTeacherName(rs.getString("teacher_name"));
                c.setTeacherPhotoUrl(rs.getString("teacher_photo_url"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public static College findById(int id) {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement("SELECT * FROM colleges WHERE id = ?")) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    College c = new College();
                    c.setId(rs.getInt("id"));
                    c.setName(rs.getString("name"));
                    c.setAddress(rs.getString("address"));
                    c.setPhone(rs.getString("phone"));
                    c.setTeacherName(rs.getString("teacher_name"));
                    c.setTeacherPhotoUrl(rs.getString("teacher_photo_url"));
                    return c;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static void update(College c) {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                "UPDATE colleges SET name=?, address=?, phone=?, teacher_name=?, teacher_photo_url=? WHERE id=?")) {
            stmt.setString(1, c.getName());
            stmt.setString(2, c.getAddress());
            stmt.setString(3, c.getPhone());
            stmt.setString(4, c.getTeacherName());
            stmt.setString(5, c.getTeacherPhotoUrl());
            stmt.setInt(6, c.getId());
            stmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

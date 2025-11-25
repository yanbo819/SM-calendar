package com.smartcalendar.utils;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import com.smartcalendar.models.CstDepartment;

/**
 * Utility methods to filter departments into logical volunteer categories.
 * Filtering is name-based for now; later can be replaced with explicit DB fields.
 */
public final class DepartmentFilterUtil {
    private DepartmentFilterUtil() {}

    public static List<CstDepartment> filterBusiness(List<CstDepartment> all) {
        List<CstDepartment> out = new ArrayList<>();
        if (all == null) return out;
        for (CstDepartment d : all) {
            String n = safe(d.getName());
            if (n.contains("business") || n.contains("admin") || n.contains("management") || n.contains("finance")) {
                out.add(d);
            }
        }
        return out;
    }

    public static List<CstDepartment> filterChinese(List<CstDepartment> all) {
        List<CstDepartment> out = new ArrayList<>();
        if (all == null) return out;
        for (CstDepartment d : all) {
            String n = safe(d.getName());
            if (n.contains("chinese") || n.contains("mandarin") || n.contains("中文") || n.contains("语言") || n.contains("culture")) {
                out.add(d);
            }
        }
        return out;
    }

    private static String safe(String s) { return s == null ? "" : s.toLowerCase(Locale.ROOT); }
}

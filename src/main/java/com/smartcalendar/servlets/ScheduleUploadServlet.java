package com.smartcalendar.servlets;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Types;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.smartcalendar.models.User;
import com.smartcalendar.utils.DatabaseUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

/**
 * Servlet to upload and import course schedule from CSV
 */
@MultipartConfig
public class ScheduleUploadServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Part filePart = request.getPart("file");
        if (filePart == null || filePart.getSize() == 0) {
            request.setAttribute("errorMessage", "Please choose a CSV or ICS file to upload.");
            request.getRequestDispatcher("schedule-upload.jsp").forward(request, response);
            return;
        }

        int imported = 0;
        String filename = getSubmittedFileName(filePart);
        boolean isIcs = filename != null && filename.toLowerCase().endsWith(".ics");
        boolean isPdf = filename != null && filename.toLowerCase().endsWith(".pdf");
        try {
            if (isIcs) {
                imported = importIcs(filePart.getInputStream(), user.getUserId());
            } else if (isPdf) {
                imported = importPdf(filePart.getInputStream(), user.getUserId());
            } else {
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(filePart.getInputStream(), StandardCharsets.UTF_8))) {
                    String line;
                    boolean headerSkipped = false;
                    while ((line = reader.readLine()) != null) {
                        if (!headerSkipped) { headerSkipped = true; continue; }
                        String[] cols = line.split(",");
                        if (cols.length < 8) continue; // skip invalid rows
                        String title = cols[0].trim();
                        String categoryName = cols[1].trim();
                        String subjectName = cols[2].trim();
                        String date = cols[3].trim();
                        String time = cols[4].trim();
                        int duration = parseIntOr(cols[5].trim(), 60);
                        String location = cols[6].trim();
                        int reminder = parseIntOr(cols[7].trim(), 15);

                        if (title.isEmpty() || date.isEmpty() || time.isEmpty()) continue;
                        importRow(user.getUserId(), title, categoryName, subjectName, date, time, duration, location, reminder);
                        imported++;
                    }
                }
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Failed to import schedule: " + e.getMessage());
            request.getRequestDispatcher("schedule-upload.jsp").forward(request, response);
            return;
        }

        request.setAttribute("successMessage", "Imported " + imported + " events from schedule.");
        request.getRequestDispatcher("schedule-upload.jsp").forward(request, response);
    }

    private int importIcs(InputStream in, int userId) throws Exception {
        // Very lightweight .ics parser for common properties from VEVENT blocks
        int count = 0;
        String defaultCategory = "Schedule";

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8))) {
            boolean inEvent = false;
            java.util.List<String> eventLines = new java.util.ArrayList<>();
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.startsWith("BEGIN:VEVENT")) {
                    inEvent = true;
                    eventLines.clear();
                    continue;
                }
                if (inEvent) {
                    if (line.startsWith(" ") || line.startsWith("\t")) {
                        // unfolded line continuation
                        if (!eventLines.isEmpty()) {
                            int last = eventLines.size() - 1;
                            eventLines.set(last, eventLines.get(last) + line.trim());
                        }
                        continue;
                    }
                    if (line.startsWith("END:VEVENT")) {
                        // process current event
                        String summary = null;
                        String location = "";
                        String dtStart = null;
                        String dtEnd = null;
                        for (String pl : eventLines) {
                            int idx = pl.indexOf(':');
                            if (idx <= 0) continue;
                            String key = pl.substring(0, idx);
                            String value = pl.substring(idx + 1).trim();
                            if (key.startsWith("SUMMARY")) summary = value;
                            else if (key.startsWith("LOCATION")) location = value;
                            else if (key.startsWith("DTSTART")) dtStart = value;
                            else if (key.startsWith("DTEND")) dtEnd = value;
                        }

                        if (dtStart != null) {
                            LocalDateTime startLdt = parseIcsDateTime(dtStart);
                            LocalDateTime endLdt = (dtEnd != null) ? parseIcsDateTime(dtEnd) : null;
                            int duration = (endLdt != null) ? (int) Math.max(1, ChronoUnit.MINUTES.between(startLdt, endLdt)) : 60;
                            LocalDate date = startLdt.toLocalDate();
                            LocalTime time = startLdt.toLocalTime();
                            String dateStr = date.toString();
                            String timeStr = time.truncatedTo(ChronoUnit.MINUTES).format(DateTimeFormatter.ofPattern("HH:mm"));
                            if (summary == null || summary.isEmpty()) summary = "(No title)";
                            importRow(userId, summary, defaultCategory, null, dateStr, timeStr, duration, location, 15);
                            count++;
                        }

                        inEvent = false;
                        eventLines.clear();
                    } else {
                        eventLines.add(line);
                    }
                }
            }
        }

        return count;
    }

    private LocalDateTime parseIcsDateTime(String value) {
        // Handle common ICS datetime forms with optional seconds and timezone:
        // yyyyMMdd, yyyyMMdd'T'HHmm, yyyyMMdd'T'HHmmss, with optional 'Z' or numeric offset.
        String v = value.trim();
        // Try with zone and seconds
        try {
            Instant inst = Instant.from(DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmmssX").parse(v));
            return LocalDateTime.ofInstant(inst, ZoneId.systemDefault());
        } catch (Exception ignore) {}
        // Try with zone and no seconds
        try {
            Instant inst = Instant.from(DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmmX").parse(v));
            return LocalDateTime.ofInstant(inst, ZoneId.systemDefault());
        } catch (Exception ignore) {}
        // UTC Z with seconds
        try {
            if (v.endsWith("Z")) {
                Instant inst = Instant.from(DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmmssX").parse(v));
                return LocalDateTime.ofInstant(inst, ZoneId.systemDefault());
            }
        } catch (Exception ignore) {}
        // Local without zone, with seconds
        try {
            return LocalDateTime.parse(v, DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmmss"));
        } catch (Exception ignore) {}
        // Local without zone, no seconds
        try {
            return LocalDateTime.parse(v, DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmm"));
        } catch (Exception ignore) {}
        // Date-only -> default to 09:00
        try {
            LocalDate d = LocalDate.parse(v, DateTimeFormatter.ofPattern("yyyyMMdd"));
            return d.atTime(9, 0);
        } catch (Exception ignore) {}
        // Fallback: now
        return LocalDateTime.now();
    }

    private int importPdf(InputStream in, int userId) throws Exception {
        // Extract text and parse lines into events using multiple flexible patterns.
        int count = 0;
        String defaultCategory = "Schedule";

        String text;
        try (org.apache.pdfbox.pdmodel.PDDocument doc = org.apache.pdfbox.pdmodel.PDDocument.load(in)) {
            org.apache.pdfbox.text.PDFTextStripper stripper = new org.apache.pdfbox.text.PDFTextStripper();
            stripper.setSortByPosition(true);
            text = stripper.getText(doc);
        }
        if (text == null || text.isEmpty()) return 0;

        // Patterns we try (ordered):
        // 1. Title yyyy-MM-dd HH:mm[-HH:mm] @ Location
        Pattern p1 = Pattern.compile("^(.*?)\\s+(\\d{4}-\\d{2}-\\d{2})\\s+(\\d{1,2}:\\d{2})(?:\\s*(?:-|–|to)\\s*(\\d{1,2}:\\d{2}))?\\s*(?:@\\s*(.+))?$");
        // 2. Title @ Location yyyy-MM-dd HH:mm[-HH:mm]
        Pattern p2 = Pattern.compile("^(.*?)\\s*@\\s*(.+?)\\s+(\\d{4}-\\d{2}-\\d{2})\\s+(\\d{1,2}:\\d{2})(?:\\s*(?:-|–|to)\\s*(\\d{1,2}:\\d{2}))?$");
        // 3. Title yyyy-MM-dd HH:mm(AM/PM)[-HH:mm(AM/PM)] @ Location
        Pattern p3 = Pattern.compile("^(.*?)\\s+(\\d{4}-\\d{2}-\\d{2})\\s+(\\d{1,2}:\\d{2})(AM|PM|am|pm)?(?:\\s*(?:-|–|to)\\s*(\\d{1,2}:\\d{2})(AM|PM|am|pm)?)?\\s*(?:@\\s*(.+))?$");
        // 4. Title dd/MM/yyyy HH:mm(AM/PM)[-HH:mm(AM/PM)] @ Location
        Pattern p4 = Pattern.compile("^(.*?)\\s+(\\d{2}/\\d{2}/\\d{4})\\s+(\\d{1,2}:\\d{2})(AM|PM|am|pm)?(?:\\s*(?:-|–|to)\\s*(\\d{1,2}:\\d{2})(AM|PM|am|pm)?)?\\s*(?:@\\s*(.+))?$");
        // 5. Title yyyy-MM-dd HH:mm[-HH:mm] Location   (no @, location last token(s))
        Pattern p5 = Pattern.compile("^(.*?)\\s+(\\d{4}-\\d{2}-\\d{2})\\s+(\\d{1,2}:\\d{2})(?:\\s*(?:-|–|to)\\s*(\\d{1,2}:\\d{2}))?\\s+(.+)$");

        String[] lines = text.split("(?:\\r?\\n)+");
        for (String raw : lines) {
            String line = raw.trim();
            if (line.isEmpty()) continue;

            String title = null;
            String dateStr = null;
            String startStr = null;
            String startSuffix = null;
            String endStr = null;
            String endSuffix = null;
            String location = "";

            Matcher m = p1.matcher(line);
            if (m.find()) {
                title = m.group(1).trim();
                dateStr = m.group(2);
                startStr = m.group(3);
                endStr = m.group(4);
                if (m.groupCount() >= 5 && m.group(5) != null) location = m.group(5).trim();
            } else if ((m = p2.matcher(line)).find()) {
                title = m.group(1).trim();
                location = m.group(2).trim();
                dateStr = m.group(3);
                startStr = m.group(4);
                endStr = m.group(5);
            } else if ((m = p3.matcher(line)).find()) {
                title = m.group(1).trim();
                dateStr = m.group(2);
                startStr = m.group(3);
                startSuffix = m.group(4);
                endStr = m.group(5);
                endSuffix = m.group(6);
                if (m.groupCount() >= 7 && m.group(7) != null) location = m.group(7).trim();
            } else if ((m = p4.matcher(line)).find()) {
                title = m.group(1).trim();
                dateStr = normalizeSlashDate(m.group(2));
                startStr = m.group(3);
                startSuffix = m.group(4);
                endStr = m.group(5);
                endSuffix = m.group(6);
                if (m.groupCount() >= 7 && m.group(7) != null) location = m.group(7).trim();
            } else if ((m = p5.matcher(line)).find()) {
                title = m.group(1).trim();
                dateStr = m.group(2);
                startStr = m.group(3);
                endStr = m.group(4);
                location = m.group(5).trim();
            } else {
                // Heuristic fallback: look for a date and time anywhere
                Pattern datePattern = Pattern.compile("(\\d{4}-\\d{2}-\\d{2}|\\d{2}/\\d{2}/\\d{4})");
                Pattern timePattern = Pattern.compile("(\\d{1,2}:\\d{2})(AM|PM|am|pm)?");
                Matcher dm = datePattern.matcher(line);
                Matcher tm = timePattern.matcher(line);
                if (dm.find() && tm.find()) {
                    dateStr = dm.group(1);
                    if (dateStr.contains("/")) dateStr = normalizeSlashDate(dateStr);
                    startStr = tm.group(1);
                    startSuffix = tm.group(2);
                    title = line.substring(0, dm.start()).trim();
                    // location heuristically after last time
                    location = line.substring(tm.end()).trim();
                } else {
                    continue; // give up on this line
                }
            }

            if (title == null || title.isEmpty()) title = "(No title)";
            if (dateStr == null || startStr == null) continue;

            LocalTime startTime = parseFlexibleTime(startStr, startSuffix);
            LocalTime endTime = null;
            if (endStr != null && !endStr.isEmpty()) {
                endTime = parseFlexibleTime(endStr, endSuffix);
            }
            int duration = 60;
            if (endTime != null) {
                try {
                    duration = (int) Math.max(1, ChronoUnit.MINUTES.between(startTime, endTime));
                } catch (Exception ignore) {}
            }

            // Persist event
            importRow(userId, title, defaultCategory, null, dateStr, startTime.truncatedTo(ChronoUnit.MINUTES).format(DateTimeFormatter.ofPattern("HH:mm")), duration, location, 15);
            count++;
        }
        return count;
    }

    private String getSubmittedFileName(Part part) {
        String header = part.getHeader("content-disposition");
        if (header == null) return null;
        for (String cd : header.split(";")) {
            String trimmed = cd.trim();
            if (trimmed.startsWith("filename")) {
                String fn = trimmed.substring(trimmed.indexOf('=') + 1).trim().replace("\"", "");
                return fn;
            }
        }
        return null;
    }

    private void importRow(int userId, String title, String categoryName, String subjectName,
                           String date, String time, int duration, String location, int reminder) throws Exception {
        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);
            Integer categoryId = getOrCreateCategory(conn, categoryName);
            Integer subjectId = (subjectName != null && !subjectName.isEmpty()) ? getOrCreateSubject(conn, userId, subjectName) : null;

            PreparedStatement insert = conn.prepareStatement(
                "INSERT INTO events (user_id, category_id, subject_id, title, event_date, event_time, duration_minutes, location, reminder_minutes_before, is_active) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, TRUE)"
            );
            insert.setInt(1, userId);
            if (categoryId != null) insert.setInt(2, categoryId); else insert.setNull(2, Types.INTEGER);
            if (subjectId != null) insert.setInt(3, subjectId); else insert.setNull(3, Types.INTEGER);
            insert.setString(4, title);
            insert.setDate(5, Date.valueOf(date));
            insert.setTime(6, Time.valueOf(time + ":00"));
            insert.setInt(7, duration);
            insert.setString(8, location);
            insert.setInt(9, reminder);
            insert.executeUpdate();
            conn.commit();
        }
    }

    private Integer getOrCreateCategory(Connection conn, String name) throws SQLException {
        if (name == null || name.isEmpty()) return null;
        PreparedStatement sel = conn.prepareStatement("SELECT category_id FROM categories WHERE category_name = ?");
        sel.setString(1, name);
        ResultSet rs = sel.executeQuery();
        if (rs.next()) return rs.getInt(1);
        PreparedStatement ins = conn.prepareStatement("INSERT INTO categories (category_name, category_color) VALUES (?, '#6c5ce7')", PreparedStatement.RETURN_GENERATED_KEYS);
        ins.setString(1, name);
        ins.executeUpdate();
        ResultSet keys = ins.getGeneratedKeys();
        if (keys.next()) return keys.getInt(1);
        return null;
    }

    private Integer getOrCreateSubject(Connection conn, int userId, String name) throws SQLException {
        PreparedStatement sel = conn.prepareStatement("SELECT subject_id FROM subjects WHERE user_id = ? AND subject_name = ?");
        sel.setInt(1, userId);
        sel.setString(2, name);
        ResultSet rs = sel.executeQuery();
        if (rs.next()) return rs.getInt(1);
        PreparedStatement ins = conn.prepareStatement("INSERT INTO subjects (user_id, subject_name) VALUES (?, ?)", PreparedStatement.RETURN_GENERATED_KEYS);
        ins.setInt(1, userId);
        ins.setString(2, name);
        ins.executeUpdate();
        ResultSet keys = ins.getGeneratedKeys();
        if (keys.next()) return keys.getInt(1);
        return null;
    }

    private int parseIntOr(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }

    // Helpers for PDF flexible parsing
    private String normalizeSlashDate(String date) {
        // dd/MM/yyyy -> yyyy-MM-dd
        if (date == null) return null;
        String[] parts = date.split("/");
        if (parts.length == 3) {
            return parts[2] + "-" + parts[1] + "-" + parts[0];
        }
        return date;
    }

    private LocalTime parseFlexibleTime(String time, String suffix) {
        try {
            LocalTime base = LocalTime.parse(time);
            if (suffix != null && !suffix.isEmpty()) {
                String s = suffix.toUpperCase();
                int hour = base.getHour();
                if (s.equals("PM") && hour < 12) hour += 12;
                if (s.equals("AM") && hour == 12) hour = 0; // 12 AM -> 00
                base = LocalTime.of(hour, base.getMinute());
            }
            return base;
        } catch (Exception e) {
            return LocalTime.of(9,0); // fallback morning
        }
    }
}

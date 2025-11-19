package com.smartcalendar.servlets;

import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Base64;

import javax.imageio.ImageIO;

import com.smartcalendar.dao.UserFaceDao;
import com.smartcalendar.models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/enroll-face-id"})
public class EnrollFaceServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        if (user == null) { resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED); return; }

        // Expect JSON { image: "data:image/png;base64,...", latitude:"...", longitude:"..." }
        String body = readAll(req.getInputStream());
        String dataUrl = extractField(body, "image");
        String latStr = extractField(body, "latitude");
        String lonStr = extractField(body, "longitude");
        if (dataUrl == null || !dataUrl.contains(",")) { resp.setStatus(400); return; }
        String b64 = dataUrl.substring(dataUrl.indexOf(',') + 1);
        byte[] imageBytes = Base64.getDecoder().decode(b64);

        try {
            BufferedImage img = ImageIO.read(new java.io.ByteArrayInputStream(imageBytes));
            if (img == null) { resp.setStatus(400); return; }
            String phash = averageHash(img);
            Double lat = null, lon = null;
            if (latStr != null && !latStr.isEmpty()) {
                try { lat = Double.valueOf(latStr); } catch (NumberFormatException ignore) {}
            }
            if (lonStr != null && !lonStr.isEmpty()) {
                try { lon = Double.valueOf(lonStr); } catch (NumberFormatException ignore) {}
            }
            try {
                UserFaceDao.upsertFace(user.getUserId(), imageBytes, phash, lat, lon);
            } catch (java.sql.SQLException sqlEx) {
                resp.setStatus(500);
                resp.setContentType("application/json");
                resp.getWriter().write("{\"ok\":false}");
                return;
            }
            resp.setContentType("application/json");
            resp.getWriter().write("{\"ok\":true}");
        } catch (IOException | RuntimeException e) {
            resp.setStatus(500);
            resp.setContentType("application/json");
            resp.getWriter().write("{\"ok\":false}");
        }
    }

    private static String readAll(InputStream is) throws IOException {
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        byte[] buf = new byte[4096]; int r;
        while ((r = is.read(buf)) != -1) bos.write(buf, 0, r);
        return bos.toString(java.nio.charset.StandardCharsets.UTF_8);
    }

    private static String extractField(String json, String field) {
        // naive extraction: "field":"value"
        String key = "\"" + field + "\":";
        int i = json.indexOf(key);
        if (i < 0) return null;
        int start = json.indexOf('"', i + key.length());
        if (start < 0) return null;
        int end = json.indexOf('"', start + 1);
        if (end < 0) return null;
        return json.substring(start + 1, end);
    }

    private static String averageHash(BufferedImage src) {
        BufferedImage gray = new BufferedImage(8, 8, BufferedImage.TYPE_BYTE_GRAY);
        Graphics2D g = gray.createGraphics();
        g.drawImage(src.getScaledInstance(8, 8, Image.SCALE_SMOOTH), 0, 0, null);
        g.dispose();
        long sum = 0;
        int[] px = new int[64];
        int k = 0;
        for (int y = 0; y < 8; y++) {
            for (int x = 0; x < 8; x++) {
                int v = gray.getRGB(x, y) & 0xFF;
                px[k++] = v; sum += v;
            }
        }
        int avg = (int)(sum / 64);
        StringBuilder bits = new StringBuilder(64);
        for (int v : px) bits.append(v >= avg ? '1' : '0');
        return bits.toString();
    }
}

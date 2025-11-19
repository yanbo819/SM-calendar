package com.smartcalendar.servlets;

import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
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

@WebServlet(urlPatterns = {"/face-recognize"})
public class FaceRecognizeServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        if (user == null) { resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED); return; }

        String body = readAll(req.getInputStream());
        String dataUrl = extractField(body, "image");
        if (dataUrl == null || !dataUrl.contains(",")) { resp.setStatus(400); return; }
        String b64 = dataUrl.substring(dataUrl.indexOf(',') + 1);
        byte[] bytes = Base64.getDecoder().decode(b64);

        try {
            String saved = UserFaceDao.getPHash(user.getUserId());
            if (saved == null) {
                resp.setContentType("application/json");
                resp.getWriter().write("{\"ok\":false,\"reason\":\"no_enrollment\"}");
                return;
            }
            BufferedImage img = ImageIO.read(new ByteArrayInputStream(bytes));
            String nowHash = averageHash(img);
            int dist = hamming(saved, nowHash);
            boolean match = dist <= 10; // simple threshold for demo
            resp.setContentType("application/json");
            resp.getWriter().write("{\"ok\":" + (match ? "true" : "false") + ",\"distance\":" + dist + "}");
        } catch (Exception e) {
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
        long sum = 0; int[] px = new int[64]; int k = 0;
        for (int y = 0; y < 8; y++) {
            for (int x = 0; x < 8; x++) {
                int v = gray.getRGB(x, y) & 0xFF; px[k++] = v; sum += v;
            }
        }
        int avg = (int)(sum / 64);
        StringBuilder bits = new StringBuilder(64);
        for (int v : px) bits.append(v >= avg ? '1' : '0');
        return bits.toString();
    }

    private static int hamming(String a, String b) {
        if (a == null || b == null || a.length() != b.length()) return Integer.MAX_VALUE;
        int d = 0; for (int i = 0; i < a.length(); i++) if (a.charAt(i) != b.charAt(i)) d++;
        return d;
    }
}

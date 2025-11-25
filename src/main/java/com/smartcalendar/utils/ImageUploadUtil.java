package com.smartcalendar.utils;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.awt.image.BufferedImage;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Locale;
import java.util.UUID;
import javax.imageio.ImageIO;

/** Utility for secure image upload handling (validation + storage). */
public final class ImageUploadUtil {
    private static final long MAX_SIZE = 2 * 1024 * 1024; // 2MB
    private static final int MAX_DIMENSION = 2000; // width/height upper bound

    private ImageUploadUtil() {}

    /**
     * Validates and stores an uploaded image Part. Returns relative path ("uploads/<uuid>.<ext>") or null when no file provided.
     * On validation failure sets i18n flashError and throws IOException.
     */
    public static String storeVolunteerImage(Part part, HttpServletRequest req) throws IOException {
        if (part == null || part.getSize() == 0) return null; // optional
        HttpSession session = req.getSession();
        String lang = (String) session.getAttribute("lang");
        if (lang == null) lang = "en";

        // Size check
        if (part.getSize() > MAX_SIZE) {
            session.setAttribute("flashError", LanguageUtil.getText(lang, "admin.volunteer.imageTooLarge"));
            throw new IOException("Image too large");
        }

        String contentType = part.getContentType();
        if (contentType == null) contentType = "";
        contentType = contentType.toLowerCase(Locale.ROOT);
        String ext;
        switch (contentType) {
            case "image/jpeg": ext = "jpg"; break;
            case "image/png": ext = "png"; break;
            case "image/webp": ext = "webp"; break;
            default:
                session.setAttribute("flashError", LanguageUtil.getText(lang, "admin.volunteer.invalidImageType"));
                throw new IOException("Invalid type");
        }

        // Decode to ensure it's actually an image & dimension constraints
        BufferedImage img;
        try (InputStream is = part.getInputStream()) {
            img = ImageIO.read(is);
        }
        if (img == null) {
            session.setAttribute("flashError", LanguageUtil.getText(lang, "admin.volunteer.invalidImageType"));
            throw new IOException("Unreadable image");
        }
        if (img.getWidth() > MAX_DIMENSION || img.getHeight() > MAX_DIMENSION) {
            session.setAttribute("flashError", LanguageUtil.getText(lang, "admin.volunteer.imageInvalidDimensions"));
            throw new IOException("Image dimensions too large");
        }

        // Store with UUID filename
        ServletContext ctx = req.getServletContext();
        String uploadsDir = ctx.getRealPath("/uploads");
        Files.createDirectories(Path.of(uploadsDir));
        String fileName = UUID.randomUUID().toString() + "." + ext;
        Path target = Path.of(uploadsDir, fileName);
        try (InputStream is2 = part.getInputStream()) {
            Files.copy(is2, target);
        } catch (IOException ex) {
            session.setAttribute("flashError", LanguageUtil.getText(lang, "admin.volunteer.uploadError"));
            throw ex;
        }

        // Create thumbnail (max 300x300) stored alongside original with _thumb suffix (convert webp to png)
        try {
            int tw = img.getWidth();
            int th = img.getHeight();
            int maxSide = 300;
            if (tw > maxSide || th > maxSide) {
                double scale = Math.min((double)maxSide / tw, (double)maxSide / th);
                int nw = (int)Math.round(tw * scale);
                int nh = (int)Math.round(th * scale);
                BufferedImage thumb = new BufferedImage(nw, nh, BufferedImage.TYPE_INT_RGB);
                Graphics2D g2 = thumb.createGraphics();
                g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
                g2.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
                g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
                g2.drawImage(img, 0, 0, nw, nh, null);
                g2.dispose();
                String thumbName = fileName.replace('.' + ext, "_thumb." + ("webp".equals(ext)?"png":ext));
                Path thumbTarget = Path.of(uploadsDir, thumbName);
                // Write as png if webp original
                ImageIO.write(thumb, ("webp".equals(ext)?"png":ext), thumbTarget.toFile());
            }
        } catch (Exception ignore) {
            // Non-fatal thumbnail generation failure
        }
        return "uploads/" + fileName;
    }
}

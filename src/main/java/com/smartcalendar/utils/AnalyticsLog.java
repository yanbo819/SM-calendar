package com.smartcalendar.utils;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class AnalyticsLog {
    public static class Entry {
        public final Instant timestamp;
        public final String userId;
        public final String endpoint;
        public final String query;
        public Entry(Instant ts, String userId, String endpoint, String query) {
            this.timestamp = ts; this.userId = userId; this.endpoint = endpoint; this.query = query;
        }
    }

    private static final int MAX_ENTRIES = 500;
    private static final List<Entry> entries = new ArrayList<>();

    public static synchronized void log(String userId, String endpoint, String query) {
        if (entries.size() >= MAX_ENTRIES) {
            entries.remove(0);
        }
        entries.add(new Entry(Instant.now(), userId, endpoint, query));
    }

    public static synchronized List<Entry> recent(int limit) {
        int size = entries.size();
        if (limit <= 0 || limit >= size) {
            return Collections.unmodifiableList(new ArrayList<>(entries));
        }
        return Collections.unmodifiableList(entries.subList(size - limit, size));
    }
}

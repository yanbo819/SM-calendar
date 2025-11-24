package com.smartcalendar.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Database utility class for managing database connections
 */
public class DatabaseUtil {
    // Use H2 embedded database for easy testing
    private static final String DB_URL = "jdbc:h2:mem:smart_calendar;DB_CLOSE_DELAY=-1;INIT=RUNSCRIPT FROM 'classpath:sql/init.sql'\\;RUNSCRIPT FROM 'classpath:sql/add_translations.sql'";
    private static final String DB_USER = "sa";
    private static final String DB_PASSWORD = "";
    
    // Alternative MySQL configuration (uncomment to use MySQL instead)
    // private static final String DB_URL = "jdbc:mysql://localhost:3306/smart_calendar?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    // private static final String DB_USER = "root";
    // private static final String DB_PASSWORD = "";
    
    static {
        try {
            // Load H2 JDBC driver
            Class.forName("org.h2.Driver");
            // Uncomment for MySQL: Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Database JDBC driver not found", e);
        }
    }
    
    /**
     * Get a database connection
     * @return Connection object
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }
    
    /**
     * Close database connection safely
     * @param connection Connection to close
     */
    public static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                System.err.println("Error closing database connection: " + e.getMessage());
            }
        }
    }
    
    /**
     * Test database connection
     * @return true if connection is successful, false otherwise
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            System.err.println("Database connection test failed: " + e.getMessage());
            return false;
        }
    }
}
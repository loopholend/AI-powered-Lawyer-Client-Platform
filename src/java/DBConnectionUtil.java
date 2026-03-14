import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class DBConnectionUtil {

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError("MySQL JDBC Driver not found: " + e.getMessage());
        }
    }

    private DBConnectionUtil() {
    }

    public static Connection getConnection() throws SQLException {
        String dbUrl = getConfigValue("LEGALCONNECT_DB_URL");
        String dbUser = getConfigValue("LEGALCONNECT_DB_USER");
        String dbPassword = getConfigValue("LEGALCONNECT_DB_PASSWORD");

        if (dbUrl.isEmpty() || dbUser.isEmpty() || dbPassword.isEmpty()) {
            throw new SQLException("Database configuration missing. Set LEGALCONNECT_DB_URL, LEGALCONNECT_DB_USER, and LEGALCONNECT_DB_PASSWORD.");
        }

        return DriverManager.getConnection(dbUrl, dbUser, dbPassword);
    }

    private static String getConfigValue(String key) {
        String value = System.getenv(key);
        if (value == null || value.trim().isEmpty()) {
            value = System.getProperty(key);
        }
        return value == null ? "" : value.trim();
    }
}

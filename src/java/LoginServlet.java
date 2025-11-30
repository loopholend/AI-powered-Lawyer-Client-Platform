import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class LoginServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "root";
    
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        System.out.println("=== LOGIN ATTEMPT ===");
        System.out.println("Email: " + email);
        
        if (email == null || email.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            System.out.println("ERROR: Empty email or password");
            response.sendRedirect("login.html?error=invalid");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String passwordHash = hashPassword(password);
            System.out.println("Password hash: " + passwordHash);
            
            String sql = "SELECT user_id, first_name, last_name, user_type, email, is_active FROM users WHERE email = ? AND password_hash = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            pstmt.setString(2, passwordHash);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                int userId = rs.getInt("user_id");
                String firstName = rs.getString("first_name");
                String lastName = rs.getString("last_name");
                String userType = rs.getString("user_type");
                int isActive = rs.getInt("is_active");
                
                System.out.println("User found: " + userId + " | Type: " + userType + " | Active: " + isActive);
                
                if (isActive != 1) {
                    System.out.println("ERROR: User account is not active");
                    response.sendRedirect("login.html?error=inactive");
                    return;
                }
                
                // Create session
                HttpSession session = request.getSession();
                session.setAttribute("userId", userId);
                session.setAttribute("firstName", firstName);
                session.setAttribute("lastName", lastName);
                session.setAttribute("email", email);
                session.setAttribute("userType", userType);
                session.setMaxInactiveInterval(30 * 60);
                
                System.out.println("Session created successfully");
                
                // Update last login time
                String updateSql = "UPDATE users SET last_login_date = NOW() WHERE user_id = ?";
                PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                updateStmt.setInt(1, userId);
                updateStmt.executeUpdate();
                updateStmt.close();
                
                // Redirect based on user type
                if ("client".equals(userType)) {
                    System.out.println("Redirecting to client dashboard");
                    response.sendRedirect("client-dashboard.jsp");
                } else if ("lawyer".equals(userType)) {
                    System.out.println("Redirecting to lawyer dashboard");
                    response.sendRedirect("lawyer-dashboard.jsp");
                } else if ("admin".equals(userType)) {
                    System.out.println("Redirecting to admin dashboard");
                    session.setAttribute("adminId", userId);
                    response.sendRedirect("admin-dashboard.jsp");
                } else {
                    System.out.println("ERROR: Unknown user type: " + userType);
                    response.sendRedirect("login.html?error=invalid");
                }
                
            } else {
                System.out.println("ERROR: No user found with provided credentials");
                response.sendRedirect("login.html?error=invalid");
            }
            
        } catch (ClassNotFoundException e) {
            System.err.println("Driver error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("login.html?error=server");
        } catch (SQLException e) {
            System.err.println("Database error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("login.html?error=database");
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("login.html");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Login Authentication Servlet";
    }
}

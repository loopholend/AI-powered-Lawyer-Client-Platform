import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import org.json.*;

public class GetAllUsersServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userType"))) {
            out.print("[]");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
                "root", "root"
            );
            
            String sql = "SELECT u.user_id, u.email, u.user_type, u.first_name, u.last_name, " +
                        "u.phone_number, u.city, u.registration_date, u.is_active, " +
                        "COALESCE(l.is_verified, 0) as is_verified " +
                        "FROM users u " +
                        "LEFT JOIN lawyers l ON u.user_id = l.user_id " +
                        "WHERE u.user_type IN ('client', 'lawyer') " +
                        "ORDER BY u.registration_date DESC";
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            JSONArray usersArray = new JSONArray();
            
            while (rs.next()) {
                JSONObject user = new JSONObject();
                user.put("userId", rs.getInt("user_id"));
                user.put("firstName", rs.getString("first_name"));
                user.put("lastName", rs.getString("last_name"));
                user.put("email", rs.getString("email"));
                user.put("phone", rs.getString("phone_number"));
                user.put("city", rs.getString("city"));
                user.put("userType", rs.getString("user_type"));
                user.put("isActive", rs.getInt("is_active") == 1);
                user.put("isVerified", rs.getInt("is_verified") == 1);
                
                Timestamp timestamp = rs.getTimestamp("registration_date");
                if (timestamp != null) {
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM dd, yyyy");
                    user.put("registeredDate", sdf.format(timestamp));
                }
                
                usersArray.put(user);
            }
            
            out.print(usersArray.toString());
            System.out.println("Loaded " + usersArray.length() + " users");
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("[]");
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {}
        }
    }
}

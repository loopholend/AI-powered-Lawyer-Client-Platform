import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import org.json.*;

public class GetPendingLawyersServlet extends HttpServlet {

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
            
            String sql = "SELECT l.lawyer_id, l.bar_number, l.state_licensed, l.years_experience, " +
                        "l.primary_specialization, l.city_practice, l.created_at, " +
                        "u.first_name, u.last_name, u.email, u.phone_number, u.registration_date " +
                        "FROM lawyers l " +
                        "JOIN users u ON l.user_id = u.user_id " +
                        "WHERE l.is_verified = 0 " +
                        "ORDER BY l.created_at DESC";
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            JSONArray lawyersArray = new JSONArray();
            
            while (rs.next()) {
                JSONObject lawyer = new JSONObject();
                lawyer.put("lawyerId", rs.getInt("lawyer_id"));
                lawyer.put("firstName", rs.getString("first_name"));
                lawyer.put("lastName", rs.getString("last_name"));
                lawyer.put("email", rs.getString("email"));
                lawyer.put("phone", rs.getString("phone_number"));
                lawyer.put("barNumber", rs.getString("bar_number"));
                lawyer.put("stateLicensed", rs.getString("state_licensed"));
                lawyer.put("experience", rs.getString("years_experience"));
                lawyer.put("specialization", rs.getString("primary_specialization"));
                lawyer.put("cityPractice", rs.getString("city_practice"));
                
                Timestamp timestamp = rs.getTimestamp("registration_date");
                if (timestamp != null) {
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM dd, yyyy");
                    lawyer.put("registeredDate", sdf.format(timestamp));
                }
                
                lawyersArray.put(lawyer);
            }
            
            out.print(lawyersArray.toString());
            System.out.println("Found " + lawyersArray.length() + " pending lawyers");
            
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

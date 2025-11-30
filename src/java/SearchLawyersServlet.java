import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import org.json.*;

public class SearchLawyersServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        String specialization = request.getParameter("specialization");
        String city = request.getParameter("city");
        String experience = request.getParameter("experience");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8",
                "root", "root"
            );
            
            StringBuilder sql = new StringBuilder(
                "SELECT l.lawyer_id, l.bar_number, l.state_licensed, l.years_experience, " +
                "l.primary_specialization, l.city_practice, l.hourly_rate, l.average_rating, " +
                "l.total_ratings, u.first_name, u.last_name, u.email " +
                "FROM lawyers l " +
                "JOIN users u ON l.user_id = u.user_id " +
                "WHERE l.is_verified = 1 AND u.is_active = 1"
            );
            
            // Add filters
            if (specialization != null && !specialization.isEmpty()) {
                sql.append(" AND l.primary_specialization = ?");
            }
            
            if (city != null && !city.isEmpty()) {
                sql.append(" AND LOWER(l.city_practice) LIKE LOWER(?)");
            }
            
            if (experience != null && !experience.isEmpty()) {
                sql.append(" AND l.years_experience = ?");
            }
            
            sql.append(" ORDER BY l.average_rating DESC, l.total_ratings DESC");
            
            pstmt = conn.prepareStatement(sql.toString());
            
            int paramIndex = 1;
            if (specialization != null && !specialization.isEmpty()) {
                pstmt.setString(paramIndex++, specialization);
            }
            if (city != null && !city.isEmpty()) {
                pstmt.setString(paramIndex++, "%" + city + "%");
            }
            if (experience != null && !experience.isEmpty()) {
                pstmt.setString(paramIndex++, experience);
            }
            
            rs = pstmt.executeQuery();
            
            JSONArray lawyersArray = new JSONArray();
            
            while (rs.next()) {
                JSONObject lawyer = new JSONObject();
                lawyer.put("lawyerId", rs.getInt("lawyer_id"));
                lawyer.put("firstName", rs.getString("first_name"));
                lawyer.put("lastName", rs.getString("last_name"));
                lawyer.put("email", rs.getString("email"));
                lawyer.put("barNumber", rs.getString("bar_number"));
                lawyer.put("stateLicensed", rs.getString("state_licensed"));
                lawyer.put("yearsExperience", rs.getString("years_experience"));
                lawyer.put("specialization", rs.getString("primary_specialization"));
                lawyer.put("cityPractice", rs.getString("city_practice"));
                lawyer.put("hourlyRate", rs.getString("hourly_rate"));
                lawyer.put("averageRating", rs.getDouble("average_rating"));
                lawyer.put("totalRatings", rs.getInt("total_ratings"));
                
                lawyersArray.put(lawyer);
            }
            
            out.print(lawyersArray.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("[]");
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
}

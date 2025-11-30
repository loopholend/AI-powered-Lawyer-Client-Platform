import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class SearchLawyersServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        String specialization = request.getParameter("specialization");
        String experience = request.getParameter("experience");
        String priceRange = request.getParameter("priceRange");
        String location = request.getParameter("location");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
                "root",
                "root"
            );
            
            StringBuilder sql = new StringBuilder(
                "SELECT u.user_id, u.first_name, u.last_name, u.email, u.phone_number, u.city, " +
                "l.bar_number, l.state_licensed, l.years_experience, l.primary_specialization, " +
                "l.city_practice, l.hourly_rate, l.is_verified, l.bio " +
                "FROM users u " +
                "INNER JOIN lawyers l ON u.user_id = l.user_id " +
                "WHERE u.user_type = 'lawyer' AND u.is_active = TRUE"
            );
            
            if (specialization != null && !specialization.isEmpty()) {
                sql.append(" AND l.primary_specialization = ?");
            }
            if (experience != null && !experience.isEmpty()) {
                sql.append(" AND l.years_experience = ?");
            }
            if (priceRange != null && !priceRange.isEmpty()) {
                sql.append(" AND l.hourly_rate = ?");
            }
            if (location != null && !location.isEmpty()) {
                sql.append(" AND (u.city LIKE ? OR l.state_licensed LIKE ? OR l.city_practice LIKE ?)");
            }
            
            sql.append(" ORDER BY l.is_verified DESC LIMIT 50");
            
            pstmt = conn.prepareStatement(sql.toString());
            
            int paramIndex = 1;
            if (specialization != null && !specialization.isEmpty()) {
                pstmt.setString(paramIndex++, specialization);
            }
            if (experience != null && !experience.isEmpty()) {
                pstmt.setString(paramIndex++, experience);
            }
            if (priceRange != null && !priceRange.isEmpty()) {
                pstmt.setString(paramIndex++, priceRange);
            }
            if (location != null && !location.isEmpty()) {
                String locationPattern = "%" + location + "%";
                pstmt.setString(paramIndex++, locationPattern);
                pstmt.setString(paramIndex++, locationPattern);
                pstmt.setString(paramIndex++, locationPattern);
            }
            
            rs = pstmt.executeQuery();
            
            out.print("[");
            boolean first = true;
            
            while (rs.next()) {
                if (!first) out.print(",");
                
                out.print("{");
                out.print("\"userId\":" + rs.getInt("user_id") + ",");
                out.print("\"firstName\":\"" + escapeJson(rs.getString("first_name")) + "\",");
                out.print("\"lastName\":\"" + escapeJson(rs.getString("last_name")) + "\",");
                out.print("\"email\":\"" + escapeJson(rs.getString("email")) + "\",");
                out.print("\"phone\":\"" + escapeJson(rs.getString("phone_number")) + "\",");
                out.print("\"city\":\"" + escapeJson(rs.getString("city")) + "\",");
                out.print("\"barNumber\":\"" + escapeJson(rs.getString("bar_number")) + "\",");
                out.print("\"state\":\"" + escapeJson(rs.getString("state_licensed")) + "\",");
                out.print("\"experience\":\"" + escapeJson(rs.getString("years_experience")) + "\",");
                out.print("\"specialization\":\"" + escapeJson(rs.getString("primary_specialization")) + "\",");
                out.print("\"hourlyRate\":\"" + escapeJson(rs.getString("hourly_rate")) + "\",");
                out.print("\"isVerified\":" + rs.getBoolean("is_verified") + ",");
                
                String bio = rs.getString("bio");
                out.print("\"bio\":\"" + (bio != null ? escapeJson(bio) : "") + "\",");
                out.print("\"avgRating\":4.5");
                out.print("}");
                
                first = false;
            }
            
            out.print("]");
            
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
    
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r");
    }
}

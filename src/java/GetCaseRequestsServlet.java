import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import org.json.*;

public class GetCaseRequestsServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            out.print("[]");
            return;
        }
        
        Integer userId = (Integer) session.getAttribute("userId");
        int caseId = Integer.parseInt(request.getParameter("caseId"));
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
                "root", "root"
            );
            
            String sql = "SELECT cr.request_id, cr.message, cr.proposed_fee, cr.created_at, " +
                        "l.lawyer_id, u.first_name, u.last_name, l.specialization, l.experience_years, " +
                        "l.average_rating, l.total_ratings " +
                        "FROM case_requests cr " +
                        "JOIN lawyers l ON cr.lawyer_id = l.lawyer_id " +
                        "JOIN users u ON l.user_id = u.user_id " +
                        "WHERE cr.case_id = ? AND cr.request_status = 'pending' " +
                        "ORDER BY cr.created_at DESC";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, caseId);
            rs = pstmt.executeQuery();
            
            JSONArray requestsArray = new JSONArray();
            
            while (rs.next()) {
                JSONObject reqObj = new JSONObject();
                reqObj.put("requestId", rs.getInt("request_id"));
                reqObj.put("lawyerId", rs.getInt("lawyer_id"));
                reqObj.put("lawyerName", rs.getString("first_name") + " " + rs.getString("last_name"));
                reqObj.put("specialization", rs.getString("specialization"));
                reqObj.put("experience", rs.getInt("experience_years"));
                reqObj.put("rating", rs.getDouble("average_rating"));
                reqObj.put("totalRatings", rs.getInt("total_ratings"));
                reqObj.put("message", rs.getString("message"));
                reqObj.put("proposedFee", rs.getDouble("proposed_fee"));
                
                Timestamp timestamp = rs.getTimestamp("created_at");
                if (timestamp != null) {
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM dd, yyyy");
                    reqObj.put("requestDate", sdf.format(timestamp));
                }
                
                requestsArray.put(reqObj);
            }
            
            out.print(requestsArray.toString());
            
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

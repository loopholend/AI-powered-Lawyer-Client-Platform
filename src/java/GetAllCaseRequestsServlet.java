import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import org.json.*;

public class GetAllCaseRequestsServlet extends HttpServlet {

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
        if (userId == null) {
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
            
            // Get client_id
            String getClientIdSql = "SELECT client_id FROM clients WHERE user_id = ?";
            pstmt = conn.prepareStatement(getClientIdSql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                out.print("[]");
                return;
            }
            
            int clientId = rs.getInt("client_id");
            rs.close();
            pstmt.close();
            
            // Get all pending requests for client's cases
            String sql = "SELECT cr.request_id, cr.case_id, cr.message, cr.proposed_fee, cr.created_at, " +
                        "c.case_title, c.case_type, c.city, " +
                        "l.lawyer_id, u.first_name, u.last_name, l.primary_specialization, l.years_experience, " +
                        "l.average_rating, l.total_ratings " +
                        "FROM case_requests cr " +
                        "JOIN cases c ON cr.case_id = c.case_id " +
                        "JOIN lawyers l ON cr.lawyer_id = l.lawyer_id " +
                        "JOIN users u ON l.user_id = u.user_id " +
                        "WHERE cr.client_id = ? AND cr.request_status = 'pending' " +
                        "ORDER BY cr.created_at DESC";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, clientId);
            rs = pstmt.executeQuery();
            
            JSONArray requestsArray = new JSONArray();
            
            while (rs.next()) {
                JSONObject reqObj = new JSONObject();
                reqObj.put("requestId", rs.getInt("request_id"));
                reqObj.put("caseId", rs.getInt("case_id"));
                reqObj.put("caseTitle", rs.getString("case_title"));
                reqObj.put("caseType", rs.getString("case_type"));
                reqObj.put("city", rs.getString("city"));
                reqObj.put("lawyerId", rs.getInt("lawyer_id"));
                reqObj.put("lawyerName", rs.getString("first_name") + " " + rs.getString("last_name"));
                reqObj.put("specialization", rs.getString("primary_specialization"));
                reqObj.put("experience", rs.getString("years_experience"));
                reqObj.put("rating", rs.getDouble("average_rating"));
                reqObj.put("totalRatings", rs.getInt("total_ratings"));
                reqObj.put("message", rs.getString("message"));
                
                double fee = rs.getDouble("proposed_fee");
                if (!rs.wasNull()) {
                    reqObj.put("proposedFee", fee);
                }
                
                Timestamp timestamp = rs.getTimestamp("created_at");
                if (timestamp != null) {
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM dd, yyyy");
                    reqObj.put("requestDate", sdf.format(timestamp));
                }
                
                requestsArray.put(reqObj);
            }
            
            out.print(requestsArray.toString());
            System.out.println("Client " + clientId + " has " + requestsArray.length() + " pending requests");
            
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

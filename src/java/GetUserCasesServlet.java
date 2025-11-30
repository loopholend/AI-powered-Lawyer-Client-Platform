import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import org.json.*;

public class GetUserCasesServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userType"))) {
            out.print("[]");
            return;
        }
        
        int userId = Integer.parseInt(request.getParameter("userId"));
        String userType = request.getParameter("userType");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
                "root", "root"
            );
            
            String sql = "";
            
            if ("client".equals(userType)) {
                // Get cases raised by client
                sql = "SELECT c.case_id, c.case_title, c.case_type, c.city, c.case_status, c.created_at, " +
                      "lu.first_name as lawyer_first_name, lu.last_name as lawyer_last_name " +
                      "FROM cases c " +
                      "JOIN clients cl ON c.client_id = cl.client_id " +
                      "LEFT JOIN lawyers l ON c.lawyer_id = l.lawyer_id " +
                      "LEFT JOIN users lu ON l.user_id = lu.user_id " +
                      "WHERE cl.user_id = ? " +
                      "ORDER BY c.created_at DESC";
                
            } else if ("lawyer".equals(userType)) {
                // Get cases worked on by lawyer
                sql = "SELECT c.case_id, c.case_title, c.case_type, c.city, c.case_status, c.created_at, " +
                      "cu.first_name as client_first_name, cu.last_name as client_last_name " +
                      "FROM cases c " +
                      "JOIN lawyers l ON c.lawyer_id = l.lawyer_id " +
                      "JOIN clients cl ON c.client_id = cl.client_id " +
                      "JOIN users cu ON cl.user_id = cu.user_id " +
                      "WHERE l.user_id = ? " +
                      "ORDER BY c.created_at DESC";
            }
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            JSONArray casesArray = new JSONArray();
            
            while (rs.next()) {
                JSONObject caseObj = new JSONObject();
                caseObj.put("caseId", rs.getInt("case_id"));
                caseObj.put("title", rs.getString("case_title"));
                caseObj.put("type", rs.getString("case_type"));
                caseObj.put("city", rs.getString("city"));
                caseObj.put("status", rs.getString("case_status"));
                
                if ("client".equals(userType)) {
                    String lawyerFirstName = rs.getString("lawyer_first_name");
                    if (lawyerFirstName != null) {
                        caseObj.put("lawyerName", lawyerFirstName + " " + rs.getString("lawyer_last_name"));
                    }
                } else {
                    String clientFirstName = rs.getString("client_first_name");
                    if (clientFirstName != null) {
                        caseObj.put("clientName", clientFirstName + " " + rs.getString("client_last_name"));
                    }
                }
                
                Timestamp timestamp = rs.getTimestamp("created_at");
                if (timestamp != null) {
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM dd, yyyy");
                    caseObj.put("createdAt", sdf.format(timestamp));
                }
                
                casesArray.put(caseObj);
            }
            
            out.print(casesArray.toString());
            
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

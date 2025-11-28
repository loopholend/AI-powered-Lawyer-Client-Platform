import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import org.json.*;

public class GetClientCasesServlet extends HttpServlet {

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
            
            // Get client_id from user_id
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
            
            // Get all cases for this client (including completed and cancelled)
            String sql = "SELECT case_id, case_title, case_type, case_description, city, urgency, " +
                        "case_status, created_at, budget " +
                        "FROM cases WHERE client_id = ? ORDER BY created_at DESC";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, clientId);
            rs = pstmt.executeQuery();
            
            JSONArray casesArray = new JSONArray();
            
            while (rs.next()) {
                JSONObject caseObj = new JSONObject();
                caseObj.put("caseId", rs.getInt("case_id"));
                caseObj.put("title", rs.getString("case_title"));
                caseObj.put("type", rs.getString("case_type"));
                caseObj.put("description", rs.getString("case_description"));
                caseObj.put("city", rs.getString("city"));
                caseObj.put("urgency", rs.getString("urgency"));
                caseObj.put("status", rs.getString("case_status"));
                caseObj.put("budget", rs.getString("budget"));
                
                // Format date
                Timestamp timestamp = rs.getTimestamp("created_at");
                if (timestamp != null) {
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM dd, yyyy");
                    caseObj.put("createdAt", sdf.format(timestamp));
                } else {
                    caseObj.put("createdAt", "N/A");
                }
                
                casesArray.put(caseObj);
            }
            
            out.print(casesArray.toString());
            System.out.println("Client " + clientId + " has " + casesArray.length() + " cases");
            
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Error fetching client cases: " + e.getMessage());
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

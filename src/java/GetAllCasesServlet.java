import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import org.json.*;

public class GetAllCasesServlet extends HttpServlet {

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
            
            String sql = "SELECT c.case_id, c.case_title, c.case_type, c.case_description, c.city, " +
                        "c.urgency, c.case_status, c.created_at, " +
                        "cu.first_name as client_first_name, cu.last_name as client_last_name, " +
                        "lu.first_name as lawyer_first_name, lu.last_name as lawyer_last_name " +
                        "FROM cases c " +
                        "JOIN clients cl ON c.client_id = cl.client_id " +
                        "JOIN users cu ON cl.user_id = cu.user_id " +
                        "LEFT JOIN lawyers l ON c.lawyer_id = l.lawyer_id " +
                        "LEFT JOIN users lu ON l.user_id = lu.user_id " +
                        "ORDER BY c.created_at DESC";
            
            pstmt = conn.prepareStatement(sql);
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
                
                String clientName = rs.getString("client_first_name") + " " + rs.getString("client_last_name");
                caseObj.put("clientName", clientName);
                
                String lawyerFirstName = rs.getString("lawyer_first_name");
                if (lawyerFirstName != null) {
                    String lawyerName = lawyerFirstName + " " + rs.getString("lawyer_last_name");
                    caseObj.put("lawyerName", lawyerName);
                }
                
                Timestamp timestamp = rs.getTimestamp("created_at");
                if (timestamp != null) {
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM dd, yyyy");
                    caseObj.put("createdAt", sdf.format(timestamp));
                }
                
                casesArray.put(caseObj);
            }
            
            out.print(casesArray.toString());
            System.out.println("Loaded " + casesArray.length() + " cases");
            
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

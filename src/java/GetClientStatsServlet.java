import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class GetClientStatsServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            out.print("{\"activeCases\":0,\"completedCases\":0,\"lawyersConnected\":0}");
            return;
        }
        
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            out.print("{\"activeCases\":0,\"completedCases\":0,\"lawyersConnected\":0}");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        int activeCases = 0;
        int completedCases = 0;
        int lawyersConnected = 0;
        
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
                out.print("{\"activeCases\":0,\"completedCases\":0,\"lawyersConnected\":0}");
                return;
            }
            
            int clientId = rs.getInt("client_id");
            rs.close();
            pstmt.close();
            
            // Count active cases (pending + active status)
            String activeCasesSql = "SELECT COUNT(*) as count FROM cases WHERE client_id = ? AND case_status IN ('pending', 'active')";
            pstmt = conn.prepareStatement(activeCasesSql);
            pstmt.setInt(1, clientId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                activeCases = rs.getInt("count");
            }
            rs.close();
            pstmt.close();
            
            // Count completed cases
            String completedCasesSql = "SELECT COUNT(*) as count FROM cases WHERE client_id = ? AND case_status IN ('completed', 'closed')";
            pstmt = conn.prepareStatement(completedCasesSql);
            pstmt.setInt(1, clientId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                completedCases = rs.getInt("count");
            }
            rs.close();
            pstmt.close();
            
            // Count unique lawyers connected (assigned to client's cases)
            String lawyersSql = "SELECT COUNT(DISTINCT lawyer_id) as count FROM cases WHERE client_id = ? AND lawyer_id IS NOT NULL";
            pstmt = conn.prepareStatement(lawyersSql);
            pstmt.setInt(1, clientId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                lawyersConnected = rs.getInt("count");
            }
            rs.close();
            pstmt.close();
            
            // Return JSON
            out.print("{");
            out.print("\"activeCases\":" + activeCases + ",");
            out.print("\"completedCases\":" + completedCases + ",");
            out.print("\"lawyersConnected\":" + lawyersConnected);
            out.print("}");
            
            System.out.println("Client " + clientId + " stats: Active=" + activeCases + ", Completed=" + completedCases + ", Lawyers=" + lawyersConnected);
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"activeCases\":0,\"completedCases\":0,\"lawyersConnected\":0}");
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {}
        }
    }
}

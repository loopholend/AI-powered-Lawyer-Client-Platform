package client;
import util.*;

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
            out.print("{\"activeCases\":0,\"lawyerConnections\":0,\"appointments\":0,\"documents\":0}");
            return;
        }
        
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            out.print("{\"activeCases\":0,\"lawyerConnections\":0,\"appointments\":0,\"documents\":0}");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        int activeCases = 0;
        int lawyerConnections = 0;
        int appointments = 0;
        int documents = 0;
        
        try {
            conn = DBConnectionUtil.getConnection();
            FeatureSchemaUtil.ensureInitialized(conn);
            
            // Get client_id
            String getClientIdSql = "SELECT client_id FROM clients WHERE user_id = ?";
            pstmt = conn.prepareStatement(getClientIdSql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                out.print("{\"activeCases\":0,\"lawyerConnections\":0,\"appointments\":0,\"documents\":0}");
                return;
            }
            
            int clientId = rs.getInt("client_id");
            rs.close();
            pstmt.close();
            
            // Count active cases
            String activeCasesSql = "SELECT COUNT(*) as count FROM cases WHERE client_id = ? AND case_status IN ('active','in_progress')";
            pstmt = conn.prepareStatement(activeCasesSql);
            pstmt.setInt(1, clientId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                activeCases = rs.getInt("count");
            }
            rs.close();
            pstmt.close();
            
            // Count lawyer connections
            String lawyersSql = "SELECT COUNT(DISTINCT lawyer_id) as count FROM cases WHERE client_id = ? AND lawyer_id IS NOT NULL";
            pstmt = conn.prepareStatement(lawyersSql);
            pstmt.setInt(1, clientId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                lawyerConnections = rs.getInt("count");
            }
            rs.close();
            pstmt.close();
            
            // Count documents
            String docsSql = "SELECT COUNT(*) as count FROM cases WHERE client_id = ? AND document_path IS NOT NULL AND document_path <> ''";
            pstmt = conn.prepareStatement(docsSql);
            pstmt.setInt(1, clientId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                documents = rs.getInt("count");
            }
            rs.close();
            pstmt.close();
            
            out.print("{"
                + "\"activeCases\":" + activeCases + ","
                + "\"lawyerConnections\":" + lawyerConnections + ","
                + "\"appointments\":" + appointments + ","
                + "\"documents\":" + documents
                + "}");
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"activeCases\":0,\"lawyerConnections\":0,\"appointments\":0,\"documents\":0}");
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {}
        }
    }
}

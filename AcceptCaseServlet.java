import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class AcceptCaseServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            out.print("{\"success\":false,\"message\":\"Not logged in\"}");
            return;
        }
        
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            out.print("{\"success\":false,\"message\":\"Not logged in\"}");
            return;
        }
        
        int caseId = Integer.parseInt(request.getParameter("caseId"));
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        PreparedStatement pstmtLawyer = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
                "root", "root"
            );
            
            // Get lawyer_id from user_id
            String getLawyerIdSql = "SELECT lawyer_id FROM lawyers WHERE user_id = ?";
            pstmtLawyer = conn.prepareStatement(getLawyerIdSql);
            pstmtLawyer.setInt(1, userId);
            rs = pstmtLawyer.executeQuery();
            
            if (!rs.next()) {
                out.print("{\"success\":false,\"message\":\"Lawyer not found\"}");
                return;
            }
            
            int lawyerId = rs.getInt("lawyer_id");
            
            // Update case status to active and assign lawyer
            String sql = "UPDATE cases SET case_status = 'active', lawyer_id = ? WHERE case_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, lawyerId);
            pstmt.setInt(2, caseId);
            
            int rowsUpdated = pstmt.executeUpdate();
            
            if (rowsUpdated > 0) {
                out.print("{\"success\":true,\"message\":\"Case accepted successfully\"}");
                System.out.println("Lawyer " + lawyerId + " accepted case " + caseId);
            } else {
                out.print("{\"success\":false,\"message\":\"Failed to accept case\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Error: " + e.getMessage() + "\"}");
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmtLawyer != null) pstmtLawyer.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {}
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}

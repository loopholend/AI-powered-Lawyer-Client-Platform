import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class AcceptLawyerRequestServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }
        
        int requestId = Integer.parseInt(request.getParameter("requestId"));
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
            
            conn.setAutoCommit(false);
            
            // Get lawyer_id from request
            String getLawyerSql = "SELECT lawyer_id FROM case_requests WHERE request_id = ?";
            pstmt = conn.prepareStatement(getLawyerSql);
            pstmt.setInt(1, requestId);
            rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                conn.rollback();
                response.sendRedirect("client-lawyer-requests.jsp?error=true");
                return;
            }
            
            int lawyerId = rs.getInt("lawyer_id");
            rs.close();
            pstmt.close();
            
            // Assign lawyer to case
            String assignSql = "UPDATE cases SET lawyer_id = ?, case_status = 'active' WHERE case_id = ?";
            pstmt = conn.prepareStatement(assignSql);
            pstmt.setInt(1, lawyerId);
            pstmt.setInt(2, caseId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // Update accepted request
            String acceptSql = "UPDATE case_requests SET request_status = 'accepted' WHERE request_id = ?";
            pstmt = conn.prepareStatement(acceptSql);
            pstmt.setInt(1, requestId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // Reject all other requests for this case
            String rejectSql = "UPDATE case_requests SET request_status = 'rejected' WHERE case_id = ? AND request_id != ?";
            pstmt = conn.prepareStatement(rejectSql);
            pstmt.setInt(1, caseId);
            pstmt.setInt(2, requestId);
            pstmt.executeUpdate();
            
            conn.commit();
            response.sendRedirect("client-lawyer-requests.jsp?lawyerAssigned=true");
            
        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException se) {}
            response.sendRedirect("client-lawyer-requests.jsp?error=true");
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {}
        }
    }
}

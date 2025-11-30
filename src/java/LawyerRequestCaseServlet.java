import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class LawyerRequestCaseServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }
        
        int caseId = Integer.parseInt(request.getParameter("caseId"));
        String message = request.getParameter("message");
        String proposedFee = request.getParameter("proposedFee");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
                "root", "root"
            );
            
            // Get lawyer_id from session
            Integer userId = (Integer) session.getAttribute("userId");
            String getLawyerIdSql = "SELECT lawyer_id FROM lawyers WHERE user_id = ?";
            pstmt = conn.prepareStatement(getLawyerIdSql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                response.sendRedirect("lawyer-new-cases.jsp?error=true");
                return;
            }
            
            int lawyerId = rs.getInt("lawyer_id");
            rs.close();
            pstmt.close();
            
            // Get client_id from case
            String getClientIdSql = "SELECT client_id FROM cases WHERE case_id = ?";
            pstmt = conn.prepareStatement(getClientIdSql);
            pstmt.setInt(1, caseId);
            rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                response.sendRedirect("lawyer-new-cases.jsp?error=true");
                return;
            }
            
            int clientId = rs.getInt("client_id");
            rs.close();
            pstmt.close();
            
            // Check if request already exists
            String checkSql = "SELECT request_id FROM case_requests WHERE case_id = ? AND lawyer_id = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, caseId);
            pstmt.setInt(2, lawyerId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                response.sendRedirect("lawyer-new-cases.jsp?alreadyRequested=true");
                return;
            }
            rs.close();
            pstmt.close();
            
            // Insert request
            String insertSql = "INSERT INTO case_requests (case_id, lawyer_id, client_id, message, proposed_fee) VALUES (?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setInt(1, caseId);
            pstmt.setInt(2, lawyerId);
            pstmt.setInt(3, clientId);
            pstmt.setString(4, message);
            
            if (proposedFee != null && !proposedFee.trim().isEmpty()) {
                pstmt.setDouble(5, Double.parseDouble(proposedFee));
            } else {
                pstmt.setNull(5, Types.DECIMAL);
            }
            
            pstmt.executeUpdate();
            
            response.sendRedirect("lawyer-new-cases.jsp?requestSent=true");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("lawyer-new-cases.jsp?error=true");
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {}
        }
    }
}

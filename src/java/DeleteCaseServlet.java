import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class DeleteCaseServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userType"))) {
            response.sendRedirect("login.html");
            return;
        }
        
        int caseId = Integer.parseInt(request.getParameter("caseId"));
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
                "root", "root"
            );
            
            conn.setAutoCommit(false);
            
            // Delete case requests first (foreign key constraint)
            String deleteCaseRequestsSql = "DELETE FROM case_requests WHERE case_id = ?";
            pstmt = conn.prepareStatement(deleteCaseRequestsSql);
            pstmt.setInt(1, caseId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // Delete lawyer ratings for this case (if they exist)
            String deleteRatingsSql = "DELETE FROM lawyer_ratings WHERE case_id = ?";
            pstmt = conn.prepareStatement(deleteRatingsSql);
            pstmt.setInt(1, caseId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // Delete the case
            String deleteCaseSql = "DELETE FROM cases WHERE case_id = ?";
            pstmt = conn.prepareStatement(deleteCaseSql);
            pstmt.setInt(1, caseId);
            pstmt.executeUpdate();
            
            conn.commit();
            System.out.println("Case " + caseId + " deleted successfully");
            
            response.sendRedirect("admin-all-cases.jsp?deleted=true");
            
        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException se) {}
            response.sendRedirect("admin-all-cases.jsp?error=true");
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {}
        }
    }
}

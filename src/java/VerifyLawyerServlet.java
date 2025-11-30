import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class VerifyLawyerServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userType"))) {
            response.sendRedirect("login.html");
            return;
        }
        
        int lawyerId = Integer.parseInt(request.getParameter("lawyerId"));
        String action = request.getParameter("action");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
                "root", "root"
            );
            
            if ("approve".equals(action)) {
                // Approve lawyer - set is_verified to 1
                String sql = "UPDATE lawyers SET is_verified = 1 WHERE lawyer_id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, lawyerId);
                pstmt.executeUpdate();
                
                System.out.println("Lawyer " + lawyerId + " approved");
                response.sendRedirect("admin-verify-lawyers.jsp?approved=true");
                
            } else if ("reject".equals(action)) {
                // Reject lawyer - delete lawyer record and user account
                conn.setAutoCommit(false);
                
                // Get user_id first
                String getUserSql = "SELECT user_id FROM lawyers WHERE lawyer_id = ?";
                pstmt = conn.prepareStatement(getUserSql);
                pstmt.setInt(1, lawyerId);
                ResultSet rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    int userId = rs.getInt("user_id");
                    rs.close();
                    pstmt.close();
                    
                    // Delete lawyer record
                    String deleteLawyerSql = "DELETE FROM lawyers WHERE lawyer_id = ?";
                    pstmt = conn.prepareStatement(deleteLawyerSql);
                    pstmt.setInt(1, lawyerId);
                    pstmt.executeUpdate();
                    pstmt.close();
                    
                    // Delete user account
                    String deleteUserSql = "DELETE FROM users WHERE user_id = ?";
                    pstmt = conn.prepareStatement(deleteUserSql);
                    pstmt.setInt(1, userId);
                    pstmt.executeUpdate();
                    
                    conn.commit();
                    System.out.println("Lawyer " + lawyerId + " rejected and deleted");
                }
                
                response.sendRedirect("admin-verify-lawyers.jsp?rejected=true");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException se) {}
            response.sendRedirect("admin-verify-lawyers.jsp?error=true");
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

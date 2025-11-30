import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class DeleteUserServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userType"))) {
            response.sendRedirect("login.html");
            return;
        }
        
        int userId = Integer.parseInt(request.getParameter("userId"));
        String userType = request.getParameter("userType");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
                "root", "root"
            );
            
            conn.setAutoCommit(false);
            
            // Delete based on user type
            if ("lawyer".equals(userType)) {
                // Delete lawyer-specific data first
                
                // Delete case requests
                String deleteCaseRequestsSql = "DELETE FROM case_requests WHERE lawyer_id IN (SELECT lawyer_id FROM lawyers WHERE user_id = ?)";
                pstmt = conn.prepareStatement(deleteCaseRequestsSql);
                pstmt.setInt(1, userId);
                pstmt.executeUpdate();
                pstmt.close();
                
                // Delete lawyer record
                String deleteLawyerSql = "DELETE FROM lawyers WHERE user_id = ?";
                pstmt = conn.prepareStatement(deleteLawyerSql);
                pstmt.setInt(1, userId);
                pstmt.executeUpdate();
                pstmt.close();
                
            } else if ("client".equals(userType)) {
                // Delete client-specific data first
                
                // Delete case requests for client's cases
                String deleteCaseRequestsSql = "DELETE FROM case_requests WHERE client_id IN (SELECT client_id FROM clients WHERE user_id = ?)";
                pstmt = conn.prepareStatement(deleteCaseRequestsSql);
                pstmt.setInt(1, userId);
                pstmt.executeUpdate();
                pstmt.close();
                
                // Delete cases
                String deleteCasesSql = "DELETE FROM cases WHERE client_id IN (SELECT client_id FROM clients WHERE user_id = ?)";
                pstmt = conn.prepareStatement(deleteCasesSql);
                pstmt.setInt(1, userId);
                pstmt.executeUpdate();
                pstmt.close();
                
                // Delete client record
                String deleteClientSql = "DELETE FROM clients WHERE user_id = ?";
                pstmt = conn.prepareStatement(deleteClientSql);
                pstmt.setInt(1, userId);
                pstmt.executeUpdate();
                pstmt.close();
            }
            
            // Delete user account
            String deleteUserSql = "DELETE FROM users WHERE user_id = ?";
            pstmt = conn.prepareStatement(deleteUserSql);
            pstmt.setInt(1, userId);
            pstmt.executeUpdate();
            
            conn.commit();
            System.out.println("User " + userId + " deleted successfully");
            
            response.sendRedirect("admin-all-users.jsp?deleted=true");
            
        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException se) {}
            response.sendRedirect("admin-all-users.jsp?error=true");
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

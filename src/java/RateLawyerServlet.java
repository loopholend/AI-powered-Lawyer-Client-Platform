import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class RateLawyerServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }
        
        int caseId = Integer.parseInt(request.getParameter("caseId"));
        int rating = Integer.parseInt(request.getParameter("rating"));
        String review = request.getParameter("review");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
                "root", "root"
            );
            
            // Get client_id and lawyer_id from case
            String getCaseInfoSql = "SELECT client_id, lawyer_id FROM cases WHERE case_id = ?";
            pstmt = conn.prepareStatement(getCaseInfoSql);
            pstmt.setInt(1, caseId);
            rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                response.sendRedirect("client-upload-case.jsp?error=true");
                return;
            }
            
            int clientId = rs.getInt("client_id");
            Integer lawyerId = (Integer) rs.getObject("lawyer_id");
            
            if (lawyerId == null) {
                // No lawyer assigned, just mark as completed
                rs.close();
                pstmt.close();
                
                String updateSql = "UPDATE cases SET case_status = 'completed' WHERE case_id = ?";
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setInt(1, caseId);
                pstmt.executeUpdate();
                
                response.sendRedirect("client-upload-case.jsp?completed=true&noLawyer=true");
                return;
            }
            
            rs.close();
            pstmt.close();
            
            // Insert rating
            String insertRatingSql = "INSERT INTO lawyer_ratings (lawyer_id, client_id, case_id, rating, review) VALUES (?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(insertRatingSql);
            pstmt.setInt(1, lawyerId);
            pstmt.setInt(2, clientId);
            pstmt.setInt(3, caseId);
            pstmt.setInt(4, rating);
            pstmt.setString(5, review);
            pstmt.executeUpdate();
            pstmt.close();
            
            // Update lawyer's average rating
            String updateAvgSql = "UPDATE lawyers SET " +
                "average_rating = (SELECT AVG(rating) FROM lawyer_ratings WHERE lawyer_id = ?), " +
                "total_ratings = (SELECT COUNT(*) FROM lawyer_ratings WHERE lawyer_id = ?) " +
                "WHERE lawyer_id = ?";
            pstmt = conn.prepareStatement(updateAvgSql);
            pstmt.setInt(1, lawyerId);
            pstmt.setInt(2, lawyerId);
            pstmt.setInt(3, lawyerId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // Mark case as completed
            String updateCaseSql = "UPDATE cases SET case_status = 'completed' WHERE case_id = ?";
            pstmt = conn.prepareStatement(updateCaseSql);
            pstmt.setInt(1, caseId);
            pstmt.executeUpdate();
            
            response.sendRedirect("client-upload-case.jsp?completed=true&rated=true");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("client-upload-case.jsp?error=true");
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {}
        }
    }
}

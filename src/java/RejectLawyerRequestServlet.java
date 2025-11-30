import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class RejectLawyerRequestServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }
        
        int requestId = Integer.parseInt(request.getParameter("requestId"));
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
                "root", "root"
            );
            
            String sql = "UPDATE case_requests SET request_status = 'rejected' WHERE request_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, requestId);
            pstmt.executeUpdate();
            
            response.sendRedirect("client-lawyer-requests.jsp?rejected=true");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("client-lawyer-requests.jsp?error=true");
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {}
        }
    }
}

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class CancelCaseServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
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
            
            String sql = "UPDATE cases SET case_status = 'cancelled' WHERE case_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, caseId);
            
            int result = pstmt.executeUpdate();
            
            // FIXED: Redirect to the JSP page directly, not the dashboard
            if (result > 0) {
                response.sendRedirect("client-upload-case.jsp?cancelled=true");
            } else {
                response.sendRedirect("client-upload-case.jsp?error=true");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("client-upload-case.jsp?error=true");
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {}
        }
    }
}

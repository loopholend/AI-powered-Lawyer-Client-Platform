import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,
    maxFileSize = 1024 * 1024 * 5,
    maxRequestSize = 1024 * 1024 * 10
)
public class UploadCaseServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "case_documents";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        
        int clientId = Integer.parseInt(request.getParameter("clientId"));
        String caseTitle = request.getParameter("caseTitle");
        String caseType = request.getParameter("caseType");
        String city = request.getParameter("city");
        String urgency = request.getParameter("urgency");
        String budget = request.getParameter("budget");
        String description = request.getParameter("description");
        
        String documentPath = null;
        Part filePart = request.getPart("caseDocument");
        
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = getFileName(filePart);
            
            // FIXED: Get the correct upload path
            String applicationPath = getServletContext().getRealPath("");
            String uploadPath = applicationPath + File.separator + UPLOAD_DIR;
            
            System.out.println("Application Path: " + applicationPath);
            System.out.println("Upload Path: " + uploadPath);
            
            // Create directory if it doesn't exist
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                boolean created = uploadDir.mkdirs();
                System.out.println("Directory created: " + created);
            }
            
            // Create unique filename
            String timestamp = String.valueOf(System.currentTimeMillis());
            String cleanFileName = fileName.replaceAll("[^a-zA-Z0-9\\.\\-]", "_");
            String newFileName = timestamp + "_" + cleanFileName;
            
            // Full file path
            String filePath = uploadPath + File.separator + newFileName;
            System.out.println("Saving file to: " + filePath);
            
            // Write file
            try (InputStream input = filePart.getInputStream();
                 FileOutputStream output = new FileOutputStream(filePath)) {
                
                byte[] buffer = new byte[1024];
                int bytesRead;
                while ((bytesRead = input.read(buffer)) != -1) {
                    output.write(buffer, 0, bytesRead);
                }
                
                documentPath = UPLOAD_DIR + "/" + newFileName;
                System.out.println("File saved successfully: " + documentPath);
            } catch (Exception e) {
                e.printStackTrace();
                System.err.println("Error saving file: " + e.getMessage());
            }
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
                "root", "root"
            );
            
            String sql = "INSERT INTO cases (client_id, case_title, case_type, case_description, city, urgency, budget, document_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, clientId);
            pstmt.setString(2, caseTitle);
            pstmt.setString(3, caseType);
            pstmt.setString(4, description);
            pstmt.setString(5, city);
            pstmt.setString(6, urgency);
            pstmt.setString(7, budget);
            pstmt.setString(8, documentPath);
            
            int rowsAffected = pstmt.executeUpdate();
            System.out.println("Case inserted successfully. Rows affected: " + rowsAffected);
            
            response.sendRedirect("client-upload-case.jsp?success=true");
            
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Database error: " + e.getMessage());
            response.sendRedirect("client-upload-case.jsp?error=true");
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "unknown_file";
    }
}

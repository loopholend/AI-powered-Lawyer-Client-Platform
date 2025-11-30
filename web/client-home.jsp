<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    int clientId = 0;
    
    int activeCases = 0;
    int completedCases = 0;
    int lawyersConnected = 0;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
            "root", "root"
        );
        
        // Get client ID
        String sql = "SELECT client_id FROM clients WHERE user_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            clientId = rs.getInt("client_id");
        }
        rs.close();
        pstmt.close();
        
        // Active cases
        sql = "SELECT COUNT(*) as count FROM cases WHERE client_id = ? AND case_status = 'active'";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, clientId);
        rs = pstmt.executeQuery();
        if (rs.next()) activeCases = rs.getInt("count");
        rs.close();
        pstmt.close();
        
        // Completed cases
        sql = "SELECT COUNT(*) as count FROM cases WHERE client_id = ? AND case_status = 'completed'";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, clientId);
        rs = pstmt.executeQuery();
        if (rs.next()) completedCases = rs.getInt("count");
        rs.close();
        pstmt.close();
        
        // Lawyers connected
        sql = "SELECT COUNT(DISTINCT lawyer_id) as count FROM cases WHERE client_id = ? AND lawyer_id IS NOT NULL";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, clientId);
        rs = pstmt.executeQuery();
        if (rs.next()) lawyersConnected = rs.getInt("count");
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="dark-mode.css">
    <script src="dark-mode.js" defer></script>
    <style>
        body { 
            margin: 0; 
            padding: 20px; 
            background: #f9fafb; 
            font-family: 'Inter', sans-serif;
        }
        
        .welcome-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
        }
        
        .welcome-header h1 { 
            margin: 0 0 0.5rem 0; 
            font-size: 2rem; 
        }
        
        .welcome-header p { 
            margin: 0; 
            opacity: 0.9; 
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .stat-card {
            background: white;
            padding: 1.5rem;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            border-top: 4px solid;
            transition: all 0.3s;
        }
        
        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 4px 16px rgba(0,0,0,0.1);
        }
        
        .stat-card.blue { border-color: #3b82f6; }
        .stat-card.green { border-color: #10b981; }
        .stat-card.purple { border-color: #8b5cf6; }
        
        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: white;
            margin-bottom: 1rem;
        }
        
        .stat-icon.blue { background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); }
        .stat-icon.green { background: linear-gradient(135deg, #10b981 0%, #059669 100%); }
        .stat-icon.purple { background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%); }
        
        .stat-value {
            font-size: 2.5rem;
            font-weight: 700;
            color: #1f2937;
            margin-bottom: 0.5rem;
        }
        
        .stat-label {
            color: #6b7280;
            font-size: 0.95rem;
        }
        
        .quick-actions {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        .quick-actions h2 {
            color: #1f2937;
            margin: 0 0 1.5rem 0;
        }
        
        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1rem;
        }
        
        .action-card {
            padding: 1.5rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 12px;
            color: white;
            cursor: pointer;
            transition: all 0.3s;
            text-align: center;
        }
        
        .action-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
        }
        
        .action-card.secondary {
            background: linear-gradient(135deg, #f9fafb 0%, #e5e7eb 100%);
            color: #1f2937;
        }
        
        .action-card.secondary:hover {
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
        }
        
        .action-card i {
            font-size: 2rem;
            margin-bottom: 0.75rem;
            display: block;
        }
        
        .action-card span {
            font-weight: 600;
            font-size: 1.1rem;
            display: block;
        }
    </style>
</head>
<body>
    <div class="welcome-header">
        <h1>Welcome, <%= session.getAttribute("firstName") %>!</h1>
        <p>Manage your legal cases and connect with expert lawyers</p>
    </div>
    
    <div class="stats-grid">
        <div class="stat-card blue">
            <div class="stat-icon blue">
                <i class="fas fa-folder-open"></i>
            </div>
            <div class="stat-value"><%= activeCases %></div>
            <div class="stat-label">Active Cases</div>
        </div>
        
        <div class="stat-card green">
            <div class="stat-icon green">
                <i class="fas fa-check-circle"></i>
            </div>
            <div class="stat-value"><%= completedCases %></div>
            <div class="stat-label">Completed Cases</div>
        </div>
        
        <div class="stat-card purple">
            <div class="stat-icon purple">
                <i class="fas fa-user-tie"></i>
            </div>
            <div class="stat-value"><%= lawyersConnected %></div>
            <div class="stat-label">Lawyers Connected</div>
        </div>
    </div>
    
    <div class="quick-actions">
        <h2>Quick Actions</h2>
        <div class="actions-grid">
            <div class="action-card" onclick="parent.loadPage('client-search-lawyers.jsp')">
                <i class="fas fa-search"></i>
                <span>Search Lawyers</span>
            </div>
            
            <div class="action-card secondary" onclick="parent.loadPage('client-upload-case.jsp')">
                <i class="fas fa-upload"></i>
                <span>Upload Case</span>
            </div>
            
            <div class="action-card secondary" onclick="parent.loadPage('client-ai-support.jsp')">
                <i class="fas fa-robot"></i>
                <span>AI Assistant</span>
            </div>
        </div>
    </div>
</body>
</html>

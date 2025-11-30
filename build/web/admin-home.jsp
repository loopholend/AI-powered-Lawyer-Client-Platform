<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String userType = (String) session.getAttribute("userType");
    
    if (userId == null || !"admin".equals(userType)) {
        response.sendRedirect("login.html");
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    int totalUsers = 0;
    int totalClients = 0;
    int totalLawyers = 0;
    int verifiedLawyers = 0;
    int pendingLawyers = 0;
    int totalCases = 0;
    int activeCases = 0;
    int completedCases = 0;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
            "root", "root"
        );
        
        // Total users
        String sql = "SELECT COUNT(*) as count FROM users WHERE is_active = 1";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        if (rs.next()) totalUsers = rs.getInt("count");
        rs.close();
        pstmt.close();
        
        // Total clients
        sql = "SELECT COUNT(*) as count FROM clients";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        if (rs.next()) totalClients = rs.getInt("count");
        rs.close();
        pstmt.close();
        
        // Total lawyers
        sql = "SELECT COUNT(*) as count FROM lawyers";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        if (rs.next()) totalLawyers = rs.getInt("count");
        rs.close();
        pstmt.close();
        
        // Verified lawyers
        sql = "SELECT COUNT(*) as count FROM lawyers WHERE is_verified = 1";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        if (rs.next()) verifiedLawyers = rs.getInt("count");
        rs.close();
        pstmt.close();
        
        // Pending lawyers
        sql = "SELECT COUNT(*) as count FROM lawyers WHERE is_verified = 0";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        if (rs.next()) pendingLawyers = rs.getInt("count");
        rs.close();
        pstmt.close();
        
        // Total cases
        sql = "SELECT COUNT(*) as count FROM cases";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        if (rs.next()) totalCases = rs.getInt("count");
        rs.close();
        pstmt.close();
        
        // Active cases
        sql = "SELECT COUNT(*) as count FROM cases WHERE case_status = 'active'";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        if (rs.next()) activeCases = rs.getInt("count");
        rs.close();
        pstmt.close();
        
        // Completed cases
        sql = "SELECT COUNT(*) as count FROM cases WHERE case_status = 'completed'";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        if (rs.next()) completedCases = rs.getInt("count");
        
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
        
        .page-header {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        .page-header h1 {
            color: #1f2937;
            font-size: 2rem;
            margin: 0 0 0.5rem 0;
        }
        
        .page-header p {
            color: #6b7280;
            margin: 0;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .stat-card {
            background: white;
            padding: 1.5rem;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            display: flex;
            align-items: center;
            gap: 1rem;
            transition: all 0.3s;
        }
        
        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        
        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: white;
        }
        
        .stat-icon.users { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
        .stat-icon.clients { background: linear-gradient(135deg, #0ea5e9 0%, #0284c7 100%); }
        .stat-icon.lawyers { background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); }
        .stat-icon.verified { background: linear-gradient(135deg, #10b981 0%, #059669 100%); }
        .stat-icon.pending { background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); }
        .stat-icon.cases { background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%); }
        .stat-icon.active { background: linear-gradient(135deg, #06b6d4 0%, #0891b2 100%); }
        .stat-icon.completed { background: linear-gradient(135deg, #84cc16 0%, #65a30d 100%); }
        
        .stat-content {
            flex: 1;
        }
        
        .stat-value {
            font-size: 2rem;
            font-weight: 700;
            color: #1f2937;
            margin-bottom: 0.25rem;
        }
        
        .stat-label {
            color: #6b7280;
            font-size: 0.9rem;
        }
        
        .quick-actions {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        .quick-actions h2 {
            color: #1f2937;
            font-size: 1.5rem;
            margin: 0 0 1.5rem 0;
        }
        
        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }
        
        .action-btn {
            padding: 1.5rem;
            background: #f9fafb;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            color: inherit;
            display: block;
        }
        
        .action-btn:hover {
            background: white;
            border-color: #dc2626;
            transform: translateY(-2px);
        }
        
        .action-btn i {
            font-size: 2rem;
            color: #dc2626;
            margin-bottom: 0.5rem;
        }
        
        .action-btn span {
            display: block;
            color: #1f2937;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <div class="page-header">
        <h1><i class="fas fa-chart-line"></i> Admin Dashboard</h1>
        <p>System overview and statistics</p>
    </div>
    
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon users">
                <i class="fas fa-users"></i>
            </div>
            <div class="stat-content">
                <div class="stat-value"><%= totalUsers %></div>
                <div class="stat-label">Total Users</div>
            </div>
        </div>
        
        <div class="stat-card">
            <div class="stat-icon clients">
                <i class="fas fa-user"></i>
            </div>
            <div class="stat-content">
                <div class="stat-value"><%= totalClients %></div>
                <div class="stat-label">Total Clients</div>
            </div>
        </div>
        
        <div class="stat-card">
            <div class="stat-icon lawyers">
                <i class="fas fa-gavel"></i>
            </div>
            <div class="stat-content">
                <div class="stat-value"><%= totalLawyers %></div>
                <div class="stat-label">Total Lawyers</div>
            </div>
        </div>
        
        <div class="stat-card">
            <div class="stat-icon verified">
                <i class="fas fa-check-circle"></i>
            </div>
            <div class="stat-content">
                <div class="stat-value"><%= verifiedLawyers %></div>
                <div class="stat-label">Verified Lawyers</div>
            </div>
        </div>
        
        <div class="stat-card">
            <div class="stat-icon pending">
                <i class="fas fa-clock"></i>
            </div>
            <div class="stat-content">
                <div class="stat-value"><%= pendingLawyers %></div>
                <div class="stat-label">Pending Verification</div>
            </div>
        </div>
        
        <div class="stat-card">
            <div class="stat-icon cases">
                <i class="fas fa-folder"></i>
            </div>
            <div class="stat-content">
                <div class="stat-value"><%= totalCases %></div>
                <div class="stat-label">Total Cases</div>
            </div>
        </div>
        
        <div class="stat-card">
            <div class="stat-icon active">
                <i class="fas fa-briefcase"></i>
            </div>
            <div class="stat-content">
                <div class="stat-value"><%= activeCases %></div>
                <div class="stat-label">Active Cases</div>
            </div>
        </div>
        
        <div class="stat-card">
            <div class="stat-icon completed">
                <i class="fas fa-check-double"></i>
            </div>
            <div class="stat-content">
                <div class="stat-value"><%= completedCases %></div>
                <div class="stat-label">Completed Cases</div>
            </div>
        </div>
    </div>
    
    <div class="quick-actions">
        <h2>Quick Actions</h2>
        <div class="actions-grid">
            <a href="admin-verify-lawyers.jsp" class="action-btn">
                <i class="fas fa-user-check"></i>
                <span>Verify Lawyers</span>
            </a>
            <a href="admin-all-users.jsp" class="action-btn">
                <i class="fas fa-users-cog"></i>
                <span>Manage Users</span>
            </a>
            <a href="admin-all-cases.jsp" class="action-btn">
                <i class="fas fa-folder-open"></i>
                <span>View All Cases</span>
            </a>
        </div>
    </div>
</body>
</html>

<%@ page session="true" %>
<%@ page import="java.sql.*" %>
<%
    String firstName = (String) session.getAttribute("firstName");
    String lastName = (String) session.getAttribute("lastName");
    String email = (String) session.getAttribute("email");
    String userType = (String) session.getAttribute("userType");
    Integer userId = (Integer) session.getAttribute("userId");
    
    if (firstName == null || !"lawyer".equals(userType)) {
        response.sendRedirect("../login.html");
        return;
    }
    
    boolean isVerified = false;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    try {
        Class<?> dbUtilClass = Class.forName("util.DBConnectionUtil");
        conn = (Connection) dbUtilClass.getMethod("getConnection").invoke(null);
        String sql = "SELECT is_verified FROM lawyers WHERE user_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            isVerified = rs.getBoolean("is_verified");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
    
    String initials = "";
    if (firstName != null && !firstName.trim().isEmpty()) {
        initials += firstName.trim().toUpperCase().charAt(0);
    }
    if (lastName != null && !lastName.trim().isEmpty()) {
        initials += lastName.trim().toUpperCase().charAt(0);
    }
    if (initials.isEmpty()) {
        initials = "U";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lawyer Dashboard - LegalConnect</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="../styles.css">
    <style>
        :root {
            --primary-color: #C9A227;
            --secondary-color: #A9861F;
            --navbar-color: #0B1F3A;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <aside class="sidebar">
            <div class="sidebar-header">
                <div class="logo">
                    <i class="fas fa-balance-scale"></i>
                    <span>LegalConnect</span>
                </div>
                
                <div class="user-info">
                    <div class="user-avatar">
                        <%= initials %>
                    </div>
                    <div class="user-name">Hello, Adv. <%= firstName %></div>
                    <div class="user-email"><%= email %></div>
                    <% if (isVerified) { %>
                    <div style="background: rgba(255,255,255,0.2); padding: 0.25rem 0.75rem; border-radius: 20px; font-size: 0.75rem; margin-top: 0.5rem; display: inline-block;">
                        Verified Lawyer
                    </div>
                    <% } else { %>
                    <div style="background: rgba(239, 68, 68, 0.2); color: #fee2e2; padding: 0.25rem 0.75rem; border-radius: 20px; font-size: 0.75rem; margin-top: 0.5rem; display: inline-block;">
                        Under Review
                    </div>
                    <% } %>
                </div>
            </div>

            <nav class="sidebar-nav">
                <a class="nav-item active" onclick="loadPage('lawyer-home.jsp')">
                    <i class="fas fa-home"></i>
                    <span>Dashboard Home</span>
                </a>
                <a class="nav-item" onclick="loadPage('lawyer-new-cases.jsp')">
                    <i class="fas fa-folder-plus"></i>
                    <span>New Cases</span>
                </a>
                <a class="nav-item" onclick="loadPage('lawyer-active-cases.jsp')">
                    <i class="fas fa-briefcase"></i>
                    <span>Active Cases</span>
                </a>
                <a class="nav-item" onclick="loadPage('../case-chat.jsp')">
                    <i class="fas fa-comments"></i>
                    <span>Case Chat</span>
                </a>
                <a class="nav-item" onclick="loadPage('../notifications.jsp')">
                    <i class="fas fa-bell"></i>
                    <span class="nav-label">Notifications <span id="lawyerNotifBadge" class="nav-badge" style="display:none;">0</span></span>
                </a>
                <a class="nav-item" onclick="loadPage('lawyer-profile.jsp')">
                    <i class="fas fa-user-tie"></i>
                    <span>Lawyer Info</span>
                </a>
                <a class="nav-item" onclick="loadPage('lawyer-ai-support.jsp')">
                    <i class="fas fa-robot"></i>
                    <span>AI Support</span>
                </a>
                <a class="nav-item logout" onclick="showLogoutModal()">
                    <i class="fas fa-sign-out-alt"></i>
                    <span>Logout</span>
                </a>
            </nav>
        </aside>

        <main class="main-content">
            <iframe id="contentFrame" class="content-frame" src="lawyer-home.jsp"></iframe>
        </main>
    </div>

    <!-- Logout Confirmation Modal -->
    <div id="logoutModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 9999; justify-content: center; align-items: center;">
        <div style="background: white; border-radius: 12px; padding: 2rem; max-width: 400px; width: 90%; text-align: center; box-shadow: 0 10px 40px rgba(0,0,0,0.3);">
            <div style="font-size: 3rem; color: #f59e0b; margin-bottom: 1rem;">
                <i class="fas fa-exclamation-triangle"></i>
            </div>
            <h2 style="color: #111827; margin-bottom: 0.5rem; font-size: 1.5rem;">Logout Confirmation</h2>
            <p style="color: #6b7280; margin-bottom: 2rem;">Are you sure you want to logout?</p>
            <div style="display: flex; gap: 1rem;">
                <button onclick="closeLogoutModal()" style="flex: 1; padding: 0.75rem; background: #F8FAFC; color: #111827; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; font-size: 0.95rem; transition: all 0.3s;">
                    Cancel
                </button>
                <button onclick="confirmLogout()" style="flex: 1; padding: 0.75rem; background: #ef4444; color: white; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; font-size: 0.95rem; transition: all 0.3s;">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </button>
            </div>
        </div>
    </div>

    <script>
        var userRole = '<%= userType %>';

        function loadPage(page) {
            document.getElementById('contentFrame').src = page;
            localStorage.setItem('lastActivePage_' + userRole, page);
            
            document.querySelectorAll('.nav-item').forEach(function(item) {
                item.classList.remove('active');
            });
            
            if (window.event && window.event.currentTarget) {
                window.event.currentTarget.classList.add('active');
            } else {
                document.querySelectorAll('.nav-item').forEach(function(item) {
                    var onclickAttr = item.getAttribute('onclick');
                    if (onclickAttr && onclickAttr.indexOf("loadPage('" + page + "')") >= 0) {
                        item.classList.add('active');
                    }
                });
            }
        }

        // Initialize frame based on saved preference or default
        var savedPage = localStorage.getItem('lastActivePage_' + userRole);
        if (savedPage) {
            loadPage(savedPage);
        } else {
            loadPage('lawyer-home.jsp');
        }

        function showLogoutModal() {
            document.getElementById('logoutModal').style.display = 'flex';
        }

        function closeLogoutModal() {
            document.getElementById('logoutModal').style.display = 'none';
        }

        function confirmLogout() {
            localStorage.removeItem('lastActivePage_' + userRole);
            window.location.href = '../LogoutServlet';
        }

        function refreshNotificationBadge() {
            fetch('../GetNotificationsServlet')
                .then(function(response) { return response.json(); })
                .then(function(data) {
                    var badge = document.getElementById('lawyerNotifBadge');
                    if (!data.success || !data.unreadCount) {
                        badge.style.display = 'none';
                        return;
                    }
                    badge.textContent = data.unreadCount > 99 ? '99+' : data.unreadCount;
                    badge.style.display = 'inline-flex';
                })
                .catch(function() {});
        }

        refreshNotificationBadge();
        setInterval(refreshNotificationBadge, 12000);
    </script>
</body>
</html>

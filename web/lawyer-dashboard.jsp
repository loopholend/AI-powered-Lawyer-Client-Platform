<%@ page session="true" %>
<%
    String firstName = (String) session.getAttribute("firstName");
    String lastName = (String) session.getAttribute("lastName");
    String email = (String) session.getAttribute("email");
    String userType = (String) session.getAttribute("userType");
    
    if (firstName == null || !"lawyer".equals(userType)) {
        response.sendRedirect("login.html");
        return;
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
    <link rel="stylesheet" href="styles.css">
    <style>
        :root {
            --lawyer-primary: #ec4899;
            --lawyer-secondary: #db2777;
        }
        
        .sidebar {
            background: linear-gradient(180deg, #ec4899 0%, #db2777 100%) !important;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <aside class="sidebar">
            <div class="sidebar-header">
                <div class="logo">
                    <i class="fas fa-gavel"></i>
                    <span>LegalConnect</span>
                </div>
                
                <div class="user-info">
                    <div class="user-avatar">
                        <%= firstName.substring(0, 1).toUpperCase() %><%= lastName.substring(0, 1).toUpperCase() %>
                    </div>
                    <div class="user-name">Hello, Adv. <%= firstName %></div>
                    <div class="user-email"><%= email %></div>
                    <div class="user-type">Verified Lawyer</div>
                </div>
            </div>

            <nav class="sidebar-nav">
                <a class="nav-item active" onclick="loadPage('lawyer-home.jsp')">
                    <i class="fas fa-home"></i>
                    <span>Dashboard Home</span>
                </a>
                <a class="nav-item" onclick="loadPage('lawyer-new-cases.jsp')">
                    <i class="fas fa-folder"></i>
                    <span>New Cases</span>
                </a>
                <a class="nav-item" onclick="loadPage('lawyer-active-cases.jsp')">
                    <i class="fas fa-briefcase"></i>
                    <span>Active Cases</span>
                </a>
                <a class="nav-item" onclick="loadPage('lawyer-profile.jsp')">
                    <i class="fas fa-user"></i>
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

    <!-- Logout Modal -->
    <div id="logoutModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 9999; justify-content: center; align-items: center;">
        <div style="background: white; border-radius: 12px; padding: 2rem; max-width: 400px; width: 90%; text-align: center; box-shadow: 0 10px 40px rgba(0,0,0,0.3);">
            <div style="font-size: 3rem; color: #f59e0b; margin-bottom: 1rem;">
                <i class="fas fa-exclamation-triangle"></i>
            </div>
            <h2 style="color: #1f2937; margin-bottom: 0.5rem; font-size: 1.5rem;">Logout Confirmation</h2>
            <p style="color: #6b7280; margin-bottom: 2rem;">Are you sure you want to logout?</p>
            <div style="display: flex; gap: 1rem;">
                <button onclick="closeLogoutModal()" style="flex: 1; padding: 0.75rem; background: #f9fafb; color: #1f2937; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; font-size: 0.95rem;">
                    Cancel
                </button>
                <button onclick="confirmLogout()" style="flex: 1; padding: 0.75rem; background: #ef4444; color: white; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; font-size: 0.95rem;">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </button>
            </div>
        </div>
    </div>

    <script>
        function loadPage(page) {
            document.getElementById('contentFrame').src = page;
            
            document.querySelectorAll('.nav-item').forEach(function(item) {
                item.classList.remove('active');
            });
            
            if (event && event.currentTarget) {
                event.currentTarget.classList.add('active');
            }
        }

        function showLogoutModal() {
            document.getElementById('logoutModal').style.display = 'flex';
        }

        function closeLogoutModal() {
            document.getElementById('logoutModal').style.display = 'none';
        }

        function confirmLogout() {
            window.location.href = 'LogoutServlet';
        }
    </script>
</body>
</html>

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
    
    String firstName = "";
    String lastName = "";
    String email = "";
    String phone = "";
    String specialization = "";
    String barCouncilId = "";
    String experience = "";
    String city = "";
    String hourlyRate = "";
    String bio = "";
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
            "root", "root"
        );
        
        String sql = "SELECT u.first_name, u.last_name, u.email, l.phone, l.specialization, " +
                     "l.bar_council_id, l.experience, l.city, l.hourly_rate, l.bio " +
                     "FROM users u " +
                     "LEFT JOIN lawyers l ON u.user_id = l.user_id " +
                     "WHERE u.user_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            firstName = rs.getString("first_name") != null ? rs.getString("first_name") : "";
            lastName = rs.getString("last_name") != null ? rs.getString("last_name") : "";
            email = rs.getString("email") != null ? rs.getString("email") : "";
            phone = rs.getString("phone") != null ? rs.getString("phone") : "";
            specialization = rs.getString("specialization") != null ? rs.getString("specialization") : "";
            barCouncilId = rs.getString("bar_council_id") != null ? rs.getString("bar_council_id") : "";
            experience = rs.getString("experience") != null ? rs.getString("experience") : "";
            city = rs.getString("city") != null ? rs.getString("city") : "";
            hourlyRate = rs.getString("hourly_rate") != null ? rs.getString("hourly_rate") : "";
            bio = rs.getString("bio") != null ? rs.getString("bio") : "";
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
    
    // Get from session if empty
    if (firstName.isEmpty()) {
        firstName = (String) session.getAttribute("firstName");
        if (firstName == null) firstName = "";
    }
    if (lastName.isEmpty()) {
        lastName = (String) session.getAttribute("lastName");
        if (lastName == null) lastName = "";
    }
    if (email.isEmpty()) {
        email = (String) session.getAttribute("email");
        if (email == null) email = "";
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
        
        .profile-container {
            max-width: 900px;
            margin: 0 auto;
        }
        
        .profile-card {
            background: white;
            border-radius: 12px;
            padding: 2rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            margin-bottom: 2rem;
        }
        
        .profile-header {
            display: flex;
            align-items: center;
            gap: 2rem;
            margin-bottom: 2rem;
            padding-bottom: 2rem;
            border-bottom: 2px solid #f9fafb;
        }
        
        .profile-avatar {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: linear-gradient(135deg, #ec4899 0%, #db2777 100%);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.5rem;
            font-weight: 700;
        }
        
        .profile-info {
            flex: 1;
        }
        
        .profile-name {
            font-size: 1.75rem;
            font-weight: 700;
            color: #1f2937;
            margin-bottom: 0.5rem;
        }
        
        .profile-email {
            color: #6b7280;
            font-size: 1rem;
        }
        
        .form-section {
            margin-bottom: 2rem;
        }
        
        .form-section h2 {
            color: #1f2937;
            font-size: 1.3rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .form-section h2 i {
            color: #ec4899;
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-group label {
            display: block;
            color: #1f2937;
            font-weight: 600;
            margin-bottom: 0.5rem;
            font-size: 0.95rem;
        }
        
        .form-control {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 0.95rem;
            font-family: 'Inter', sans-serif;
            box-sizing: border-box;
            transition: all 0.3s;
            color: #1f2937;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #ec4899;
            box-shadow: 0 0 0 3px rgba(236, 72, 153, 0.1);
        }
        
        .form-control:disabled {
            background: #f3f4f6;
            color: #374151;
            cursor: not-allowed;
            border-color: #d1d5db;
            -webkit-text-fill-color: #374151;
            opacity: 1;
        }
        
        textarea.form-control {
            min-height: 120px;
            resize: vertical;
        }
        
        .btn-update {
            width: 100%;
            padding: 1rem;
            background: linear-gradient(135deg, #ec4899 0%, #db2777 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            font-size: 1rem;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
        }
        
        .btn-update:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(236, 72, 153, 0.4);
        }
        
        .success-message {
            background: #d1fae5;
            color: #065f46;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .error-message {
            background: #fee2e2;
            color: #991b1b;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .password-card {
            background: white;
            border-radius: 12px;
            padding: 2rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        .password-card h2 {
            color: #1f2937;
            font-size: 1.3rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .password-card h2 i {
            color: #ef4444;
        }
        
        @media (max-width: 768px) {
            .profile-header {
                flex-direction: column;
                text-align: center;
            }
            
            .form-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="page-header">
        <h1><i class="fas fa-user-edit"></i> Lawyer Profile</h1>
        <p>Update your professional information and credentials</p>
    </div>

    <div class="profile-container">
        <% if (request.getParameter("updated") != null && request.getParameter("updated").equals("true")) { %>
            <div class="success-message">
                <i class="fas fa-check-circle"></i>
                <span>Profile updated successfully!</span>
            </div>
        <% } %>
        
        <% if (request.getParameter("error") != null && request.getParameter("error").equals("true")) { %>
            <div class="error-message">
                <i class="fas fa-exclamation-circle"></i>
                <span>Failed to update profile. Please try again.</span>
            </div>
        <% } %>

        <div class="profile-card">
            <div class="profile-header">
                <div class="profile-avatar">
                    <%= !firstName.isEmpty() && !lastName.isEmpty() ? firstName.substring(0, 1).toUpperCase() + lastName.substring(0, 1).toUpperCase() : "L" %>
                </div>
                <div class="profile-info">
                    <div class="profile-name">
                        Adv. <%= !firstName.isEmpty() ? firstName : "Lawyer" %> <%= lastName %>
                    </div>
                    <div class="profile-email"><%= email %></div>
                </div>
            </div>

            <form action="UpdateLawyerProfileServlet" method="POST">
                <div class="form-section">
                    <h2><i class="fas fa-user"></i> Personal Information</h2>
                    
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="firstName">First Name</label>
                            <input type="text" id="firstName" name="firstName" class="form-control" 
                                   value="<%= firstName %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="lastName">Last Name</label>
                            <input type="text" id="lastName" name="lastName" class="form-control" 
                                   value="<%= lastName %>" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="email">Email Address</label>
                        <input type="email" id="email" name="email" class="form-control" 
                               value="<%= email %>" disabled>
                        <small style="color: #6b7280; font-size: 0.85rem; display: block; margin-top: 0.25rem;">
                            Email cannot be changed
                        </small>
                    </div>
                    
                    <div class="form-group">
                        <label for="phone">Phone Number</label>
                        <input type="tel" id="phone" name="phone" class="form-control" 
                               value="<%= phone %>" placeholder="Enter your phone number" required>
                    </div>
                </div>

                <div class="form-section">
                    <h2><i class="fas fa-briefcase"></i> Professional Information</h2>
                    
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="specialization">Specialization</label>
                            <select id="specialization" name="specialization" class="form-control" required>
                                <option value="">Select Specialization</option>
                                <option value="Criminal Law" <%= "Criminal Law".equals(specialization) ? "selected" : "" %>>Criminal Law</option>
                                <option value="Civil Law" <%= "Civil Law".equals(specialization) ? "selected" : "" %>>Civil Law</option>
                                <option value="Family Law" <%= "Family Law".equals(specialization) ? "selected" : "" %>>Family Law</option>
                                <option value="Corporate Law" <%= "Corporate Law".equals(specialization) ? "selected" : "" %>>Corporate Law</option>
                                <option value="Property Law" <%= "Property Law".equals(specialization) ? "selected" : "" %>>Property Law</option>
                                <option value="Tax Law" <%= "Tax Law".equals(specialization) ? "selected" : "" %>>Tax Law</option>
                                <option value="Labour Law" <%= "Labour Law".equals(specialization) ? "selected" : "" %>>Labour Law</option>
                                <option value="Consumer Law" <%= "Consumer Law".equals(specialization) ? "selected" : "" %>>Consumer Law</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="experience">Years of Experience</label>
                            <input type="number" id="experience" name="experience" class="form-control" 
                                   value="<%= experience %>" placeholder="Years" required min="0" max="50">
                        </div>
                    </div>
                    
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="barCouncilId">Bar Council ID</label>
                            <input type="text" id="barCouncilId" name="barCouncilId" class="form-control" 
                                   value="<%= barCouncilId %>" placeholder="Enter your Bar Council ID" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="city">City</label>
                            <input type="text" id="city" name="city" class="form-control" 
                                   value="<%= city %>" placeholder="Enter your city" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="hourlyRate">Consultation Fee (per hour)</label>
                        <input type="text" id="hourlyRate" name="hourlyRate" class="form-control" 
                               value="<%= hourlyRate %>" placeholder="e.g., Rs. 2000/hour" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="bio">Professional Bio</label>
                        <textarea id="bio" name="bio" class="form-control" 
                                  placeholder="Tell clients about your experience, expertise, and achievements..."><%= bio %></textarea>
                    </div>
                </div>

                <button type="submit" class="btn-update">
                    <i class="fas fa-save"></i> Save Changes
                </button>
            </form>
        </div>

        <div class="password-card">
            <h2><i class="fas fa-lock"></i> Change Password</h2>
            
            <% if (request.getParameter("passwordUpdated") != null && request.getParameter("passwordUpdated").equals("true")) { %>
                <div class="success-message">
                    <i class="fas fa-check-circle"></i>
                    <span>Password changed successfully!</span>
                </div>
            <% } %>
            
            <% if (request.getParameter("passwordError") != null) { %>
                <div class="error-message">
                    <i class="fas fa-exclamation-circle"></i>
                    <span><%= request.getParameter("passwordError") %></span>
                </div>
            <% } %>

            <form action="ChangePasswordServlet" method="POST">
                <div class="form-group">
                    <label for="currentPassword">Current Password</label>
                    <input type="password" id="currentPassword" name="currentPassword" 
                           class="form-control" required placeholder="Enter current password">
                </div>
                
                <div class="form-group">
                    <label for="newPassword">New Password</label>
                    <input type="password" id="newPassword" name="newPassword" 
                           class="form-control" required placeholder="Enter new password" minlength="6">
                </div>
                
                <div class="form-group">
                    <label for="confirmPassword">Confirm New Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" 
                           class="form-control" required placeholder="Confirm new password" minlength="6">
                </div>

                <button type="submit" class="btn-update" style="background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);">
                    <i class="fas fa-key"></i> Change Password
                </button>
            </form>
        </div>
    </div>

    <script>
        // Password match validation
        document.querySelector('form[action="ChangePasswordServlet"]').addEventListener('submit', function(e) {
            var newPassword = document.getElementById('newPassword').value;
            var confirmPassword = document.getElementById('confirmPassword').value;
            
            if (newPassword !== confirmPassword) {
                e.preventDefault();
                alert('New passwords do not match!');
                return false;
            }
            
            if (newPassword.length < 6) {
                e.preventDefault();
                alert('Password must be at least 6 characters long!');
                return false;
            }
        });
    </script>
</body>
</html>

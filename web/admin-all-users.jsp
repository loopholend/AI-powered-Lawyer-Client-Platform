<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String userType = (String) session.getAttribute("userType");
    
    if (userId == null || !"admin".equals(userType)) {
        response.sendRedirect("login.html");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            margin: 0;
            padding: 20px;
            background: #f9fafb;
            font-family: 'Inter', sans-serif;
        }

        /* ========== DARK MODE (toggled by body.dark-mode) ========== */
        body.dark-mode {
            background: #020617;
            color: #e5e7eb;
        }
        body.dark-mode .page-header,
        body.dark-mode .users-container,
        body.dark-mode .modal-content {
            background: #020617;
            color: #e5e7eb;
            box-shadow: 0 2px 12px rgba(15,23,42,0.7);
        }
        body.dark-mode .page-header h1,
        body.dark-mode h2,
        body.dark-mode h3 {
            color: #f9fafb;
        }
        body.dark-mode .filter-tabs .tab {
            background: #020617;
            border-color: #1f2937;
            color: #e5e7eb;
        }
        body.dark-mode .filter-tabs .tab.active {
            background: #dc2626;
            border-color: #dc2626;
            color: #fff;
        }
        body.dark-mode .search-input {
            background: #020617;
            border-color: #1f2937;
            color: #e5e7eb;
        }
        body.dark-mode .users-table th {
            background: #020617;
            border-color: #1f2937;
            color: #e5e7eb;
        }
        body.dark-mode .users-table td {
            border-color: #1f2937;
            color: #cbd5f5;
        }
        body.dark-mode .users-table tr:hover {
            background: #0b1120;
        }
        body.dark-mode .empty-state {
            color: #9ca3af;
        }
        body.dark-mode .modal-header {
            background: #020617;
            border-color: #1f2937;
        }
        body.dark-mode .case-item {
            background: #020617;
            border-color: #1f2937;
        }

        /* ========== ORIGINAL STYLES (slightly wider) ========== */
        .page-header {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
            max-width: 1150px;
            margin-left: auto;
            margin-right: auto;
        }
        
        .page-header h1 {
            color: #1f2937;
            font-size: 2rem;
            margin: 0;
        }
        
        .filter-tabs {
            display: flex;
            gap: 1rem;
        }
        
        .tab {
            padding: 0.75rem 1.5rem;
            background: #f9fafb;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            color: #6b7280;
            transition: all 0.3s;
        }
        
        .tab:hover {
            background: #e5e7eb;
        }
        
        .tab.active {
            background: #dc2626;
            color: white;
            border-color: #dc2626;
        }
        
        .users-container {
            background: white;
            border-radius: 12px;
            padding: 2.25rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            max-width: 1150px;
            margin-left: auto;
            margin-right: auto;
        }
        
        .search-bar {
            margin-bottom: 1.5rem;
            display: flex;
            gap: 1rem;
        }
        
        .search-input {
            flex: 1;
            padding: 0.75rem 1rem;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 0.95rem;
            font-family: 'Inter', sans-serif;
        }
        
        .search-input:focus {
            outline: none;
            border-color: #dc2626;
        }
        
        .users-table {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;
        }
        
        .users-table th {
            padding: 1rem;
            text-align: left;
            font-weight: 600;
            color: #1f2937;
            border-bottom: 2px solid #e5e7eb;
            background: #f9fafb;
        }
        
        .users-table th:nth-child(1) { width: 22%; }  /* User */
        .users-table th:nth-child(2) { width: 8%; }   /* Type */
        .users-table th:nth-child(3) { width: 11%; }  /* Phone */
        .users-table th:nth-child(4) { width: 9%; }   /* City */
        .users-table th:nth-child(5) { width: 12%; }  /* Verification */
        .users-table th:nth-child(6) { width: 8%; }   /* Status */
        .users-table th:nth-child(7) { width: 11%; }  /* Registered */
        .users-table th:nth-child(8) { width: 19%; }  /* Action */
        
        .users-table td {
            padding: 1rem;
            border-bottom: 1px solid #e5e7eb;
            color: #6b7280;
            word-wrap: break-word;
        }
        
        .users-table tr:hover {
            background: #f9fafb;
        }
        
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            flex-shrink: 0;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        
        .user-name {
            font-weight: 600;
            color: #1f2937;
        }
        
        .user-email {
            font-size: 0.85rem;
            color: #6b7280;
        }
        
        .badge {
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            white-space: nowrap;
            display: inline-block;
        }
        
        .badge-client {
            background: #dbeafe;
            color: #1e40af;
        }
        
        .badge-lawyer {
            background: #fef3c7;
            color: #92400e;
        }
        
        .badge-verified {
            background: #d1fae5;
            color: #065f46;
        }
        
        .badge-unverified {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .badge-active {
            background: #dcfce7;
            color: #166534;
        }
        
        .badge-inactive {
            background: #f3f4f6;
            color: #6b7280;
        }
        
        .btn-view {
            padding: 0.5rem 1rem;
            background: #2563eb;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.85rem;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .btn-view:hover {
            background: #1e40af;
            transform: translateY(-1px);
        }
        
        .btn-delete {
            padding: 0.5rem 1rem;
            background: #ef4444;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.85rem;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .btn-delete:hover {
            background: #dc2626;
            transform: translateY(-1px);
        }
        
        .empty-state {
            text-align: center;
            padding: 3rem;
            color: #6b7280;
        }
        
        .empty-state i {
            font-size: 3rem;
            color: #e5e7eb;
            margin-bottom: 1rem;
        }
        
        .modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow-y: auto;
        }
        
        .modal-content {
            background: white;
            border-radius: 12px;
            width: 90%;
            max-width: 900px;
            max-height: 90vh;
            overflow-y: auto;
            margin: 20px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
        }
        
        .modal-header {
            position: sticky;
            top: 0;
            z-index: 10;
            background: #f9fafb;
            padding: 1.5rem 2rem;
            border-bottom: 2px solid #e5e7eb;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .modal-header h2 {
            margin: 0;
            color: #1f2937;
        }
        
        .case-item {
            background: white;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 1rem;
            transition: all 0.3s;
        }
        
        .case-item:hover {
            border-color: #2563eb;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .case-item-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 0.5rem;
        }
        
        .case-item-title {
            font-weight: 700;
            color: #1f2937;
            font-size: 1.1rem;
        }
        
        .case-item-meta {
            color: #6b7280;
            font-size: 0.9rem;
            margin: 0.25rem 0;
        }
        
        .case-item-meta i {
            color: #2563eb;
            width: 18px;
            margin-right: 0.5rem;
        }
        
        @media (max-width: 768px) {
            .users-table {
                display: block;
                overflow-x: auto;
            }
        }
    </style>
</head>
<body>
    <div class="page-header">
        <h1><i class="fas fa-users"></i> All Users</h1>
        <div class="filter-tabs">
            <div class="tab active" onclick="filterUsers('all')" id="tab-all">All Users</div>
            <div class="tab" onclick="filterUsers('client')" id="tab-client">Clients</div>
            <div class="tab" onclick="filterUsers('lawyer')" id="tab-lawyer">Lawyers</div>
        </div>
    </div>
    
    <div class="users-container">
        <div class="search-bar">
            <input type="text" class="search-input" id="searchInput" 
                   placeholder="Search by name or email..." 
                   onkeyup="searchUsers()">
        </div>
        
        <table class="users-table" id="usersTable">
            <thead>
                <tr>
                    <th>User</th>
                    <th>Type</th>
                    <th>Phone</th>
                    <th>City</th>
                    <th>Verification</th>
                    <th>Status</th>
                    <th>Registered</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="usersTableBody">
                <!-- Data loaded via JavaScript -->
            </tbody>
        </table>
        
        <div id="emptyState" class="empty-state" style="display: none;">
            <i class="fas fa-users-slash"></i>
            <h3>No Users Found</h3>
        </div>
    </div>

    <!-- User Details Modal -->
    <div id="userDetailsModal" class="modal" style="display: none;">
        <div class="modal-content">
            <div class="modal-header">
                <h2 id="modalUserName">User Details</h2>
                <button onclick="closeUserModal()" style="background: none; border: none; font-size: 1.5rem; color: #6b7280; cursor: pointer;">&times;</button>
            </div>
            
            <div style="padding: 2rem;">
                <div id="loadingDetails" style="text-align: center; padding: 3rem;">
                    <i class="fas fa-spinner fa-spin" style="font-size: 3rem; color: #2563eb;"></i>
                    <p style="margin-top: 1rem; color: #6b7280;">Loading details...</p>
                </div>
                
                <div id="userCasesContainer" style="display: none;">
                    <h3 style="color: #1f2937; margin-bottom: 1rem; display: flex; align-items: center; gap: 0.5rem;">
                        <i class="fas fa-folder-open"></i>
                        <span id="casesTitle">Cases</span>
                    </h3>
                    <div id="userCasesList"></div>
                </div>
                
                <div id="noCasesMessage" style="display: none; text-align: center; padding: 3rem; background: #f9fafb; border-radius: 8px;">
                    <i class="fas fa-folder-open" style="font-size: 3rem; color: #e5e7eb;"></i>
                    <p style="margin-top: 1rem; color: #6b7280;">No cases found</p>
                </div>
            </div>
        </div>
    </div>

    <script>
        let allUsers = [];
        let currentFilter = 'all';
        
        window.onload = function() {
            loadAllUsers();
            
            var urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('deleted') === 'true') {
                showNotification('User deleted successfully', 'success');
            }
        };
        
        function loadAllUsers() {
            fetch('GetAllUsersServlet')
                .then(function(response) {
                    return response.json();
                })
                .then(function(data) {
                    allUsers = data;
                    displayUsers(data);
                })
                .catch(function(error) {
                    console.error('Error loading users:', error);
                    document.getElementById('emptyState').style.display = 'block';
                });
        }
        
        function displayUsers(users) {
            var tbody = document.getElementById('usersTableBody');
            tbody.innerHTML = '';
            
            if (users.length === 0) {
                document.getElementById('usersTable').style.display = 'none';
                document.getElementById('emptyState').style.display = 'block';
                return;
            }
            
            document.getElementById('usersTable').style.display = 'table';
            document.getElementById('emptyState').style.display = 'none';
            
            users.forEach(function(user) {
                var row = document.createElement('tr');
                
                var initials = user.firstName.charAt(0) + user.lastName.charAt(0);
                var typeBadgeClass = user.userType === 'client' ? 'badge-client' : 'badge-lawyer';
                var verificationBadge = '';
                
                if (user.userType === 'lawyer') {
                    verificationBadge = user.isVerified ? 
                        '<span class="badge badge-verified"><i class="fas fa-check-circle"></i> Verified</span>' :
                        '<span class="badge badge-unverified"><i class="fas fa-clock"></i> Unverified</span>';
                } else {
                    verificationBadge = '<span class="badge" style="background:#f3f4f6; color:#9ca3af;">N/A</span>';
                }
                
                var statusBadge = user.isActive ? 
                    '<span class="badge badge-active">Active</span>' :
                    '<span class="badge badge-inactive">Inactive</span>';
                
                row.innerHTML =
                    '<td>' +
                        '<div class="user-info">' +
                            '<div class="user-avatar">' + initials + '</div>' +
                            '<div>' +
                                '<div class="user-name">' + escapeHtml(user.firstName) + ' ' + escapeHtml(user.lastName) + '</div>' +
                                '<div class="user-email">' + escapeHtml(user.email) + '</div>' +
                            '</div>' +
                        '</div>' +
                    '</td>' +
                    '<td><span class="badge ' + typeBadgeClass + '">' + user.userType.toUpperCase() + '</span></td>' +
                    '<td>' + escapeHtml(user.phone) + '</td>' +
                    '<td>' + escapeHtml(user.city) + '</td>' +
                    '<td>' + verificationBadge + '</td>' +
                    '<td>' + statusBadge + '</td>' +
                    '<td>' + user.registeredDate + '</td>' +
                    '<td>' +
                        '<div style="display: flex; gap: 0.5rem;">' +
                            '<button class="btn-view" onclick="viewUserDetails(' + user.userId + ', \'' + user.userType + '\', \'' + escapeHtml(user.firstName + ' ' + user.lastName) + '\')" title="View Details">' +
                                '<i class="fas fa-eye"></i> View' +
                            '</button>' +
                            '<button class="btn-delete" onclick="deleteUser(' + user.userId + ', \'' + user.userType + '\')" title="Delete User">' +
                                '<i class="fas fa-trash"></i> Delete' +
                            '</button>' +
                        '</div>' +
                    '</td>';
                
                tbody.appendChild(row);
            });
        }
        
        function filterUsers(type) {
            currentFilter = type;
            
            // Update active tab
            document.querySelectorAll('.tab').forEach(function(tab) {
                tab.classList.remove('active');
            });
            document.getElementById('tab-' + type).classList.add('active');
            
            // Filter users
            var filtered = allUsers;
            if (type !== 'all') {
                filtered = allUsers.filter(function(user) {
                    return user.userType === type;
                });
            }
            
            displayUsers(filtered);
        }
        
        function searchUsers() {
            var searchTerm = document.getElementById('searchInput').value.toLowerCase();
            
            var filtered = allUsers.filter(function(user) {
                var fullName = (user.firstName + ' ' + user.lastName).toLowerCase();
                var email = user.email.toLowerCase();
                return fullName.includes(searchTerm) || email.includes(searchTerm);
            });
            
            // Apply current filter
            if (currentFilter !== 'all') {
                filtered = filtered.filter(function(user) {
                    return user.userType === currentFilter;
                });
            }
            
            displayUsers(filtered);
        }
        
        function viewUserDetails(userId, userType, userName) {
            document.getElementById('userDetailsModal').style.display = 'flex';
            document.getElementById('modalUserName').textContent = userName;
            document.getElementById('loadingDetails').style.display = 'block';
            document.getElementById('userCasesContainer').style.display = 'none';
            document.getElementById('noCasesMessage').style.display = 'none';
            document.body.style.overflow = 'hidden';
            
            var casesTitle = userType === 'client' ? 'Cases Raised by Client' : 'Cases Worked On by Lawyer';
            document.getElementById('casesTitle').textContent = casesTitle;
            
            fetch('GetUserCasesServlet?userId=' + userId + '&userType=' + userType)
                .then(function(response) {
                    return response.json();
                })
                .then(function(data) {
                    document.getElementById('loadingDetails').style.display = 'none';
                    
                    if (data.length === 0) {
                        document.getElementById('noCasesMessage').style.display = 'block';
                        return;
                    }
                    
                    document.getElementById('userCasesContainer').style.display = 'block';
                    displayUserCases(data, userType);
                })
                .catch(function(error) {
                    console.error('Error loading cases:', error);
                    document.getElementById('loadingDetails').style.display = 'none';
                    document.getElementById('noCasesMessage').style.display = 'block';
                });
        }
        
        function displayUserCases(cases, userType) {
            var container = document.getElementById('userCasesList');
            container.innerHTML = '';
            
            cases.forEach(function(c) {
                var statusColors = {
                    'pending': '#fef3c7',
                    'active': '#dcfce7',
                    'completed': '#d1fae5',
                    'cancelled': '#fee2e2'
                };
                var statusTextColors = {
                    'pending': '#92400e',
                    'active': '#166534',
                    'completed': '#065f46',
                    'cancelled': '#991b1b'
                };
                
                var item = document.createElement('div');
                item.className = 'case-item';
                
                var partnerInfo = '';
                if (userType === 'client' && c.lawyerName) {
                    partnerInfo = '<div class="case-item-meta"><i class="fas fa-gavel"></i> Lawyer: ' + escapeHtml(c.lawyerName) + '</div>';
                } else if (userType === 'lawyer' && c.clientName) {
                    partnerInfo = '<div class="case-item-meta"><i class="fas fa-user"></i> Client: ' + escapeHtml(c.clientName) + '</div>';
                }
                
                item.innerHTML =
                    '<div class="case-item-header">' +
                        '<div>' +
                            '<div class="case-item-title">' + escapeHtml(c.title) + '</div>' +
                            '<div class="case-item-meta" style="font-size: 0.85rem; color: #9ca3af;">Case #' + c.caseId + '</div>' +
                        '</div>' +
                        '<span style="padding: 0.25rem 0.75rem; border-radius: 20px; font-size: 0.85rem; font-weight: 600; background: ' + statusColors[c.status] + '; color: ' + statusTextColors[c.status] + ';">' +
                            c.status.charAt(0).toUpperCase() + c.status.slice(1) +
                        '</span>' +
                    '</div>' +
                    partnerInfo +
                    '<div class="case-item-meta"><i class="fas fa-balance-scale"></i> ' + escapeHtml(c.type) + '</div>' +
                    '<div class="case-item-meta"><i class="fas fa-map-marker-alt"></i> ' + escapeHtml(c.city) + '</div>' +
                    '<div class="case-item-meta"><i class="fas fa-calendar"></i> Created: ' + c.createdAt + '</div>';
                
                container.appendChild(item);
            });
        }
        
        function closeUserModal() {
            document.getElementById('userDetailsModal').style.display = 'none';
            document.body.style.overflow = 'auto';
        }
        
        function deleteUser(userId, userType) {
            if (confirm('Are you sure you want to delete this user? This action cannot be undone and will delete all associated data.')) {
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = 'DeleteUserServlet';
                
                var userIdInput = document.createElement('input');
                userIdInput.type = 'hidden';
                userIdInput.name = 'userId';
                userIdInput.value = userId;
                form.appendChild(userIdInput);
                
                var userTypeInput = document.createElement('input');
                userTypeInput.type = 'hidden';
                userTypeInput.name = 'userType';
                userTypeInput.value = userType;
                form.appendChild(userTypeInput);
                
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        function escapeHtml(text) {
            var div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
        
        function showNotification(message, type) {
            var notification = document.createElement('div');
            notification.style.cssText = 'position: fixed; top: 20px; right: 20px; padding: 1rem 1.5rem; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.2); z-index: 9999; font-weight: 600;';
            notification.style.background = type === 'success' ? '#10b981' : '#ef4444';
            notification.style.color = 'white';
            notification.innerHTML = message;
            
            document.body.appendChild(notification);
            
            setTimeout(function() {
                notification.style.transition = 'opacity 0.3s ease';
                notification.style.opacity = '0';
                setTimeout(function() {
                    document.body.removeChild(notification);
                }, 300);
            }, 3000);
        }
    </script>
</body>
</html>

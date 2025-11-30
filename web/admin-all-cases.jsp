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
    <link rel="stylesheet" href="dark-mode.css">
    <script src="dark-mode.js" defer></script>
    <style>
        body {
            margin: 0;
            padding: 20px;
            background: #f9fafb;
            font-family: 'Inter', sans-serif;
        }

        /* ===== DARK MODE – only colors, no layout change ===== */
        body.dark-mode {
            background: #020617;
            color: #e5e7eb;
        }
        body.dark-mode .page-header,
        body.dark-mode .search-container,
        body.dark-mode .case-card {
            background: #020617;
            color: #e5e7eb;
            box-shadow: 0 2px 12px rgba(15,23,42,0.7);
        }
        body.dark-mode .page-header h1 {
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
        body.dark-mode .case-description {
            background: #0b1120;
            color: #cbd5f5;
        }
        body.dark-mode .detail-row {
            color: #cbd5f5;
        }
        body.dark-mode .detail-row strong {
            color: #e5e7eb;
        }
        body.dark-mode .empty-state {
            background: #020617;
            color: #9ca3af;
        }

        /* ===== ORIGINAL STYLES (slightly wider, centered) ===== */
        .page-header {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 1rem;
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
            flex-wrap: wrap;
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
        
        .search-container {
            background: white;
            padding: 1.5rem 2rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            max-width: 1150px;
            margin-left: auto;
            margin-right: auto;
        }
        
        .search-input {
            width: 100%;
            padding: 0.75rem 1rem;
            padding-left: 2.5rem;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 0.95rem;
            font-family: 'Inter', sans-serif;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%236b7280'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: 0.75rem center;
            background-size: 1.25rem;
            box-sizing: border-box;
        }
        
        .search-input:focus {
            outline: none;
            border-color: #dc2626;
        }
        
        .cases-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
            gap: 1.5rem;
            max-width: 1150px;
            margin-left: auto;
            margin-right: auto;
        }
        
        .case-card {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            border-left: 4px solid #8b5cf6;
            transition: all 0.3s;
        }
        
        .case-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        
        .case-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 1rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid #f9fafb;
        }
        
        .case-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: #1f2937;
            margin-bottom: 0.25rem;
        }
        
        .case-id {
            font-size: 0.85rem;
            color: #6b7280;
        }
        
        .status-badge {
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
        }
        
        .status-pending {
            background: #fef3c7;
            color: #92400e;
        }
        
        .status-active {
            background: #dcfce7;
            color: #166534;
        }
        
        .status-completed {
            background: #d1fae5;
            color: #065f46;
        }
        
        .status-cancelled {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .case-details {
            display: grid;
            gap: 0.75rem;
            margin-bottom: 1rem;
        }
        
        .detail-row {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            color: #6b7280;
            font-size: 0.9rem;
        }
        
        .detail-row i {
            color: #dc2626;
            width: 20px;
        }
        
        .detail-row strong {
            color: #1f2937;
        }
        
        .case-description {
            background: #f9fafb;
            padding: 1rem;
            border-radius: 8px;
            color: #6b7280;
            font-size: 0.9rem;
            line-height: 1.6;
            margin-top: 1rem;
            max-height: 100px;
            overflow-y: auto;
        }
        
        .btn-delete {
            width: 100%;
            padding: 0.75rem;
            background: #ef4444;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.9rem;
            transition: all 0.3s;
            margin-top: 1rem;
        }
        
        .btn-delete:hover {
            background: #dc2626;
            transform: translateY(-2px);
        }
        
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            background: white;
            border-radius: 12px;
            max-width: 1150px;
            margin: 0 auto;
        }
        
        .empty-state i {
            font-size: 4rem;
            color: #e5e7eb;
            margin-bottom: 1rem;
        }
        
        .empty-state h3 {
            color: #1f2937;
            margin-bottom: 0.5rem;
        }
        
        .empty-state p {
            color: #6b7280;
        }
        
        @media (max-width: 768px) {
            .cases-grid {
                grid-template-columns: 1fr;
            }
            
            .filter-tabs {
                width: 100%;
            }
            
            .tab {
                flex: 1;
                text-align: center;
                padding: 0.5rem 1rem;
                font-size: 0.85rem;
            }
        }
    </style>
</head>
<body>
    <div class="page-header">
        <h1><i class="fas fa-folder-open"></i> All Cases</h1>
        <div class="filter-tabs">
            <div class="tab active" onclick="filterCases('all')" id="tab-all">All</div>
            <div class="tab" onclick="filterCases('pending')" id="tab-pending">Pending</div>
            <div class="tab" onclick="filterCases('active')" id="tab-active">Active</div>
            <div class="tab" onclick="filterCases('completed')" id="tab-completed">Completed</div>
            <div class="tab" onclick="filterCases('cancelled')" id="tab-cancelled">Cancelled</div>
        </div>
    </div>

    <div class="search-container">
        <input type="text" id="searchInput" class="search-input" 
               placeholder="Search by case title, client name, or lawyer name..." 
               onkeyup="searchCases()">
    </div>

    <div id="loadingState" style="display: none; text-align: center; padding: 3rem;">
        <i class="fas fa-spinner fa-spin" style="font-size: 3rem; color: #dc2626;"></i>
        <p style="margin-top: 1rem; color: #6b7280;">Loading cases...</p>
    </div>

    <div id="casesGrid" class="cases-grid"></div>

    <div id="emptyState" class="empty-state" style="display: none;">
        <i class="fas fa-folder-open"></i>
        <h3>No Cases Found</h3>
        <p>No cases match the selected filter or search criteria</p>
    </div>

    <script>
        let allCases = [];
        let currentFilter = 'all';
        
        window.onload = function() {
            loadAllCases();
            
            var urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('deleted') === 'true') {
                showNotification('Case deleted successfully', 'success');
            }
        };
        
        function loadAllCases() {
            document.getElementById('loadingState').style.display = 'block';
            document.getElementById('casesGrid').style.display = 'none';
            document.getElementById('emptyState').style.display = 'none';

            fetch('GetAllCasesServlet')
                .then(function(response) {
                    return response.json();
                })
                .then(function(data) {
                    document.getElementById('loadingState').style.display = 'none';
                    allCases = data;
                    displayCases(data);
                })
                .catch(function(error) {
                    console.error('Error loading cases:', error);
                    document.getElementById('loadingState').style.display = 'none';
                    document.getElementById('emptyState').style.display = 'block';
                });
        }
        
        function displayCases(cases) {
            var grid = document.getElementById('casesGrid');
            grid.innerHTML = '';
            
            if (cases.length === 0) {
                document.getElementById('casesGrid').style.display = 'none';
                document.getElementById('emptyState').style.display = 'block';
                return;
            }
            
            document.getElementById('casesGrid').style.display = 'grid';
            document.getElementById('emptyState').style.display = 'none';
            
            cases.forEach(function(c) {
                var card = document.createElement('div');
                card.className = 'case-card';
                
                var statusClass = 'status-' + c.status;
                var statusText = c.status.charAt(0).toUpperCase() + c.status.slice(1);
                
                var lawyerInfo = c.lawyerName ? 
                    '<div class="detail-row">' +
                        '<i class="fas fa-gavel"></i>' +
                        '<span><strong>Lawyer:</strong> ' + escapeHtml(c.lawyerName) + '</span>' +
                    '</div>' : 
                    '<div class="detail-row">' +
                        '<i class="fas fa-gavel"></i>' +
                        '<span><strong>Lawyer:</strong> Not Assigned</span>' +
                    '</div>';
                
                card.innerHTML =
                    '<div class="case-header">' +
                        '<div>' +
                            '<div class="case-title">' + escapeHtml(c.title) + '</div>' +
                            '<div class="case-id">Case #' + c.caseId + '</div>' +
                        '</div>' +
                        '<span class="status-badge ' + statusClass + '">' + statusText + '</span>' +
                    '</div>' +
                    
                    '<div class="case-details">' +
                        '<div class="detail-row">' +
                            '<i class="fas fa-user"></i>' +
                            '<span><strong>Client:</strong> ' + escapeHtml(c.clientName) + '</span>' +
                        '</div>' +
                        lawyerInfo +
                        '<div class="detail-row">' +
                            '<i class="fas fa-balance-scale"></i>' +
                            '<span><strong>Type:</strong> ' + escapeHtml(c.type) + '</span>' +
                        '</div>' +
                        '<div class="detail-row">' +
                            '<i class="fas fa-map-marker-alt"></i>' +
                            '<span><strong>Location:</strong> ' + escapeHtml(c.city) + '</span>' +
                        '</div>' +
                        '<div class="detail-row">' +
                            '<i class="fas fa-clock"></i>' +
                            '<span><strong>Urgency:</strong> ' + (c.urgency || 'Normal') + '</span>' +
                        '</div>' +
                        '<div class="detail-row">' +
                            '<i class="fas fa-calendar"></i>' +
                            '<span><strong>Created:</strong> ' + c.createdAt + '</span>' +
                        '</div>' +
                    '</div>' +
                    
                    '<div class="case-description">' +
                        '<strong>Description:</strong><br>' +
                        escapeHtml(c.description) +
                    '</div>' +
                    
                    '<button class="btn-delete" onclick="deleteCase(' + c.caseId + ')">' +
                        '<i class="fas fa-trash"></i> Delete Case' +
                    '</button>';
                
                grid.appendChild(card);
            });
        }
        
        function filterCases(status) {
            currentFilter = status;
            
            document.querySelectorAll('.tab').forEach(function(tab) {
                tab.classList.remove('active');
            });
            document.getElementById('tab-' + status).classList.add('active');
            
            applyFiltersAndSearch();
        }
        
        function searchCases() {
            applyFiltersAndSearch();
        }
        
        function applyFiltersAndSearch() {
            var searchTerm = document.getElementById('searchInput').value.toLowerCase();
            
            var filtered = allCases.filter(function(c) {
                var title = c.title.toLowerCase();
                var clientName = c.clientName.toLowerCase();
                var lawyerName = c.lawyerName ? c.lawyerName.toLowerCase() : '';
                var caseId = 'case #' + c.caseId;
                
                return title.includes(searchTerm) || 
                       clientName.includes(searchTerm) || 
                       lawyerName.includes(searchTerm) ||
                       caseId.includes(searchTerm);
            });
            
            if (currentFilter !== 'all') {
                filtered = filtered.filter(function(c) {
                    return c.status === currentFilter;
                });
            }
            
            displayCases(filtered);
        }
        
        function deleteCase(caseId) {
            if (confirm('Are you sure you want to delete this case? This will also delete all associated data.')) {
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = 'DeleteCaseServlet';
                
                var input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'caseId';
                input.value = caseId;
                form.appendChild(input);
                
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

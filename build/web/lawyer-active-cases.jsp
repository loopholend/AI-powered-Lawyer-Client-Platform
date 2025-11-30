<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
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
        
        .tabs {
            display: flex;
            gap: 1rem;
            margin-bottom: 2rem;
            flex-wrap: wrap;
        }
        
        .tab {
            padding: 0.75rem 1.5rem;
            background: white;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            color: #6b7280;
            transition: all 0.3s;
        }
        
        .tab.active {
            background: linear-gradient(135deg, #ec4899 0%, #db2777 100%);
            color: white;
            border-color: #ec4899;
        }
        
        .tab:hover:not(.active) {
            border-color: #ec4899;
            color: #ec4899;
        }
        
        .cases-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 1.5rem;
        }
        
        .case-card {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            border-left: 4px solid #ec4899;
            transition: all 0.3s;
        }
        
        .case-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 4px 16px rgba(0,0,0,0.1);
        }
        
        .case-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 1rem;
            gap: 1rem;
        }
        
        .case-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: #1f2937;
            flex: 1;
        }
        
        .status-badge {
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            white-space: nowrap;
        }
        
        .status-active {
            background: #dbeafe;
            color: #1e40af;
        }
        
        .status-pending {
            background: #fef3c7;
            color: #b45309;
        }
        
        .status-completed {
            background: #d1fae5;
            color: #065f46;
        }
        
        .client-info {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1rem;
            padding: 1rem;
            background: #f9fafb;
            border-radius: 8px;
        }
        
        .client-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
        }
        
        .client-details {
            flex: 1;
        }
        
        .client-name {
            font-weight: 600;
            color: #1f2937;
            margin-bottom: 0.25rem;
        }
        
        .client-email {
            color: #6b7280;
            font-size: 0.85rem;
        }
        
        .case-description {
            color: #6b7280;
            line-height: 1.6;
            margin-bottom: 1rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        .case-meta {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            margin-bottom: 1rem;
        }
        
        .meta-item {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            color: #6b7280;
            font-size: 0.9rem;
        }
        
        .meta-item i {
            color: #ec4899;
            width: 18px;
        }
        
        .case-actions {
            display: flex;
            gap: 0.75rem;
        }
        
        .btn-update, .btn-complete, .btn-view {
            flex: 1;
            padding: 0.75rem 1rem;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            font-size: 0.9rem;
        }
        
        .btn-update {
            background: #ec4899;
            color: white;
        }
        
        .btn-update:hover {
            background: #db2777;
            transform: translateY(-2px);
        }
        
        .btn-complete {
            background: #10b981;
            color: white;
        }
        
        .btn-complete:hover {
            background: #059669;
            transform: translateY(-2px);
        }
        
        .btn-view {
            background: #f9fafb;
            color: #1f2937;
            border: 2px solid #e5e7eb;
        }
        
        .btn-view:hover {
            background: #e5e7eb;
        }
        
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            background: white;
            border-radius: 12px;
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
        
        /* Update Modal */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
        }
        
        .modal.active {
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .modal-content {
            background: white;
            border-radius: 12px;
            padding: 2rem;
            max-width: 500px;
            width: 90%;
            max-height: 90vh;
            overflow-y: auto;
        }
        
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        
        .modal-header h2 {
            color: #1f2937;
            margin: 0;
        }
        
        .close-btn {
            background: none;
            border: none;
            font-size: 1.5rem;
            color: #6b7280;
            cursor: pointer;
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-group label {
            display: block;
            color: #1f2937;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }
        
        .form-control {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-family: 'Inter', sans-serif;
            box-sizing: border-box;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #ec4899;
        }
        
        textarea.form-control {
            min-height: 100px;
            resize: vertical;
        }
        
        .btn-submit {
            width: 100%;
            padding: 1rem;
            background: linear-gradient(135deg, #ec4899 0%, #db2777 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(236, 72, 153, 0.4);
        }
        
        @media (max-width: 768px) {
            .cases-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="page-header">
        <h1><i class="fas fa-briefcase"></i> My Active Cases</h1>
        <p>Manage your ongoing cases and client communications</p>
    </div>

    <div class="tabs">
        <div class="tab active" onclick="filterCases('all')">
            <i class="fas fa-list"></i> All Cases
        </div>
        <div class="tab" onclick="filterCases('active')">
            <i class="fas fa-play-circle"></i> Active
        </div>
        <div class="tab" onclick="filterCases('pending')">
            <i class="fas fa-clock"></i> Pending
        </div>
        <div class="tab" onclick="filterCases('completed')">
            <i class="fas fa-check-circle"></i> Completed
        </div>
    </div>

    <div id="casesGrid" class="cases-grid"></div>
    
    <div id="emptyState" class="empty-state" style="display: none;">
        <i class="fas fa-briefcase"></i>
        <h3>No Active Cases</h3>
        <p>Your accepted cases will appear here</p>
    </div>

    <!-- Update Modal -->
    <div id="updateModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Update Case Status</h2>
                <button class="close-btn" onclick="closeUpdateModal()">&times;</button>
            </div>
            
            <form id="updateForm" onsubmit="submitUpdate(event)">
                <input type="hidden" id="updateCaseId" name="caseId">
                
                <div class="form-group">
                    <label>Case Status</label>
                    <select class="form-control" name="status" required>
                        <option value="Active">Active</option>
                        <option value="Pending">Pending</option>
                        <option value="Completed">Completed</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>Update Notes</label>
                    <textarea class="form-control" name="notes" required
                              placeholder="Enter case progress notes..."></textarea>
                </div>
                
                <button type="submit" class="btn-submit">
                    <i class="fas fa-save"></i> Save Update
                </button>
            </form>
        </div>
    </div>

    <script>
        var currentFilter = 'all';
        
        window.onload = function() {
            loadCases();
        };
        
        function filterCases(filter) {
            currentFilter = filter;
            
            document.querySelectorAll('.tab').forEach(function(tab) {
                tab.classList.remove('active');
            });
            event.target.closest('.tab').classList.add('active');
            
            loadCases();
        }
        
        function loadCases() {
            fetch('GetLawyerActiveCasesServlet?filter=' + currentFilter)
                .then(function(response) {
                    return response.json();
                })
                .then(function(data) {
                    displayCases(data);
                })
                .catch(function(error) {
                    console.error('Error loading cases:', error);
                    document.getElementById('emptyState').style.display = 'block';
                });
        }
        
        function displayCases(cases) {
            var grid = document.getElementById('casesGrid');
            var emptyState = document.getElementById('emptyState');
            
            if (cases.length === 0) {
                grid.style.display = 'none';
                emptyState.style.display = 'block';
                return;
            }
            
            grid.style.display = 'grid';
            emptyState.style.display = 'none';
            grid.innerHTML = '';
            
            cases.forEach(function(c) {
                var card = document.createElement('div');
                card.className = 'case-card';
                
                var statusClass = 'status-' + c.status.toLowerCase();
                var clientInitials = c.clientName.split(' ').map(function(n) { return n[0]; }).join('');
                
                card.innerHTML =
                    '<div class="case-header">' +
                        '<div class="case-title">' + escapeHtml(c.title) + '</div>' +
                        '<div class="status-badge ' + statusClass + '">' + c.status + '</div>' +
                    '</div>' +
                    
                    '<div class="client-info">' +
                        '<div class="client-avatar">' + clientInitials + '</div>' +
                        '<div class="client-details">' +
                            '<div class="client-name">' + escapeHtml(c.clientName) + '</div>' +
                            '<div class="client-email">' + escapeHtml(c.clientEmail) + '</div>' +
                        '</div>' +
                    '</div>' +
                    
                    '<div class="case-description">' + escapeHtml(c.description) + '</div>' +
                    
                    '<div class="case-meta">' +
                        '<div class="meta-item"><i class="fas fa-tag"></i><span>' + escapeHtml(c.type) + '</span></div>' +
                        '<div class="meta-item"><i class="fas fa-map-marker-alt"></i><span>' + escapeHtml(c.city) + '</span></div>' +
                        '<div class="meta-item"><i class="fas fa-calendar"></i><span>Started: ' + c.acceptedDate + '</span></div>' +
                    '</div>' +
                    
                    '<div class="case-actions">' +
                        '<button class="btn-update" onclick="openUpdateModal(' + c.caseId + ')">' +
                            '<i class="fas fa-edit"></i> Update' +
                        '</button>' +
                        (c.status !== 'Completed' ? 
                            '<button class="btn-complete" onclick="completeCase(' + c.caseId + ')">' +
                                '<i class="fas fa-check"></i> Complete' +
                            '</button>' : '') +
                        '<button class="btn-view" onclick="viewCase(' + c.caseId + ')">' +
                            '<i class="fas fa-eye"></i> View' +
                        '</button>' +
                    '</div>';
                
                grid.appendChild(card);
            });
        }
        
        function openUpdateModal(caseId) {
            document.getElementById('updateCaseId').value = caseId;
            document.getElementById('updateModal').classList.add('active');
        }
        
        function closeUpdateModal() {
            document.getElementById('updateModal').classList.remove('active');
            document.getElementById('updateForm').reset();
        }
        
        function submitUpdate(event) {
            event.preventDefault();
            
            var formData = new FormData(event.target);
            
            fetch('UpdateCaseStatusServlet', {
                method: 'POST',
                body: formData
            })
            .then(function(response) {
                return response.text();
            })
            .then(function(data) {
                closeUpdateModal();
                alert('Case updated successfully!');
                loadCases();
            })
            .catch(function(error) {
                console.error('Error:', error);
                alert('Failed to update case. Please try again.');
            });
        }
        
        function completeCase(caseId) {
            if (confirm('Mark this case as completed?')) {
                var formData = new FormData();
                formData.append('caseId', caseId);
                formData.append('status', 'Completed');
                formData.append('notes', 'Case completed successfully');
                
                fetch('UpdateCaseStatusServlet', {
                    method: 'POST',
                    body: formData
                })
                .then(function(response) {
                    return response.text();
                })
                .then(function(data) {
                    alert('Case marked as completed!');
                    loadCases();
                })
                .catch(function(error) {
                    console.error('Error:', error);
                    alert('Failed to complete case.');
                });
            }
        }
        
        function viewCase(caseId) {
            alert('View case details for ID: ' + caseId);
        }
        
        function escapeHtml(text) {
            var div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
    </script>
</body>
</html>

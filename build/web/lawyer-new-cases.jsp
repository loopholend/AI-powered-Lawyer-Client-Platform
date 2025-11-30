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
        
        .filters-section {
            background: white;
            padding: 1.5rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        .filters-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            align-items: end;
        }
        
        .filter-group {
            display: flex;
            flex-direction: column;
        }
        
        .filter-group label {
            color: #1f2937;
            font-weight: 600;
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
        }
        
        .filter-input {
            padding: 0.75rem;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 0.95rem;
            font-family: 'Inter', sans-serif;
        }
        
        .filter-input:focus {
            outline: none;
            border-color: #ec4899;
        }
        
        .btn-filter {
            padding: 0.75rem 1.5rem;
            background: linear-gradient(135deg, #ec4899 0%, #db2777 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-filter:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(236, 72, 153, 0.4);
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
        
        .case-type {
            padding: 0.25rem 0.75rem;
            background: #fdf2f8;
            color: #db2777;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            white-space: nowrap;
        }
        
        .case-description {
            color: #6b7280;
            line-height: 1.6;
            margin-bottom: 1rem;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        .case-meta {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            margin-bottom: 1rem;
            padding: 1rem;
            background: #f9fafb;
            border-radius: 8px;
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
        
        .btn-request, .btn-view-details {
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
        
        .btn-request {
            background: #ec4899;
            color: white;
        }
        
        .btn-request:hover {
            background: #db2777;
            transform: translateY(-2px);
        }
        
        .btn-view-details {
            background: #f9fafb;
            color: #1f2937;
            border: 2px solid #e5e7eb;
        }
        
        .btn-view-details:hover {
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
        
        /* Request Modal */
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
        <h1><i class="fas fa-folder-open"></i> Available Cases</h1>
        <p>Browse and request to work on new cases</p>
    </div>

    <div class="filters-section">
        <form class="filters-grid" id="filterForm">
            <div class="filter-group">
                <label>Case Type</label>
                <select class="filter-input" id="caseType" name="caseType">
                    <option value="">All Types</option>
                    <option value="Criminal Law">Criminal Law</option>
                    <option value="Civil Law">Civil Law</option>
                    <option value="Family Law">Family Law</option>
                    <option value="Corporate Law">Corporate Law</option>
                    <option value="Property Law">Property Law</option>
                    <option value="Tax Law">Tax Law</option>
                    <option value="Labour Law">Labour Law</option>
                </select>
            </div>
            
            <div class="filter-group">
                <label>City</label>
                <input type="text" class="filter-input" id="city" name="city" placeholder="Enter city">
            </div>
            
            <div class="filter-group">
                <label>Urgency</label>
                <select class="filter-input" id="urgency" name="urgency">
                    <option value="">All</option>
                    <option value="Normal">Normal</option>
                    <option value="Urgent">Urgent</option>
                    <option value="Very Urgent">Very Urgent</option>
                </select>
            </div>
            
            <button type="submit" class="btn-filter">
                <i class="fas fa-filter"></i> Apply Filters
            </button>
        </form>
    </div>

    <div id="casesGrid" class="cases-grid"></div>
    
    <div id="emptyState" class="empty-state" style="display: none;">
        <i class="fas fa-folder-open"></i>
        <h3>No Cases Available</h3>
        <p>Check back later for new cases</p>
    </div>

    <!-- Request Modal -->
    <div id="requestModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Send Request to Client</h2>
                <button class="close-btn" onclick="closeRequestModal()">&times;</button>
            </div>
            
            <form id="requestForm" onsubmit="submitRequest(event)">
                <input type="hidden" id="requestCaseId" name="caseId">
                
                <div class="form-group">
                    <label>Proposed Fee (Optional)</label>
                    <input type="number" class="form-control" name="proposedFee" 
                           placeholder="Enter your consultation fee">
                </div>
                
                <div class="form-group">
                    <label>Message to Client</label>
                    <textarea class="form-control" name="message" required
                              placeholder="Introduce yourself and explain why you're a good fit for this case..."></textarea>
                </div>
                
                <button type="submit" class="btn-submit">
                    <i class="fas fa-paper-plane"></i> Send Request
                </button>
            </form>
        </div>
    </div>

    <script>
        window.onload = function() {
            loadCases();
        };
        
        document.getElementById('filterForm').addEventListener('submit', function(e) {
            e.preventDefault();
            loadCases();
        });
        
        function loadCases() {
            var caseType = document.getElementById('caseType').value;
            var city = document.getElementById('city').value;
            var urgency = document.getElementById('urgency').value;
            
            var params = new URLSearchParams({
                caseType: caseType,
                city: city,
                urgency: urgency
            });
            
            fetch('GetAvailableCasesServlet?' + params.toString())
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
                
                card.innerHTML =
                    '<div class="case-header">' +
                        '<div class="case-title">' + escapeHtml(c.title) + '</div>' +
                        '<div class="case-type">' + escapeHtml(c.type) + '</div>' +
                    '</div>' +
                    '<div class="case-description">' + escapeHtml(c.description) + '</div>' +
                    '<div class="case-meta">' +
                        '<div class="meta-item"><i class="fas fa-map-marker-alt"></i><span>' + escapeHtml(c.city) + '</span></div>' +
                        '<div class="meta-item"><i class="fas fa-clock"></i><span>Urgency: ' + escapeHtml(c.urgency || 'Normal') + '</span></div>' +
                        '<div class="meta-item"><i class="fas fa-calendar"></i><span>Posted: ' + c.createdAt + '</span></div>' +
                    '</div>' +
                    '<div class="case-actions">' +
                        '<button class="btn-request" onclick="openRequestModal(' + c.caseId + ')">' +
                            '<i class="fas fa-paper-plane"></i> Send Request' +
                        '</button>' +
                        '<button class="btn-view-details" onclick="viewDetails(' + c.caseId + ')">' +
                            '<i class="fas fa-eye"></i> Details' +
                        '</button>' +
                    '</div>';
                
                grid.appendChild(card);
            });
        }
        
        function openRequestModal(caseId) {
            document.getElementById('requestCaseId').value = caseId;
            document.getElementById('requestModal').classList.add('active');
        }
        
        function closeRequestModal() {
            document.getElementById('requestModal').classList.remove('active');
            document.getElementById('requestForm').reset();
        }
        
        function submitRequest(event) {
            event.preventDefault();
            
            var formData = new FormData(event.target);
            
            fetch('SendCaseRequestServlet', {
                method: 'POST',
                body: formData
            })
            .then(function(response) {
                return response.text();
            })
            .then(function(data) {
                closeRequestModal();
                alert('Request sent successfully!');
                loadCases();
            })
            .catch(function(error) {
                console.error('Error:', error);
                alert('Failed to send request. Please try again.');
            });
        }
        
        function viewDetails(caseId) {
            alert('Case details for ID: ' + caseId);
        }
        
        function escapeHtml(text) {
            var div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
    </script>
</body>
</html>

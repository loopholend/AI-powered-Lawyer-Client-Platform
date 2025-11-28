<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }
    
    // Get client_id from database
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    int clientId = 0;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
            "root", "root"
        );
        
        String sql = "SELECT client_id FROM clients WHERE user_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            clientId = rs.getInt("client_id");
        }
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
    <style>
        body { 
            margin: 0; 
            padding: 20px; 
            background: #f9fafb; 
            font-family: 'Inter', sans-serif; 
        }
        
        .content-header {
            background: white;
            padding: 1.5rem 2rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .content-header h1 { 
            color: #1f2937; 
            font-size: 1.75rem; 
            margin: 0; 
        }
        
        .btn-add-case {
            background: #2563eb;
            color: white;
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-add-case:hover { 
            background: #1e40af; 
            transform: translateY(-2px); 
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            overflow-y: auto;
        }
        
        .modal.active { 
            display: flex; 
            align-items: center; 
            justify-content: center; 
        }
        
        .modal-content {
            background: white;
            border-radius: 12px;
            width: 90%;
            max-width: 700px;
            max-height: 90vh;
            overflow-y: auto;
            margin: 20px;
        }
        
        .modal-header {
            padding: 1.5rem 2rem;
            border-bottom: 2px solid #f9fafb;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .modal-header h2 { 
            color: #1f2937; 
            margin: 0; 
            font-size: 1.5rem; 
        }
        
        .close-btn {
            background: none;
            border: none;
            font-size: 1.5rem;
            color: #6b7280;
            cursor: pointer;
        }
        
        .close-btn:hover { 
            color: #1f2937; 
        }
        
        .modal-body { 
            padding: 2rem; 
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-group label {
            display: block;
            color: #1f2937;
            font-weight: 500;
            margin-bottom: 0.5rem;
            font-size: 0.95rem;
        }
        
        .required { 
            color: #ef4444; 
        }
        
        .form-control {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 0.95rem;
            font-family: 'Inter', sans-serif;
            transition: border-color 0.3s;
        }
        
        .form-control:focus { 
            outline: none; 
            border-color: #2563eb; 
        }
        
        textarea.form-control { 
            min-height: 120px; 
            resize: vertical; 
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }
        
        .file-upload {
            border: 2px dashed #e5e7eb;
            border-radius: 8px;
            padding: 2rem;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .file-upload:hover { 
            border-color: #2563eb; 
            background: #f9fafb; 
        }
        
        .file-upload.active { 
            border-color: #2563eb; 
            background: #eff6ff; 
        }
        
        .file-upload i { 
            font-size: 3rem; 
            color: #6b7280; 
            margin-bottom: 1rem; 
        }
        
        .file-upload p { 
            color: #6b7280; 
            margin: 0.5rem 0; 
        }
        
        .file-name {
            color: #2563eb;
            font-weight: 600;
            margin-top: 1rem;
            display: none;
        }
        
        .modal-footer {
            padding: 1.5rem 2rem;
            border-top: 2px solid #f9fafb;
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
        }
        
        .btn-cancel, .btn-submit {
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            border: none;
            font-size: 0.95rem;
            transition: all 0.3s;
        }
        
        .btn-cancel { 
            background: #f9fafb; 
            color: #1f2937; 
        }
        
        .btn-cancel:hover { 
            background: #e5e7eb; 
        }
        
        .btn-submit { 
            background: #2563eb; 
            color: white; 
        }
        
        .btn-submit:hover { 
            background: #1e40af; 
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
            border-left: 4px solid #2563eb;
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
        }
        
        .case-title { 
            font-size: 1.2rem; 
            font-weight: 700; 
            color: #1f2937; 
        }
        
        .case-status {
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 500;
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
        
        .case-meta {
            color: #6b7280;
            font-size: 0.9rem;
            line-height: 1.6;
            margin-bottom: 0.5rem;
        }
        
        .case-meta i { 
            color: #2563eb; 
            width: 18px; 
            margin-right: 0.5rem; 
        }
        
        /* Case Action Buttons */
        .case-actions {
            margin-top: 1rem;
            display: flex;
            gap: 0.5rem;
            border-top: 1px solid #e5e7eb;
            padding-top: 1rem;
        }
        
        .btn-complete, 
        .btn-cancel-case {
            flex: 1;
            padding: 0.65rem 1rem;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            font-size: 0.9rem;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            font-family: 'Inter', sans-serif;
        }
        
        .btn-complete {
            background: #10b981;
            color: white;
            box-shadow: 0 2px 4px rgba(16, 185, 129, 0.2);
        }
        
        .btn-complete:hover {
            background: #059669;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(16, 185, 129, 0.3);
        }
        
        .btn-cancel-case {
            background: #ef4444;
            color: white;
            box-shadow: 0 2px 4px rgba(239, 68, 68, 0.2);
        }
        
        .btn-cancel-case:hover {
            background: #dc2626;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(239, 68, 68, 0.3);
        }
        
        /* Status Badges */
        .case-completed-badge, 
        .case-cancelled-badge {
            margin-top: 1rem;
            padding: 0.75rem;
            border-radius: 8px;
            text-align: center;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
        }
        
        .case-completed-badge {
            background: #d1fae5;
            color: #065f46;
            border: 2px solid #a7f3d0;
        }
        
        .case-cancelled-badge {
            background: #fee2e2;
            color: #991b1b;
            border: 2px solid #fecaca;
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
        
        @media (max-width: 600px) {
            .form-row { 
                grid-template-columns: 1fr; 
            }
            
            .case-actions {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="content-header">
        <h1>My Cases</h1>
        <button class="btn-add-case" onclick="openModal()">
            <i class="fas fa-plus"></i> Add New Case
        </button>
    </div>

    <div id="casesGrid" class="cases-grid"></div>
    
    <div id="emptyState" class="empty-state">
        <i class="fas fa-folder-open"></i>
        <h3>No Cases Yet</h3>
        <p>Click "Add New Case" to submit your first case</p>
    </div>

    <!-- Modal -->
    <div id="caseModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Submit New Case</h2>
                <button class="close-btn" onclick="closeModal()">&times;</button>
            </div>
            
            <form id="caseForm" action="UploadCaseServlet" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="clientId" value="<%= clientId %>">
                
                <div class="modal-body">
                    <div class="form-group">
                        <label for="caseTitle">Case Title <span class="required">*</span></label>
                        <input type="text" id="caseTitle" name="caseTitle" class="form-control" 
                               placeholder="Brief title of your legal matter" required>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="caseType">Case Type <span class="required">*</span></label>
                            <select id="caseType" name="caseType" class="form-control" required>
                                <option value="">Select Case Type</option>
                                <option value="Criminal Law">Criminal Law</option>
                                <option value="Civil Law">Civil Law</option>
                                <option value="Family Law">Family Law</option>
                                <option value="Corporate Law">Corporate Law</option>
                                <option value="Property Law">Property Law</option>
                                <option value="Tax Law">Tax Law</option>
                                <option value="Labour Law">Labour Law</option>
                                <option value="Intellectual Property">Intellectual Property</option>
                                <option value="Consumer Law">Consumer Law</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="city">City <span class="required">*</span></label>
                            <input type="text" id="city" name="city" class="form-control" 
                                   placeholder="City where case needs to be filed" required>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="urgency">Urgency Level</label>
                            <select id="urgency" name="urgency" class="form-control">
                                <option value="Normal">Normal</option>
                                <option value="Urgent">Urgent</option>
                                <option value="Very Urgent">Very Urgent</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="budget">Budget Range</label>
                            <select id="budget" name="budget" class="form-control">
                                <option value="">Not decided</option>
                                <option value="Less than Rs.10,000">Less than Rs.10,000</option>
                                <option value="Rs.10,000 - Rs.50,000">Rs.10,000 - Rs.50,000</option>
                                <option value="Rs.50,000 - Rs.1,00,000">Rs.50,000 - Rs.1,00,000</option>
                                <option value="Above Rs.1,00,000">Above Rs.1,00,000</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="description">Case Description <span class="required">*</span></label>
                        <textarea id="description" name="description" class="form-control" 
                                  placeholder="Provide detailed description of your case..." required></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label>Upload Case Documents (Optional)</label>
                        <div class="file-upload" id="fileUpload" onclick="document.getElementById('caseDocument').click()">
                            <i class="fas fa-cloud-upload-alt"></i>
                            <p><strong>Click to upload</strong> or drag and drop</p>
                            <p style="font-size: 0.85rem;">PDF, DOC, DOCX (Max 5MB)</p>
                            <div class="file-name" id="fileName"></div>
                        </div>
                        <input type="file" id="caseDocument" name="caseDocument" 
                               accept=".pdf,.doc,.docx" style="display: none;" onchange="handleFileSelect()">
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal()">Cancel</button>
                    <button type="submit" class="btn-submit">Submit Case</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        window.onload = function() {
            loadCases();
            
            var urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('success') === 'true') {
                showMessage('Case submitted successfully!', 'success');
            } else if (urlParams.get('completed') === 'true') {
                showMessage('Case marked as completed!', 'success');
            } else if (urlParams.get('cancelled') === 'true') {
                showMessage('Case cancelled successfully!', 'success');
            } else if (urlParams.get('error') === 'true') {
                showMessage('An error occurred. Please try again.', 'error');
            }
        };

        function showMessage(text, type) {
            var messageDiv = document.createElement('div');
            var bgColor = type === 'success' ? '#10b981' : '#ef4444';
            messageDiv.style.cssText = 'position: fixed; top: 20px; right: 20px; background: ' + bgColor + '; color: white; padding: 1rem 1.5rem; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.2); z-index: 9999; animation: slideIn 0.3s ease;';
            messageDiv.innerHTML = '<i class="fas fa-check-circle"></i> ' + text;
            document.body.appendChild(messageDiv);
            
            setTimeout(function() {
                messageDiv.style.animation = 'slideOut 0.3s ease';
                setTimeout(function() {
                    if (document.body.contains(messageDiv)) {
                        document.body.removeChild(messageDiv);
                    }
                }, 300);
            }, 3000);
        }

        function openModal() {
            document.getElementById('caseModal').classList.add('active');
            document.body.style.overflow = 'hidden';
        }

        function closeModal() {
            document.getElementById('caseModal').classList.remove('active');
            document.body.style.overflow = 'auto';
            document.getElementById('caseForm').reset();
            document.getElementById('fileName').style.display = 'none';
            document.getElementById('fileUpload').classList.remove('active');
        }

        function handleFileSelect() {
            var fileInput = document.getElementById('caseDocument');
            var fileName = document.getElementById('fileName');
            var fileUpload = document.getElementById('fileUpload');
            
            if (fileInput.files.length > 0) {
                var file = fileInput.files[0];
                
                if (file.size > 5 * 1024 * 1024) {
                    alert('File size must be less than 5MB');
                    fileInput.value = '';
                    return;
                }
                
                fileName.textContent = file.name + ' (' + (file.size / 1024).toFixed(2) + ' KB)';
                fileName.style.display = 'block';
                fileUpload.classList.add('active');
            }
        }

        function loadCases() {
            console.log('Loading cases...');
            
            fetch('GetClientCasesServlet')
                .then(function(response) {
                    return response.json();
                })
                .then(function(data) {
                    console.log('Cases loaded:', data.length);
                    
                    var grid = document.getElementById('casesGrid');
                    var emptyState = document.getElementById('emptyState');
                    
                    if (data.length === 0) {
                        grid.style.display = 'none';
                        emptyState.style.display = 'block';
                        return;
                    }
                    
                    grid.style.display = 'grid';
                    emptyState.style.display = 'none';
                    grid.innerHTML = '';
                    
                    data.forEach(function(c) {
                        var card = document.createElement('div');
                        card.className = 'case-card';
                        
                        var statusClass = 'status-' + c.status;
                        var statusText = c.status.charAt(0).toUpperCase() + c.status.slice(1);
                        
                        var actionButtons = '';
                        
                        if (c.status === 'pending' || c.status === 'active') {
                            actionButtons = 
                                '<div class="case-actions">' +
                                    '<button class="btn-complete" onclick="completeCase(' + c.caseId + ')">' +
                                        '<i class="fas fa-check"></i> Mark Completed' +
                                    '</button>' +
                                    '<button class="btn-cancel-case" onclick="cancelCase(' + c.caseId + ')">' +
                                        '<i class="fas fa-times"></i> Cancel' +
                                    '</button>' +
                                '</div>';
                        } else if (c.status === 'completed') {
                            actionButtons = 
                                '<div class="case-completed-badge">' +
                                    '<i class="fas fa-check-circle"></i> Case Completed' +
                                '</div>';
                        } else if (c.status === 'cancelled') {
                            actionButtons = 
                                '<div class="case-cancelled-badge">' +
                                    '<i class="fas fa-ban"></i> Case Cancelled' +
                                '</div>';
                        }
                        
                        card.innerHTML =
                            '<div class="case-header">' +
                                '<div class="case-title">' + escapeHtml(c.title) + '</div>' +
                                '<div class="case-status ' + statusClass + '">' + statusText + '</div>' +
                            '</div>' +
                            '<div class="case-meta"><i class="fas fa-gavel"></i>' + escapeHtml(c.type) + '</div>' +
                            '<div class="case-meta"><i class="fas fa-map-marker-alt"></i>' + escapeHtml(c.city) + '</div>' +
                            '<div class="case-meta"><i class="fas fa-clock"></i>Urgency: ' + (c.urgency || 'Normal') + '</div>' +
                            '<div class="case-meta"><i class="fas fa-calendar"></i>Submitted: ' + c.createdAt + '</div>' +
                            actionButtons;
                        
                        grid.appendChild(card);
                    });
                })
                .catch(function(error) {
                    console.error('Error loading cases:', error);
                    document.getElementById('emptyState').style.display = 'block';
                });
        }

        function escapeHtml(text) {
            var div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        function completeCase(caseId) {
            if (confirm('Mark this case as completed?')) {
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = 'CompleteCaseServlet';
                
                var input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'caseId';
                input.value = caseId;
                form.appendChild(input);
                
                document.body.appendChild(form);
                form.submit();
            }
        }

        function cancelCase(caseId) {
            if (confirm('Are you sure you want to cancel this case? This action cannot be undone.')) {
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = 'CancelCaseServlet';
                
                var input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'caseId';
                input.value = caseId;
                form.appendChild(input);
                
                document.body.appendChild(form);
                form.submit();
            }
        }

        var style = document.createElement('style');
        style.textContent = '@keyframes slideIn { from { transform: translateX(400px); opacity: 0; } to { transform: translateX(0); opacity: 1; } } @keyframes slideOut { from { transform: translateX(0); opacity: 1; } to { transform: translateX(400px); opacity: 0; } }';
        document.head.appendChild(style);
    </script>
</body>
</html>

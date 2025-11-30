<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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
        
        .content-header {
            background: white;
            padding: 1.5rem 2rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        .content-header h1 { 
            color: #1f2937; 
            font-size: 1.75rem; 
            margin: 0 0 0.5rem 0; 
        }
        
        .content-header p {
            color: #6b7280;
            margin: 0;
        }
        
        .requests-container {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }
        
        .case-group {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        .case-group-header {
            padding-bottom: 1rem;
            border-bottom: 2px solid #f9fafb;
            margin-bottom: 1rem;
        }
        
        .case-title {
            font-size: 1.3rem;
            font-weight: 700;
            color: #1f2937;
            margin-bottom: 0.5rem;
        }
        
        .case-meta {
            color: #6b7280;
            font-size: 0.9rem;
            display: flex;
            gap: 1.5rem;
            flex-wrap: wrap;
        }
        
        .case-meta span {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .case-meta i {
            color: #2563eb;
        }
        
        .lawyer-requests-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 1rem;
        }
        
        .lawyer-card {
            background: #f9fafb;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            padding: 1.5rem;
            transition: all 0.3s;
        }
        
        .lawyer-card:hover {
            border-color: #2563eb;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        
        .lawyer-header {
            display: flex;
            align-items: start;
            gap: 1rem;
            margin-bottom: 1rem;
        }
        
        .lawyer-avatar {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            font-weight: 700;
            flex-shrink: 0;
        }
        
        .lawyer-info {
            flex: 1;
        }
        
        .lawyer-name {
            font-size: 1.1rem;
            font-weight: 700;
            color: #1f2937;
            margin-bottom: 0.25rem;
        }
        
        .lawyer-specialization {
            color: #6b7280;
            font-size: 0.9rem;
        }
        
        .lawyer-rating {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-top: 0.5rem;
        }
        
        .stars {
            color: #fbbf24;
        }
        
        .rating-count {
            color: #6b7280;
            font-size: 0.85rem;
        }
        
        .lawyer-details {
            display: flex;
            gap: 1.5rem;
            margin: 1rem 0;
            padding: 1rem;
            background: white;
            border-radius: 8px;
        }
        
        .detail-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #6b7280;
            font-size: 0.9rem;
        }
        
        .detail-item i {
            color: #2563eb;
        }
        
        .lawyer-message {
            background: white;
            padding: 1rem;
            border-radius: 8px;
            margin: 1rem 0;
            border-left: 4px solid #2563eb;
        }
        
        .message-label {
            font-size: 0.85rem;
            color: #6b7280;
            margin-bottom: 0.5rem;
        }
        
        .message-text {
            color: #1f2937;
            line-height: 1.6;
        }
        
        .proposed-fee {
            background: #dcfce7;
            color: #166534;
            padding: 0.75rem 1rem;
            border-radius: 8px;
            font-weight: 700;
            text-align: center;
            margin: 1rem 0;
        }
        
        .lawyer-actions {
            display: flex;
            gap: 0.5rem;
            margin-top: 1rem;
        }
        
        .btn-accept, .btn-reject {
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
        }
        
        .btn-accept {
            background: #10b981;
            color: white;
        }
        
        .btn-accept:hover {
            background: #059669;
            transform: translateY(-2px);
        }
        
        .btn-reject {
            background: #ef4444;
            color: white;
        }
        
        .btn-reject:hover {
            background: #dc2626;
            transform: translateY(-2px);
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
    </style>
</head>
<body>
    <div class="content-header">
        <h1><i class="fas fa-envelope-open-text"></i> Lawyer Requests</h1>
        <p>Review and accept requests from lawyers interested in your cases</p>
    </div>

    <div id="requestsContainer" class="requests-container"></div>
    
    <div id="emptyState" class="empty-state" style="display:none;">
        <i class="fas fa-inbox"></i>
        <h3>No Lawyer Requests</h3>
        <p>When lawyers express interest in your cases, they will appear here</p>
    </div>

    <script>
        window.onload = function() {
            loadAllRequests();
            
            var urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('lawyerAssigned') === 'true') {
                showMessage('Lawyer assigned successfully!', 'success');
            } else if (urlParams.get('rejected') === 'true') {
                showMessage('Request declined', 'success');
            } else if (urlParams.get('error') === 'true') {
                showMessage('An error occurred', 'error');
            }
        };

        function loadAllRequests() {
            fetch('GetAllCaseRequestsServlet')
                .then(function(response) {
                    return response.json();
                })
                .then(function(data) {
                    console.log('Requests loaded:', data);
                    
                    var container = document.getElementById('requestsContainer');
                    var emptyState = document.getElementById('emptyState');
                    
                    if (data.length === 0) {
                        container.style.display = 'none';
                        emptyState.style.display = 'block';
                        return;
                    }
                    
                    container.style.display = 'flex';
                    emptyState.style.display = 'none';
                    container.innerHTML = '';
                    
                    // Group requests by case
                    var groupedRequests = {};
                    data.forEach(function(req) {
                        if (!groupedRequests[req.caseId]) {
                            groupedRequests[req.caseId] = {
                                caseInfo: req,
                                lawyers: []
                            };
                        }
                        groupedRequests[req.caseId].lawyers.push(req);
                    });
                    
                    // Render each case group
                    Object.values(groupedRequests).forEach(function(group) {
                        var caseGroup = document.createElement('div');
                        caseGroup.className = 'case-group';
                        
                        var header = 
                            '<div class="case-group-header">' +
                                '<div class="case-title">' + escapeHtml(group.caseInfo.caseTitle) + '</div>' +
                                '<div class="case-meta">' +
                                    '<span><i class="fas fa-gavel"></i>' + escapeHtml(group.caseInfo.caseType) + '</span>' +
                                    '<span><i class="fas fa-map-marker-alt"></i>' + escapeHtml(group.caseInfo.city) + '</span>' +
                                    '<span><i class="fas fa-users"></i>' + group.lawyers.length + ' Request' + (group.lawyers.length > 1 ? 's' : '') + '</span>' +
                                '</div>' +
                            '</div>';
                        
                        var lawyersGrid = document.createElement('div');
                        lawyersGrid.className = 'lawyer-requests-grid';
                        
                        group.lawyers.forEach(function(lawyer) {
                            var lawyerCard = createLawyerCard(lawyer);
                            lawyersGrid.appendChild(lawyerCard);
                        });
                        
                        caseGroup.innerHTML = header;
                        caseGroup.appendChild(lawyersGrid);
                        container.appendChild(caseGroup);
                    });
                })
                .catch(function(error) {
                    console.error('Error loading requests:', error);
                    document.getElementById('emptyState').style.display = 'block';
                });
        }

        function createLawyerCard(lawyer) {
            var card = document.createElement('div');
            card.className = 'lawyer-card';
            
            var initials = lawyer.lawyerName.split(' ').map(function(n) { return n[0]; }).join('');
            var stars = getStarRating(lawyer.rating);
            
            var messageHtml = '';
            if (lawyer.message) {
                messageHtml = 
                    '<div class="lawyer-message">' +
                        '<div class="message-label">Message from lawyer:</div>' +
                        '<div class="message-text">' + escapeHtml(lawyer.message) + '</div>' +
                    '</div>';
            }
            
            var feeHtml = '';
            if (lawyer.proposedFee) {
                feeHtml = 
                    '<div class="proposed-fee">' +
                        '<i class="fas fa-rupee-sign"></i> Proposed Fee: Rs. ' + lawyer.proposedFee.toLocaleString() +
                    '</div>';
            }
            
            card.innerHTML = 
                '<div class="lawyer-header">' +
                    '<div class="lawyer-avatar">' + initials + '</div>' +
                    '<div class="lawyer-info">' +
                        '<div class="lawyer-name">' + escapeHtml(lawyer.lawyerName) + '</div>' +
                        '<div class="lawyer-specialization">' + escapeHtml(lawyer.specialization) + '</div>' +
                        '<div class="lawyer-rating">' +
                            '<div class="stars">' + stars + '</div>' +
                            '<span class="rating-count">' + lawyer.rating.toFixed(1) + ' (' + lawyer.totalRatings + ' reviews)</span>' +
                        '</div>' +
                    '</div>' +
                '</div>' +
                
                '<div class="lawyer-details">' +
                    '<div class="detail-item">' +
                        '<i class="fas fa-briefcase"></i>' +
                        lawyer.experience + ' years' +
                    '</div>' +
                    '<div class="detail-item">' +
                        '<i class="fas fa-clock"></i>' +
                        lawyer.requestDate +
                    '</div>' +
                '</div>' +
                
                messageHtml +
                feeHtml +
                
                '<div class="lawyer-actions">' +
                    '<button class="btn-accept" onclick="acceptLawyer(' + lawyer.requestId + ', ' + lawyer.caseId + ')">' +
                        '<i class="fas fa-check"></i> Accept' +
                    '</button>' +
                    '<button class="btn-reject" onclick="rejectLawyer(' + lawyer.requestId + ')">' +
                        '<i class="fas fa-times"></i> Decline' +
                    '</button>' +
                '</div>';
            
            return card;
        }

        function getStarRating(rating) {
            var fullStars = Math.floor(rating);
            var halfStar = rating % 1 >= 0.5;
            var emptyStars = 5 - fullStars - (halfStar ? 1 : 0);
            
            var stars = '';
            for (var i = 0; i < fullStars; i++) stars += '<i class="fas fa-star"></i>';
            if (halfStar) stars += '<i class="fas fa-star-half-alt"></i>';
            for (var i = 0; i < emptyStars; i++) stars += '<i class="far fa-star"></i>';
            
            return stars;
        }

        function acceptLawyer(requestId, caseId) {
            if (confirm('Accept this lawyer for your case? Other requests will be declined.')) {
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = 'AcceptLawyerRequestServlet';
                
                var reqInput = document.createElement('input');
                reqInput.type = 'hidden';
                reqInput.name = 'requestId';
                reqInput.value = requestId;
                form.appendChild(reqInput);
                
                var caseInput = document.createElement('input');
                caseInput.type = 'hidden';
                caseInput.name = 'caseId';
                caseInput.value = caseId;
                form.appendChild(caseInput);
                
                document.body.appendChild(form);
                form.submit();
            }
        }

        function rejectLawyer(requestId) {
            if (confirm('Decline this lawyer request?')) {
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = 'RejectLawyerRequestServlet';
                
                var input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'requestId';
                input.value = requestId;
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

        function showMessage(text, type) {
            var messageDiv = document.createElement('div');
            var bgColor = type === 'success' ? '#10b981' : '#ef4444';
            messageDiv.style.cssText = 'position: fixed; top: 20px; right: 20px; background: ' + bgColor + '; color: white; padding: 1rem 1.5rem; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.2); z-index: 9999;';
            messageDiv.innerHTML = '<i class="fas fa-check-circle"></i> ' + text;
            document.body.appendChild(messageDiv);
            
            setTimeout(function() {
                messageDiv.style.opacity = '0';
                messageDiv.style.transition = 'opacity 0.3s';
                setTimeout(function() {
                    document.body.removeChild(messageDiv);
                }, 300);
            }, 3000);
        }
    </script>
</body>
</html>

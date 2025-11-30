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
        
        .lawyers-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 1.5rem;
        }
        
        .lawyer-card {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            border-left: 4px solid #f59e0b;
            transition: all 0.3s;
        }
        
        .lawyer-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        
        .lawyer-header {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid #f9fafb;
        }
        
        .lawyer-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 1.5rem;
        }
        
        .lawyer-info {
            flex: 1;
        }
        
        .lawyer-name {
            font-size: 1.2rem;
            font-weight: 700;
            color: #1f2937;
            margin-bottom: 0.25rem;
        }
        
        .lawyer-email {
            color: #6b7280;
            font-size: 0.9rem;
        }
        
        .lawyer-details {
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
            color: #f59e0b;
            width: 20px;
        }
        
        .detail-row strong {
            color: #1f2937;
        }
        
        .lawyer-actions {
            display: flex;
            gap: 0.75rem;
            margin-top: 1rem;
        }
        
        .btn-approve {
            flex: 1;
            padding: 0.75rem;
            background: #10b981;
            color: white;
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
        
        .btn-approve:hover {
            background: #059669;
            transform: translateY(-2px);
        }
        
        .btn-reject {
            flex: 1;
            padding: 0.75rem;
            background: #ef4444;
            color: white;
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
    <div class="page-header">
        <h1><i class="fas fa-user-check"></i> Verify Lawyers</h1>
        <p>Review and approve lawyer registration requests</p>
    </div>

    <div id="lawyersGrid" class="lawyers-grid"></div>
    
    <div id="emptyState" class="empty-state" style="display: none;">
        <i class="fas fa-user-check"></i>
        <h3>No Pending Verifications</h3>
        <p>All lawyer registrations have been processed!</p>
    </div>

    <script>
        window.onload = function() {
            loadPendingLawyers();
            
            var urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('approved') === 'true') {
                showMessage('Lawyer approved successfully!', 'success');
            } else if (urlParams.get('rejected') === 'true') {
                showMessage('Lawyer rejected successfully!', 'success');
            }
        };

        function loadPendingLawyers() {
            fetch('GetPendingLawyersServlet')
                .then(function(response) {
                    return response.json();
                })
                .then(function(data) {
                    var grid = document.getElementById('lawyersGrid');
                    var emptyState = document.getElementById('emptyState');
                    
                    if (data.length === 0) {
                        grid.style.display = 'none';
                        emptyState.style.display = 'block';
                        return;
                    }
                    
                    grid.style.display = 'grid';
                    emptyState.style.display = 'none';
                    grid.innerHTML = '';
                    
                    data.forEach(function(lawyer) {
                        var card = document.createElement('div');
                        card.className = 'lawyer-card';
                        
                        var initials = lawyer.firstName.charAt(0) + lawyer.lastName.charAt(0);
                        
                        card.innerHTML =
                            '<div class="lawyer-header">' +
                                '<div class="lawyer-avatar">' + initials + '</div>' +
                                '<div class="lawyer-info">' +
                                    '<div class="lawyer-name">' + escapeHtml(lawyer.firstName) + ' ' + escapeHtml(lawyer.lastName) + '</div>' +
                                    '<div class="lawyer-email">' + escapeHtml(lawyer.email) + '</div>' +
                                '</div>' +
                            '</div>' +
                            '<div class="lawyer-details">' +
                                '<div class="detail-row">' +
                                    '<i class="fas fa-id-card"></i>' +
                                    '<span><strong>Bar Number:</strong> ' + escapeHtml(lawyer.barNumber) + '</span>' +
                                '</div>' +
                                '<div class="detail-row">' +
                                    '<i class="fas fa-map-marker-alt"></i>' +
                                    '<span><strong>State:</strong> ' + escapeHtml(lawyer.stateLicensed) + '</span>' +
                                '</div>' +
                                '<div class="detail-row">' +
                                    '<i class="fas fa-briefcase"></i>' +
                                    '<span><strong>Experience:</strong> ' + escapeHtml(lawyer.yearsExperience) + '</span>' +
                                '</div>' +
                                '<div class="detail-row">' +
                                    '<i class="fas fa-gavel"></i>' +
                                    '<span><strong>Specialization:</strong> ' + escapeHtml(lawyer.specialization) + '</span>' +
                                '</div>' +
                                '<div class="detail-row">' +
                                    '<i class="fas fa-city"></i>' +
                                    '<span><strong>Practice City:</strong> ' + escapeHtml(lawyer.cityPractice) + '</span>' +
                                '</div>' +
                                '<div class="detail-row">' +
                                    '<i class="fas fa-dollar-sign"></i>' +
                                    '<span><strong>Rate:</strong> ' + escapeHtml(lawyer.hourlyRate) + '</span>' +
                                '</div>' +
                                '<div class="detail-row">' +
                                    '<i class="fas fa-phone"></i>' +
                                    '<span><strong>Phone:</strong> ' + escapeHtml(lawyer.phone) + '</span>' +
                                '</div>' +
                            '</div>' +
                            '<div class="lawyer-actions">' +
                                '<button class="btn-approve" onclick="approveLawyer(' + lawyer.lawyerId + ')">' +
                                    '<i class="fas fa-check"></i> Approve' +
                                '</button>' +
                                '<button class="btn-reject" onclick="rejectLawyer(' + lawyer.lawyerId + ')">' +
                                    '<i class="fas fa-times"></i> Reject' +
                                '</button>' +
                            '</div>';
                        
                        grid.appendChild(card);
                    });
                })
                .catch(function(error) {
                    console.error('Error loading lawyers:', error);
                    document.getElementById('emptyState').style.display = 'block';
                });
        }

        function approveLawyer(lawyerId) {
            if (confirm('Are you sure you want to approve this lawyer?')) {
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = 'ApproveLawyerServlet';
                
                var input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'lawyerId';
                input.value = lawyerId;
                form.appendChild(input);
                
                document.body.appendChild(form);
                form.submit();
            }
        }

        function rejectLawyer(lawyerId) {
            if (confirm('Are you sure you want to reject this lawyer? This action cannot be undone.')) {
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = 'RejectLawyerServlet';
                
                var input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'lawyerId';
                input.value = lawyerId;
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
                    if (document.body.contains(messageDiv)) {
                        document.body.removeChild(messageDiv);
                    }
                }, 300);
            }, 3000);
        }
    </script>
</body>
</html>

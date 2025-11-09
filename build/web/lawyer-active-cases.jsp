<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="styles.css">
    <style>
        body { margin: 0; padding: 20px; background: #f9fafb; font-family: 'Inter', sans-serif; }
        .content-header {
            background: white;
            padding: 1.5rem 2rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        .content-header h1 { color: #1f2937; font-size: 1.75rem; margin-bottom: 0.5rem; }
        .content-header p { color: #6b7280; }
        
        .cases-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
            gap: 1.5rem;
        }
        
        .case-card {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            border-left: 4px solid #10b981;
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
            margin-bottom: 0.5rem;
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
            background: #dcfce7;
            color: #166534;
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
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            font-weight: 700;
        }
        
        .client-name {
            font-weight: 600;
            color: #1f2937;
            margin-bottom: 0.25rem;
        }
        
        .client-contact {
            font-size: 0.85rem;
            color: #6b7280;
        }
        
        .detail-row {
            display: flex;
            gap: 0.75rem;
            padding: 0.5rem 0;
            color: #6b7280;
            font-size: 0.9rem;
        }
        
        .detail-row i {
            color: #10b981;
            width: 20px;
        }
        
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            background: white;
            border-radius: 12px;
        }
        .empty-state i { font-size: 4rem; color: #e5e7eb; margin-bottom: 1rem; }
        .empty-state h3 { color: #1f2937; margin-bottom: 0.5rem; }
        .empty-state p { color: #6b7280; }
    </style>
</head>
<body>
    <div class="content-header">
        <h1>Active Cases</h1>
        <p>Manage your ongoing client cases</p>
    </div>

    <div id="loadingState" style="display: none; text-align: center; padding: 3rem;">
        <i class="fas fa-spinner fa-spin" style="font-size: 3rem; color: #10b981;"></i>
        <p style="margin-top: 1rem; color: #6b7280;">Loading active cases...</p>
    </div>

    <div id="casesGrid" class="cases-grid"></div>

    <div id="emptyState" class="empty-state" style="display: none;">
        <i class="fas fa-briefcase"></i>
        <h3>No Active Cases</h3>
        <p>You don't have any active cases at the moment.</p>
        <p style="margin-top: 1rem;">Accepted cases will appear here.</p>
    </div>

    <script>
        window.onload = function() {
            loadActiveCases();
        };

        function loadActiveCases() {
            document.getElementById('loadingState').style.display = 'block';
            
            fetch('GetActiveCasesServlet')
                .then(function(response) { return response.json(); })
                .then(function(data) {
                    document.getElementById('loadingState').style.display = 'none';
                    
                    if (data.length === 0) {
                        document.getElementById('emptyState').style.display = 'block';
                        return;
                    }
                    
                    displayCases(data);
                    document.getElementById('casesGrid').style.display = 'grid';
                })
                .catch(function(error) {
                    console.error('Error:', error);
                    document.getElementById('loadingState').style.display = 'none';
                    document.getElementById('emptyState').style.display = 'block';
                });
        }

        function displayCases(cases) {
            var grid = document.getElementById('casesGrid');
            grid.innerHTML = '';

            cases.forEach(function(c) {
                var card = document.createElement('div');
                card.className = 'case-card';
                
                var initials = c.clientFirstName.charAt(0) + c.clientLastName.charAt(0);
                
                card.innerHTML =
                    '<div class="case-header">' +
                        '<div>' +
                            '<div class="case-title">' + c.title + '</div>' +
                            '<div class="case-id">Case ID: #' + c.caseId + '</div>' +
                        '</div>' +
                        '<div class="status-badge">Active</div>' +
                    '</div>' +
                    '<div class="client-info">' +
                        '<div class="client-avatar">' + initials + '</div>' +
                        '<div>' +
                            '<div class="client-name">' + c.clientFirstName + ' ' + c.clientLastName + '</div>' +
                            '<div class="client-contact">' + c.clientEmail + ' | ' + c.clientPhone + '</div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="detail-row"><i class="fas fa-gavel"></i><span>' + c.type + '</span></div>' +
                    '<div class="detail-row"><i class="fas fa-map-marker-alt"></i><span>' + c.city + '</span></div>' +
                    '<div class="detail-row"><i class="fas fa-money-bill-wave"></i><span>' + (c.budget || 'Not specified') + '</span></div>';
                
                grid.appendChild(card);
            });
        }
    </script>
</body>
</html>

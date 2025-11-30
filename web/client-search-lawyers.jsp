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
            padding: 1.5rem 2rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        .filters-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1rem;
        }
        
        .filter-group label {
            display: block;
            color: #1f2937;
            font-weight: 600;
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
        }
        
        .filter-input {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 0.95rem;
            font-family: 'Inter', sans-serif;
            box-sizing: border-box;
        }
        
        .filter-input:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .btn-search {
            width: 100%;
            padding: 0.75rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 1.5rem;
            font-size: 1rem;
            transition: all 0.3s;
        }
        
        .btn-search:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
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
            border-left: 4px solid #667eea;
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 1.5rem;
            flex-shrink: 0;
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
        
        .lawyer-specialization {
            color: #667eea;
            font-size: 0.9rem;
            font-weight: 600;
        }
        
        .rating-section {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-top: 0.5rem;
        }
        
        .rating-stars {
            color: #fbbf24;
            font-size: 0.9rem;
        }
        
        .rating-text {
            color: #6b7280;
            font-size: 0.85rem;
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
            color: #667eea;
            width: 20px;
        }
        
        .btn-view-profile {
            width: 100%;
            padding: 0.75rem;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-view-profile:hover {
            background: #764ba2;
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
        <h1><i class="fas fa-search"></i> Search Lawyers</h1>
        <p>Find the perfect lawyer for your legal needs</p>
    </div>
    
    <div class="filters-section">
        <div class="filters-grid">
            <div class="filter-group">
                <label>Specialization</label>
                <select id="specialization" class="filter-input">
                    <option value="">All Specializations</option>
                    <option value="Criminal Law">Criminal Law</option>
                    <option value="Civil Law">Civil Law</option>
                    <option value="Family Law">Family Law</option>
                    <option value="Corporate Law">Corporate Law</option>
                    <option value="Property Law">Property Law</option>
                    <option value="Tax Law">Tax Law</option>
                    <option value="Labour Law">Labour Law</option>
                    <option value="Consumer Law">Consumer Law</option>
                    <option value="Intellectual Property">Intellectual Property</option>
                </select>
            </div>
            
            <div class="filter-group">
                <label>City</label>
                <input type="text" id="city" class="filter-input" placeholder="Enter city">
            </div>
            
            <div class="filter-group">
                <label>Experience</label>
                <select id="experience" class="filter-input">
                    <option value="">Any Experience</option>
                    <option value="0-2 years">0-2 years</option>
                    <option value="3-5 years">3-5 years</option>
                    <option value="5-10 years">5-10 years</option>
                    <option value="10+ years">10+ years</option>
                </select>
            </div>
        </div>
        
        <button class="btn-search" onclick="searchLawyers()">
            <i class="fas fa-search"></i> Search Lawyers
        </button>
    </div>
    
    <div id="lawyersGrid" class="lawyers-grid"></div>
    
    <div id="emptyState" class="empty-state" style="display: none;">
        <i class="fas fa-user-tie"></i>
        <h3>No Lawyers Found</h3>
        <p>Try adjusting your search filters</p>
    </div>

    <script>
        window.onload = function() {
            searchLawyers();
        };

        function searchLawyers() {
            var specialization = document.getElementById('specialization').value;
            var city = document.getElementById('city').value;
            var experience = document.getElementById('experience').value;
            
            var url = 'SearchLawyersServlet?specialization=' + encodeURIComponent(specialization) + 
                      '&city=' + encodeURIComponent(city) + 
                      '&experience=' + encodeURIComponent(experience);
            
            fetch(url)
                .then(function(response) {
                    return response.json();
                })
                .then(function(data) {
                    displayLawyers(data);
                })
                .catch(function(error) {
                    console.error('Error:', error);
                    document.getElementById('emptyState').style.display = 'block';
                });
        }

        function displayLawyers(lawyers) {
            var grid = document.getElementById('lawyersGrid');
            var emptyState = document.getElementById('emptyState');
            
            if (lawyers.length === 0) {
                grid.style.display = 'none';
                emptyState.style.display = 'block';
                return;
            }
            
            grid.style.display = 'grid';
            emptyState.style.display = 'none';
            grid.innerHTML = '';
            
            lawyers.forEach(function(lawyer) {
                var card = document.createElement('div');
                card.className = 'lawyer-card';
                
                var initials = lawyer.firstName.charAt(0) + lawyer.lastName.charAt(0);
                var rating = lawyer.averageRating || 0;
                var totalRatings = lawyer.totalRatings || 0;
                
                // Generate star ratings
                var stars = '';
                for (var i = 1; i <= 5; i++) {
                    if (i <= Math.floor(rating)) {
                        stars += '<i class="fas fa-star"></i>';
                    } else if (i === Math.ceil(rating) && rating % 1 !== 0) {
                        stars += '<i class="fas fa-star-half-alt"></i>';
                    } else {
                        stars += '<i class="far fa-star"></i>';
                    }
                }
                
                // Handle missing/empty data
                var cityState = lawyer.cityPractice && lawyer.stateLicensed ? 
                    escapeHtml(lawyer.cityPractice) + ', ' + escapeHtml(lawyer.stateLicensed) : 
                    (lawyer.cityPractice ? escapeHtml(lawyer.cityPractice) : 'Location not specified');
                
                var experience = lawyer.yearsExperience || 'Not specified';
                var hourlyRate = lawyer.hourlyRate || 'Not specified';
                var barNumber = lawyer.barNumber || 'Not specified';
                
                card.innerHTML =
                    '<div class="lawyer-header">' +
                        '<div class="lawyer-avatar">' + initials + '</div>' +
                        '<div class="lawyer-info">' +
                            '<div class="lawyer-name">' + escapeHtml(lawyer.firstName) + ' ' + escapeHtml(lawyer.lastName) + '</div>' +
                            '<div class="lawyer-specialization">' + escapeHtml(lawyer.specialization) + '</div>' +
                            '<div class="rating-section">' +
                                '<span class="rating-stars">' + stars + '</span>' +
                                '<span class="rating-text">' + rating.toFixed(1) + ' (' + totalRatings + ' reviews)</span>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="lawyer-details">' +
                        '<div class="detail-row">' +
                            '<i class="fas fa-map-marker-alt"></i>' +
                            '<span>' + cityState + '</span>' +
                        '</div>' +
                        '<div class="detail-row">' +
                            '<i class="fas fa-briefcase"></i>' +
                            '<span>' + escapeHtml(experience) + '</span>' +
                        '</div>' +
                        '<div class="detail-row">' +
                            '<i class="fas fa-dollar-sign"></i>' +
                            '<span>' + escapeHtml(hourlyRate) + '</span>' +
                        '</div>' +
                        '<div class="detail-row">' +
                            '<i class="fas fa-id-card"></i>' +
                            '<span>Bar #: ' + escapeHtml(barNumber) + '</span>' +
                        '</div>' +
                    '</div>' +
                    '<button class="btn-view-profile" onclick="viewProfile(' + lawyer.lawyerId + ')">' +
                        '<i class="fas fa-eye"></i> View Profile' +
                    '</button>';
                
                grid.appendChild(card);
            });
        }

        function viewProfile(lawyerId) {
            window.location.href = 'client-lawyer-profile.jsp?lawyerId=' + lawyerId;
        }

        function escapeHtml(text) {
            if (!text) return '';
            var div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
    </script>
</body>
</html>

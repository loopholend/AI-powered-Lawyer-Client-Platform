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
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        .stat-card {
            background: white;
            padding: 1.5rem;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            text-align: center;
            position: relative;
            overflow: hidden;
            transition: transform 0.3s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
        }
        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .stat-icon {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
            font-size: 1.5rem;
        }
        .stat-value { 
            font-size: 2rem; 
            font-weight: 700; 
            color: #1f2937; 
            margin-bottom: 0.5rem;
            min-height: 48px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .stat-label { color: #6b7280; font-size: 0.9rem; }
        
        .stat-loading {
            display: inline-block;
            width: 30px;
            height: 30px;
            border: 3px solid #f3f4f6;
            border-top: 3px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .card {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            margin-bottom: 1.5rem;
        }
        .card h3 { color: #1f2937; margin-bottom: 1rem; }
        .card p { color: #6b7280; line-height: 1.6; }
        
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-top: 1.5rem;
        }
        .action-btn {
            padding: 1rem;
            background: #f9fafb;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            color: #1f2937;
            font-weight: 600;
        }
        .action-btn:hover {
            background: #2563eb;
            color: white;
            border-color: #2563eb;
            transform: translateY(-2px);
        }
        .action-btn i {
            display: block;
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }
    </style>
</head>
<body>
    <div class="content-header">
        <h1>Welcome, <%= session.getAttribute("firstName") %>!</h1>
        <p>Manage your legal cases and connect with expert lawyers</p>
    </div>

    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-folder"></i></div>
            <div class="stat-value" id="activeCases">
                <div class="stat-loading"></div>
            </div>
            <div class="stat-label">Active Cases</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-gavel"></i></div>
            <div class="stat-value" id="completedCases">
                <div class="stat-loading"></div>
            </div>
            <div class="stat-label">Completed Cases</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-user-tie"></i></div>
            <div class="stat-value" id="lawyersConnected">
                <div class="stat-loading"></div>
            </div>
            <div class="stat-label">Lawyers Connected</div>
        </div>
    </div>

    <div class="card">
        <h3>Quick Actions</h3>
        <div class="quick-actions">
            <a href="#" onclick="parent.document.querySelectorAll('.nav-item')[1].click(); return false;" class="action-btn">
                <i class="fas fa-search"></i>
                Search Lawyers
            </a>
            <a href="#" onclick="parent.document.querySelectorAll('.nav-item')[2].click(); return false;" class="action-btn">
                <i class="fas fa-upload"></i>
                Upload Case
            </a>
            <a href="#" onclick="parent.document.querySelectorAll('.nav-item')[4].click(); return false;" class="action-btn">
                <i class="fas fa-robot"></i>
                AI Assistant
            </a>
        </div>
    </div>

    <div class="card">
        <h3>How LegalConnect Works</h3>
        <p><strong>1. Search & Connect:</strong> Find qualified lawyers by specialization, location, and experience. Review their profiles and ratings.</p>
        <p style="margin-top: 1rem;"><strong>2. Submit Your Case:</strong> Upload your legal case details with relevant documents. Lawyers will review and accept cases that match their expertise.</p>
        <p style="margin-top: 1rem;"><strong>3. Get Legal Help:</strong> Once a lawyer accepts your case, you'll be connected directly. Track case progress from your dashboard.</p>
        <p style="margin-top: 1rem;"><strong>4. AI Support:</strong> Use our AI assistant for instant legal guidance, understanding your rights, and getting answers to common legal questions.</p>
    </div>

    <script>
        window.onload = function() {
            loadStats();
        };

        function loadStats() {
            fetch('GetClientStatsServlet')
                .then(function(response) {
                    return response.json();
                })
                .then(function(data) {
                    console.log('Client stats loaded:', data);
                    
                    // Animate numbers
                    animateNumber('activeCases', 0, data.activeCases, 1000);
                    animateNumber('completedCases', 0, data.completedCases, 1000);
                    animateNumber('lawyersConnected', 0, data.lawyersConnected, 1000);
                })
                .catch(function(error) {
                    console.error('Error loading stats:', error);
                    document.getElementById('activeCases').innerHTML = '0';
                    document.getElementById('completedCases').innerHTML = '0';
                    document.getElementById('lawyersConnected').innerHTML = '0';
                });
        }

        function animateNumber(elementId, start, end, duration) {
            var element = document.getElementById(elementId);
            var range = end - start;
            var increment = range / (duration / 16);
            var current = start;
            
            var timer = setInterval(function() {
                current += increment;
                if ((increment > 0 && current >= end) || (increment < 0 && current <= end)) {
                    current = end;
                    clearInterval(timer);
                }
                element.innerHTML = Math.round(current);
            }, 16);
        }
    </script>
</body>
</html>

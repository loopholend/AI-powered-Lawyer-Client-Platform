<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userType = (String) session.getAttribute("userType");
    if (session.getAttribute("userId") == null || !"lawyer".equals(userType)) {
        response.sendRedirect("login.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Case Assistant - Lawyer</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; }
        body { margin: 0; padding: 20px; background: #F8FAFC; font-family: 'Inter', sans-serif; color: #111827; }
        .content-header { background: #FFFFFF; padding: 1.5rem 2rem; border-radius: 12px; margin-bottom: 1rem; border: 1px solid #E5E7EB; }
        .content-header h1 { margin: 0 0 0.5rem; font-size: 1.75rem; }
        .content-header p { margin: 0; color: #6b7280; }
        .card { background: #FFFFFF; border: 1px solid #E5E7EB; border-radius: 12px; padding: 1.2rem; margin-bottom: 1rem; }
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0.8rem; }
        .field label { display: block; font-size: 0.9rem; margin-bottom: 0.35rem; color: #374151; font-weight: 600; }
        .field input, .field select, .field textarea {
            width: 100%; border: 1px solid #D1D5DB; border-radius: 8px; padding: 0.65rem 0.8rem; font-family: inherit; font-size: 0.95rem;
        }
        .field textarea { min-height: 150px; resize: vertical; }
        .field input:focus, .field select:focus, .field textarea:focus { outline: none; border-color: #C9A227; }
        .btn { background: #C9A227; color: #fff; border: none; border-radius: 8px; padding: 0.75rem 1rem; font-weight: 600; cursor: pointer; }
        .btn:hover { background: #A9861F; }
        .btn-alt { background: #0B1F3A; }
        .btn-alt:hover { background: #09172C; }
        .badge { margin-bottom: 0.8rem; border-radius: 8px; padding: 0.55rem 0.75rem; font-size: 0.9rem; border: 1px solid #E5E7EB; }
        .badge-ok { background: #ecfdf5; color: #065f46; border-color: #a7f3d0; }
        .badge-warning { background: #fffbeb; color: #92400e; border-color: #fcd34d; }
        .panel-title { margin: 0 0 0.6rem; font-size: 1.1rem; }
        .muted { color: #6B7280; font-size: 0.9rem; }
        .list { margin: 0; padding-left: 1.1rem; }
        .list li { margin-bottom: 0.4rem; }
        .strength-low { color: #B91C1C; }
        .strength-medium { color: #92400E; }
        .strength-high { color: #065F46; }
        @media (max-width: 900px) { .grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <div class="content-header">
        <h1><i class="fas fa-robot"></i> AI Case Assistant</h1>
        <p>Grounded legal drafting support using selected case details. Documents improve accuracy but are optional.</p>
    </div>

    <div class="card">
        <div id="modeStatus" class="badge badge-ok">Ready. Pick a case and request analysis.</div>
        <div class="grid">
            <div class="field">
                <label for="caseSelect">Active Case</label>
                <select id="caseSelect"></select>
            </div>
            <div class="field">
                <label for="caseIdManual">Or enter Case ID</label>
                <input type="number" id="caseIdManual" placeholder="Example: 101">
            </div>
        </div>
        <div class="field" style="margin-top:0.8rem;">
            <label for="prompt">Request</label>
            <textarea id="prompt" placeholder="Example: Summarize this case, identify applicable rules, estimate case strength, and list proof required."></textarea>
        </div>
        <div style="margin-top:0.8rem;display:flex;gap:0.6rem;flex-wrap:wrap;">
            <button id="analyzeBtn" class="btn" onclick="analyzeCase()">Generate Analysis</button>
            <button class="btn btn-alt" onclick="insertTemplate()">Insert Template</button>
        </div>
        <p class="muted" style="margin-top:0.6rem;">If document text is missing, AI still provides procedural guidance from available case details.</p>
    </div>

    <div class="card" id="analysisCard" style="display:none;">
        <h3 class="panel-title">Analysis Output</h3>
        <div id="analysisContent"></div>
    </div>

    <script>
        function escapeHtml(text) {
            return String(text || '')
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
        }

        function setStatus(message, type) {
            var el = document.getElementById('modeStatus');
            el.className = 'badge ' + (type === 'warning' ? 'badge-warning' : 'badge-ok');
            el.textContent = message;
        }

        function insertTemplate() {
            document.getElementById('prompt').value =
                'Using only case records, provide JSON with summary, applicable_rules, case_strength, and proof_required. ' +
                'If evidence is missing, return: I don\'t know from provided documents.';
        }

        async function loadCases() {
            var select = document.getElementById('caseSelect');
            select.innerHTML = '<option value="">Loading active cases...</option>';
            try {
                var res = await fetch('GetActiveCasesServlet');
                var rows = await res.json();
                if (!Array.isArray(rows) || rows.length === 0) {
                    select.innerHTML = '<option value="">No active cases found</option>';
                    return;
                }
                var options = ['<option value="">Select case</option>'];
                rows.forEach(function (r) {
                    options.push(
                        '<option value="' + r.caseId + '">#' + r.caseId + ' - ' +
                        escapeHtml(r.title || 'Untitled') + ' (' + escapeHtml(r.status || 'unknown') + ')</option>'
                    );
                });
                select.innerHTML = options.join('');
            } catch (e) {
                select.innerHTML = '<option value="">Unable to load active cases</option>';
            }
        }

        function getSelectedCaseId() {
            var manual = document.getElementById('caseIdManual').value.trim();
            if (manual) return manual;
            return document.getElementById('caseSelect').value;
        }

        function renderList(items) {
            if (!Array.isArray(items) || items.length === 0) return '<p class="muted">No items.</p>';
            return '<ul class="list">' + items.map(function (x) { return '<li>' + escapeHtml(x) + '</li>'; }).join('') + '</ul>';
        }

        function renderAnalysis(analysis) {
            var level = (analysis.case_strength && analysis.case_strength.level) ? analysis.case_strength.level : 'low';
            var strengthClass = 'strength-' + level;
            var html = '';
            html += '<p><strong>Summary:</strong> ' + escapeHtml(analysis.summary || '') + '</p>';
            html += '<p><strong>Confidence:</strong> ' + escapeHtml(String(analysis.confidence || 0)) + '%</p>';
            html += '<p><strong>Case Strength:</strong> <span class="' + strengthClass + '">' + escapeHtml(level.toUpperCase()) + '</span></p>';
            html += '<p><strong>Strength Reasoning</strong></p>' + renderList((analysis.case_strength || {}).reasoning || []);
            html += '<p><strong>Applicable Rules</strong></p>' + renderList(analysis.applicable_rules || []);
            html += '<p><strong>Proof Required</strong></p>' + renderList(analysis.proof_required || []);
            if (analysis.insufficient_evidence) {
                html += '<p class="muted"><strong>Evidence Gap:</strong> ' + escapeHtml(analysis.insufficient_evidence_reason || '') + '</p>';
            }
            html += '<p class="muted"><strong>Disclaimer:</strong> ' + escapeHtml(analysis.disclaimer || '') + '</p>';
            document.getElementById('analysisContent').innerHTML = html;
        }

        async function analyzeCase() {
            var caseId = getSelectedCaseId();
            var prompt = document.getElementById('prompt').value.trim();
            var analysisCard = document.getElementById('analysisCard');
            var analysisContent = document.getElementById('analysisContent');
            var btn = document.getElementById('analyzeBtn');

            if (!caseId) {
                analysisCard.style.display = 'block';
                analysisContent.innerHTML = '<p class="muted">Please select or enter a case ID.</p>';
                return;
            }
            if (!prompt) {
                analysisCard.style.display = 'block';
                analysisContent.innerHTML = '<p class="muted">Please enter a request.</p>';
                return;
            }

            btn.disabled = true;
            btn.textContent = 'Analyzing...';
            analysisCard.style.display = 'block';
            analysisContent.innerHTML = '<p class="muted">Generating grounded analysis...</p>';

            try {
                var body = new URLSearchParams({ role: 'lawyer', caseId: String(caseId), prompt: prompt });
                var response = await fetch('AiSupportServlet', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                    body: body.toString()
                });
                var data = await response.json();
                if (!response.ok || !data.ok) {
                    throw new Error(data.message || 'Request failed');
                }

                renderAnalysis(data.analysis || {});
                if (data.mode === 'live') {
                    setStatus('Live Gemini mode with grounded case context.', 'ok');
                } else if (data.mode === 'grounded-insufficient') {
                    setStatus('Limited evidence for case-specific judgment. Ask checklist/next-step questions or request more facts.', 'warning');
                } else {
                    setStatus('Fallback grounded mode used (Gemini key missing/unavailable).', 'warning');
                }
            } catch (err) {
                setStatus('Request failed. Please verify case access and server config.', 'warning');
                analysisContent.innerHTML = '<p class="muted">' + escapeHtml(err.message || String(err)) + '</p>';
            } finally {
                btn.disabled = false;
                btn.textContent = 'Generate Analysis';
            }
        }

        loadCases();
    </script>
</body>
</html>

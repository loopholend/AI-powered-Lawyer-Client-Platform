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
    <title>AI Support - Lawyer</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; }
        body { margin: 0; padding: 20px; background: #F8FAFC; font-family: 'Inter', sans-serif; color: #111827; }
        .content-header { background: #FFFFFF; padding: 1.5rem 2rem; border-radius: 12px; margin-bottom: 1.5rem; border: 1px solid #E5E7EB; }
        .content-header h1 { margin: 0 0 0.5rem; font-size: 1.75rem; }
        .content-header p { margin: 0; color: #6b7280; }
        .card { background: #FFFFFF; border: 1px solid #E5E7EB; border-radius: 12px; padding: 1.5rem; margin-bottom: 1rem; }
        .card h3 { margin: 0 0 0.75rem; }
        .status-badge { margin: 0 0 1rem; border-radius: 8px; padding: 0.6rem 0.75rem; font-size: 0.9rem; border: 1px solid #E5E7EB; }
        .status-ok { background: #ecfdf5; color: #065f46; border-color: #a7f3d0; }
        .status-warning { background: #fffbeb; color: #92400e; border-color: #fcd34d; }
        .btn { background: #C9A227; color: #fff; border: none; border-radius: 8px; padding: 0.75rem 1.1rem; font-weight: 600; cursor: pointer; }
        .btn:hover { background: #A9861F; }
        .btn-secondary { background: #0B1F3A; }
        .btn-secondary:hover { background: #09172C; }
        .grid { display: grid; grid-template-columns: 2fr 1fr; gap: 1rem; }
        .input-area { width: 100%; max-width: 100%; min-height: 150px; border: 1px solid #E5E7EB; border-radius: 8px; padding: 0.9rem; font-family: inherit; font-size: 0.95rem; resize: vertical; }
        .input-area:focus { outline: none; border-color: #C9A227; }
        .response { margin-top: 1rem; background: #F8FAFC; border: 1px solid #E5E7EB; border-radius: 8px; padding: 1rem; color: #374151; white-space: pre-wrap; overflow-wrap: anywhere; word-break: break-word; }
        .list { margin: 0; padding-left: 1rem; color: #4b5563; }
        .list li { margin-bottom: 0.5rem; }
        @media (max-width: 900px) { .grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <div class="content-header">
        <h1><i class="fas fa-robot"></i> AI Support</h1>
        <p>This chat uses the API key configured in backend file <code>src/java/AIConfig.java</code>.</p>
    </div>

    <div class="grid">
        <div class="card">
            <h3>Draft assistant</h3>
            <div id="modeStatus" class="status-badge status-ok">Using backend AI configuration.</div>
            <textarea id="prompt" class="input-area" placeholder="Paste case facts and ask for issue framing, missing facts checklist, or hearing prep notes."></textarea>
            <div style="display:flex;gap:0.6rem;flex-wrap:wrap;margin-top:0.8rem;">
                <button id="draftBtn" class="btn" onclick="generateDraft()">Generate Draft</button>
                <button class="btn btn-secondary" onclick="fillTemplate()">Insert Template</button>
            </div>
            <div id="draft" class="response" style="display:none;"></div>
        </div>

        <div class="card">
            <h3>Quick options</h3>
            <ul class="list">
                <li>Issue-spotting checklist</li>
                <li>Missing evidence checklist</li>
                <li>Client interview question bank</li>
                <li>Hearing preparation notes</li>
            </ul>
        </div>
    </div>

    <script>
        function setStatus(message, type) {
            var status = document.getElementById('modeStatus');
            status.className = 'status-badge ' + (type === 'ok' ? 'status-ok' : 'status-warning');
            status.textContent = message;
        }

        function fillTemplate() {
            document.getElementById('prompt').value =
                'Case Facts:\n' +
                '- Parties involved:\n' +
                '- Key dates:\n' +
                '- Current stage:\n\n' +
                'Please provide:\n' +
                '1) Key legal issues\n' +
                '2) Missing facts/evidence\n' +
                '3) Suggested next procedural steps';
        }

        function normalizeText(text) {
            if (!text) return '';
            return String(text).replace(/\\n/g, '\n').trim();
        }

        function localLawyerReply(prompt) {
            var lower = prompt.toLowerCase();
            var lines = ['Draft support (built-in mode):'];

            if (lower.indexOf('bail') !== -1 || lower.indexOf('criminal') !== -1) {
                lines.push('- Identify immediate procedural deadlines and jurisdiction.');
                lines.push('- Prepare chronology, notice/arrest records, and risk factors.');
            } else if (lower.indexOf('contract') !== -1 || lower.indexOf('agreement') !== -1) {
                lines.push('- Extract key obligations, breach points, and notice clauses.');
                lines.push('- List missing annexures, communication trail, and damages support.');
            } else {
                lines.push('- Frame issues: cause of action, maintainability, and relief sought.');
                lines.push('- Build missing-facts and evidence checklists.');
                lines.push('- Prioritize immediate procedural actions and client follow-up.');
            }

            return lines.join('\n');
        }

        async function generateDraft() {
            var prompt = document.getElementById('prompt').value.trim();
            var draft = document.getElementById('draft');
            var draftBtn = document.getElementById('draftBtn');

            if (!prompt) {
                draft.style.display = 'block';
                draft.textContent = 'Please provide case facts or use Insert Template first.';
                return;
            }

            draftBtn.disabled = true;
            draftBtn.textContent = 'Thinking...';
            draft.style.display = 'block';
            draft.textContent = 'Generating draft...';

            try {
                var body = new URLSearchParams({ prompt: prompt, role: 'lawyer' });
                var response = await fetch('AiSupportServlet', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                    body: body.toString()
                });

                var data = await response.json();
                if (!response.ok || !data.ok) {
                    throw new Error(data.message || 'Request failed');
                }

                var text = normalizeText(data.reply);
                if (!text) {
                    text = localLawyerReply(prompt);
                }

                draft.textContent = text;
                if (data.mode === 'fallback') {
                    setStatus('Using built-in fallback reply. Update key in backend file when ready.', 'warning');
                } else {
                    setStatus('Using backend AI key (live).', 'ok');
                }
            } catch (err) {
                draft.textContent = localLawyerReply(prompt) + '\n\n(Using built-in reply due to request issue.)';
                setStatus('Request issue detected. Using built-in fallback reply.', 'warning');
            } finally {
                draftBtn.disabled = false;
                draftBtn.textContent = 'Generate Draft';
            }
        }
    </script>
</body>
</html>
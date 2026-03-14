<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userType = (String) session.getAttribute("userType");
    if (session.getAttribute("userId") == null || !"client".equals(userType)) {
        response.sendRedirect("login.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Support - Client</title>
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
        .btn { background: #C9A227; color: #fff; border: none; border-radius: 8px; padding: 0.7rem 1.1rem; font-weight: 600; cursor: pointer; }
        .btn:hover { background: #A9861F; }
        .input-area { width: 100%; max-width: 100%; min-height: 130px; border: 1px solid #E5E7EB; border-radius: 8px; padding: 0.9rem; font-family: inherit; font-size: 0.95rem; resize: vertical; }
        .input-area:focus { outline: none; border-color: #C9A227; }
        .response { margin-top: 1rem; background: #F8FAFC; border: 1px solid #E5E7EB; border-radius: 8px; padding: 1rem; color: #374151; white-space: pre-wrap; overflow-wrap: anywhere; word-break: break-word; }
        .chips { display: flex; flex-wrap: wrap; gap: 0.5rem; margin-top: 0.5rem; }
        .chip { border: 1px solid #E5E7EB; background: #FFFFFF; color: #111827; border-radius: 999px; padding: 0.45rem 0.8rem; font-size: 0.85rem; cursor: pointer; }
        .chip:hover { border-color: #C9A227; color: #A9861F; }
        .note { color: #6b7280; font-size: 0.85rem; margin-top: 0.6rem; }
    </style>
</head>
<body>
    <div class="content-header">
        <h1><i class="fas fa-robot"></i> AI Support</h1>
        <p>This chat uses the API key configured in backend file <code>src/java/AIConfig.java</code>.</p>
    </div>

    <div class="card">
        <h3>Ask your question</h3>
        <div id="modeStatus" class="status-badge status-ok">Using backend AI configuration.</div>
        <textarea id="prompt" class="input-area" placeholder="Example: What documents should I prepare for a property dispute?"></textarea>
        <button id="askBtn" class="btn" onclick="generateAnswer()">Get Guidance</button>
        <div class="chips">
            <button class="chip" onclick="setPrompt('What documents are useful for a family law case?')">Family law documents</button>
            <button class="chip" onclick="setPrompt('How should I summarize my case for a lawyer?')">Case summary format</button>
            <button class="chip" onclick="setPrompt('How can I prepare for my first lawyer consultation?')">First consultation prep</button>
        </div>
        <div id="answer" class="response" style="display:none;"></div>
        <div class="note">Note: AI output is informational and not a substitute for formal legal advice.</div>
    </div>

    <script>
        function setPrompt(text) {
            document.getElementById('prompt').value = text;
        }

        function setStatus(message, type) {
            var status = document.getElementById('modeStatus');
            status.className = 'status-badge ' + (type === 'ok' ? 'status-ok' : 'status-warning');
            status.textContent = message;
        }

        function normalizeText(text) {
            if (!text) return '';
            return String(text).replace(/\\n/g, '\n').trim();
        }

        function localClientReply(prompt) {
            var lower = prompt.toLowerCase();
            var lines = ['Here is a quick guidance response:'];

            if (lower.indexOf('document') !== -1) {
                lines.push('1) Keep identity proof, timeline notes, and related records ready.');
                lines.push('2) Label each document by date for faster lawyer review.');
            } else if (lower.indexOf('consult') !== -1 || lower.indexOf('meeting') !== -1) {
                lines.push('1) Prepare a one-page summary (events, dates, desired outcome).');
                lines.push('2) Carry evidence and ask direct next-step questions.');
            } else {
                lines.push('1) Write a short timeline with dates and involved parties.');
                lines.push('2) Gather supporting records and urgent deadlines.');
                lines.push('3) Confirm final strategy with a verified lawyer.');
            }

            return lines.join('\n');
        }

        async function generateAnswer() {
            var prompt = document.getElementById('prompt').value.trim();
            var answer = document.getElementById('answer');
            var askBtn = document.getElementById('askBtn');

            if (!prompt) {
                answer.style.display = 'block';
                answer.textContent = 'Please type your question first.';
                return;
            }

            askBtn.disabled = true;
            askBtn.textContent = 'Thinking...';
            answer.style.display = 'block';
            answer.textContent = 'Generating response...';

            try {
                var body = new URLSearchParams({ prompt: prompt, role: 'client' });
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
                    text = localClientReply(prompt);
                }

                answer.textContent = text;
                if (data.mode === 'fallback') {
                    setStatus('Using built-in fallback reply. Update key in backend file when ready.', 'warning');
                } else {
                    setStatus('Using backend AI key (live).', 'ok');
                }
            } catch (err) {
                answer.textContent = localClientReply(prompt) + '\n\n(Using built-in reply due to request issue.)';
                setStatus('Request issue detected. Using built-in fallback reply.', 'warning');
            } finally {
                askBtn.disabled = false;
                askBtn.textContent = 'Get Guidance';
            }
        }
    </script>
</body>
</html>
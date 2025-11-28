<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { margin: 0; padding: 20px; background: #f9fafb; font-family: 'Inter', sans-serif; height: calc(100vh - 40px); overflow: hidden; }
        .content-header { background: white; padding: 1.5rem 2rem; border-radius: 12px; margin-bottom: 1rem; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        .content-header h1 { color: #1f2937; font-size: 1.75rem; margin-bottom: 0.5rem; display: flex; align-items: center; gap: 0.5rem; }
        .ai-icon { width: 40px; height: 40px; background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
        
        .tools-bar { background: white; padding: 1rem 2rem; border-radius: 12px; margin-bottom: 1rem; box-shadow: 0 2px 8px rgba(0,0,0,0.05); display: flex; gap: 1rem; flex-wrap: wrap; }
        .tool-btn { padding: 0.75rem 1.5rem; background: #f9fafb; border: 2px solid #e5e7eb; border-radius: 8px; cursor: pointer; transition: all 0.3s; font-size: 0.9rem; font-weight: 600; color: #1f2937; }
        .tool-btn:hover { background: #f5576c; color: white; border-color: #f5576c; transform: translateY(-2px); }
        .tool-btn.active { background: #f5576c; color: white; border-color: #f5576c; }
        
        .chat-container { background: white; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); display: flex; flex-direction: column; height: calc(100vh - 280px); }
        .chat-messages { flex: 1; overflow-y: auto; padding: 2rem; display: flex; flex-direction: column; gap: 1rem; }
        .message { display: flex; gap: 1rem; max-width: 85%; animation: slideIn 0.3s ease; }
        @keyframes slideIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        .message.user { margin-left: auto; flex-direction: row-reverse; }
        .message-avatar { width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; flex-shrink: 0; }
        .message.ai .message-avatar { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; }
        .message.user .message-avatar { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }
        .message-content { background: #f9fafb; padding: 1rem 1.5rem; border-radius: 12px; line-height: 1.6; color: #1f2937; }
        .message.user .message-content { background: #2563eb; color: white; }
        .message.ai .message-content { background: #f9fafb; border: 1px solid #e5e7eb; }
        
        .chat-input-container { padding: 1.5rem 2rem; border-top: 2px solid #f9fafb; display: flex; gap: 1rem; }
        .chat-input { flex: 1; padding: 1rem; border: 2px solid #e5e7eb; border-radius: 12px; font-size: 0.95rem; resize: none; min-height: 60px; max-height: 150px; }
        .send-btn { padding: 1rem 2rem; background: #f5576c; color: white; border: none; border-radius: 12px; font-weight: 600; cursor: pointer; transition: all 0.3s; }
        .send-btn:hover { background: #d93d52; transform: translateY(-2px); }
        .send-btn:disabled { background: #9ca3af; transform: none; }
        
        .welcome-message { text-align: center; color: #6b7280; margin-top: 2rem; }
        .quick-tools { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-top: 2rem; }
        .quick-tool-card { background: white; border: 2px solid #e5e7eb; padding: 1.5rem; border-radius: 8px; cursor: pointer; transition: all 0.3s; text-align: center; }
        .quick-tool-card:hover { border-color: #f5576c; transform: translateY(-3px); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .quick-tool-card i { font-size: 2rem; color: #f5576c; margin-bottom: 0.5rem; }
        .quick-tool-card h4 { color: #1f2937; margin: 0.5rem 0; }
        .quick-tool-card p { color: #6b7280; font-size: 0.85rem; margin: 0; }
    </style>
</head>
<body>
    <div class="content-header">
        <h1><div class="ai-icon"><i class="fas fa-brain"></i></div> AI Legal Assistant - Pro</h1>
        <p>Case analysis, summarization, and legal research powered by AI</p>
    </div>

    <div class="tools-bar">
        <button class="tool-btn active" onclick="setMode('summarize')">
            <i class="fas fa-file-alt"></i> Case Summarization
        </button>
        <button class="tool-btn" onclick="setMode('analysis')">
            <i class="fas fa-balance-scale"></i> Case Analysis
        </button>
        <button class="tool-btn" onclick="setMode('draft')">
            <i class="fas fa-pen"></i> Draft Review
        </button>
        <button class="tool-btn" onclick="setMode('research')">
            <i class="fas fa-search"></i> Legal Research
        </button>
    </div>

    <div class="chat-container">
        <div class="chat-messages" id="chatMessages">
            <div class="welcome-message">
                <i class="fas fa-gavel" style="font-size: 3rem; color: #f5576c; margin-bottom: 1rem;"></i>
                <h3>Welcome to AI Legal Assistant Pro!</h3>
                <p>Your professional legal research and case analysis tool</p>
                
                <div class="quick-tools">
                    <div class="quick-tool-card" onclick="quickStart('summarize')">
                        <i class="fas fa-file-contract"></i>
                        <h4>Summarize Case</h4>
                        <p>Get concise case summaries</p>
                    </div>
                    <div class="quick-tool-card" onclick="quickStart('precedent')">
                        <i class="fas fa-book"></i>
                        <h4>Find Precedents</h4>
                        <p>Search similar judgments</p>
                    </div>
                    <div class="quick-tool-card" onclick="quickStart('arguments')">
                        <i class="fas fa-comments"></i>
                        <h4>Build Arguments</h4>
                        <p>Generate legal arguments</p>
                    </div>
                    <div class="quick-tool-card" onclick="quickStart('sections')">
                        <i class="fas fa-list-ol"></i>
                        <h4>Applicable Sections</h4>
                        <p>Identify relevant laws</p>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="chat-input-container">
            <textarea id="messageInput" class="chat-input" placeholder="Paste case details, ask legal questions, or request case analysis..."></textarea>
            <button id="sendBtn" class="send-btn" onclick="sendMessage()">
                <i class="fas fa-paper-plane"></i> Analyze
            </button>
        </div>
    </div>

    <script type="importmap">
    {
        "imports": {
            "@google/generative-ai": "https://esm.run/@google/generative-ai"
        }
    }
    </script>
    
    <script type="module">
        import { GoogleGenerativeAI } from "@google/generative-ai";
        
        const API_KEY = "AIzaSyCr38DYy0JcA2G5LF6dRkNwStufy3Sp-ps";
        const genAI = new GoogleGenerativeAI(API_KEY);
        const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
        
        let currentMode = 'summarize';
        let typingDiv = null;
        
        window.setMode = function(mode) {
            currentMode = mode;
            document.querySelectorAll('.tool-btn').forEach(btn => btn.classList.remove('active'));
            event.target.closest('.tool-btn').classList.add('active');
        };
        
        window.quickStart = function(type) {
            const prompts = {
                'summarize': 'Please help me summarize a legal case. I will provide the details.',
                'precedent': 'Help me find relevant precedents for my case.',
                'arguments': 'Help me build legal arguments for my case.',
                'sections': 'Help me identify applicable legal sections.'
            };
            document.getElementById('messageInput').value = prompts[type];
            document.querySelector('.welcome-message').style.display = 'none';
        };
        
        window.sendMessage = async function() {
            const input = document.getElementById('messageInput');
            const message = input.value.trim();
            if (!message) return;
            
            document.querySelector('.welcome-message').style.display = 'none';
            addMessage(message, 'user');
            input.value = '';
            
            const sendBtn = document.getElementById('sendBtn');
            sendBtn.disabled = true;
            showTyping();
            
            try {
                const systemPrompt = getSystemPrompt(currentMode);
                const fullPrompt = systemPrompt + "\n\nLawyer's Request: " + message;
                
                const result = await model.generateContent(fullPrompt);
                const response = await result.response;
                const text = response.text();
                
                hideTyping();
                addMessage(text, 'ai');
                sendBtn.disabled = false;
                
            } catch (error) {
                console.error('Error:', error);
                hideTyping();
                addMessage('Error processing request. Please try again.', 'ai');
                sendBtn.disabled = false;
            }
        };
        
        function getSystemPrompt(mode) {
            const prompts = {
                'summarize': "You are an AI legal assistant for lawyers. Your task is to SUMMARIZE legal cases.\n\n" +
                    "When given case details, provide:\n" +
                    "1. **Case Summary** (3-4 sentences)\n" +
                    "2. **Key Facts** (bullet points)\n" +
                    "3. **Legal Issues** (main questions of law)\n" +
                    "4. **Parties Involved**\n" +
                    "5. **Timeline of Events** (if applicable)\n" +
                    "6. **Relief Sought**\n\n" +
                    "Be concise, professional, and structured. Use legal terminology appropriately.",
                
                'analysis': "You are an AI legal analyst for lawyers. Provide CASE STRENGTH ANALYSIS.\n\n" +
                    "When analyzing cases, provide:\n" +
                    "1. **Case Strength**: Percentage estimate (e.g., 70-75%)\n" +
                    "2. **Strong Points**: Legal strengths with specific sections\n" +
                    "3. **Weak Points**: Vulnerabilities and risks\n" +
                    "4. **Applicable Laws**: Cite specific Acts and sections\n" +
                    "5. **Precedents to Consider**: Mention relevant case laws\n" +
                    "6. **Strategy Recommendations**: Suggest approach\n\n" +
                    "Be thorough and professional.",
                
                'draft': "You are an AI legal document reviewer. Review and improve LEGAL DRAFTS.\n\n" +
                    "When reviewing drafts:\n" +
                    "1. **Identify errors**: Legal, factual, or grammatical\n" +
                    "2. **Missing elements**: What's not included\n" +
                    "3. **Improvement suggestions**: How to strengthen\n" +
                    "4. **Language check**: Professional legal language\n" +
                    "5. **Format suggestions**: Proper structure\n\n" +
                    "Be constructive and detailed.",
                
                'research': "You are an AI legal research assistant. Help with LEGAL RESEARCH.\n\n" +
                    "When asked for research:\n" +
                    "1. **Relevant Laws**: Cite applicable Acts and sections\n" +
                    "2. **Key Principles**: Explain legal doctrines\n" +
                    "3. **Suggested Precedents**: Mention important case laws (if known)\n" +
                    "4. **Search Suggestions**: Where to find more (SCC, Manupatra, etc.)\n" +
                    "5. **Related Issues**: Connected legal points\n\n" +
                    "Be comprehensive and scholarly."
            };
            
            return prompts[mode] || prompts['summarize'];
        }
        
        function addMessage(text, sender) {
            const messagesDiv = document.getElementById('chatMessages');
            const messageDiv = document.createElement('div');
            messageDiv.className = 'message ' + sender;
            
            const avatar = document.createElement('div');
            avatar.className = 'message-avatar';
            avatar.innerHTML = sender === 'user' ? '<%= session.getAttribute("firstName").toString().charAt(0) %>' : '<i class="fas fa-brain"></i>';
            
            const content = document.createElement('div');
            content.className = 'message-content';
            
            let formattedText = text
                .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
                .replace(/\*(.*?)\*/g, '<em>$1</em>')
                .replace(/###\s*(.*)/g, '<h4 style="margin-top:1rem; margin-bottom:0.5rem; color:#1f2937;">$1</h4>')
                .replace(/##\s*(.*)/g, '<h3 style="margin-top:1rem; margin-bottom:0.5rem; color:#1f2937;">$1</h3>')
                .replace(/•\s/g, '<br>• ')
                .replace(/\n/g, '<br>');
            
            content.innerHTML = formattedText;
            
            messageDiv.appendChild(avatar);
            messageDiv.appendChild(content);
            messagesDiv.appendChild(messageDiv);
            messagesDiv.scrollTop = messagesDiv.scrollHeight;
        }
        
        function showTyping() {
            typingDiv = document.createElement('div');
            typingDiv.className = 'message ai';
            typingDiv.innerHTML = '<div class="message-avatar"><i class="fas fa-brain"></i></div><div class="message-content"><em>Analyzing...</em></div>';
            document.getElementById('chatMessages').appendChild(typingDiv);
            document.getElementById('chatMessages').scrollTop = document.getElementById('chatMessages').scrollHeight;
        }
        
        function hideTyping() {
            if (typingDiv) typingDiv.remove();
        }
        
        document.getElementById('messageInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
            }
        });
    </script>
</body>
</html>

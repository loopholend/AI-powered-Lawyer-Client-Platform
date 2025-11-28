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
        .ai-icon { width: 40px; height: 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
        
        .tools-bar { background: white; padding: 1rem 2rem; border-radius: 12px; margin-bottom: 1rem; box-shadow: 0 2px 8px rgba(0,0,0,0.05); display: flex; gap: 1rem; flex-wrap: wrap; }
        .tool-btn { padding: 0.75rem 1.5rem; background: #f9fafb; border: 2px solid #e5e7eb; border-radius: 8px; cursor: pointer; transition: all 0.3s; font-size: 0.9rem; font-weight: 600; color: #1f2937; }
        .tool-btn:hover { background: #2563eb; color: white; border-color: #2563eb; transform: translateY(-2px); }
        .tool-btn.active { background: #2563eb; color: white; border-color: #2563eb; }
        
        .chat-container { background: white; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); display: flex; flex-direction: column; height: calc(100vh - 280px); }
        .chat-messages { flex: 1; overflow-y: auto; padding: 2rem; display: flex; flex-direction: column; gap: 1rem; }
        .message { display: flex; gap: 1rem; max-width: 85%; animation: slideIn 0.3s ease; }
        @keyframes slideIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        .message.user { margin-left: auto; flex-direction: row-reverse; }
        .message-avatar { width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; flex-shrink: 0; }
        .message.ai .message-avatar { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }
        .message.user .message-avatar { background: linear-gradient(135deg, #34d399 0%, #10b981 100%); color: white; }
        .message-content { background: #f9fafb; padding: 1rem 1.5rem; border-radius: 12px; line-height: 1.6; color: #1f2937; }
        .message.user .message-content { background: #2563eb; color: white; }
        .message.ai .message-content { background: #f9fafb; border: 1px solid #e5e7eb; }
        
        .chat-input-container { padding: 1.5rem 2rem; border-top: 2px solid #f9fafb; display: flex; gap: 1rem; }
        .chat-input { flex: 1; padding: 1rem; border: 2px solid #e5e7eb; border-radius: 12px; font-size: 0.95rem; resize: none; min-height: 60px; max-height: 150px; }
        .send-btn { padding: 1rem 2rem; background: #2563eb; color: white; border: none; border-radius: 12px; font-weight: 600; cursor: pointer; transition: all 0.3s; }
        .send-btn:hover { background: #1e40af; transform: translateY(-2px); }
        .send-btn:disabled { background: #9ca3af; transform: none; }
        
        .welcome-message { text-align: center; color: #6b7280; margin-top: 2rem; }
        .quick-tools { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-top: 2rem; }
        .quick-tool-card { background: white; border: 2px solid #e5e7eb; padding: 1.5rem; border-radius: 8px; cursor: pointer; transition: all 0.3s; text-align: center; }
        .quick-tool-card:hover { border-color: #2563eb; transform: translateY(-3px); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .quick-tool-card i { font-size: 2rem; color: #2563eb; margin-bottom: 0.5rem; }
        .quick-tool-card h4 { color: #1f2937; margin: 0.5rem 0; }
        .quick-tool-card p { color: #6b7280; font-size: 0.85rem; margin: 0; }
    </style>
</head>
<body>
    <div class="content-header">
        <h1><div class="ai-icon"><i class="fas fa-robot"></i></div> AI Legal Assistant</h1>
        <p>Get instant legal guidance and understand your rights</p>
    </div>

    <div class="tools-bar">
        <button class="tool-btn active" onclick="setMode('general')">
            <i class="fas fa-question-circle"></i> Legal Advice
        </button>
        <button class="tool-btn" onclick="setMode('rights')">
            <i class="fas fa-shield-alt"></i> Know Your Rights
        </button>
        <button class="tool-btn" onclick="setMode('documents')">
            <i class="fas fa-file-alt"></i> Legal Documents
        </button>
        <button class="tool-btn" onclick="setMode('procedures')">
            <i class="fas fa-tasks"></i> Legal Procedures
        </button>
    </div>

    <div class="chat-container">
        <div class="chat-messages" id="chatMessages">
            <div class="welcome-message">
                <i class="fas fa-balance-scale" style="font-size: 3rem; color: #2563eb; margin-bottom: 1rem;"></i>
                <h3>Welcome to AI Legal Assistant!</h3>
                <p>Ask me anything about Indian law, your rights, or legal procedures</p>
                
                <div class="quick-tools">
                    <div class="quick-tool-card" onclick="quickStart('rights')">
                        <i class="fas fa-home"></i>
                        <h4>Tenant Rights</h4>
                        <p>Know your rental rights</p>
                    </div>
                    <div class="quick-tool-card" onclick="quickStart('consumer')">
                        <i class="fas fa-shopping-cart"></i>
                        <h4>Consumer Rights</h4>
                        <p>File consumer complaints</p>
                    </div>
                    <div class="quick-tool-card" onclick="quickStart('divorce')">
                        <i class="fas fa-ring"></i>
                        <h4>Divorce Process</h4>
                        <p>Understand divorce laws</p>
                    </div>
                    <div class="quick-tool-card" onclick="quickStart('fir')">
                        <i class="fas fa-file-signature"></i>
                        <h4>File FIR</h4>
                        <p>How to file police complaint</p>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="chat-input-container">
            <textarea id="messageInput" class="chat-input" placeholder="Type your legal question here..."></textarea>
            <button id="sendBtn" class="send-btn" onclick="sendMessage()">
                <i class="fas fa-paper-plane"></i> Send
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
        
        let currentMode = 'general';
        let typingDiv = null;
        
        // Document/Form Links Database
        const documentLinks = {
            'fir': 'https://www.ecourts.gov.in/',
            'bail': 'https://www.ecourts.gov.in/',
            'affidavit': 'https://www.ecourts.gov.in/services/affidavit',
            'rtt': 'https://rtionline.gov.in/',
            'consumer complaint': 'https://consumerhelpline.gov.in/',
            'divorce': 'https://doj.gov.in/',
            'property': 'https://igrs.gov.in/'
        };
        
        window.setMode = function(mode) {
            currentMode = mode;
            document.querySelectorAll('.tool-btn').forEach(btn => btn.classList.remove('active'));
            event.target.closest('.tool-btn').classList.add('active');
        };
        
        window.quickStart = function(type) {
            const prompts = {
                'rights': 'What are my rights as a tenant in India?',
                'consumer': 'How do I file a consumer complaint?',
                'divorce': 'What is the divorce process in India and what documents do I need?',
                'fir': 'How do I file an FIR and what are my rights when dealing with police?'
            };
            document.getElementById('messageInput').value = prompts[type];
            document.querySelector('.welcome-message').style.display = 'none';
            sendMessage();
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
                const fullPrompt = systemPrompt + "\n\nUser Question: " + message;
                
                const result = await model.generateContent(fullPrompt);
                const response = await result.response;
                let text = response.text();
                
                // Add relevant document links
                let additionalLinks = checkForDocumentLinks(message);
                if (additionalLinks) {
                    text += "\n\n**📎 Helpful Resources:**\n" + additionalLinks;
                }
                
                hideTyping();
                addMessage(text, 'ai');
                sendBtn.disabled = false;
                
            } catch (error) {
                console.error('Error:', error);
                hideTyping();
                addMessage('Sorry, I encountered an error. Please try again.', 'ai');
                sendBtn.disabled = false;
            }
        };
        
        function getSystemPrompt(mode) {
            const prompts = {
                'general': "You are a helpful AI legal assistant for Indian law. Provide clear, accurate information.\n\n" +
                    "**For complex legal situations**: Provide case strength analysis with percentage, strengths, weaknesses, applicable laws.\n" +
                    "**For simple questions**: Give clear, concise answers in plain language.\n" +
                    "**Always include**: Relevant Indian laws and sections, practical steps, and disclaimer to consult a lawyer.\n\n" +
                    "Be empathetic and easy to understand.",
                
                'rights': "You are an AI assistant helping people understand their LEGAL RIGHTS in India.\n\n" +
                    "When explaining rights:\n" +
                    "1. **Explain the right clearly** in simple language\n" +
                    "2. **Cite the law**: Mention Constitutional Articles or specific Acts\n" +
                    "3. **How to exercise**: Practical steps to use the right\n" +
                    "4. **Where to complain**: If rights are violated\n" +
                    "5. **Important notes**: Limitations or exceptions\n\n" +
                    "Always remind to consult a lawyer for specific cases.",
                
                'documents': "You are an AI assistant helping with LEGAL DOCUMENTS and forms.\n\n" +
                    "When asked about documents:\n" +
                    "1. **Explain the document purpose**\n" +
                    "2. **List required information/fields**\n" +
                    "3. **Where to obtain**: Government portals, courts, etc.\n" +
                    "4. **Filing process**: How to submit\n" +
                    "5. **Fees involved**: If applicable\n\n" +
                    "Mention 'See helpful links below' (links will be added automatically).",
                
                'procedures': "You are an AI assistant explaining LEGAL PROCEDURES in India.\n\n" +
                    "When explaining procedures:\n" +
                    "1. **Step-by-step process**: Clear numbered steps\n" +
                    "2. **Timeline**: How long each step takes\n" +
                    "3. **Documents needed**: What to prepare\n" +
                    "4. **Costs involved**: Filing fees, etc.\n" +
                    "5. **Common mistakes**: What to avoid\n\n" +
                    "Use simple language and be thorough."
            };
            
            return prompts[mode] || prompts['general'];
        }
        
        function checkForDocumentLinks(message) {
            const lowerMessage = message.toLowerCase();
            let links = "";
            
            for (let [keyword, url] of Object.entries(documentLinks)) {
                if (lowerMessage.includes(keyword)) {
                    const displayName = keyword.charAt(0).toUpperCase() + keyword.slice(1);
                    links += `• ${displayName}: <a href="${url}" target="_blank" style="color:#2563eb;">${url}</a><br>`;
                }
            }
            
            if (lowerMessage.includes('form') || lowerMessage.includes('document') || lowerMessage.includes('blank')) {
                if (!links) {
                    links += "• eCourts India: <a href='https://ecourts.gov.in/ecourts_home/' target='_blank' style='color:#2563eb;'>https://ecourts.gov.in/</a><br>";
                    links += "• Department of Justice: <a href='https://doj.gov.in/' target='_blank' style='color:#2563eb;'>https://doj.gov.in/</a><br>";
                }
            }
            
            return links;
        }
        
        function addMessage(text, sender) {
            const messagesDiv = document.getElementById('chatMessages');
            const messageDiv = document.createElement('div');
            messageDiv.className = 'message ' + sender;
            
            const avatar = document.createElement('div');
            avatar.className = 'message-avatar';
            avatar.innerHTML = sender === 'user' ? '<%= session.getAttribute("firstName").toString().charAt(0) %>' : '<i class="fas fa-robot"></i>';
            
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
            typingDiv.innerHTML = '<div class="message-avatar"><i class="fas fa-robot"></i></div><div class="message-content"><em>Thinking...</em></div>';
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

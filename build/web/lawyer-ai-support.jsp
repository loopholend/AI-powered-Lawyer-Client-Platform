<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }
    
    String firstName = (String) session.getAttribute("firstName");
    if (firstName == null || firstName.isEmpty()) {
        firstName = "L";
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
            padding: 0;
            background: #f9fafb;
            font-family: 'Inter', sans-serif;
            height: 100vh;
            overflow: hidden;
        }

        .main-wrap {
            max-width: 600px;
            margin: 0 auto;
            height: 100vh;
            display: flex;
            flex-direction: column;
            box-shadow: 0 2px 10px rgba(60,72,100,0.05);
        }

        .content-header {
            background: #fff;
            padding: 1rem 1.5rem 1rem 1.5rem;
            border-bottom: 1px solid #e5e7eb;
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        .ai-icon {
            width: 32px;
            height: 32px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
        }
        .content-header h1 {
            font-size: 1.2rem;
            color: #1f2937;
            margin: 0;
        }
        .content-header p {
            font-size: 0.95rem;
            color: #6b7280;
            margin: 0;
        }
        .tools-bar {
            display: flex;
            gap: 0.5rem;
            margin: 0.5rem;
            flex-wrap: wrap;
            font-size: 0.92rem;
        }
        .tool-btn {
            padding: 0.4rem 1.1rem;
            border-radius: 6px;
            border: 1px solid #e5e7eb;
            background: #f3f6fb;
            color: #2563eb;
            font-weight: 500;
            cursor: pointer;
            transition: background 0.2s, color 0.2s;
        }
        .tool-btn.active, .tool-btn:hover {
            background: #2563eb;
            color: white;
        }
        .chat-container {
            flex: 1;
            min-height: 0;
            display: flex;
            flex-direction: column;
            background: #fff;
            position:relative;
            border-radius: 0 0 0 0;
        }
        .chat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 1rem 1.1rem;
            display: flex;
            flex-direction: column;
            gap: 0.7rem;
            max-height: 63vh;
            min-height: 100px;
            background: #f9fafb;
        }
        .message {
            display: flex;
            gap: 0.7rem;
            max-width: 92%;
            align-items: flex-start;
        }
        .message.user {
            flex-direction: row-reverse;
            margin-left: auto;
        }
        .message-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #ccd6f6;
            color: #2563eb;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 1.1rem;
        }
        .message.ai .message-avatar {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
        }
        .message.user .message-avatar {
            background: #10b981;
            color: #fff;
        }
        .message-content {
            padding: 0.8rem 1rem;
            border-radius: 8px;
            background: #fff;
            font-size: 0.97rem;
            box-shadow: 0 1px 4px rgba(60,72,100,0.045);
            color: #262732;
            word-break: break-word;
            white-space: pre-line;
            border: 1px solid #eaecf2;
        }
        .message.user .message-content {
            background: #2563eb;
            color: white;
            border: 1px solid #2563eb;
        }
        .welcome-message {
            text-align: center;
            color: #6b7280;
            padding: 0.7rem 0;
        }
        .welcome-message h3 {
            margin: 0.5rem 0 0.7rem 0;
            font-weight: 500;
            font-size: 1.14rem;
        }
        .quick-tools {
            display: flex;
            gap: 0.7rem;
            flex-wrap: wrap;
            justify-content: center;
            margin: 0.8rem 0 0 0;
        }
        .quick-tool-card {
            background: #fff;
            border: 2px solid #e5e7eb;
            padding: 0.7rem 1rem;
            border-radius: 8px;
            cursor: pointer;
            transition: border .2s, box-shadow .2s;
            text-align: center;
            font-size: 0.9rem;
            min-width: 120px;
        }
        .quick-tool-card:hover {
            border-color: #2563eb;
            box-shadow: 0 2px 8px rgba(37,99,235,.07);
        }
        .quick-tool-card i { font-size: 1.15rem; color: #2563eb; margin-bottom: 0.3rem;}
        .chat-input-container {
            border-top: 2px solid #f3f6fb;
            padding: 0.8rem 1rem 0.8rem 1rem;
            background: #fff;
            display: flex;
            gap: 0.6rem;
            align-items: flex-end;
        }
        .chat-input {
            flex: 1;
            padding: 0.8rem 1rem;
            border: 1.8px solid #e5e7eb;
            border-radius: 8px;
            font-size: 1rem;
            font-family: 'Inter', sans-serif;
            resize: none;
            min-height: 40px;
            max-height: 100px;
            background: #f9fafb;
        }
        .send-btn {
            padding: 0.8rem 1.3rem;
            background: #2563eb;
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            font-size: 1rem;
            transition: background .2s, box-shadow .2s;
        }
        .send-btn:hover { background: #1e40af; box-shadow: 0 4px 15px #cfd5f7a9;}
        .send-btn:disabled { background: #9ca3af; }
        @media (max-width:650px) {
            .main-wrap { max-width: 100vw; min-width:0; box-shadow:none;}
            .chat-container { border-radius:0; }
        }
    </style>
</head>
<body>
    <div class="main-wrap">
        <div class="content-header">
            <div class="ai-icon"><i class="fas fa-robot"></i></div>
            <div>
                <h1>AI Legal Assistant</h1>
                <p style="margin-top:2px;">Ask about law, procedures, or government forms</p>
            </div>
        </div>
        <div class="tools-bar">
            <button class="tool-btn active" onclick="setMode('general')"><i class="fas fa-question-circle"></i> Legal Advice</button>
            <button class="tool-btn" onclick="setMode('rights')"><i class="fas fa-shield-alt"></i> Your Rights</button>
            <button class="tool-btn" onclick="setMode('documents')"><i class="fas fa-file-alt"></i> Documents</button>
            <button class="tool-btn" onclick="setMode('procedures')"><i class="fas fa-tasks"></i> Procedures</button>
        </div>
        <div class="chat-container">
            <div class="chat-messages" id="chatMessages">
                <div class="welcome-message">
                    <i class="fas fa-balance-scale" style="font-size:2rem; color:#2563eb; margin-bottom:2px;"></i>
                    <h3>Welcome to AI Legal Assistant!</h3>
                    <p>Ask about Indian law, rights, forms, or court process</p>
                    <div class="quick-tools">
                        <div class="quick-tool-card" onclick="quickStart('rights')"><i class="fas fa-home"></i><div>Tenant Rights</div></div>
                        <div class="quick-tool-card" onclick="quickStart('consumer')"><i class="fas fa-shopping-cart"></i><div>Consumer Rights</div></div>
                        <div class="quick-tool-card" onclick="quickStart('divorce')"><i class="fas fa-ring"></i><div>Divorce Process</div></div>
                        <div class="quick-tool-card" onclick="quickStart('fir')"><i class="fas fa-file-signature"></i><div>File FIR</div></div>
                    </div>
                </div>
            </div>
            <div class="chat-input-container">
                <textarea id="messageInput" class="chat-input" placeholder="Type your legal question..."></textarea>
                <button id="sendBtn" class="send-btn" onclick="sendMessage()">
                    <i class="fas fa-paper-plane"></i>
                </button>
            </div>
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
    const API_KEY = "AIzaSyBEXfMRXVqFd1iN_uQkAHVR2B57I9K81uc";
    const genAI = new GoogleGenerativeAI(API_KEY);
    const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash-exp" });
    let currentMode = 'general';
    let typingDiv = null;

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
        document.getElementById('messageInput').focus();
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
        document.getElementById('messageInput').focus();
        sendMessage();
    };

    window.sendMessage = async function() {
        const input = document.getElementById('messageInput');
        const message = input.value.trim();
        if (!message) return;
        document.querySelector('.welcome-message').style.display = 'none';
        addMessage(message, 'user');
        input.value = '';
        input.style.height = "40px";
        document.getElementById('messageInput').focus();

        const sendBtn = document.getElementById('sendBtn');
        sendBtn.disabled = true;
        showTyping();
        try {
            const systemPrompt = getSystemPrompt(currentMode);
            const fullPrompt = systemPrompt + "\n\nUser Question: " + message;
            const result = await model.generateContent(fullPrompt);
            const response = await result.response;
            let text = response.text();
            let additionalLinks = checkForDocumentLinks(message);
            if (additionalLinks) {
                text += "\n\n**📎 Helpful Resources:**\n" + additionalLinks;
            }
            hideTyping();
            addMessage(text, 'ai');
            sendBtn.disabled = false;
            setTimeout(() => { document.getElementById('chatMessages').scrollTop = document.getElementById('chatMessages').scrollHeight; }, 80);
        } catch (error) {
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
        avatar.innerHTML = sender === 'user' ? '<%= firstName.substring(0, 1).toUpperCase() %>' : '<i class="fas fa-robot"></i>';
        const content = document.createElement('div');
        content.className = 'message-content';
        let formattedText = text
            .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
            .replace(/\*(.*?)\*/g, '<em>$1</em>')
            .replace(/###\s*(.*)/g, '<h4 style="margin:0.3rem 0;color:#1f2937;">$1</h4>')
            .replace(/##\s*(.*)/g, '<h3 style="margin:0.3rem 0;color:#1f2937;">$1</h3>')
            .replace(/•\s/g, '<br>• ')
            .replace(/\n/g, '<br>');
        content.innerHTML = formattedText;
        messageDiv.appendChild(avatar);
        messageDiv.appendChild(content);
        messagesDiv.appendChild(messageDiv);
        setTimeout(() => { messagesDiv.scrollTop = messagesDiv.scrollHeight; }, 40);
    }

    function showTyping() {
        typingDiv = document.createElement('div');
        typingDiv.className = 'message ai';
        typingDiv.innerHTML = '<div class="message-avatar"><i class="fas fa-robot"></i></div><div class="message-content"><em>Typing...</em></div>';
        document.getElementById('chatMessages').appendChild(typingDiv);
        document.getElementById('chatMessages').scrollTop = document.getElementById('chatMessages').scrollHeight;
    }

    function hideTyping() {
        if (typingDiv) typingDiv.remove();
    }

    document.getElementById('messageInput').addEventListener('input', function() {
        this.style.height = '40px';
        this.style.height = (this.scrollHeight) + 'px';
    });
    document.getElementById('messageInput').addEventListener('focus', function() {
        this.scrollIntoView({block:"nearest"});
    });
    document.getElementById('messageInput').addEventListener('keypress', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });
    </script>
</body>
</html>

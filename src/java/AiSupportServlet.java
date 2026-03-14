import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class AiSupportServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"ok\":false,\"message\":\"Not logged in\"}");
            return;
        }

        String userType = safe((String) session.getAttribute("userType"));
        String role = safe(request.getParameter("role"));
        String prompt = safe(request.getParameter("prompt"));

        if (prompt.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"ok\":false,\"message\":\"Prompt is required\"}");
            return;
        }

        if (role.isEmpty()) {
            role = userType;
        }

        if (!userType.equals(role)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().print("{\"ok\":false,\"message\":\"Unauthorized role\"}");
            return;
        }

        String reply;
        String mode;

        if (AIConfig.API_KEY == null || AIConfig.API_KEY.trim().isEmpty()) {
            reply = buildLocalReply(prompt, role);
            mode = "fallback";
        } else {
            try {
                reply = callProvider(prompt, role);
                if (reply == null || reply.trim().isEmpty()) {
                    reply = buildLocalReply(prompt, role);
                    mode = "fallback";
                } else {
                    mode = "live";
                }
            } catch (Exception ex) {
                reply = buildLocalReply(prompt, role) + "\n\n(Using built-in reply due to API issue.)";
                mode = "fallback";
            }
        }

        response.getWriter().print(
                "{\"ok\":true,\"mode\":\"" + escapeJson(mode) + "\",\"reply\":\"" + escapeJson(reply) + "\"}");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    private String callProvider(String prompt, String role) throws IOException {
        String endpoint = safe(AIConfig.ENDPOINT);
        String model = safe(AIConfig.MODEL);

        if (endpoint.isEmpty()) {
            throw new IOException("AI endpoint is empty");
        }
        if (model.isEmpty()) {
            throw new IOException("AI model is empty");
        }

        String systemPrompt;
        if ("lawyer".equals(role)) {
            systemPrompt = "You assist lawyers with concise drafting support. Do not claim final legal conclusions.";
        } else {
            systemPrompt = "You are a concise legal support assistant. Provide informational guidance, not final legal advice.";
        }

        String payload = "{"
                + "\"model\":\"" + escapeJson(model) + "\","
                + "\"input\":["
                + "{\"role\":\"system\",\"content\":\"" + escapeJson(systemPrompt) + "\"},"
                + "{\"role\":\"user\",\"content\":\"" + escapeJson(prompt) + "\"}"
                + "]"
                + "}";

        HttpURLConnection connection = (HttpURLConnection) new URL(endpoint).openConnection();
        connection.setRequestMethod("POST");
        connection.setConnectTimeout(15000);
        connection.setReadTimeout(30000);
        connection.setDoOutput(true);
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setRequestProperty("Authorization", "Bearer " + AIConfig.API_KEY);

        try (OutputStream outputStream = connection.getOutputStream()) {
            outputStream.write(payload.getBytes(StandardCharsets.UTF_8));
        }

        int status = connection.getResponseCode();
        String body;
        try (InputStream stream = status >= 200 && status < 300
                ? connection.getInputStream()
                : connection.getErrorStream()) {
            body = readStream(stream);
        }

        if (status < 200 || status >= 300) {
            throw new IOException("Provider request failed with status " + status + ": " + truncate(body, 200));
        }

        String text = extractResponseText(body);
        return text == null ? "" : text.trim();
    }

    private String extractResponseText(String responseBody) {
        if (responseBody == null || responseBody.isEmpty()) {
            return "";
        }

        Pattern outputTextPattern = Pattern.compile("\"output_text\"\\s*:\\s*\"((?:\\\\.|[^\"\\\\])*)\"");
        Matcher outputTextMatcher = outputTextPattern.matcher(responseBody);
        if (outputTextMatcher.find()) {
            return unescapeJsonString(outputTextMatcher.group(1));
        }

        Pattern contentTextPattern = Pattern.compile("\"text\"\\s*:\\s*\"((?:\\\\.|[^\"\\\\])*)\"");
        Matcher contentTextMatcher = contentTextPattern.matcher(responseBody);
        if (contentTextMatcher.find()) {
            return unescapeJsonString(contentTextMatcher.group(1));
        }

        return "";
    }

    private String buildLocalReply(String prompt, String role) {
        String lower = safe(prompt).toLowerCase();
        StringBuilder reply = new StringBuilder();

        if ("lawyer".equals(role)) {
            reply.append("Draft support (built-in mode):\n");
            if (lower.contains("bail") || lower.contains("criminal")) {
                reply.append("- Identify immediate procedural deadlines and jurisdiction.\n");
                reply.append("- Prepare chronology, notice/arrest records, and risk factors.");
            } else if (lower.contains("contract") || lower.contains("agreement")) {
                reply.append("- Extract key obligations, breach points, and notice clauses.\n");
                reply.append("- List missing annexures, communication trail, and damages support.");
            } else {
                reply.append("- Frame issues: cause of action, maintainability, and relief sought.\n");
                reply.append("- Build missing-facts and evidence checklists.\n");
                reply.append("- Prioritize immediate procedural actions and client follow-up.");
            }
        } else {
            reply.append("Here is a quick guidance response:\n");
            if (lower.contains("document")) {
                reply.append("1) Keep identity proof, timeline notes, and related records ready.\n");
                reply.append("2) Label each document by date for faster lawyer review.");
            } else if (lower.contains("consult") || lower.contains("meeting")) {
                reply.append("1) Prepare a one-page summary (events, dates, desired outcome).\n");
                reply.append("2) Carry evidence and ask direct next-step questions.");
            } else {
                reply.append("1) Write a short timeline with dates and involved parties.\n");
                reply.append("2) Gather supporting records and urgent deadlines.\n");
                reply.append("3) Confirm final strategy with a verified lawyer.");
            }
        }

        return reply.toString();
    }

    private String readStream(InputStream inputStream) throws IOException {
        if (inputStream == null) {
            return "";
        }
        StringBuilder builder = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                builder.append(line);
            }
        }
        return builder.toString();
    }

    private String safe(String value) {
        return value == null ? "" : value.trim();
    }

    private String truncate(String value, int maxLength) {
        if (value == null) {
            return "";
        }
        return value.length() <= maxLength ? value : value.substring(0, maxLength);
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    private String unescapeJsonString(String value) {
        if (value == null || value.isEmpty()) {
            return "";
        }

        StringBuilder out = new StringBuilder();
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            if (c == '\\' && i + 1 < value.length()) {
                char n = value.charAt(i + 1);
                switch (n) {
                    case 'n':
                        out.append('\n');
                        i++;
                        break;
                    case 'r':
                        out.append('\r');
                        i++;
                        break;
                    case 't':
                        out.append('\t');
                        i++;
                        break;
                    case '\\':
                        out.append('\\');
                        i++;
                        break;
                    case '"':
                        out.append('"');
                        i++;
                        break;
                    case '/':
                        out.append('/');
                        i++;
                        break;
                    case 'b':
                        out.append('\b');
                        i++;
                        break;
                    case 'f':
                        out.append('\f');
                        i++;
                        break;
                    default:
                        out.append(c);
                        break;
                }
            } else {
                out.append(c);
            }
        }
        return out.toString();
    }
}

# LegalConnect

LegalConnect is a Java EE web application that connects clients and lawyers with case management, chat, notifications, admin moderation, and AI-assisted legal support.

## Highlights

- Multi-role authentication (`client`, `lawyer`, `admin`)
- Client workflows: register, upload cases, track progress, review lawyers, submit complaints
- Lawyer workflows: discover pending cases, accept/manage active cases, update status/timeline
- Shared chat per case with optional file attachments
- Notification center with read/unread tracking
- Admin panel for lawyer verification, complaints handling, and audit logs
- AI support endpoint with provider mode + built-in fallback responses

## Tech Stack

- Java 8
- Java EE Web (Servlet/JSP)
- Apache Ant / NetBeans web project
- MySQL (JDBC: `mysql-connector-j-9.1.0`)
- Frontend: JSP/HTML/CSS/Vanilla JS

## Project Structure

```text
LegalConnent/
  src/java/               # Servlets + utility classes
  web/                    # JSP/HTML views and static assets
    WEB-INF/web.xml       # Servlet declarations + mappings
  nbproject/              # NetBeans project metadata
  build.xml               # Ant build entrypoint
```

## Prerequisites

- JDK 8+
- MySQL 8+
- GlassFish/Payara server compatible with Java EE web apps
- NetBeans (recommended) or Ant CLI

## Configuration

### 1) Database connection

Update database settings in `src/java/DBConnectionUtil.java`:

```java
private static final String DB_URL = "jdbc:mysql://localhost:3306/legalconnect_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
private static final String DB_USER = "root";
private static final String DB_PASSWORD = "root";
```

Create the database:

```sql
CREATE DATABASE legalconnect_db;
```

> Note: Feature tables (`case_timeline`, `notifications`, `case_messages`, `lawyer_reviews`, `complaints`, `admin_logs`) are auto-created at runtime by `FeatureSchemaUtil`.

### 2) AI support (optional)

Set your key in `src/java/AIConfig.java`:

```java
public static final String API_KEY = "";
public static final String MODEL = "gpt-4o-mini";
public static final String ENDPOINT = "https://api.openai.com/v1/responses";
```

If `API_KEY` is empty, the app automatically returns built-in fallback responses.

## Running the App

### Option A: NetBeans (recommended)

1. Open this folder as a NetBeans project.
2. Configure your application server (GlassFish/Payara).
3. Build and run.
4. Open:
   - `http://localhost:8080/LegalConnect/`

### Option B: Ant build

```bash
ant clean
ant
```

Deploy the generated WAR (typically `dist/LegalConnect.war`) to your Java EE server.

## Core Endpoints (sample)

- Auth: `LoginServlet`, `LogoutServlet`, `ClientRegisterServlet`, `LawyerRegisterServlet`
- Client: `UploadCaseServlet`, `GetCasesServlet`, `GetClientCaseTrackerServlet`, `SubmitReviewServlet`, `SubmitComplaintServlet`
- Lawyer: `GetNewCasesServlet`, `AcceptCaseServlet`, `GetActiveCasesServlet`, `UpdateCaseStatusServlet`, `GetLawyerStatsServlet`
- Messaging: `GetCaseChatListServlet`, `GetCaseMessagesServlet`, `SendCaseMessageServlet`
- Admin: `GetAdminStatsServlet`, `GetAdminLawyersServlet`, `AdminLawyerActionServlet`, `GetAdminComplaintsServlet`, `UpdateComplaintStatusServlet`, `GetAdminLogsServlet`
- Shared: `GetNotificationsServlet`, `MarkNotificationsReadServlet`, `GetCaseTimelineServlet`, `AiSupportServlet`

Full servlet mappings are defined in `web/WEB-INF/web.xml`.

## Current Known Gaps

- `Forgot Password` link in `web/login.html` is currently a placeholder.
- Terms/Privacy/Code of Conduct links in registration pages are placeholders.
- `Remember me` is present in UI but not persisted in backend login logic.

## Security Notes

- Do not commit real DB passwords or API keys.
- Move credentials to environment variables or server secrets for production use.
- Add password reset, email verification, and stronger auth controls before production rollout.

## License

No license file is currently included in this repository.

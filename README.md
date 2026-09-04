# JSP Anatomy & Lifecycle Inspector

A professional single-page JSP diagnostic dashboard created for Full Stack Technology lab work.

## 🌐 Live Demo
   🚀 **Live Project:**  https://jsp-anatomy-lifecycle-inspector.onrender.com

## What it demonstrates

- JSP processing / translation cycle
- JSP page directives
- JSP implicit objects
- Request method, URI, protocol and client IP
- HTTP request headers
- Response content type, encoding, buffer and committed state
- JVM startup time and uptime
- JVM memory usage
- HTTP session information
- Interactive session parameter storage
- Responsive dashboard UI

## Main file

`index.jsp` contains the complete dashboard, Java/JSP logic, HTML and CSS. No database, framework, JavaScript library or separate servlet is required.

## Run

1. Install JDK and Apache Tomcat.
2. Copy the `JSP_Anatomy_Lifecycle_Inspector` folder into Tomcat's `webapps` directory.
3. Start Tomcat with `bin/startup.bat` on Windows.
4. Open:

`http://localhost:8080/JSP_Anatomy_Lifecycle_Inspector/index.jsp`

## Technical note

A standard JSP implicit object does not directly expose a Tomcat-wide server startup timestamp. This dashboard therefore uses Java's `RuntimeMXBean` JVM start time and uptime as the runtime diagnostic.

## GitHub

Commit `index.jsp`, `README.md` and `.gitignore`. Do not commit the Tomcat installation, logs, temporary files or generated server files.

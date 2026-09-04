<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.lang.management.ManagementFactory,java.lang.management.RuntimeMXBean,java.text.SimpleDateFormat,java.util.Date,java.util.Map,java.util.LinkedHashMap" %>

<%!
    private String esc(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;")
                   .replace(">", "&gt;").replace("\"", "&quot;");
    }

    private String date(long millis) {
        return new SimpleDateFormat("dd MMM yyyy, hh:mm:ss a").format(new Date(millis));
    }

    private String bytes(long value) {
        if (value < 1024) return value + " B";
        double kb = value / 1024.0;
        if (kb < 1024) return String.format("%.2f KB", kb);
        double mb = kb / 1024.0;
        if (mb < 1024) return String.format("%.2f MB", mb);
        return String.format("%.2f GB", mb / 1024.0 / 1024.0);
    }
%>

<%
    /* =========================
       RUNTIME / JVM INFORMATION
       ========================= */
    Runtime runtime = Runtime.getRuntime();
    RuntimeMXBean mx = ManagementFactory.getRuntimeMXBean();

    long startTime = mx.getStartTime();
    long uptimeSeconds = mx.getUptime() / 1000;

    long allocatedMemory = runtime.totalMemory();
    long freeMemory = runtime.freeMemory();
    long usedMemory = allocatedMemory - freeMemory;
    long maxMemory = runtime.maxMemory();

    double memoryOfMax = maxMemory > 0 ? (usedMemory * 100.0 / maxMemory) : 0;
    double memoryOfAllocated = allocatedMemory > 0 ? (usedMemory * 100.0 / allocatedMemory) : 0;

    /* =========================
       REQUEST INFORMATION
       ========================= */
    String requestUri = request.getRequestURI();
    String clientIp = request.getRemoteAddr();
    String serverName = request.getServerName();
    int serverPort = request.getServerPort();

    /* =========================
       RESPONSE INFORMATION
       ========================= */
    String responseType = response.getContentType();
    String encoding = response.getCharacterEncoding();

    /* =========================
       CONFIG / PAGE CONTEXT
       ========================= */
    String servletName = config.getServletName();
    String pageContextClass = pageContext.getClass().getName();

    /* =========================
       SESSION INFORMATION
       ========================= */
    String sessionValue = request.getParameter("sessionValue");

    if (sessionValue != null && !sessionValue.trim().isEmpty()) {
        session.setAttribute("demoParameter", sessionValue.trim());
    }

    Object demoParameter = session.getAttribute("demoParameter");

    String sessionId = session.getId();
    long sessionCreated = session.getCreationTime();
    long sessionLastAccessed = session.getLastAccessedTime();
    int inactiveInterval = session.getMaxInactiveInterval();

    /* =========================
       REQUEST HEADERS
       ========================= */
    Map<String, String> headers = new LinkedHashMap<String, String>();
    java.util.Enumeration<String> names = request.getHeaderNames();

    if (names != null) {
        while (names.hasMoreElements()) {
            String name = names.nextElement();
            headers.put(name, request.getHeader(name));
        }
    }

    /* A single JSP cannot reliably expose a Tomcat-wide server-start timestamp
       through implicit objects. JVM start time is used as the diagnostic runtime. */
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>JSP Anatomy & Lifecycle Inspector</title>

<style>
    :root {
        --navy: #071426;
        --navy2: #0d1e35;
        --blue: #1677ff;
        --blue2: #35a4ff;
        --text: #142033;
        --muted: #718096;
        --line: #e8edf5;
        --bg: #f4f7fb;
        --card: #ffffff;
        --green: #13a463;
        --purple: #7357e8;
        --orange: #e88b18;
        --pink: #db3e83;
        --shadow: 0 14px 40px rgba(20, 42, 78, .08);
    }

    * { box-sizing: border-box; }

    html { scroll-behavior: smooth; }

    body {
        margin: 0;
        background: var(--bg);
        color: var(--text);
        font-family: Inter, "Segoe UI", Arial, sans-serif;
    }

    .app {
        min-height: 100vh;
        display: flex;
    }

    /* ---------- SIDEBAR ---------- */
    .sidebar {
        width: 245px;
        position: fixed;
        inset: 0 auto 0 0;
        background: linear-gradient(180deg, #071426 0%, #0b1b31 100%);
        color: #dce8ff;
        padding: 24px 15px;
        display: flex;
        flex-direction: column;
        z-index: 20;
    }

    .brand {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 2px 12px 28px;
    }

    .brand-icon {
        width: 42px;
        height: 42px;
        border-radius: 12px;
        display: grid;
        place-items: center;
        font-size: 23px;
        background: linear-gradient(135deg, #1979ff, #49b7ff);
        box-shadow: 0 8px 25px rgba(35, 137, 255, .25);
    }

    .brand-title {
        font-size: 16px;
        font-weight: 800;
        letter-spacing: .2px;
    }

    .brand-title span { color: #31a7ff; }

    .brand-sub {
        color: #8094b2;
        font-size: 9px;
        margin-top: 4px;
        letter-spacing: 1px;
    }

    .nav-title {
        color: #617793;
        font-size: 10px;
        font-weight: 800;
        text-transform: uppercase;
        letter-spacing: 1.3px;
        padding: 4px 13px 9px;
    }

    .nav a {
        display: flex;
        align-items: center;
        gap: 12px;
        color: #b9c9df;
        text-decoration: none;
        padding: 11px 13px;
        border-radius: 10px;
        margin: 4px 0;
        font-size: 13px;
        transition: .2s;
    }

    .nav a:hover, .nav a.active {
        background: linear-gradient(90deg, rgba(36, 125, 244, .95), rgba(36, 125, 244, .55));
        color: white;
        box-shadow: 0 8px 20px rgba(20, 105, 220, .18);
    }

    .nav-icon {
        width: 20px;
        text-align: center;
        font-size: 16px;
    }

    .about-box {
        margin: auto 5px 16px;
        border: 1px solid rgba(145, 181, 226, .2);
        background: rgba(255,255,255,.035);
        border-radius: 13px;
        padding: 15px;
    }

    .about-box h4 {
        margin: 0 0 7px;
        color: #35a8ff;
        font-size: 12px;
    }

    .about-box p {
        margin: 0;
        color: #9eb0c9;
        font-size: 11px;
        line-height: 1.65;
    }

    .side-footer {
        color: #6f839f;
        font-size: 10px;
        line-height: 1.7;
        padding: 0 10px;
    }

    /* ---------- MAIN ---------- */
    .main {
        width: calc(100% - 245px);
        margin-left: 245px;
    }

    .hero {
        min-height: 142px;
        color: white;
        position: relative;
        overflow: visible;
        padding: 28px 42px;
        background:
            radial-gradient(circle at 88% 20%, rgba(56, 165, 255, .22), transparent 28%),
            linear-gradient(115deg, #0b1a30, #10294a 55%, #123d75);
        border-bottom: 1px solid rgba(255,255,255,.06);
    }

    .hero:after {
        content: "";
        position: absolute;
        width: 420px;
        height: 420px;
        border: 1px solid rgba(94, 178, 255, .10);
        border-radius: 50%;
        right: -100px;
        top: -230px;
    }

    .hero-content {
        position: relative;
        z-index: 30;
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 25px;
    }

    .hero h1 {
        margin: 0 0 7px;
        font-size: 31px;
        letter-spacing: -.7px;
    }

    .hero p {
        margin: 0;
        color: #b9cae2;
        font-size: 14px;
    }

    .server-pill {
        min-width: 215px;
        padding: 12px 16px;
        border: 1px solid rgba(135, 192, 255, .35);
        border-radius: 12px;
        background: rgba(2, 16, 35, .25);
        backdrop-filter: blur(8px);
    }

    .server-status {
        color: #45e394;
        font-size: 12px;
        font-weight: 800;
        margin-bottom: 5px;
    }

    .server-time {
        color: #b7c7dc;
        font-size: 10px;
    }

    .content {
        position: relative;
        z-index: 1;
        width: 94%;
        max-width: 1450px;
        margin: 0 auto;
        padding: 22px 0 40px;
    }

    /* ---------- KPI ---------- */
    .kpis {
        display: grid;
        grid-template-columns: repeat(5, 1fr);
        gap: 15px;
        margin-bottom: 17px;
    }

    .kpi {
        background: var(--card);
        border: 1px solid var(--line);
        border-radius: 12px;
        box-shadow: 0 8px 25px rgba(20, 42, 78, .055);
        padding: 14px 15px;
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .kpi-icon {
        width: 42px;
        height: 42px;
        border-radius: 11px;
        display: grid;
        place-items: center;
        font-size: 20px;
        flex: 0 0 auto;
    }

    .kpi:nth-child(1) .kpi-icon { background:#e1f8ed; color:#10965b; }
    .kpi:nth-child(2) .kpi-icon { background:#eee8ff; color:#7357e8; }
    .kpi:nth-child(3) .kpi-icon { background:#e4f1ff; color:#1677ff; }
    .kpi:nth-child(4) .kpi-icon { background:#fff0dc; color:#d9790b; }
    .kpi:nth-child(5) .kpi-icon { background:#ffe5f0; color:#d53d7c; }

    .kpi-label {
        color: var(--muted);
        font-size: 10px;
        font-weight: 700;
        margin-bottom: 4px;
    }

    .kpi-value {
        font-size: 15px;
        font-weight: 850;
        white-space: nowrap;
    }

    /* ---------- CARDS ---------- */
    .grid {
        display: grid;
        grid-template-columns: 1.05fr 1fr 1fr;
        gap: 17px;
    }

    .card {
        background: var(--card);
        border: 1px solid var(--line);
        border-radius: 13px;
        box-shadow: var(--shadow);
        padding: 19px;
        overflow: hidden;
    }

    .card.full { grid-column: 1 / -1; }

    .card-head {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 10px;
        padding-bottom: 13px;
        margin-bottom: 5px;
        border-bottom: 1px solid #edf1f6;
    }

    .title-wrap {
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .section-icon {
        width: 34px;
        height: 34px;
        border-radius: 10px;
        display: grid;
        place-items: center;
        font-size: 16px;
        background: #e9f3ff;
        color: var(--blue);
    }

    .card h2 {
        margin: 0;
        color: #103582;
        font-size: 16px;
        letter-spacing: -.2px;
    }

    .tag {
        padding: 5px 9px;
        border-radius: 999px;
        background: #e7f2ff;
        color: #126ce2;
        font-size: 9px;
        font-weight: 850;
        white-space: nowrap;
    }

    .row {
        display: grid;
        grid-template-columns: 44% 56%;
        padding: 9px 5px;
        border-bottom: 1px solid #f0f3f7;
        gap: 8px;
    }

    .row:last-child { border-bottom: 0; }

    .label {
        color: #51627b;
        font-size: 11px;
        font-weight: 700;
    }

    .value {
        color: #1a2a43;
        font-size: 11px;
        font-family: Consolas, "Courier New", monospace;
        text-align: right;
        word-break: break-word;
    }

    .status {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 10px;
        border-radius: 999px;
        background: #dff8e9;
        color: #07854c;
        font-family: Inter, sans-serif;
        font-weight: 850;
        font-size: 10px;
    }

    .status-dot {
        width: 7px;
        height: 7px;
        background: #12b76a;
        border-radius: 50%;
        box-shadow: 0 0 0 4px rgba(18,183,106,.10);
    }

    /* ---------- MEMORY ---------- */
    .memory-stat {
        display: flex;
        justify-content: space-between;
        padding: 8px 3px;
        font-size: 11px;
        border-bottom: 1px solid #f0f3f7;
    }

    .memory-stat strong { font-family: Consolas, monospace; }

    .progress {
        height: 13px;
        background: #e9edf3;
        border-radius: 20px;
        overflow: hidden;
        margin: 17px 0 8px;
    }

    .progress > div {
        height: 100%;
        border-radius: 20px;
        background: linear-gradient(90deg, #2cc786, #46d29b);
    }

    .memory-foot {
        display: flex;
        justify-content: space-between;
        color: #61718a;
        font-size: 10px;
    }

    /* ---------- TABLE ---------- */
    .table-wrap {
        max-height: 270px;
        overflow: auto;
        border: 1px solid #e9edf3;
        border-radius: 9px;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        font-size: 11px;
    }

    th {
        position: sticky;
        top: 0;
        z-index: 2;
        background: #f5f7fa;
        color: #40516a;
        text-align: left;
        padding: 10px;
        font-size: 10px;
    }

    td {
        padding: 9px 10px;
        border-top: 1px solid #edf1f5;
        vertical-align: top;
    }

    td:first-child { font-family: Consolas, monospace; color: #263b59; }
    td:last-child { word-break: break-word; color: #61718a; }

    /* ---------- SESSION ---------- */
    .session-form {
        margin-top: 12px;
        padding: 12px;
        border-radius: 10px;
        background: linear-gradient(135deg, #f5f1ff, #faf8ff);
        border: 1px solid #e8ddff;
    }

    .session-form label {
        display: block;
        color: #5d32c9;
        font-size: 11px;
        font-weight: 850;
        margin-bottom: 8px;
    }

    .form-row {
        display: flex;
        gap: 8px;
    }

    input[type=text] {
        flex: 1;
        min-width: 0;
        border: 1px solid #ddd5f5;
        border-radius: 8px;
        padding: 10px 11px;
        outline: none;
        background: white;
        font-size: 11px;
    }

    input[type=text]:focus {
        border-color: #8b6de8;
        box-shadow: 0 0 0 3px rgba(115,87,232,.10);
    }

    button {
        border: 0;
        border-radius: 8px;
        background: linear-gradient(135deg, #7357e8, #5837d2);
        color: white;
        padding: 0 15px;
        font-weight: 800;
        cursor: pointer;
        box-shadow: 0 7px 15px rgba(93,57,210,.18);
    }

    button:hover { transform: translateY(-1px); }

    .session-result {
        margin-top: 9px;
        padding: 9px 11px;
        border-radius: 8px;
        background: #e7faef;
        color: #087c49;
        font-size: 10px;
        font-weight: 700;
    }

    /* ---------- LIFECYCLE ---------- */
    .lifecycle {
        display: grid;
        grid-template-columns: repeat(5, 1fr);
        gap: 9px;
        margin-top: 12px;
    }

    .life-step {
        position: relative;
        padding: 13px 11px;
        border: 1px solid #e6edf7;
        border-radius: 10px;
        background: #fbfcfe;
    }

    .life-step:not(:last-child):after {
        content: "→";
        position: absolute;
        right: -13px;
        top: 28px;
        color: #7ca9df;
        font-weight: 900;
        z-index: 3;
    }

    .life-num {
        width: 25px;
        height: 25px;
        display: grid;
        place-items: center;
        border-radius: 8px;
        background: #e7f2ff;
        color: #1677ff;
        font-size: 10px;
        font-weight: 900;
        margin-bottom: 8px;
    }

    .life-step strong {
        display: block;
        font-size: 11px;
        margin-bottom: 4px;
    }

    .life-step span {
        display: block;
        color: #74839a;
        font-size: 9px;
        line-height: 1.5;
    }

    .note {
        margin-top: 12px;
        padding: 10px 12px;
        background: #fff6e8;
        border: 1px solid #ffe3b4;
        color: #82550e;
        border-radius: 9px;
        font-size: 10px;
        line-height: 1.55;
    }

    .footer {
        margin-top: 20px;
        padding: 14px 4px;
        color: #7b899e;
        font-size: 10px;
        display: flex;
        justify-content: space-between;
        border-top: 1px solid #e3e8ef;
    }

    /* ---------- PROFILE MENU ---------- */
    .hero-actions {
        position: relative;
        z-index: 5;
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .profile-wrap {
        position: relative;
    }

    .profile-button {
        border: 1px solid rgba(145, 198, 255, .30);
        background: rgba(3, 18, 38, .42);
        color: white;
        min-height: 50px;
        padding: 6px 10px 6px 7px;
        border-radius: 13px;
        display: flex;
        align-items: center;
        gap: 9px;
        cursor: pointer;
        box-shadow: none;
        backdrop-filter: blur(10px);
        transition: .2s ease;
    }

    .profile-button:hover {
        transform: translateY(-1px);
        background: rgba(20, 55, 96, .62);
        box-shadow: 0 10px 25px rgba(0,0,0,.14);
    }

    .profile-avatar {
        width: 36px;
        height: 36px;
        border-radius: 11px;
        display: grid;
        place-items: center;
        background: linear-gradient(135deg, #4aa8ff, #1767e8);
        color: white;
        font-size: 12px;
        font-weight: 900;
        letter-spacing: .4px;
        box-shadow: 0 5px 15px rgba(25, 119, 255, .28);
    }

    .profile-avatar.large {
        width: 44px;
        height: 44px;
        border-radius: 13px;
        flex: 0 0 auto;
    }

    .profile-name {
        font-size: 11px;
        font-weight: 800;
        white-space: nowrap;
    }

    .profile-chevron {
        color: #a9c0dc;
        font-size: 15px;
        line-height: 1;
        margin-left: 1px;
    }

    .profile-menu {
        z-index: 9999;
        display: none;
        position: absolute;
        top: calc(100% + 10px);
        right: 0;
        width: 310px;
        background: white;
        color: var(--text);
        border: 1px solid #dfe7f2;
        border-radius: 15px;
        box-shadow: 0 20px 50px rgba(5, 24, 52, .25);
        padding: 15px;
        animation: profileIn .16s ease-out;
    }

    .profile-menu.show {
        display: block;
    }

    @keyframes profileIn {
        from { opacity: 0; transform: translateY(-5px) scale(.98); }
        to { opacity: 1; transform: translateY(0) scale(1); }
    }

    .profile-menu-head {
        display: flex;
        align-items: center;
        gap: 11px;
        padding: 2px 2px 5px;
    }

    .profile-fullname {
        color: #12233d;
        font-size: 14px;
        font-weight: 900;
    }

    .profile-role {
        color: #7b899d;
        font-size: 9px;
        margin-top: 4px;
    }

    .profile-divider {
        height: 1px;
        background: #edf1f6;
        margin: 12px 0 4px;
    }

    .profile-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 3px;
        border-bottom: 1px solid #f0f3f7;
    }

    .profile-item-icon {
        width: 31px;
        height: 31px;
        display: grid;
        place-items: center;
        border-radius: 9px;
        background: #edf5ff;
        color: #176fe7;
        font-size: 8px;
        font-weight: 900;
    }

    .profile-item small {
        display: block;
        color: #8491a4;
        font-size: 8px;
        font-weight: 700;
        margin-bottom: 3px;
    }

    .profile-item strong {
        display: block;
        color: #1d2e47;
        font-size: 10px;
        line-height: 1.35;
    }

    .profile-status {
        display: flex;
        align-items: center;
        gap: 7px;
        margin-top: 11px;
        padding: 8px 9px;
        border-radius: 8px;
        background: #effaf4;
        color: #087d49;
        font-size: 9px;
        font-weight: 800;
    }

    /* ---------- RESPONSIVE ---------- */
    @media (max-width: 1150px) {
        .kpis { grid-template-columns: repeat(3, 1fr); }
        .grid { grid-template-columns: 1fr 1fr; }
        .lifecycle { grid-template-columns: 1fr 1fr; }
        .life-step:not(:last-child):after { display: none; }
    }

    @media (max-width: 850px) {
        .sidebar {
            width: 70px;
            padding: 18px 8px;
        }
        .brand-title, .brand-sub, .nav-title, .nav a span:not(.nav-icon),
        .about-box, .side-footer { display: none; }
        .brand { justify-content: center; padding: 0 0 25px; }
        .nav a { justify-content: center; }
        .main { width: calc(100% - 70px); margin-left: 70px; }
        .hero { padding: 24px; }
        .hero-content { align-items: flex-start; }
        .hero-actions { align-items: flex-start; }
        .server-pill { display: none; }
        .profile-name { display: none; }
        .profile-menu { right: -5px; }
        .content { width: 92%; }
        .kpis, .grid { grid-template-columns: 1fr; }
        .card.full { grid-column: auto; }
    }

    @media (max-width: 520px) {
        .hero h1 { font-size: 23px; }
        .hero p { font-size: 11px; }
        .kpis { grid-template-columns: 1fr; }
        .row { grid-template-columns: 1fr; }
        .value { text-align: left; }
    }
</style>
</head>

<body>

<div class="app">

    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="brand">
            <div class="brand-icon">&lt;/&gt;</div>
            <div>
                <div class="brand-title">JSP <span>Inspector</span></div>
                <div class="brand-sub">UNDERSTAND • INSPECT • EXPLORE</div>
            </div>
        </div>

        <div class="nav-title">Monitoring</div>

        <nav class="nav">
            <a href="#top" class="active"><span class="nav-icon">⌂</span><span>Dashboard</span></a>
            <a href="#lifecycle"><span class="nav-icon">◈</span><span>JSP Lifecycle</span></a>
            <a href="#request"><span class="nav-icon">↗</span><span>Request Info</span></a>
            <a href="#response"><span class="nav-icon">◁</span><span>Response Info</span></a>
            <a href="#memory"><span class="nav-icon">▣</span><span>Memory Monitor</span></a>
            <a href="#session"><span class="nav-icon">♙</span><span>Session Management</span></a>
            <a href="#headers"><span class="nav-icon">▤</span><span>Request Headers</span></a>
        </nav>

        <div class="about-box">
            <h4>💡 About This Project</h4>
            <p>A single JSP page that inspects its own runtime details using JSP intrinsic objects and Java runtime information.</p>
        </div>

        <div class="side-footer">
            ◈ Built with JSP<br>
            ◈ Powered by Apache Tomcat
        </div>
    </aside>

    <!-- MAIN -->
    <main class="main" id="top">

        <header class="hero">
            <div class="hero-content">
                <div>
                    <h1>JSP Anatomy &amp; Lifecycle Inspector</h1>
                    <p>A real-time diagnostic dashboard built using JSP implicit objects</p>
                </div>

                <div class="hero-actions">
                    <div class="server-pill">
                        <div class="server-status">● Server Running</div>
                        <div class="server-time"><%= date(System.currentTimeMillis()) %></div>
                    </div>

                    <div class="profile-wrap">
                        <button type="button" class="profile-button" onclick="toggleProfile()" aria-label="Open student profile">
                            <span class="profile-avatar">RK</span>
                            <span class="profile-name">Rohit Kumar</span>
                            <span class="profile-chevron">⌄</span>
                        </button>

                        <div class="profile-menu" id="profileMenu">
                            <div class="profile-menu-head">
                                <div class="profile-avatar large">RK</div>
                                <div>
                                    <div class="profile-fullname">Rohit Kumar</div>
                                    <div class="profile-role">Student • Full Stack Technology</div>
                                </div>
                            </div>

                            <div class="profile-divider"></div>

                            <div class="profile-item">
                                <span class="profile-item-icon">ID</span>
                                <div>
                                    <small>Registration Number</small>
                                    <strong>251FD01047</strong>
                                </div>
                            </div>

                            <div class="profile-item">
                                <span class="profile-item-icon">⌘</span>
                                <div>
                                    <small>Project</small>
                                    <strong>JSP Anatomy &amp; Lifecycle Inspector</strong>
                                </div>
                            </div>

                            <div class="profile-status">
                                <span class="status-dot"></span>
                                Dashboard Session Active
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </header>

        <div class="content">

            <!-- KPI CARDS -->
            <section class="kpis">
                <div class="kpi">
                    <div class="kpi-icon">◷</div>
                    <div>
                        <div class="kpi-label">JVM UPTIME</div>
                        <div class="kpi-value"><%= uptimeSeconds %> seconds</div>
                    </div>
                </div>

                <div class="kpi">
                    <div class="kpi-icon">⚙</div>
                    <div>
                        <div class="kpi-label">USED MEMORY</div>
                        <div class="kpi-value"><%= bytes(usedMemory) %></div>
                    </div>
                </div>

                <div class="kpi">
                    <div class="kpi-icon">♙</div>
                    <div>
                        <div class="kpi-label">CURRENT SESSION</div>
                        <div class="kpi-value"><%= session.isNew() ? "New" : "Active" %></div>
                    </div>
                </div>

                <div class="kpi">
                    <div class="kpi-icon">▤</div>
                    <div>
                        <div class="kpi-label">TOTAL HEADERS</div>
                        <div class="kpi-value"><%= headers.size() %></div>
                    </div>
                </div>

                <div class="kpi">
                    <div class="kpi-icon">▣</div>
                    <div>
                        <div class="kpi-label">SERVER</div>
                        <div class="kpi-value"><%= esc(serverName) %>:<%= serverPort %></div>
                    </div>
                </div>
            </section>

            <!-- TOP DIAGNOSTIC CARDS -->
            <section class="grid">

                <article class="card" id="lifecycle">
                    <div class="card-head">
                        <div class="title-wrap">
                            <div class="section-icon">▱</div>
                            <h2>JSP Lifecycle / Runtime</h2>
                        </div>
                        <span class="tag">SELF INSPECTION</span>
                    </div>

                    <div class="row">
                        <div class="label">Servlet / JSP Name</div>
                        <div class="value"><%= esc(servletName) %></div>
                    </div>
                    <div class="row">
                        <div class="label">JVM Startup Time</div>
                        <div class="value"><%= date(startTime) %></div>
                    </div>
                    <div class="row">
                        <div class="label">JVM Uptime</div>
                        <div class="value"><%= uptimeSeconds %> seconds</div>
                    </div>
                    <div class="row">
                        <div class="label">PageContext Class</div>
                        <div class="value"><%= esc(pageContextClass) %></div>
                    </div>
                    <div class="row">
                        <div class="label">Current Status</div>
                        <div class="value">
                            <span class="status"><span class="status-dot"></span>JSP RUNNING</span>
                        </div>
                    </div>
                </article>

                <article class="card" id="request">
                    <div class="card-head">
                        <div class="title-wrap">
                            <div class="section-icon">➤</div>
                            <h2>Request Inspector</h2>
                        </div>
                        <span class="tag">REQUEST</span>
                    </div>

                    <div class="row">
                        <div class="label">HTTP Method</div>
                        <div class="value"><%= esc(request.getMethod()) %></div>
                    </div>
                    <div class="row">
                        <div class="label">Request URI</div>
                        <div class="value"><%= esc(requestUri) %></div>
                    </div>
                    <div class="row">
                        <div class="label">Protocol</div>
                        <div class="value"><%= esc(request.getProtocol()) %></div>
                    </div>
                    <div class="row">
                        <div class="label">Client IP</div>
                        <div class="value"><%= esc(clientIp) %></div>
                    </div>
                    <div class="row">
                        <div class="label">Server</div>
                        <div class="value"><%= esc(serverName) %>:<%= serverPort %></div>
                    </div>
                    <div class="row">
                        <div class="label">Context Path</div>
                        <div class="value"><%= esc(request.getContextPath()) %></div>
                    </div>
                </article>

                <article class="card" id="response">
                    <div class="card-head">
                        <div class="title-wrap">
                            <div class="section-icon" style="background:#ffe9f3;color:#d43b7d;">➤</div>
                            <h2>Response Inspector</h2>
                        </div>
                        <span class="tag">RESPONSE</span>
                    </div>

                    <div class="row">
                        <div class="label">Content Type</div>
                        <div class="value"><%= esc(responseType) %></div>
                    </div>
                    <div class="row">
                        <div class="label">Buffer Size</div>
                        <div class="value"><%= response.getBufferSize() %> bytes</div>
                    </div>
                    <div class="row">
                        <div class="label">Response Committed?</div>
                        <div class="value"><%= response.isCommitted() ? "YES" : "NO" %></div>
                    </div>
                    <div class="row">
                        <div class="label">Character Encoding</div>
                        <div class="value"><%= esc(encoding) %></div>
                    </div>
                    <div class="row">
                        <div class="label">HTTP Status</div>
                        <div class="value">200 (Normal)</div>
                    </div>

                    <div class="note">
                        <strong>ⓘ Response object:</strong> used by the JSP container to construct and send the HTTP response back to the browser.
                    </div>
                </article>

                <!-- MEMORY -->
                <article class="card" id="memory">
                    <div class="card-head">
                        <div class="title-wrap">
                            <div class="section-icon" style="background:#e3f9ed;color:#079653;">▣</div>
                            <h2>Memory Monitor</h2>
                        </div>
                        <span class="tag">JVM</span>
                    </div>

                    <div class="memory-stat"><span>Used Memory</span><strong><%= bytes(usedMemory) %></strong></div>
                    <div class="memory-stat"><span>Free Memory</span><strong><%= bytes(freeMemory) %></strong></div>
                    <div class="memory-stat"><span>Allocated Memory</span><strong><%= bytes(allocatedMemory) %></strong></div>
                    <div class="memory-stat"><span>Maximum Memory</span><strong><%= bytes(maxMemory) %></strong></div>

                    <div class="progress">
                        <div style="width:<%= Math.min(100, memoryOfAllocated) %>%"></div>
                    </div>

                    <div class="memory-foot">
                        <span>Memory Usage: <strong><%= String.format("%.2f", memoryOfAllocated) %>%</strong></span>
                        <span>Used / Max: <strong><%= String.format("%.2f", memoryOfMax) %>%</strong></span>
                    </div>
                </article>

                <!-- SESSION -->
                <article class="card" id="session">
                    <div class="card-head">
                        <div class="title-wrap">
                            <div class="section-icon" style="background:#eee8ff;color:#7357e8;">♙</div>
                            <h2>Session Inspector</h2>
                        </div>
                        <span class="tag">SESSION</span>
                    </div>

                    <div class="row">
                        <div class="label">Session ID</div>
                        <div class="value"><%= esc(sessionId) %></div>
                    </div>
                    <div class="row">
                        <div class="label">Creation Time</div>
                        <div class="value"><%= date(sessionCreated) %></div>
                    </div>
                    <div class="row">
                        <div class="label">Last Accessed</div>
                        <div class="value"><%= date(sessionLastAccessed) %></div>
                    </div>
                    <div class="row">
                        <div class="label">Max Inactive Interval</div>
                        <div class="value"><%= inactiveInterval %> seconds</div>
                    </div>

                    <div class="session-form">
                        <label>Set a Session Parameter</label>
                        <form method="post" action="<%= esc(requestUri) %>">
                            <div class="form-row">
                                <input type="text" name="sessionValue" placeholder="Enter parameter value">
                                <button type="submit">▣ Save</button>
                            </div>
                        </form>

                        <div class="session-result">
                            ● Current session parameter:
                            <%= demoParameter == null ? "Not Set" : esc(String.valueOf(demoParameter)) %>
                        </div>
                    </div>
                </article>

                <!-- HEADERS -->
                <article class="card" id="headers">
                    <div class="card-head">
                        <div class="title-wrap">
                            <div class="section-icon" style="background:#fff0dc;color:#d9790b;">▤</div>
                            <h2>Request Headers</h2>
                        </div>
                        <span class="tag"><%= headers.size() %> HEADERS</span>
                    </div>

                    <div class="table-wrap">
                        <table>
                            <thead>
                                <tr>
                                    <th style="width:7%;">#</th>
                                    <th style="width:27%;">Header Name</th>
                                    <th>Header Value</th>
                                </tr>
                            </thead>
                            <tbody>
                            <%
                                int counter = 1;
                                if (headers.isEmpty()) {
                            %>
                                <tr><td colspan="3">No request headers available.</td></tr>
                            <%
                                } else {
                                    for (Map.Entry<String, String> entry : headers.entrySet()) {
                            %>
                                <tr>
                                    <td><%= counter++ %></td>
                                    <td><%= esc(entry.getKey()) %></td>
                                    <td><%= esc(entry.getValue()) %></td>
                                </tr>
                            <%
                                    }
                                }
                            %>
                            </tbody>
                        </table>
                    </div>
                </article>

                <!-- LIFECYCLE EXPLANATION -->
                <article class="card full">
                    <div class="card-head">
                        <div class="title-wrap">
                            <div class="section-icon">◈</div>
                            <h2>JSP Processing Cycle</h2>
                        </div>
                        <span class="tag">HOW JSP WORKS</span>
                    </div>

                    <div class="lifecycle">
                        <div class="life-step">
                            <div class="life-num">01</div>
                            <strong>Request</strong>
                            <span>Browser requests the JSP page from Tomcat.</span>
                        </div>
                        <div class="life-step">
                            <div class="life-num">02</div>
                            <strong>Translation</strong>
                            <span>JSP is translated into a Java servlet.</span>
                        </div>
                        <div class="life-step">
                            <div class="life-num">03</div>
                            <strong>Compilation</strong>
                            <span>The generated servlet is compiled into bytecode.</span>
                        </div>
                        <div class="life-step">
                            <div class="life-num">04</div>
                            <strong>Execution</strong>
                            <span>The servlet executes and reads JSP runtime objects.</span>
                        </div>
                        <div class="life-step">
                            <div class="life-num">05</div>
                            <strong>Response</strong>
                            <span>HTML is returned to the browser and rendered.</span>
                        </div>
                    </div>

                    <div class="note">
                        <strong>Why this dashboard is useful:</strong>
                        it makes the normally invisible JSP processing/runtime information visible on one page. The dashboard itself is implemented in a single JSP file.
                    </div>
                </article>

                <!-- IMPLICIT OBJECTS -->
                <article class="card full">
                    <div class="card-head">
                        <div class="title-wrap">
                            <div class="section-icon">◆</div>
                            <h2>JSP Implicit Objects Used</h2>
                        </div>
                        <span class="tag">CORE CONCEPT</span>
                    </div>

                    <div class="table-wrap">
                        <table>
                            <thead>
                                <tr>
                                    <th>Implicit Object</th>
                                    <th>How this dashboard uses it</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>request</td>
                                    <td>Reads HTTP method, URI, protocol, client IP, server details and request headers.</td>
                                </tr>
                                <tr>
                                    <td>response</td>
                                    <td>Reads content type, character encoding, buffer size and committed state.</td>
                                </tr>
                                <tr>
                                    <td>config</td>
                                    <td>Reads the servlet name/configuration associated with the JSP.</td>
                                </tr>
                                <tr>
                                    <td>pageContext</td>
                                    <td>Inspects the runtime PageContext implementation for the current JSP page.</td>
                                </tr>
                                <tr>
                                    <td>session</td>
                                    <td>Reads session information and stores an interactive session parameter.</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </article>

            </section>

            <footer class="footer">
                <span>◈ Apache Tomcat &nbsp; | &nbsp; JSP Anatomy &amp; Lifecycle Inspector &nbsp; | &nbsp; Built with JSP</span>
                <span>“A small page, a big insight into JSP internals.”</span>
            </footer>

        </div>
    </main>
</div>


<script>
    function toggleProfile() {
        document.getElementById("profileMenu").classList.toggle("show");
    }

    document.addEventListener("click", function(event) {
        var wrap = document.querySelector(".profile-wrap");
        var menu = document.getElementById("profileMenu");

        if (wrap && menu && !wrap.contains(event.target)) {
            menu.classList.remove("show");
        }
    });
</script>

</body>
</html>

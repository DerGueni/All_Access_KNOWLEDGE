# MCP Server Übersicht - CONSYS Projekt
## Stand: 19.01.2026

---

## ✅ Installierte MCP-Server

### Claude Desktop (`claude_desktop_config.json`)

| Server | Status | Zweck |
|--------|--------|-------|
| **filesystem** | ✅ Aktiv | Dateizugriff (Docs, C:\) |
| **filesystem-access** | ✅ Aktiv | Erweiterter Dateizugriff |
| **memory** | ✅ Aktiv | Persistenter Kontext |
| **brave-search** | ✅ Aktiv | Web-Suche |
| **context7** | ✅ Aktiv | Library-Dokumentation |
| **web-automation** | ✅ Aktiv | Puppeteer Browser-Tests |
| **n8n-mcp** | ✅ Aktiv | Workflow-Automation |
| **sequential-thinking** | ✅ Aktiv | Komplexe Problemlösung |
| **magic** | ✅ Aktiv | 21st.dev UI-Komponenten |
| **chrome-devtools** | ✅ Aktiv | Browser-Debugging |
| **playwright** | ✅ NEU | Multi-Browser-Tests |
| **github** | ✅ NEU | GitHub-Integration |
| **sqlite** | ✅ NEU | SQLite-Datenbank |
| **fetch** | ✅ NEU | HTTP-Requests |
| **everything** | ✅ NEU | Meta-Server |

### Claude Code CLI (`~/.claude/settings.json`)

| Server | Status | Zweck |
|--------|--------|-------|
| **filesystem** | ✅ Aktiv | Dateizugriff |
| **memory** | ✅ Aktiv | Persistenter Kontext |
| **sqlite** | ✅ Aktiv | SQLite-Datenbank |
| **fetch** | ✅ Aktiv | HTTP-Requests |
| **github** | ✅ Aktiv | GitHub-Integration |
| **playwright** | ✅ Aktiv | Multi-Browser-Tests |
| **chrome-devtools** | ✅ Aktiv | Browser-Debugging |
| **sequential-thinking** | ✅ Aktiv | Komplexe Problemlösung |
| **context7** | ✅ Aktiv | Library-Dokumentation |
| **brave-search** | ✅ Aktiv | Web-Suche |

---

## 📦 Zusätzlich installiert

### Python Libraries
- **py-healthcheck** - Flask Health-Check Endpoints
- **psutil** (optional) - System-Monitoring

### Dateien erstellt
- `mcp_tools/install_mcp_servers.bat` - Installations-Skript
- `mcp_tools/flask_healthcheck_template.py` - Flask Health-Check Template
- `mcp_tools/TOKEN_OPTIMIERUNG_GUIDE.md` - Token-Spar-Anleitung

---

## 🚀 Nächste Schritte

1. **Claude Desktop neu starten** (Pflicht!)
2. **Installations-Skript ausführen:** `install_mcp_servers.bat`
3. **GitHub Token eintragen** (optional, für GitHub MCP)

---

## 🔧 Konfigurationspfade

```
Claude Desktop:
C:\Users\guenther.siegert\AppData\Roaming\Claude\claude_desktop_config.json

Claude Code CLI:
C:\Users\guenther.siegert\.claude\settings.json
```

---

## 📋 MCP-Befehle (Claude Code CLI)

```bash
# Server auflisten
claude mcp list

# Server-Details
claude mcp get <servername>

# Server hinzufügen
claude mcp add <name> -- npx -y @package/name

# Server entfernen
claude mcp remove <name>

# Status prüfen (in Session)
/mcp
```

---

## ⚠️ Hinweise

- **Token-Verbrauch:** Jeder aktive MCP-Server verbraucht ~200-500 Token
- **Deaktivieren:** `/mcp disable <server>` wenn nicht benötigt
- **GitHub Token:** Für GitHub MCP muss `GITHUB_PERSONAL_ACCESS_TOKEN` gesetzt werden
- **SQLite Pfad:** Zeigt auf `consys.db` (wird bei Bedarf erstellt)

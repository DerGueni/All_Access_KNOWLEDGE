@echo off
REM ═══════════════════════════════════════════════════════════════
REM   ACCESS BRIDGE MCP SERVER - INSTALLATION FÜR CLAUDE CODE
REM ═══════════════════════════════════════════════════════════════

echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║  ACCESS BRIDGE MCP SERVER - Claude Code Installation      ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.

cd /d "%~dp0"

REM Node.js prüfen
echo [1/3] Prüfe Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo FEHLER: Node.js nicht gefunden!
    echo Bitte installieren: https://nodejs.org/
    pause
    exit /b 1
)
echo OK - Node.js gefunden

REM Dependencies installieren
echo.
echo [2/3] Installiere Dependencies...
call npm install
if errorlevel 1 (
    echo FEHLER bei npm install!
    pause
    exit /b 1
)
echo OK - Dependencies installiert

REM Claude Code MCP hinzufügen
echo.
echo [3/3] Registriere MCP Server in Claude Code...

set "MCP_PATH=%~dp0index.js"

REM Versuche via CLI zu registrieren
claude mcp add access-bridge node "%MCP_PATH%" 2>nul
if errorlevel 1 (
    echo.
    echo CLI-Registrierung nicht möglich. Manuelle Konfiguration:
    echo.
    echo Öffne: %USERPROFILE%\.claude\settings.json
    echo.
    echo Füge unter "mcpServers" hinzu:
    echo.
    echo   "access-bridge": {
    echo     "command": "node",
    echo     "args": ["%MCP_PATH:\=\\%"]
    echo   }
    echo.
) else (
    echo OK - MCP Server registriert
)

echo.
echo ═══════════════════════════════════════════════════════════════
echo   INSTALLATION ABGESCHLOSSEN
echo ═══════════════════════════════════════════════════════════════
echo.
echo Nächste Schritte:
echo   1. Access Frontend öffnen (falls nicht offen)
echo   2. Claude Code neu starten
echo   3. MCP Tools sollten verfügbar sein (access_*)
echo.
pause

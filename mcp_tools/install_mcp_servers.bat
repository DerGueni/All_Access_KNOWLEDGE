@echo off
REM ============================================
REM MCP Server Installation Script für CONSYS
REM ============================================

echo.
echo ========================================
echo   MCP Server Installation für CONSYS
echo ========================================
echo.

REM Prüfe Node.js
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [FEHLER] Node.js nicht gefunden! Bitte installieren: https://nodejs.org
    pause
    exit /b 1
)

echo [OK] Node.js gefunden
node --version

echo.
echo [1/8] Installiere Playwright MCP...
call npx -y @anthropic-ai/mcp-server-playwright --version 2>nul || echo Playwright wird beim ersten Aufruf installiert

echo.
echo [2/8] Installiere SQLite MCP...
call npx -y @modelcontextprotocol/server-sqlite --help 2>nul || echo SQLite wird beim ersten Aufruf installiert

echo.
echo [3/8] Installiere Fetch MCP...
call npx -y @modelcontextprotocol/server-fetch --help 2>nul || echo Fetch wird beim ersten Aufruf installiert

echo.
echo [4/8] Installiere GitHub MCP...
call npx -y @modelcontextprotocol/server-github --help 2>nul || echo GitHub wird beim ersten Aufruf installiert

echo.
echo [5/8] Installiere Sequential Thinking MCP...
call npx -y @modelcontextprotocol/server-sequential-thinking --help 2>nul || echo Sequential Thinking wird beim ersten Aufruf installiert

echo.
echo [6/8] Installiere Context7 MCP...
call npx -y @upstash/context7-mcp --help 2>nul || echo Context7 wird beim ersten Aufruf installiert

echo.
echo [7/8] Installiere Chrome DevTools MCP...
call npx -y chrome-devtools-mcp@latest --help 2>nul || echo Chrome DevTools wird beim ersten Aufruf installiert

echo.
echo [8/8] Installiere Everything MCP...
call npx -y @modelcontextprotocol/server-everything --help 2>nul || echo Everything wird beim ersten Aufruf installiert

echo.
echo ========================================
echo   Python Health-Check Library
echo ========================================
echo.

REM Prüfe Python
where python >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNUNG] Python nicht gefunden - Health-Check Library wird übersprungen
) else (
    echo [OK] Python gefunden
    python --version
    echo.
    echo Installiere py-healthcheck...
    pip install py-healthcheck --quiet
    echo [OK] py-healthcheck installiert
)

echo.
echo ========================================
echo   INSTALLATION ABGESCHLOSSEN
echo ========================================
echo.
echo Bitte Claude Desktop neu starten!
echo.
pause

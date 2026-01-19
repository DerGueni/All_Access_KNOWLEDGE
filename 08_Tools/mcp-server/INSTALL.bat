@echo off
REM ═══════════════════════════════════════════════════════════════
REM   ACCESS BRIDGE MCP SERVER - INSTALLATION
REM ═══════════════════════════════════════════════════════════════

echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║  ACCESS BRIDGE MCP SERVER - Installation                  ║
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

REM Claude Desktop Config
echo.
echo [3/3] Claude Desktop Konfiguration...
set "CONFIG_PATH=%APPDATA%\Claude\claude_desktop_config.json"
set "MCP_PATH=%~dp0index.js"

if not exist "%APPDATA%\Claude" (
    mkdir "%APPDATA%\Claude"
)

REM Prüfe ob Config existiert
if exist "%CONFIG_PATH%" (
    echo.
    echo HINWEIS: %CONFIG_PATH% existiert bereits.
    echo Bitte füge manuell folgenden Eintrag unter "mcpServers" hinzu:
    echo.
    echo   "access-bridge": {
    echo     "command": "node",
    echo     "args": ["%MCP_PATH:\=\\%"]
    echo   }
    echo.
) else (
    REM Erstelle neue Config
    echo {> "%CONFIG_PATH%"
    echo   "mcpServers": {>> "%CONFIG_PATH%"
    echo     "access-bridge": {>> "%CONFIG_PATH%"
    echo       "command": "node",>> "%CONFIG_PATH%"
    echo       "args": ["%MCP_PATH:\=\\%"]>> "%CONFIG_PATH%"
    echo     }>> "%CONFIG_PATH%"
    echo   }>> "%CONFIG_PATH%"
    echo }>> "%CONFIG_PATH%"
    echo OK - Konfiguration erstellt: %CONFIG_PATH%
)

echo.
echo ═══════════════════════════════════════════════════════════════
echo   INSTALLATION ABGESCHLOSSEN
echo ═══════════════════════════════════════════════════════════════
echo.
echo Nächste Schritte:
echo   1. Claude Desktop KOMPLETT schließen
echo   2. Access Frontend öffnen (falls nicht offen)
echo   3. Claude Desktop neu starten
echo   4. In Claude fragen: "Teste die Access-Verbindung"
echo.
pause

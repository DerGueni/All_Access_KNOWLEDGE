@echo off
REM ============================================================================
REM WebView2 Access Integration - Installationsskript
REM ============================================================================
REM Fuehrt alle Installationsschritte auf einem Arbeitsplatz aus.
REM Als Administrator ausfuehren!
REM ============================================================================

echo.
echo ============================================================
echo  WebView2 Access Integration - Installation
echo ============================================================
echo.

REM Pruefe Admin-Rechte
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo FEHLER: Bitte als Administrator ausfuehren!
    pause
    exit /b 1
)

set INSTALL_DIR=C:\ProgramData\Consys\WebView2
set SOURCE_DIR=%~dp0..

REM ----------------------------------------------------------------------------
REM 1. Ordnerstruktur erstellen
REM ----------------------------------------------------------------------------
echo [1/6] Erstelle Ordnerstruktur...

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if not exist "%INSTALL_DIR%\API" mkdir "%INSTALL_DIR%\API"
if not exist "%INSTALL_DIR%\COM" mkdir "%INSTALL_DIR%\COM"
if not exist "%INSTALL_DIR%\Logs" mkdir "%INSTALL_DIR%\Logs"

REM ----------------------------------------------------------------------------
REM 2. WebView2 Runtime pruefen/installieren
REM ----------------------------------------------------------------------------
echo [2/6] Pruefe WebView2 Runtime...

reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" >nul 2>&1
if %errorLevel% neq 0 (
    echo WebView2 Runtime nicht gefunden. Starte Download...
    echo Bitte WebView2 Runtime manuell installieren von:
    echo https://developer.microsoft.com/en-us/microsoft-edge/webview2/
    echo.
    start "" "https://go.microsoft.com/fwlink/p/?LinkId=2124703"
    echo Druecken Sie eine Taste nach der Installation...
    pause
) else (
    echo WebView2 Runtime bereits installiert.
)

REM ----------------------------------------------------------------------------
REM 3. Python-Pakete installieren
REM ----------------------------------------------------------------------------
echo [3/6] Installiere Python-Pakete...

pip install flask flask-cors pyodbc --quiet
if %errorLevel% neq 0 (
    echo WARNUNG: Python-Pakete konnten nicht installiert werden.
    echo Bitte manuell: pip install flask flask-cors pyodbc
)

REM ----------------------------------------------------------------------------
REM 4. Dateien kopieren
REM ----------------------------------------------------------------------------
echo [4/6] Kopiere Dateien...

xcopy /Y /Q "%SOURCE_DIR%\API\*.*" "%INSTALL_DIR%\API\"

REM ----------------------------------------------------------------------------
REM 5. COM-Komponente registrieren (optional)
REM ----------------------------------------------------------------------------
echo [5/6] COM-Registrierung (optional)...

if exist "%SOURCE_DIR%\COM_Wrapper\bin\x64\Release\ConsysWebView2Host.dll" (
    echo Registriere COM-Komponente...
    regasm /codebase "%SOURCE_DIR%\COM_Wrapper\bin\x64\Release\ConsysWebView2Host.dll"
) else (
    echo COM-DLL nicht gefunden - uebersprungen.
    echo Browser-Modus wird verwendet (empfohlen).
)

REM ----------------------------------------------------------------------------
REM 6. Startskript erstellen
REM ----------------------------------------------------------------------------
echo [6/6] Erstelle Startskript...

echo @echo off > "%INSTALL_DIR%\start_server.bat"
echo cd /d "%INSTALL_DIR%\API" >> "%INSTALL_DIR%\start_server.bat"
echo python api_server_wv2.py >> "%INSTALL_DIR%\start_server.bat"

echo @echo off > "%INSTALL_DIR%\stop_server.bat"
echo taskkill /F /IM python.exe /FI "WINDOWTITLE eq *api_server*" >> "%INSTALL_DIR%\stop_server.bat"

REM ----------------------------------------------------------------------------
REM Fertig
REM ----------------------------------------------------------------------------
echo.
echo ============================================================
echo  Installation abgeschlossen!
echo ============================================================
echo.
echo Installationsverzeichnis: %INSTALL_DIR%
echo.
echo Naechste Schritte:
echo 1. VBA-Modul mod_N_WebView2.bas in Access importieren
echo 2. Server starten: WV2_StartServer oder %INSTALL_DIR%\start_server.bat
echo 3. Test: WV2_Test im Direktfenster ausfuehren
echo.
pause

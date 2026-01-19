@echo off
REM ============================================================================
REM Prueft alle Voraussetzungen fuer die WebView2 Access Integration
REM ============================================================================

echo.
echo ============================================================
echo  Voraussetzungen pruefen
echo ============================================================
echo.

set ERRORS=0

REM ----------------------------------------------------------------------------
REM 1. Access 2021 64-Bit
REM ----------------------------------------------------------------------------
echo [1] Microsoft Access...
reg query "HKLM\SOFTWARE\Microsoft\Office\16.0\Access\InstallRoot" >nul 2>&1
if %errorLevel% equ 0 (
    echo     OK: Access gefunden
) else (
    echo     FEHLER: Access nicht gefunden
    set /a ERRORS+=1
)

REM Bitness pruefen
reg query "HKLM\SOFTWARE\Microsoft\Office\16.0\Outlook" /v Bitness 2>nul | findstr "x64" >nul
if %errorLevel% equ 0 (
    echo     OK: 64-Bit Office
) else (
    echo     WARNUNG: 64-Bit Status unklar
)

REM ----------------------------------------------------------------------------
REM 2. Python
REM ----------------------------------------------------------------------------
echo [2] Python...
python --version >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=2" %%i in ('python --version 2^>^&1') do echo     OK: Python %%i
) else (
    echo     FEHLER: Python nicht gefunden
    set /a ERRORS+=1
)

REM ----------------------------------------------------------------------------
REM 3. Python-Pakete
REM ----------------------------------------------------------------------------
echo [3] Python-Pakete...
python -c "import flask" >nul 2>&1
if %errorLevel% equ 0 (
    echo     OK: Flask
) else (
    echo     FEHLT: Flask (pip install flask)
    set /a ERRORS+=1
)

python -c "import flask_cors" >nul 2>&1
if %errorLevel% equ 0 (
    echo     OK: Flask-CORS
) else (
    echo     FEHLT: Flask-CORS (pip install flask-cors)
    set /a ERRORS+=1
)

python -c "import pyodbc" >nul 2>&1
if %errorLevel% equ 0 (
    echo     OK: pyodbc
) else (
    echo     FEHLT: pyodbc (pip install pyodbc)
    set /a ERRORS+=1
)

REM ----------------------------------------------------------------------------
REM 4. Access Database Engine (ACE)
REM ----------------------------------------------------------------------------
echo [4] Microsoft ACE OLEDB...
reg query "HKLM\SOFTWARE\Microsoft\Office\16.0\Access Connectivity Engine\Engines\ACE" >nul 2>&1
if %errorLevel% equ 0 (
    echo     OK: ACE 64-Bit
) else (
    reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Office\16.0\Access Connectivity Engine" >nul 2>&1
    if %errorLevel% equ 0 (
        echo     WARNUNG: ACE 32-Bit (64-Bit benoetigt)
        set /a ERRORS+=1
    ) else (
        echo     FEHLER: ACE nicht gefunden
        set /a ERRORS+=1
    )
)

REM ----------------------------------------------------------------------------
REM 5. WebView2 Runtime
REM ----------------------------------------------------------------------------
echo [5] WebView2 Runtime...
reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" >nul 2>&1
if %errorLevel% equ 0 (
    echo     OK: WebView2 Runtime installiert
) else (
    echo     FEHLT: WebView2 Runtime
    echo           Download: https://developer.microsoft.com/microsoft-edge/webview2/
    set /a ERRORS+=1
)

REM ----------------------------------------------------------------------------
REM 6. Backend-Zugriff
REM ----------------------------------------------------------------------------
echo [6] Backend-Zugriff...
set BACKEND_PATH=\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\Consec_BE_V1.55ANALYSETEST.accdb
if exist "%BACKEND_PATH%" (
    echo     OK: Backend erreichbar
) else (
    echo     FEHLER: Backend nicht erreichbar
    echo           Pfad: %BACKEND_PATH%
    set /a ERRORS+=1
)

REM ----------------------------------------------------------------------------
REM Zusammenfassung
REM ----------------------------------------------------------------------------
echo.
echo ============================================================
if %ERRORS% equ 0 (
    echo  ALLE VORAUSSETZUNGEN ERFUELLT
    echo  Installation kann gestartet werden.
) else (
    echo  %ERRORS% FEHLER GEFUNDEN
    echo  Bitte beheben Sie die Fehler vor der Installation.
)
echo ============================================================
echo.
pause

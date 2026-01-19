@echo off
REM ========================================
REM COM-Registrierung für ConsysWebView2.dll
REM MUSS ALS ADMINISTRATOR AUSGEFÜHRT WERDEN!
REM ========================================

echo.
echo ========================================
echo ConsysWebView2 COM Registrierung
echo ========================================
echo.

REM Prüfen ob Admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo FEHLER: Dieses Script muss als Administrator ausgefuehrt werden!
    echo Rechtsklick auf die Datei ^> "Als Administrator ausfuehren"
    pause
    exit /b 1
)

set DLL_PATH=%~dp0bin\Release\net48\ConsysWebView2.dll

echo DLL-Pfad: %DLL_PATH%
echo.

if not exist "%DLL_PATH%" (
    echo FEHLER: DLL nicht gefunden!
    echo Bitte zuerst das Projekt kompilieren.
    pause
    exit /b 1
)

echo Registriere COM-Komponente...
echo.

REM 64-Bit RegAsm verwenden (fuer Office 64-Bit)
set REGASM=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\RegAsm.exe

if not exist "%REGASM%" (
    echo FEHLER: RegAsm nicht gefunden unter %REGASM%
    pause
    exit /b 1
)

echo Verwende: %REGASM%
echo.

"%REGASM%" "%DLL_PATH%" /codebase /tlb

if %errorLevel% equ 0 (
    echo.
    echo ========================================
    echo ERFOLG! COM-Komponente registriert.
    echo ========================================
    echo.
    echo ProgIDs:
    echo   - Consys.WebView2Host
    echo   - ConsysWebView2.WebFormHost
    echo.
    echo Verwendung in VBA:
    echo   Dim host As Object
    echo   Set host = CreateObject("Consys.WebView2Host")
    echo.
) else (
    echo.
    echo FEHLER bei der Registrierung!
    echo Exitcode: %errorLevel%
)

pause

@echo off
setlocal

set "WORKDIR=C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\electron_auftragstamm"
set "PATH=C:\Program Files\nodejs;%PATH%"

cd /d "%WORKDIR%"

echo ========================================
echo CONSYS Electron App - Installation
echo ========================================
echo.

echo Node Version:
call node --version
echo.

echo NPM Version:
call npm --version
echo.

echo Loesche alte node_modules...
if exist node_modules rmdir /s /q node_modules
if exist package-lock.json del package-lock.json

echo.
echo Starte npm install...
echo.

call npm install

echo.
echo ========================================
echo Installation abgeschlossen!
echo ========================================

if exist node_modules\electron (
    echo Electron erfolgreich installiert!
) else (
    echo FEHLER: Electron wurde nicht installiert!
)

echo.
pause

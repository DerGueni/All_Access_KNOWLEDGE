@echo off
cd /d "%~dp0"
echo [*] Starte API Server...
start "CONSYS API" python api_server_robust.py
timeout /t 3 /nobreak
echo [*] Öffne Browser...
start http://localhost:5000/shell.html

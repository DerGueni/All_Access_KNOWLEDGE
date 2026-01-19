@echo off
REM ═══════════════════════════════════════════════════════════════
REM   ACCESS BRIDGE MCP SERVER - TEST
REM ═══════════════════════════════════════════════════════════════

echo.
echo Teste MCP Server (Ctrl+C zum Beenden)...
echo.

cd /d "%~dp0"
node index.js

pause

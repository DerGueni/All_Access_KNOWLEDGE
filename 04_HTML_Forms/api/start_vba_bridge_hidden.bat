@echo off
REM VBA Bridge Server UNSICHTBAR starten auf Port 5002
REM Verwendet pythonw (windowless) für unsichtbaren Betrieb

cd /d "%~dp0"
start /min pythonw vba_bridge_server.py

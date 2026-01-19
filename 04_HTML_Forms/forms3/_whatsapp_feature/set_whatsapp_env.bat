@echo off
REM ============================================
REM WhatsApp Business API Umgebungsvariablen
REM ============================================
REM Diese Datei vor dem Start des API-Servers ausführen
REM oder die Werte in die Systemumgebungsvariablen eintragen.
REM
REM WICHTIG: Die Werte müssen aus dem Meta Business Manager kommen!
REM https://business.facebook.com/
REM ============================================

REM Phone Number ID aus Meta Business Manager
REM (Unter WhatsApp > Phone Numbers > Nummer auswählen > Phone Number ID)
set WA_PHONE_NUMBER_ID=HIER_PHONE_NUMBER_ID_EINTRAGEN

REM Access Token aus Meta Business Manager
REM (Unter WhatsApp > Configuration > Temporary Access Token)
REM ACHTUNG: Temporary Tokens laufen nach 24h ab! Für Produktion: Permanent Token erstellen
set WA_ACCESS_TOKEN=HIER_ACCESS_TOKEN_EINTRAGEN

echo.
echo WhatsApp-Umgebungsvariablen gesetzt:
echo   WA_PHONE_NUMBER_ID = %WA_PHONE_NUMBER_ID%
echo   WA_ACCESS_TOKEN    = %WA_ACCESS_TOKEN:~0,20%...
echo.
echo Starte jetzt den API-Server...
echo.

cd /d "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py

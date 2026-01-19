@echo off
chcp 65001 >nul
cls

echo ╔════════════════════════════════════════════════════════════════╗
echo ║  AUTO CLAUDE - btnMail Implementierung                        ║
echo ║  Mehrphasen-Ausfuehrung                                       ║
echo ╠════════════════════════════════════════════════════════════════╣
echo ║  Phase 2: UI Modal fuer Anfrage-Log                           ║
echo ║  Phase 3: Daten-Vorbereitung (Texte laden)                    ║
echo ║  Phase 4: MD5-Hash und URL-Generierung                        ║
echo ║  Phase 5: E-Mail-Body-Generierung                             ║
echo ║  Phase 6: E-Mail-Versand (mailto Fallback)                    ║
echo ║  Phase 7: Status-Update in Datenbank                          ║
echo ║  Phase 8: Hauptfunktion zusammenfuehren                       ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo HINWEIS: Jede Phase erstellt einen Spec, wartet auf Approval,
echo          und fuehrt dann den Build aus.
echo.
echo Druecken Sie eine Taste um zu starten...
pause >nul

echo.
echo ========================================
echo Starte Phase 2...
echo ========================================
call "%~dp0run_phase2.bat"

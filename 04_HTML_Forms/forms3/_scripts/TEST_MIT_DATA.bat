@echo off
echo Teste WebView2 mit -data Parameter...
echo.

set EXE="C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\WebView2_Access\COM_Wrapper\ConsysWebView2App\bin\Release\ConsysWebView2App.exe"
set HTML="C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\shell.html"

echo Starte: %EXE%
echo HTML: %HTML%
echo Data: {\"form\":\"frm_va_Auftragstamm\"}
echo.

%EXE% -html %HTML% -title "Auftragsverwaltung Test" -width 1400 -height 900 -data "{\"form\":\"frm_va_Auftragstamm\"}"

echo.
echo Fertig.
pause

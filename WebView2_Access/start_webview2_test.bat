@echo off
echo === ConsysWebView2 Test ===
echo.

set EXE=C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\WebView2_Access\COM_Wrapper\ConsysWebView2App\bin\Release\ConsysWebView2App.exe
set HTML=C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\webview2_test.html

echo Starte WebView2...
"%EXE%" -html "%HTML%" -title "WebView2 Test" -width 1000 -height 700 -data "{\"test\":\"Hallo\"}"

echo.
echo Fertig.
pause

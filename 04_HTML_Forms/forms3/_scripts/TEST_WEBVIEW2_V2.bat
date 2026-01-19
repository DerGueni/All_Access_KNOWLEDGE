@echo off
echo === Test 1: Mit Backslashes (Windows-Pfad) ===
start "" "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\WebView2_Access\COM_Wrapper\ConsysWebView2App\bin\Release\ConsysWebView2App.exe" -html "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\shell.html" -title "Test1-Backslash" -width 800 -height 600
timeout /t 3

echo === Test 2: Mit Forward-Slashes ===
start "" "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\WebView2_Access\COM_Wrapper\ConsysWebView2App\bin\Release\ConsysWebView2App.exe" -html "C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms3/shell.html" -title "Test2-ForwardSlash" -width 800 -height 600
timeout /t 3

echo === Test 3: file:// URL ===
start "" "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\WebView2_Access\COM_Wrapper\ConsysWebView2App\bin\Release\ConsysWebView2App.exe" -html "file:///C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms3/shell.html" -title "Test3-FileURL" -width 800 -height 600

echo.
echo 3 Fenster sollten sich oeffnen. Welches zeigt den Inhalt korrekt an?
pause

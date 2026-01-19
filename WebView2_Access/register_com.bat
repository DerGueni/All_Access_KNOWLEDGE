@echo off
echo ============================================
echo WebView2 COM-Wrapper Registrierung
echo ============================================
echo.
echo WICHTIG: Dieses Skript als Administrator ausfuehren!
echo.
pause

cd /d "C:\Users\guenther.siegert\Documents\WebView2_Access\COM_Wrapper\ConsysWebView2\bin\Release\net48"

echo Registriere ConsysWebView2.dll...
"%windir%\Microsoft.NET\Framework64\v4.0.30319\RegAsm.exe" ConsysWebView2.dll /codebase /tlb

if %errorlevel% equ 0 (
    echo.
    echo ============================================
    echo ERFOLG! COM-Komponente registriert.
    echo ============================================
    echo.
    echo In Access VBA testen:
    echo   Dim wv As Object
    echo   Set wv = CreateObject("Consys.WebView2Host")
    echo   wv.Navigate "https://www.google.de"
    echo   wv.Show
) else (
    echo.
    echo FEHLER bei der Registrierung!
)

pause

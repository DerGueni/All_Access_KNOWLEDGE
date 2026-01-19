@echo off
echo === Building ConsysWebView2 (AccessDataBridge) ===
"C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe" "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\WebView2_Access\COM_Wrapper\ConsysWebView2\ConsysWebView2.csproj" /t:Rebuild /p:Configuration=Release /p:Platform=x64 /v:minimal
if %errorlevel% neq 0 (
    echo ERROR: ConsysWebView2 Build failed!
    exit /b 1
)

echo.
echo === Building ConsysWebView2App ===
"C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe" "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\WebView2_Access\COM_Wrapper\ConsysWebView2App\ConsysWebView2App.csproj" /t:Rebuild /p:Configuration=Release /p:Platform=x64 /v:minimal
if %errorlevel% neq 0 (
    echo ERROR: ConsysWebView2App Build failed!
    exit /b 1
)

echo.
echo === Build Successful! ===
dir "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\WebView2_Access\COM_Wrapper\ConsysWebView2App\bin\Release\*.exe"

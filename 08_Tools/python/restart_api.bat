@echo off
echo Stopping existing Python processes...
taskkill /F /IM python.exe 2>nul
timeout /t 2 /nobreak >nul

echo Starting API Server...
cd /d "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python"
start "API Server" cmd /c "python api_server.py"

echo API Server started!
timeout /t 3 /nobreak >nul
echo Testing API...
curl -s http://localhost:5000/ | findstr "API Server"
echo.
echo Done! You can close this window.
pause

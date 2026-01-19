@echo off
echo === ConsysWinUI Build Script ===
echo.

:: Set Visual Studio environment
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -arch=x64

echo.
echo VCInstallDir: %VCInstallDir%
echo.

:: Navigate to project directory
cd /d "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0000_Windows_WinUI3_2\ConsysWinUI"

echo Building ConsysWinUI...
echo.

:: Build the project
dotnet build ConsysWinUI.sln -c Debug -p:Platform=x64

echo.
echo Build completed with exit code: %ERRORLEVEL%

@echo off
setlocal enabledelayedexpansion

set "LOGFILE=C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\build_output.log"

echo === ConsysWinUI MSBuild Script === > "%LOGFILE%"
echo Started: %date% %time% >> "%LOGFILE%"
echo. >> "%LOGFILE%"

:: Set Visual Studio environment
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -arch=x64 >> "%LOGFILE%" 2>&1

echo VCInstallDir: %VCInstallDir% >> "%LOGFILE%"
echo. >> "%LOGFILE%"

cd /d "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0000_Windows_WinUI3_2\ConsysWinUI"

echo Building... >> "%LOGFILE%"

msbuild ConsysWinUI.sln /p:Configuration=Debug /p:Platform=x64 /restore /t:Build /m >> "%LOGFILE%" 2>&1

echo. >> "%LOGFILE%"
echo Build exit code: %ERRORLEVEL% >> "%LOGFILE%"
echo Finished: %date% %time% >> "%LOGFILE%"

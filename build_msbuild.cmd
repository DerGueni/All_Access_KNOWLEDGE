@echo off
setlocal enabledelayedexpansion

echo === ConsysWinUI MSBuild Script ===
echo.

:: Find Visual Studio installation
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if exist "%VSWHERE%" (
    for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do (
        set "MSBUILD=%%i"
    )
)

if not defined MSBUILD (
    echo MSBuild not found via vswhere, trying BuildTools path...
    set "MSBUILD=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
)

if not exist "%MSBUILD%" (
    echo ERROR: MSBuild not found!
    exit /b 1
)

echo Found MSBuild: %MSBUILD%
echo.

:: Set Visual Studio environment
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -arch=x64

echo.
echo VCInstallDir: %VCInstallDir%
echo WindowsSdkDir: %WindowsSdkDir%
echo.

cd /d "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0000_Windows_WinUI3_2\ConsysWinUI"

echo Building ConsysWinUI.sln...
echo.

"%MSBUILD%" ConsysWinUI.sln /p:Configuration=Debug /p:Platform=x64 /restore /t:Build /m

echo.
echo Build exit code: %ERRORLEVEL%

# WinUI3 Build Script with VC++ Environment
Write-Host "=== ConsysWinUI Build Script ===" -ForegroundColor Cyan

# Set VCToolsInstallDir environment variable for XamlCompiler
$vcToolsPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207"
$env:VCToolsInstallDir = $vcToolsPath
$env:VCInstallDir = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC"
$env:VCToolsVersion = "14.44.35207"

# Add VC tools to path
$env:Path = "$vcToolsPath\bin\Hostx64\x64;$env:Path"

# Find MSBuild
$msbuildPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
if (-not (Test-Path $msbuildPath)) {
    Write-Host "MSBuild not found at: $msbuildPath" -ForegroundColor Red
    exit 1
}

Write-Host "MSBuild: $msbuildPath" -ForegroundColor Green
Write-Host "VCToolsInstallDir: $vcToolsPath" -ForegroundColor Green
Write-Host ""

# Navigate to project
Set-Location "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0000_Windows_WinUI3_2\ConsysWinUI"

# Clean first
Write-Host "Cleaning obj folder..." -ForegroundColor Yellow
if (Test-Path "ConsysWinUI\obj") {
    Remove-Item -Recurse -Force "ConsysWinUI\obj"
}

Write-Host "Building..." -ForegroundColor Yellow
& $msbuildPath ConsysWinUI.sln /p:Configuration=Debug /p:Platform=x64 /restore /t:Build /m /v:minimal

Write-Host ""
Write-Host "Build completed with exit code: $LASTEXITCODE" -ForegroundColor $(if ($LASTEXITCODE -eq 0) { "Green" } else { "Red" })

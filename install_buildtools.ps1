# Visual Studio Build Tools Installer Script
Write-Host "=== Visual Studio Build Tools Installation ===" -ForegroundColor Cyan

$vsInstallerUrl = "https://aka.ms/vs/17/release/vs_buildtools.exe"
$installerPath = "$env:TEMP\vs_buildtools.exe"

Write-Host "Downloading Visual Studio Build Tools..."
try {
    Invoke-WebRequest -Uri $vsInstallerUrl -OutFile $installerPath -UseBasicParsing
    Write-Host "Download complete: $installerPath" -ForegroundColor Green
} catch {
    Write-Host "Download failed: $_" -ForegroundColor Red
    exit 1
}

if (Test-Path $installerPath) {
    $fileSize = (Get-Item $installerPath).Length / 1MB
    Write-Host "File size: $([math]::Round($fileSize, 2)) MB"

    Write-Host ""
    Write-Host "Starting installation with required components..." -ForegroundColor Yellow
    Write-Host "This will install:" -ForegroundColor Yellow
    Write-Host "  - MSVC v143 C++ Build Tools (x64/x86)" -ForegroundColor White
    Write-Host "  - Windows 10 SDK" -ForegroundColor White
    Write-Host "  - C++ CMake Tools" -ForegroundColor White
    Write-Host ""

    # Install with required workloads for WinUI3
    $installArgs = @(
        "--quiet",
        "--wait",
        "--norestart",
        "--nocache",
        "--add", "Microsoft.VisualStudio.Workload.VCTools",
        "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
        "--add", "Microsoft.VisualStudio.Component.Windows10SDK.19041"
    )

    Write-Host "Running installer (this may take 5-10 minutes)..." -ForegroundColor Cyan
    $process = Start-Process -FilePath $installerPath -ArgumentList $installArgs -Wait -PassThru

    if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
        Write-Host ""
        Write-Host "Installation completed successfully!" -ForegroundColor Green
        if ($process.ExitCode -eq 3010) {
            Write-Host "Note: A restart may be required." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Installation finished with exit code: $($process.ExitCode)" -ForegroundColor Yellow
    }
} else {
    Write-Host "Installer file not found!" -ForegroundColor Red
    exit 1
}

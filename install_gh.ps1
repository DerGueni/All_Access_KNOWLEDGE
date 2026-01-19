# GitHub CLI Installer
$url = "https://github.com/cli/cli/releases/download/v2.63.2/gh_2.63.2_windows_amd64.msi"
$output = "$env:TEMP\gh_installer.msi"

Write-Host "Downloading GitHub CLI..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $url -OutFile $output

Write-Host "Installing GitHub CLI..." -ForegroundColor Cyan
Start-Process msiexec.exe -ArgumentList "/i", $output, "/quiet", "/norestart" -Wait

Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "Please restart your terminal to use 'gh' command." -ForegroundColor Yellow

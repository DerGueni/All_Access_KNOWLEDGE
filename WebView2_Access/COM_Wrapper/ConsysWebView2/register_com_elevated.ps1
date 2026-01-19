# ========================================
# COM-Registrierung für ConsysWebView2.dll
# Startet sich automatisch mit Admin-Rechten
# ========================================

$DllPath = Join-Path $PSScriptRoot "bin\Release\net48\ConsysWebView2.dll"
$RegAsm = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\RegAsm.exe"

# Prüfen ob Admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Starte mit Administrator-Rechten..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -Wait
    exit
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ConsysWebView2 COM Registrierung" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $DllPath)) {
    Write-Host "FEHLER: DLL nicht gefunden!" -ForegroundColor Red
    Write-Host "Pfad: $DllPath" -ForegroundColor Red
    Write-Host "Bitte zuerst das Projekt kompilieren." -ForegroundColor Yellow
    Read-Host "Druecke Enter zum Beenden"
    exit 1
}

Write-Host "DLL: $DllPath" -ForegroundColor Green
Write-Host ""

if (-not (Test-Path $RegAsm)) {
    Write-Host "FEHLER: RegAsm nicht gefunden!" -ForegroundColor Red
    Write-Host "Pfad: $RegAsm" -ForegroundColor Red
    Read-Host "Druecke Enter zum Beenden"
    exit 1
}

Write-Host "Registriere COM-Komponente..." -ForegroundColor Yellow
Write-Host ""

$result = & $RegAsm $DllPath /codebase /tlb 2>&1

Write-Host $result

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "ERFOLG! COM-Komponente registriert." -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "ProgIDs:" -ForegroundColor Cyan
    Write-Host "  - Consys.WebView2Host" -ForegroundColor White
    Write-Host "  - ConsysWebView2.WebFormHost" -ForegroundColor White
    Write-Host ""
    Write-Host "Verwendung in VBA:" -ForegroundColor Cyan
    Write-Host "  Dim host As Object" -ForegroundColor White
    Write-Host "  Set host = CreateObject(`"ConsysWebView2.WebFormHost`")" -ForegroundColor White
    Write-Host "  host.ShowForm `"C:\...\form.html`", `"Titel`", 1200, 800" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "FEHLER bei der Registrierung!" -ForegroundColor Red
    Write-Host "Exitcode: $LASTEXITCODE" -ForegroundColor Red
}

Write-Host ""
Read-Host "Druecke Enter zum Beenden"

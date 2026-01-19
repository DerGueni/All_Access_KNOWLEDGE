# CONSEC VBA Bridge Server - PowerShell Starter
# Startet den Python VBA Bridge Server

$Host.UI.RawUI.WindowTitle = "CONSEC VBA Bridge Server"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CONSEC Access VBA Bridge" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Dieser Server verbindet HTML mit Access VBA!"
Write-Host ""

# Wechsle ins Verzeichnis
Set-Location "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python"

# Prüfe ob Python verfügbar ist
$pythonPath = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonPath) {
    Write-Host "FEHLER: Python nicht gefunden!" -ForegroundColor Red
    Write-Host "Bitte Python installieren: https://www.python.org/downloads/"
    Read-Host "Drücke Enter zum Beenden"
    exit 1
}

Write-Host "Python gefunden: $($pythonPath.Source)" -ForegroundColor Green

# Prüfe ob Flask installiert ist
$flaskCheck = python -c "import flask" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Flask nicht gefunden, installiere Abhängigkeiten..." -ForegroundColor Yellow
    pip install flask flask-cors pywin32
}

Write-Host ""
Write-Host "Starte Server auf Port 5002..." -ForegroundColor Green
Write-Host ""
Write-Host "Endpunkte:" -ForegroundColor Yellow
Write-Host "  http://localhost:5002/              - Status"
Write-Host "  http://localhost:5002/api/vba/status - Access-Verbindung prüfen"
Write-Host "  http://localhost:5002/api/vba/anfragen - E-Mail-Anfragen senden"
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Starte den Server
python vba_bridge.py

Read-Host "Drücke Enter zum Beenden"

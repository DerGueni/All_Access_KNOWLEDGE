# PowerShell-Script zum Neustarten des API-Servers
# Kann mit Rechtsklick -> "Mit PowerShell ausführen" gestartet werden

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CONSEC API Server Neustart" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Schritt 1: Existierende Python-Prozesse beenden
Write-Host "[1/3] Stoppe existierende Python-Prozesse..." -ForegroundColor Yellow
$pythonProcesses = Get-Process -Name "python" -ErrorAction SilentlyContinue
if ($pythonProcesses) {
    $pythonProcesses | Stop-Process -Force
    Write-Host "      Python-Prozesse gestoppt." -ForegroundColor Green
} else {
    Write-Host "      Keine Python-Prozesse gefunden." -ForegroundColor Gray
}

Start-Sleep -Seconds 2

# Schritt 2: In das richtige Verzeichnis wechseln
Write-Host "[2/3] Wechsle in API-Server Verzeichnis..." -ForegroundColor Yellow
$apiPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python"
Set-Location $apiPath
Write-Host "      Pfad: $apiPath" -ForegroundColor Gray

# Schritt 3: API-Server starten
Write-Host "[3/3] Starte API-Server..." -ForegroundColor Yellow
Start-Process -FilePath "python" -ArgumentList "api_server.py" -WorkingDirectory $apiPath

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  API-Server gestartet!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Server laeuft auf: http://localhost:5000" -ForegroundColor Cyan
Write-Host "Email-Endpoint:    http://localhost:5000/api/email/send" -ForegroundColor Cyan
Write-Host ""

# Warten und testen
Write-Host "Warte 5 Sekunden und teste API..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000/" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host ""
        Write-Host "[OK] API-Server antwortet!" -ForegroundColor Green
    }
} catch {
    Write-Host ""
    Write-Host "[WARNUNG] API-Server antwortet noch nicht. Bitte warten..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Druecken Sie eine Taste zum Beenden..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# VBA Bridge starten und testen
$workDir = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python"
$logFile = "$workDir\ps_test.log"

Set-Location $workDir

"=== VBA Bridge Test ===" | Out-File $logFile
"Zeitpunkt: $(Get-Date)" | Out-File $logFile -Append
"" | Out-File $logFile -Append

# 1. Pruefen ob bereits laeuft
"1. Pruefe Status..." | Out-File $logFile -Append
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5002/api/vba/status" -TimeoutSec 2 -ErrorAction Stop
    "   Status: LAEUFT" | Out-File $logFile -Append
    "   Response: $($response.Content)" | Out-File $logFile -Append
    Write-Host "VBA Bridge laeuft bereits!" -ForegroundColor Green
    Get-Content $logFile
    exit 0
} catch {
    "   Status: NICHT AKTIV" | Out-File $logFile -Append
    "   Fehler: $_" | Out-File $logFile -Append
}

# 2. Python pruefen
"" | Out-File $logFile -Append
"2. Python pruefen..." | Out-File $logFile -Append
$pythonVersion = & python --version 2>&1
"   $pythonVersion" | Out-File $logFile -Append

# 3. VBA Bridge starten
"" | Out-File $logFile -Append
"3. Starte VBA Bridge..." | Out-File $logFile -Append
try {
    $proc = Start-Process -FilePath "pythonw" -ArgumentList "vba_bridge.py" -WorkingDirectory $workDir -WindowStyle Hidden -PassThru
    "   Gestartet mit PID: $($proc.Id)" | Out-File $logFile -Append
} catch {
    "   pythonw fehlgeschlagen, versuche python..." | Out-File $logFile -Append
    $proc = Start-Process -FilePath "python" -ArgumentList "vba_bridge.py" -WorkingDirectory $workDir -WindowStyle Hidden -PassThru
    "   Gestartet mit PID: $($proc.Id)" | Out-File $logFile -Append
}

# 4. Warten
"" | Out-File $logFile -Append
"4. Warte 5 Sekunden..." | Out-File $logFile -Append
Start-Sleep -Seconds 5

# 5. Erneut pruefen
"" | Out-File $logFile -Append
"5. Pruefe erneut..." | Out-File $logFile -Append
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5002/api/vba/status" -TimeoutSec 3 -ErrorAction Stop
    "   Status: LAEUFT!" | Out-File $logFile -Append
    "   Response: $($response.Content)" | Out-File $logFile -Append
    "" | Out-File $logFile -Append
    "=== ERFOLG ===" | Out-File $logFile -Append
    Write-Host "VBA Bridge erfolgreich gestartet!" -ForegroundColor Green
} catch {
    "   Status: FEHLGESCHLAGEN" | Out-File $logFile -Append
    "   Fehler: $_" | Out-File $logFile -Append
    "" | Out-File $logFile -Append
    "=== FEHLGESCHLAGEN ===" | Out-File $logFile -Append
    Write-Host "VBA Bridge konnte nicht gestartet werden!" -ForegroundColor Red
}

# Log anzeigen
"" | Out-File $logFile -Append
Get-Content $logFile

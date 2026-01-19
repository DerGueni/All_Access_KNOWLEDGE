# ====================================================================
# INSTALLATION: Access Bridge Vollautomatisch
# Installiert alle benötigten Dependencies
# ====================================================================

Write-Host @"
╔══════════════════════════════════════════════════════════════════╗
║  INSTALLATION: Access Bridge VOLLAUTOMATISCH                     ║
╚══════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# Admin-Check
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠ WARNUNG: Nicht als Administrator ausgeführt" -ForegroundColor Yellow
    Write-Host "  Einige Installationen könnten fehlschlagen" -ForegroundColor Yellow
    Write-Host ""
}

# Python Dependencies
Write-Host "[1/3] Prüfe Python Dependencies..." -ForegroundColor Yellow

$pythonDeps = @(
    "pywin32",      # Für COM-Zugriff
    "pyodbc",       # Für ODBC-Verbindungen
    "pythoncom"     # Windows COM
)

foreach ($dep in $pythonDeps) {
    Write-Host "  Prüfe $dep..." -NoNewline
    
    $installed = python -c "import $dep" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✓ Bereits installiert" -ForegroundColor Green
    } else {
        Write-Host " ⚙ Installiere..." -ForegroundColor Yellow
        
        # Special case für pywin32
        if ($dep -eq "pythoncom") {
            $dep = "pywin32"
        }
        
        python -m pip install $dep --quiet
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    ✓ Erfolgreich installiert" -ForegroundColor Green
        } else {
            Write-Host "    ⚠ Installation fehlgeschlagen" -ForegroundColor Red
        }
    }
}

# ODBC Driver prüfen
Write-Host "`n[2/3] Prüfe ODBC Driver für Access..." -ForegroundColor Yellow

$odbcDrivers = Get-OdbcDriver | Where-Object { $_.Name -like "*Access*" }

if ($odbcDrivers) {
    Write-Host "  ✓ Access ODBC Driver gefunden:" -ForegroundColor Green
    foreach ($driver in $odbcDrivers) {
        Write-Host "    • $($driver.Name)" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⚠ Kein Access ODBC Driver gefunden!" -ForegroundColor Red
    Write-Host "    Installiere Microsoft Access Database Engine:" -ForegroundColor Yellow
    Write-Host "    https://www.microsoft.com/en-us/download/details.aspx?id=54920" -ForegroundColor Cyan
}

# Bridge-Dateien prüfen
Write-Host "`n[3/3] Prüfe Bridge-Dateien..." -ForegroundColor Yellow

$bridgePath = "C:\Users\guenther.siegert\Documents\Access Bridge"
$requiredFiles = @(
    "access_bridge_auto.py",
    "bridge_auto.ps1",
    "config.json",
    "README_VOLLAUTOMATISCH.md",
    "test_auto_bridge.ps1"
)

$allFilesPresent = $true

foreach ($file in $requiredFiles) {
    $fullPath = Join-Path $bridgePath $file
    
    if (Test-Path $fullPath) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file FEHLT!" -ForegroundColor Red
        $allFilesPresent = $false
    }
}

# Test ausführen
if ($allFilesPresent) {
    Write-Host "`n[TEST] Führe Verbindungstest aus..." -ForegroundColor Yellow
    
    $testScript = @"
import sys
sys.path.insert(0, r'$bridgePath')

try:
    from access_bridge_auto import AccessBridge
    
    # Kurzer Test
    with AccessBridge() as bridge:
        info = bridge.get_database_info()
        print('✓ Verbindung erfolgreich!')
        print(f'  Frontend: OK')
        print(f'  Backend: {"OK" if info["using_backend_for_data"] else "N/A"}')
        print(f'  Watchdog: {"AKTIV" if info["watchdog_active"] else "INAKTIV"}')
        print(f'  Tabellen: {info["tables_count"]}')
        print(f'  Formulare: {info["forms_count"]}')
        
except Exception as e:
    print(f'✗ Test fehlgeschlagen: {e}')
    sys.exit(1)
"@
    
    try {
        $testScript | python
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n✓ Installation erfolgreich!" -ForegroundColor Green
        } else {
            Write-Host "`n⚠ Test fehlgeschlagen - prüfe Konfiguration" -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "`n⚠ Test konnte nicht ausgeführt werden: $_" -ForegroundColor Yellow
    }
}

# Zusammenfassung
Write-Host @"

╔══════════════════════════════════════════════════════════════════╗
║  INSTALLATION ABGESCHLOSSEN                                      ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  VERWENDUNG:                                                     ║
║  ───────────                                                     ║
║                                                                  ║
║  Python:                                                         ║
║  --------                                                        ║
║  from access_bridge_auto import AccessBridge                    ║
║                                                                  ║
║  with AccessBridge() as bridge:                                 ║
║      data = bridge.get_table_data('tbl_Name')                   ║
║      # Alle Dialoge automatisch behandelt!                      ║
║                                                                  ║
║  PowerShell:                                                     ║
║  -----------                                                     ║
║  Import-Module .\bridge_auto.ps1                                ║
║  `$bridge = New-AccessBridgeAuto                                 ║
║  Get-AccessTableData -Bridge `$bridge -TableName 'tbl_Name'      ║
║  Disconnect-AccessBridge -Bridge `$bridge                        ║
║                                                                  ║
║  FEATURES:                                                       ║
║  ─────────                                                       ║
║  ✅ Vollautomatische Dialog-Behandlung                          ║
║  ✅ Keine manuellen Eingriffe nötig                             ║
║  ✅ Perfekt für Batch-Jobs                                      ║
║  ✅ Auto-Retry bei Fehlern                                      ║
║                                                                  ║
║  DOKUMENTATION:                                                  ║
║  ──────────────                                                  ║
║  README_VOLLAUTOMATISCH.md                                       ║
║                                                                  ║
║  TEST:                                                           ║
║  ─────                                                           ║
║  .\test_auto_bridge.ps1                                          ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Green

# Optionale Tests
$response = Read-Host "Möchten Sie jetzt den vollständigen Test ausführen? (j/n)"

if ($response -eq 'j' -or $response -eq 'J') {
    Write-Host "`nStarte Test-Suite..." -ForegroundColor Yellow
    & "$bridgePath\test_auto_bridge.ps1"
} else {
    Write-Host "`nTest übersprungen. Sie können ihn später mit .\test_auto_bridge.ps1 ausführen" -ForegroundColor Gray
}

Write-Host "`nDrücke eine Taste zum Beenden..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

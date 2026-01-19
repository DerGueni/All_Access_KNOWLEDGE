# Access Bridge - PowerShell Wrapper
# Ermöglicht einfache Nutzung der Bridge aus PowerShell

# Konfiguration
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptPath "quick_start.py"
$ConfigFile = Join-Path $ScriptPath "config.json"

# Funktion: Bridge-Info anzeigen
function Show-BridgeInfo {
    Write-Host "=== ACCESS BRIDGE INFO ===" -ForegroundColor Cyan
    Write-Host "Script-Pfad: $ScriptPath"
    Write-Host "Python-Script: $PythonScript"
    Write-Host "Konfiguration: $ConfigFile"
    Write-Host ""
}

# Funktion: Setup ausführen
function Start-BridgeSetup {
    Write-Host "Starte Setup..." -ForegroundColor Yellow
    python (Join-Path $ScriptPath "setup.py")
}

# Funktion: Quick-Start Demo
function Start-BridgeDemo {
    Write-Host "Starte Demo..." -ForegroundColor Yellow
    python $PythonScript --demo
}

# Funktion: Interaktives Menü
function Start-BridgeInteractive {
    Write-Host "Starte interaktives Menü..." -ForegroundColor Yellow
    python $PythonScript --interactive
}

# Funktion: Custom Python Script ausführen
function Invoke-BridgeScript {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ScriptName
    )
    
    $FullPath = Join-Path $ScriptPath $ScriptName
    
    if (Test-Path $FullPath) {
        Write-Host "Führe aus: $ScriptName" -ForegroundColor Yellow
        python $FullPath
    } else {
        Write-Host "Script nicht gefunden: $ScriptName" -ForegroundColor Red
    }
}

# Funktion: Backup erstellen
function New-DatabaseBackup {
    param(
        [Parameter(Mandatory=$false)]
        [string]$DbPath,
        
        [Parameter(Mandatory=$false)]
        [string]$BackupPath
    )
    
    # Python-Script inline erstellen
    $TempScript = Join-Path $env:TEMP "bridge_backup.py"
    
    $PythonCode = @"
from access_bridge import AccessBridge
import json
import os
from datetime import datetime

# Config laden
with open(r'$ConfigFile', 'r') as f:
    config = json.load(f)

db_path = r'$DbPath' if r'$DbPath' else config['database']['frontend_path']
backup_folder = config['database']['backup_folder']

# Backup-Name mit Timestamp
timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
backup_name = f'backup_{timestamp}.accdb'
backup_path = r'$BackupPath' if r'$BackupPath' else os.path.join(backup_folder, backup_name)

# Backup erstellen
bridge = AccessBridge(db_path)
bridge.backup_database(backup_path)
bridge.disconnect()

print(f'Backup erstellt: {backup_path}')
"@
    
    $PythonCode | Out-File -FilePath $TempScript -Encoding UTF8
    python $TempScript
    Remove-Item $TempScript
}

# Funktion: Tabellen-Daten exportieren
function Export-TableData {
    param(
        [Parameter(Mandatory=$true)]
        [string]$TableName,
        
        [Parameter(Mandatory=$false)]
        [string]$OutputPath,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet('json', 'csv')]
        [string]$Format = 'json'
    )
    
    if (-not $OutputPath) {
        $OutputPath = Join-Path $ScriptPath "exports\$TableName.$Format"
    }
    
    $TempScript = Join-Path $env:TEMP "bridge_export.py"
    
    $PythonCode = @"
from access_helpers import AccessHelper
import json

with open(r'$ConfigFile', 'r') as f:
    config = json.load(f)

db_path = config['database']['frontend_path']

with AccessHelper(db_path) as helper:
    helper.export_table_to_json('$TableName', r'$OutputPath')

print('Export abgeschlossen: $OutputPath')
"@
    
    $PythonCode | Out-File -FilePath $TempScript -Encoding UTF8
    python $TempScript
    Remove-Item $TempScript
}

# Funktion: SQL ausführen
function Invoke-BridgeSQL {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SQL
    )
    
    $TempScript = Join-Path $env:TEMP "bridge_sql.py"
    
    $PythonCode = @"
from access_bridge import AccessBridge
import json

with open(r'$ConfigFile', 'r') as f:
    config = json.load(f)

db_path = config['database']['frontend_path']

with AccessBridge(db_path) as bridge:
    result = bridge.execute_sql('''$SQL''')
    
    if result:
        for row in result[:50]:  # Max 50 Zeilen
            print(row)
        
        if len(result) > 50:
            print(f'... ({len(result) - 50} weitere Zeilen)')
    else:
        print('Query erfolgreich ausgeführt (keine Rückgabe)')
"@
    
    $PythonCode | Out-File -FilePath $TempScript -Encoding UTF8
    python $TempScript
    Remove-Item $TempScript
}

# Hauptmenü
function Show-BridgeMenu {
    while ($true) {
        Clear-Host
        Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║              ACCESS BRIDGE - PowerShell Menü                 ║
╚══════════════════════════════════════════════════════════════╝

    1  - Setup ausführen
    2  - Demo starten
    3  - Interaktives Python-Menü
    4  - Datenbank-Backup erstellen
    5  - Tabelle exportieren
    6  - SQL-Query ausführen
    7  - Custom Script ausführen
    
    I  - Bridge-Info anzeigen
    Q  - Beenden

"@ -ForegroundColor Cyan
        
        $choice = Read-Host "Wahl"
        
        switch ($choice.ToUpper()) {
            "1" { Start-BridgeSetup; Pause }
            "2" { Start-BridgeDemo; Pause }
            "3" { Start-BridgeInteractive }
            "4" { 
                New-DatabaseBackup
                Pause 
            }
            "5" { 
                $table = Read-Host "Tabellenname"
                Export-TableData -TableName $table
                Pause 
            }
            "6" { 
                $sql = Read-Host "SQL-Query"
                Invoke-BridgeSQL -SQL $sql
                Pause 
            }
            "7" { 
                $script = Read-Host "Script-Name"
                Invoke-BridgeScript -ScriptName $script
                Pause 
            }
            "I" { 
                Show-BridgeInfo
                Pause 
            }
            "Q" { 
                Write-Host "Auf Wiedersehen!" -ForegroundColor Yellow
                return 
            }
            default { 
                Write-Host "Ungültige Eingabe!" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}

# Start
if ($args.Count -eq 0) {
    Show-BridgeMenu
} else {
    switch ($args[0]) {
        "setup" { Start-BridgeSetup }
        "demo" { Start-BridgeDemo }
        "interactive" { Start-BridgeInteractive }
        "backup" { New-DatabaseBackup }
        "info" { Show-BridgeInfo }
        default { 
            Write-Host "Unbekannter Parameter. Verfügbar: setup, demo, interactive, backup, info"
        }
    }
}

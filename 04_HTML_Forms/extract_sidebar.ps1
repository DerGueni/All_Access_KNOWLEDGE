# extract_sidebar.ps1
# =====================
# Extrahiert die Sidebar (left-menu) aus allen HTML-Formularen
# und bereitet sie für die Shell-Integration vor.
#
# Ausführung: powershell -ExecutionPolicy Bypass -File extract_sidebar.ps1

param(
    [switch]$DryRun = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"

# Konfiguration
$formsPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms"
$backupDir = Join-Path $formsPath "_sidebar_backups"
$logFile = Join-Path $formsPath "sidebar_extraction_log.txt"

# Skip-Liste
$skipFiles = @(
    'sidebar.html',
    'index.html',
    'test_ie.html',
    'webview2_test.html',
    'eventdaten_test.html',
    'filter_test.html',
    'ping.html'
)

# Logging-Funktion
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "SUCCESS" { Write-Host $logLine -ForegroundColor Green }
        "ERROR"   { Write-Host $logLine -ForegroundColor Red }
        "WARNING" { Write-Host $logLine -ForegroundColor Yellow }
        "DEBUG"   { if ($Verbose) { Write-Host $logLine -ForegroundColor Gray } }
        default   { Write-Host $logLine -ForegroundColor Cyan }
    }
    
    Add-Content -Path $logFile -Value $logLine -Encoding UTF8
}

# Sidebar aus HTML entfernen
function Remove-SidebarFromHtml {
    param([string]$Content)
    
    if ($Content -notmatch 'class="left-menu"') {
        return @{ Content = $Content; Modified = $false }
    }
    
    $lines = $Content -split "`n"
    $resultLines = @()
    $inSidebar = $false
    $sidebarDepth = 0
    
    foreach ($line in $lines) {
        # Start der Sidebar
        if ($line -match 'class="left-menu"' -and -not $inSidebar) {
            $inSidebar = $true
            $sidebarDepth = 1
            
            # Prüfe auf schließendes Tag in gleicher Zeile
            $opens = ([regex]::Matches($line, '<div\b')).Count
            $closes = ([regex]::Matches($line, '</div>')).Count
            $sidebarDepth = $opens - $closes
            
            if ($sidebarDepth -le 0) {
                $inSidebar = $false
            }
            continue
        }
        
        # Innerhalb der Sidebar
        if ($inSidebar) {
            $opens = ([regex]::Matches($line, '<div\b')).Count
            $closes = ([regex]::Matches($line, '</div>')).Count
            $sidebarDepth += $opens - $closes
            
            if ($sidebarDepth -le 0) {
                $inSidebar = $false
            }
            continue
        }
        
        $resultLines += $line
    }
    
    $newContent = $resultLines -join "`n"
    $wasModified = $resultLines.Count -lt $lines.Count
    
    return @{ Content = $newContent; Modified = $wasModified }
}

# Sidebar.html erstellen
function New-SidebarHtml {
    $sidebarContent = @'
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CONSYS Sidebar</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 11px;
        }
        body {
            margin: 0;
            padding: 0;
            overflow: hidden;
            height: 100vh;
        }
        .left-menu {
            width: 185px;
            height: 100vh;
            background-color: #6060a0;
            padding: 5px;
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
            flex-shrink: 0;
        }
        .menu-header {
            background-color: #000080;
            color: white;
            padding: 6px;
            text-align: center;
            font-weight: bold;
            font-size: 12px;
            margin-bottom: 8px;
        }
        .menu-buttons {
            display: flex;
            flex-direction: column;
            flex: 1;
            gap: 2px;
        }
        .menu-btn {
            background: linear-gradient(to bottom, #d0d0e0, #a0a0c0);
            padding: 8px 10px;
            text-align: center;
            cursor: pointer;
            font-size: 12px;
            color: #000;
            font-weight: 500;
            position: relative;
            border: none;
            margin: 1px 0;
        }
        .menu-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: calc(100% - 4px);
            height: 2px;
            background: #ffffff;
            z-index: 1;
        }
        .menu-btn::after {
            content: '';
            position: absolute;
            bottom: 0;
            right: 0;
            width: calc(100% - 4px);
            height: 2px;
            background: #404070;
            z-index: 1;
        }
        .menu-btn:hover {
            background: linear-gradient(to bottom, #e0e0f0, #b0b0d0);
        }
        .menu-btn.active {
            background: linear-gradient(to bottom, #a0a0d0, #8080b0);
        }
        .menu-btn.active::before {
            background: #505080;
            left: 4px;
        }
        .menu-btn.active::after {
            background: #c0c0d8;
            right: 4px;
        }
    </style>
</head>
<body>
    <div class="left-menu">
        <div>
            <div class="menu-header">HAUPTMENÜ</div>
        </div>
        <div class="menu-buttons">
            <button class="menu-btn" data-form="frm_N_Dienstplanuebersicht">Dienstplanübersicht</button>
            <button class="menu-btn" data-form="frm_DP_Dienstplan_Objekt">Planungsübersicht</button>
            <button class="menu-btn" data-form="frm_va_Auftragstamm">Auftragsverwaltung</button>
            <button class="menu-btn" data-form="frm_MA_Mitarbeiterstamm">Mitarbeiterverwaltung</button>
            <button class="menu-btn" data-form="frm_MA_Offene_Anfragen">Offene Mail Anfragen</button>
            <button class="menu-btn" data-form="frm_MA_Zeitkonten">Excel Zeitkonten</button>
            <button class="menu-btn" data-form="frm_MA_Zeitkonten">Zeitkonten</button>
            <button class="menu-btn" data-form="frmTop_MA_Abwesenheitsplanung">Abwesenheitsplanung</button>
            <button class="menu-btn" data-form="frm_Ausweis_Create">Dienstausweis erstellen</button>
            <button class="menu-btn" data-form="frm_N_Stundenauswertung">Stundenabgleich</button>
            <button class="menu-btn" data-form="frm_KD_Kundenstamm">Kundenverwaltung</button>
            <button class="menu-btn" data-form="frm_OB_Objekt">Objektverwaltung</button>
            <button class="menu-btn" data-form="frm_Verrechnungssaetze">Verrechnungssätze</button>
            <button class="menu-btn" data-form="frm_SubRechnungen">Sub Rechnungen</button>
            <button class="menu-btn" data-form="frmOff_Outlook_aufrufen">E-Mail</button>
            <button class="menu-btn" data-form="frm_Menuefuehrung1">Menü 2</button>
            <button class="menu-btn" data-form="frm_SystemInfo">System Info</button>
        </div>
    </div>
    <script>
        document.querySelectorAll('.menu-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const formName = this.dataset.form;
                if (!formName) return;
                document.querySelectorAll('.menu-btn').forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                if (window.parent !== window) {
                    window.parent.postMessage({ type: 'SIDEBAR_NAVIGATE', form: formName }, '*');
                }
            });
        });
        window.addEventListener('message', function(event) {
            if (event.data.type === 'SET_ACTIVE_FORM') {
                const formName = event.data.form;
                document.querySelectorAll('.menu-btn').forEach(btn => {
                    const isActive = btn.dataset.form === formName;
                    btn.classList.toggle('active', isActive);
                });
            }
        });
        console.log('[Sidebar] Initialisiert');
    </script>
</body>
</html>
'@
    
    $sidebarPath = Join-Path $formsPath "sidebar.html"
    
    if (-not $DryRun) {
        Set-Content -Path $sidebarPath -Value $sidebarContent -Encoding UTF8
    }
    
    Write-Log "Sidebar erstellt: $sidebarPath" "SUCCESS"
}

# Hauptprogramm
function Main {
    # Log initialisieren
    Set-Content -Path $logFile -Value "Sidebar Extraction Log - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n$('=' * 70)`n" -Encoding UTF8
    
    Write-Log "=" * 60
    Write-Log "SIDEBAR EXTRACTION GESTARTET"
    Write-Log "Quellordner: $formsPath"
    if ($DryRun) { Write-Log "MODUS: Dry-Run (keine Änderungen)" "WARNING" }
    Write-Log "=" * 60
    
    # Backup-Ordner erstellen
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        Write-Log "Backup-Ordner erstellt: $backupDir" "DEBUG"
    }
    
    # Phase 1: Sidebar.html erstellen
    Write-Log "`n[Phase 1] Erstelle sidebar.html..."
    New-SidebarHtml
    
    # Phase 2: HTML-Formulare verarbeiten
    Write-Log "`n[Phase 2] Verarbeite HTML-Formulare..."
    
    $htmlFiles = Get-ChildItem -Path $formsPath -Filter "*.html" -File | 
        Where-Object { $_.Name -notin $skipFiles -and -not $_.Name.StartsWith("sub_") }
    
    $processed = 0
    $modified = 0
    $skipped = 0
    
    foreach ($file in $htmlFiles) {
        $processed++
        
        try {
            # Datei lesen
            $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
            $originalSize = $content.Length
            
            # Sidebar entfernen
            $result = Remove-SidebarFromHtml -Content $content
            
            if ($result.Modified) {
                # Backup erstellen
                $backupPath = Join-Path $backupDir "$($file.Name).backup"
                if (-not (Test-Path $backupPath)) {
                    Copy-Item $file.FullName $backupPath
                    Write-Log "Backup: $($file.Name)" "DEBUG"
                }
                
                if (-not $DryRun) {
                    Set-Content -Path $file.FullName -Value $result.Content -Encoding UTF8 -NoNewline
                }
                
                $newSize = $result.Content.Length
                $diff = $originalSize - $newSize
                Write-Log "OK: $($file.Name) ($originalSize -> $newSize bytes, -$diff)" "SUCCESS"
                $modified++
            } else {
                Write-Log "SKIP: $($file.Name) - Keine Sidebar" "DEBUG"
                $skipped++
            }
        }
        catch {
            Write-Log "ERROR: $($file.Name) - $_" "ERROR"
        }
    }
    
    # Zusammenfassung
    Write-Log "`n$('=' * 60)"
    Write-Log "ZUSAMMENFASSUNG"
    Write-Log "=" * 60
    Write-Log "Dateien verarbeitet: $processed"
    Write-Log "Dateien modifiziert: $modified"
    Write-Log "Dateien übersprungen: $skipped"
    Write-Log "Backups in: $backupDir"
    Write-Log "=" * 60
    
    Write-Host "`n✅ Fertig! $modified Formulare modifiziert." -ForegroundColor Green
    Write-Host "📁 Backups: $backupDir" -ForegroundColor Cyan
    Write-Host "📄 Log: $logFile" -ForegroundColor Cyan
}

# Script ausführen
Main

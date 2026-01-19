# ====================================================================
# Access Bridge VOLLAUTOMATISCH - PowerShell Version
# Automatische Behandlung aller Dialoge und Pop-ups
# ====================================================================

$ErrorActionPreference = "SilentlyContinue"

# ====================================================================
# DIALOG WATCHDOG - Automatische Pop-up Behandlung
# ====================================================================

$Global:WatchdogRunning = $false
$Global:DialogsHandled = @()

function Start-DialogWatchdog {
    <#
    .SYNOPSIS
    Startet Background-Job zur automatischen Dialog-Behandlung
    #>
    
    $Global:WatchdogRunning = $true
    
    $watchdogScript = {
        Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        using System.Text;
        
        public class WinAPI {
            [DllImport("user32.dll")]
            public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
            
            [DllImport("user32.dll")]
            public static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindow);
            
            [DllImport("user32.dll")]
            public static extern int SendMessage(IntPtr hWnd, uint Msg, int wParam, int lParam);
            
            [DllImport("user32.dll")]
            public static extern bool SetForegroundWindow(IntPtr hWnd);
            
            [DllImport("user32.dll")]
            public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);
            
            [DllImport("user32.dll")]
            public static extern bool IsWindowVisible(IntPtr hWnd);
            
            public const uint WM_CLOSE = 0x0010;
            public const uint BN_CLICKED = 0x00F5;
            public const uint WM_COMMAND = 0x0111;
        }
"@
        
        $autoCloseTitles = @(
            "Microsoft Access",
            "Warnung",
            "Fehler", 
            "Speichern",
            "Sicherheit",
            "Bestätigung",
            "Hinweis",
            "Information",
            "Achtung"
        )
        
        $autoClickButtons = @("Ja", "OK", "Schließen", "Ignorieren", "Weiter", "Überspringen")
        
        while ($true) {
            Start-Sleep -Milliseconds 500
            
            # Suche nach Dialogen
            foreach ($title in $autoCloseTitles) {
                $hwnd = [WinAPI]::FindWindow($null, $title)
                
                if ($hwnd -ne [IntPtr]::Zero -and [WinAPI]::IsWindowVisible($hwnd)) {
                    # Dialog gefunden - versuche Button zu klicken
                    $buttonClicked = $false
                    
                    foreach ($btnText in $autoClickButtons) {
                        $btnHwnd = [WinAPI]::FindWindowEx($hwnd, [IntPtr]::Zero, "Button", $btnText)
                        
                        if ($btnHwnd -ne [IntPtr]::Zero) {
                            # Button klicken
                            [WinAPI]::SendMessage($btnHwnd, [WinAPI]::WM_COMMAND, 0, 0) | Out-Null
                            
                            Write-Host "  🤖 Dialog auto-behandelt: $title -> Button '$btnText' geklickt" -ForegroundColor Cyan
                            $buttonClicked = $true
                            break
                        }
                    }
                    
                    # Falls kein Button: Dialog schließen
                    if (-not $buttonClicked) {
                        [WinAPI]::SendMessage($hwnd, [WinAPI]::WM_CLOSE, 0, 0) | Out-Null
                        Write-Host "  🤖 Dialog auto-geschlossen: $title" -ForegroundColor Cyan
                    }
                }
            }
        }
    }
    
    # Starte Watchdog als Background-Job
    $Global:WatchdogJob = Start-Job -ScriptBlock $watchdogScript
    Write-Host "✓ Dialog-Watchdog gestartet (automatische Pop-up Behandlung aktiv)" -ForegroundColor Green
}

function Stop-DialogWatchdog {
    <#
    .SYNOPSIS
    Stoppt den Dialog-Watchdog
    #>
    
    if ($Global:WatchdogJob) {
        Stop-Job $Global:WatchdogJob -ErrorAction SilentlyContinue
        Remove-Job $Global:WatchdogJob -Force -ErrorAction SilentlyContinue
        $Global:WatchdogRunning = $false
        Write-Host "✓ Dialog-Watchdog gestoppt" -ForegroundColor Green
    }
}

# ====================================================================
# ACCESS BRIDGE - Vollautomatische Verbindung
# ====================================================================

function New-AccessBridgeAuto {
    <#
    .SYNOPSIS
    Erstellt vollautomatische Access Bridge mit Dialog-Behandlung
    
    .PARAMETER DatabasePath
    Pfad zur Access-Datenbank (optional, nutzt config.json)
    
    .PARAMETER UseRunningInstance
    Nutzt laufende Access-Instanz wenn verfügbar
    
    .EXAMPLE
    $bridge = New-AccessBridgeAuto
    #>
    
    [CmdletBinding()]
    param(
        [string]$DatabasePath,
        [bool]$UseRunningInstance = $true
    )
    
    # Config laden
    $configPath = Join-Path $PSScriptRoot "config.json"
    $config = Get-Content $configPath | ConvertFrom-Json
    
    # Datenbankpfade
    if ($DatabasePath) {
        $frontendPath = $DatabasePath
    } else {
        $frontendPath = $config.database.frontend_path
    }
    $backendPath = $config.database.backend_path
    
    # Dialog-Watchdog starten
    Start-DialogWatchdog
    
    # Bridge-Objekt erstellen
    $bridge = [PSCustomObject]@{
        FrontendPath = $frontendPath
        BackendPath = $backendPath
        AccessApp = $null
        DB = $null
        ConnBackend = $null
        ConnFrontend = $null
        IsConnected = $false
        IsFrontendLocked = $false
        UseRunningInstance = $UseRunningInstance
    }
    
    # COM-Verbindung
    Write-Host "Verbinde mit Access..." -ForegroundColor Yellow
    
    if ($UseRunningInstance) {
        try {
            # Versuche laufende Instanz
            $bridge.AccessApp = [System.Runtime.InteropServices.Marshal]::GetActiveObject("Access.Application")
            Write-Host "  ✓ COM: Laufende Access-Instanz gefunden" -ForegroundColor Green
        } catch {
            # Neue Instanz erstellen
            $bridge.AccessApp = New-Object -ComObject Access.Application
            $bridge.AccessApp.Visible = $false
            $bridge.AccessApp.OpenCurrentDatabase($frontendPath, $false)
            Write-Host "  ✓ COM: Neue Access-Instanz erstellt" -ForegroundColor Green
        }
    } else {
        $bridge.AccessApp = New-Object -ComObject Access.Application
        $bridge.AccessApp.Visible = $false
        $bridge.AccessApp.OpenCurrentDatabase($frontendPath, $false)
        Write-Host "  ✓ COM: Access-Instanz erstellt" -ForegroundColor Green
    }
    
    # ALLE Warnungen deaktivieren
    try {
        $bridge.AccessApp.DoCmd.SetWarnings($false)
        $bridge.AccessApp.SetOption("Confirm Record Changes", $false)
        $bridge.AccessApp.SetOption("Confirm Document Deletions", $false)
        $bridge.AccessApp.SetOption("Confirm Action Queries", $false)
        Write-Host "  ✓ Alle Access-Warnungen deaktiviert" -ForegroundColor Green
    } catch {
        Write-Host "  ℹ Einige Optionen nicht verfügbar" -ForegroundColor Gray
    }
    
    # DB-Objekt
    $bridge.DB = $bridge.AccessApp.CurrentDb()
    
    # ODBC-Verbindung (Backend bevorzugt)
    if (Test-Path $backendPath) {
        try {
            $connStr = "Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=$backendPath;"
            $bridge.ConnBackend = New-Object System.Data.Odbc.OdbcConnection($connStr)
            $bridge.ConnBackend.Open()
            Write-Host "  ✓ ODBC: Backend verbunden" -ForegroundColor Green
        } catch {
            Write-Host "  ⚠ Backend-Verbindung fehlgeschlagen" -ForegroundColor Yellow
        }
    }
    
    # Fallback: Frontend
    if (-not $bridge.ConnBackend) {
        try {
            $connStr = "Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=$frontendPath;"
            $bridge.ConnFrontend = New-Object System.Data.Odbc.OdbcConnection($connStr)
            $bridge.ConnFrontend.Open()
            Write-Host "  ✓ ODBC: Frontend verbunden" -ForegroundColor Green
        } catch {
            $bridge.IsFrontendLocked = $true
            Write-Host "  ℹ Frontend ist gesperrt - nur Backend-Operationen" -ForegroundColor Gray
        }
    }
    
    $bridge.IsConnected = $true
    Write-Host "✓ Vollautomatisch verbunden (ALLE Warnungen deaktiviert)" -ForegroundColor Green
    
    return $bridge
}

# ====================================================================
# SQL-OPERATIONEN mit Auto-Retry
# ====================================================================

function Invoke-AccessSQL {
    <#
    .SYNOPSIS
    Führt SQL-Query aus mit automatischen Wiederholungen
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Bridge,
        
        [Parameter(Mandatory)]
        [string]$SQL,
        
        [switch]$NoFetch,
        
        [int]$MaxRetries = 3
    )
    
    $retryCount = 0
    $lastError = $null
    
    while ($retryCount -le $MaxRetries) {
        try {
            # Wähle Verbindung
            $conn = if ($Bridge.ConnBackend) { $Bridge.ConnBackend } else { $Bridge.ConnFrontend }
            
            if (-not $conn) {
                throw "Keine ODBC-Verbindung verfügbar"
            }
            
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = $SQL
            
            if ($NoFetch) {
                $cmd.ExecuteNonQuery() | Out-Null
                return $null
            } else {
                $reader = $cmd.ExecuteReader()
                $results = @()
                
                while ($reader.Read()) {
                    $row = @{}
                    for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                        $row[$reader.GetName($i)] = $reader.GetValue($i)
                    }
                    $results += [PSCustomObject]$row
                }
                
                $reader.Close()
                return $results
            }
            
        } catch {
            $lastError = $_
            $retryCount++
            
            if ($retryCount -le $MaxRetries) {
                Write-Host "  ⚠ SQL-Fehler (Versuch $retryCount/$MaxRetries): $($_.Exception.Message.Substring(0,100))..." -ForegroundColor Yellow
                Start-Sleep -Milliseconds 500
                continue
            } else {
                throw "SQL-Fehler nach $MaxRetries Versuchen: $($_.Exception.Message)`nQuery: $SQL"
            }
        }
    }
}

# ====================================================================
# HELPER-FUNKTIONEN
# ====================================================================

function Get-AccessTableData {
    <#
    .SYNOPSIS
    Liest Daten aus Tabelle
    #>
    
    param(
        [Parameter(Mandatory)]$Bridge,
        [Parameter(Mandatory)][string]$TableName,
        [string]$Where,
        [int]$Limit,
        [string]$OrderBy
    )
    
    $sql = "SELECT "
    if ($Limit) { $sql += "TOP $Limit " }
    $sql += "* FROM [$TableName]"
    
    if ($Where) { $sql += " WHERE $Where" }
    if ($OrderBy) { $sql += " ORDER BY $OrderBy" }
    
    return Invoke-AccessSQL -Bridge $Bridge -SQL $sql
}

function Add-AccessRecord {
    <#
    .SYNOPSIS
    Fügt Datensatz ein
    #>
    
    param(
        [Parameter(Mandatory)]$Bridge,
        [Parameter(Mandatory)][string]$TableName,
        [Parameter(Mandatory)][hashtable]$Data,
        [switch]$ReturnID
    )
    
    $fields = ($Data.Keys | ForEach-Object { "[$_]" }) -join ", "
    $values = ($Data.Values | ForEach-Object { 
        if ($_ -is [string]) { "'$($_.Replace("'", "''"))'" } 
        elseif ($null -eq $_) { "NULL" }
        else { $_ }
    }) -join ", "
    
    $sql = "INSERT INTO [$TableName] ($fields) VALUES ($values)"
    
    Invoke-AccessSQL -Bridge $Bridge -SQL $sql -NoFetch
    
    if ($ReturnID) {
        $result = Invoke-AccessSQL -Bridge $Bridge -SQL "SELECT @@IDENTITY AS NewID"
        return $result[0].NewID
    }
}

function Update-AccessRecord {
    <#
    .SYNOPSIS
    Aktualisiert Datensatz(e)
    #>
    
    param(
        [Parameter(Mandatory)]$Bridge,
        [Parameter(Mandatory)][string]$TableName,
        [Parameter(Mandatory)][hashtable]$Data,
        [Parameter(Mandatory)][string]$Where
    )
    
    $setClause = ($Data.GetEnumerator() | ForEach-Object {
        $value = if ($_.Value -is [string]) { "'$($_.Value.Replace("'", "''"))'" }
                elseif ($null -eq $_.Value) { "NULL" }
                else { $_.Value }
        "[$($_.Key)] = $value"
    }) -join ", "
    
    $sql = "UPDATE [$TableName] SET $setClause WHERE $Where"
    
    Invoke-AccessSQL -Bridge $Bridge -SQL $sql -NoFetch
}

function Remove-AccessRecord {
    <#
    .SYNOPSIS
    Löscht Datensatz(e)
    #>
    
    param(
        [Parameter(Mandatory)]$Bridge,
        [Parameter(Mandatory)][string]$TableName,
        [Parameter(Mandatory)][string]$Where
    )
    
    $sql = "DELETE FROM [$TableName] WHERE $Where"
    Invoke-AccessSQL -Bridge $Bridge -SQL $sql -NoFetch
}

# ====================================================================
# FORMULAR-OPERATIONEN
# ====================================================================

function Open-AccessForm {
    <#
    .SYNOPSIS
    Öffnet Formular
    #>
    
    param(
        [Parameter(Mandatory)]$Bridge,
        [Parameter(Mandatory)][string]$FormName,
        [int]$View = 0,
        [string]$Where,
        [double]$Wait = 0.5
    )
    
    try {
        $Bridge.AccessApp.DoCmd.OpenForm($FormName, $View, "", $Where, 1, 0)
        Start-Sleep -Milliseconds ($Wait * 1000)
        Write-Host "✓ Formular '$FormName' geöffnet" -ForegroundColor Green
    } catch {
        throw "Fehler beim Öffnen: $_"
    }
}

function Close-AccessForm {
    <#
    .SYNOPSIS
    Schließt Formular
    #>
    
    param(
        [Parameter(Mandatory)]$Bridge,
        [Parameter(Mandatory)][string]$FormName,
        [int]$Save = 1,
        [switch]$Force
    )
    
    try {
        $Bridge.AccessApp.DoCmd.Close(2, $FormName, $Save)
        Write-Host "✓ Formular '$FormName' geschlossen" -ForegroundColor Green
    } catch {
        if ($Force) {
            # Notfall: SendKeys
            try {
                $Bridge.AccessApp.DoCmd.SelectObject(2, $FormName, $true)
                $wshell = New-Object -ComObject WScript.Shell
                $wshell.SendKeys("%{F4}")  # ALT+F4
                Write-Host "✓ Formular '$FormName' zwangsweise geschlossen" -ForegroundColor Green
            } catch {
                throw "Fehler beim Schließen: $_"
            }
        } else {
            throw "Fehler beim Schließen: $_"
        }
    }
}

function Get-AccessFormValue {
    <#
    .SYNOPSIS
    Liest Formular-Control-Wert
    #>
    
    param(
        [Parameter(Mandatory)]$Bridge,
        [Parameter(Mandatory)][string]$FormName,
        [Parameter(Mandatory)][string]$ControlName
    )
    
    return $Bridge.AccessApp.Forms($FormName).Controls($ControlName).Value
}

function Set-AccessFormValue {
    <#
    .SYNOPSIS
    Setzt Formular-Control-Wert
    #>
    
    param(
        [Parameter(Mandatory)]$Bridge,
        [Parameter(Mandatory)][string]$FormName,
        [Parameter(Mandatory)][string]$ControlName,
        $Value,
        [double]$Wait = 0.2
    )
    
    $Bridge.AccessApp.Forms($FormName).Controls($ControlName).Value = $Value
    Start-Sleep -Milliseconds ($Wait * 1000)
    Write-Host "✓ Wert gesetzt: $ControlName = $Value" -ForegroundColor Green
}

# ====================================================================
# VBA-OPERATIONEN
# ====================================================================

function Invoke-AccessVBA {
    <#
    .SYNOPSIS
    Führt VBA-Funktion aus
    #>
    
    param(
        [Parameter(Mandatory)]$Bridge,
        [Parameter(Mandatory)][string]$FunctionName,
        [object[]]$Arguments
    )
    
    try {
        if ($Arguments) {
            $result = $Bridge.AccessApp.Run($FunctionName, $Arguments)
        } else {
            $result = $Bridge.AccessApp.Run($FunctionName)
        }
        Write-Host "✓ VBA '$FunctionName' ausgeführt" -ForegroundColor Green
        return $result
    } catch {
        throw "VBA-Fehler: $_"
    }
}

# ====================================================================
# CLEANUP
# ====================================================================

function Disconnect-AccessBridge {
    <#
    .SYNOPSIS
    Trennt Access Bridge und stoppt Watchdog
    #>
    
    param([Parameter(Mandatory)]$Bridge)
    
    try {
        # Watchdog stoppen
        Stop-DialogWatchdog
        
        # ODBC trennen
        if ($Bridge.ConnBackend) {
            $Bridge.ConnBackend.Close()
            $Bridge.ConnBackend = $null
        }
        
        if ($Bridge.ConnFrontend) {
            $Bridge.ConnFrontend.Close()
            $Bridge.ConnFrontend = $null
        }
        
        # COM trennen (nur wenn WIR die Instanz erstellt haben)
        if ($Bridge.AccessApp -and -not $Bridge.UseRunningInstance) {
            try {
                $Bridge.AccessApp.DoCmd.SetWarnings($true)
            } catch {}
            
            $Bridge.AccessApp.CloseCurrentDatabase()
            $Bridge.AccessApp.Quit()
            [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Bridge.AccessApp) | Out-Null
            $Bridge.AccessApp = $null
        }
        
        Write-Host "✓ Verbindung getrennt" -ForegroundColor Green
        
    } catch {
        Write-Host "Warnung beim Trennen: $_" -ForegroundColor Yellow
    }
}

# ====================================================================
# EXPORT
# ====================================================================

Export-ModuleMember -Function @(
    'New-AccessBridgeAuto',
    'Invoke-AccessSQL',
    'Get-AccessTableData',
    'Add-AccessRecord',
    'Update-AccessRecord',
    'Remove-AccessRecord',
    'Open-AccessForm',
    'Close-AccessForm',
    'Get-AccessFormValue',
    'Set-AccessFormValue',
    'Invoke-AccessVBA',
    'Disconnect-AccessBridge',
    'Start-DialogWatchdog',
    'Stop-DialogWatchdog'
)

# ====================================================================
# VERWENDUNG
# ====================================================================

<#
.EXAMPLE
# Bridge erstellen (vollautomatisch)
$bridge = New-AccessBridgeAuto

# Daten lesen
$data = Get-AccessTableData -Bridge $bridge -TableName "tbl_MA_Mitarbeiterstamm" -Limit 10

# Datensatz einfügen
Add-AccessRecord -Bridge $bridge -TableName "tbl_Test" -Data @{
    Feld1 = "Wert1"
    Feld2 = 42
}

# Formular öffnen
Open-AccessForm -Bridge $bridge -FormName "frm_MA_Mitarbeiterstamm"

# Aufräumen
Disconnect-AccessBridge -Bridge $bridge

.NOTES
Alle Dialoge werden AUTOMATISCH behandelt!
Keine manuelle Interaktion nötig!
#>

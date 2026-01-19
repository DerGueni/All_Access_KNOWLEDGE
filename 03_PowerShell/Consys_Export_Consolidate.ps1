#═══════════════════════════════════════════════════════════════════════════════
# Script: Consys_Export_Consolidate.ps1
# Zweck: Konsolidiert alle JSON-Exporte in eine Wissensdatenbank
# Version: 1.0
# Erstellt: 2025-10-30
# PowerShell: 5.1+
#
# VERWENDUNG:
# 1. VBA-Export in Access ausführen (mod_ConsysExport_Complete)
# 2. Dieses Script ausführen: .\Consys_Export_Consolidate.ps1
# 3. Ergebnis: Consys_FE_N_KnowledgeBase.json
#═══════════════════════════════════════════════════════════════════════════════

param(
    [string]$ExportRoot = "$env:USERPROFILE\Documents\Consys_Export",
    [string]$OutputFile = "Consys_FE_N_KnowledgeBase.json",
    [switch]$Verbose
)

#═══════════════════════════════════════════════════════════════════════════════
# KONFIGURATION
#═══════════════════════════════════════════════════════════════════════════════

$ErrorActionPreference = "Stop"
$ProgressPreference = "Continue"

#═══════════════════════════════════════════════════════════════════════════════
# FUNKTIONEN
#═══════════════════════════════════════════════════════════════════════════════

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "INFO"    { "White" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        default   { "White" }
    }
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

function Test-JsonFile {
    param([string]$FilePath)
    
    try {
        $content = Get-Content -Path $FilePath -Raw -ErrorAction Stop
        if ([string]::IsNullOrWhiteSpace($content)) {
            Write-Log "Datei ist leer: $FilePath" "WARNING"
            return $false
        }
        $null = $content | ConvertFrom-Json -ErrorAction Stop
        return $true
    }
    catch {
        Write-Log "Ungültiges JSON in: $FilePath - $($_.Exception.Message)" "WARNING"
        return $false
    }
}

#═══════════════════════════════════════════════════════════════════════════════
# HAUPTLOGIK
#═══════════════════════════════════════════════════════════════════════════════

Write-Log "═══════════════════════════════════════════════════════════" "INFO"
Write-Log "CONSYS EXPORT KONSOLIDIERUNG - START" "INFO"
Write-Log "═══════════════════════════════════════════════════════════" "INFO"
Write-Log ""

# Prüfe Export-Ordner
if (-not (Test-Path $ExportRoot)) {
    Write-Log "Export-Ordner nicht gefunden: $ExportRoot" "ERROR"
    Write-Log "Bitte zuerst den VBA-Export ausführen!" "ERROR"
    exit 1
}

Write-Log "Export-Ordner: $ExportRoot" "INFO"
Write-Log ""

# Erstelle Haupt-Objekt
$knowledgeBase = [ordered]@{
    metadata = [ordered]@{
        exportDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        version = "1.0"
        source = "Consys_FE_N_Test_Claude.accdb"
        generator = "Access-Forensiker SDK"
    }
}

# Zu ladende Dateien
$dataFiles = @(
    "metadata",
    "tables",
    "queries",
    "forms",
    "reports",
    "modules",
    "macros",
    "relations",
    "workflows"
)

# Lade alle JSON-Dateien
$successCount = 0
$errorCount = 0

foreach ($fileName in $dataFiles) {
    $filePath = Join-Path $ExportRoot "$fileName.json"
    
    if (Test-Path $filePath) {
        Write-Log "Lade: $fileName.json..." "INFO"
        
        if (Test-JsonFile -FilePath $filePath) {
            try {
                $content = Get-Content -Path $filePath -Raw | ConvertFrom-Json
                $knowledgeBase[$fileName] = $content
                $successCount++
                
                # Statistik anzeigen
                if ($content -is [Array]) {
                    Write-Log "  → $($content.Count) Einträge geladen" "SUCCESS"
                } elseif ($content -is [PSCustomObject]) {
                    $propCount = ($content | Get-Member -MemberType NoteProperty).Count
                    Write-Log "  → $propCount Eigenschaften geladen" "SUCCESS"
                }
            }
            catch {
                Write-Log "Fehler beim Laden von $fileName.json: $($_.Exception.Message)" "ERROR"
                $errorCount++
            }
        }
        else {
            Write-Log "Überspringe ungültige Datei: $fileName.json" "WARNING"
            $errorCount++
        }
    }
    else {
        Write-Log "Datei nicht gefunden: $fileName.json" "WARNING"
        $errorCount++
    }
}

Write-Log ""
Write-Log "───────────────────────────────────────────────────────────" "INFO"

# Zusätzliche Analyse
Write-Log "Führe Zusatzanalysen durch..." "INFO"

# Statistik erstellen
$stats = [ordered]@{
    tables = if ($knowledgeBase.tables) { $knowledgeBase.tables.Count } else { 0 }
    queries = if ($knowledgeBase.queries) { $knowledgeBase.queries.Count } else { 0 }
    forms = if ($knowledgeBase.forms) { $knowledgeBase.forms.Count } else { 0 }
    reports = if ($knowledgeBase.reports) { $knowledgeBase.reports.Count } else { 0 }
    modules = if ($knowledgeBase.modules) { $knowledgeBase.modules.Count } else { 0 }
    macros = if ($knowledgeBase.macros) { $knowledgeBase.macros.Count } else { 0 }
    relations = if ($knowledgeBase.relations) { $knowledgeBase.relations.Count } else { 0 }
}

$knowledgeBase["statistics"] = $stats

Write-Log "  → Statistik hinzugefügt" "SUCCESS"

# Navigation erstellen
$navigation = [ordered]@{
    sections = @(
        [ordered]@{ name = "metadata"; description = "Datenbank-Metadaten und Grundinformationen" }
        [ordered]@{ name = "tables"; description = "Tabellen-Definitionen mit Feldern und Indizes" }
        [ordered]@{ name = "queries"; description = "Gespeicherte Abfragen und SQL-Statements" }
        [ordered]@{ name = "forms"; description = "Formulare mit Controls und Eigenschaften" }
        [ordered]@{ name = "reports"; description = "Berichte und Report-Definitionen" }
        [ordered]@{ name = "modules"; description = "VBA-Module und Code" }
        [ordered]@{ name = "macros"; description = "Access-Makros" }
        [ordered]@{ name = "relations"; description = "Tabellen-Beziehungen" }
        [ordered]@{ name = "workflows"; description = "Erkannte Workflows und Prozesse" }
        [ordered]@{ name = "statistics"; description = "Objekt-Statistiken" }
    )
    howToUse = @(
        "Diese Datei enthält die komplette Struktur der Access-Datenbank",
        "Alle Objekte sind nach Typ gruppiert und durchsuchbar",
        "VBA-Code ist im 'modules' Abschnitt zu finden",
        "Tabellen-Beziehungen sind im 'relations' Abschnitt dokumentiert"
    )
}

$knowledgeBase["_navigation"] = $navigation

Write-Log "  → Navigation hinzugefügt" "SUCCESS"

# Speichern
$outputPath = Join-Path $ExportRoot $OutputFile
Write-Log ""
Write-Log "Speichere Wissensdatenbank..." "INFO"

try {
    $knowledgeBase | ConvertTo-Json -Depth 20 | Set-Content -Path $outputPath -Encoding UTF8
    Write-Log "  → Erfolgreich gespeichert: $outputPath" "SUCCESS"
    
    # Dateigröße anzeigen
    $fileSize = (Get-Item $outputPath).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    Write-Log "  → Dateigröße: $fileSizeMB MB" "INFO"
}
catch {
    Write-Log "Fehler beim Speichern: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Zusammenfassung
Write-Log ""
Write-Log "═══════════════════════════════════════════════════════════" "INFO"
Write-Log "KONSOLIDIERUNG ABGESCHLOSSEN" "SUCCESS"
Write-Log "═══════════════════════════════════════════════════════════" "INFO"
Write-Log ""
Write-Log "📊 STATISTIK:" "INFO"
Write-Log "  Tabellen:     $($stats.tables)" "INFO"
Write-Log "  Abfragen:     $($stats.queries)" "INFO"
Write-Log "  Formulare:    $($stats.forms)" "INFO"
Write-Log "  Berichte:     $($stats.reports)" "INFO"
Write-Log "  Module:       $($stats.modules)" "INFO"
Write-Log "  Makros:       $($stats.macros)" "INFO"
Write-Log "  Beziehungen:  $($stats.relations)" "INFO"
Write-Log ""
Write-Log "📁 AUSGABE:" "INFO"
Write-Log "  $outputPath" "INFO"
Write-Log ""
Write-Log "✅ Erfolgreiche Dateien: $successCount" "SUCCESS"
if ($errorCount -gt 0) {
    Write-Log "⚠️  Fehler/Warnungen:     $errorCount" "WARNING"
}
Write-Log ""
Write-Log "🎯 NÄCHSTER SCHRITT:" "INFO"
Write-Log "  Diese Datei kann jetzt in Claude Desktop oder andere Tools importiert werden" "INFO"
Write-Log ""

# Explorer öffnen
Start-Process explorer.exe -ArgumentList $ExportRoot

Write-Log "Export-Ordner wurde geöffnet" "INFO"
Write-Log ""

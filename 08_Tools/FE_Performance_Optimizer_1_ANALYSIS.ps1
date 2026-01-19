# ============================================================================
# CONSYS Frontend Performance Optimizer - Phase 1: ANALYSE
# ============================================================================
# Analysiert die Access Frontend-Datenbank auf Performance-Engpässe
# Erzeugt detaillierten Report mit Optimierungsempfehlungen
# ============================================================================

param(
    [string]$DbPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb",
    [string]$OutputDir = "c:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\10_Logs_Reports"
)

Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  CONSYS Frontend Performance Analyzer - Phase 1: ANALYSE" -ForegroundColor Yellow
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan

# Überprüfe Datenbank
if (-not (Test-Path $DbPath)) {
    Write-Host "❌ FEHLER: Datenbank nicht gefunden: $DbPath" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Datenbank gefunden: $(Get-Item $DbPath | Select-Object -ExpandProperty Length) bytes" -ForegroundColor Green

# COM-Objekt für Access erstellen
try {
    $Access = New-Object -ComObject Access.Application
    $Access.Visible = $false
    Write-Host "✓ Access COM-Objekt erstellt" -ForegroundColor Green
} catch {
    Write-Host "❌ FEHLER beim Erstellen des Access COM-Objekts: $_" -ForegroundColor Red
    exit 1
}

# Datenbank öffnen
try {
    $Db = $Access.CurrentProject.OpenCurrentDatabase($DbPath, $false)
    Write-Host "✓ Datenbank geöffnet" -ForegroundColor Green
} catch {
    Write-Host "❌ FEHLER beim Öffnen der Datenbank: $_" -ForegroundColor Red
    $Access.Quit()
    exit 1
}

$Results = @{
    "Zeitstempel" = (Get-Date -Format "dd.MM.yyyy HH:mm:ss")
    "Datenbank" = (Get-Item $DbPath).Name
    "Größe_Bytes" = (Get-Item $DbPath).Length
    "Forms" = @()
    "Queries" = @()
    "Modules" = @()
    "Performance_Issues" = @()
    "Recommendations" = @()
}

# ============================================================================
# 1. FORMULARE ANALYSIEREN
# ============================================================================
Write-Host "`n📋 Analysiere Formulare..." -ForegroundColor Cyan
$FormCount = 0
$HeavyForms = @()

try {
    foreach ($Form in $Access.CurrentProject.AllForms) {
        $FormCount++
        $FormInfo = @{
            "Name" = $Form.Name
            "SubformCount" = 0
            "ControlCount" = 0
            "HasImages" = $false
            "Issues" = @()
        }
        
        # Kontrollzählung
        $ControlCount = $Form.Controls.Count
        $FormInfo.ControlCount = $ControlCount
        
        # Suche Unterformulare
        foreach ($Control in $Form.Controls) {
            if ($Control.ControlType -eq 112) { # SubformControl
                $FormInfo.SubformCount++
            }
            if ($Control.ControlType -eq 12) { # ImageControl
                $FormInfo.HasImages = $true
            }
        }
        
        # Identifiziere Performance-Probleme
        if ($FormInfo.SubformCount -gt 3) {
            $FormInfo.Issues += "⚠️ Viele Unterformulare ($($FormInfo.SubformCount))"
            $HeavyForms += $Form.Name
        }
        if ($FormInfo.ControlCount -gt 100) {
            $FormInfo.Issues += "⚠️ Viele Kontrollelemente ($($FormInfo.ControlCount))"
            $HeavyForms += $Form.Name
        }
        if ($FormInfo.HasImages) {
            $FormInfo.Issues += "⚠️ Eingebettete Bilder vorhanden"
        }
        
        $Results.Forms += $FormInfo
        Write-Host "  ✓ $($Form.Name) - $ControlCount Kontrolle(n), $($FormInfo.SubformCount) Unterforumlar(e)" -ForegroundColor Gray
    }
    Write-Host "✓ $FormCount Formulare analysiert" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Fehler bei Formularanalyse: $_" -ForegroundColor Yellow
}

# ============================================================================
# 2. ABFRAGEN ANALYSIEREN
# ============================================================================
Write-Host "`n📊 Analysiere Abfragen..." -ForegroundColor Cyan
$QueryCount = 0
$ProblematicQueries = @()

try {
    foreach ($Query in $Access.CurrentProject.AllQueries) {
        $QueryCount++
        $QueryInfo = @{
            "Name" = $Query.Name
            "Type" = $Query.Type
            "Issues" = @()
        }
        
        # SQL-Code analysieren
        $SQL = $Query.SQL
        
        # Prüfe auf Performance-Probleme
        if ($SQL -match "SELECT \* FROM") {
            $QueryInfo.Issues += "⚠️ SELECT * verwendet"
            $ProblematicQueries += $Query.Name
        }
        if ($SQL -match "WHERE.*LIKE '%") {
            $QueryInfo.Issues += "⚠️ LIKE mit wildcard am Anfang"
            $ProblematicQueries += $Query.Name
        }
        if ($SQL -match "UNION\s+SELECT" -and -not ($SQL -match "UNION\s+ALL")) {
            $QueryInfo.Issues += "⚠️ UNION statt UNION ALL"
            $ProblematicQueries += $Query.Name
        }
        
        $Results.Queries += $QueryInfo
        Write-Host "  ✓ $($Query.Name)" -ForegroundColor Gray
    }
    Write-Host "✓ $QueryCount Abfragen analysiert" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Fehler bei Abfrageanalyse: $_" -ForegroundColor Yellow
}

# ============================================================================
# 3. MODULE ANALYSIEREN
# ============================================================================
Write-Host "`n🔧 Analysiere Module..." -ForegroundColor Cyan
$ModuleCount = 0
$CodeIssues = @()

try {
    foreach ($Module in $Access.CurrentProject.AllModules) {
        $ModuleCount++
        $ModuleInfo = @{
            "Name" = $Module.Name
            "LineCount" = $Module.CountOfLines
            "Issues" = @()
        }
        
        # Code-Analyse (vereinfacht)
        $Code = $Module.Lines(1, $Module.CountOfLines)
        
        if ($Code -match "DLookup|DCount|DSum") {
            $ModuleInfo.Issues += "⚠️ Wiederholte D-Funktionen erkannt"
            $CodeIssues += $Module.Name
        }
        if ($Code -match "On Error Resume Next") {
            $ModuleInfo.Issues += "⚠️ On Error Resume Next vorhanden"
            $CodeIssues += $Module.Name
        }
        
        $Results.Modules += $ModuleInfo
        Write-Host "  ✓ $($Module.Name) - $($Module.CountOfLines) Zeilen" -ForegroundColor Gray
    }
    Write-Host "✓ $ModuleCount Module analysiert" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Fehler bei Modulanalyse: $_" -ForegroundColor Yellow
}

# ============================================================================
# 4. PERFORMANCE-EMPFEHLUNGEN
# ============================================================================
Write-Host "`n💡 Generiere Performance-Empfehlungen..." -ForegroundColor Cyan

$Recommendations = @(
    @{
        Priorität = "KRITISCH"
        Kategorie = "Datenbankoptimierung"
        Aktion = "Führe COMPACT AND REPAIR durch"
        Effekt = "Reduziert Dateigröße um 10-20%, verbessert Zugriffsgeschwindigkeit"
    }
    @{
        Priorität = "HOCH"
        Kategorie = "Abfragen"
        Aktion = "Ersetze SELECT * durch benannte Spalten"
        Auswirkung = "Reduziert Datenmenge um 30-50%"
    }
    @{
        Priorität = "HOCH"
        Kategorie = "Indizierung"
        Aktion = "Erstelle Indizes auf häufig gefilterten/sortierten Feldern"
        Effekt = "Beschleunigt Filterung/Sorting um 10-100x"
    }
    @{
        Priorität = "HOCH"
        Kategorie = "Formulare"
        Aktion = "Reduziere Unterformulare, nutze Tab-Steuerelemente für verschachtelte Daten"
        Effekt = "Reduziert Speicherverbrauch um 20-40%"
    }
    @{
        Priorität = "MITTEL"
        Kategorie = "VBA-Code"
        Aktion = "Ersetze wiederholte DLookup durch Arrays oder DAO-Recordsets"
        Effekt = "Beschleunigt Code um 5-20x"
    }
    @{
        Priorität = "MITTEL"
        Kategorie = "Cache"
        Aktion = "Implementiere lokales Caching für häufig abgerufene Daten"
        Effekt = "Reduziert Datenbankabfragen um 30-60%"
    }
    @{
        Priorität = "NIEDRIG"
        Kategorie = "Bilder"
        Aktion = "Verschiebe eingebettete Bilder in externe Dateien mit Verlinkung"
        Effekt = "Reduziert Dateigröße um 20-40%"
    }
)

$Results.Recommendations = $Recommendations

# ============================================================================
# REPORT GENERIEREN
# ============================================================================
$ReportPath = Join-Path $OutputDir "FE_Performance_Analysis_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
$Results | ConvertTo-Json -Depth 5 | Out-File -FilePath $ReportPath -Encoding UTF8

Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ANALYSE ABGESCHLOSSEN" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✓ Formulare: $($Results.Forms.Count)" -ForegroundColor Gray
Write-Host "✓ Abfragen: $($Results.Queries.Count)" -ForegroundColor Gray
Write-Host "✓ Module: $($Results.Modules.Count)" -ForegroundColor Gray
Write-Host "✓ Report: $ReportPath" -ForegroundColor Yellow

# Cleanup
try {
    $Access.Quit()
} catch {}

Write-Host "`n📄 Siehe Report für detaillierte Optimierungsempfehlungen" -ForegroundColor Yellow

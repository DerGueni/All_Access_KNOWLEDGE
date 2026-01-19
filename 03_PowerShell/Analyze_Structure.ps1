# ═══════════════════════════════════════════════════════════════════════════════
# Skript:    Analyze_Structure.ps1
# Zweck:     Analysiert die Datenbank-Struktur und erstellt einen Übersichtsbericht
# Autor:     Access-Forensiker Agent
# Datum:     2025-10-31
# Version:   1.0
# ═══════════════════════════════════════════════════════════════════════════════

[CmdletBinding()]
param(
    [string]$KnowledgeBasePath = "$env:USERPROFILE\Documents\0000_Consys_Wissen_kpl\03_Export_Ergebnisse\Consys_FE_N_KnowledgeBase.json"
)

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Consys Knowledge Base - Struktur-Analyse" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Prüfen ob Wissensdatenbank existiert
if (-not (Test-Path $KnowledgeBasePath)) {
    Write-Host "✗ Wissensdatenbank nicht gefunden!" -ForegroundColor Red
    Write-Host "  Pfad: $KnowledgeBasePath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Bitte erst Merge_JSONs.ps1 ausführen!" -ForegroundColor Yellow
    exit 1
}

Write-Host "[1/6] Lade Wissensdatenbank..." -ForegroundColor Green

try {
    $kb = Get-Content -Path $KnowledgeBasePath -Raw | ConvertFrom-Json
    Write-Host "  ✓ Erfolgreich geladen" -ForegroundColor White
} catch {
    Write-Host "  ✗ Fehler beim Laden: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "DATENBANK-ÜBERSICHT" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Datenbank:     $($kb.databaseName)" -ForegroundColor White
Write-Host "Export-Datum:  $($kb.exportDate)" -ForegroundColor White
Write-Host "Version:       $($kb.exportVersion)" -ForegroundColor White
Write-Host ""

Write-Host "[2/6] Analysiere Tabellen..." -ForegroundColor Green
Write-Host ""
Write-Host "Tabellen ($($kb.tables.Count)):" -ForegroundColor Yellow

if ($kb.tables.Count -gt 0) {
    $kb.tables | ForEach-Object {
        $fieldCount = $_.fields.Count
        $indexCount = $_.indexes.Count
        Write-Host "  • $($_.name)" -ForegroundColor White
        Write-Host "    → Felder: $fieldCount, Indizes: $indexCount" -ForegroundColor Gray
    }
} else {
    Write-Host "  (Keine Tabellen gefunden)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "[3/6] Analysiere Queries..." -ForegroundColor Green
Write-Host ""
Write-Host "Queries ($($kb.queries.Count)):" -ForegroundColor Yellow

if ($kb.queries.Count -gt 0) {
    # Gruppierung nach Typ
    $queryTypes = $kb.queries | Group-Object -Property typeName
    foreach ($group in $queryTypes) {
        Write-Host "  $($group.Name): $($group.Count)" -ForegroundColor White
        $group.Group | ForEach-Object {
            Write-Host "    • $($_.name)" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "  (Keine Queries gefunden)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "[4/6] Analysiere Formulare..." -ForegroundColor Green
Write-Host ""
Write-Host "Formulare ($($kb.forms.Count)):" -ForegroundColor Yellow

if ($kb.forms.Count -gt 0) {
    $kb.forms | ForEach-Object {
        $controlCount = $_.controls.Count
        $hasEvents = ($_.events.PSObject.Properties | Measure-Object).Count -gt 0
        
        Write-Host "  • $($_.name)" -ForegroundColor White
        Write-Host "    → RecordSource: $($_.recordSource)" -ForegroundColor Gray
        Write-Host "    → Controls: $controlCount" -ForegroundColor Gray
        if ($hasEvents) {
            Write-Host "    → Events: Ja" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "  (Keine Formulare gefunden)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "[5/6] Analysiere Module..." -ForegroundColor Green
Write-Host ""
Write-Host "Module ($($kb.modules.Count)):" -ForegroundColor Yellow

if ($kb.modules.Count -gt 0) {
    # Gruppierung nach Typ
    $standardModules = $kb.modules | Where-Object { $_.type -eq "StandardModule" }
    $formModules = $kb.modules | Where-Object { $_.type -eq "FormModule" }
    $reportModules = $kb.modules | Where-Object { $_.type -eq "ReportModule" }
    
    Write-Host "  Standard-Module: $($standardModules.Count)" -ForegroundColor White
    $standardModules | ForEach-Object {
        Write-Host "    • $($_.name) ($($_.procedureCount) Prozeduren, $($_.lineCount) Zeilen)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "  Formular-Module: $($formModules.Count)" -ForegroundColor White
    $formModules | ForEach-Object {
        Write-Host "    • $($_.name) ($($_.procedureCount) Prozeduren)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "  Report-Module: $($reportModules.Count)" -ForegroundColor White
    $reportModules | ForEach-Object {
        Write-Host "    • $($_.name) ($($_.procedureCount) Prozeduren)" -ForegroundColor Gray
    }
} else {
    Write-Host "  (Keine Module gefunden)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "[6/6] Analysiere Beziehungen..." -ForegroundColor Green
Write-Host ""
Write-Host "Beziehungen ($($kb.relations.Count)):" -ForegroundColor Yellow

if ($kb.relations.Count -gt 0) {
    $kb.relations | ForEach-Object {
        Write-Host "  • $($_.name)" -ForegroundColor White
        Write-Host "    → $($_.table) → $($_.foreignTable)" -ForegroundColor Gray
        Write-Host "    → Typ: $($_.relationshipType)" -ForegroundColor Gray
        if ($_.properties.cascadeUpdates) {
            Write-Host "    → Cascade Updates: Ja" -ForegroundColor Gray
        }
        if ($_.properties.cascadeDeletes) {
            Write-Host "    → Cascade Deletes: Ja" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "  (Keine Beziehungen gefunden)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "ZUSAMMENFASSUNG" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Gesamtstatistiken
$totalTables = $kb.tables.Count
$totalFields = ($kb.tables | ForEach-Object { $_.fields.Count } | Measure-Object -Sum).Sum
$totalQueries = $kb.queries.Count
$totalForms = $kb.forms.Count
$totalControls = ($kb.forms | ForEach-Object { $_.controls.Count } | Measure-Object -Sum).Sum
$totalReports = $kb.reports.Count
$totalModules = $kb.modules.Count
$totalProcedures = ($kb.modules | ForEach-Object { $_.procedureCount } | Measure-Object -Sum).Sum
$totalCodeLines = ($kb.modules | ForEach-Object { $_.lineCount } | Measure-Object -Sum).Sum
$totalRelations = $kb.relations.Count

Write-Host "Tabellen:           $totalTables (mit $totalFields Feldern)" -ForegroundColor White
Write-Host "Queries:            $totalQueries" -ForegroundColor White
Write-Host "Formulare:          $totalForms (mit $totalControls Controls)" -ForegroundColor White
Write-Host "Reports:            $totalReports" -ForegroundColor White
Write-Host "VBA-Module:         $totalModules" -ForegroundColor White
Write-Host "VBA-Prozeduren:     $totalProcedures" -ForegroundColor White
Write-Host "VBA-Codezeilen:     $totalCodeLines" -ForegroundColor White
Write-Host "Beziehungen:        $totalRelations" -ForegroundColor White
Write-Host ""

# Komplexitäts-Bewertung
$complexity = "Niedrig"
if ($totalTables -gt 20 -or $totalForms -gt 30 -or $totalCodeLines -gt 5000) {
    $complexity = "Hoch"
} elseif ($totalTables -gt 10 -or $totalForms -gt 15 -or $totalCodeLines -gt 2000) {
    $complexity = "Mittel"
}

Write-Host "Komplexität:        $complexity" -ForegroundColor $(if ($complexity -eq "Hoch") { "Red" } elseif ($complexity -eq "Mittel") { "Yellow" } else { "Green" })
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✓ Analyse abgeschlossen!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

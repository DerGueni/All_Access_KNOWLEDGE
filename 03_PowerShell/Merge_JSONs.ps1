# ═══════════════════════════════════════════════════════════════════════════════
# Skript:    Merge_JSONs.ps1
# Zweck:     Fügt alle exportierten JSON-Dateien zu einer Gesamt-Wissensdatenbank zusammen
# Autor:     Access-Forensiker Agent
# Datum:     2025-10-31
# Version:   1.0
# ═══════════════════════════════════════════════════════════════════════════════

[CmdletBinding()]
param(
    [string]$ExportPath = "$env:USERPROFILE\Documents\0000_Consys_Wissen_kpl\03_Export_Ergebnisse",
    [string]$OutputFile = "Consys_FE_N_KnowledgeBase.json"
)

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Consys Knowledge Base - JSON Merger" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Prüfen ob Export-Pfad existiert
if (-not (Test-Path $ExportPath)) {
    Write-Host "✗ Fehler: Export-Pfad nicht gefunden!" -ForegroundColor Red
    Write-Host "  Pfad: $ExportPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Bitte erst VBA-Export durchführen!" -ForegroundColor Yellow
    exit 1
}

Write-Host "[1/4] Lade JSON-Dateien..." -ForegroundColor Green

# Alle JSON-Dateien sammeln
$jsonFiles = Get-ChildItem -Path $ExportPath -Filter "*.json" | Where-Object { $_.Name -ne $OutputFile }

if ($jsonFiles.Count -eq 0) {
    Write-Host "✗ Keine JSON-Dateien gefunden!" -ForegroundColor Red
    Write-Host "  Bitte erst VBA-Export durchführen." -ForegroundColor Yellow
    exit 1
}

Write-Host "  → Gefunden: $($jsonFiles.Count) Dateien" -ForegroundColor White

# Haupt-Objekt für kombinierte Daten
$knowledgeBase = [PSCustomObject]@{
    exportDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    databaseName = "Consys_FE_N_Test_Claude.accdb"
    databasePath = "C:\Users\guenther.siegert\Documents\Consys_FE_N_Test_Claude.accdb"
    exportVersion = "1.0"
    statistics = [PSCustomObject]@{}
}

Write-Host ""
Write-Host "[2/4] Verarbeite JSON-Dateien..." -ForegroundColor Green

# Jede JSON-Datei einlesen und hinzufügen
foreach ($file in $jsonFiles) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    
    Write-Host "  → $name.json" -ForegroundColor White
    
    try {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        
        # Leere oder ungültige JSONs überspringen
        if ([string]::IsNullOrWhiteSpace($content) -or $content.Trim() -eq "[]" -or $content.Trim() -eq "{}") {
            Write-Host "    ⚠ Leer oder ungültig - übersprungen" -ForegroundColor Yellow
            $knowledgeBase | Add-Member -NotePropertyName $name -NotePropertyValue @() -Force
            continue
        }
        
        # JSON parsen
        $jsonData = $content | ConvertFrom-Json
        
        # Zum Haupt-Objekt hinzufügen
        $knowledgeBase | Add-Member -NotePropertyName $name -NotePropertyValue $jsonData -Force
        
        # Statistiken sammeln
        if ($jsonData -is [Array]) {
            $count = $jsonData.Count
            Write-Host "    ✓ $count Einträge geladen" -ForegroundColor Gray
        } else {
            Write-Host "    ✓ Objekt geladen" -ForegroundColor Gray
        }
        
    } catch {
        Write-Host "    ✗ Fehler beim Parsen: $($_.Exception.Message)" -ForegroundColor Red
        $knowledgeBase | Add-Member -NotePropertyName $name -NotePropertyValue @() -Force
    }
}

Write-Host ""
Write-Host "[3/4] Erstelle Statistiken..." -ForegroundColor Green

# Statistiken berechnen
$stats = @{
    tableCount = if ($knowledgeBase.tables) { $knowledgeBase.tables.Count } else { 0 }
    queryCount = if ($knowledgeBase.queries) { $knowledgeBase.queries.Count } else { 0 }
    formCount = if ($knowledgeBase.forms) { $knowledgeBase.forms.Count } else { 0 }
    reportCount = if ($knowledgeBase.reports) { $knowledgeBase.reports.Count } else { 0 }
    moduleCount = if ($knowledgeBase.modules) { $knowledgeBase.modules.Count } else { 0 }
    relationCount = if ($knowledgeBase.relations) { $knowledgeBase.relations.Count } else { 0 }
}

$knowledgeBase.statistics = [PSCustomObject]$stats

Write-Host "  → Tabellen:    $($stats.tableCount)" -ForegroundColor White
Write-Host "  → Queries:     $($stats.queryCount)" -ForegroundColor White
Write-Host "  → Formulare:   $($stats.formCount)" -ForegroundColor White
Write-Host "  → Reports:     $($stats.reportCount)" -ForegroundColor White
Write-Host "  → Module:      $($stats.moduleCount)" -ForegroundColor White
Write-Host "  → Beziehungen: $($stats.relationCount)" -ForegroundColor White

Write-Host ""
Write-Host "[4/4] Speichere Wissensdatenbank..." -ForegroundColor Green

# Als JSON speichern
$outputPath = Join-Path $ExportPath $OutputFile

try {
    $knowledgeBase | ConvertTo-Json -Depth 20 | Set-Content -Path $outputPath -Encoding UTF8
    
    $fileSize = (Get-Item $outputPath).Length / 1MB
    
    Write-Host "  ✓ Gespeichert: $OutputFile" -ForegroundColor White
    Write-Host "  → Dateigröße: $($fileSize.ToString('0.00')) MB" -ForegroundColor Gray
    Write-Host "  → Pfad: $outputPath" -ForegroundColor Gray
    
} catch {
    Write-Host "  ✗ Fehler beim Speichern: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✓ Wissensdatenbank erfolgreich erstellt!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Nächste Schritte:" -ForegroundColor Yellow
Write-Host "  1. Datei in Claude Desktop hochladen" -ForegroundColor White
Write-Host "  2. Fragen zur Datenbank-Struktur stellen" -ForegroundColor White
Write-Host "  3. Optional: HTML-Report generieren mit Generate_Report.ps1" -ForegroundColor White
Write-Host ""

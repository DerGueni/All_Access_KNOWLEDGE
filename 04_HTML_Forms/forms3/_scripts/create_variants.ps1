# PowerShell Script to create design variants
# Erstellt 2 Design-Varianten von frm_va_Auftragstamm.html

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "  Design Variants Generator" -ForegroundColor Yellow
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""

# Pfade
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$originalFile = Join-Path $scriptDir "frm_va_Auftragstamm.html"
$outputDir = Join-Path $scriptDir "varianten_auftragstamm"

# Erstelle Output-Verzeichnis
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
    Write-Host "✓ Ordner erstellt: varianten_auftragstamm" -ForegroundColor Green
}

# Prüfe Original-Datei
if (-not (Test-Path $originalFile)) {
    Write-Host "❌ FEHLER: Original-Datei nicht gefunden!" -ForegroundColor Red
    Write-Host "   Pfad: $originalFile" -ForegroundColor Red
    exit 1
}

# Lese Original
Write-Host "Lese Original-Datei..." -ForegroundColor Cyan
$content = Get-Content $originalFile -Raw -Encoding UTF8
Write-Host "✓ Gelesen: $($content.Length) Zeichen" -ForegroundColor Green
Write-Host ""

# Python-Script ausführen
Write-Host "Führe Python-Script aus..." -ForegroundColor Cyan
$pythonScript = Join-Path $scriptDir "create_design_variants.py"

try {
    $result = python $pythonScript 2>&1
    Write-Host $result
    Write-Host ""
    Write-Host "✓ Varianten erfolgreich erstellt!" -ForegroundColor Green
} catch {
    Write-Host "❌ Fehler beim Ausführen des Python-Scripts:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "  FERTIG!" -ForegroundColor Green
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""
Write-Host "Die Varianten befinden sich in:" -ForegroundColor Yellow
Write-Host "  $outputDir" -ForegroundColor White
Write-Host ""

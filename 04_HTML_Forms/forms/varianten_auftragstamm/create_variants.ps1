# PowerShell Script zum Erstellen der Design-Varianten
# Ausfuehren: powershell -ExecutionPolicy Bypass -File create_variants.ps1

$ErrorActionPreference = "Stop"

# Pfade
$OriginalFile = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\frm_va_Auftragstamm.html"
$OutputDir = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\varianten_auftragstamm"

# Original-HTML lesen
Write-Host "Lese Original-Datei..." -ForegroundColor Cyan
$originalHtml = Get-Content -Path $OriginalFile -Raw -Encoding UTF8

# ==================================================
# VARIANTE 5: ELEGANT DARK MODE
# ==================================================
Write-Host "`nErstelle Variante 5: Dark Mode..." -ForegroundColor Yellow

$darkModeHtml = $originalHtml

# Title
$darkModeHtml = $darkModeHtml -replace '<title>Auftragsverwaltung</title>', '<title>Auftragsverwaltung - Dark Mode</title>'

# Haupt-Hintergrund
$darkModeHtml = $darkModeHtml -replace 'background-color: #8080c0;', 'background-color: #1E1E1E;'

# Title Bar
$darkModeHtml = $darkModeHtml -replace 'background: linear-gradient\(to right, #000080, #1084d0\);', 'background: linear-gradient(to right, #2D2D2D, #3D3D3D); border-bottom: 1px solid #BB86FC;'

# Menu
$darkModeHtml = $darkModeHtml -replace 'background-color: #6060a0;', 'background-color: #2D2D2D;'
$darkModeHtml = $darkModeHtml -replace 'background-color: #000080;', 'background-color: #BB86FC;'

# Buttons
$darkModeHtml = $darkModeHtml -replace 'background: linear-gradient\(to bottom, #d0d0e0, #a0a0c0\);', 'background: linear-gradient(to bottom, #3C3C3C, #2D2D2D);'
$darkModeHtml = $darkModeHtml -replace 'background: linear-gradient\(to bottom, #e8e8e8, #c0c0c0\);', 'background: linear-gradient(to bottom, #3C3C3C, #2D2D2D);'

# Content Bereiche
$darkModeHtml = $darkModeHtml -replace 'background-color: #9090c0;', 'background-color: #2D2D2D;'
$darkModeHtml = $darkModeHtml -replace 'background-color: #b8b8d8;', 'background-color: #3C3C3C;'

# Borders
$darkModeHtml = $darkModeHtml -replace 'border: 1px solid #606090;', 'border: 1px solid #4C4C4C;'

# Akzentfarbe
$darkModeHtml = $darkModeHtml -replace 'color: #000080;', 'color: #BB86FC;'

# Text
$darkModeHtml = $darkModeHtml -replace 'color: #000;', 'color: #E0E0E0;'
$darkModeHtml = $darkModeHtml -replace 'color: white;', 'color: #E0E0E0;'

# Inputs
$darkModeHtml = $darkModeHtml -replace 'background: white;', 'background: #2D2D2D; color: #E0E0E0;'
$darkModeHtml = $darkModeHtml -replace 'background: #e0e0e0;', 'background: #1E1E1E;'

# Tabellen
$darkModeHtml = $darkModeHtml -replace 'background: linear-gradient\(to bottom, #e0e0e0, #c0c0c0\);', 'background: linear-gradient(to bottom, #3C3C3C, #2D2D2D); color: #E0E0E0;'
$darkModeHtml = $darkModeHtml -replace 'background: #e0e0ff;', 'background: #3C3C4C;'

# Zell-Farben
$darkModeHtml = $darkModeHtml -replace 'background-color: #add8e6;', 'background-color: #2C4C5C;'
$darkModeHtml = $darkModeHtml -replace 'background-color: #90ee90;', 'background-color: #2C5C2C;'
$darkModeHtml = $darkModeHtml -replace 'background-color: #ffff90;', 'background-color: #5C5C2C;'
$darkModeHtml = $darkModeHtml -replace 'background-color: #ffb0b0;', 'background-color: #5C2C2C;'

# Status Bar
$darkModeHtml = $darkModeHtml -replace 'background: #c0c0c0;', 'background: #2D2D2D;'

# Datei speichern
$outputFile = Join-Path $OutputDir "variante_05_dark_mode.html"
$darkModeHtml | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline
Write-Host "✓ Gespeichert: $outputFile" -ForegroundColor Green

# ==================================================
# VARIANTE 6: CORPORATE ENTERPRISE GRAY
# ==================================================
Write-Host "`nErstelle Variante 6: Enterprise..." -ForegroundColor Yellow

$enterpriseHtml = $originalHtml

# Title
$enterpriseHtml = $enterpriseHtml -replace '<title>Auftragsverwaltung</title>', '<title>Auftragsverwaltung - Enterprise</title>'

# Haupt-Hintergrund
$enterpriseHtml = $enterpriseHtml -replace 'background-color: #8080c0;', 'background-color: #ECEFF1;'

# Title Bar
$enterpriseHtml = $enterpriseHtml -replace 'background: linear-gradient\(to right, #000080, #1084d0\);', 'background: linear-gradient(to right, #37474F, #455A64);'

# Menu
$enterpriseHtml = $enterpriseHtml -replace 'background-color: #6060a0;', 'background-color: #37474F;'
$enterpriseHtml = $enterpriseHtml -replace 'background-color: #000080;', 'background-color: #0288D1;'

# Buttons
$enterpriseHtml = $enterpriseHtml -replace 'background: linear-gradient\(to bottom, #d0d0e0, #a0a0c0\);', 'background: linear-gradient(to bottom, #CFD8DC, #B0BEC5);'
$enterpriseHtml = $enterpriseHtml -replace 'background: linear-gradient\(to bottom, #e8e8e8, #c0c0c0\);', 'background: linear-gradient(to bottom, #ECEFF1, #CFD8DC);'

# Content Bereiche
$enterpriseHtml = $enterpriseHtml -replace 'background-color: #9090c0;', 'background-color: #CFD8DC;'
$enterpriseHtml = $enterpriseHtml -replace 'background-color: #b8b8d8;', 'background-color: #ECEFF1;'

# Borders
$enterpriseHtml = $enterpriseHtml -replace 'border: 1px solid #606090;', 'border: 1px solid #90A4AE;'

# Akzentfarbe
$enterpriseHtml = $enterpriseHtml -replace 'color: #000080;', 'color: #0288D1;'

# Text bleibt dunkel (Enterprise-Look)
$enterpriseHtml = $enterpriseHtml -replace 'color: #000;', 'color: #263238;'

# Inputs
$enterpriseHtml = $enterpriseHtml -replace 'background: white;', 'background: #FFFFFF; color: #263238;'
$enterpriseHtml = $enterpriseHtml -replace 'background: #e0e0e0;', 'background: #ECEFF1;'

# Tabellen
$enterpriseHtml = $enterpriseHtml -replace 'background: linear-gradient\(to bottom, #e0e0e0, #c0c0c0\);', 'background: linear-gradient(to bottom, #CFD8DC, #B0BEC5); color: #263238;'
$enterpriseHtml = $enterpriseHtml -replace 'background: #e0e0ff;', 'background: #E1F5FE;'

# Zell-Farben
$enterpriseHtml = $enterpriseHtml -replace 'background-color: #add8e6;', 'background-color: #B3E5FC;'
$enterpriseHtml = $enterpriseHtml -replace 'background-color: #90ee90;', 'background-color: #C8E6C9;'
$enterpriseHtml = $enterpriseHtml -replace 'background-color: #ffff90;', 'background-color: #FFF9C4;'
$enterpriseHtml = $enterpriseHtml -replace 'background-color: #ffb0b0;', 'background-color: #FFCCBC;'

# Status Bar
$enterpriseHtml = $enterpriseHtml -replace 'background: #c0c0c0;', 'background: #CFD8DC;'

# Datei speichern
$outputFile = Join-Path $OutputDir "variante_06_enterprise.html"
$enterpriseHtml | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline
Write-Host "✓ Gespeichert: $outputFile" -ForegroundColor Green

# ==================================================
# FERTIG
# ==================================================
Write-Host "`n=== FERTIG ===" -ForegroundColor Cyan
Write-Host "Beide Varianten wurden erstellt:" -ForegroundColor White
Write-Host "  - variante_05_dark_mode.html" -ForegroundColor Green
Write-Host "  - variante_06_enterprise.html" -ForegroundColor Green
Write-Host "`nTesten Sie die Varianten im Browser!" -ForegroundColor Yellow

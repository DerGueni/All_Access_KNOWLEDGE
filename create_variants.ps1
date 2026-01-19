# PowerShell Script zum Erstellen der Design-Varianten
# NUR CSS wird geändert - HTML-Struktur bleibt 1:1 identisch

$originalPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\frm_va_Auftragstamm.html"
$outputDir = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\varianten_auftragstamm"

# Lese Original-HTML
$originalHtml = Get-Content -Path $originalPath -Raw -Encoding UTF8

Write-Host "Original gelesen: $($originalHtml.Length) Zeichen"

# Python-Script ausführen
$pythonScript = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\temp_create_variants.py"
python $pythonScript

Write-Host "`nVarianten erstellt!"
Write-Host "Speicherort: $outputDir"

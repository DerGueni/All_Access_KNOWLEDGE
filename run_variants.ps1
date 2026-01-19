# PowerShell Script zum Ausführen von create_variants.py
Set-Location "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE"
python create_variants.py
Write-Host "Varianten erstellt. Druecken Sie eine Taste..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

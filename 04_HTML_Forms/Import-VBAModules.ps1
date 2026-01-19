# Access VBA Module Import Script
# Importiert alle WebView2-Bridge Module in das Frontend

$fePath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb"
$vbaPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\vba"

Write-Host "=== ACCESS VBA MODULE IMPORT ===" -ForegroundColor Yellow

# Access-Anwendung starten
$access = $null
try {
    $access = New-Object -ComObject Access.Application
    $access.Visible = $true
    Write-Host "✅ Access gestartet" -ForegroundColor Green
    
    # Datenbank öffnen
    $access.OpenCurrentDatabase($fePath)
    Write-Host "✅ Datenbank geöffnet: $fePath" -ForegroundColor Green
    
    # VBE Zugriff
    $vbe = $access.VBE
    $project = $vbe.ActiveVBProject
    
    Write-Host "`nImportiere Module..." -ForegroundColor Cyan
    
    # Module importieren
    $modules = @(
        "mdl_N_DataService_Complete.bas",
        "mdl_N_DataService_Kunden.bas",
        "mdl_N_WebView2Bridge_V4.bas"
    )
    
    foreach ($module in $modules) {
        $modulePath = Join-Path $vbaPath $module
        if (Test-Path $modulePath) {
            try {
                # Prüfe ob Modul bereits existiert
                $moduleName = [System.IO.Path]::GetFileNameWithoutExtension($module)
                $existing = $null
                try {
                    $existing = $project.VBComponents.Item($moduleName)
                } catch {}
                
                if ($existing) {
                    Write-Host "   ⚠️ $moduleName existiert bereits - überspringe" -ForegroundColor Yellow
                } else {
                    $project.VBComponents.Import($modulePath)
                    Write-Host "   ✅ $module importiert" -ForegroundColor Green
                }
            } catch {
                Write-Host "   ❌ Fehler bei $module : $_" -ForegroundColor Red
            }
        } else {
            Write-Host "   ❌ $module nicht gefunden" -ForegroundColor Red
        }
    }
    
    # Datenbank speichern und schließen
    $access.CloseCurrentDatabase()
    Write-Host "`n✅ Import abgeschlossen" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Fehler: $_" -ForegroundColor Red
} finally {
    if ($access) {
        $access.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($access) | Out-Null
    }
}

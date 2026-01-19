# PowerShell Verifikation
$dbPath = "C:\Users\guenther.siegert\Documents\Consys_FE_N_Test_Claude_GPT.accdb"

Write-Host "=== VERIFIKATION: Auto-Festangestellte ===" -ForegroundColor Cyan
Write-Host ""

try {
    $access = New-Object -ComObject Access.Application
    $access.Visible = $false
    $access.OpenCurrentDatabase($dbPath)
    
    # Modul prüfen
    Write-Host "Prüfe VBA-Module..." -ForegroundColor Yellow
    $modulFound = $false
    foreach ($module in $access.CurrentProject.AllModules) {
        if ($module.Name -eq "mdl_Auto_Festangestellte") {
            Write-Host "  [OK] Modul 'mdl_Auto_Festangestellte' gefunden" -ForegroundColor Green
            $modulFound = $true
        }
    }
    if (-not $modulFound) {
        Write-Host "  [FEHLT] Modul 'mdl_Auto_Festangestellte' nicht gefunden!" -ForegroundColor Red
    }
    
    # Formular prüfen
    Write-Host "`nPrüfe Formulare..." -ForegroundColor Yellow
    $formFound = $false
    foreach ($form in $access.CurrentProject.AllForms) {
        if ($form.Name -eq "frm_menuefuehrung1") {
            Write-Host "  [OK] Formular 'frm_menuefuehrung1' gefunden" -ForegroundColor Green
            $formFound = $true
        }
    }
    if (-not $formFound) {
        Write-Host "  [FEHLT] Formular 'frm_menuefuehrung1' nicht gefunden!" -ForegroundColor Red
    }
    
    # Button im Formular prüfen
    if ($formFound) {
        Write-Host "`nPrüfe Button im Formular..." -ForegroundColor Yellow
        try {
            $access.DoCmd.OpenForm("frm_menuefuehrung1", 2) # Design View
            $form = $access.Forms("frm_menuefuehrung1")
            
            $buttonFound = $false
            foreach ($ctrl in $form.Controls) {
                if ($ctrl.Name -eq "cmd_Auto_Festangestellte") {
                    Write-Host "  [OK] Button 'cmd_Auto_Festangestellte' gefunden" -ForegroundColor Green
                    Write-Host "       Beschriftung: $($ctrl.Caption)" -ForegroundColor Gray
                    $buttonFound = $true
                    break
                }
            }
            
            if (-not $buttonFound) {
                Write-Host "  [FEHLT] Button 'cmd_Auto_Festangestellte' nicht gefunden!" -ForegroundColor Red
            }
            
            $access.DoCmd.Close(2, "frm_menuefuehrung1", 2) # Close without saving
            
        } catch {
            Write-Host "  [FEHLER] Konnte Formular nicht öffnen: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    $access.CloseCurrentDatabase()
    $access.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($access) | Out-Null
    
    Write-Host "`n=== VERIFIKATION ABGESCHLOSSEN ===" -ForegroundColor Cyan
    
} catch {
    Write-Host "`n[FEHLER] $($_.Exception.Message)" -ForegroundColor Red
    if ($access) {
        $access.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($access) | Out-Null
    }
}

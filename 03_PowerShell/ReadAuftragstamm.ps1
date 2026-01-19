# Beende alle Access Prozesse zuerst
Get-Process MSACCESS -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

$accApp = New-Object -ComObject Access.Application
$accApp.Visible = $true
$dbPath = "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"

try {
    $accApp.OpenCurrentDatabase($dbPath)
    Write-Host "Datenbank geoeffnet: $dbPath"
    Start-Sleep -Seconds 5

    # Versuche VBA Code zu lesen
    $vbaCode = $accApp.Run("GetFormModuleCode", "frm_VA_Auftragstamm")
    Write-Host $vbaCode
} catch {
    Write-Host "Fehler mit Run: $($_.Exception.Message)"

    # Alternative: Direkt per DoCmd lesen
    try {
        # Suche nach existierenden Modulen
        $accApp.DoCmd.OpenModule "mdl_Bridge_Helper"
        Write-Host "Modul mdl_Bridge_Helper geoeffnet"
    } catch {
        Write-Host "Konnte Modul nicht oeffnen: $($_.Exception.Message)"
    }
}

Start-Sleep -Seconds 3
try { $accApp.Quit() } catch {}
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($accApp) | Out-Null
Write-Host "Script beendet"

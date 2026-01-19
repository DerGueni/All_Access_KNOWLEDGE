$accApp = New-Object -ComObject Access.Application
$accApp.Visible = $true
$accApp.OpenCurrentDatabase("S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb")
Start-Sleep -Seconds 5

try {
    $vbe = $accApp.VBE
    Write-Host "VBE gefunden"

    # Liste alle VBProjects
    $count = $vbe.VBProjects.Count
    Write-Host "Anzahl VBProjects: $count"

    if ($count -gt 0) {
        $proj = $vbe.VBProjects.Item(1)
        Write-Host "Projekt: $($proj.Name)"

        # Liste alle Module
        foreach ($comp in $proj.VBComponents) {
            Write-Host "Modul gefunden: $($comp.Name) - Type: $($comp.Type)"
            if ($comp.Name -eq "mdl_Bridge_Helper") {
                $lineCount = $comp.CodeModule.CountOfLines
                Write-Host "Zeilen: $lineCount"
                if ($lineCount -gt 0) {
                    $code = $comp.CodeModule.Lines(1, $lineCount)
                    Write-Host "=== mdl_Bridge_Helper Code ==="
                    Write-Host $code
                }
            }
        }
    }
} catch {
    Write-Host "Fehler: $_"
    Write-Host $_.Exception.Message
}

Start-Sleep -Seconds 2
$accApp.CloseCurrentDatabase()
$accApp.Quit()
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($accApp) | Out-Null
Write-Host "Fertig"

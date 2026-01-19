# Schliesse das Frontend
try {
    $acc = [System.Runtime.InteropServices.Marshal]::GetActiveObject('Access.Application')
    $acc.CloseCurrentDatabase()
    Start-Sleep -Seconds 3
    $acc.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($acc) | Out-Null
    Start-Sleep -Seconds 2
} catch {
    Write-Host "Frontend konnte nicht geschlossen werden: $_"
}

# Warte bis Access beendet ist
Start-Sleep -Seconds 3

# Oeffne Backend direkt und fuege Felder hinzu
$accBE = New-Object -ComObject Access.Application
$accBE.Visible = $false
$accBE.OpenCurrentDatabase('C:\Users\guenther.siegert\Documents\1__Projektordner\Consec_BE_TEST.accdb')

# SQL zum Hinzufuegen der Felder (mit SetWarnings False)
$accBE.DoCmd.SetWarnings($false)

$fields = @('Zeit1_Label', 'Zeit2_Label', 'Zeit3_Label', 'Zeit4_Label')
foreach ($field in $fields) {
    try {
        $sql = "ALTER TABLE tbl_OB_Objekt ADD COLUMN $field TEXT(20)"
        $accBE.DoCmd.RunSQL($sql)
        Write-Host "$field hinzugefuegt"
    } catch {
        Write-Host "$field existiert bereits oder Fehler: $($_.Exception.Message)"
    }
}

$accBE.DoCmd.SetWarnings($true)
$accBE.CloseCurrentDatabase()
$accBE.Quit()
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($accBE) | Out-Null

Write-Host "Backend aktualisiert"

# Warte kurz
Start-Sleep -Seconds 2

# Oeffne Frontend wieder
Start-Process 'C:\Users\guenther.siegert\Documents\Consys_FE_N_Test_Claude.accdb'
Write-Host "Frontend wird geoeffnet"

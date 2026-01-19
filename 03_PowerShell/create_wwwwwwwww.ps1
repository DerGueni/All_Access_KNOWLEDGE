# Auftrag WWWWWWWWW erstellen
# Datum: 30.11.2025, 2 MA, 18:00-23:00

$dbPath = "C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"

$auftragData = @{
    AuftragName = "WWWWWWWWW"
    Objekt = "Stadionpark"
    Ort = "Nürnberg"
    Datum = "2025-11-30"
    MaAnzahl = 2
    StartZeit = "18:00"
    EndZeit = "23:00"
    Bemerkungen = ""
}

try {
    $accessApp = New-Object -ComObject Access.Application
    $accessApp.Visible = $false
    $accessApp.OpenCurrentDatabase($dbPath)
    
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "AUFTRAGSERSTELLUNG" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "Auftrag: $($auftragData.AuftragName)"
    Write-Host "Objekt: $($auftragData.Objekt)"
    Write-Host "Ort: $($auftragData.Ort)"
    Write-Host "Datum: $($auftragData.Datum)"
    Write-Host "Zeit: $($auftragData.StartZeit) - $($auftragData.EndZeit)"
    Write-Host "Mitarbeiter: $($auftragData.MaAnzahl)"
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Schritt 1: Auftrag
    Write-Host "Schritt 1: Erstelle Auftrag..." -ForegroundColor Yellow
    $sql1 = "INSERT INTO tbl_VA_Auftragstamm (Auftrag, Objekt, Ort, Dat_VA_Von, Dat_VA_Bis, AnzTg, Erst_von, Erst_am, Veranst_Status_ID) VALUES ('$($auftragData.AuftragName)', '$($auftragData.Objekt)', '$($auftragData.Ort)', #$($auftragData.Datum)#, #$($auftragData.Datum)#, 1, '$env:USERNAME', Now(), 1)"
    $accessApp.CurrentDb().Execute($sql1)
    
    # Schritt 2: VA_ID
    Write-Host "Schritt 2: Ermittle VA_ID..." -ForegroundColor Yellow
    $rs = $accessApp.CurrentDb().OpenRecordset("SELECT MAX(ID) AS NewID FROM tbl_VA_Auftragstamm WHERE Auftrag = '$($auftragData.AuftragName)'")
    $vaId = $rs.Fields("NewID").Value
    $rs.Close()
    Write-Host "  -> VA_ID: $vaId" -ForegroundColor Green
    
    # Schritt 3: AnzTage
    Write-Host "Schritt 3: Erstelle VA_AnzTage..." -ForegroundColor Yellow
    $sql2 = "INSERT INTO tbl_VA_AnzTage (VA_ID, VADatum, TVA_Soll, TVA_Ist) VALUES ($vaId, #$($auftragData.Datum)#, $($auftragData.MaAnzahl), 0)"
    $accessApp.CurrentDb().Execute($sql2)
    
    # Schritt 4: VADatum_ID
    Write-Host "Schritt 4: Ermittle VADatum_ID..." -ForegroundColor Yellow
    $rs = $accessApp.CurrentDb().OpenRecordset("SELECT ID FROM tbl_VA_AnzTage WHERE VA_ID = $vaId")
    $vaDatumId = $rs.Fields("ID").Value
    $rs.Close()
    Write-Host "  -> VADatum_ID: $vaDatumId" -ForegroundColor Green
    
    # Schritt 5: VA_Start
    Write-Host "Schritt 5: Erstelle VA_Start..." -ForegroundColor Yellow
    $startDateTime = "$($auftragData.Datum) $($auftragData.StartZeit):00"
    $endDateTime = "$($auftragData.Datum) $($auftragData.EndZeit):00"
    $sql3 = "INSERT INTO tbl_VA_Start (VA_ID, VADatum_ID, VADatum, MA_Anzahl, VA_Start, VA_Ende, MVA_Start, MVA_Ende) VALUES ($vaId, $vaDatumId, #$($auftragData.Datum)#, $($auftragData.MaAnzahl), #$($auftragData.StartZeit):00#, #$($auftragData.EndZeit):00#, #$startDateTime#, #$endDateTime#)"
    $accessApp.CurrentDb().Execute($sql3)
    
    $rs = $accessApp.CurrentDb().OpenRecordset("SELECT MAX(ID) AS MaxID FROM tbl_VA_Start WHERE VA_ID = $vaId")
    $vaStartId = $rs.Fields("MaxID").Value
    $rs.Close()
    Write-Host "  -> VAStart_ID: $vaStartId" -ForegroundColor Green
    
    # Verifizierung
    Write-Host "`nVerifizierung..." -ForegroundColor Yellow
    $rs = $accessApp.CurrentDb().OpenRecordset("SELECT ID, Datum, Auftrag, Objekt, Ort, Soll FROM qry_lst_Row_Auftrag WHERE ID = $vaId")
    
    if (-not $rs.EOF) {
        Write-Host "OK: Auftrag in qry_lst_Row_Auftrag sichtbar!" -ForegroundColor Green
        Write-Host "  Datum: $($rs.Fields('Datum').Value)"
        Write-Host "  Auftrag: $($rs.Fields('Auftrag').Value)"
        Write-Host "  Objekt: $($rs.Fields('Objekt').Value)"
        Write-Host "  Ort: $($rs.Fields('Ort').Value)"
        Write-Host "  Soll: $($rs.Fields('Soll').Value)"
    } else {
        Write-Host "WARNUNG: Nicht in Query sichtbar!" -ForegroundColor Red
    }
    $rs.Close()
    
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "ERGEBNIS" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "VA_ID: $vaId"
    Write-Host "VADatum_ID: $vaDatumId"
    Write-Host "VAStart_ID: $vaStartId"
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "OK: Auftragserstellung erfolgreich!" -ForegroundColor Green
    
} catch {
    Write-Host ""
    Write-Host "FEHLER: $_" -ForegroundColor Red
    Write-Host $_.Exception.ToString()
} finally {
    if ($accessApp) {
        $accessApp.Quit()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($accessApp) | Out-Null
    }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}

# Auftrag WWWWWWWWW erstellen - DAO-Methode

$dbPath = "C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"

$auftragData = @{
    AuftragName = "WWWWWWWWW"
    Objekt = "Stadionpark"
    Ort = "Nürnberg"
    Datum = "2025-11-30"
    MaAnzahl = 2
    StartZeit = "18:00"
    EndZeit = "23:00"
}

try {
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "AUFTRAGSERSTELLUNG - DAO-Methode" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "Auftrag: $($auftragData.AuftragName)"
    Write-Host "Objekt: $($auftragData.Objekt)"
    Write-Host "Ort: $($auftragData.Ort)"
    Write-Host "Datum: $($auftragData.Datum)"
    Write-Host "Zeit: $($auftragData.StartZeit) - $($auftragData.EndZeit)"
    Write-Host "Mitarbeiter: $($auftragData.MaAnzahl)"
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # DAO DBEngine verwenden statt Access.Application
    Write-Host "Erstelle DAO.DBEngine..." -ForegroundColor Yellow
    $dbEngine = New-Object -ComObject DAO.DBEngine.120
    $db = $dbEngine.OpenDatabase($dbPath)
    Write-Host "OK: Datenbank geöffnet" -ForegroundColor Green
    
    # Schritt 1: Auftrag
    Write-Host "`nSchritt 1: Erstelle Auftrag..." -ForegroundColor Yellow
    $sql1 = "INSERT INTO tbl_VA_Auftragstamm (Auftrag, Objekt, Ort, Dat_VA_Von, Dat_VA_Bis, AnzTg, Erst_von, Erst_am, Veranst_Status_ID) VALUES ('$($auftragData.AuftragName)', '$($auftragData.Objekt)', '$($auftragData.Ort)', #$($auftragData.Datum)#, #$($auftragData.Datum)#, 1, '$env:USERNAME', Now(), 1)"
    $db.Execute($sql1)
    Write-Host "OK: Auftrag erstellt" -ForegroundColor Green
    
    # Schritt 2: VA_ID
    Write-Host "`nSchritt 2: Ermittle VA_ID..." -ForegroundColor Yellow
    $rs = $db.OpenRecordset("SELECT MAX(ID) AS NewID FROM tbl_VA_Auftragstamm WHERE Auftrag = '$($auftragData.AuftragName)'")
    $vaId = $rs.Fields("NewID").Value
    $rs.Close()
    Write-Host "OK: VA_ID = $vaId" -ForegroundColor Green
    
    # Schritt 3: AnzTage
    Write-Host "`nSchritt 3: Erstelle VA_AnzTage..." -ForegroundColor Yellow
    $sql2 = "INSERT INTO tbl_VA_AnzTage (VA_ID, VADatum, TVA_Soll, TVA_Ist) VALUES ($vaId, #$($auftragData.Datum)#, $($auftragData.MaAnzahl), 0)"
    $db.Execute($sql2)
    Write-Host "OK: VA_AnzTage erstellt" -ForegroundColor Green
    
    # Schritt 4: VADatum_ID
    Write-Host "`nSchritt 4: Ermittle VADatum_ID..." -ForegroundColor Yellow
    $rs = $db.OpenRecordset("SELECT ID FROM tbl_VA_AnzTage WHERE VA_ID = $vaId")
    $vaDatumId = $rs.Fields("ID").Value
    $rs.Close()
    Write-Host "OK: VADatum_ID = $vaDatumId" -ForegroundColor Green
    
    # Schritt 5: VA_Start
    Write-Host "`nSchritt 5: Erstelle VA_Start..." -ForegroundColor Yellow
    $startDateTime = "$($auftragData.Datum) $($auftragData.StartZeit):00"
    $endDateTime = "$($auftragData.Datum) $($auftragData.EndZeit):00"
    $sql3 = "INSERT INTO tbl_VA_Start (VA_ID, VADatum_ID, VADatum, MA_Anzahl, VA_Start, VA_Ende, MVA_Start, MVA_Ende) VALUES ($vaId, $vaDatumId, #$($auftragData.Datum)#, $($auftragData.MaAnzahl), #$($auftragData.StartZeit):00#, #$($auftragData.EndZeit):00#, #$startDateTime#, #$endDateTime#)"
    $db.Execute($sql3)
    Write-Host "OK: VA_Start erstellt" -ForegroundColor Green
    
    $rs = $db.OpenRecordset("SELECT MAX(ID) AS MaxID FROM tbl_VA_Start WHERE VA_ID = $vaId")
    $vaStartId = $rs.Fields("MaxID").Value
    $rs.Close()
    Write-Host "OK: VAStart_ID = $vaStartId" -ForegroundColor Green
    
    # Verifizierung
    Write-Host "`nVerifizierung..." -ForegroundColor Yellow
    $rs = $db.OpenRecordset("SELECT ID, Datum, Auftrag, Objekt, Ort, Soll FROM qry_lst_Row_Auftrag WHERE ID = $vaId")
    
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
    Write-Host "ERFOLGREICH: Auftrag WWWWWWWWW erstellt!" -ForegroundColor Green
    
    $db.Close()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($db) | Out-Null
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($dbEngine) | Out-Null
    
} catch {
    Write-Host ""
    Write-Host "FEHLER: $_" -ForegroundColor Red
    Write-Host $_.Exception.ToString()
} finally {
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}

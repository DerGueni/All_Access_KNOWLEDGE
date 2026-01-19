# Auftrag mit Mitarbeitern und Schichten anlegen
# Beispiel: 2 Mitarbeiter, 18:00-23:00

param(
    [string]$AuftragName = "TEST_PS_$(Get-Date -Format 'HHmmss')",
    [string]$Objekt = "Test Objekt",
    [string]$Ort = "Test Ort", 
    [string]$Datum = "2025-11-10",
    [int]$MaAnzahl = 2,
    [string]$StartZeit = "18:00",
    [string]$EndZeit = "23:00",
    [string]$Bemerkungen = ""
)

$ErrorActionPreference = "Stop"

function Create-AuftragWithShifts {
    param(
        [string]$DbPath,
        [hashtable]$AuftragData
    )
    
    try {
        # Access COM-Objekt erstellen
        $accessApp = New-Object -ComObject Access.Application
        $accessApp.Visible = $false
        $accessApp.OpenCurrentDatabase($DbPath)
        
        Write-Host "=" -NoNewline -ForegroundColor Cyan
        Write-Host ("=" * 59) -ForegroundColor Cyan
        Write-Host "AUFTRAGSERSTELLUNG - VOLLAUTOMATISCH" -ForegroundColor Cyan
        Write-Host ("=" * 60) -ForegroundColor Cyan
        Write-Host "Auftrag: $($AuftragData.AuftragName)"
        Write-Host "Datum: $($AuftragData.Datum)"
        Write-Host "Zeit: $($AuftragData.StartZeit) - $($AuftragData.EndZeit)"
        Write-Host "Mitarbeiter: $($AuftragData.MaAnzahl)"
        Write-Host ("=" * 60) -ForegroundColor Cyan
        Write-Host ""
        
        # Schritt 1: Auftrag in tbl_VA_Auftragstamm erstellen
        Write-Host "Schritt 1: Erstelle Auftrag '$($AuftragData.AuftragName)'..." -ForegroundColor Yellow
        
        $auftragSql = "INSERT INTO tbl_VA_Auftragstamm (Auftrag, Objekt, Ort, Dat_VA_Von, Dat_VA_Bis, AnzTg, Erst_von, Erst_am, Veranst_Status_ID) VALUES ('$($AuftragData.AuftragName)', '$($AuftragData.Objekt)', '$($AuftragData.Ort)', #$($AuftragData.Datum)#, #$($AuftragData.Datum)#, 1, '$env:USERNAME', Now(), 1)"
        $accessApp.CurrentDb().Execute($auftragSql)
        
        # Schritt 2: VA_ID ermitteln
        Write-Host "Schritt 2: Ermittle VA_ID..." -ForegroundColor Yellow
        
        $rs = $accessApp.CurrentDb().OpenRecordset("SELECT MAX(ID) AS NewID FROM tbl_VA_Auftragstamm WHERE Auftrag = '$($AuftragData.AuftragName)'")
        $vaId = $rs.Fields("NewID").Value
        $rs.Close()
        Write-Host "  -> VA_ID: $vaId" -ForegroundColor Green
        
        # Schritt 3: Eintrag in tbl_VA_AnzTage erstellen
        Write-Host "Schritt 3: Erstelle VA_AnzTage Eintrag..." -ForegroundColor Yellow
        
        $anztageSql = "INSERT INTO tbl_VA_AnzTage (VA_ID, VADatum, TVA_Soll, TVA_Ist) VALUES ($vaId, #$($AuftragData.Datum)#, $($AuftragData.MaAnzahl), 0)"
        $accessApp.CurrentDb().Execute($anztageSql)
        
        # Schritt 4: VADatum_ID ermitteln
        Write-Host "Schritt 4: Ermittle VADatum_ID..." -ForegroundColor Yellow
        
        $rs = $accessApp.CurrentDb().OpenRecordset("SELECT ID FROM tbl_VA_AnzTage WHERE VA_ID = $vaId")
        $vaDatumId = $rs.Fields("ID").Value
        $rs.Close()
        Write-Host "  -> VADatum_ID: $vaDatumId" -ForegroundColor Green
        
        # Schritt 5: Mitarbeiter und Zeiten in tbl_VA_Start eintragen
        Write-Host "Schritt 5: Erstelle VA_Start Eintrag..." -ForegroundColor Yellow
        
        $startDateTime = "$($AuftragData.Datum) $($AuftragData.StartZeit):00"
        $endDateTime = "$($AuftragData.Datum) $($AuftragData.EndZeit):00"
        
        $vastartSql = "INSERT INTO tbl_VA_Start (VA_ID, VADatum_ID, VADatum, MA_Anzahl, VA_Start, VA_Ende, MVA_Start, MVA_Ende, Bemerkungen) VALUES ($vaId, $vaDatumId, #$($AuftragData.Datum)#, $($AuftragData.MaAnzahl), #$($AuftragData.StartZeit):00#, #$($AuftragData.EndZeit):00#, #$startDateTime#, #$endDateTime#, '$($AuftragData.Bemerkungen)')"
        $accessApp.CurrentDb().Execute($vastartSql)
        
        # VAStart_ID ermitteln
        $rs = $accessApp.CurrentDb().OpenRecordset("SELECT MAX(ID) AS MaxID FROM tbl_VA_Start WHERE VA_ID = $vaId")
        $vaStartId = $rs.Fields("MaxID").Value
        $rs.Close()
        Write-Host "  -> VAStart_ID: $vaStartId" -ForegroundColor Green
        
        # Verifizierung
        Write-Host "`nVerifizierung..." -ForegroundColor Yellow
        
        $verifySql = "SELECT ID, Datum, Auftrag, Objekt, Ort, Soll, Ist, Status FROM qry_lst_Row_Auftrag WHERE ID = $vaId"
        $rs = $accessApp.CurrentDb().OpenRecordset($verifySql)
        
        if (-not $rs.EOF) {
            Write-Host "OK: Auftrag erfolgreich in qry_lst_Row_Auftrag sichtbar!" -ForegroundColor Green
            Write-Host "  Datum: $($rs.Fields('Datum').Value)"
            Write-Host "  Auftrag: $($rs.Fields('Auftrag').Value)"
            Write-Host "  Soll: $($rs.Fields('Soll').Value)"
        } else {
            Write-Host "WARNUNG: Auftrag nicht in qry_lst_Row_Auftrag sichtbar!" -ForegroundColor Red
        }
        $rs.Close()
        
        # Ergebnis
        Write-Host ""
        Write-Host ("=" * 60) -ForegroundColor Cyan
        Write-Host "ERGEBNIS" -ForegroundColor Cyan
        Write-Host ("=" * 60) -ForegroundColor Cyan
        Write-Host "VA_ID: $vaId"
        Write-Host "VADatum_ID: $vaDatumId"
        Write-Host "VAStart_ID: $vaStartId"
        Write-Host ("=" * 60) -ForegroundColor Cyan
        
        return @{
            VA_ID = $vaId
            VADatum_ID = $vaDatumId
            VAStart_ID = $vaStartId
            Success = $true
        }
        
    } catch {
        Write-Host "FEHLER: $_" -ForegroundColor Red
        return @{Success = $false; Error = $_.Exception.Message}
    } finally {
        if ($accessApp) {
            $accessApp.Quit()
            [System.Runtime.InteropServices.Marshal]::ReleaseComObject($accessApp) | Out-Null
        }
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
    }
}

# Hauptausfuehrung
$dbPath = "C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"

$auftragData = @{
    AuftragName = $AuftragName
    Objekt = $Objekt
    Ort = $Ort
    Datum = $Datum
    MaAnzahl = $MaAnzahl
    StartZeit = $StartZeit
    EndZeit = $EndZeit
    Bemerkungen = $Bemerkungen
}

$result = Create-AuftragWithShifts -DbPath $dbPath -AuftragData $auftragData

if ($result.Success) {
    Write-Host "`nOK: Auftragserstellung erfolgreich abgeschlossen!" -ForegroundColor Green
} else {
    Write-Host "`nFEHLER bei Auftragserstellung: $($result.Error)" -ForegroundColor Red
    exit 1
}

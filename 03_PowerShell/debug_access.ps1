# Debug: Teste Access-Verbindung

$dbPath = "C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"

Write-Host "Debug: Teste Access-Verbindung..." -ForegroundColor Yellow
Write-Host "DB-Pfad: $dbPath"

# Test 1: Datei existiert?
if (Test-Path $dbPath) {
    Write-Host "OK: Datenbank-Datei existiert" -ForegroundColor Green
} else {
    Write-Host "FEHLER: Datenbank-Datei nicht gefunden!" -ForegroundColor Red
    exit 1
}

# Test 2: Access COM erstellen
try {
    Write-Host "`nTest 2: Erstelle Access COM-Objekt..."
    $accessApp = New-Object -ComObject Access.Application
    Write-Host "OK: Access COM-Objekt erstellt" -ForegroundColor Green
    
    # Test 3: Datenbank öffnen
    Write-Host "`nTest 3: Öffne Datenbank..."
    $accessApp.OpenCurrentDatabase($dbPath)
    Write-Host "OK: Datenbank geöffnet" -ForegroundColor Green
    
    # Test 4: CurrentDb() prüfen
    Write-Host "`nTest 4: Prüfe CurrentDb()..."
    $db = $accessApp.CurrentDb()
    if ($db) {
        Write-Host "OK: CurrentDb() verfügbar" -ForegroundColor Green
    } else {
        Write-Host "FEHLER: CurrentDb() ist NULL!" -ForegroundColor Red
    }
    
    # Test 5: Einfache Query
    Write-Host "`nTest 5: Führe Test-Query aus..."
    $rs = $db.OpenRecordset("SELECT COUNT(*) AS Cnt FROM tbl_VA_Auftragstamm")
    $count = $rs.Fields("Cnt").Value
    $rs.Close()
    Write-Host "OK: Anzahl Aufträge: $count" -ForegroundColor Green
    
    # Test 6: INSERT-Test
    Write-Host "`nTest 6: Teste INSERT..."
    $testName = "DEBUG_TEST_$(Get-Date -Format 'HHmmss')"
    $sql = "INSERT INTO tbl_VA_Auftragstamm (Auftrag, Objekt, Ort, Dat_VA_Von, Dat_VA_Bis, AnzTg, Erst_von, Erst_am, Veranst_Status_ID) VALUES ('$testName', 'Debug', 'Test', #2025-11-30#, #2025-11-30#, 1, '$env:USERNAME', Now(), 1)"
    
    Write-Host "SQL: $sql"
    $db.Execute($sql)
    Write-Host "OK: INSERT erfolgreich" -ForegroundColor Green
    
    # Test 7: ID abrufen
    Write-Host "`nTest 7: Hole neue ID..."
    $rs = $db.OpenRecordset("SELECT MAX(ID) AS NewID FROM tbl_VA_Auftragstamm WHERE Auftrag = '$testName'")
    $newId = $rs.Fields("NewID").Value
    $rs.Close()
    Write-Host "OK: Neue VA_ID: $newId" -ForegroundColor Green
    
    Write-Host "`n============================================" -ForegroundColor Cyan
    Write-Host "ALLE TESTS ERFOLGREICH!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Cyan
    
    $accessApp.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($accessApp) | Out-Null
    
} catch {
    Write-Host "`nFEHLER: $_" -ForegroundColor Red
    Write-Host $_.Exception.ToString()
    
    if ($accessApp) {
        $accessApp.Quit()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($accessApp) | Out-Null
    }
}

[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

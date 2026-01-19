@echo off
echo ================================================
echo AUFTRAGSERSTELLUNG - DIREKTER TEST
echo ================================================

set "DB=C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"
set "AUFTRAG=TEST_CMD_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%"
set "DATUM=2025-11-10"

echo Auftrag: %AUFTRAG%
echo Datum: %DATUM%
echo.

echo Fuehre PowerShell-Befehl aus...

powershell -ExecutionPolicy Bypass -Command ^
"$db='%DB%'; $auf='%AUFTRAG%'; $dat='%DATUM%'; $acc=New-Object -ComObject Access.Application; $acc.Visible=$false; $acc.OpenCurrentDatabase($db); $acc.CurrentDb().Execute(\"INSERT INTO tbl_VA_Auftragstamm (Auftrag,Objekt,Ort,Dat_VA_Von,Dat_VA_Bis,AnzTg,Erst_von,Erst_am,Veranst_Status_ID) VALUES ('$auf','Test','Nbg',#$dat#,#$dat#,1,'$env:USERNAME',Now(),1)\"); $rs=$acc.CurrentDb().OpenRecordset(\"SELECT MAX(ID) AS N FROM tbl_VA_Auftragstamm WHERE Auftrag='$auf'\"); $id=$rs.Fields('N').Value; $rs.Close(); Write-Host \"VA_ID: $id\"; $acc.CurrentDb().Execute(\"INSERT INTO tbl_VA_AnzTage (VA_ID,VADatum,TVA_Soll,TVA_Ist) VALUES ($id,#$dat#,2,0)\"); $rs=$acc.CurrentDb().OpenRecordset(\"SELECT ID FROM tbl_VA_AnzTage WHERE VA_ID=$id\"); $did=$rs.Fields('ID').Value; $rs.Close(); Write-Host \"VADatum_ID: $did\"; $acc.CurrentDb().Execute(\"INSERT INTO tbl_VA_Start (VA_ID,VADatum_ID,VADatum,MA_Anzahl,VA_Start,VA_Ende,MVA_Start,MVA_Ende) VALUES ($id,$did,#$dat#,2,#18:00:00#,#23:00:00#,#$dat 18:00:00#,#$dat 23:00:00#)\"); $rs=$acc.CurrentDb().OpenRecordset(\"SELECT * FROM qry_lst_Row_Auftrag WHERE ID=$id\"); if(-not $rs.EOF){Write-Host 'OK: In Query sichtbar'}else{Write-Host 'WARNUNG: Nicht in Query'}; $rs.Close(); $acc.Quit(); Write-Host 'Fertig'"

echo.
echo ================================================
echo Test abgeschlossen
echo ================================================
pause

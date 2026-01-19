Private Type tSchicht
    Standort As String
    Datum As Date
    StartZeit As Date
    EndeZeit As Date
End Type

Public Sub ImportSpielwarenmesse()
    On Error GoTo ErrHandler
    
    Dim xlApp As Object, xlWb As Object
    Dim colSchichten As Collection, colFiles As Collection
    Dim newVA_ID As Long, parsedFiles As String, filePath As Variant
    
    Debug.Print "===== START ====="
    
    Set colFiles = New Collection
    With Application.FileDialog(3)
        .title = "Spielwarenmesse Excel-Dateien auswählen"
        .Filters.clear
        .Filters.Add "Excel", "*.xlsx"
        .AllowMultiSelect = True
        If .Show = -1 Then
            Dim i As Long
            For i = 1 To .SelectedItems.Count
                colFiles.Add .SelectedItems(i)
                Debug.Print "Datei: " & .SelectedItems(i)
            Next i
        Else
            Exit Sub
        End If
    End With
    
    If colFiles.Count = 0 Then Exit Sub
    
    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = False
    xlApp.DisplayAlerts = False
    
    Set colSchichten = New Collection
    
    For Each filePath In colFiles
        Set xlWb = xlApp.Workbooks.Open(CStr(filePath), ReadOnly:=True)
        Debug.Print "Verarbeite: " & xlWb.Name
        ParseExcelWorkbook xlWb, colSchichten
        parsedFiles = parsedFiles & vbCrLf & "  - " & xlWb.Name
        xlWb.Close False
    Next filePath
    
    xlApp.Quit
    Set xlApp = Nothing
    
    Debug.Print "===== ERGEBNIS: " & colSchichten.Count & " Schichten ====="
    
    If colSchichten.Count = 0 Then
        MsgBox "Keine Schichten gefunden!", vbExclamation
        Exit Sub
    End If
    
    newVA_ID = ExecuteImport(colSchichten)
    
    If newVA_ID > 0 Then
        Dim gruppiert As Object
        Set gruppiert = GruppiereSchichten(colSchichten)
        MsgBox "Import erfolgreich!" & vbCrLf & vbCrLf & _
               "VA_ID: " & newVA_ID & vbCrLf & _
               "Dateien:" & parsedFiles & vbCrLf & _
               "MA-Positionen: " & colSchichten.Count & vbCrLf & _
               "Schichtblöcke: " & gruppiert.Count, vbInformation
    End If
    
    Exit Sub
ErrHandler:
    Debug.Print "!!! FEHLER: " & Err.description
    MsgBox "Fehler: " & Err.description, vbCritical
End Sub

Private Sub ParseExcelWorkbook(ByVal wb As Object, ByRef colSchichten As Collection)
    On Error GoTo ErrHandler
    
    Dim ws As Object
    Dim arrDates(1 To 4) As Variant
    Dim rowIdx As Long, i As Long, gefunden As Long
    Dim schicht As tSchicht
    Dim startVal As Variant, endeVal As Variant, standortVal As Variant
    Dim lastRow As Long, startCol As Long, endeCol As Long
    
    Set ws = wb.Sheets(1)
    lastRow = ws.UsedRange.rows.Count
    
    arrDates(1) = ws.Cells(2, 3).Value
    arrDates(2) = ws.Cells(2, 5).Value
    arrDates(3) = ws.Cells(2, 7).Value
    arrDates(4) = ws.Cells(2, 9).Value
    
    Debug.Print "  Datum C2=" & arrDates(1) & ", E2=" & arrDates(2) & ", G2=" & arrDates(3) & ", I2=" & arrDates(4)
    gefunden = 0
    
    For rowIdx = 3 To lastRow Step 2
        standortVal = ws.Cells(rowIdx, 2).Value
        If Not IsEmpty(standortVal) Then
            schicht.Standort = CStr(standortVal)
            For i = 1 To 4
                If IsDate(arrDates(i)) Then
                    startCol = 1 + i * 2
                    endeCol = startCol + 1
                    startVal = ws.Cells(rowIdx, startCol).Value
                    endeVal = ws.Cells(rowIdx, endeCol).Value
                    If IsValidTime(startVal) And IsValidTime(endeVal) Then
                        schicht.Datum = CDate(arrDates(i))
                        schicht.StartZeit = ConvertToTime(startVal)
                        schicht.EndeZeit = ConvertToTime(endeVal)
                        Dim arr(1 To 4) As Variant
                        arr(1) = schicht.Standort
                        arr(2) = schicht.Datum
                        arr(3) = schicht.StartZeit
                        arr(4) = schicht.EndeZeit
                        colSchichten.Add arr
                        gefunden = gefunden + 1
                        If gefunden <= 5 Then
                            Debug.Print "  + " & schicht.Standort & " | " & Format(schicht.Datum, "dd.mm.yyyy") & " | " & Format(schicht.StartZeit, "HH:MM") & "-" & Format(schicht.EndeZeit, "HH:MM")
                        End If
                    End If
                End If
            Next i
        End If
    Next rowIdx
    Debug.Print "  Gefunden: " & gefunden
    Exit Sub
ErrHandler:
    Debug.Print "  !!! PARSER-FEHLER Zeile " & rowIdx & ": " & Err.description
End Sub

Private Function IsValidTime(val As Variant) As Boolean
    If IsEmpty(val) Then
        IsValidTime = False
    ElseIf IsDate(val) Then
        IsValidTime = True
    ElseIf IsNumeric(val) Then
        IsValidTime = (val >= 0 And val < 1)
    Else
        IsValidTime = False
    End If
End Function

Private Function ConvertToTime(val As Variant) As Date
    If IsDate(val) Then
        ConvertToTime = CDate(val)
    ElseIf IsNumeric(val) Then
        ConvertToTime = CDate(val)
    Else
        ConvertToTime = 0
    End If
End Function

Private Function GruppiereSchichten(ByRef colSchichten As Collection) As Object
    Dim dict As Object, arr As Variant, schluessel As String, i As Long
    Dim colStandorte As Collection, bestehendes As Variant
    
    Set dict = CreateObject("Scripting.Dictionary")
    For i = 1 To colSchichten.Count
        arr = colSchichten(i)
        schluessel = CStr(CLng(CDate(arr(2)))) & "|" & Format(CDate(arr(3)), "HH:MM") & "|" & Format(CDate(arr(4)), "HH:MM")
        If Not dict.exists(schluessel) Then
            Set colStandorte = New Collection
            colStandorte.Add CStr(arr(1))
            dict.Add schluessel, Array(arr(2), arr(3), arr(4), 1, colStandorte)
        Else
            bestehendes = dict(schluessel)
            bestehendes(3) = bestehendes(3) + 1
            bestehendes(4).Add CStr(arr(1))
            dict(schluessel) = bestehendes
        End If
    Next i
    Set GruppiereSchichten = dict
End Function

Private Function ExecuteImport(ByRef colSchichten As Collection) As Long
    On Error GoTo ErrHandler
    
    Dim newVA_ID As Long, minDate As Date, maxDate As Date
    Dim dictDates As Object, dictVADatum As Object, dictGruppiert As Object
    Dim arr As Variant, d As Date, i As Long, vaDatumID As Long, vaStartID As Long
    Dim dateKey As Variant, schluessel As Variant, gruppenDaten As Variant
    Dim colStandorte As Collection, Standort As Variant
    Dim startDT As Date, endeDT As Date, maAnzahl As Long
    Dim sql As String
    Dim tmpID As Variant
    Dim sumMA As Variant
    
    Set dictDates = CreateObject("Scripting.Dictionary")
    Set dictVADatum = CreateObject("Scripting.Dictionary")
    Set dictGruppiert = GruppiereSchichten(colSchichten)
    
    minDate = #12/31/2099#
    maxDate = #1/1/1900#
    For i = 1 To colSchichten.Count
        arr = colSchichten(i)
        d = CDate(arr(2))
        If d < minDate Then minDate = d
        If d > maxDate Then maxDate = d
        If Not dictDates.exists(CLng(d)) Then dictDates.Add CLng(d), d
    Next i
    
    DoCmd.SetWarnings False
    
    ' Prüfe ob Auftrag bereits existiert
    tmpID = DLookup("ID", "tbl_VA_Auftragstamm", "Auftrag = 'Spielwarenmesse Bereichswachen' AND Dat_VA_Von = " & FmtD(minDate))
    If IsNull(tmpID) Then
        sql = "INSERT INTO tbl_VA_Auftragstamm (Auftrag, Objekt, Ort, Treffpunkt, Dienstkleidung, Veranstalter_ID, " & _
              "Dat_VA_Von, Dat_VA_Bis, AnzTg, Erst_von, Erst_am, Veranst_Status_ID) VALUES (" & _
              "'Spielwarenmesse Bereichswachen', 'Messezentrum', 'Nürnberg', " & _
              "'15 min vor DB an der SCU', 'schwarz neutral', 10730, " & _
              FmtD(minDate) & ", " & FmtD(maxDate) & ", " & dictDates.Count & ", " & _
              "'" & Environ("USERNAME") & "', Now(), 1)"
        DoCmd.RunSQL sql
        newVA_ID = DMax("ID", "tbl_VA_Auftragstamm", "Auftrag = 'Spielwarenmesse Bereichswachen'")
        Debug.Print "Neuer Auftrag angelegt ID: " & newVA_ID
    Else
        newVA_ID = tmpID
        Debug.Print "Auftrag existiert bereits ID: " & newVA_ID
    End If
    
    ' AnzTage anlegen/prüfen
    For Each dateKey In dictDates.Keys
        d = dictDates(dateKey)
        tmpID = DLookup("ID", "tbl_VA_AnzTage", "VA_ID = " & newVA_ID & " AND VADatum = " & FmtD(d))
        If IsNull(tmpID) Then
            sql = "INSERT INTO tbl_VA_AnzTage (VA_ID, VADatum, TVA_Soll, TVA_Ist) VALUES (" & newVA_ID & ", " & FmtD(d) & ", 0, 0)"
            DoCmd.RunSQL sql
            tmpID = DLookup("ID", "tbl_VA_AnzTage", "VA_ID = " & newVA_ID & " AND VADatum = " & FmtD(d))
            Debug.Print "  AnzTage angelegt für " & Format(d, "dd.mm.yyyy") & " ID: " & tmpID
        Else
            Debug.Print "  AnzTage existiert für " & Format(d, "dd.mm.yyyy") & " ID: " & tmpID
        End If
        dictVADatum.Add CLng(d), CLng(tmpID)
    Next dateKey
    
    ' VA_Start + MA_VA_Zuordnung
    For Each schluessel In dictGruppiert.Keys
        gruppenDaten = dictGruppiert(schluessel)
        d = CDate(gruppenDaten(0))
        vaDatumID = dictVADatum(CLng(d))
        maAnzahl = gruppenDaten(3)
        Set colStandorte = gruppenDaten(4)
        
        startDT = CDate(gruppenDaten(0)) + CDate(gruppenDaten(1))
        endeDT = CDate(gruppenDaten(0)) + CDate(gruppenDaten(2))
        If CDate(gruppenDaten(2)) < CDate(gruppenDaten(1)) Then endeDT = endeDT + 1
        
        ' Prüfe ob VA_Start existiert
        tmpID = DLookup("ID", "tbl_VA_Start", "VA_ID = " & newVA_ID & " AND VADatum = " & FmtD(d) & " AND VA_Start = " & FmtT(CDate(gruppenDaten(1))) & " AND VA_Ende = " & FmtT(CDate(gruppenDaten(2))))
        If IsNull(tmpID) Then
            sql = "INSERT INTO tbl_VA_Start (VA_ID, VADatum_ID, VADatum, MA_Anzahl, VA_Start, VA_Ende, MVA_Start, MVA_Ende) VALUES (" & _
                  newVA_ID & ", " & vaDatumID & ", " & FmtD(d) & ", " & maAnzahl & ", " & _
                  FmtT(CDate(gruppenDaten(1))) & ", " & FmtT(CDate(gruppenDaten(2))) & ", " & FmtDT(startDT) & ", " & FmtDT(endeDT) & ")"
            DoCmd.RunSQL sql
            vaStartID = DMax("ID", "tbl_VA_Start", "VA_ID = " & newVA_ID)
            Debug.Print "  VA_Start angelegt: " & Format(d, "dd.mm.yyyy") & " " & Format(CDate(gruppenDaten(1)), "HH:MM") & " ID: " & vaStartID
        Else
            vaStartID = tmpID
            Debug.Print "  VA_Start existiert: " & Format(d, "dd.mm.yyyy") & " " & Format(CDate(gruppenDaten(1)), "HH:MM") & " ID: " & vaStartID
        End If
        
        ' MA_VA_Zuordnung für jeden Standort
        For Each Standort In colStandorte
            tmpID = DLookup("ID", "tbl_MA_VA_Zuordnung", "VA_ID = " & newVA_ID & " AND VAStart_ID = " & vaStartID & " AND Bemerkungen = '" & FmtStandort(CStr(Standort)) & "'")
            If IsNull(tmpID) Then
                sql = "INSERT INTO tbl_MA_VA_Zuordnung (VA_ID, VADatum_ID, VAStart_ID, VADatum, MVA_Start, MVA_Ende, Bemerkungen, Erst_von, Erst_am) VALUES (" & _
                      newVA_ID & ", " & vaDatumID & ", " & vaStartID & ", " & FmtD(d) & ", " & FmtDT(startDT) & ", " & FmtDT(endeDT) & ", " & _
                      "'" & FmtStandort(CStr(Standort)) & "', '" & Environ("USERNAME") & "', Now())"
                DoCmd.RunSQL sql
                Debug.Print "    Zuordnung angelegt: " & CStr(Standort)
            Else
                Debug.Print "    Zuordnung existiert: " & CStr(Standort)
            End If
        Next Standort
    Next schluessel
    
    ' TVA_Soll Update - einzeln pro VADatum_ID
    Debug.Print "  TVA_Soll Update..."
    For Each dateKey In dictVADatum.Keys
        vaDatumID = dictVADatum(dateKey)
        sumMA = DSum("MA_Anzahl", "tbl_VA_Start", "VADatum_ID = " & vaDatumID)
        If IsNull(sumMA) Then sumMA = 0
        sql = "UPDATE tbl_VA_AnzTage SET TVA_Soll = " & sumMA & " WHERE ID = " & vaDatumID
        DoCmd.RunSQL sql
        Debug.Print "    ID " & vaDatumID & " -> TVA_Soll = " & sumMA
    Next dateKey
    
    DoCmd.SetWarnings True
    Debug.Print "===== IMPORT ABGESCHLOSSEN ====="
    
    ExecuteImport = newVA_ID
    Exit Function
ErrHandler:
    DoCmd.SetWarnings True
    Debug.Print "!!! IMPORT-FEHLER: " & Err.description
    MsgBox "Fehler: " & Err.description, vbCritical
    ExecuteImport = 0
End Function

Private Function FmtD(d As Date) As String
    FmtD = "#" & Month(d) & "/" & Day(d) & "/" & Year(d) & "#"
End Function

Private Function FmtT(t As Date) As String
    FmtT = "#" & Hour(t) & ":" & minute(t) & ":" & Second(t) & "#"
End Function

Private Function FmtDT(dt As Date) As String
    FmtDT = "#" & Month(dt) & "/" & Day(dt) & "/" & Year(dt) & " " & Hour(dt) & ":" & minute(dt) & ":" & Second(dt) & "#"
End Function

Private Function FmtStandort(s As String) As String
    Dim r As String, i As Long
    r = Replace(s, "'", "''")
    For i = 15 To 0 Step -1
        r = Replace(r, "H" & i, "Halle " & i)
    Next i
    FmtStandort = r
End Function
Option Compare Database
Option Explicit

Public Sub Email_Zu_Auftrag()
    On Error GoTo ErrHandler
    
    Debug.Print "=== Email_Zu_Auftrag START ==="
    
    Dim xlApp As Object
    Dim excelDateiPfad As String
    
    excelDateiPfad = Email_Import_Zu_Excel(xlApp)
    
    If excelDateiPfad = "" Or xlApp Is Nothing Then
        MsgBox "Fehler beim Import der E-Mail-Daten.", vbCritical
        Exit Sub
    End If
    
    Debug.Print "Excel-Datei erstellt: " & excelDateiPfad
    
    Excel_Auftrag_Anlegen xlApp
    
    On Error Resume Next
    If Not xlApp Is Nothing Then
        xlApp.DisplayAlerts = False
        xlApp.Quit
        Set xlApp = Nothing
    End If
    On Error GoTo 0
    
    Debug.Print "=== Email_Zu_Auftrag ERFOLG ==="
    Exit Sub
    
ErrHandler:
    Debug.Print "FEHLER Email_Zu_Auftrag: " & Err.description
    On Error Resume Next
    If Not xlApp Is Nothing Then
        xlApp.DisplayAlerts = False
        xlApp.Quit
    End If
    MsgBox "Fehler: " & Err.description, vbCritical
End Sub

Private Function Email_Import_Zu_Excel(ByRef xlApp As Object) As String
    On Error GoTo ErrHandler
    
    Dim olApp As Object, mail As Object
    Dim wb As Object, ws As Object
    Dim subj As String, baseName As String
    Dim tempPfad As String
    
    On Error Resume Next
    Set olApp = GetObject(, "Outlook.Application")
    If olApp Is Nothing Then Set olApp = CreateObject("Outlook.Application")
    On Error GoTo ErrHandler
    
    If olApp Is Nothing Then
        MsgBox "Outlook nicht gefunden.", vbExclamation
        Email_Import_Zu_Excel = ""
        Exit Function
    End If
    
    Dim insp As Object, exp As Object
    Set insp = olApp.ActiveInspector
    If Not insp Is Nothing Then
        If TypeName(insp.CurrentItem) = "MailItem" Then
            Set mail = insp.CurrentItem
        End If
    End If
    
    If mail Is Nothing Then
        Set exp = olApp.ActiveExplorer
        If Not exp Is Nothing Then
            If exp.Selection.Count > 0 Then
                If TypeName(exp.Selection.item(1)) = "MailItem" Then
                    Set mail = exp.Selection.item(1)
                End If
            End If
        End If
    End If
    
    If mail Is Nothing Then
        MsgBox "Bitte eine E-Mail in Outlook öffnen oder markieren.", vbExclamation
        Email_Import_Zu_Excel = ""
        Exit Function
    End If
    
    subj = CStr(mail.Subject)
    baseName = CleanFileName(subj)
    
    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = True
    xlApp.DisplayAlerts = False
    
    Set wb = xlApp.Workbooks.Add
    Set ws = wb.Worksheets(1)
    
    On Error Resume Next
    wb.BuiltinDocumentProperties("Title").Value = subj
    ws.Name = Left(Replace(baseName, "  ", " "), 31)
    wb.Windows(1).caption = baseName & " (neu)"
    On Error GoTo ErrHandler
    
    Const FIRST_DATA_ROW As Long = 1
    Dim wdDoc As Object, wdTbl As Object
    
    On Error Resume Next
    Set wdDoc = mail.GetInspector.WordEditor
    On Error GoTo ErrHandler
    
    If Not wdDoc Is Nothing Then
        Set wdTbl = PickBestWordTable(wdDoc)
        If Not wdTbl Is Nothing Then
            Dim r As Long, c As Long, outRow As Long
            outRow = FIRST_DATA_ROW
            For r = 1 To wdTbl.rows.Count
                For c = 1 To wdTbl.Columns.Count
                    ws.Cells(outRow, c).Value = CleanWordCellText(wdTbl.Cell(r, c).Range.Text)
                Next c
                outRow = outRow + 1
            Next r
            GoTo AfterWrite
        End If
    End If
    
    Dim html As String
    html = CStr(mail.HTMLBody)
    
    If Len(html) = 0 Then
        MsgBox "Keine Tabelle in der E-Mail gefunden.", vbExclamation
        Email_Import_Zu_Excel = ""
        Exit Function
    End If
    
    Dim htmlTbl As Object
    Set htmlTbl = FindBestHtmlTable(html)
    
    If htmlTbl Is Nothing Then
        MsgBox "Keine Tabelle in der E-Mail gefunden.", vbExclamation
        Email_Import_Zu_Excel = ""
        Exit Function
    End If
    
    Dim trColl As Object, rowObj As Object, tdColl As Object
    Dim thColl As Object, cellObj As Object
    Dim outRow2 As Long, CC As Long
    outRow2 = FIRST_DATA_ROW
    
    Set trColl = htmlTbl.getElementsByTagName("tr")
    For Each rowObj In trColl
        Set thColl = rowObj.getElementsByTagName("th")
        If thColl.Length = 0 Then
            Set tdColl = rowObj.getElementsByTagName("td")
        Else
            Set tdColl = thColl
        End If
        
        If Not tdColl Is Nothing Then
            If tdColl.Length > 0 Then
                CC = 1
                For Each cellObj In tdColl
                    ws.Cells(outRow2, CC).Value = CleanText(cellObj.innerText)
                    CC = CC + 1
                Next cellObj
                outRow2 = outRow2 + 1
            End If
        End If
    Next rowObj
    
AfterWrite:
    Dim lastCol As Long, lastRow As Long, rr As Long
    lastRow = ws.Cells(ws.rows.Count, 1).End(-4162).row
    lastCol = ws.Cells(1, ws.Columns.Count).End(-4159).Column
    If lastCol = 0 Then lastCol = 1
    
    For rr = lastRow To 1 Step -1
        If IsRowBlank(ws, rr, lastCol) Then
            ws.rows(rr).Delete
        End If
    Next rr
    
    ErzeugeRechteTabelle ws
    
    ws.rows(1).Insert
    ws.Range("A1").Value = subj
    ws.Range("A1").Font.Bold = True
    
    Dim lastRowL As Long
    lastRowL = ws.Cells(ws.rows.Count, "A").End(-4162).row
    ws.Range("A1:H" & lastRowL).EntireColumn.AutoFit
    
    tempPfad = Environ("TEMP") & "\" & baseName & "_" & Format(Now, "yyyymmdd_hhnnss") & ".xlsx"
    wb.SaveAs tempPfad
    
    Email_Import_Zu_Excel = tempPfad
    Exit Function
    
ErrHandler:
    Debug.Print "FEHLER Email_Import_Zu_Excel: " & Err.description
    Email_Import_Zu_Excel = ""
End Function

Private Sub ErzeugeRechteTabelle(ws As Object)
    On Error GoTo ErrHandler
    
    Dim lastRow As Long
    lastRow = ws.Cells(ws.rows.Count, "A").End(-4162).row
    
    If lastRow < 2 Then
        MsgBox "Keine Quelldaten in A:H gefunden.", vbExclamation
        Exit Sub
    End If
    
    Dim headerRow As Long, r As Long
    For r = 1 To lastRow
        If LCase(Trim(ws.Cells(r, "A").Text)) = "firma" And _
           LCase(Trim(ws.Cells(r, "C").Text)) = "datum" Then
            headerRow = r
            Exit For
        End If
    Next r
    
    Dim startRow As Long
    startRow = IIf(headerRow > 0, headerRow + 1, 2)
    
    ws.Range("J1").Value = "Nr"
    ws.Range("K1").Value = "Datum"
    ws.Range("L1").Value = "Beginn"
    ws.Range("M1").Value = "Ende"
    ws.Range("N1").Value = "Dauer"
    ws.Range("O1").Value = "Stand"
    
    ws.Range("J2:O" & ws.rows.Count).ClearContents
    
    Dim outRow As Long
    outRow = 2
    
    Const SPLIT_LIMIT As Double = 13# / 24#
    Const T_23 As Double = 23# / 24#
    
    For r = startRow To lastRow
        If LCase(Trim(ws.Cells(r, "A").Text)) = "firma" Then GoTo ContinueLoop
        
        If Trim(ws.Cells(r, "A").Text) = "" Or _
           Trim(ws.Cells(r, "C").Text) = "" Or _
           Trim(ws.Cells(r, "D").Text) = "" Or _
           Trim(ws.Cells(r, "E").Text) = "" Or _
           Trim(ws.Cells(r, "G").Text) = "" Or _
           Trim(ws.Cells(r, "H").Text) = "" Then GoTo ContinueLoop
        
        Dim firma As String, halle As String, standNr As String
        Dim tBeg As Double, tEnd As Double
        Dim srcDateCell As Object, standText As String
        
        firma = Trim(ws.Cells(r, "A").Text)
        halle = HalleAusgeschrieben(ws.Cells(r, "G").Text)
        standNr = Trim(ws.Cells(r, "H").Text)
        Set srcDateCell = ws.Cells(r, "C")
        
        tBeg = ToTimeFraction(ws.Cells(r, "D").Value)
        tEnd = ToTimeFraction(ws.Cells(r, "E").Value)
        
        If Len(halle) > 0 And Len(standNr) > 0 Then
            standText = halle & "-" & standNr & " " & firma
        Else
            standText = Trim(halle & " " & standNr & " " & firma)
        End If
        
        If DurationFrom(tBeg, tEnd) > SPLIT_LIMIT Then
            ws.Cells(outRow, "K").Value = srcDateCell.Value
            ws.Cells(outRow, "K").NumberFormat = srcDateCell.NumberFormat
            ws.Cells(outRow, "L").Value = tBeg
            ws.Cells(outRow, "M").Value = T_23
            ws.Cells(outRow, "N").Value = DurationFrom(tBeg, T_23)
            ws.Cells(outRow, "O").Value = standText
            outRow = outRow + 1
            
            ws.Cells(outRow, "K").Value = srcDateCell.Value
            ws.Cells(outRow, "K").NumberFormat = srcDateCell.NumberFormat
            ws.Cells(outRow, "L").Value = T_23
            ws.Cells(outRow, "M").Value = tEnd
            ws.Cells(outRow, "N").Value = DurationFrom(T_23, tEnd)
            ws.Cells(outRow, "O").Value = standText
            outRow = outRow + 1
        Else
            ws.Cells(outRow, "K").Value = srcDateCell.Value
            ws.Cells(outRow, "K").NumberFormat = srcDateCell.NumberFormat
            ws.Cells(outRow, "L").Value = tBeg
            ws.Cells(outRow, "M").Value = tEnd
            ws.Cells(outRow, "N").Value = DurationFrom(tBeg, tEnd)
            ws.Cells(outRow, "O").Value = standText
            outRow = outRow + 1
        End If
        
ContinueLoop:
    Next r
    
    Dim lastOut As Long
    lastOut = ws.Cells(ws.rows.Count, "K").End(-4162).row
    
    If lastOut < 2 Then
        MsgBox "Keine gültigen Datensätze für die rechte Tabelle vorhanden.", vbInformation
        Exit Sub
    End If
    
    ws.Range("L2:M" & lastOut).NumberFormat = "hh:mm"
    ws.Range("N2:N" & lastOut).NumberFormat = "[h]:mm"
    
    ws.Range("J1:O" & lastOut).Sort _
        Key1:=ws.Range("K2"), Order1:=1, _
        Key2:=ws.Range("L2"), Order2:=1, _
        Key3:=ws.Range("M2"), Order3:=1, _
        Header:=1
    
    Dim i As Long, cnt As Long
    cnt = 0
    For i = 2 To lastOut
        If i = 2 Then
            cnt = 1
        ElseIf ws.Cells(i, "K").Value = ws.Cells(i - 1, "K").Value Then
            cnt = cnt + 1
        Else
            cnt = 1
        End If
        ws.Cells(i, "J").Value = cnt
    Next i
    
    ws.Range("J2:J" & lastOut).HorizontalAlignment = -4152
    ws.Range("K2:M" & lastOut).HorizontalAlignment = -4108
    ws.Range("N2:N" & lastOut).HorizontalAlignment = -4108
    ws.Range("J1:O1").Font.Bold = True
    ws.Columns("J").AutoFit
    
    Exit Sub
    
ErrHandler:
    Debug.Print "FEHLER ErzeugeRechteTabelle: " & Err.description
End Sub

Private Function SucheBestehendenAuftrag(basisName As String, DatumVon As Date, DatumBis As Date) As Long
    On Error GoTo ErrHandler
    
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sqlStr As String
    
    Dim suchName As String
    suchName = Trim(basisName)
    
    Debug.Print "=========================================="
    Debug.Print "SUCHE BESTEHENDER AUFTRAG:"
    Debug.Print "Original-Name: " & basisName
    Debug.Print "Such-Name: " & suchName
    Debug.Print "Datums-Bereich: " & Format(DatumVon, "dd.mm.yyyy") & " - " & Format(DatumBis, "dd.mm.yyyy")
    
    Set db = CurrentDb
    
    sqlStr = "SELECT TOP 1 ID, Auftrag, Dat_VA_Von, Dat_VA_Bis FROM tbl_VA_Auftragstamm " & _
             "WHERE Auftrag = '" & Replace(suchName, "'", "''") & "' " & _
             "ORDER BY Erst_am DESC"
    
    Debug.Print "SQL (Strategie 1 - Exakt): " & sqlStr
    Set rs = db.OpenRecordset(sqlStr)
    
    If Not rs.EOF Then
        Debug.Print ">>> EXAKTE ÜBEREINSTIMMUNG GEFUNDEN <<<"
        Debug.Print "ID: " & rs!ID & " | Auftrag: " & rs!Auftrag
        Debug.Print "Von: " & Format(rs!Dat_VA_Von, "dd.mm.yyyy") & " | Bis: " & Format(rs!Dat_VA_Bis, "dd.mm.yyyy")
        SucheBestehendenAuftrag = rs!ID
        rs.Close
        Set rs = Nothing
        Set db = Nothing
        Exit Function
    End If
    rs.Close
    
    Dim basisOhneTimestamp As String
    basisOhneTimestamp = ExtrahiereBasisName(suchName)
    
    If basisOhneTimestamp <> suchName Then
        Debug.Print "Basis ohne Timestamp: " & basisOhneTimestamp
        
        sqlStr = "SELECT TOP 1 ID, Auftrag, Dat_VA_Von, Dat_VA_Bis FROM tbl_VA_Auftragstamm " & _
                 "WHERE Auftrag LIKE '" & Replace(basisOhneTimestamp, "'", "''") & "%' " & _
                 "ORDER BY Erst_am DESC"
        
        Debug.Print "SQL (Strategie 2 - LIKE): " & sqlStr
        Set rs = db.OpenRecordset(sqlStr)
        
        If Not rs.EOF Then
            Debug.Print ">>> LIKE-ÜBEREINSTIMMUNG GEFUNDEN <<<"
            Debug.Print "ID: " & rs!ID & " | Auftrag: " & rs!Auftrag
            SucheBestehendenAuftrag = rs!ID
            rs.Close
            Set rs = Nothing
            Set db = Nothing
            Exit Function
        End If
        rs.Close
    End If
    
    Dim erstesWort As String
    Dim spacePos As Long
    spacePos = InStr(suchName, " ")
    If spacePos > 0 Then
        erstesWort = Left(suchName, spacePos - 1)
    Else
        erstesWort = suchName
    End If
    
    If Len(erstesWort) >= 5 Then
        Debug.Print "Erstes Wort: " & erstesWort
        
        sqlStr = "SELECT TOP 5 ID, Auftrag, Dat_VA_Von, Dat_VA_Bis FROM tbl_VA_Auftragstamm " & _
                 "WHERE Auftrag LIKE '" & Replace(erstesWort, "'", "''") & "%' " & _
                 "ORDER BY Erst_am DESC"
        
        Debug.Print "SQL (Strategie 3 - Erstes Wort): " & sqlStr
        Set rs = db.OpenRecordset(sqlStr)
        
        If Not rs.EOF Then
            Debug.Print ">>> ÄHNLICHE AUFTRÄGE GEFUNDEN <<<"
            Do While Not rs.EOF
                Debug.Print "  ID: " & rs!ID & " | " & rs!Auftrag
                rs.MoveNext
            Loop
            rs.MoveFirst
            SucheBestehendenAuftrag = rs!ID
            rs.Close
            Set rs = Nothing
            Set db = Nothing
            Exit Function
        End If
        rs.Close
    End If
    
    Debug.Print ">>> KEIN BESTEHENDER AUFTRAG GEFUNDEN <<<"
    Debug.Print "=========================================="
    Set db = Nothing
    SucheBestehendenAuftrag = 0
    Exit Function
    
ErrHandler:
    Debug.Print "!!! FEHLER in SucheBestehendenAuftrag: " & Err.description
    Debug.Print "=========================================="
    On Error Resume Next
    If Not rs Is Nothing Then rs.Close
    Set rs = Nothing
    Set db = Nothing
    SucheBestehendenAuftrag = 0
End Function

Private Function ExtrahiereBasisName(vollName As String) As String
    Dim result As String
    result = vollName
    result = Replace(Replace(result, ".xlsx", ""), ".xls", "")
    
    Dim pos As Long
    pos = InStrRev(result, "_2025")
    If pos = 0 Then pos = InStrRev(result, "_2024")
    If pos = 0 Then pos = InStrRev(result, "_2026")
    If pos = 0 Then pos = InStrRev(result, "_2027")
    
    If pos > 0 Then
        result = Left(result, pos - 1)
    End If
    
    ExtrahiereBasisName = Trim(result)
End Function

' =====================================================================
' NEU V6: DATUMS-BEREICH IM AUFTRAGSSTAMM AKTUALISIEREN
' =====================================================================
Private Sub AktualisiereDatumsBereich(ByVal VA_ID As Long, ByVal neuDatumVon As Date, ByVal neuDatumBis As Date)
    On Error GoTo ErrHandler
    
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim altDatumVon As Date, altDatumBis As Date
    Dim finalDatumVon As Date, finalDatumBis As Date
    Dim anzTage As Long
    Dim geaendert As Boolean
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT Dat_VA_Von, Dat_VA_Bis FROM tbl_VA_Auftragstamm WHERE ID = " & VA_ID)
    
    If Not rs.EOF Then
        altDatumVon = rs!Dat_VA_Von
        altDatumBis = rs!Dat_VA_Bis
        rs.Close
        Set rs = Nothing
        
        Debug.Print "=== DATUMS-BEREICH PRÜFUNG ==="
        Debug.Print "ALT: " & Format(altDatumVon, "dd.mm.yyyy") & " - " & Format(altDatumBis, "dd.mm.yyyy")
        Debug.Print "NEU: " & Format(neuDatumVon, "dd.mm.yyyy") & " - " & Format(neuDatumBis, "dd.mm.yyyy")
        
        geaendert = False
        finalDatumVon = altDatumVon
        finalDatumBis = altDatumBis
        
        If neuDatumVon < altDatumVon Then
            finalDatumVon = neuDatumVon
            geaendert = True
            Debug.Print ">>> Dat_VA_Von wird erweitert: " & Format(finalDatumVon, "dd.mm.yyyy")
        End If
        
        If neuDatumBis > altDatumBis Then
            finalDatumBis = neuDatumBis
            geaendert = True
            Debug.Print ">>> Dat_VA_Bis wird erweitert: " & Format(finalDatumBis, "dd.mm.yyyy")
        End If
        
        If geaendert Then
            anzTage = DateDiff("d", finalDatumVon, finalDatumBis) + 1
            
            db.Execute "UPDATE tbl_VA_Auftragstamm SET " & _
                      "Dat_VA_Von = #" & Month(finalDatumVon) & "/" & Day(finalDatumVon) & "/" & Year(finalDatumVon) & "#, " & _
                      "Dat_VA_Bis = #" & Month(finalDatumBis) & "/" & Day(finalDatumBis) & "/" & Year(finalDatumBis) & "#, " & _
                      "AnzTg = " & anzTage & " " & _
                      "WHERE ID = " & VA_ID, dbFailOnError
            
            Debug.Print "? Auftragsstamm aktualisiert!"
            Debug.Print "FINAL: " & Format(finalDatumVon, "dd.mm.yyyy") & " - " & Format(finalDatumBis, "dd.mm.yyyy") & " (" & anzTage & " Tage)"
        Else
            Debug.Print "Keine Änderung nötig (neue Daten innerhalb bestehender Zeitspanne)"
        End If
        Debug.Print "=============================="
    End If
    
    Set db = Nothing
    Exit Sub
    
ErrHandler:
    Debug.Print "!!! FEHLER AktualisiereDatumsBereich: " & Err.description
    On Error Resume Next
    If Not rs Is Nothing Then rs.Close
    Set rs = Nothing
    Set db = Nothing
End Sub

' =====================================================================
' ERWEITERT V6: EXCEL -> ACCESS MIT DATUMS-AKTUALISIERUNG
' (Autopilot: vorhandener Auftrag = automatische Nachbestellung)
' =====================================================================
Private Sub Excel_Auftrag_Anlegen(xlApp As Object)
    On Error GoTo ErrHandler
    
    Dim xlWb As Object, xlWs As Object
    Dim lastRow As Long, i As Long
    Dim db As DAO.Database, rs As DAO.Recordset
    Dim newVA_ID As Long, vaDatumID As Long, vaStartID As Long
    Dim DatumVon As Date, DatumBis As Date
    Dim anzTage As Long
    Dim auftragName As String, Objekt As String, Ort As String
    Dim Treffpunkt As String, Dienstkleidung As String, VeranstalterID As Long
    Dim Datum As Date, Beginn As Date, Ende As Date, stand As String, sqlStr As String
    Dim strStartZeit As String, strEndeZeit As String
    
    Debug.Print "=== Excel_Auftrag_Anlegen START ==="
    
    Set xlWb = xlApp.ActiveWorkbook
    If xlWb Is Nothing Then
        MsgBox "Keine Excel-Arbeitsmappe geöffnet!", vbExclamation
        Exit Sub
    End If
    
    Set xlWs = xlWb.ActiveSheet
    
    On Error Resume Next
    auftragName = Trim(CStr(xlWs.Range("A1").Value))
    On Error GoTo ErrHandler
    
    If Len(auftragName) = 0 Then
        auftragName = Replace(Replace(xlWb.Name, ".xlsx", ""), ".xls", "")
        Debug.Print "WARNUNG: A1 leer, nutze Dateinamen: " & auftragName
    Else
        Debug.Print "Auftragsname aus A1: " & auftragName
    End If
    
    Objekt = "Messezentrum"
    Ort = "Nürnberg"
    Treffpunkt = "15 min vor DB an der SCU"
    Dienstkleidung = "schwarz neutral"
    VeranstalterID = 20760
    
    Dim datumCol As Long, beginnCol As Long, endeCol As Long, standCol As Long
    datumCol = 11
    beginnCol = 12
    endeCol = 13
    standCol = 15
    
    Dim headerRow As Long, r As Long
    headerRow = 0
    For r = 1 To 5
        If LCase(Trim(xlWs.Cells(r, datumCol).Text)) = "datum" Then
            headerRow = r
            Exit For
        End If
    Next r
    
    Dim startRow As Long
    If headerRow > 0 Then
        startRow = headerRow + 1
        Debug.Print "Header-Zeile: " & headerRow & " -> Daten ab " & startRow
    Else
        startRow = 2
        Debug.Print "Kein Header, Start ab Zeile 2"
    End If
    
    lastRow = xlWs.Cells(xlWs.rows.Count, datumCol).End(-4162).row
    Debug.Print "LastRow: " & lastRow
    
    If lastRow < startRow Then
        MsgBox "Keine Daten gefunden!", vbExclamation
        Exit Sub
    End If
    
    DatumVon = #12/31/9999#
    DatumBis = #1/1/1900#
    
    Dim tempDate As Variant, validDatesFound As Boolean
    validDatesFound = False
    
    For i = startRow To lastRow
        On Error Resume Next
        tempDate = xlWs.Cells(i, datumCol).Value
        
        If IsDate(tempDate) Then
            tempDate = CDate(tempDate)
            If tempDate > #1/1/1900# Then
                validDatesFound = True
                If tempDate < DatumVon Then DatumVon = tempDate
                If tempDate > DatumBis Then DatumBis = tempDate
            End If
        End If
        On Error GoTo ErrHandler
    Next i
    
    If Not validDatesFound Then
        MsgBox "Keine gültigen Datumswerte!", vbExclamation
        Exit Sub
    End If
    
    anzTage = DateDiff("d", DatumVon, DatumBis) + 1
    
    Debug.Print "=== DATUMS-BEREICH ==="
    Debug.Print "Von: " & Format(DatumVon, "dd.mm.yyyy")
    Debug.Print "Bis: " & Format(DatumBis, "dd.mm.yyyy")
    Debug.Print "Tage: " & anzTage
    
    Dim bestehendeVA_ID As Long
    bestehendeVA_ID = SucheBestehendenAuftrag(auftragName, DatumVon, DatumBis)
    
    Dim istNachbestellung As Boolean
    istNachbestellung = False
    
    ' Automatisch als Nachbestellung behandeln, wenn Auftrag existiert
    If bestehendeVA_ID > 0 Then
        istNachbestellung = True
        newVA_ID = bestehendeVA_ID
        Debug.Print ">>> BESTEHENDER AUFTRAG GEFUNDEN – automatische Nachbestellung zu VA_ID " & newVA_ID
    End If
    
    ' Wenn keine Nachbestellung -> neuen Auftrag anlegen
    If Not istNachbestellung Then
        Set db = CurrentDb
        
        sqlStr = "INSERT INTO tbl_VA_Auftragstamm (Auftrag, Objekt, Ort, Dat_VA_Von, Dat_VA_Bis, AnzTg, " & _
                 "Treffpunkt, Dienstkleidung, Veranstalter_ID, Erst_von, Erst_am, Veranst_Status_ID) VALUES (" & _
                 "'" & Replace(auftragName, "'", "''") & "', '" & Replace(Objekt, "'", "''") & "', '" & Replace(Ort, "'", "''") & "', " & _
                 "#" & Month(DatumVon) & "/" & Day(DatumVon) & "/" & Year(DatumVon) & "#, " & _
                 "#" & Month(DatumBis) & "/" & Day(DatumBis) & "/" & Year(DatumBis) & "#, " & anzTage & ", " & _
                 "'" & Replace(Treffpunkt, "'", "''") & "', '" & Replace(Dienstkleidung, "'", "''") & "', " & _
                 VeranstalterID & ", '" & Environ("USERNAME") & "', Now(), 1)"
        
        db.Execute sqlStr, dbFailOnError
        Set rs = db.OpenRecordset("SELECT MAX(ID) AS NewID FROM tbl_VA_Auftragstamm WHERE Auftrag = '" & Replace(auftragName, "'", "''") & "'")
        newVA_ID = rs!newID
        rs.Close
        Set rs = Nothing
        Set db = Nothing
        
        Debug.Print "NEUER Auftrag - VA_ID: " & newVA_ID
    End If
    
    ' Tage in tbl_VA_AnzTage sicherstellen
    Set db = CurrentDb
    Dim currentDate As Date
    currentDate = DatumVon
    Dim neueTagecounter As Long
    neueTagecounter = 0
    
    Do While currentDate <= DatumBis
        Set rs = db.OpenRecordset("SELECT ID FROM tbl_VA_AnzTage WHERE VA_ID = " & newVA_ID & _
                                  " AND VADatum = #" & Month(currentDate) & "/" & Day(currentDate) & "/" & Year(currentDate) & "#")
        
        If rs.EOF Then
            db.Execute "INSERT INTO tbl_VA_AnzTage (VA_ID, VADatum, TVA_Soll, TVA_Ist) VALUES (" & _
                       newVA_ID & ", #" & Month(currentDate) & "/" & Day(currentDate) & "/" & Year(currentDate) & "#, 0, 0)", dbFailOnError
            neueTagecounter = neueTagecounter + 1
            If istNachbestellung Then Debug.Print "Neuer Tag: " & Format(currentDate, "dd.mm.yyyy")
        End If
        rs.Close
        Set rs = Nothing
        
        currentDate = DateAdd("d", 1, currentDate)
    Loop
    Set db = Nothing
    
    If istNachbestellung And neueTagecounter > 0 Then
        Debug.Print "Neue Tage: " & neueTagecounter
    End If
    
    ' Datumsbereich im Auftragsstamm ggf. erweitern
    If istNachbestellung Then
        AktualisiereDatumsBereich newVA_ID, DatumVon, DatumBis
    End If
    
    Debug.Print "=== SCHICHT-IMPORT START ==="
    
    Dim PosNr As Long, schichtCounter As Long, skipCounter As Long, mergeCounter As Long
    
    If istNachbestellung Then
        Set db = CurrentDb
        Set rs = db.OpenRecordset("SELECT MAX(PosNr) AS MaxPos FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & newVA_ID)
        If Not rs.EOF And Not IsNull(rs!MaxPos) Then
            PosNr = rs!MaxPos + 1
        Else
            PosNr = 1
        End If
        rs.Close
        Set rs = Nothing
        Set db = Nothing
        Debug.Print "Start PosNr: " & PosNr
    Else
        PosNr = 1
    End If
    
    schichtCounter = 0
    skipCounter = 0
    mergeCounter = 0
    
    For i = startRow To lastRow
        On Error Resume Next
        
        If IsEmpty(xlWs.Cells(i, datumCol).Value) Then
            skipCounter = skipCounter + 1
            On Error GoTo ErrHandler
            GoTo NextRow
        End If
        
        Datum = CDate(xlWs.Cells(i, datumCol).Value)
        If Err.Number <> 0 Or Datum <= #1/1/1900# Then
            Err.clear
            skipCounter = skipCounter + 1
            On Error GoTo ErrHandler
            GoTo NextRow
        End If
        
        If IsEmpty(xlWs.Cells(i, beginnCol).Value) Or IsEmpty(xlWs.Cells(i, endeCol).Value) Then
            skipCounter = skipCounter + 1
            On Error GoTo ErrHandler
            GoTo NextRow
        End If
        
        Beginn = xlWs.Cells(i, beginnCol).Value
        Ende = xlWs.Cells(i, endeCol).Value
        
        If Not IsDate(Beginn) Or Not IsDate(Ende) Then
            Err.clear
            skipCounter = skipCounter + 1
            On Error GoTo ErrHandler
            GoTo NextRow
        End If
        
        Beginn = CDate(Beginn)
        Ende = CDate(Ende)
        
        If Err.Number <> 0 Then
            Err.clear
            skipCounter = skipCounter + 1
            On Error GoTo ErrHandler
            GoTo NextRow
        End If
        
        stand = ""
        Dim standCell As Object
        Set standCell = xlWs.Cells(i, standCol)
        standCell.NumberFormat = "@"
        stand = Trim(CStr(standCell.Text))
        stand = Replace(stand, Chr(0), "")
        If IsNumeric(stand) And InStr(stand, ",") > 0 Then stand = ""
        On Error GoTo ErrHandler
        
        strStartZeit = "#" & Format(Hour(Beginn), "00") & ":" & Format(minute(Beginn), "00") & ":" & Format(Second(Beginn), "00") & "#"
        strEndeZeit = "#" & Format(Hour(Ende), "00") & ":" & Format(minute(Ende), "00") & ":" & Format(Second(Ende), "00") & "#"
        
        Set db = CurrentDb
        
        Set rs = db.OpenRecordset("SELECT ID FROM tbl_VA_AnzTage WHERE VA_ID = " & newVA_ID & _
                                  " AND VADatum = #" & Month(Datum) & "/" & Day(Datum) & "/" & Year(Datum) & "#")
        If rs.EOF Then
            rs.Close
            Set rs = Nothing
            Set db = Nothing
            skipCounter = skipCounter + 1
            GoTo NextRow
        End If
        vaDatumID = rs!ID
        rs.Close
        Set rs = Nothing
        
        Set rs = db.OpenRecordset("SELECT ID, MA_Anzahl FROM tbl_VA_Start WHERE VADatum_ID = " & vaDatumID & _
                                  " AND VA_Start = " & strStartZeit & " AND VA_Ende = " & strEndeZeit)
        
        If Not rs.EOF Then
            vaStartID = rs!ID
            Dim aktAnz As Long
            aktAnz = rs!MA_Anzahl
            rs.Close
            Set rs = Nothing
            db.Execute "UPDATE tbl_VA_Start SET MA_Anzahl = " & (aktAnz + 1) & " WHERE ID = " & vaStartID, dbFailOnError
            mergeCounter = mergeCounter + 1
        Else
            rs.Close
            Set rs = Nothing
            sqlStr = "INSERT INTO tbl_VA_Start (VA_ID, VADatum_ID, VADatum, MA_Anzahl, VA_Start, VA_Ende, Bemerkungen) VALUES (" & _
                     newVA_ID & ", " & vaDatumID & ", #" & Month(Datum) & "/" & Day(Datum) & "/" & Year(Datum) & "#, 1, " & _
                     strStartZeit & ", " & strEndeZeit & ", '" & Replace(stand, "'", "''") & "')"
            db.Execute sqlStr, dbFailOnError
            Set rs = db.OpenRecordset("SELECT MAX(ID) AS MaxID FROM tbl_VA_Start WHERE VA_ID = " & newVA_ID)
            vaStartID = rs!MaxID
            rs.Close
            Set rs = Nothing
            schichtCounter = schichtCounter + 1
        End If
        
        sqlStr = "INSERT INTO tbl_MA_VA_Zuordnung (VA_ID, VADatum_ID, VAStart_ID, VADatum, PosNr, MA_Start, MA_Ende, Bemerkungen, Erst_von, Erst_am) VALUES (" & _
                 newVA_ID & ", " & vaDatumID & ", " & vaStartID & ", #" & Month(Datum) & "/" & Day(Datum) & "/" & Year(Datum) & "#, " & PosNr & ", " & _
                 strStartZeit & ", " & strEndeZeit & ", '" & Replace(stand, "'", "''") & "', '" & Environ("USERNAME") & "', Now())"
        db.Execute sqlStr, dbFailOnError
        Set db = Nothing
        PosNr = PosNr + 1
        
NextRow:
    Next i
    
    Set db = CurrentDb
    currentDate = DatumVon
    Do While currentDate <= DatumBis
        Set rs = db.OpenRecordset("SELECT ID FROM tbl_VA_AnzTage WHERE VA_ID = " & newVA_ID & _
                                  " AND VADatum = #" & Month(currentDate) & "/" & Day(currentDate) & "/" & Year(currentDate) & "#")
        If Not rs.EOF Then
            vaDatumID = rs!ID
            rs.Close
            Set rs = Nothing
            Set rs = db.OpenRecordset("SELECT SUM(MA_Anzahl) AS Total FROM tbl_VA_Start WHERE VADatum_ID = " & vaDatumID)
            If Not rs.EOF And Not IsNull(rs!Total) Then
                db.Execute "UPDATE tbl_VA_AnzTage SET TVA_Soll = " & rs!Total & " WHERE ID = " & vaDatumID, dbFailOnError
            End If
            rs.Close
            Set rs = Nothing
        End If
        currentDate = DateAdd("d", 1, currentDate)
    Loop
    Set db = Nothing
    
    Debug.Print "=== ERFOLG ==="
    Debug.Print "Neu: " & schichtCounter & " | Merge: " & mergeCounter & " | Skip: " & skipCounter
    
    ' Abschlussmeldung:
    If istNachbestellung Then
        ' Nur kurze Meldung bei Nachbestellung
        MsgBox "Zusätzliche Schichten wurden hinzugefügt", vbInformation
    Else
        ' Ausführliche Meldung nur bei neuem Auftrag
        Dim meldung As String
        meldung = "Neuer Auftrag erstellt!" & vbCrLf & vbCrLf & _
                  "Auftrag: " & auftragName & vbCrLf & _
                  "VA_ID: " & newVA_ID & vbCrLf & _
                  "Datum: " & Format(DatumVon, "dd.mm.yyyy") & " - " & Format(DatumBis, "dd.mm.yyyy") & vbCrLf & vbCrLf & _
                  "Schichten neu: " & schichtCounter & vbCrLf & _
                  "Schichten ergänzt: " & mergeCounter & vbCrLf & _
                  "übersprungen: " & skipCounter
        
        MsgBox meldung, vbInformation
    End If
    
    Exit Sub
    
ErrHandler:
    Debug.Print "FEHLER Zeile " & i & ": " & Err.description & " (Nr: " & Err.Number & ")"
    On Error Resume Next
    If Not rs Is Nothing Then
        rs.Close
        Set rs = Nothing
    End If
    Set db = Nothing
    MsgBox "Fehler in Zeile " & i & ":" & vbCrLf & Err.description & vbCrLf & "Nummer: " & Err.Number, vbCritical
End Sub

Private Function CleanFileName(ByVal s As String) As String
    Dim badChars As Variant, ch As Variant
    badChars = Array("<", ">", ":", """", "/", "\", "|", "?", "*")
    For Each ch In badChars
        s = Replace(s, ch, " ")
    Next ch
    s = Trim(s)
    If Len(s) = 0 Then s = "Import"
    CleanFileName = s
End Function

Private Function IsRowBlank(ws As Object, ByVal r As Long, ByVal lastCol As Long) As Boolean
    Dim c As Long, v As String
    For c = 1 To lastCol
        v = CStr(ws.Cells(r, c).Value)
        v = Replace(v, Chr(160), "")
        v = Trim(v)
        If Len(v) > 0 Then
            IsRowBlank = False
            Exit Function
        End If
    Next c
    IsRowBlank = True
End Function

Private Function PickBestWordTable(wdDoc As Object) As Object
    On Error Resume Next
    Dim t As Object, best As Object
    Dim bestArea As Long, area As Long
    If wdDoc.tables.Count = 0 Then Exit Function
    For Each t In wdDoc.tables
        area = t.rows.Count * t.Columns.Count
        If area > bestArea Then
            Set best = t
            bestArea = area
        End If
    Next t
    Set PickBestWordTable = best
End Function

Private Function CleanWordCellText(ByVal s As String) As String
    s = Replace(s, Chr(160), " ")
    s = Replace(s, Chr(13), " ")
    s = Replace(s, Chr(7), " ")
    s = Replace(s, vbTab, " ")
    CleanWordCellText = Trim(s)
End Function

Private Function FindBestHtmlTable(ByVal html As String) As Object
    Dim doc As Object
    Set doc = CreateObject("htmlfile")
    doc.Body.innerHTML = html
    
    Dim tables As Object, tbl As Object, best As Object
    Dim bestArea As Long, area As Long
    
    Set tables = doc.getElementsByTagName("table")
    If tables.Length = 0 Then
        Set FindBestHtmlTable = Nothing
        Exit Function
    End If
    
    For Each tbl In tables
        area = tbl.rows.Length * 10
        If area > bestArea Then
            Set best = tbl
            bestArea = area
        End If
    Next tbl
    
    Set FindBestHtmlTable = best
End Function

Private Function CleanText(ByVal s As String) As String
    s = Replace(s, Chr(160), " ")
    s = Replace(s, Chr(13), " ")
    s = Replace(s, Chr(10), " ")
    s = Replace(s, vbTab, " ")
    CleanText = Trim(s)
End Function

Private Function HalleAusgeschrieben(ByVal h As String) As String
    Dim s As String
    s = Trim(CStr(h))
    If s = "" Then Exit Function
    If UCase(Left(s, 1)) = "H" Then s = Mid(s, 2)
    HalleAusgeschrieben = "Halle " & s
End Function

Private Function ToTimeFraction(ByVal v As Variant) As Double
    On Error GoTo Fallback
    If IsEmpty(v) Or v = "" Then Exit Function
    If IsDate(v) Then
        ToTimeFraction = CDbl(TimeValue(v))
        Exit Function
    End If
    If IsNumeric(v) Then
        Dim x As Double
        x = CDbl(v)
        ToTimeFraction = IIf(x > 1#, x / 24#, x)
        Exit Function
    End If
    Dim s As String
    s = Trim(CStr(v))
    s = Replace(s, ".", ":")
    s = Replace(s, ",", ":")
    If InStr(s, ":") > 0 Then
        ToTimeFraction = CDbl(TimeValue(s))
        Exit Function
    End If
Fallback:
    ToTimeFraction = 0
End Function

Private Function DurationFrom(ByVal tStart As Double, ByVal tEnd As Double) As Double
    Dim d As Double
    d = tEnd - tStart
    If d < 0 Then d = d + 1#
    DurationFrom = d
End Function
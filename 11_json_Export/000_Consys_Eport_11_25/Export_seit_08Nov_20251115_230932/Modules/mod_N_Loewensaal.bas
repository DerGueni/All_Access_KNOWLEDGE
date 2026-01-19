'Attribute VB_Name = "mod_N_Loewensaal"
Option Compare Database
Option Explicit

' ============================================================================
' Modul: mod_N_loewensaal
' Version: 5.9 FINAL  (mit Location-Overrides für Morlock/Ronhof)
' ============================================================================

Private Const EXCEL_FILE_PATH As String = "\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\ZZ  CBF Veranstaltungen 2025  2026.xlsm"
Private Const TREFFPUNKT_DEFAULT As String = "15 min vor DB vor Ort"
Private Const DIENSTKLEIDUNG_DEFAULT As String = "Consec"
Private Const VERANSTALTER_ID_DEFAULT As Long = 10233

' Location-Liste: NUR diese Objekte werden importiert
Private Const RELEVANT_LOCATIONS As String = _
    "Löwensaal|" & _
    "Loewensaal|" & _
    "Heinrich-Lades-Halle|" & _
    "Meistersingerhalle|" & _
    "Serenadenhof|" & _
    "Stadionpark|" & _
    "Markgrafensaal|" & _
    "Stadthalle|" & _
    "PSD Bank Arena|" & _
    "Donau-Arena|" & _
    "Schloss Jägersburg|" & _
    "Burg Abenberg|" & _
    "LUX-Kirche|" & _
    "Jurahalle|" & _
    "Brauereigutshof|" & _
    "Strandbad am Segelhafen|" & _
    "KIA Metropol Arena|" & _
    "Max-Morlock-Stadion|" & _
    "Sportpark am Ronhof|"

' ---------- NEU: Override-Konstanten ----------
Private Const VERANSTALTER_ID_MORLOCK As Long = 20771
Private Const VERANSTALTER_ID_RONHOF  As Long = 20737
Private Const DIENSTKLEIDUNG_SPEZIAL  As String = "schwarz neutral"
' ---------------------------------------------

Public Type EventInfo
    Datum As Date
    DatumStr As String
    titel As String
    Ort As String
    Objekt As String
    VeranstalterID As Long
    ExistiertInDB As Boolean
    SheetQuelle As String
    Treffpunkt As String
    einlasszeit As Date
    EinlasszeitStr As String
End Type

Private Type SchichtInfo
    anzahlMA As Integer
    MinutenVorEinlass As Integer
    FixeStartzeit As String
End Type

Private Function DatumFuerSQL(ByVal Datum As Date) As String
    DatumFuerSQL = Month(Datum) & "/" & Day(Datum) & "/" & year(Datum)
End Function

Private Function DatumZeitFuerSQL(ByVal datumZeit As Date) As String
    DatumZeitFuerSQL = Month(datumZeit) & "/" & Day(datumZeit) & "/" & year(datumZeit) & " " & Format(datumZeit, "hh:nn:ss")
End Function

Private Function NormalisiereTitel(ByVal titel As String) As String
    If titel = UCase$(titel) Then
        NormalisiereTitel = ToTitleCase(titel)
        Debug.Print "      > Titel normalisiert: " & titel & " -> " & NormalisiereTitel
    Else
        NormalisiereTitel = titel
    End If
End Function

Public Sub SyncLoewensaalEvents()
    On Error GoTo ErrorHandler
    
    Dim allEvents() As EventInfo
    Dim eventCount As Integer
    Dim newCount As Integer
    Dim i As Integer
    Dim heutesDatum As Date
    
    heutesDatum = Date
    
    If Dir(EXCEL_FILE_PATH) = "" Then
        MsgBox "Excel-Datei nicht gefunden:" & vbCrLf & EXCEL_FILE_PATH, vbCritical, "Datei nicht gefunden"
        Exit Sub
    End If
    
    DoCmd.Hourglass True
    Debug.Print String(80, "=")
    Debug.Print "=== Excel-Import Synchronisation gestartet ==="
    Debug.Print "Version: 5.9 FINAL"
    Debug.Print "Filter: NUR definierte Locations"
    Debug.Print "TVA_Soll Update: AKTIV"
    Debug.Print String(80, "=")
    
    allEvents = LoadEventsFromExcel(EXCEL_FILE_PATH, heutesDatum)
    eventCount = UBound(allEvents) - LBound(allEvents) + 1
    
    If eventCount = 0 Or (eventCount = 1 And Len(Trim(allEvents(0).titel)) = 0) Then
        DoCmd.Hourglass False
        MsgBox "Keine relevanten Events gefunden.", vbInformation
        Exit Sub
    End If
    
    Debug.Print vbCrLf & "Gefundene Events: " & eventCount
    
    newCount = 0
    For i = LBound(allEvents) To UBound(allEvents)
        allEvents(i).ExistiertInDB = EventExistsInDatabase(allEvents(i).Datum, allEvents(i).titel, allEvents(i).Objekt)
        If Not allEvents(i).ExistiertInDB Then newCount = newCount + 1
    Next i
    
    Debug.Print "Neue Events: " & newCount
    
    If newCount = 0 Then
        DoCmd.Hourglass False
        MsgBox "Alle Events bereits vorhanden.", vbInformation
        Exit Sub
    End If
    
    Dim successCount As Integer, errorCount As Integer
    Dim successDetails As String
    successCount = 0: errorCount = 0
    
    For i = LBound(allEvents) To UBound(allEvents)
        If Not allEvents(i).ExistiertInDB Then
            Debug.Print vbCrLf & "  [" & i & "] " & allEvents(i).titel
            Debug.Print "       Location: " & allEvents(i).Objekt
            Debug.Print "       Einlass: " & allEvents(i).EinlasszeitStr
            
            Dim ergebnis As String
            ergebnis = CreateNewAuftragMitSchichten(allEvents(i))
            
            If Left(ergebnis, 7) = "SUCCESS" Then
                successCount = successCount + 1
                Dim Teile() As String
                Teile = Split(ergebnis, "|")
                If UBound(Teile) >= 1 Then
                    Call KorrigiereAuftragBooleans(CLng(Teile(1)))
                    successDetails = successDetails & "* ID " & Teile(1) & ": " & Left(allEvents(i).titel, 50) & vbCrLf
                    Debug.Print "       > Erfolgreich (ID: " & Teile(1) & ")"
                End If
            Else
                errorCount = errorCount + 1
                Debug.Print "       > FEHLER: " & ergebnis
            End If
        End If
    Next i
    
    DoCmd.Hourglass False
    
    Debug.Print vbCrLf & String(80, "=")
    Debug.Print "=== Import abgeschlossen ==="
    Debug.Print "Erfolgreich: " & successCount & " | Fehler: " & errorCount
    Debug.Print String(80, "=")
    
    If errorCount = 0 Then
        MsgBox "Import erfolgreich!" & vbCrLf & vbCrLf & "Neue Events: " & successCount & vbCrLf & vbCrLf & successDetails, vbInformation
    Else
        MsgBox "Import mit Fehlern:" & vbCrLf & vbCrLf & "Erfolgreich: " & successCount & vbCrLf & "Fehler: " & errorCount, vbExclamation
    End If
    
    Exit Sub
    
ErrorHandler:
    DoCmd.Hourglass False
    MsgBox "Fehler: " & err.description, vbCritical
End Sub

' ---------- NEU: Overrides anwenden & Update Auftragstamm ----------
' Entscheidet anhand des Objekt-/Location-Namens, ob spezieller Veranstalter
' und "schwarz neutral" zu setzen sind (Morlock/Ronhof).
Private Sub ApplyLocationOverrides(ByVal objektName As String, _
                                  ByRef outVeranstalterID As Long, _
                                  ByRef outDienstkleidung As String, _
                                  ByRef outHatOverride As Boolean)

    Dim U As String
    U = UCase$(Trim$(objektName))
    outHatOverride = False

    ' Morlock / Max-Morlock
    If (InStr(U, "MAX-MORLOCK") > 0) Or (InStr(U, "MORLOCK") > 0) Then
        outVeranstalterID = VERANSTALTER_ID_MORLOCK
        outDienstkleidung = DIENSTKLEIDUNG_SPEZIAL
        outHatOverride = True
        Exit Sub
    End If

    ' Sportpark am Ronhof / Ronhof
    If (InStr(U, "SPORTPARK AM RONHOF") > 0) Or (InStr(U, "RONHOF") > 0) Then
        outVeranstalterID = VERANSTALTER_ID_RONHOF
        outDienstkleidung = DIENSTKLEIDUNG_SPEZIAL
        outHatOverride = True
        Exit Sub
    End If
End Sub
' ------------------------------------------------------------------

Private Function CreateNewAuftragMitSchichten(evt As EventInfo) As String
    On Error GoTo ErrorHandler
    
    Dim ortName As String
    ortName = evt.Ort
    ' Nuernberg ohne Umlaut
    If Len(Trim(ortName)) = 0 Then ortName = "Nuernberg"
    
    Dim titelNormalisiert As String
    titelNormalisiert = NormalisiereTitel(evt.titel)
    
    Dim ergebnis As String
    ergebnis = AuftragErstellen( _
        auftragsName:=titelNormalisiert, _
        objektName:=evt.Objekt, _
        ortName:=ortName, _
        DatumVon:=evt.Datum, _
        DatumBis:=evt.Datum, _
        auftraggeber:="", _
        Treffpunkt:=evt.Treffpunkt, _
        schichten:="", _
        statusID:=1, _
        Ersteller:="Excel-Import" _
    )
    
    If Left(ergebnis, 7) = "SUCCESS" Then
        Dim Teile() As String
        Teile = Split(ergebnis, "|")
        If UBound(Teile) >= 1 Then
            Dim auftragsID As Long
            auftragsID = CLng(Teile(1))
            
            ' --------- NEU: Location-Overrides für Veranstalter & Dienstkleidung ---------
            Dim zielVeranstalterID As Long
            Dim zielDienstkleidung As String
            Dim hatOverride As Boolean
            zielVeranstalterID = VERANSTALTER_ID_DEFAULT
            zielDienstkleidung = DIENSTKLEIDUNG_DEFAULT
            Call ApplyLocationOverrides(evt.Objekt, zielVeranstalterID, zielDienstkleidung, hatOverride)

            ' Erstversuch: beide Felder updaten (inkl. Dienstkleidung)
            Dim sql As String
            sql = "UPDATE tbl_VA_Auftragstamm " & _
                  "SET Veranstalter_ID = " & CLng(zielVeranstalterID) & ", " & _
                  "Dienstkleidung = '" & Replace(zielDienstkleidung, "'", "''") & "' " & _
                  "WHERE ID = " & auftragsID

            On Error Resume Next
            CurrentDb.Execute sql, dbFailOnError
            If err.Number <> 0 Then
                ' Falls z. B. Feld Dienstkleidung nicht existiert -> Fallback nur Veranstalter setzen
                Debug.Print "       > Hinweis: Update mit Dienstkleidung fehlgeschlagen (" & err.Number & "): " & err.description
                err.clear
                sql = "UPDATE tbl_VA_Auftragstamm SET Veranstalter_ID = " & CLng(zielVeranstalterID) & " WHERE ID = " & auftragsID
                CurrentDb.Execute sql, dbFailOnError
                If err.Number <> 0 Then
                    Debug.Print "       > FEHLER: Veranstalter_ID-Update fehlgeschlagen: " & err.description
                Else
                    Debug.Print "       > Veranstalter_ID gesetzt (Fallback)."
                End If
            Else
                Debug.Print "       > Veranstalter_ID & Dienstkleidung aktualisiert."
            End If
            On Error GoTo ErrorHandler

            If hatOverride Then
                Debug.Print "       > Override aktiv: Veranstalter_ID=" & zielVeranstalterID & _
                            " | Dienstkleidung='" & zielDienstkleidung & "'"
            Else
                Debug.Print "       > Standardwerte gesetzt: Veranstalter_ID=" & VERANSTALTER_ID_DEFAULT & _
                            " | Dienstkleidung='" & DIENSTKLEIDUNG_DEFAULT & "'"
            End If
            ' ---------------------------------------------------------------------------

            ' VADatum ermitteln
            Dim vaDatumID As Long
            vaDatumID = HoleVADatumID(auftragsID, evt.Datum)
            
            If vaDatumID = 0 Then
                Debug.Print "       > FEHLER: VADatum_ID nicht gefunden!"
                CreateNewAuftragMitSchichten = "FEHLER: VADatum_ID nicht gefunden"
                Exit Function
            End If
            
            ' Schichten erstellen
            Dim anzahlSchichten As Integer
            anzahlSchichten = ErstelleSchichtenFuerLocation(auftragsID, vaDatumID, evt.Datum, evt.Objekt, evt.einlasszeit)
            
            If anzahlSchichten > 0 Then
                Call AktualisiereVAAnzTage(vaDatumID, anzahlSchichten)
                Debug.Print "       > TVA_Soll: " & anzahlSchichten & " MA"
            Else
                Debug.Print "       > WARNUNG: Keine Schichten erstellt!"
            End If
        End If
    End If
    
    CreateNewAuftragMitSchichten = ergebnis
    Exit Function
    
ErrorHandler:
    CreateNewAuftragMitSchichten = "FEHLER: " & err.description
    Debug.Print "       > Fehler: " & err.description
End Function

Private Sub AktualisiereVAAnzTage(ByVal vaDatumID As Long, ByVal anzahlMA As Integer)
    On Error Resume Next
    
    Dim sql As String
    sql = "UPDATE tbl_VA_AnzTage SET TVA_Soll = " & anzahlMA & ", TVA_Ist = 0 WHERE ID = " & vaDatumID
    
    CurrentDb.Execute sql
    
    If err.Number <> 0 Then
        Debug.Print "       > Update-Fehler TVA_Soll: " & err.description
    End If
End Sub

Private Function HoleVADatumID(ByVal auftragsID As Long, ByVal eventDatum As Date) As Long
    On Error Resume Next
    
    Dim rs As DAO.Recordset
    Dim sql As String
    
    sql = "SELECT ID FROM tbl_VA_AnzTage WHERE VA_ID = " & auftragsID & " AND VADatum = #" & DatumFuerSQL(eventDatum) & "#"
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    
    If Not rs.EOF Then
        HoleVADatumID = rs.fields("ID").Value
    Else
        HoleVADatumID = 0
    End If
    
    rs.Close
    Set rs = Nothing
End Function

' ============================================================================
' SCHICHTERSTELLUNG - MITARBEITERZAHLEN
' ============================================================================
Private Function ErstelleSchichtenFuerLocation(ByVal auftragsID As Long, _
                                               ByVal vaDatumID As Long, _
                                               ByVal eventDatum As Date, _
                                               ByVal Location As String, _
                                               ByVal einlasszeit As Date) As Integer
    On Error GoTo ErrorHandler
    
    Dim schichten() As SchichtInfo
    Dim locationUpper As String
    Dim schichtCount As Integer
    Dim gesamtAnzahlMA As Integer
    Dim i As Integer
    Dim startzeit As Date, endzeit As Date
    
    locationUpper = UCase(Trim(Location))
    gesamtAnzahlMA = 0
    
    ' Löwensaal: 13 MA (11+1+1)  -> Reihenfolge: 90, 60, 30
    If InStr(locationUpper, "LÖWENSAAL") > 0 Or InStr(locationUpper, "LOEWENSAAL") > 0 Then
        ReDim schichten(0 To 2)
        schichten(0).anzahlMA = 1:  schichten(0).MinutenVorEinlass = 90
        schichten(1).anzahlMA = 1:  schichten(1).MinutenVorEinlass = 60
        schichten(2).anzahlMA = 11: schichten(2).MinutenVorEinlass = 30
        schichtCount = 3
        gesamtAnzahlMA = 13
        Debug.Print "       > Löwensaal: 1@90 + 1@60 + 11@30 = 13 MA"
        
    ' Meistersingerhalle: 2 MA -> 30
    ElseIf InStr(locationUpper, "MEISTERSINGERHALLE") > 0 Then
        ReDim schichten(0 To 0)
        schichten(0).anzahlMA = 2: schichten(0).MinutenVorEinlass = 30
        schichtCount = 1
        gesamtAnzahlMA = 2
        Debug.Print "       > Meistersingerhalle: 2@30 = 2 MA"
        
    ' Markgrafensaal: 2 MA -> 30
    ElseIf InStr(locationUpper, "MARKGRAFENSAAL") > 0 Then
        ReDim schichten(0 To 0)
        schichten(0).anzahlMA = 2: schichten(0).MinutenVorEinlass = 30
        schichtCount = 1
        gesamtAnzahlMA = 2
        Debug.Print "       > Markgrafensaal: 2@30 = 2 MA"
        
    ' Stadthalle: 17 MA (15+1+1) -> Reihenfolge: 480, 60, 30
    ElseIf InStr(locationUpper, "STADTHALLE") > 0 Then
        ReDim schichten(0 To 2)
        schichten(0).anzahlMA = 1:  schichten(0).MinutenVorEinlass = 480
        schichten(1).anzahlMA = 1:  schichten(1).MinutenVorEinlass = 60
        schichten(2).anzahlMA = 15: schichten(2).MinutenVorEinlass = 30
        schichtCount = 3
        gesamtAnzahlMA = 17
        Debug.Print "       > Stadthalle: 1@480 + 1@60 + 15@30 = 17 MA"
        
    ' Max-Morlock-Stadion (FCN) -> Reihenfolge: 165, 135
    ElseIf InStr(locationUpper, "MAX-MORLOCK") > 0 Or InStr(locationUpper, "MORLOCK") > 0 Then
        ReDim schichten(0 To 1)
        schichten(0).anzahlMA = 2:  schichten(0).MinutenVorEinlass = 165
        schichten(1).anzahlMA = 60: schichten(1).MinutenVorEinlass = 135
        schichtCount = 2
        gesamtAnzahlMA = 62
        Debug.Print "       > Max-Morlock-Stadion: 2@165 + 60@135 = 62 MA"
        
    ' Sportpark Ronhof (Greuther Fürth) -> Reihenfolge: 180, 150
    ElseIf InStr(locationUpper, "RONHOF") > 0 Then
        ReDim schichten(0 To 1)
        schichten(0).anzahlMA = 2:  schichten(0).MinutenVorEinlass = 180
        schichten(1).anzahlMA = 40: schichten(1).MinutenVorEinlass = 150
        schichtCount = 2
        gesamtAnzahlMA = 42
        Debug.Print "       > Sportpark Ronhof: 2@180 + 40@150 = 42 MA"
        
    Else
        Debug.Print "       > KEINE Schichtkonfiguration fuer: " & Location
        ErstelleSchichtenFuerLocation = 0
        Exit Function
    End If
    
    ' SCHICHTEN ERSTELLEN
    endzeit = DateSerial(year(eventDatum), Month(eventDatum), Day(eventDatum)) + TimeSerial(23, 30, 0)
    
    For i = 0 To schichtCount - 1
        ' Startzeit immer relativ zum Einlass (größter Abstand zuerst)
        startzeit = DateAdd("n", -schichten(i).MinutenVorEinlass, einlasszeit)

        ' *** NEU: Ein Datensatz pro Schicht mit der jeweiligen Gesamtanzahl ***
        Call SchichtEintragErstellen(auftragsID, vaDatumID, eventDatum, startzeit, endzeit, schichten(i).anzahlMA)
        
        Debug.Print "         - " & schichten(i).anzahlMA & " MA: " & _
                    Format(startzeit, "hh:nn") & "-" & Format(endzeit, "hh:nn") & _
                    " (Start -" & schichten(i).MinutenVorEinlass & " min)"
    Next i
    
    ErstelleSchichtenFuerLocation = gesamtAnzahlMA
    Exit Function
    
ErrorHandler:
    Debug.Print "       > Schicht-Fehler: " & err.description
    ErstelleSchichtenFuerLocation = 0
End Function

Private Sub SchichtEintragErstellen(ByVal auftragsID As Long, _
                                    ByVal vaDatumID As Long, _
                                    ByVal eventDatum As Date, _
                                    ByVal startzeit As Date, _
                                    ByVal endzeit As Date, _
                                    ByVal maAnzahl As Integer)
    On Error Resume Next
    
    Dim sql As String
    sql = "INSERT INTO tbl_VA_Start (VA_ID, VADatum_ID, VADatum, MA_Anzahl, VA_Start, VA_Ende, MVA_Start, MVA_Ende) " & _
          "VALUES (" & auftragsID & ", " & vaDatumID & ", " & _
          "#" & DatumFuerSQL(eventDatum) & "#, " & CInt(maAnzahl) & ", " & _
          "#" & Format(startzeit, "hh:nn:ss") & "#, " & _
          "#" & Format(endzeit, "hh:nn:ss") & "#, " & _
          "#" & DatumZeitFuerSQL(startzeit) & "#, " & _
          "#" & DatumZeitFuerSQL(endzeit) & "#)"
    
    CurrentDb.Execute sql
    
    If err.Number <> 0 Then
        Debug.Print "         > SQL-Fehler: " & err.description
    End If
End Sub

' ============================================================================
' LOCATION-FILTER - NUR DEFINIERTE LOCATIONS
' ============================================================================
Private Function IsRelevantLocation(Objekt As String) As Boolean
    If Len(Trim(Objekt)) = 0 Then
        IsRelevantLocation = False
        Exit Function
    End If
    
    Dim locations As Variant, Location As Variant
    locations = Split(RELEVANT_LOCATIONS, "|")
    
    Dim objektUpper As String
    objektUpper = UCase(Trim(Objekt))
    
    For Each Location In locations
        If Len(Trim(CStr(Location))) > 0 Then
            If InStr(1, objektUpper, UCase(Trim(CStr(Location))), vbTextCompare) > 0 Then
                IsRelevantLocation = True
                Exit Function
            End If
        End If
    Next Location
    
    IsRelevantLocation = False
End Function

Private Function LoadEventsFromExcel(filePath As String, minDatum As Date) As EventInfo()
    On Error GoTo ErrorHandler
    
    Dim xlApp As Object, xlBook As Object, xlSheet As Object
    Dim allEvents() As EventInfo
    Dim totalCount As Integer
    Dim sheetsToProcess As Variant
    Dim i As Integer
    
    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = False
    xlApp.DisplayAlerts = False
    Set xlBook = xlApp.Workbooks.Open(filePath, ReadOnly:=True)
    
    sheetsToProcess = Array( _
        "CBF Löwensaal", _
        "CBF Loewensaal", _
        "CBF Serenadenhof", _
        "CBF Veranstaltungen 2025-2026", _
        "1.FC Nürnberg Herren", _
        "1.FC Nürnberg Frauen", _
        "SpVgg Greuther Fürth", _
        "Greuther Fürth" _
    )
    
    ReDim allEvents(0 To 999)
    totalCount = 0
    
    For i = LBound(sheetsToProcess) To UBound(sheetsToProcess)
        On Error Resume Next
        Set xlSheet = xlBook.Worksheets(CStr(sheetsToProcess(i)))
        If err.Number = 0 And Not xlSheet Is Nothing Then
            On Error GoTo ErrorHandler
            Debug.Print "  > Sheet: " & sheetsToProcess(i)
            totalCount = ProcessExcelSheet(xlSheet, CStr(sheetsToProcess(i)), allEvents, totalCount, minDatum)
        End If
        Set xlSheet = Nothing
    Next i
    
    xlBook.Close SaveChanges:=False
    xlApp.Quit
    Set xlSheet = Nothing: Set xlBook = Nothing: Set xlApp = Nothing
    
    If totalCount > 0 Then
        ReDim Preserve allEvents(0 To totalCount - 1)
    Else
        ReDim allEvents(0 To 0)
        allEvents(0).titel = ""
    End If
    
    LoadEventsFromExcel = allEvents
    Exit Function
    
ErrorHandler:
    On Error Resume Next
    If Not xlBook Is Nothing Then xlBook.Close SaveChanges:=False
    If Not xlApp Is Nothing Then xlApp.Quit
    ReDim allEvents(0 To 0)
    allEvents(0).titel = ""
    LoadEventsFromExcel = allEvents
End Function

Private Function ProcessExcelSheet(xlSheet As Object, sheetName As String, ByRef allEvents() As EventInfo, startIndex As Integer, minDatum As Date) As Integer
    On Error GoTo ErrorHandler
    
    Dim row As Long, Datum As Variant, titel As String, Ort As String, Objekt As String, einlassStr As String
    Dim currentIndex As Integer, lastRow As Long, eventDate As Date
    Dim startCol As Long, maxCol As Long
    
    currentIndex = startIndex
    lastRow = xlSheet.UsedRange.rows.Count
    maxCol = xlSheet.UsedRange.Columns.Count
    
    If lastRow < 2 Then
        ProcessExcelSheet = currentIndex
        Exit Function
    End If
    
    For startCol = 1 To maxCol Step 5
        On Error Resume Next
        If xlSheet.Cells(1, startCol).Value = "Datum" Then
            On Error GoTo ErrorHandler
            
            For row = 2 To lastRow
                On Error Resume Next
                Datum = xlSheet.Cells(row, startCol).Value
                titel = Trim(CStr(Nz(xlSheet.Cells(row, startCol + 1).Value, "")))
                Ort = Trim(CStr(Nz(xlSheet.Cells(row, startCol + 2).Value, "")))
                Objekt = Trim(CStr(Nz(xlSheet.Cells(row, startCol + 3).Value, "")))
                einlassStr = Trim(CStr(Nz(xlSheet.Cells(row, startCol + 4).Value, "")))
                On Error GoTo ErrorHandler
                
                If Not IsEmpty(Datum) And Len(titel) > 0 And Len(Objekt) > 0 Then
                    If IsRelevantLocation(Objekt) Then
                        If IsDate(Datum) Then
                            eventDate = CDate(Datum)
                            If eventDate >= minDatum And eventDate <= #12/31/2099# Then
                                If Not IsDuplicateEvent(allEvents, currentIndex, eventDate, titel, Objekt) Then
                                    If Len(Trim(Ort)) = 0 Then
                                        If InStr(UCase(Objekt), "RONHOF") > 0 Or InStr(UCase(Objekt), "FUERTH") > 0 Or InStr(UCase(Objekt), "FÜRTH") > 0 Then
                                            Ort = "Fuerth"
                                        Else
                                            Ort = "Nuernberg"
                                        End If
                                    End If
                                    
                                    Dim einlasszeitDate As Date
                                    If Len(einlassStr) > 0 Then
                                        einlasszeitDate = ParseEinlasszeit(einlassStr, eventDate)
                                    Else
                                        einlasszeitDate = DateSerial(year(eventDate), Month(eventDate), Day(eventDate)) + TimeSerial(19, 0, 0)
                                    End If

                                    allEvents(currentIndex).Datum = eventDate
                                    allEvents(currentIndex).DatumStr = Format(eventDate, "dd.mm.yyyy")
                                    allEvents(currentIndex).titel = titel
                                    allEvents(currentIndex).Ort = Ort
                                    allEvents(currentIndex).Objekt = Objekt
                                    allEvents(currentIndex).VeranstalterID = VERANSTALTER_ID_DEFAULT
                                    allEvents(currentIndex).ExistiertInDB = False
                                    allEvents(currentIndex).SheetQuelle = sheetName
                                    allEvents(currentIndex).Treffpunkt = TREFFPUNKT_DEFAULT
                                    allEvents(currentIndex).einlasszeit = einlasszeitDate
                                    allEvents(currentIndex).EinlasszeitStr = Format(einlasszeitDate, "hh:mm")

                                    currentIndex = currentIndex + 1
                                    If currentIndex > UBound(allEvents) Then
                                        ReDim Preserve allEvents(0 To UBound(allEvents) + 500)
                                    End If
                                End If
                            End If
                        End If
                    End If
                End If
            Next row
        End If
    Next startCol
    
    ProcessExcelSheet = currentIndex
    Exit Function
    
ErrorHandler:
    ProcessExcelSheet = currentIndex
End Function

Private Function ParseEinlasszeit(zeitStr As String, eventDate As Date) As Date
    Dim stunde As Integer
    Dim minute As Integer
    Dim Teile() As String
    
    zeitStr = Replace(zeitStr, "Uhr", "")
    zeitStr = Replace(zeitStr, ".", ":")
    zeitStr = Trim(zeitStr)
    
    If InStr(zeitStr, ":") > 0 Then
        Teile = Split(zeitStr, ":")
        If UBound(Teile) >= 1 Then
            stunde = Val(Trim(Teile(0)))
            minute = Val(Trim(Left(Teile(1), 2)))
            
            If stunde >= 0 And stunde <= 23 And minute >= 0 And minute <= 59 Then
                ParseEinlasszeit = DateSerial(year(eventDate), Month(eventDate), Day(eventDate)) + TimeSerial(stunde, minute, 0)
                Exit Function
            End If
        End If
    End If
    
    ParseEinlasszeit = DateSerial(year(eventDate), Month(eventDate), Day(eventDate)) + TimeSerial(19, 0, 0)
End Function

Private Function IsDuplicateEvent(events() As EventInfo, Count As Integer, eventDate As Date, titel As String, Objekt As String) As Boolean
    Dim i As Integer
    For i = 0 To Count - 1
        If events(i).Datum = eventDate And StrComp(events(i).titel, titel, vbTextCompare) = 0 And StrComp(events(i).Objekt, Objekt, vbTextCompare) = 0 Then
            IsDuplicateEvent = True
            Exit Function
        End If
    Next i
    IsDuplicateEvent = False
End Function

Public Function EventExistsInDatabase(ByVal eventDatum As Date, _
                                      ByVal eventTitel As String, _
                                      ByVal eventObjekt As String) As Boolean
    On Error GoTo ErrorHandler
    
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim found As Boolean
    Dim dbTitel As String
    Dim titelNormalisiert As String
    
    sql = "SELECT Auftrag FROM tbl_VA_Auftragstamm " & _
          "WHERE Dat_VA_Von = #" & DatumFuerSQL(eventDatum) & "# " & _
          "AND Objekt = '" & Replace(eventObjekt, "'", "''") & "'"
    
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    
    If eventTitel = UCase$(eventTitel) Then
        titelNormalisiert = ToTitleCase(eventTitel)
    Else
        titelNormalisiert = eventTitel
    End If
    
    found = False
    Do While Not rs.EOF
        dbTitel = Trim(Nz(rs!Auftrag, ""))
        
        If StrComp(dbTitel, eventTitel, vbTextCompare) = 0 Or _
           StrComp(dbTitel, titelNormalisiert, vbTextCompare) = 0 Then
            found = True
            Debug.Print "       > Bereits vorhanden: " & dbTitel
            Exit Do
        End If
        
        rs.MoveNext
    Loop
    
    rs.Close
    Set rs = Nothing
    EventExistsInDatabase = found
    Exit Function
    
ErrorHandler:
    EventExistsInDatabase = False
    Debug.Print "       > Fehler in EventExistsInDatabase: " & err.description
End Function

Public Sub KorrigiereAuftragBooleans(ByVal auftragsID As Long)
    On Error Resume Next
    Dim rs As DAO.Recordset, i As Integer, hatUpdate As Boolean
    Set rs = CurrentDb.OpenRecordset("SELECT * FROM tbl_VA_Auftragstamm WHERE ID = " & auftragsID, dbOpenDynaset)
    
    If Not rs.EOF Then
        hatUpdate = False
        For i = 0 To rs.fields.Count - 1
            If rs.fields(i).Type = dbBoolean Then
                If Not hatUpdate Then
                    rs.Edit
                    hatUpdate = True
                End If
                rs.fields(i).Value = True
            End If
        Next i
        If hatUpdate Then rs.update
    End If
    rs.Close
End Sub

Public Function ToTitleCase(inputText As String) As String
    If Len(Trim(inputText)) = 0 Then
        ToTitleCase = ""
        Exit Function
    End If
    
    Dim words() As String, i As Integer, result As String
    words = Split(LCase(Trim(inputText)), " ")
    result = ""
    
    For i = LBound(words) To UBound(words)
        If Len(words(i)) > 0 Then
            words(i) = UCase(Left(words(i), 1)) & Mid(words(i), 2)
            result = result & IIf(Len(result) > 0, " ", "") & words(i)
        End If
    Next i
    ToTitleCase = result
End Function

Private Function Nz(Value As Variant, Optional valueIfNull As Variant = "") As Variant
    Nz = IIf(IsNull(Value) Or IsEmpty(Value), valueIfNull, Value)
End Function

' DoWebScan = True   ? zuerst Excel per Website-Makro aktualisieren, dann Access-Sync
Public Sub RunLoewensaalSync(Optional ByVal DoWebScan As Boolean = False)
    On Error GoTo ErrorHandler

    Dim excelAktualisiert As Boolean
    excelAktualisiert = False

    If DoWebScan Then
        DoCmd.Hourglass True
        Debug.Print String(80, "=")
        Debug.Print "=== SCHRITT 1: Excel-Aktualisierung von Website ==="
        Debug.Print String(80, "=")

        If AktualisiereCBFExcelVonWebsite() Then
            Debug.Print "Excel-Datei erfolgreich aktualisiert."
            excelAktualisiert = True
        Else
            Debug.Print "Excel-Aktualisierung fehlgeschlagen – Synchronisation wird trotzdem fortgesetzt."
        End If
        DoCmd.Hourglass False
    End If

    DoCmd.Hourglass True
    Debug.Print vbCrLf & String(80, "=")
    Debug.Print "=== SCHRITT 2: Access-Synchronisation aus Excel ==="
    Debug.Print String(80, "=")

    ' Auftrags-Sync starten (Prozedur aus mod_N_Loewensaal)
    mod_N_Loewensaal.SyncLoewensaalEvents

    DoCmd.Hourglass False

    Exit Sub
ErrorHandler:
    DoCmd.Hourglass False
    Debug.Print "Fehler in RunLoewensaalSync: " & err.description
    MsgBox "Fehler in RunLoewensaalSync:" & vbCrLf & err.description, vbCritical
End Sub

' Bequeme Wrapper – optional nutzbar:
Public Sub RunLoewensaalSync_OnlySync()
    RunLoewensaalSync False
End Sub

Public Sub RunLoewensaalSync_WithWebScan()
    RunLoewensaalSync True
End Sub

' ============================================================================
' HILFSFUNKTION: Excel-Aktualisierung von Website (ruft Excel-Makro auf)
' ============================================================================
Private Function AktualisiereCBFExcelVonWebsite() As Boolean
    On Error GoTo ErrorHandler

    Const EXCEL_FILE_PATH As String = "\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\ZZ  CBF Veranstaltungen 2025  2026.xlsm"

    ' Prüfen, ob die Excel-Datei existiert
    If Dir(EXCEL_FILE_PATH) = "" Then
        Debug.Print "? Excel-Datei nicht gefunden: " & EXCEL_FILE_PATH
        AktualisiereCBFExcelVonWebsite = False
        Exit Function
    End If

    Debug.Print "… Öffne Excel-Datei: " & EXCEL_FILE_PATH

    Dim xlApp As Object
    Dim xlBook As Object

    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = False
    xlApp.DisplayAlerts = False

    Set xlBook = xlApp.Workbooks.Open(EXCEL_FILE_PATH)

    Debug.Print "… Führe Makro 'Lade_CBF_Veranstaltungen_Aktualisieren' aus …"

    On Error Resume Next
    xlApp.Run "'" & xlBook.Name & "'!Lade_CBF_Veranstaltungen_Aktualisieren"
    If err.Number <> 0 Then
        Debug.Print "? Fehler beim Ausführen des Makros: " & err.description
        xlBook.Close SaveChanges:=False
        xlApp.Quit
        Set xlBook = Nothing
        Set xlApp = Nothing
        AktualisiereCBFExcelVonWebsite = False
        Exit Function
    End If
    On Error GoTo ErrorHandler

    Debug.Print "? Makro erfolgreich ausgeführt."

    Debug.Print "… Speichere Excel-Datei …"
    xlBook.Save
    xlBook.Close SaveChanges:=False
    xlApp.Quit

    Set xlBook = Nothing
    Set xlApp = Nothing

    Debug.Print "? Excel-Datei gespeichert und geschlossen."

    AktualisiereCBFExcelVonWebsite = True
    Exit Function

ErrorHandler:
    Debug.Print "Fehler in AktualisiereCBFExcelVonWebsite: " & err.description
    On Error Resume Next
    If Not xlBook Is Nothing Then xlBook.Close SaveChanges:=False
    If Not xlApp Is Nothing Then xlApp.Quit
    Set xlBook = Nothing
    Set xlApp = Nothing
    AktualisiereCBFExcelVonWebsite = False
End Function
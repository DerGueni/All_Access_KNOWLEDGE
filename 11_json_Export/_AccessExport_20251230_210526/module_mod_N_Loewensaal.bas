Option Compare Database
Option Explicit

' ============================================================================
' Modul: mod_N_loewensaal
' Version: 8.1 - STRENGE + FUZZY DUPLIKATERKENNUNG
' ============================================================================
' FEATURES:
' - Kein Excel blockieren (ADODB statt COM)
' - STRENGE Duplikat-Prüfung (95%+ Ähnlichkeit) zuerst
' - Fuzzy-Matching für Ort UND Titel als Fallback
' - Sport-Event-Erkennung (Vereinsnamen)
' - Normalisierung von Umlauten, Präfixen, Sonderzeichen
' - Stadionpark in Kern-Locations ergänzt
' ============================================================================

Private Const EXCEL_FILE_PATH As String = "\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\ZZ  CBF Veranstaltungen 2025  2026.xlsm"
Private Const TREFFPUNKT_DEFAULT As String = "15 min vor DB vor Ort"
Private Const DIENSTKLEIDUNG_DEFAULT As String = "Consec"
Private Const VERANSTALTER_ID_DEFAULT As Long = 10233

Private Const RELEVANT_LOCATIONS As String = _
    "Löwensaal|Loewensaal|Heinrich-Lades-Halle|Meistersingerhalle|Serenadenhof|" & _
    "Stadionpark|Markgrafensaal|Stadthalle|PSD Bank Nürnberg Arena|PSD Bank Arena Nürnberg|" & _
    "Donau-Arena|KIA Metropol Arena|Max-Morlock-Stadion|Sportpark am Ronhof"

Private Const VERANSTALTER_ID_MORLOCK As Long = 20771
Private Const VERANSTALTER_ID_RONHOF  As Long = 20737
Private Const DIENSTKLEIDUNG_SPEZIAL  As String = "schwarz neutral"

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
    IstFixeStartzeit As Boolean
    IstFixeEndzeit As Boolean
    FixeEndzeitStunden As Integer
    FixeEndzeitMinuten As Integer
End Type

' ============================================================================
' HAUPTFUNKTION: 2-ETAPPEN-WORKFLOW
' ============================================================================
Public Sub RunLoewensaalSync_2Etappen()
    On Error GoTo ErrorHandler
    
    Dim intAntwort As Integer
    Dim erfolg As Boolean
    
    ' ========== ETAPPE 1: WEB -> EXCEL ==========
    intAntwort = MsgBox("Excel Liste von Webseiten aktualisieren?" & vbCrLf & vbCrLf & _
                        "Kann 2-3 Min dauern.", _
                        vbQuestion + vbYesNoCancel, "Etappe 1: Web Update")
    
    If intAntwort = vbCancel Then Exit Sub
    
    If intAntwort = vbYes Then
        DoCmd.Hourglass True
        erfolg = AktualisiereCBFExcelVonWebsite_Safe()
        DoCmd.Hourglass False
        
        If Not erfolg Then
            MsgBox "Excel Update fehlgeschlagen!", vbCritical
            Exit Sub
        End If
    End If
    
    ' ========== ETAPPE 2: EXCEL -> ACCESS ==========
    intAntwort = MsgBox("Aufträge aus Excel Liste mit Access synchronisieren?" & vbCrLf & vbCrLf & _
                        "Neue Aufträge werden angelegt." & vbCrLf & _
                        "(Kann 2-3 Min. dauern)", _
                        vbQuestion + vbYesNo, "Etappe 2: Sync")
    
    If intAntwort = vbNo Then Exit Sub
    
    DoCmd.Hourglass True
    Call SyncLoewensaalEvents_ADODB
    DoCmd.Hourglass False
    
    Exit Sub
    
ErrorHandler:
    DoCmd.Hourglass False
    MsgBox "Fehler: " & Err.description, vbCritical
End Sub

' ============================================================================
' WRAPPER-FUNKTIONEN
' ============================================================================
Public Sub RunLoewensaalSync_WithWebScan()
    RunLoewensaalSync_2Etappen
End Sub

Public Sub RunLoewensaalSync_OnlySync()
    DoCmd.Hourglass True
    Call SyncLoewensaalEvents_ADODB
    DoCmd.Hourglass False
End Sub

' ============================================================================
' EXCEL-UPDATE (SICHER MIT TIMEOUT)
' ============================================================================
Private Function AktualisiereCBFExcelVonWebsite_Safe() As Boolean
    On Error GoTo ErrorHandler
    
    If Dir(EXCEL_FILE_PATH) = "" Then
        Debug.Print "Excel nicht gefunden: " & EXCEL_FILE_PATH
        AktualisiereCBFExcelVonWebsite_Safe = False
        Exit Function
    End If
    
    Dim xlApp As Object, xlBook As Object
    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = True
    xlApp.DisplayAlerts = False
    
    Set xlBook = xlApp.Workbooks.Open(EXCEL_FILE_PATH)
    
    On Error Resume Next
    xlApp.Run "'" & xlBook.Name & "'!Lade_CBF_Veranstaltungen_Aktualisieren"
    
    If Err.Number <> 0 Then
        Debug.Print "Makro-Fehler: " & Err.description
        xlBook.Close SaveChanges:=False
        xlApp.Quit
        Set xlBook = Nothing: Set xlApp = Nothing
        AktualisiereCBFExcelVonWebsite_Safe = False
        Exit Function
    End If
    On Error GoTo ErrorHandler
    
    xlBook.Save
    xlBook.Close SaveChanges:=False
    xlApp.Quit
    Set xlBook = Nothing: Set xlApp = Nothing
    
    AktualisiereCBFExcelVonWebsite_Safe = True
    Exit Function
    
ErrorHandler:
    On Error Resume Next
    If Not xlBook Is Nothing Then xlBook.Close SaveChanges:=False
    If Not xlApp Is Nothing Then xlApp.Quit
    AktualisiereCBFExcelVonWebsite_Safe = False
End Function

' ============================================================================
' SYNCHRONISATION MIT ADODB (OHNE Excel COM!)
' ============================================================================
Public Sub SyncLoewensaalEvents_ADODB()
    On Error GoTo ErrorHandler
    
    Dim allEvents() As EventInfo
    Dim eventCount As Integer, newCount As Integer, i As Integer
    Dim heutesDatum As Date
    
    heutesDatum = Date
    
    If Dir(EXCEL_FILE_PATH) = "" Then
        MsgBox "Excel nicht gefunden:" & vbCrLf & EXCEL_FILE_PATH, vbCritical
        Exit Sub
    End If
    
    Debug.Print String(60, "=")
    Debug.Print "=== SYNC v8.1 STRENGE + FUZZY MATCHING ==="
    Debug.Print "Filter: >= " & Format(heutesDatum, "dd.mm.yyyy")
    Debug.Print String(60, "=")
    
    allEvents = LoadEventsFromExcel_ADODB(EXCEL_FILE_PATH, heutesDatum)
    eventCount = UBound(allEvents) - LBound(allEvents) + 1
    
    If eventCount = 0 Or (eventCount = 1 And Len(Trim(allEvents(0).titel)) = 0) Then
        MsgBox "Keine relevanten Events gefunden.", vbInformation
        Exit Sub
    End If
    
    Debug.Print "Gefundene Events: " & eventCount
    
    newCount = 0
    For i = LBound(allEvents) To UBound(allEvents)
        allEvents(i).ExistiertInDB = EventExistsInDatabase(allEvents(i).Datum, allEvents(i).titel, allEvents(i).Objekt)
        If Not allEvents(i).ExistiertInDB Then newCount = newCount + 1
    Next i
    
    Debug.Print "Neue Events: " & newCount
    
    If newCount = 0 Then
        MsgBox "Alle Events bereits vorhanden.", vbInformation
        Exit Sub
    End If
    
    Dim successCount As Integer, errorCount As Integer, successDetails As String
    successCount = 0: errorCount = 0
    
    For i = LBound(allEvents) To UBound(allEvents)
        If Not allEvents(i).ExistiertInDB Then
            Debug.Print "  -> " & allEvents(i).titel & " | " & allEvents(i).Objekt
            
            Dim ergebnis As String
            ergebnis = CreateNewAuftragMitSchichten(allEvents(i))
            
            If Left(ergebnis, 7) = "SUCCESS" Then
                successCount = successCount + 1
                Dim teile() As String: teile = Split(ergebnis, "|")
                If UBound(teile) >= 1 Then
                    Call KorrigiereAuftragBooleans(CLng(teile(1)))
                    successDetails = successDetails & "ID " & teile(1) & ": " & Left(allEvents(i).titel, 35) & vbCrLf
                End If
            Else
                errorCount = errorCount + 1
            End If
        End If
    Next i
    
    Debug.Print "Erfolgreich: " & successCount & " | Fehler: " & errorCount
    
    MsgBox "Sync abgeschlossen!" & vbCrLf & vbCrLf & _
           "Neue Events: " & successCount & vbCrLf & _
           IIf(errorCount > 0, "Fehler: " & errorCount & vbCrLf, "") & vbCrLf & _
           successDetails, IIf(errorCount = 0, vbInformation, vbExclamation), "Ergebnis"
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Fehler: " & Err.description, vbCritical
End Sub

' ============================================================================
' EXCEL LESEN MIT ADODB (SCHNELL, KEIN EXCEL NÖTIG!)
' ============================================================================
Private Function LoadEventsFromExcel_ADODB(filePath As String, minDatum As Date) As EventInfo()
    On Error GoTo ErrorHandler
    
    Dim conn As Object, rs As Object
    Dim allEvents() As EventInfo
    Dim totalCount As Integer
    Dim sheetsToProcess As Variant, sheetName As Variant
    Dim connStr As String, sql As String
    
    Set conn = CreateObject("ADODB.Connection")
    
    connStr = "Provider=Microsoft.ACE.OLEDB.12.0;" & _
              "Data Source=" & filePath & ";" & _
              "Extended Properties=""Excel 12.0 Macro;HDR=YES;IMEX=1"";"
    
    conn.Open connStr
    
    sheetsToProcess = Array("CBF Veranstaltungen 2025-2026")
    
    ReDim allEvents(0 To 999)
    totalCount = 0
    
    For Each sheetName In sheetsToProcess
        On Error Resume Next
        
        sql = "SELECT * FROM [" & sheetName & "$]"
        
        Set rs = CreateObject("ADODB.Recordset")
        rs.Open sql, conn, 3, 1
        
        If Err.Number = 0 Then
            On Error GoTo ErrorHandler
            Debug.Print "  Sheet: " & sheetName
            
            Do While Not rs.EOF
                Dim datumVal As Variant, titelVal As String, ortVal As String, objektVal As String, einlassVal As Variant
                Dim eventDate As Date, einlasszeit As Date
                
                datumVal = rs.fields(0).Value
                titelVal = Trim(Nz(rs.fields(1).Value, ""))
                ortVal = Trim(Nz(rs.fields(2).Value, ""))
                objektVal = Trim(Nz(rs.fields(3).Value, ""))
                einlassVal = rs.fields(4).Value
                
                If Not IsNull(datumVal) And Len(titelVal) > 0 And Len(objektVal) > 0 Then
                    If IsRelevantLocation(objektVal) Then
                        If IsDate(datumVal) Then
                            eventDate = CDate(datumVal)
                        Else
                            eventDate = ParseGermanDateString(CStr(datumVal))
                        End If
                        
                        If eventDate >= minDatum And eventDate <= #12/31/2099# Then
                            If Not IsDuplicateEventInArray(allEvents, totalCount, eventDate, titelVal, objektVal) Then
                                If Len(Trim(ortVal)) = 0 Then
                                    If InStr(UCase(objektVal), "RONHOF") > 0 Or InStr(UCase(objektVal), "FÜRTH") > 0 Then
                                        ortVal = "Fuerth"
                                    Else
                                        ortVal = "Nuernberg"
                                    End If
                                End If
                                
                                If IsDate(einlassVal) Then
                                    einlasszeit = DateSerial(Year(eventDate), Month(eventDate), Day(eventDate)) + _
                                                  TimeSerial(Hour(CDate(einlassVal)), minute(CDate(einlassVal)), 0)
                                Else
                                    einlasszeit = DateSerial(Year(eventDate), Month(eventDate), Day(eventDate)) + TimeSerial(19, 0, 0)
                                End If
                                
                                titelVal = Replace(titelVal, "_x000D_", "")
                                titelVal = Trim(titelVal)
                                
                                allEvents(totalCount).Datum = eventDate
                                allEvents(totalCount).DatumStr = Format(eventDate, "dd.mm.yyyy")
                                allEvents(totalCount).titel = NormalisiereTitel(titelVal)
                                allEvents(totalCount).Ort = ortVal
                                allEvents(totalCount).Objekt = objektVal
                                allEvents(totalCount).VeranstalterID = VERANSTALTER_ID_DEFAULT
                                allEvents(totalCount).ExistiertInDB = False
                                allEvents(totalCount).SheetQuelle = CStr(sheetName)
                                allEvents(totalCount).Treffpunkt = TREFFPUNKT_DEFAULT
                                allEvents(totalCount).einlasszeit = einlasszeit
                                allEvents(totalCount).EinlasszeitStr = Format(einlasszeit, "hh:mm")
                                
                                totalCount = totalCount + 1
                                If totalCount > UBound(allEvents) Then ReDim Preserve allEvents(0 To UBound(allEvents) + 500)
                            End If
                        End If
                    End If
                End If
                
                rs.MoveNext
            Loop
        End If
        
        If Not rs Is Nothing Then
            If rs.State = 1 Then rs.Close
            Set rs = Nothing
        End If
        Err.clear
    Next sheetName
    
    conn.Close
    Set conn = Nothing
    
    If totalCount > 0 Then
        ReDim Preserve allEvents(0 To totalCount - 1)
    Else
        ReDim allEvents(0 To 0)
        allEvents(0).titel = ""
    End If
    
    LoadEventsFromExcel_ADODB = allEvents
    Exit Function
    
ErrorHandler:
    Debug.Print "ADODB-Fehler: " & Err.description
    On Error Resume Next
    If Not rs Is Nothing Then rs.Close
    If Not conn Is Nothing Then conn.Close
    ReDim allEvents(0 To 0)
    allEvents(0).titel = ""
    LoadEventsFromExcel_ADODB = allEvents
End Function

' ============================================================================
' DUPLIKAT IM ARRAY PRÜFEN (für Excel-Import) - MIT STRENGER + FUZZY PRÜFUNG
' ============================================================================
Private Function IsDuplicateEventInArray(events() As EventInfo, Count As Integer, _
                                          eventDate As Date, titel As String, Objekt As String) As Boolean
    Dim i As Integer
    Dim strengePruefung As Boolean
    
    For i = 0 To Count - 1
        ' Gleiches Datum
        If events(i).Datum = eventDate Then
            
            ' STRENGE PRÜFUNG ZUERST
            strengePruefung = IsStrictDuplicate(events(i).titel, titel, events(i).Objekt, Objekt)
            
            If strengePruefung Then
                Debug.Print "  [EXCEL-STRENG-DUPLIKAT] " & titel & " = " & events(i).titel
                IsDuplicateEventInArray = True
                Exit Function
            End If
            
            ' FUZZY MATCHING
            If IsSimilarLocation(events(i).Objekt, Objekt) And _
               IsSimilarTitle(events(i).titel, titel) Then
                Debug.Print "  [EXCEL-FUZZY-DUPLIKAT] " & titel & " ~ " & events(i).titel
                IsDuplicateEventInArray = True
                Exit Function
            End If
        End If
    Next i
    
    IsDuplicateEventInArray = False
End Function

' ============================================================================
' DUPLIKATERKENNUNG IN DATENBANK - MIT STRENGER + FUZZY MATCHING
' ============================================================================
Public Function EventExistsInDatabase(ByVal eventDatum As Date, ByVal eventTitel As String, ByVal eventObjekt As String) As Boolean
    On Error GoTo ErrorHandler
    
    Dim rs As DAO.Recordset, sql As String
    Dim dbTitel As String, dbObjekt As String
    Dim ortMatch As Boolean, titelMatch As Boolean
    Dim strengePruefung As Boolean
    
    ' ALLE Aufträge am gleichen Tag holen (Ort-Filter kommt später fuzzy)
    sql = "SELECT Auftrag, Objekt FROM tbl_VA_Auftragstamm " & _
          "WHERE Dat_VA_Von = #" & DatumFuerSQL(eventDatum) & "#"
    
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    
    Do While Not rs.EOF
        dbTitel = Trim(Nz(rs!Auftrag, ""))
        dbObjekt = Trim(Nz(rs!Objekt, ""))
        
        ' ===== STRENGE PRÜFUNG ZUERST (für eindeutige Duplikate) =====
        strengePruefung = IsStrictDuplicate(dbTitel, eventTitel, dbObjekt, eventObjekt)
        
        If strengePruefung Then
            Debug.Print "  [STRENGE DUPLIKAT-ERKENNUNG]"
            Debug.Print "    DB:  " & dbTitel & " @ " & dbObjekt
            Debug.Print "    NEU: " & eventTitel & " @ " & eventObjekt
            rs.Close
            Set rs = Nothing
            EventExistsInDatabase = True
            Exit Function
        End If
        
        ' ===== FUZZY MATCHING (für ähnliche Duplikate) =====
        ' 1. Ort vergleichen (fuzzy)
        ortMatch = IsSimilarLocation(dbObjekt, eventObjekt)
        
        ' 2. Titel vergleichen (fuzzy)
        titelMatch = IsSimilarTitle(dbTitel, eventTitel)
        
        ' Wenn BEIDES passt = Duplikat
        If ortMatch And titelMatch Then
            Debug.Print "  [FUZZY DUPLIKAT ERKANNT]"
            Debug.Print "    DB:  " & dbTitel & " @ " & dbObjekt
            Debug.Print "    NEU: " & eventTitel & " @ " & eventObjekt
            rs.Close
            Set rs = Nothing
            EventExistsInDatabase = True
            Exit Function
        End If
        
        rs.MoveNext
    Loop
    
    rs.Close
    Set rs = Nothing
    EventExistsInDatabase = False
    Exit Function
    
ErrorHandler:
    On Error Resume Next
    If Not rs Is Nothing Then rs.Close
    EventExistsInDatabase = False
End Function

' ============================================================================
' STRENGE DUPLIKAT-PRÜFUNG (für eindeutige Fälle)
' ============================================================================
' Erkennt: Gleiches Datum + sehr ähnlicher/gleicher Ort + sehr ähnlicher/gleicher Titel
' ============================================================================
Private Function IsStrictDuplicate(ByVal dbTitel As String, ByVal neuTitel As String, _
                                    ByVal dbObjekt As String, ByVal neuObjekt As String) As Boolean
    
    Dim T1 As String, T2 As String
    Dim o1 As String, o2 As String
    Dim core1 As String, core2 As String
    Dim titelSimilarity As Double, ortSimilarity As Double
    
    ' Titel normalisieren
    T1 = NormalizeTitle(dbTitel)
    T2 = NormalizeTitle(neuTitel)
    
    ' Ort normalisieren
    o1 = NormalizeLocation(dbObjekt)
    o2 = NormalizeLocation(neuObjekt)
    
    ' ===== REGEL 1: EXAKT GLEICH (nach Normalisierung) =====
    If StrComp(T1, T2, vbTextCompare) = 0 And StrComp(o1, o2, vbTextCompare) = 0 Then
        IsStrictDuplicate = True
        Exit Function
    End If
    
    ' ===== REGEL 2: GLEICHE KERN-LOCATION + EXAKT GLEICHER TITEL =====
    core1 = GetLocationCore(o1)
    core2 = GetLocationCore(o2)
    
    If Len(core1) > 0 And core1 = core2 Then
        ' Gleiche Location-Kern ? Titel muss exakt gleich sein
        If StrComp(T1, T2, vbTextCompare) = 0 Then
            IsStrictDuplicate = True
            Exit Function
        End If
        
        ' Oder Titel mind. 95% ähnlich
        titelSimilarity = CalculateSimilarity(T1, T2)
        If titelSimilarity >= 0.95 Then
            IsStrictDuplicate = True
            Exit Function
        End If
        
        ' Oder einer enthält den anderen komplett
        If InStr(1, T1, T2, vbTextCompare) > 0 Or InStr(1, T2, T1, vbTextCompare) > 0 Then
            IsStrictDuplicate = True
            Exit Function
        End If
    End If
    
    ' ===== REGEL 3: EXAKTER TITEL + SEHR ÄHNLICHER ORT (>95%) =====
    If StrComp(T1, T2, vbTextCompare) = 0 Then
        ortSimilarity = CalculateSimilarity(o1, o2)
        If ortSimilarity >= 0.95 Then
            IsStrictDuplicate = True
            Exit Function
        End If
        
        ' Oder einer enthält den anderen
        If InStr(1, o1, o2, vbTextCompare) > 0 Or InStr(1, o2, o1, vbTextCompare) > 0 Then
            IsStrictDuplicate = True
            Exit Function
        End If
    End If
    
    ' ===== REGEL 4: BEIDE >95% ÄHNLICH =====
    titelSimilarity = CalculateSimilarity(T1, T2)
    ortSimilarity = CalculateSimilarity(o1, o2)
    
    If titelSimilarity >= 0.95 And ortSimilarity >= 0.95 Then
        IsStrictDuplicate = True
        Exit Function
    End If
    
    ' ===== REGEL 5: SEHR KURZE TITEL (=6 Zeichen) + GLEICHER ORT =====
    ' Bei kurzen Titeln wie "Team", "Loi" etc. muss exakte Übereinstimmung gegeben sein
    If Len(T1) <= 6 Or Len(T2) <= 6 Then
        If StrComp(T1, T2, vbTextCompare) = 0 Then
            ' Gleicher Ort?
            If StrComp(o1, o2, vbTextCompare) = 0 Then
                IsStrictDuplicate = True
                Exit Function
            End If
            
            ' Oder gleicher Kern?
            If Len(core1) > 0 And core1 = core2 Then
                IsStrictDuplicate = True
                Exit Function
            End If
        End If
    End If
    
    IsStrictDuplicate = False
End Function

' ============================================================================
' ORT/OBJEKT VERGLEICH (FUZZY)
' ============================================================================
Private Function IsSimilarLocation(ByVal ort1 As String, ByVal ort2 As String) As Boolean
    Dim o1 As String, o2 As String
    
    o1 = NormalizeLocation(ort1)
    o2 = NormalizeLocation(ort2)
    
    ' Leer = kein Match
    If Len(o1) = 0 Or Len(o2) = 0 Then
        IsSimilarLocation = False
        Exit Function
    End If
    
    ' 1. Exakt gleich nach Normalisierung
    If StrComp(o1, o2, vbTextCompare) = 0 Then
        IsSimilarLocation = True
        Exit Function
    End If
    
    ' 2. Einer enthält den anderen
    If InStr(o1, o2) > 0 Or InStr(o2, o1) > 0 Then
        IsSimilarLocation = True
        Exit Function
    End If
    
    ' 3. Kern-Location identisch (z.B. beide "RONHOF" oder beide "LOEWENSAAL")
    Dim core1 As String, core2 As String
    core1 = GetLocationCore(o1)
    core2 = GetLocationCore(o2)
    
    If Len(core1) > 0 And core1 = core2 Then
        IsSimilarLocation = True
        Exit Function
    End If
    
    ' 4. Ähnlichkeit > 70%
    If CalculateSimilarity(o1, o2) >= 0.7 Then
        IsSimilarLocation = True
        Exit Function
    End If
    
    IsSimilarLocation = False
End Function

' ============================================================================
' LOCATION NORMALISIEREN
' ============================================================================
Private Function NormalizeLocation(ByVal loc As String) As String
    Dim result As String
    result = UCase(Trim(loc))
    
    ' Umlaute normalisieren
    result = Replace(result, "Ö", "OE")
    result = Replace(result, "Ä", "AE")
    result = Replace(result, "Ü", "UE")
    result = Replace(result, "ß", "SS")
    result = Replace(result, "ö", "OE")
    result = Replace(result, "ä", "AE")
    result = Replace(result, "ü", "UE")
    
    ' Varianten vereinheitlichen
    result = Replace(result, "LÖWENSAAL", "LOEWENSAAL")
    result = Replace(result, "NUERNBERG", "NUERNBERG")
    result = Replace(result, "NÜRNBERG", "NUERNBERG")
    result = Replace(result, "FUERTH", "FUERTH")
    result = Replace(result, "FÜRTH", "FUERTH")
    
    ' Zusätze entfernen
    result = Replace(result, "ARENA", "")
    result = Replace(result, "STADION", "")
    result = Replace(result, "HALLE", "")
    result = Replace(result, "PARK", "")
    
    ' Leerzeichen bereinigen
    Do While InStr(result, "  ") > 0
        result = Replace(result, "  ", " ")
    Loop
    
    NormalizeLocation = Trim(result)
End Function

' ============================================================================
' KERN-LOCATION EXTRAHIEREN (Schlüsselwort)
' ============================================================================
Private Function GetLocationCore(ByVal loc As String) As String
    Dim U As String
    U = UCase(Trim(loc))
    
    ' Bekannte Locations auf Kern reduzieren
    If InStr(U, "LOEWENSAAL") > 0 Or InStr(U, "LÖWENSAAL") > 0 Then
        GetLocationCore = "LOEWENSAAL": Exit Function
    End If
    If InStr(U, "RONHOF") > 0 Then
        GetLocationCore = "RONHOF": Exit Function
    End If
    If InStr(U, "MORLOCK") > 0 Then
        GetLocationCore = "MORLOCK": Exit Function
    End If
    If InStr(U, "PSD BANK") > 0 Or InStr(U, "PSDBANK") > 0 Then
        GetLocationCore = "PSDBANK": Exit Function
    End If
    If InStr(U, "MEISTERSINGERHALLE") > 0 Or InStr(U, "MEISTERSINGER") > 0 Then
        GetLocationCore = "MEISTERSINGERHALLE": Exit Function
    End If
    If InStr(U, "MARKGRAFENSAAL") > 0 Or InStr(U, "MARKGRAFEN") > 0 Then
        GetLocationCore = "MARKGRAFENSAAL": Exit Function
    End If
    If InStr(U, "SERENADENHOF") > 0 Or InStr(U, "SERENADEN") > 0 Then
        GetLocationCore = "SERENADENHOF": Exit Function
    End If
    If InStr(U, "STADTHALLE") > 0 Then
        GetLocationCore = "STADTHALLE": Exit Function
    End If
    If InStr(U, "LADES") > 0 Or InStr(U, "HEINRICH-LADES") > 0 Then
        GetLocationCore = "LADESHALLE": Exit Function
    End If
    If InStr(U, "KIA METROPOL") > 0 Or InStr(U, "METROPOL") > 0 Then
        GetLocationCore = "KIAMETROPOL": Exit Function
    End If
    If InStr(U, "DONAU") > 0 Then
        GetLocationCore = "DONAUARENA": Exit Function
    End If
    If InStr(U, "STADIONPARK") > 0 Then
        GetLocationCore = "STADIONPARK": Exit Function
    End If
    
    GetLocationCore = ""
End Function

' ============================================================================
' TITEL VERGLEICH (FUZZY)
' ============================================================================
Private Function IsSimilarTitle(ByVal titel1 As String, ByVal titel2 As String) As Boolean
    Dim T1 As String, T2 As String
    Dim similarity As Double
    
    T1 = NormalizeTitle(titel1)
    T2 = NormalizeTitle(titel2)
    
    ' Leer = kein Match
    If Len(T1) < 3 Or Len(T2) < 3 Then
        IsSimilarTitle = False
        Exit Function
    End If
    
    ' 1. Exakt gleich
    If StrComp(T1, T2, vbTextCompare) = 0 Then
        IsSimilarTitle = True
        Exit Function
    End If
    
    ' 2. Einer enthält den anderen (mind. 80% Länge)
    If Len(T1) >= Len(T2) * 0.8 Or Len(T2) >= Len(T1) * 0.8 Then
        If InStr(T1, T2) > 0 Or InStr(T2, T1) > 0 Then
            IsSimilarTitle = True
            Exit Function
        End If
    End If
    
    ' 3. Sport-Event: Gegner vergleichen
    If IsSportEvent(T1) And IsSportEvent(T2) Then
        If CompareSportEvents(T1, T2) Then
            IsSimilarTitle = True
            Exit Function
        End If
    End If
    
    ' 4. Gemeinsame Wörter (mind. 60% der kürzeren Version)
    Dim commonWords As Integer, minWords As Integer
    commonWords = CountCommonSignificantWords(T1, T2)
    minWords = MinValue(CountWords(T1), CountWords(T2))
    
    If minWords > 0 And commonWords >= minWords * 0.6 Then
        IsSimilarTitle = True
        Exit Function
    End If
    
    ' 5. String-Ähnlichkeit > 65%
    similarity = CalculateSimilarity(T1, T2)
    If similarity >= 0.65 Then
        IsSimilarTitle = True
        Exit Function
    End If
    
    IsSimilarTitle = False
End Function

' ============================================================================
' TITEL NORMALISIEREN
' ============================================================================
Private Function NormalizeTitle(ByVal titel As String) As String
    Dim result As String
    result = UCase(Trim(titel))
    
    ' Steuerzeichen entfernen
    result = Replace(result, "_x000D_", "")
    result = Replace(result, vbCr, "")
    result = Replace(result, vbLf, "")
    
    ' Umlaute
    result = Replace(result, "Ö", "OE")
    result = Replace(result, "Ä", "AE")
    result = Replace(result, "Ü", "UE")
    result = Replace(result, "ß", "SS")
    result = Replace(result, "ö", "OE")
    result = Replace(result, "ä", "AE")
    result = Replace(result, "ü", "UE")
    
    ' Sonderzeichen
    result = Replace(result, ".", " ")
    result = Replace(result, ",", " ")
    result = Replace(result, ":", " ")
    result = Replace(result, ";", " ")
    result = Replace(result, "!", "")
    result = Replace(result, "?", "")
    result = Replace(result, "'", "")
    result = Replace(result, """", "")
    
    ' Mehrfache Leerzeichen
    Do While InStr(result, "  ") > 0
        result = Replace(result, "  ", " ")
    Loop
    
    NormalizeTitle = Trim(result)
End Function

' ============================================================================
' SPORT-EVENT ERKENNUNG
' ============================================================================
Private Function IsSportEvent(ByVal titel As String) As Boolean
    Dim U As String
    U = UCase(titel)
    
    ' Typische Merkmale: " - " und Vereinsname
    If InStr(U, " - ") > 0 Then
        ' Enthält Vereinsnamen?
        If InStr(U, "GREUTHER") > 0 Or InStr(U, "FUERTH") > 0 Or InStr(U, "FURTH") > 0 Or _
           InStr(U, "NUERNBERG") > 0 Or InStr(U, "NURNBERG") > 0 Or _
           InStr(U, "CLUB") > 0 Or InStr(U, "BAYERN") > 0 Or _
           InStr(U, "DORTMUND") > 0 Or InStr(U, "SCHALKE") > 0 Or _
           InStr(U, "FORTUNA") > 0 Or InStr(U, "HERTHA") > 0 Or _
           InStr(U, "WERDER") > 0 Or InStr(U, "KOELN") > 0 Or InStr(U, "COLOGNE") > 0 Or _
           InStr(U, "FRANKFURT") > 0 Or InStr(U, "HOFFENHEIM") > 0 Or _
           InStr(U, "LEVERKUSEN") > 0 Or InStr(U, "GLADBACH") > 0 Or _
           InStr(U, "WOLFSBURG") > 0 Or InStr(U, "FREIBURG") > 0 Or _
           InStr(U, "MAINZ") > 0 Or InStr(U, "AUGSBURG") > 0 Or _
           InStr(U, "BOCHUM") > 0 Or InStr(U, "HEIDENHEIM") > 0 Or _
           InStr(U, "DARMSTADT") > 0 Or InStr(U, "ELVERSBERG") > 0 Or _
           InStr(U, "KAISERSLAUTERN") > 0 Or InStr(U, "HANNOVER") > 0 Or _
           InStr(U, "BRAUNSCHWEIG") > 0 Or InStr(U, "PADERBORN") > 0 Or _
           InStr(U, "REGENSBURG") > 0 Or InStr(U, "MAGDEBURG") > 0 Or _
           InStr(U, "DUESSELDORF") > 0 Or InStr(U, "DUSSELDORF") > 0 Or _
           InStr(U, "FC ") > 0 Or InStr(U, "1.FC") > 0 Or InStr(U, "1. FC") > 0 Or _
           InStr(U, "SPVGG") > 0 Or InStr(U, "SV ") > 0 Or _
           InStr(U, "VFB") > 0 Or InStr(U, "VFL") > 0 Or _
           InStr(U, "TSG") > 0 Or InStr(U, "RB ") > 0 Or _
           InStr(U, "UNION") > 0 Or InStr(U, "EINTRACHT") > 0 Then
            IsSportEvent = True
            Exit Function
        End If
    End If
    
    IsSportEvent = False
End Function

' ============================================================================
' SPORT-EVENTS VERGLEICHEN
' ============================================================================
Private Function CompareSportEvents(ByVal T1 As String, ByVal T2 As String) As Boolean
    Dim heim1 As String, gast1 As String
    Dim heim2 As String, gast2 As String
    
    ' Teams extrahieren
    Call ExtractTeams(T1, heim1, gast1)
    Call ExtractTeams(T2, heim2, gast2)
    
    ' Beide haben Teams?
    If Len(gast1) < 3 Or Len(gast2) < 3 Then
        CompareSportEvents = False
        Exit Function
    End If
    
    ' Teams normalisieren
    heim1 = NormalizeTeamName(heim1)
    heim2 = NormalizeTeamName(heim2)
    gast1 = NormalizeTeamName(gast1)
    gast2 = NormalizeTeamName(gast2)
    
    ' Gegner identisch oder sehr ähnlich?
    If InStr(gast1, gast2) > 0 Or InStr(gast2, gast1) > 0 Then
        ' Und Heimteam auch ähnlich?
        If InStr(heim1, heim2) > 0 Or InStr(heim2, heim1) > 0 Then
            CompareSportEvents = True
            Exit Function
        End If
    End If
    
    ' Alternative: Beide Gegner haben gemeinsamen Kern
    If Len(gast1) >= 4 And Len(gast2) >= 4 Then
        If Left(gast1, 4) = Left(gast2, 4) Then
            If Len(heim1) >= 4 And Len(heim2) >= 4 Then
                If Left(heim1, 4) = Left(heim2, 4) Then
                    CompareSportEvents = True
                    Exit Function
                End If
            End If
        End If
    End If
    
    CompareSportEvents = False
End Function

' ============================================================================
' TEAMS EXTRAHIEREN
' ============================================================================
Private Sub ExtractTeams(ByVal titel As String, ByRef heim As String, ByRef gast As String)
    Dim pos As Integer
    
    pos = InStr(titel, " - ")
    If pos > 0 Then
        heim = Trim(Left(titel, pos - 1))
        gast = Trim(Mid(titel, pos + 3))
    Else
        heim = titel
        gast = ""
    End If
End Sub

' ============================================================================
' TEAM-NAME NORMALISIEREN
' ============================================================================
Private Function NormalizeTeamName(ByVal team As String) As String
    Dim result As String
    result = UCase(Trim(team))
    
    ' Präfixe entfernen
    result = Replace(result, "SPVGG ", "")
    result = Replace(result, "SPVGG. ", "")
    result = Replace(result, "1. FC ", "")
    result = Replace(result, "1.FC ", "")
    result = Replace(result, "FC ", "")
    result = Replace(result, "SV ", "")
    result = Replace(result, "TSV ", "")
    result = Replace(result, "TSG ", "")
    result = Replace(result, "VFB ", "")
    result = Replace(result, "VFL ", "")
    result = Replace(result, "FSV ", "")
    result = Replace(result, "SC ", "")
    result = Replace(result, "BSC ", "")
    result = Replace(result, "RB ", "")
    result = Replace(result, "BORUSSIA ", "")
    result = Replace(result, "EINTRACHT ", "")
    result = Replace(result, "FORTUNA ", "")
    
    NormalizeTeamName = Trim(result)
End Function

' ============================================================================
' GEMEINSAME SIGNIFIKANTE WÖRTER ZÄHLEN
' ============================================================================
Private Function CountCommonSignificantWords(ByVal T1 As String, ByVal T2 As String) As Integer
    Dim words1() As String, words2() As String
    Dim W1 As Variant, W2 As Variant
    Dim commonCount As Integer
    
    words1 = Split(T1, " ")
    words2 = Split(T2, " ")
    commonCount = 0
    
    For Each W1 In words1
        If IsSignificantWord(CStr(W1)) Then
            For Each W2 In words2
                If StrComp(Trim(CStr(W1)), Trim(CStr(W2)), vbTextCompare) = 0 Then
                    commonCount = commonCount + 1
                    Exit For
                End If
            Next W2
        End If
    Next W1
    
    CountCommonSignificantWords = commonCount
End Function

' ============================================================================
' SIGNIFIKANTES WORT? (nicht nur Füllwörter)
' ============================================================================
Private Function IsSignificantWord(ByVal word As String) As Boolean
    Dim w As String
    w = UCase(Trim(word))
    
    ' Zu kurz
    If Len(w) < 3 Then
        IsSignificantWord = False
        Exit Function
    End If
    
    ' Füllwörter ignorieren
    Select Case w
        Case "UND", "AND", "THE", "DER", "DIE", "DAS", "MIT", "VON", "ZU", "ZUM", "ZUR", _
             "AUS", "BEI", "FUER", "FUR", "FOR", "AUF", "IN", "IM", "AM", "AN", "AB", _
             "BIS", "NACH", "VOR", "UEBER", "UNTER", "DURCH", "GEGEN", "OHNE", _
             "FEAT", "FT", "VS", "LIVE", "TOUR", "SHOW", "KONZERT", "CONCERT"
            IsSignificantWord = False
        Case Else
            IsSignificantWord = True
    End Select
End Function

' ============================================================================
' WÖRTER ZÄHLEN
' ============================================================================
Private Function CountWords(ByVal Text As String) As Integer
    Dim words() As String
    Dim cnt As Integer, i As Integer
    
    If Len(Trim(Text)) = 0 Then
        CountWords = 0
        Exit Function
    End If
    
    words = Split(Trim(Text), " ")
    cnt = 0
    
    For i = LBound(words) To UBound(words)
        If Len(Trim(words(i))) > 0 Then cnt = cnt + 1
    Next i
    
    CountWords = cnt
End Function

' ============================================================================
' ÄHNLICHKEIT BERECHNEN (vereinfacht)
' ============================================================================
Private Function CalculateSimilarity(ByVal s1 As String, ByVal s2 As String) As Double
    Dim longer As String, shorter As String
    Dim longerLen As Integer
    
    If Len(s1) >= Len(s2) Then
        longer = s1: shorter = s2
    Else
        longer = s2: shorter = s1
    End If
    
    longerLen = Len(longer)
    If longerLen = 0 Then
        CalculateSimilarity = 1#
        Exit Function
    End If
    
    ' Vereinfachte Ähnlichkeit: Anteil gemeinsamer Zeichen
    Dim matches As Integer, i As Integer
    matches = 0
    
    For i = 1 To Len(shorter)
        If InStr(longer, Mid(shorter, i, 1)) > 0 Then
            matches = matches + 1
        End If
    Next i
    
    CalculateSimilarity = CDbl(matches) / CDbl(longerLen)
End Function

' ============================================================================
' MINIMUM (ohne Excel-Referenz)
' ============================================================================
Private Function MinValue(ByVal a As Integer, ByVal b As Integer) As Integer
    If a <= b Then MinValue = a Else MinValue = b
End Function

' ============================================================================
' HILFSFUNKTIONEN
' ============================================================================
Private Function ParseGermanDateString(ByVal dateStr As String) As Date
    On Error GoTo ErrorHandler
    Dim parts() As String, d As Integer, m As Integer, y As Integer
    dateStr = Trim(dateStr)
    If InStr(dateStr, ".") > 0 Then
        parts = Split(dateStr, ".")
        If UBound(parts) >= 2 Then
            d = CInt(Trim(parts(0))): m = CInt(Trim(parts(1))): y = CInt(Trim(parts(2)))
            If y >= 2000 And y <= 2100 And m >= 1 And m <= 12 And d >= 1 And d <= 31 Then
                ParseGermanDateString = DateSerial(y, m, d): Exit Function
            End If
        End If
    End If
ErrorHandler:
    On Error Resume Next
    ParseGermanDateString = CDate(dateStr)
    If Err.Number <> 0 Then ParseGermanDateString = #1/1/2000#
End Function

Private Function DatumFuerSQL(ByVal Datum As Date) As String
    DatumFuerSQL = Month(Datum) & "/" & Day(Datum) & "/" & Year(Datum)
End Function

Private Function DatumZeitFuerSQL(ByVal datumZeit As Date) As String
    DatumZeitFuerSQL = Month(datumZeit) & "/" & Day(datumZeit) & "/" & Year(datumZeit) & " " & Format(datumZeit, "hh:nn:ss")
End Function

Private Function NormalisiereTitel(ByVal titel As String) As String
    If titel = UCase$(titel) Then NormalisiereTitel = ToTitleCase(titel) Else NormalisiereTitel = titel
End Function

Private Sub ApplyLocationOverrides(ByVal objektName As String, ByRef outVeranstalterID As Long, ByRef outDienstkleidung As String, ByRef outHatOverride As Boolean)
    Dim U As String: U = UCase$(Trim$(objektName)): outHatOverride = False
    If InStr(U, "MAX-MORLOCK") > 0 Or InStr(U, "MORLOCK") > 0 Then
        outVeranstalterID = VERANSTALTER_ID_MORLOCK: outDienstkleidung = DIENSTKLEIDUNG_SPEZIAL: outHatOverride = True
    ElseIf InStr(U, "RONHOF") > 0 Then
        outVeranstalterID = VERANSTALTER_ID_RONHOF: outDienstkleidung = DIENSTKLEIDUNG_SPEZIAL: outHatOverride = True
    End If
End Sub

Private Function CreateNewAuftragMitSchichten(evt As EventInfo) As String
    On Error GoTo ErrorHandler
    Dim ortName As String, ergebnis As String
    ortName = evt.Ort: If Len(Trim(ortName)) = 0 Then ortName = "Nuernberg"
    
    ergebnis = AuftragErstellen(auftragsName:=evt.titel, objektName:=evt.Objekt, ortName:=ortName, _
        DatumVon:=evt.Datum, DatumBis:=evt.Datum, auftraggeber:="", Treffpunkt:=evt.Treffpunkt, _
        schichten:="", statusId:=1, Ersteller:="Excel-Import")
    
    If Left(ergebnis, 7) = "SUCCESS" Then
        Dim teile() As String: teile = Split(ergebnis, "|")
        If UBound(teile) >= 1 Then
            Dim auftragsID As Long: auftragsID = CLng(teile(1))
            Dim zielVeranstalterID As Long, zielDienstkleidung As String, hatOverride As Boolean
            zielVeranstalterID = VERANSTALTER_ID_DEFAULT: zielDienstkleidung = DIENSTKLEIDUNG_DEFAULT
            Call ApplyLocationOverrides(evt.Objekt, zielVeranstalterID, zielDienstkleidung, hatOverride)
            
            On Error Resume Next
            CurrentDb.Execute "UPDATE tbl_VA_Auftragstamm SET Veranstalter_ID = " & zielVeranstalterID & _
                ", Dienstkleidung = '" & Replace(zielDienstkleidung, "'", "''") & "' WHERE ID = " & auftragsID, dbFailOnError
            On Error GoTo ErrorHandler
            
            Dim vaDatumID As Long: vaDatumID = HoleVADatumID(auftragsID, evt.Datum)
            If vaDatumID > 0 Then
                Dim anzahlSchichten As Integer
                anzahlSchichten = ErstelleSchichtenFuerLocation(auftragsID, vaDatumID, evt.Datum, evt.Objekt, evt.einlasszeit)
                If anzahlSchichten > 0 Then Call AktualisiereVAAnzTage(vaDatumID, anzahlSchichten)
            End If
        End If
    End If
    CreateNewAuftragMitSchichten = ergebnis
    Exit Function
ErrorHandler:
    CreateNewAuftragMitSchichten = "FEHLER|" & Err.description
End Function

Private Sub AktualisiereVAAnzTage(ByVal vaDatumID As Long, ByVal anzahlMA As Integer)
    On Error Resume Next
    CurrentDb.Execute "UPDATE tbl_VA_AnzTage SET TVA_Soll = " & anzahlMA & ", TVA_Ist = 0 WHERE ID = " & vaDatumID
End Sub

Private Function HoleVADatumID(ByVal auftragsID As Long, ByVal eventDatum As Date) As Long
    On Error Resume Next
    Dim rs As DAO.Recordset
    Set rs = CurrentDb.OpenRecordset("SELECT ID FROM tbl_VA_AnzTage WHERE VA_ID = " & auftragsID & " AND VADatum = #" & DatumFuerSQL(eventDatum) & "#", dbOpenSnapshot)
    If Not rs.EOF Then HoleVADatumID = rs.fields("ID").Value Else HoleVADatumID = 0
    rs.Close: Set rs = Nothing
End Function

' ============================================================================
' SCHICHTERSTELLUNG
' ============================================================================
Private Function ErstelleSchichtenFuerLocation(ByVal auftragsID As Long, ByVal vaDatumID As Long, ByVal eventDatum As Date, ByVal Location As String, ByVal einlasszeit As Date) As Integer
    On Error GoTo ErrorHandler
    Dim schichten() As SchichtInfo, locationUpper As String, schichtCount As Integer, gesamtAnzahlMA As Integer, i As Integer
    Dim StartZeit As Date, endzeit As Date, istStadion As Boolean
    locationUpper = UCase(Trim(Location)): gesamtAnzahlMA = 0: istStadion = False
    
    If InStr(locationUpper, "LÖWENSAAL") > 0 Or InStr(locationUpper, "LOEWENSAAL") > 0 Then
        ReDim schichten(0 To 2)
        schichten(0).anzahlMA = 1: schichten(0).MinutenVorEinlass = 90
        schichten(1).anzahlMA = 1: schichten(1).MinutenVorEinlass = 60
        schichten(2).anzahlMA = 11: schichten(2).MinutenVorEinlass = 30
        schichtCount = 3: gesamtAnzahlMA = 13
    ElseIf InStr(locationUpper, "MEISTERSINGERHALLE") > 0 Then
        ReDim schichten(0 To 0): schichten(0).anzahlMA = 2: schichten(0).MinutenVorEinlass = 30
        schichtCount = 1: gesamtAnzahlMA = 2
    ElseIf InStr(locationUpper, "MARKGRAFENSAAL") > 0 Then
        ReDim schichten(0 To 0): schichten(0).anzahlMA = 2: schichten(0).MinutenVorEinlass = 30
        schichtCount = 1: gesamtAnzahlMA = 2
    ElseIf InStr(locationUpper, "SERENADENHOF") > 0 Then
        ReDim schichten(0 To 0): schichten(0).anzahlMA = 2: schichten(0).MinutenVorEinlass = 30
        schichtCount = 1: gesamtAnzahlMA = 2
    ElseIf InStr(locationUpper, "STADTHALLE") > 0 Then
        ReDim schichten(0 To 2)
        schichten(0).anzahlMA = 1: schichten(0).MinutenVorEinlass = 480
        schichten(1).anzahlMA = 1: schichten(1).MinutenVorEinlass = 60
        schichten(2).anzahlMA = 15: schichten(2).MinutenVorEinlass = 30
        schichtCount = 3: gesamtAnzahlMA = 17
    ElseIf InStr(locationUpper, "PSD Bank Arena Nürnberg") > 0 Or InStr(locationUpper, "PSDBANK") > 0 Then
        ReDim schichten(0 To 4)
        schichten(0).anzahlMA = 6: schichten(0).FixeStartzeit = "08:00": schichten(0).IstFixeStartzeit = True
        schichten(1).anzahlMA = 5: schichten(1).FixeStartzeit = "12:00": schichten(1).IstFixeStartzeit = True
        schichten(2).anzahlMA = 4: schichten(2).FixeStartzeit = "16:00": schichten(2).IstFixeStartzeit = True
        schichten(3).anzahlMA = 5: schichten(3).MinutenVorEinlass = 45: schichten(3).IstFixeEndzeit = True: schichten(3).FixeEndzeitStunden = 1: schichten(3).FixeEndzeitMinuten = 30
        schichten(4).anzahlMA = 70: schichten(4).MinutenVorEinlass = 45: schichten(4).IstFixeEndzeit = True: schichten(4).FixeEndzeitStunden = 23: schichten(4).FixeEndzeitMinuten = 30
        schichtCount = 5: gesamtAnzahlMA = 90
    ElseIf InStr(locationUpper, "MAX-MORLOCK") > 0 Or InStr(locationUpper, "MORLOCK") > 0 Then
        ReDim schichten(0 To 1)
        schichten(0).anzahlMA = 2: schichten(0).MinutenVorEinlass = 165
        schichten(1).anzahlMA = 60: schichten(1).MinutenVorEinlass = 135
        schichtCount = 2: gesamtAnzahlMA = 62: istStadion = True
        
    ElseIf InStr(locationUpper, "RONHOF") > 0 Then
        ReDim schichten(0 To 1)
        schichten(0).anzahlMA = 2: schichten(0).MinutenVorEinlass = 210
        schichten(1).anzahlMA = 40: schichten(1).MinutenVorEinlass = 150
        schichtCount = 2: gesamtAnzahlMA = 42: istStadion = True
        
    ElseIf InStr(locationUpper, "KIA Metropol Arena") > 0 Then
        ReDim schichten(0 To 2)
         schichten(0).anzahlMA = 2: schichten(0).FixeStartzeit = "08:00": schichten(0).IstFixeStartzeit = True
         schichten(1).anzahlMA = 2: schichten(1).FixeStartzeit = "12:00": schichten(1).IstFixeStartzeit = True
        schichten(3).anzahlMA = 40: schichten(2).MinutenVorEinlass = 45: schichten(2).IstFixeEndzeit = True: schichten(3).FixeEndzeitStunden = 1: schichten(3).FixeEndzeitMinuten = 30
        schichtCount = 3: gesamtAnzahlMA = 44
    Else
        ReDim schichten(0 To 0): schichten(0).anzahlMA = 2: schichten(0).MinutenVorEinlass = 30
        schichtCount = 1: gesamtAnzahlMA = 2
    End If
    
    For i = 0 To schichtCount - 1
        If schichten(i).IstFixeStartzeit Then
            Dim teileStart() As String: teileStart = Split(schichten(i).FixeStartzeit, ":")
            StartZeit = DateSerial(Year(eventDatum), Month(eventDatum), Day(eventDatum)) + TimeSerial(CInt(teileStart(0)), CInt(teileStart(1)), 0)
        Else
            StartZeit = DateAdd("n", -schichten(i).MinutenVorEinlass, einlasszeit)
        End If
        If schichten(i).IstFixeEndzeit Then
            endzeit = DateSerial(Year(eventDatum), Month(eventDatum), Day(eventDatum)) + TimeSerial(schichten(i).FixeEndzeitStunden, schichten(i).FixeEndzeitMinuten, 0)
            If schichten(i).FixeEndzeitStunden < 6 Then endzeit = DateAdd("d", 1, endzeit)
        ElseIf schichten(i).IstFixeStartzeit Then
            endzeit = einlasszeit
        Else
            If istStadion Then endzeit = DateAdd("n", 150, einlasszeit) Else endzeit = DateSerial(Year(eventDatum), Month(eventDatum), Day(eventDatum)) + TimeSerial(23, 30, 0)
        End If
        Call SchichtEintragErstellen(auftragsID, vaDatumID, eventDatum, StartZeit, endzeit, schichten(i).anzahlMA)
    Next i
    ErstelleSchichtenFuerLocation = gesamtAnzahlMA
    Exit Function
ErrorHandler:
    ErstelleSchichtenFuerLocation = 0
End Function

Private Sub SchichtEintragErstellen(ByVal auftragsID As Long, ByVal vaDatumID As Long, ByVal eventDatum As Date, ByVal StartZeit As Date, ByVal endzeit As Date, ByVal maAnzahl As Integer)
    On Error Resume Next
    CurrentDb.Execute "INSERT INTO tbl_VA_Start (VA_ID, VADatum_ID, VADatum, MA_Anzahl, VA_Start, VA_Ende, MVA_Start, MVA_Ende) VALUES (" & _
        auftragsID & ", " & vaDatumID & ", #" & DatumFuerSQL(eventDatum) & "#, " & maAnzahl & ", #" & Format(StartZeit, "hh:nn:ss") & "#, #" & _
        Format(endzeit, "hh:nn:ss") & "#, #" & DatumZeitFuerSQL(StartZeit) & "#, #" & DatumZeitFuerSQL(endzeit) & "#)"
End Sub

Private Function IsRelevantLocation(Objekt As String) As Boolean
    If Len(Trim(Objekt)) = 0 Then IsRelevantLocation = False: Exit Function
    Dim locations As Variant, loc As Variant, objektUpper As String
    locations = Split(RELEVANT_LOCATIONS, "|"): objektUpper = UCase(Trim(Objekt))
    For Each loc In locations
        If Len(Trim(CStr(loc))) > 0 Then
            If InStr(1, objektUpper, UCase(Trim(CStr(loc))), vbTextCompare) > 0 Then IsRelevantLocation = True: Exit Function
        End If
    Next loc
    IsRelevantLocation = False
End Function

Public Sub KorrigiereAuftragBooleans(ByVal auftragsID As Long)
    On Error Resume Next
    Dim rs As DAO.Recordset, i As Integer, hatUpdate As Boolean
    Set rs = CurrentDb.OpenRecordset("SELECT * FROM tbl_VA_Auftragstamm WHERE ID = " & auftragsID, dbOpenDynaset)
    If Not rs.EOF Then
        hatUpdate = False
        For i = 0 To rs.fields.Count - 1
            If rs.fields(i).Type = dbBoolean Then
                If Not hatUpdate Then rs.Edit: hatUpdate = True
                rs.fields(i).Value = True
            End If
        Next i
        If hatUpdate Then rs.update
    End If
    rs.Close
End Sub

Public Function ToTitleCase(inputText As String) As String
    If Len(Trim(inputText)) = 0 Then ToTitleCase = "": Exit Function
    Dim words() As String, i As Integer, result As String
    words = Split(LCase(Trim(inputText)), " "): result = ""
    For i = LBound(words) To UBound(words)
        If Len(words(i)) > 0 Then words(i) = UCase(Left(words(i), 1)) & Mid(words(i), 2): result = result & IIf(Len(result) > 0, " ", "") & words(i)
    Next i
    ToTitleCase = result
End Function

Private Function Nz(Value As Variant, Optional valueIfNull As Variant = "") As Variant
    Nz = IIf(IsNull(Value) Or IsEmpty(Value), valueIfNull, Value)
End Function
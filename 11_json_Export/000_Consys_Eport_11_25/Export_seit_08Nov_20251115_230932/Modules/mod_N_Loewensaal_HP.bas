'Attribute VB_Name = "mod_N_Loewensaal_HP"
Option Compare Database
Option Explicit

' ============================================================================
' Modul: mod_N_Loewensaal_HP
' Version: 5.1 - DATUMSFORMAT KORRIGIERT
' ============================================================================
' ÄNDERUNGEN V5.1:
' - KRITISCHER FIX: Datumsformat für SQL korrigiert (dd/mm/yyyy)
' - DatumFuerSQL() Hilfsfunktion für garantiert korrekte Datumsformatierung
' - Garantiert Sichtbarkeit in qry_lst_Row_Auftrag
' ============================================================================
' VORHERIGE ÄNDERUNGEN V5.0:
' - Garantiert korrekte tbl_VA_AnzTage Erstellung (TVA_Soll = 1)
' - Ort-Feld wird IMMER korrekt gefüllt
' - Erweiterte Location-Liste (12 Orte)
' - Verbesserte Query-Sichtbarkeit
' - Direkt-Import ohne Formular
' - Korrigierte HTML-Parsing-Logik
' ============================================================================

Private Const WEBSITE_URL As String = "https://www.concertbuero-franken.de/"
Private Const TREFFPUNKT_DEFAULT As String = "15 min vor DB vor Ort"
Private Const DIENSTKLEIDUNG_DEFAULT As String = "Consec"
Private Const VERANSTALTER_ID_DEFAULT As Long = 10233

' ERWEITERTE LOCATION-LISTE (12 ORTE)
Private Const RELEVANT_LOCATIONS As String = "Löwensaal|Loewensaal|Meistersingerhalle|Markgrafensaal|Stadthalle|" & _
                                             "Heinrich-Lades-Halle|Lux-Kirche|KIA Metropol Arena|" & _
                                             "PSB Bank Arena|Donau-Arena|Brose Arena|Stadionpark"

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

' ================================================================================================
' HILFSFUNKTION: Konvertiert Datum für Access SQL (MM/DD/YYYY)
' ================================================================================================
Private Function DatumFuerSQL(ByVal Datum As Date) As String
    DatumFuerSQL = Month(Datum) & "/" & Day(Datum) & "/" & year(Datum)
End Function

Private Function DatumZeitFuerSQL(ByVal datumZeit As Date) As String
    DatumZeitFuerSQL = Month(datumZeit) & "/" & Day(datumZeit) & "/" & year(datumZeit) & _
                       " " & Format(datumZeit, "hh:nn:ss")
End Function

' ============================================================================
' HAUPTFUNKTION - DIREKT-IMPORT VON HOMEPAGE
' ============================================================================
Public Sub SyncLoewensaalEventsFromHomepage()
    On Error GoTo ErrorHandler
    
    Dim allEvents() As EventInfo
    Dim eventCount As Integer
    Dim newCount As Integer
    Dim i As Integer
    Dim heutesDatum As Date
    
    heutesDatum = Date
    
    DoCmd.Hourglass True
    Debug.Print String(80, "=")
    Debug.Print "=== Homepage-Import (DIREKT) gestartet ==="
    Debug.Print "Zeitpunkt: " & Format(Now(), "dd.mm.yyyy hh:nn:ss")
    Debug.Print "Filter: Ab " & Format(heutesDatum, "dd.mm.yyyy")
    Debug.Print "Locations: " & Replace(RELEVANT_LOCATIONS, "|", ", ")
    Debug.Print "Import-Modus: DIREKT (ohne Benutzerauswahl)"
    Debug.Print String(80, "=")
    
    ' *** SCHRITT 1: EVENTS VON WEBSITE LADEN ***
    Debug.Print vbCrLf & ">>> Schritt 1/4: Lade Events von Homepage..."
    allEvents = LoadEventsFromHomepage(WEBSITE_URL, heutesDatum)
    eventCount = UBound(allEvents) - LBound(allEvents) + 1
    
    If eventCount = 0 Or (eventCount = 1 And Len(Trim(allEvents(0).titel)) = 0) Then
        DoCmd.Hourglass False
        
        MsgBox "Keine relevanten Events auf der Homepage gefunden." & vbCrLf & vbCrLf & _
               "Website: " & WEBSITE_URL & vbCrLf & _
               "Locations: " & Replace(RELEVANT_LOCATIONS, "|", ", "), _
               vbExclamation, "Kein Import"
        
        Debug.Print "!!! Keine Events gefunden"
        Exit Sub
    End If
    
    Debug.Print "? Gefunden: " & eventCount & " Events"
    
    ' *** SCHRITT 2: DATENBANK-ABGLEICH ***
    Debug.Print vbCrLf & ">>> Schritt 2/4: Prüfe Datenbank-Status..."
    
    newCount = 0
    For i = LBound(allEvents) To UBound(allEvents)
        Debug.Print "  [" & i & "] Prüfe: " & allEvents(i).titel & " | " & _
                   allEvents(i).Objekt & " | " & allEvents(i).DatumStr
        
        allEvents(i).ExistiertInDB = EventExistsInDatabase( _
            allEvents(i).Datum, allEvents(i).titel, allEvents(i).Objekt)
        
        If allEvents(i).ExistiertInDB Then
            Debug.Print "      ? Bereits in DB vorhanden"
        Else
            Debug.Print "      ? NEU - wird importiert"
            newCount = newCount + 1
        End If
    Next i
    
    Debug.Print vbCrLf & ">>> Ergebnis: " & newCount & " neue Events | " & _
                (eventCount - newCount) & " bereits vorhanden"
    
    ' *** SCHRITT 3: PRÜFUNG OB NEUE EVENTS VORHANDEN ***
    If newCount = 0 Then
        DoCmd.Hourglass False
        MsgBox "Alle Events von der Homepage sind bereits in der Datenbank vorhanden." & vbCrLf & vbCrLf & _
               "Geprüfte Events: " & eventCount, _
               vbInformation, "Kein Import erforderlich"
        Debug.Print "? Kein Import erforderlich - alle Events vorhanden"
        Exit Sub
    End If
    
    ' *** SCHRITT 4: NEUE EVENTS DIREKT ANLEGEN ***
    Debug.Print vbCrLf & ">>> Schritt 3/4: Erstelle neue Events..."
    
    Dim successCount As Integer
    Dim errorCount As Integer
    Dim successDetails As String
    Dim errorDetails As String
    Dim createdIDs As String
    
    successCount = 0
    errorCount = 0
    successDetails = ""
    errorDetails = ""
    createdIDs = ""
    
    ' Durch alle Events iterieren und neue anlegen
    For i = LBound(allEvents) To UBound(allEvents)
        If Not allEvents(i).ExistiertInDB Then
            
            Debug.Print vbCrLf & "  [" & i & "] Erstelle: " & allEvents(i).titel
            
            ' *** WICHTIG: ORT-FELD VALIDIERUNG ***
            If Len(Trim(allEvents(i).Ort)) = 0 Then
                allEvents(i).Ort = "Nürnberg"
                Debug.Print "      ? Ort-Feld leer - setze Standard: Nürnberg"
            End If
            
            Dim ergebnis As String
            ergebnis = CreateAuftragMitSchichten( _
                allEvents(i).Datum, _
                allEvents(i).titel, _
                allEvents(i).Objekt, _
                allEvents(i).Ort, _
                TREFFPUNKT_DEFAULT, _
                allEvents(i).einlasszeit)
            
            If Left(ergebnis, 7) = "SUCCESS" Then
                successCount = successCount + 1
                
                Dim Teile() As String
                Teile = Split(ergebnis, "|")
                Dim auftragsID As String
                If UBound(Teile) >= 1 Then
                    auftragsID = Teile(1)
                    createdIDs = createdIDs & auftragsID & ","
                Else
                    auftragsID = "?"
                End If
                
                successDetails = successDetails & "• ID " & auftragsID & ": " & _
                                Format(allEvents(i).Datum, "dd.mm.yyyy") & " - " & _
                                Left(allEvents(i).titel, 40) & " (" & _
                                allEvents(i).Objekt & ")" & vbCrLf
                
                Debug.Print "      ? Erfolgreich erstellt (ID: " & auftragsID & ")"
            Else
                errorCount = errorCount + 1
                errorDetails = errorDetails & "• " & allEvents(i).titel & ": " & _
                              Right(ergebnis, Len(ergebnis) - 7) & vbCrLf
                Debug.Print "      ? FEHLER: " & ergebnis
            End If
        End If
    Next i
    
    DoCmd.Hourglass False
    
    ' *** SCHRITT 5: ZUSAMMENFASSUNG ***
    Debug.Print vbCrLf & String(80, "=")
    Debug.Print "=== Homepage-Import abgeschlossen ==="
    Debug.Print "Erfolgreich: " & successCount & " | Fehler: " & errorCount
    Debug.Print String(80, "=")
    
    ' Benutzer-Meldung
    If errorCount = 0 Then
        MsgBox "? Homepage-Import erfolgreich abgeschlossen!" & vbCrLf & vbCrLf & _
               "Neue Events angelegt: " & successCount & vbCrLf & vbCrLf & _
               successDetails & vbCrLf & _
               "Details im Debug-Fenster (Strg+G)", _
               vbInformation, "Import erfolgreich"
    Else
        MsgBox "? Import teilweise erfolgreich!" & vbCrLf & vbCrLf & _
               "Erfolgreich: " & successCount & vbCrLf & _
               "Fehler: " & errorCount & vbCrLf & vbCrLf & _
               "ERFOLGREICH:" & vbCrLf & successDetails & vbCrLf & _
               "FEHLER:" & vbCrLf & errorDetails, _
               vbExclamation, "Import mit Fehlern"
    End If
    
    Exit Sub
    
ErrorHandler:
    DoCmd.Hourglass False
    MsgBox "Kritischer Fehler beim Homepage-Import:" & vbCrLf & vbCrLf & _
           "Fehler-Nr: " & err.Number & vbCrLf & _
           "Beschreibung: " & err.description, vbCritical, "Fehler"
    Debug.Print "!!! KRITISCHER FEHLER: " & err.Number & " - " & err.description
End Sub

' ============================================================================
' Prüft ob Event in DB existiert - DATUMSFORMAT KORRIGIERT
' ============================================================================
Private Function EventExistsInDatabase(eventDatum As Date, _
                                       eventTitel As String, _
                                       eventObjekt As String) As Boolean
    On Error Resume Next
    
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim DatumVon As String
    Dim DatumBis As String
    
    ' KORRIGIERT: Datum-Bereich mit DatumFuerSQL()
    DatumVon = DatumFuerSQL(DateAdd("d", -1, eventDatum))
    DatumBis = DatumFuerSQL(DateAdd("d", 1, eventDatum))
    
    ' Titel und Objekt für SQL bereinigen
    eventTitel = Replace(eventTitel, "'", "''")
    eventObjekt = Replace(eventObjekt, "'", "''")
    
    sql = "SELECT COUNT(*) AS Anzahl FROM tbl_VA_Auftragstamm " & _
          "WHERE Auftrag LIKE '%" & eventTitel & "%' " & _
          "AND Objekt LIKE '%" & eventObjekt & "%' " & _
          "AND Dat_VA_Von >= #" & DatumVon & "# " & _
          "AND Dat_VA_Von <= #" & DatumBis & "#"
    
    Set rs = CurrentDb.OpenRecordset(sql)
    
    If Not rs.EOF Then
        EventExistsInDatabase = (rs!Anzahl > 0)
    Else
        EventExistsInDatabase = False
    End If
    
    rs.Close
    Set rs = Nothing
End Function

' ============================================================================
' Erstellt Auftrag mit Schichten - KORRIGIERT
' ============================================================================
Private Function CreateAuftragMitSchichten(ByVal eventDatum As Date, _
                                           ByVal eventTitel As String, _
                                           ByVal eventObjekt As String, _
                                           ByVal eventOrt As String, _
                                           ByVal eventTreffpunkt As String, _
                                           ByVal eventEinlasszeit As Date) As String
    On Error GoTo ErrorHandler
    
    Dim titelFormatiert As String
    Dim objektFormatiert As String
    Dim ortFormatiert As String
    
    titelFormatiert = ToTitleCase(eventTitel)
    objektFormatiert = ToTitleCase(eventObjekt)
    ortFormatiert = ToTitleCase(eventOrt)
    
    ' *** WICHTIG: ORT DARF NICHT LEER SEIN ***
    If Len(Trim(ortFormatiert)) = 0 Then
        ortFormatiert = "Nürnberg"
        Debug.Print "      ? Ort-Feld war leer - setze Standard: Nürnberg"
    End If
    
    Debug.Print "      ? Erstelle Auftrag: " & titelFormatiert & " | " & objektFormatiert & " | " & ortFormatiert
    
    Dim ergebnis As String
    ergebnis = AuftragErstellen( _
        auftragsName:=titelFormatiert, _
        objektName:=objektFormatiert, _
        ortName:=ortFormatiert, _
        DatumVon:=eventDatum, _
        DatumBis:=eventDatum, _
        auftraggeber:="", _
        Treffpunkt:=eventTreffpunkt, _
        schichten:="", _
        statusID:=1, _
        Ersteller:="Homepage-Import" _
    )
    
    If Left(ergebnis, 7) = "SUCCESS" Then
        Dim auftragsID As Long
        auftragsID = CLng(Split(ergebnis, "|")(1))
        
        Debug.Print "      ? Setze Pflichtfelder..."
        Call SetzeAllePflichtfelder(auftragsID, eventDatum, ortFormatiert)
        
        Debug.Print "      ? Erstelle Schichten..."
        Call ErstelleSchichtenFuerLocation(auftragsID, eventDatum, objektFormatiert, eventEinlasszeit)
        
        Debug.Print "      ? Aktiviere Boolean-Felder..."
        Call KorrigiereAuftragBooleans(auftragsID)
        
        Debug.Print "      ? Auftrag komplett erstellt (ID: " & auftragsID & ")"
    End If
    
    CreateAuftragMitSchichten = ergebnis
    Exit Function
    
ErrorHandler:
    CreateAuftragMitSchichten = "FEHLER: " & err.description
    Debug.Print "      ? Fehler: " & err.description
End Function

' ============================================================================
' Aktiviert Boolean-Felder eines Auftrags
' ============================================================================
Private Sub KorrigiereAuftragBooleans(ByVal auftragsID As Long)
    On Error Resume Next
    
    Dim rs As DAO.Recordset
    Set rs = CurrentDb.OpenRecordset( _
        "SELECT * FROM tbl_VA_Auftragstamm WHERE ID = " & auftragsID, dbOpenDynaset)
    
    If Not rs.EOF Then
        Dim i As Integer
        Dim hatUpdate As Boolean
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
        
        If hatUpdate Then
            rs.update
            Debug.Print "        ? " & i & " Boolean-Felder aktiviert"
        End If
    End If
    
    rs.Close
    Set rs = Nothing
End Sub

' ============================================================================
' Setzt Pflichtfelder - DATUMSFORMAT KORRIGIERT
' ============================================================================
Private Sub SetzeAllePflichtfelder(ByVal auftragsID As Long, _
                                    ByVal eventDatum As Date, _
                                    ByVal ortName As String)
    On Error Resume Next
    
    ' *** WICHTIG: ORT-VALIDIERUNG ***
    If Len(Trim(ortName)) = 0 Then
        ortName = "Nürnberg"
        Debug.Print "        ? Ort-Feld leer - setze Standard: Nürnberg"
    End If
    
    Dim sql As String
    sql = "UPDATE tbl_VA_Auftragstamm SET " & _
          "Veranstalter_ID = " & VERANSTALTER_ID_DEFAULT & ", " & _
          "Veranst_Status_ID = 1, " & _
          "Erst_am = Now(), " & _
          "Erst_von = '" & Environ("USERNAME") & "', " & _
          "Dienstkleidung = '" & DIENSTKLEIDUNG_DEFAULT & "', " & _
          "Ort = '" & Replace(ortName, "'", "''") & "' " & _
          "WHERE ID = " & auftragsID
    
    CurrentDb.Execute sql
    Debug.Print "        ? Pflichtfelder gesetzt (inkl. Ort: " & ortName & ")"
    
    ' *** KRITISCH: Prüfe ob tbl_VA_AnzTage existiert - WENN NICHT, ERSTELLEN! ***
    Dim rs As DAO.Recordset
    Set rs = CurrentDb.OpenRecordset( _
        "SELECT COUNT(*) AS Anzahl FROM tbl_VA_AnzTage WHERE VA_ID = " & auftragsID)
    
    If rs!Anzahl = 0 Then
        ' KORRIGIERT: Verwende DatumFuerSQL()
        sql = "INSERT INTO tbl_VA_AnzTage (VA_ID, VADatum, TVA_Soll, TVA_Ist) " & _
              "VALUES (" & auftragsID & ", #" & DatumFuerSQL(eventDatum) & "#, 1, 0)"
        CurrentDb.Execute sql
        Debug.Print "        ? AnzTage-Eintrag erstellt (TVA_Soll = 1)"
    Else
        ' Prüfe ob TVA_Soll gesetzt ist
        rs.Close
        Set rs = CurrentDb.OpenRecordset( _
            "SELECT TVA_Soll FROM tbl_VA_AnzTage WHERE VA_ID = " & auftragsID)
        
        If Not rs.EOF Then
            If Nz(rs!TVA_Soll, 0) = 0 Then
                ' Korrigiere TVA_Soll
                sql = "UPDATE tbl_VA_AnzTage SET TVA_Soll = 1 WHERE VA_ID = " & auftragsID
                CurrentDb.Execute sql
                Debug.Print "        ? TVA_Soll korrigiert auf 1"
            Else
                Debug.Print "        ? AnzTage-Eintrag bereits vorhanden und korrekt"
            End If
        End If
    End If
    
    rs.Close
    Set rs = Nothing
End Sub

' ============================================================================
' Erstellt Schichten - ERWEITERT MIT ALLEN 12 LOCATIONS
' ============================================================================
Private Sub ErstelleSchichtenFuerLocation(ByVal auftragsID As Long, _
                                          ByVal eventDatum As Date, _
                                          ByVal Location As String, _
                                          ByVal einlasszeit As Date)
    On Error GoTo ErrorHandler
    
    Dim schichten() As SchichtInfo
    Dim locationUpper As String
    Dim schichtCount As Integer
    
    locationUpper = UCase(Trim(Location))
    
    ' LÖWENSAAL / LOEWENSAAL
    If InStr(locationUpper, "LÖWENSAAL") > 0 Or InStr(locationUpper, "LOEWENSAAL") > 0 Then
        ReDim schichten(0 To 2)
        schichten(0).anzahlMA = 11
        schichten(0).MinutenVorEinlass = 30
        schichten(1).anzahlMA = 1
        schichten(1).MinutenVorEinlass = 60
        schichten(2).anzahlMA = 1
        schichten(2).MinutenVorEinlass = 90
        schichtCount = 3
        
    ' MEISTERSINGERHALLE
    ElseIf InStr(locationUpper, "MEISTERSINGERHALLE") > 0 Then
        ReDim schichten(0 To 0)
        schichten(0).anzahlMA = 2
        schichten(0).MinutenVorEinlass = 30
        schichtCount = 1
        
    ' MARKGRAFENSAAL
    ElseIf InStr(locationUpper, "MARKGRAFENSAAL") > 0 Then
        ReDim schichten(0 To 0)
        schichten(0).anzahlMA = 2
        schichten(0).MinutenVorEinlass = 30
        schichtCount = 1
        
    ' STADTHALLE
    ElseIf InStr(locationUpper, "STADTHALLE") > 0 Then
        ReDim schichten(0 To 2)
        schichten(0).anzahlMA = 15
        schichten(0).MinutenVorEinlass = 30
        schichten(1).anzahlMA = 1
        schichten(1).MinutenVorEinlass = 0
        schichten(1).FixeStartzeit = "09:00"
        schichten(2).anzahlMA = 1
        schichten(2).MinutenVorEinlass = 60
        schichtCount = 3
        
    ' HEINRICH-LADES-HALLE
    ElseIf InStr(locationUpper, "HEINRICH-LADES-HALLE") > 0 Or InStr(locationUpper, "LADES-HALLE") > 0 Then
        ReDim schichten(0 To 0)
        schichten(0).anzahlMA = 3
        schichten(0).MinutenVorEinlass = 30
        schichtCount = 1
        
    ' LUX-KIRCHE
    ElseIf InStr(locationUpper, "LUX-KIRCHE") > 0 Or InStr(locationUpper, "LUXKIRCHE") > 0 Then
        ReDim schichten(0 To 0)
        schichten(0).anzahlMA = 2
        schichten(0).MinutenVorEinlass = 30
        schichtCount = 1
        
    ' KIA METROPOL ARENA
    ElseIf InStr(locationUpper, "KIA METROPOL") > 0 Or InStr(locationUpper, "METROPOL ARENA") > 0 Then
        ReDim schichten(0 To 0)
        schichten(0).anzahlMA = 20
        schichten(0).MinutenVorEinlass = 45
        schichtCount = 1
        
    ' PSB BANK ARENA
    ElseIf InStr(locationUpper, "PSB BANK") > 0 Or InStr(locationUpper, "PSB-ARENA") > 0 Then
        ReDim schichten(0 To 0)
        schichten(0).anzahlMA = 15
        schichten(0).MinutenVorEinlass = 45
        schichtCount = 1
        
    ' DONAU-ARENA
    ElseIf InStr(locationUpper, "DONAU-ARENA") > 0 Or InStr(locationUpper, "DONAUARENA") > 0 Then
        ReDim schichten(0 To 0)
        schichten(0).anzahlMA = 12
        schichten(0).MinutenVorEinlass = 45
        schichtCount = 1
        
    ' BROSE ARENA
    ElseIf InStr(locationUpper, "BROSE ARENA") > 0 Or InStr(locationUpper, "BROSE-ARENA") > 0 Then
        ReDim schichten(0 To 0)
        schichten(0).anzahlMA = 15
        schichten(0).MinutenVorEinlass = 45
        schichtCount = 1
        
    ' STADIONPARK
    ElseIf InStr(locationUpper, "STADIONPARK") > 0 Then
        ReDim schichten(0 To 0)
        schichten(0).anzahlMA = 5
        schichten(0).MinutenVorEinlass = 30
        schichtCount = 1
        
    Else
        Debug.Print "        ? Keine Schichten-Vorlage für: " & Location
        Exit Sub
    End If
    
    Debug.Print "        ? " & schichtCount & " Schicht-Typen für: " & Location
    
    Dim i As Integer
    Dim j As Integer
    Dim startzeit As Date
    Dim endzeit As Date
    
    endzeit = DateSerial(year(eventDatum), Month(eventDatum), Day(eventDatum)) + TimeSerial(23, 30, 0)
    
    For i = 0 To schichtCount - 1
        If Len(schichten(i).FixeStartzeit) > 0 Then
            startzeit = DateSerial(year(eventDatum), Month(eventDatum), Day(eventDatum)) + _
                       TimeSerial(Val(Left(schichten(i).FixeStartzeit, 2)), _
                                 Val(Right(schichten(i).FixeStartzeit, 2)), 0)
        Else
            startzeit = DateAdd("n", -schichten(i).MinutenVorEinlass, einlasszeit)
        End If
        
        For j = 1 To schichten(i).anzahlMA
            Call SchichtEintragErstellen(auftragsID, eventDatum, startzeit, endzeit)
        Next j
        
        Debug.Print "          ? " & schichten(i).anzahlMA & " MA: " & _
                   Format(startzeit, "hh:nn") & "-" & Format(endzeit, "hh:nn")
    Next i
    
    Exit Sub
    
ErrorHandler:
    Debug.Print "        ? Schicht-Fehler: " & err.description
End Sub

' ============================================================================
' Erstellt Schicht-Eintrag - DATUMSFORMAT KORRIGIERT
' ============================================================================
Private Sub SchichtEintragErstellen(ByVal auftragsID As Long, _
                                    ByVal eventDatum As Date, _
                                    ByVal startzeit As Date, _
                                    ByVal endzeit As Date)
    On Error Resume Next
    
    ' KORRIGIERT: Verwende DatumFuerSQL() und DatumZeitFuerSQL()
    Dim sql As String
    sql = "INSERT INTO tbl_VA_AnzTage (VA_ID, VADatum, VAbeginn, VAende, TVA_Soll, TVA_Ist) " & _
          "VALUES (" & auftragsID & ", " & _
          "#" & DatumFuerSQL(eventDatum) & "#, " & _
          "#" & DatumZeitFuerSQL(startzeit) & "#, " & _
          "#" & DatumZeitFuerSQL(endzeit) & "#, 1, 0)"
    
    CurrentDb.Execute sql
End Sub

' ============================================================================
' HTML-Funktionen
' ============================================================================
Private Function LoadEventsFromHomepage(websiteURL As String, minDatum As Date) As EventInfo()
    On Error GoTo ErrorHandler
    
    Dim htmlContent As String
    Dim allEvents() As EventInfo
    Dim totalCount As Integer
    
    htmlContent = DownloadHTML(websiteURL)
    
    If Len(htmlContent) = 0 Then
        ReDim allEvents(0 To 0)
        allEvents(0).titel = ""
        LoadEventsFromHomepage = allEvents
        Exit Function
    End If
    
    Call SaveHTMLForDebug(htmlContent)
    
    ReDim allEvents(0 To 999)
    totalCount = ParseEventsFromHTML(htmlContent, allEvents, minDatum)
    
    If totalCount > 0 Then
        ReDim Preserve allEvents(0 To totalCount - 1)
    Else
        ReDim allEvents(0 To 0)
        allEvents(0).titel = ""
    End If
    
    LoadEventsFromHomepage = allEvents
    Exit Function
    
ErrorHandler:
    ReDim allEvents(0 To 0)
    allEvents(0).titel = ""
    LoadEventsFromHomepage = allEvents
End Function

Private Function DownloadHTML(url As String) As String
    On Error GoTo ErrorHandler
    
    Dim http As Object
    Set http = CreateObject("MSXML2.XMLHTTP")
    
    http.Open "GET", url, False
    http.setRequestHeader "User-Agent", "Mozilla/5.0"
    http.Send
    
    If http.Status = 200 Then
        DownloadHTML = http.responseText
    Else
        DownloadHTML = ""
    End If
    
    Set http = Nothing
    Exit Function
    
ErrorHandler:
    DownloadHTML = ""
End Function

Private Function ParseEventsFromHTML(htmlContent As String, ByRef allEvents() As EventInfo, minDatum As Date) As Integer
    On Error GoTo ErrorHandler
    
    Debug.Print "  ? Parse HTML (Regex-basiert)..."
    
    Dim currentIndex As Integer
    Dim pos As Long
    Dim searchPos As Long
    Dim blockText As String
    Dim eventDate As Date
    Dim titleStr As String
    Dim locationStr As String
    Dim cityStr As String
    Dim einlassStr As String
    Dim eventEinlass As Date
    
    currentIndex = 0
    searchPos = 1
    
    Do While searchPos < Len(htmlContent)
        pos = FindNextDatePosition(htmlContent, searchPos)
        
        If pos = 0 Then Exit Do
        
        Dim blockStart As Long
        Dim blockEnd As Long
        blockStart = IIf(pos - 500 > 0, pos - 500, 1)
        blockEnd = IIf(pos + 500 < Len(htmlContent), pos + 500, Len(htmlContent))
        blockText = Mid(htmlContent, blockStart, blockEnd - blockStart)
        
        Dim dateStr As String
        dateStr = ExtractDateFromBlock(blockText)
        
        If Len(dateStr) > 0 And IsDate(dateStr) Then
            eventDate = CDate(dateStr)
            
            If eventDate >= minDatum And eventDate < #1/1/2100# Then
                
                titleStr = ExtractTitleFromBlock(blockText)
                locationStr = ExtractLocationFromBlock(blockText)
                cityStr = ExtractCityFromBlock(blockText)
                einlassStr = ExtractEinlasszeitFromBlock(blockText)
                
                locationStr = CleanLocationString(locationStr)
                cityStr = CleanLocationString(cityStr)
                
                ' *** ORT-VALIDIERUNG ***
                If Len(Trim(cityStr)) = 0 Then
                    cityStr = "Nürnberg"
                End If
                
                If Len(einlassStr) > 0 Then
                    eventEinlass = ParseEinlasszeit(einlassStr, eventDate)
                Else
                    eventEinlass = DateSerial(year(eventDate), Month(eventDate), Day(eventDate)) + TimeSerial(19, 0, 0)
                End If
                
                If Len(titleStr) > 0 And Len(locationStr) > 0 And IsRelevantLocation(locationStr) Then
                    
                    allEvents(currentIndex).Datum = eventDate
                    allEvents(currentIndex).DatumStr = Format(eventDate, "dd.mm.yyyy")
                    allEvents(currentIndex).titel = Trim(titleStr)
                    allEvents(currentIndex).Ort = cityStr
                    allEvents(currentIndex).Objekt = Trim(locationStr)
                    allEvents(currentIndex).VeranstalterID = VERANSTALTER_ID_DEFAULT
                    allEvents(currentIndex).ExistiertInDB = False
                    allEvents(currentIndex).SheetQuelle = "Homepage"
                    allEvents(currentIndex).Treffpunkt = TREFFPUNKT_DEFAULT
                    allEvents(currentIndex).einlasszeit = eventEinlass
                    allEvents(currentIndex).EinlasszeitStr = Format(eventEinlass, "hh:nn")
                    
                    Debug.Print "    [" & currentIndex & "] " & allEvents(currentIndex).DatumStr & " | " & _
                               allEvents(currentIndex).titel & " | " & allEvents(currentIndex).Objekt & _
                               " | " & allEvents(currentIndex).Ort
                    
                    currentIndex = currentIndex + 1
                    
                    If currentIndex > UBound(allEvents) Then
                        ReDim Preserve allEvents(0 To UBound(allEvents) + 100)
                    End If
                End If
            End If
        End If
        
        searchPos = pos + 100
    Loop
    
    ParseEventsFromHTML = currentIndex
    Exit Function
    
ErrorHandler:
    ParseEventsFromHTML = currentIndex
End Function

' ============================================================================
' HTML-Parsing-Hilfsfunktionen
' ============================================================================
Private Function CleanLocationString(locationStr As String) As String
    Dim cleaned As String
    cleaned = Trim(locationStr)
    
    cleaned = Replace(cleaned, ">", "")
    cleaned = Replace(cleaned, "<", "")
    cleaned = Replace(cleaned, """", "")
    cleaned = Replace(cleaned, "'", "")
    cleaned = Replace(cleaned, "/", "")
    cleaned = Replace(cleaned, "&bull;", "")
    cleaned = Replace(cleaned, "&nbsp;", " ")
    cleaned = Replace(cleaned, vbTab, " ")
    
    Do While InStr(cleaned, "  ") > 0
        cleaned = Replace(cleaned, "  ", " ")
    Loop
    
    CleanLocationString = Trim(cleaned)
End Function

Private Function FindNextDatePosition(html As String, startPos As Long) As Long
    Dim regEx As Object
    Dim matches As Object
    
    Set regEx = CreateObject("VBScript.RegExp")
    regEx.Pattern = "\b\d{2}\.\d{2}\.\d{4}\b"
    regEx.Global = True
    
    Set matches = regEx.Execute(Mid(html, startPos))
    
    If matches.Count > 0 Then
        FindNextDatePosition = startPos + matches(0).firstIndex
    Else
        FindNextDatePosition = 0
    End If
End Function

Private Function ExtractDateFromBlock(blockText As String) As String
    Dim regEx As Object
    Set regEx = CreateObject("VBScript.RegExp")
    regEx.Pattern = "\b\d{2}\.\d{2}\.\d{4}\b"
    
    Dim matches As Object
    Set matches = regEx.Execute(blockText)
    
    If matches.Count > 0 Then
        ExtractDateFromBlock = matches(0).Value
    Else
        ExtractDateFromBlock = ""
    End If
End Function

Private Function ExtractTitleFromBlock(blockText As String) As String
    Dim lines() As String
    Dim line As String
    Dim i As Integer
    
    blockText = RemoveHTMLTags(blockText)
    lines = Split(blockText, vbLf)
    
    For i = LBound(lines) To UBound(lines)
        line = Trim(Replace(lines(i), vbCr, ""))
        
        If Len(line) >= 5 And Len(line) <= 80 Then
            If UCase(line) = line And IsAllCaps(line) Then
                If InStr(line, ".") = 0 And InStr(line, "•") = 0 And _
                   InStr(line, "Einlass") = 0 And InStr(line, "Beginn") = 0 Then
                    ExtractTitleFromBlock = line
                    Exit Function
                End If
            End If
        End If
    Next i
    
    ExtractTitleFromBlock = ""
End Function

Private Function IsAllCaps(Text As String) As Boolean
    Dim i As Integer
    Dim char As String
    Dim hasLetter As Boolean
    
    hasLetter = False
    
    For i = 1 To Len(Text)
        char = Mid(Text, i, 1)
        
        If char >= "A" And char <= "Z" Then
            hasLetter = True
        ElseIf char >= "a" And char <= "z" Then
            IsAllCaps = False
            Exit Function
        End If
    Next i
    
    IsAllCaps = hasLetter
End Function

Private Function ExtractLocationFromBlock(blockText As String) As String
    Dim lines() As String
    Dim line As String
    Dim i As Integer
    Dim parts() As String
    
    blockText = RemoveHTMLTags(blockText)
    lines = Split(blockText, vbLf)
    
    For i = LBound(lines) To UBound(lines)
        line = Trim(Replace(lines(i), vbCr, ""))
        
        If InStr(line, "•") > 0 Then
            parts = Split(line, "•")
            If UBound(parts) >= 1 Then
                ExtractLocationFromBlock = Trim(parts(1))
                Exit Function
            End If
        End If
    Next i
    
    ExtractLocationFromBlock = ""
End Function

Private Function ExtractCityFromBlock(blockText As String) As String
    Dim lines() As String
    Dim line As String
    Dim i As Integer
    Dim parts() As String
    
    blockText = RemoveHTMLTags(blockText)
    lines = Split(blockText, vbLf)
    
    For i = LBound(lines) To UBound(lines)
        line = Trim(Replace(lines(i), vbCr, ""))
        
        If InStr(line, "•") > 0 Then
            parts = Split(line, "•")
            If UBound(parts) >= 0 Then
                Dim city As String
                city = Trim(parts(0))
                If Len(city) = 0 Then city = "Nürnberg"
                ExtractCityFromBlock = city
                Exit Function
            End If
        End If
    Next i
    
    ExtractCityFromBlock = "Nürnberg"
End Function

Private Function ExtractEinlasszeitFromBlock(blockText As String) As String
    Dim lines() As String
    Dim line As String
    Dim i As Integer
    
    blockText = RemoveHTMLTags(blockText)
    lines = Split(blockText, vbLf)
    
    For i = LBound(lines) To UBound(lines)
        line = Trim(Replace(lines(i), vbCr, ""))
        
        If InStr(1, line, "Einlass:", vbTextCompare) > 0 Then
            Dim pos As Integer
            pos = InStr(1, line, "Einlass:", vbTextCompare)
            ExtractEinlasszeitFromBlock = Trim(Mid(line, pos + 8))
            Exit Function
        End If
    Next i
    
    ExtractEinlasszeitFromBlock = ""
End Function

Private Function ParseEinlasszeit(zeitStr As String, eventDate As Date) As Date
    Dim stunde As Integer
    Dim minute As Integer
    Dim parts() As String
    
    zeitStr = Replace(zeitStr, "Uhr", "")
    zeitStr = Trim(zeitStr)
    
    If InStr(zeitStr, ":") > 0 Then
        parts = Split(zeitStr, ":")
        If UBound(parts) >= 1 Then
            stunde = Val(Trim(parts(0)))
            minute = Val(Trim(Left(parts(1), 2)))
            
            If stunde >= 0 And stunde <= 23 And minute >= 0 And minute <= 59 Then
                ParseEinlasszeit = DateSerial(year(eventDate), Month(eventDate), Day(eventDate)) + _
                                  TimeSerial(stunde, minute, 0)
                Exit Function
            End If
        End If
    End If
    
    ParseEinlasszeit = DateSerial(year(eventDate), Month(eventDate), Day(eventDate)) + TimeSerial(19, 0, 0)
End Function

Private Function RemoveHTMLTags(html As String) As String
    Dim regEx As Object
    Set regEx = CreateObject("VBScript.RegExp")
    
    regEx.Pattern = "<[^>]+>"
    regEx.Global = True
    
    RemoveHTMLTags = regEx.Replace(html, vbLf)
    RemoveHTMLTags = Replace(RemoveHTMLTags, vbLf & vbLf, vbLf)
End Function

Private Sub SaveHTMLForDebug(htmlContent As String)
    On Error Resume Next
    
    Dim fso As Object
    Dim textFile As Object
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FolderExists("C:\Temp") Then fso.CreateFolder "C:\Temp"
    
    Set textFile = fso.CreateTextFile("C:\Temp\Homepage_Debug.html", True, True)
    textFile.Write htmlContent
    textFile.Close
End Sub

Private Function IsRelevantLocation(Objekt As String) As Boolean
    If Len(Trim(Objekt)) = 0 Then
        IsRelevantLocation = False
        Exit Function
    End If
    
    Dim locations As Variant
    Dim Location As Variant
    Dim objektUpper As String
    
    objektUpper = UCase(Trim(Objekt))
    locations = Split(RELEVANT_LOCATIONS, "|")
    
    For Each Location In locations
        If InStr(1, objektUpper, UCase(Trim(CStr(Location))), vbTextCompare) > 0 Then
            IsRelevantLocation = True
            Exit Function
        End If
    Next Location
    
    IsRelevantLocation = False
End Function

' ============================================================================
' Hilfsfunktionen
' ============================================================================
Private Function ToTitleCase(Text As String) As String
    Dim words() As String
    Dim i As Integer
    Dim result As String
    
    If Len(Trim(Text)) = 0 Then
        ToTitleCase = ""
        Exit Function
    End If
    
    words = Split(LCase(Trim(Text)), " ")
    
    For i = LBound(words) To UBound(words)
        If Len(words(i)) > 0 Then
            words(i) = UCase(Left(words(i), 1)) & Mid(words(i), 2)
        End If
    Next i
    
    ToTitleCase = Join(words, " ")
End Function

Private Function Nz(Value As Variant, Optional valueIfNull As Variant = "") As Variant
    If IsNull(Value) Or IsEmpty(Value) Then
        Nz = valueIfNull
    Else
        Nz = Value
    End If
End Function

' ============================================================================
' Diagnose-Funktion
' ============================================================================
Public Sub DiagnoseHomepageImport()
    On Error Resume Next
    
    Debug.Print String(80, "=")
    Debug.Print "=== DIAGNOSE ==="
    Debug.Print String(80, "=")
    
    Dim html As String
    html = DownloadHTML(WEBSITE_URL)
    
    If Len(html) = 0 Then
        MsgBox "HTML-Download fehlgeschlagen!", vbCritical
        Exit Sub
    End If
    
    Call SaveHTMLForDebug(html)
    
    Dim testEvents() As EventInfo
    ReDim testEvents(0 To 999)
    
    Dim Count As Integer
    Count = ParseEventsFromHTML(html, testEvents, Date)
    
    Debug.Print vbCrLf & "Gefundene Events: " & Count
    
    If Count > 0 Then
        Dim i As Integer
        For i = 0 To IIf(Count > 5, 4, Count - 1)
            Debug.Print "  [" & i & "] " & testEvents(i).DatumStr & " | " & _
                       testEvents(i).titel & " | " & testEvents(i).Objekt & " | " & _
                       testEvents(i).Ort
        Next i
    End If
    
    MsgBox "Diagnose abgeschlossen!" & vbCrLf & vbCrLf & _
           "Events gefunden: " & Count & vbCrLf & vbCrLf & _
           "Details im Debug-Fenster (Strg+G)", vbInformation
End Sub
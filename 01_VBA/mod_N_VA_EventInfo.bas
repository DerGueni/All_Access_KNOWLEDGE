Attribute VB_Name = "mod_N_VA_EventInfo"
' ========================================================================
' Modul: mod_N_VA_EventInfo
' Zweck: Event Info Tab Funktionen fuer Auftragstamm
' Erstellt: 2026-01-05
' Abhaengigkeiten: mod_N_EventDaten (fuer Web-Scraping)
' ========================================================================

' ========================================================================
' Konstanten fuer API-Zugriffe
' ========================================================================
Private Const OPENWEATHERMAP_API_KEY As String = "YOUR_API_KEY_HERE"  ' Bitte API-Key eintragen
Private Const OPENWEATHERMAP_URL As String = "https://api.openweathermap.org/data/2.5/forecast"

' ========================================================================
' Type Definitionen
' ========================================================================
Public Type EventInfoResult
    VA_ID As Long
    EventName As String
    Datum As Date
    Ort As String
    Einlass As String
    Beginn As String
    Ende As String
    GeschaetzteBesucherzahl As Long
    WetterInfo As String
    WetterTemp As String
    MA_Geplant As Integer
    MA_Gebucht As Integer
    Positionen_Offen As Integer
    Positionen_Besetzt As Integer
    WebLink As String
    Notizen As String
    LetzteAktualisierung As Date
    Erfolgreich As Boolean
    Fehlermeldung As String
End Type

' ========================================================================
' 1. EVENT-DATEN LADEN
' ========================================================================

' ------------------------------------------------------------------------
' GetEventInfo: Hauptfunktion - Laedt alle Event-Infos
' Return: JSON-String mit allen Event-Informationen
' ------------------------------------------------------------------------
Public Function GetEventInfo(VA_ID As Long) As String
    On Error GoTo ErrorHandler

    Dim info As EventInfoResult
    Dim json As String

    ' Basis-Daten aus Auftragstamm laden
    info = LoadBaseEventInfo(VA_ID)

    If Not info.Erfolgreich Then
        GetEventInfo = BuildErrorJSON(info.Fehlermeldung)
        Exit Function
    End If

    ' Event-Name aus Auftrag extrahieren
    Dim extractedName As String
    extractedName = GetEventFromAuftrag(VA_ID)
    If Len(extractedName) > 0 Then
        info.EventName = extractedName
    End If

    ' Wetter laden (falls Datum in Zukunft und innerhalb 5 Tage)
    If info.Datum >= Date And info.Datum <= Date + 5 Then
        info.WetterInfo = GetEventWetter(info.Datum, info.Ort)
    End If

    ' Besucherzahl schaetzen
    info.GeschaetzteBesucherzahl = GetEventBesucherzahl(info.EventName)

    ' Ressourcen laden
    Dim ressourcenJSON As String
    ressourcenJSON = GetEventRessourcen(VA_ID)

    ' Notizen laden
    info.Notizen = GetEventNotiz(VA_ID)

    ' JSON zusammenbauen
    json = "{"
    json = json & """VA_ID"":" & info.VA_ID & ","
    json = json & """EventName"":""" & EscapeJSON(info.EventName) & ""","
    json = json & """Datum"":""" & Format(info.Datum, "yyyy-mm-dd") & ""","
    json = json & """Ort"":""" & EscapeJSON(info.Ort) & ""","
    json = json & """Einlass"":""" & EscapeJSON(info.Einlass) & ""","
    json = json & """Beginn"":""" & EscapeJSON(info.Beginn) & ""","
    json = json & """Ende"":""" & EscapeJSON(info.Ende) & ""","
    json = json & """GeschaetzteBesucherzahl"":" & info.GeschaetzteBesucherzahl & ","
    json = json & """WetterInfo"":""" & EscapeJSON(info.WetterInfo) & ""","
    json = json & """WetterTemp"":""" & EscapeJSON(info.WetterTemp) & ""","
    json = json & """MA_Geplant"":" & info.MA_Geplant & ","
    json = json & """MA_Gebucht"":" & info.MA_Gebucht & ","
    json = json & """Positionen_Offen"":" & info.Positionen_Offen & ","
    json = json & """Positionen_Besetzt"":" & info.Positionen_Besetzt & ","
    json = json & """WebLink"":""" & EscapeJSON(info.WebLink) & ""","
    json = json & """Notizen"":""" & EscapeJSON(info.Notizen) & ""","
    json = json & """Ressourcen"":" & ressourcenJSON & ","
    json = json & """LetzteAktualisierung"":""" & Format(Now, "yyyy-mm-dd hh:nn:ss") & ""","
    json = json & """Erfolgreich"":true"
    json = json & "}"

    GetEventInfo = json
    Exit Function

ErrorHandler:
    GetEventInfo = BuildErrorJSON("Fehler in GetEventInfo: " & Err.Description)
End Function

' ------------------------------------------------------------------------
' LoadBaseEventInfo: Laedt Basis-Daten aus Auftragstamm
' ------------------------------------------------------------------------
Private Function LoadBaseEventInfo(VA_ID As Long) As EventInfoResult
    On Error GoTo ErrorHandler

    Dim result As EventInfoResult
    Dim rs As DAO.Recordset
    Dim sql As String

    result.VA_ID = VA_ID
    result.Erfolgreich = False

    sql = "SELECT a.Auftrag, a.Objekt, a.Ort, a.Dat_VA_Von, a.Dat_VA_Bis, " & _
          "a.VA_Einlass, a.VA_Beginn, a.VA_Ende, " & _
          "k.kun_Firma " & _
          "FROM tbl_VA_Auftragstamm a " & _
          "LEFT JOIN tbl_KD_Kundenstamm k ON a.Veranstalter_ID = k.kun_Id " & _
          "WHERE a.VA_ID = " & VA_ID

    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)

    If rs.EOF Then
        result.Fehlermeldung = "VA_ID " & VA_ID & " nicht gefunden"
        GoTo Cleanup
    End If

    result.EventName = Nz(rs!Auftrag, "")
    result.Ort = Nz(rs!Ort, "")
    result.Datum = Nz(rs!Dat_VA_Von, Date)
    result.Einlass = FormatTime(rs!VA_Einlass)
    result.Beginn = FormatTime(rs!VA_Beginn)
    result.Ende = FormatTime(rs!VA_Ende)
    result.Erfolgreich = True

Cleanup:
    If Not rs Is Nothing Then
        rs.Close
        Set rs = Nothing
    End If
    LoadBaseEventInfo = result
    Exit Function

ErrorHandler:
    result.Erfolgreich = False
    result.Fehlermeldung = "Datenbankfehler: " & Err.Description
    Resume Cleanup
End Function

' ------------------------------------------------------------------------
' GetEventFromAuftrag: Extrahiert Event-Name aus Auftragsbezeichnung
' Beispiel: "1.FCN - Bayern Muenchen" -> "1. FC Nuernberg vs Bayern Muenchen"
' ------------------------------------------------------------------------
Public Function GetEventFromAuftrag(VA_ID As Long) As String
    On Error GoTo ErrorHandler

    Dim rs As DAO.Recordset
    Dim sql As String
    Dim auftrag As String
    Dim objekt As String
    Dim eventName As String

    sql = "SELECT Auftrag, Objekt FROM tbl_VA_Auftragstamm WHERE VA_ID = " & VA_ID
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)

    If rs.EOF Then
        GetEventFromAuftrag = ""
        GoTo Cleanup
    End If

    auftrag = Nz(rs!Auftrag, "")
    objekt = Nz(rs!Objekt, "")

    ' Event-Name aus Auftrag extrahieren
    eventName = auftrag

    ' Bekannte Muster erkennen und verbessern
    eventName = NormalizeEventName(eventName)

    ' Falls Objekt vorhanden, als Kontext nutzen
    If Len(objekt) > 0 Then
        eventName = eventName & " @ " & objekt
    End If

Cleanup:
    If Not rs Is Nothing Then
        rs.Close
        Set rs = Nothing
    End If
    GetEventFromAuftrag = eventName
    Exit Function

ErrorHandler:
    GetEventFromAuftrag = ""
    Resume Cleanup
End Function

' ------------------------------------------------------------------------
' NormalizeEventName: Normalisiert Event-Namen
' ------------------------------------------------------------------------
Private Function NormalizeEventName(eventName As String) As String
    Dim result As String
    result = eventName

    ' Fussball-Abkuerzungen ersetzen
    result = Replace(result, "FCN", "1. FC Nuernberg", 1, -1, vbTextCompare)
    result = Replace(result, "1.FCN", "1. FC Nuernberg", 1, -1, vbTextCompare)
    result = Replace(result, "FCB", "FC Bayern Muenchen", 1, -1, vbTextCompare)
    result = Replace(result, "BVB", "Borussia Dortmund", 1, -1, vbTextCompare)
    result = Replace(result, "SGE", "Eintracht Frankfurt", 1, -1, vbTextCompare)
    result = Replace(result, "RBL", "RB Leipzig", 1, -1, vbTextCompare)

    ' "vs" oder "-" normalisieren
    If InStr(result, " - ") > 0 Then
        result = Replace(result, " - ", " vs ")
    End If

    NormalizeEventName = Trim(result)
End Function

' ========================================================================
' 2. EXTERNE DATEN
' ========================================================================

' ------------------------------------------------------------------------
' GetEventWetter: Wetter-Vorhersage fuer Event-Datum
' Nutzt OpenWeatherMap API (kostenloser Tier: 5-Tage-Vorhersage)
' ------------------------------------------------------------------------
Public Function GetEventWetter(Datum As Date, Ort As String) As String
    On Error GoTo ErrorHandler

    ' API-Key pruefen
    If OPENWEATHERMAP_API_KEY = "YOUR_API_KEY_HERE" Or Len(OPENWEATHERMAP_API_KEY) = 0 Then
        GetEventWetter = "Wetter-API nicht konfiguriert"
        Exit Function
    End If

    ' Nur Vorhersage fuer naechste 5 Tage moeglich
    If Datum > Date + 5 Then
        GetEventWetter = "Vorhersage nur fuer 5 Tage moeglich"
        Exit Function
    End If

    If Datum < Date Then
        GetEventWetter = "Datum liegt in der Vergangenheit"
        Exit Function
    End If

    ' Stadt fuer API vorbereiten
    Dim city As String
    city = CleanCityName(Ort)

    If Len(city) = 0 Then
        GetEventWetter = "Kein gueltiger Ort angegeben"
        Exit Function
    End If

    ' API-Aufruf
    Dim http As Object
    Dim url As String
    Dim response As String

    url = OPENWEATHERMAP_URL & "?q=" & URLEncode(city) & ",DE" & _
          "&appid=" & OPENWEATHERMAP_API_KEY & _
          "&units=metric&lang=de"

    Set http = CreateObject("MSXML2.ServerXMLHTTP.6.0")
    http.Open "GET", url, False
    http.setTimeouts 5000, 5000, 10000, 10000

    http.Send

    If http.Status <> 200 Then
        GetEventWetter = "Wetter-Abfrage fehlgeschlagen (HTTP " & http.Status & ")"
        GoTo Cleanup
    End If

    response = http.responseText

    ' Wetter fuer gewuenschtes Datum extrahieren
    GetEventWetter = ParseWeatherResponse(response, Datum)

Cleanup:
    Set http = Nothing
    Exit Function

ErrorHandler:
    GetEventWetter = "Fehler: " & Err.Description
    Resume Cleanup
End Function

' ------------------------------------------------------------------------
' ParseWeatherResponse: Extrahiert Wetter aus API-Antwort
' ------------------------------------------------------------------------
Private Function ParseWeatherResponse(jsonResponse As String, targetDate As Date) As String
    On Error Resume Next

    Dim targetDateStr As String
    targetDateStr = Format(targetDate, "yyyy-mm-dd")

    ' Einfaches Pattern-Matching fuer Wetter-Daten
    Dim temp As String
    Dim description As String

    ' Suche nach Eintrag fuer das Zieldatum (12:00 Uhr)
    Dim searchPattern As String
    searchPattern = targetDateStr & " 12:00:00"

    Dim pos As Long
    pos = InStr(jsonResponse, searchPattern)

    If pos > 0 Then
        ' Temperatur extrahieren
        temp = ExtractJSONValue(Mid(jsonResponse, pos), """temp"":")
        ' Beschreibung extrahieren
        description = ExtractJSONValue(Mid(jsonResponse, pos), """description"":""")
    End If

    If Len(temp) > 0 And Len(description) > 0 Then
        ParseWeatherResponse = description & ", " & Format(Val(temp), "0.0") & " Grad C"
    ElseIf Len(temp) > 0 Then
        ParseWeatherResponse = Format(Val(temp), "0.0") & " Grad C"
    Else
        ParseWeatherResponse = "Keine Daten verfuegbar"
    End If
End Function

' ------------------------------------------------------------------------
' GetEventBesucherzahl: Geschaetzte Besucherzahl basierend auf Event-Typ
' ------------------------------------------------------------------------
Public Function GetEventBesucherzahl(EventName As String) As Long
    On Error GoTo ErrorHandler

    Dim besucherzahl As Long
    Dim eventLower As String

    eventLower = LCase(EventName)

    ' Stadien und bekannte Locations
    Select Case True
        ' Fussball Bundesliga
        Case InStr(eventLower, "nuernberg") > 0 Or InStr(eventLower, "fcn") > 0
            besucherzahl = 45000  ' Max Morlock Stadion
        Case InStr(eventLower, "bayern") > 0 Or InStr(eventLower, "fcb") > 0
            besucherzahl = 75000  ' Allianz Arena
        Case InStr(eventLower, "dortmund") > 0 Or InStr(eventLower, "bvb") > 0
            besucherzahl = 81000  ' Signal Iduna Park
        Case InStr(eventLower, "frankfurt") > 0 Or InStr(eventLower, "sge") > 0
            besucherzahl = 51500  ' Deutsche Bank Park
        Case InStr(eventLower, "leipzig") > 0 Or InStr(eventLower, "rbl") > 0
            besucherzahl = 47000  ' Red Bull Arena

        ' Konzert-Locations Nuernberg
        Case InStr(eventLower, "arena nuernberg") > 0
            besucherzahl = 8000
        Case InStr(eventLower, "meistersingerhalle") > 0
            besucherzahl = 2100
        Case InStr(eventLower, "hirsch") > 0
            besucherzahl = 450
        Case InStr(eventLower, "z-bau") > 0
            besucherzahl = 800
        Case InStr(eventLower, "rock im park") > 0
            besucherzahl = 70000

        ' Konzert-Locations Muenchen
        Case InStr(eventLower, "olympiahalle") > 0
            besucherzahl = 12500
        Case InStr(eventLower, "zenith") > 0
            besucherzahl = 5800
        Case InStr(eventLower, "backstage") > 0
            besucherzahl = 1500

        ' Event-Typen
        Case InStr(eventLower, "konzert") > 0
            besucherzahl = 5000  ' Durchschnitt
        Case InStr(eventLower, "messe") > 0
            besucherzahl = 10000
        Case InStr(eventLower, "festival") > 0
            besucherzahl = 30000
        Case InStr(eventLower, "kongress") > 0
            besucherzahl = 1000
        Case InStr(eventLower, "firmenfeier") > 0
            besucherzahl = 300
        Case InStr(eventLower, "hochzeit") > 0
            besucherzahl = 100

        Case Else
            besucherzahl = 0  ' Unbekannt
    End Select

    GetEventBesucherzahl = besucherzahl
    Exit Function

ErrorHandler:
    GetEventBesucherzahl = 0
End Function

' ========================================================================
' 3. RESSOURCEN-UEBERSICHT
' ========================================================================

' ------------------------------------------------------------------------
' GetEventRessourcen: MA geplant vs. gebucht, Positionen-Status
' Return: JSON-String
' ------------------------------------------------------------------------
Public Function GetEventRessourcen(VA_ID As Long) As String
    On Error GoTo ErrorHandler

    Dim rs As DAO.Recordset
    Dim sql As String
    Dim json As String

    Dim MA_Geplant As Integer
    Dim MA_Gebucht As Integer
    Dim Positionen_Offen As Integer
    Dim Positionen_Besetzt As Integer
    Dim Schichten_Anzahl As Integer

    ' Schichten und MA-Bedarf aus tbl_VA_Start
    sql = "SELECT COUNT(*) AS AnzahlSchichten, " & _
          "SUM(Nz(MA_Anzahl, 0)) AS MA_Geplant, " & _
          "SUM(Nz(MA_Anzahl_Ist, 0)) AS MA_Gebucht " & _
          "FROM tbl_VA_Start " & _
          "WHERE VA_ID = " & VA_ID

    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)

    If Not rs.EOF Then
        Schichten_Anzahl = Nz(rs!AnzahlSchichten, 0)
        MA_Geplant = Nz(rs!MA_Geplant, 0)
        MA_Gebucht = Nz(rs!MA_Gebucht, 0)
    End If
    rs.Close

    ' Positionen berechnen
    Positionen_Besetzt = MA_Gebucht
    Positionen_Offen = MA_Geplant - MA_Gebucht
    If Positionen_Offen < 0 Then Positionen_Offen = 0

    ' Detaillierte Schicht-Infos laden
    Dim schichtenJSON As String
    schichtenJSON = GetSchichtenDetails(VA_ID)

    ' JSON zusammenbauen
    json = "{"
    json = json & """MA_Geplant"":" & MA_Geplant & ","
    json = json & """MA_Gebucht"":" & MA_Gebucht & ","
    json = json & """Positionen_Offen"":" & Positionen_Offen & ","
    json = json & """Positionen_Besetzt"":" & Positionen_Besetzt & ","
    json = json & """Schichten_Anzahl"":" & Schichten_Anzahl & ","
    json = json & """Auslastung_Prozent"":" & IIf(MA_Geplant > 0, Round((MA_Gebucht / MA_Geplant) * 100, 1), 0) & ","
    json = json & """Schichten"":" & schichtenJSON
    json = json & "}"

    GetEventRessourcen = json
    Exit Function

ErrorHandler:
    GetEventRessourcen = "{""Fehler"":""" & EscapeJSON(Err.Description) & """}"
End Function

' ------------------------------------------------------------------------
' GetSchichtenDetails: Detaillierte Schicht-Informationen
' ------------------------------------------------------------------------
Private Function GetSchichtenDetails(VA_ID As Long) As String
    On Error GoTo ErrorHandler

    Dim rs As DAO.Recordset
    Dim sql As String
    Dim json As String
    Dim isFirst As Boolean

    sql = "SELECT VAStart_ID, VADatum, VA_Start, VA_Ende, MA_Anzahl, MA_Anzahl_Ist " & _
          "FROM tbl_VA_Start " & _
          "WHERE VA_ID = " & VA_ID & " " & _
          "ORDER BY VADatum, VA_Start"

    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)

    json = "["
    isFirst = True

    Do Until rs.EOF
        If Not isFirst Then json = json & ","
        isFirst = False

        json = json & "{"
        json = json & """VAStart_ID"":" & Nz(rs!VAStart_ID, 0) & ","
        json = json & """VADatum"":""" & Format(Nz(rs!VADatum, Date), "yyyy-mm-dd") & ""","
        json = json & """VA_Start"":""" & FormatTime(rs!VA_Start) & ""","
        json = json & """VA_Ende"":""" & FormatTime(rs!VA_Ende) & ""","
        json = json & """MA_Anzahl"":" & Nz(rs!MA_Anzahl, 0) & ","
        json = json & """MA_Anzahl_Ist"":" & Nz(rs!MA_Anzahl_Ist, 0) & ","
        json = json & """Offen"":" & (Nz(rs!MA_Anzahl, 0) - Nz(rs!MA_Anzahl_Ist, 0))
        json = json & "}"

        rs.MoveNext
    Loop

    json = json & "]"

    rs.Close
    Set rs = Nothing

    GetSchichtenDetails = json
    Exit Function

ErrorHandler:
    GetSchichtenDetails = "[]"
End Function

' ========================================================================
' 4. NOTIZEN
' ========================================================================

' ------------------------------------------------------------------------
' SaveEventNotiz: Speichert Event-Notiz
' Nutzt Feld Event_Notizen in tbl_VA_Auftragstamm (wird ggf. erstellt)
' ------------------------------------------------------------------------
Public Sub SaveEventNotiz(VA_ID As Long, Notiz As String)
    On Error GoTo ErrorHandler

    ' Pruefen ob Feld existiert, sonst erstellen
    If Not FieldExists("tbl_VA_Auftragstamm", "Event_Notizen") Then
        CreateEventNotizenField
    End If

    ' Notiz speichern
    Dim sql As String
    sql = "UPDATE tbl_VA_Auftragstamm SET Event_Notizen = " & QuoteString(Notiz) & " " & _
          "WHERE VA_ID = " & VA_ID

    CurrentDb.Execute sql, dbFailOnError

    Exit Sub

ErrorHandler:
    MsgBox "Fehler beim Speichern der Notiz: " & Err.Description, vbExclamation
End Sub

' ------------------------------------------------------------------------
' GetEventNotiz: Laedt Event-Notiz
' ------------------------------------------------------------------------
Public Function GetEventNotiz(VA_ID As Long) As String
    On Error GoTo ErrorHandler

    ' Pruefen ob Feld existiert
    If Not FieldExists("tbl_VA_Auftragstamm", "Event_Notizen") Then
        GetEventNotiz = ""
        Exit Function
    End If

    Dim rs As DAO.Recordset
    Dim sql As String

    sql = "SELECT Event_Notizen FROM tbl_VA_Auftragstamm WHERE VA_ID = " & VA_ID
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)

    If Not rs.EOF Then
        GetEventNotiz = Nz(rs!Event_Notizen, "")
    Else
        GetEventNotiz = ""
    End If

    rs.Close
    Set rs = Nothing
    Exit Function

ErrorHandler:
    GetEventNotiz = ""
End Function

' ------------------------------------------------------------------------
' CreateEventNotizenField: Erstellt Event_Notizen Feld in tbl_VA_Auftragstamm
' ------------------------------------------------------------------------
Private Sub CreateEventNotizenField()
    On Error Resume Next

    Dim db As DAO.Database
    Dim tbl As DAO.TableDef
    Dim fld As DAO.Field

    Set db = CurrentDb
    Set tbl = db.TableDefs("tbl_VA_Auftragstamm")

    Set fld = tbl.CreateField("Event_Notizen", dbMemo)
    tbl.Fields.Append fld

    tbl.Fields.Refresh

    Set fld = Nothing
    Set tbl = Nothing
    Set db = Nothing
End Sub

' ========================================================================
' HILFSFUNKTIONEN
' ========================================================================

' ------------------------------------------------------------------------
' FieldExists: Prueft ob Feld in Tabelle existiert
' ------------------------------------------------------------------------
Private Function FieldExists(tableName As String, fieldName As String) As Boolean
    On Error Resume Next
    Dim fld As DAO.Field
    Set fld = CurrentDb.TableDefs(tableName).Fields(fieldName)
    FieldExists = (Err.Number = 0)
    Set fld = Nothing
    On Error GoTo 0
End Function

' ------------------------------------------------------------------------
' TableExists: Prueft ob Tabelle existiert
' ------------------------------------------------------------------------
Private Function TableExists(tableName As String) As Boolean
    On Error Resume Next
    Dim tbl As DAO.TableDef
    Set tbl = CurrentDb.TableDefs(tableName)
    TableExists = (Err.Number = 0)
    Set tbl = Nothing
    On Error GoTo 0
End Function

' ------------------------------------------------------------------------
' FormatTime: Formatiert Zeit-Wert
' ------------------------------------------------------------------------
Private Function FormatTime(timeValue As Variant) As String
    If IsNull(timeValue) Then
        FormatTime = ""
    ElseIf IsDate(timeValue) Then
        FormatTime = Format(timeValue, "hh:nn")
    Else
        FormatTime = CStr(timeValue)
    End If
End Function

' ------------------------------------------------------------------------
' EscapeJSON: Escaped Sonderzeichen fuer JSON
' ------------------------------------------------------------------------
Private Function EscapeJSON(Text As String) As String
    Dim result As String
    result = Text
    result = Replace(result, "\", "\\")
    result = Replace(result, """", "\""")
    result = Replace(result, vbCr, "")
    result = Replace(result, vbLf, "\n")
    result = Replace(result, vbTab, "\t")
    EscapeJSON = result
End Function

' ------------------------------------------------------------------------
' QuoteString: Quoted String fuer SQL
' ------------------------------------------------------------------------
Private Function QuoteString(Text As String) As String
    QuoteString = "'" & Replace(Text, "'", "''") & "'"
End Function

' ------------------------------------------------------------------------
' BuildErrorJSON: Erstellt Fehler-JSON
' ------------------------------------------------------------------------
Private Function BuildErrorJSON(errorMsg As String) As String
    BuildErrorJSON = "{""Erfolgreich"":false,""Fehlermeldung"":""" & EscapeJSON(errorMsg) & """}"
End Function

' ------------------------------------------------------------------------
' URLEncode: URL-Encoding fuer HTTP-Requests
' ------------------------------------------------------------------------
Private Function URLEncode(Text As String) As String
    Dim i As Integer
    Dim char As String
    Dim result As String

    For i = 1 To Len(Text)
        char = Mid(Text, i, 1)
        Select Case char
            Case "A" To "Z", "a" To "z", "0" To "9", "-", "_", ".", "~"
                result = result & char
            Case " "
                result = result & "+"
            Case Else
                result = result & "%" & Right("0" & Hex(Asc(char)), 2)
        End Select
    Next i

    URLEncode = result
End Function

' ------------------------------------------------------------------------
' ExtractJSONValue: Extrahiert Wert aus JSON
' ------------------------------------------------------------------------
Private Function ExtractJSONValue(json As String, Key As String) As String
    On Error Resume Next

    Dim pos As Long
    Dim endPos As Long
    Dim value As String

    pos = InStr(json, Key)
    If pos = 0 Then
        ExtractJSONValue = ""
        Exit Function
    End If

    pos = pos + Len(Key)

    ' String oder Nummer?
    If Mid(json, pos, 1) = """" Then
        pos = pos + 1
        endPos = InStr(pos, json, """")
        If endPos > pos Then
            value = Mid(json, pos, endPos - pos)
        End If
    Else
        ' Nummer bis zum naechsten Komma oder }
        endPos = InStr(pos, json, ",")
        If endPos = 0 Then endPos = InStr(pos, json, "}")
        If endPos > pos Then
            value = Trim(Mid(json, pos, endPos - pos))
        End If
    End If

    ExtractJSONValue = value
End Function

' ------------------------------------------------------------------------
' CleanCityName: Bereinigt Stadtnamen fuer API
' ------------------------------------------------------------------------
Private Function CleanCityName(Ort As String) As String
    Dim city As String
    city = Trim(Ort)

    ' Nur Stadt-Teil (vor Komma oder Bindestrich)
    If InStr(city, ",") > 0 Then
        city = Left(city, InStr(city, ",") - 1)
    End If

    ' Postleitzahl entfernen
    Dim regex As Object
    Set regex = CreateObject("VBScript.RegExp")
    regex.Pattern = "^\d{5}\s*"
    regex.Global = False
    city = regex.Replace(city, "")

    ' Ortsteil entfernen (nach Bindestrich)
    If InStr(city, "-") > 0 Then
        city = Left(city, InStr(city, "-") - 1)
    End If

    Set regex = Nothing
    CleanCityName = Trim(city)
End Function

' ========================================================================
' TEST-FUNKTIONEN
' ========================================================================

' ------------------------------------------------------------------------
' TestEventInfo: Testet GetEventInfo
' ------------------------------------------------------------------------
Public Sub TestEventInfo(VA_ID As Long)
    Dim json As String
    json = GetEventInfo(VA_ID)

    Debug.Print "=== Event Info fuer VA_ID " & VA_ID & " ==="
    Debug.Print json
End Sub

' ------------------------------------------------------------------------
' TestEventRessourcen: Testet GetEventRessourcen
' ------------------------------------------------------------------------
Public Sub TestEventRessourcen(VA_ID As Long)
    Dim json As String
    json = GetEventRessourcen(VA_ID)

    Debug.Print "=== Ressourcen fuer VA_ID " & VA_ID & " ==="
    Debug.Print json
End Sub

' ------------------------------------------------------------------------
' TestEventNotizen: Testet Notizen-Funktionen
' ------------------------------------------------------------------------
Public Sub TestEventNotizen(VA_ID As Long)
    ' Notiz speichern
    SaveEventNotiz VA_ID, "Test-Notiz vom " & Format(Now, "dd.mm.yyyy hh:nn:ss")

    ' Notiz laden
    Dim notiz As String
    notiz = GetEventNotiz(VA_ID)

    Debug.Print "=== Notiz fuer VA_ID " & VA_ID & " ==="
    Debug.Print notiz
End Sub

' ------------------------------------------------------------------------
' TestBesucherzahl: Testet Besucherzahl-Schaetzung
' ------------------------------------------------------------------------
Public Sub TestBesucherzahl()
    Debug.Print "=== Besucherzahl-Tests ==="
    Debug.Print "FCN vs Bayern: " & GetEventBesucherzahl("1.FCN - Bayern")
    Debug.Print "Konzert Arena: " & GetEventBesucherzahl("Konzert Arena Nuernberg")
    Debug.Print "Rock im Park: " & GetEventBesucherzahl("Rock im Park 2026")
    Debug.Print "Firmenfeier: " & GetEventBesucherzahl("Firmenfeier XYZ GmbH")
    Debug.Print "Unbekannt: " & GetEventBesucherzahl("Irgendwas")
End Sub

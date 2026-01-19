Attribute VB_Name = "mod_N_EventDaten"
' ========================================================================
' Modul: mod_N_EventDaten
' Zweck: Web-Scraping von Event-Daten aus oeffentlichen Quellen
' Erstellt: 2026-01-03
' Korrigiert: 2026-01-05
' ========================================================================

' ========================================================================
' Type Definitionen
' ========================================================================
Public Type EventDaten
    VA_ID As Long
    Einlass As String
    Beginn As String
    Ende As String
    Infos As String
    WebLink As String
    Erfolgreich As Boolean
    Fehlermeldung As String
End Type

' ========================================================================
' Hauptfunktion: HoleEventDatenAusWeb
' ========================================================================
Public Function HoleEventDatenAusWeb(VA_ID As Long) As EventDaten
    On Error GoTo ErrorHandler

    Dim result As EventDaten
    result.VA_ID = VA_ID
    result.Erfolgreich = False

    ' Schritt 1: Auftragsdaten aus DB laden
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim suchbegriff As String
    Dim Auftrag As String, Objekt As String, Ort As String, Datum As String, kunde As String

    sql = "SELECT a.Auftrag, a.Objekt, a.Ort, a.Dat_VA_Von, k.kun_Firma " & _
          "FROM tbl_VA_Auftragstamm a " & _
          "LEFT JOIN tbl_KD_Kundenstamm k ON a.Veranstalter_ID = k.kun_Id " & _
          "WHERE a.VA_ID = " & VA_ID

    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)

    If rs.EOF Then
        result.Fehlermeldung = "VA_ID nicht gefunden"
        GoTo Cleanup
    End If

    ' Suchbegriffe zusammenstellen
    Auftrag = Nz(rs!Auftrag, "")
    Objekt = Nz(rs!Objekt, "")
    Ort = Nz(rs!Ort, "")
    Datum = IIf(IsNull(rs!Dat_VA_Von), "", Format(rs!Dat_VA_Von, "dd.mm.yyyy"))
    kunde = Nz(rs!kun_Firma, "")

    rs.Close
    Set rs = Nothing

    ' Suchbegriff aufbauen
    suchbegriff = Trim(Auftrag & " " & Objekt & " " & Ort & " " & Datum & " " & kunde)

    If Len(suchbegriff) < 5 Then
        result.Fehlermeldung = "Zu wenige Informationen fuer Suche"
        GoTo Cleanup
    End If

    ' Schritt 2: Web-Suche durchfuehren
    Dim htmlContent As String
    htmlContent = WebSuche(suchbegriff)

    If Len(htmlContent) = 0 Then
        result.Fehlermeldung = "Keine Websuche-Ergebnisse gefunden"
        GoTo Cleanup
    End If

    ' Schritt 3: Event-Webseiten extrahieren und parsen
    Dim eventLinks As Collection
    Set eventLinks = ExtrahiereEventLinks(htmlContent)

    If eventLinks.Count = 0 Then
        result.Fehlermeldung = "Keine Event-Webseiten gefunden"
        GoTo Cleanup
    End If

    ' Ersten relevanten Link parsen
    Dim i As Integer
    For i = 1 To eventLinks.Count
        Dim eventData As EventDaten
        eventData = ParseEventWebseite(CStr(eventLinks(i)))

        If eventData.Erfolgreich Then
            result = eventData
            result.VA_ID = VA_ID
            Exit For
        End If
    Next i

    If Not result.Erfolgreich Then
        result.Fehlermeldung = "Keine verwertbaren Event-Daten gefunden"
    End If

Cleanup:
    If Not rs Is Nothing Then
        If rs.State = 1 Then rs.Close
        Set rs = Nothing
    End If
    HoleEventDatenAusWeb = result
    Exit Function

ErrorHandler:
    result.Erfolgreich = False
    result.Fehlermeldung = "Fehler: " & Err.Description
    Resume Cleanup
End Function

' ========================================================================
' WebSuche: Fuehrt Google/Bing-Suche durch
' ========================================================================
Private Function WebSuche(suchbegriff As String) As String
    On Error GoTo ErrorHandler

    Dim http As Object
    Dim url As String
    Dim encodedQuery As String
    Dim response As String

    ' URL-Encoding fuer Suchbegriff
    encodedQuery = URLEncode(suchbegriff)

    ' Google-Suche (primaer)
    url = "https://www.google.com/search?q=" & encodedQuery & "+event+tickets"

    ' MSXML2.XMLHTTP60 fuer moderne TLS-Unterstuetzung
    Set http = CreateObject("MSXML2.ServerXMLHTTP.6.0")

    http.Open "GET", url, False
    http.setRequestHeader "User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    http.setRequestHeader "Accept", "text/html"
    http.setTimeouts 5000, 5000, 10000, 10000  ' 10 Sekunden Timeout

    http.Send

    If http.Status = 200 Then
        response = http.responseText
    Else
        response = ""
    End If

    Set http = Nothing
    WebSuche = response
    Exit Function

ErrorHandler:
    WebSuche = ""
    If Not http Is Nothing Then Set http = Nothing
End Function

' ========================================================================
' ExtrahiereEventLinks: Findet Event-Webseiten in HTML
' ========================================================================
Private Function ExtrahiereEventLinks(htmlContent As String) As Collection
    Dim links As New Collection
    Dim pos As Long, startPos As Long, endPos As Long
    Dim link As String
    Dim i As Integer

    ' Bekannte Event-Websites
    Dim knownSites As Variant
    knownSites = Array("eventim.de", "ticketmaster.de", "eventbrite.de", _
                       "reservix.de", "ticketmaster.com", "eventbrite.com", _
                       "tickets.de", "adticket.de", "myticket.de", _
                       "olympiapark.de", "olympiahalle-muenchen.de", _
                       "o2world.de", "lanxess-arena.de")

    ' HTML nach Links durchsuchen
    pos = 1
    Do While pos > 0
        pos = InStr(pos, htmlContent, "href=""http", vbTextCompare)
        If pos > 0 Then
            startPos = pos + 6
            endPos = InStr(startPos, htmlContent, """")

            If endPos > startPos Then
                link = Mid(htmlContent, startPos, endPos - startPos)

                ' Pruefen ob Link von bekannter Event-Seite
                For i = LBound(knownSites) To UBound(knownSites)
                    If InStr(1, link, knownSites(i), vbTextCompare) > 0 Then
                        On Error Resume Next
                        links.Add link, link  ' Key=link verhindert Duplikate
                        On Error GoTo 0
                        Exit For
                    End If
                Next i

                pos = endPos
            Else
                pos = 0
            End If
        End If
    Loop

    Set ExtrahiereEventLinks = links
End Function

' ========================================================================
' ParseEventWebseite: Extrahiert strukturierte Daten von Event-Seiten
' ========================================================================
Public Function ParseEventWebseite(url As String) As EventDaten
    On Error GoTo ErrorHandler

    Dim result As EventDaten
    result.Erfolgreich = False
    result.WebLink = url

    ' HTML-Inhalt laden
    Dim http As Object
    Set http = CreateObject("MSXML2.ServerXMLHTTP.6.0")

    http.Open "GET", url, False
    http.setRequestHeader "User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    http.setTimeouts 5000, 5000, 10000, 10000

    http.Send

    If http.Status <> 200 Then
        result.Fehlermeldung = "HTTP " & http.Status
        GoTo Cleanup
    End If

    Dim html As String
    html = http.responseText

    ' Parser-Strategie basierend auf Domain
    Select Case True
        Case InStr(url, "eventim.de") > 0
            result = ParseEventim(html, url)
        Case InStr(url, "ticketmaster.de") > 0
            result = ParseTicketmaster(html, url)
        Case InStr(url, "eventbrite.de") > 0
            result = ParseEventbrite(html, url)
        Case Else
            result = ParseGeneric(html, url)
    End Select

Cleanup:
    Set http = Nothing
    ParseEventWebseite = result
    Exit Function

ErrorHandler:
    result.Erfolgreich = False
    result.Fehlermeldung = "Fehler beim Parsen: " & Err.Description
    Resume Cleanup
End Function

' ========================================================================
' ParseEventim: Parser fuer eventim.de
' ========================================================================
Private Function ParseEventim(html As String, url As String) As EventDaten
    Dim result As EventDaten
    result.WebLink = url

    ' Eventim verwendet oft JSON-LD fuer strukturierte Daten
    result.Beginn = ExtractPattern(html, """startDate"":""([^""]+)""")
    result.Ende = ExtractPattern(html, """endDate"":""([^""]+)""")
    result.Einlass = ExtractPattern(html, """doorTime"":""([^""]+)""")

    ' Fallback: HTML-Parsing
    If Len(result.Beginn) = 0 Then
        result.Beginn = ExtractPattern(html, "Beginn:?\s*(\d{2}:\d{2})")
    End If

    result.Infos = ExtractPattern(html, "<meta name=""description"" content=""([^""]+)""")
    result.Erfolgreich = (Len(result.Beginn) > 0)

    ParseEventim = result
End Function

' ========================================================================
' ParseTicketmaster: Parser fuer ticketmaster.de
' ========================================================================
Private Function ParseTicketmaster(html As String, url As String) As EventDaten
    Dim result As EventDaten
    result.WebLink = url

    result.Beginn = ExtractPattern(html, """startDateTime"":""([^""]+)""")
    result.Ende = ExtractPattern(html, """endDateTime"":""([^""]+)""")
    result.Einlass = ExtractPattern(html, "Einlass:?\s*(\d{2}:\d{2})")
    result.Infos = ExtractPattern(html, "<meta property=""og:description"" content=""([^""]+)""")
    result.Erfolgreich = (Len(result.Beginn) > 0)

    ParseTicketmaster = result
End Function

' ========================================================================
' ParseEventbrite: Parser fuer eventbrite.de
' ========================================================================
Private Function ParseEventbrite(html As String, url As String) As EventDaten
    Dim result As EventDaten
    result.WebLink = url

    result.Beginn = ExtractPattern(html, """start"":\{""local"":""([^""]+)""")
    result.Ende = ExtractPattern(html, """end"":\{""local"":""([^""]+)""")
    result.Infos = ExtractPattern(html, "<meta name=""description"" content=""([^""]+)""")
    result.Erfolgreich = (Len(result.Beginn) > 0)

    ParseEventbrite = result
End Function

' ========================================================================
' ParseGeneric: Generischer Parser fuer unbekannte Seiten
' ========================================================================
Private Function ParseGeneric(html As String, url As String) As EventDaten
    Dim result As EventDaten
    result.WebLink = url

    ' Generisches Parsing: Schema.org JSON-LD
    result.Beginn = ExtractPattern(html, """startDate"":""([^""]+)""")
    result.Ende = ExtractPattern(html, """endDate"":""([^""]+)""")

    ' Fallback: Textmuster
    If Len(result.Beginn) = 0 Then
        result.Beginn = ExtractPattern(html, "(?:Beginn|Start|Begin):?\s*(\d{2}:\d{2})")
    End If

    If Len(result.Ende) = 0 Then
        result.Ende = ExtractPattern(html, "(?:Ende|End):?\s*(\d{2}:\d{2})")
    End If

    If Len(result.Einlass) = 0 Then
        result.Einlass = ExtractPattern(html, "(?:Einlass|Doors):?\s*(\d{2}:\d{2})")
    End If

    result.Infos = ExtractPattern(html, "<meta name=""description"" content=""([^""]+)""")
    result.Erfolgreich = (Len(result.Beginn) > 0)

    ParseGeneric = result
End Function

' ========================================================================
' ExtractPattern: Regex-basierte Musterextraktion
' ========================================================================
Private Function ExtractPattern(Text As String, pattern As String) As String
    On Error Resume Next

    Dim regex As Object
    Set regex = CreateObject("VBScript.RegExp")

    regex.pattern = pattern
    regex.IgnoreCase = True
    regex.MultiLine = True
    regex.Global = False

    Dim matches As Object
    Set matches = regex.Execute(Text)

    If matches.Count > 0 Then
        If matches(0).SubMatches.Count > 0 Then
            ExtractPattern = matches(0).SubMatches(0)
        Else
            ExtractPattern = matches(0).Value
        End If
    Else
        ExtractPattern = ""
    End If

    Set matches = Nothing
    Set regex = Nothing
End Function

' ========================================================================
' SpeichereEventDaten: Speichert Event-Daten in Tabelle
' ========================================================================
Public Function SpeichereEventDaten(eventData As EventDaten) As Boolean
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = CurrentDb

    ' Pruefen ob Tabelle existiert
    If Not TableExists("tbl_N_VA_EventDaten") Then
        CreateEventDatenTable
    End If

    ' Pruefen ob bereits Eintrag existiert
    sql = "SELECT * FROM tbl_N_VA_EventDaten WHERE VA_ID = " & eventData.VA_ID
    Set rs = db.OpenRecordset(sql, dbOpenDynaset)

    If rs.EOF Then
        rs.AddNew
    Else
        rs.Edit
    End If

    rs!VA_ID = eventData.VA_ID
    rs!Einlass = Left(eventData.Einlass, 50)
    rs!Beginn = Left(eventData.Beginn, 50)
    rs!Ende = Left(eventData.Ende, 50)
    rs!Infos = Left(eventData.Infos, 255)
    rs!WebLink = Left(eventData.WebLink, 255)
    rs!LetzteAktualisierung = Now
    rs!Erfolgreich = eventData.Erfolgreich
    rs!Fehlermeldung = Left(eventData.Fehlermeldung, 255)

    rs.Update
    rs.Close
    Set rs = Nothing
    Set db = Nothing

    SpeichereEventDaten = True
    Exit Function

ErrorHandler:
    SpeichereEventDaten = False
    If Not rs Is Nothing Then
        If rs.State = 1 Then rs.Close
        Set rs = Nothing
    End If
    Set db = Nothing
End Function

' ========================================================================
' CreateEventDatenTable: Erstellt tbl_N_VA_EventDaten
' ========================================================================
Private Sub CreateEventDatenTable()
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim tbl As DAO.TableDef
    Dim fld As DAO.Field

    Set db = CurrentDb
    Set tbl = db.CreateTableDef("tbl_N_VA_EventDaten")

    ' Felder definieren
    Set fld = tbl.CreateField("ID", dbLong)
    fld.Attributes = dbAutoIncrField
    tbl.Fields.Append fld

    tbl.Fields.Append tbl.CreateField("VA_ID", dbLong)
    tbl.Fields.Append tbl.CreateField("Einlass", dbText, 50)
    tbl.Fields.Append tbl.CreateField("Beginn", dbText, 50)
    tbl.Fields.Append tbl.CreateField("Ende", dbText, 50)
    tbl.Fields.Append tbl.CreateField("Infos", dbText, 255)
    tbl.Fields.Append tbl.CreateField("WebLink", dbText, 255)
    tbl.Fields.Append tbl.CreateField("LetzteAktualisierung", dbDate)
    tbl.Fields.Append tbl.CreateField("Erfolgreich", dbBoolean)
    tbl.Fields.Append tbl.CreateField("Fehlermeldung", dbText, 255)

    db.TableDefs.Append tbl

    ' Primaerschluessel
    Dim idx As DAO.Index
    Set idx = tbl.CreateIndex("PrimaryKey")
    idx.Primary = True
    idx.Fields.Append idx.CreateField("ID")
    tbl.Indexes.Append idx

    ' Index auf VA_ID
    Set idx = tbl.CreateIndex("VA_ID_Index")
    idx.Fields.Append idx.CreateField("VA_ID")
    tbl.Indexes.Append idx

    Set fld = Nothing
    Set tbl = Nothing
    Set db = Nothing
    Exit Sub

ErrorHandler:
    ' Tabelle existiert bereits oder anderer Fehler
End Sub

' ========================================================================
' Hilfsfunktionen
' ========================================================================
Private Function TableExists(tableName As String) As Boolean
    On Error Resume Next
    Dim tbl As DAO.TableDef
    Set tbl = CurrentDb.TableDefs(tableName)
    TableExists = (Err.Number = 0)
    Set tbl = Nothing
    On Error GoTo 0
End Function

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

' ========================================================================
' Test-Funktion
' ========================================================================
Public Sub TestEventDaten(VA_ID As Long)
    Dim eventData As EventDaten

    eventData = HoleEventDatenAusWeb(VA_ID)

    If eventData.Erfolgreich Then
        SpeichereEventDaten eventData
        MsgBox "Event-Daten erfolgreich geladen und gespeichert!" & vbCrLf & _
               "Beginn: " & eventData.Beginn & vbCrLf & _
               "Ende: " & eventData.Ende & vbCrLf & _
               "Einlass: " & eventData.Einlass, vbInformation
    Else
        MsgBox "Keine Event-Daten gefunden: " & eventData.Fehlermeldung, vbExclamation
    End If
End Sub

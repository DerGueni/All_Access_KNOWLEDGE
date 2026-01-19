Attribute VB_Name = "mod_N_MA_QuickInfo"
Option Compare Database
Option Explicit

'===============================================================================
' Modul: mod_N_MA_QuickInfo
' Beschreibung: Funktionen fuer Quick Info Tab im Mitarbeiterstamm
' Autor: Claude Code Generator
' Datum: 05.01.2026
' Version: 1.0
'===============================================================================

' Konstanten
Private Const MODULE_NAME As String = "mod_N_MA_QuickInfo"

'===============================================================================
' STATISTIK-FUNKTIONEN
'===============================================================================

'-------------------------------------------------------------------------------
' GetMA_EinsaetzeJahr
' Zaehlt die Einsaetze des Mitarbeiters im laufenden Jahr
'
' Parameter:
'   MA_ID - Die ID des Mitarbeiters
'
' Rueckgabe:
'   Anzahl der Einsaetze im laufenden Jahr
'-------------------------------------------------------------------------------
Public Function GetMA_EinsaetzeJahr(MA_ID As Long) As Long
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim lngResult As Long

    ' Initialisierung
    lngResult = 0

    ' SQL-Abfrage: Zaehle Einsaetze im laufenden Jahr
    strSQL = "SELECT COUNT(*) AS AnzahlEinsaetze " & _
             "FROM tbl_MA_VA_Zuordnung " & _
             "WHERE MA_ID = " & MA_ID & " " & _
             "AND Year(VADatum) = Year(Date())"

    Set db = CurrentDb()
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)

    If Not rs.EOF Then
        If Not IsNull(rs!AnzahlEinsaetze) Then
            lngResult = rs!AnzahlEinsaetze
        End If
    End If

Cleanup:
    If Not rs Is Nothing Then
        rs.Close
        Set rs = Nothing
    End If
    Set db = Nothing

    GetMA_EinsaetzeJahr = lngResult
    Exit Function

ErrorHandler:
    LogError MODULE_NAME, "GetMA_EinsaetzeJahr", Err.Number, Err.Description
    Resume Cleanup
End Function

'-------------------------------------------------------------------------------
' GetMA_StundenJahr
' Summiert die Arbeitsstunden des Mitarbeiters im laufenden Jahr
'
' Parameter:
'   MA_ID - Die ID des Mitarbeiters
'
' Rueckgabe:
'   Gesamtstunden im laufenden Jahr (als Double)
'-------------------------------------------------------------------------------
Public Function GetMA_StundenJahr(MA_ID As Long) As Double
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim dblResult As Double

    ' Initialisierung
    dblResult = 0#

    ' SQL-Abfrage: Summiere Stunden im laufenden Jahr
    ' DateDiff("n",...) gibt Minuten zurueck, Division durch 60 fuer Stunden
    strSQL = "SELECT SUM(DateDiff('n', VA_Start, VA_Ende) / 60) AS GesamtStunden " & _
             "FROM tbl_MA_VA_Zuordnung " & _
             "WHERE MA_ID = " & MA_ID & " " & _
             "AND Year(VADatum) = Year(Date()) " & _
             "AND VA_Start IS NOT NULL " & _
             "AND VA_Ende IS NOT NULL"

    Set db = CurrentDb()
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)

    If Not rs.EOF Then
        If Not IsNull(rs!GesamtStunden) Then
            dblResult = rs!GesamtStunden
        End If
    End If

Cleanup:
    If Not rs Is Nothing Then
        rs.Close
        Set rs = Nothing
    End If
    Set db = Nothing

    GetMA_StundenJahr = dblResult
    Exit Function

ErrorHandler:
    LogError MODULE_NAME, "GetMA_StundenJahr", Err.Number, Err.Description
    Resume Cleanup
End Function

'-------------------------------------------------------------------------------
' GetMA_Zuverlaessigkeit
' Berechnet die Zuverlaessigkeit: (Einsaetze - Absagen) / Einsaetze * 100
'
' Parameter:
'   MA_ID - Die ID des Mitarbeiters
'
' Rueckgabe:
'   Zuverlaessigkeit in Prozent (0-100)
'-------------------------------------------------------------------------------
Public Function GetMA_Zuverlaessigkeit(MA_ID As Long) As Double
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim lngEinsaetze As Long
    Dim lngAbsagen As Long
    Dim dblResult As Double

    ' Initialisierung
    dblResult = 100#  ' Default: 100% wenn keine Daten
    lngEinsaetze = 0
    lngAbsagen = 0

    Set db = CurrentDb()

    ' Gesamtzahl der Einsaetze (alle Status)
    strSQL = "SELECT COUNT(*) AS Anzahl " & _
             "FROM tbl_MA_VA_Zuordnung " & _
             "WHERE MA_ID = " & MA_ID

    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)

    If Not rs.EOF Then
        If Not IsNull(rs!Anzahl) Then
            lngEinsaetze = rs!Anzahl
        End If
    End If
    rs.Close

    ' Falls keine Einsaetze vorhanden, 100% zurueckgeben
    If lngEinsaetze = 0 Then
        GoTo Cleanup
    End If

    ' Anzahl der Absagen zaehlen
    ' Status fuer Absagen: "Abgesagt", "Storniert", "Absage" oder entsprechender Status-Code
    strSQL = "SELECT COUNT(*) AS Anzahl " & _
             "FROM tbl_MA_VA_Zuordnung " & _
             "WHERE MA_ID = " & MA_ID & " " & _
             "AND (Status = 'Abgesagt' " & _
             "     OR Status = 'Storniert' " & _
             "     OR Status = 'Absage' " & _
             "     OR Status LIKE '*absag*' " & _
             "     OR Absage = True)"

    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)

    If Not rs.EOF Then
        If Not IsNull(rs!Anzahl) Then
            lngAbsagen = rs!Anzahl
        End If
    End If

    ' Zuverlaessigkeit berechnen
    dblResult = ((lngEinsaetze - lngAbsagen) / lngEinsaetze) * 100

    ' Auf 2 Nachkommastellen runden
    dblResult = Round(dblResult, 2)

Cleanup:
    If Not rs Is Nothing Then
        rs.Close
        Set rs = Nothing
    End If
    Set db = Nothing

    GetMA_Zuverlaessigkeit = dblResult
    Exit Function

ErrorHandler:
    LogError MODULE_NAME, "GetMA_Zuverlaessigkeit", Err.Number, Err.Description
    Resume Cleanup
End Function

'-------------------------------------------------------------------------------
' GetMA_Rating
' Ermittelt das durchschnittliche Rating aus Bewertungen
'
' Parameter:
'   MA_ID - Die ID des Mitarbeiters
'
' Rueckgabe:
'   Durchschnittliches Rating (z.B. 1-5 Sterne)
'   Gibt 0 zurueck wenn keine Bewertungen vorhanden oder Tabelle nicht existiert
'-------------------------------------------------------------------------------
Public Function GetMA_Rating(MA_ID As Long) As Double
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim dblResult As Double

    ' Initialisierung
    dblResult = 0#

    Set db = CurrentDb()

    ' Pruefen ob Tabelle tbl_MA_Bewertung existiert
    If Not TableExists("tbl_MA_Bewertung") Then
        ' Tabelle existiert nicht - alternative Tabelle versuchen
        If TableExists("tbl_MA_Rating") Then
            strSQL = "SELECT AVG(Rating) AS DurchschnittRating " & _
                     "FROM tbl_MA_Rating " & _
                     "WHERE MA_ID = " & MA_ID
        Else
            ' Keine Bewertungstabelle vorhanden
            GoTo Cleanup
        End If
    Else
        ' Haupttabelle verwenden
        strSQL = "SELECT AVG(Bewertung) AS DurchschnittRating " & _
                 "FROM tbl_MA_Bewertung " & _
                 "WHERE MA_ID = " & MA_ID
    End If

    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)

    If Not rs.EOF Then
        If Not IsNull(rs!DurchschnittRating) Then
            dblResult = rs!DurchschnittRating
            ' Auf 1 Nachkommastelle runden
            dblResult = Round(dblResult, 1)
        End If
    End If

Cleanup:
    If Not rs Is Nothing Then
        rs.Close
        Set rs = Nothing
    End If
    Set db = Nothing

    GetMA_Rating = dblResult
    Exit Function

ErrorHandler:
    LogError MODULE_NAME, "GetMA_Rating", Err.Number, Err.Description
    Resume Cleanup
End Function

'===============================================================================
' NAECHSTE EINSAETZE
'===============================================================================

'-------------------------------------------------------------------------------
' GetMA_NaechsteEinsaetze
' Gibt die naechsten Einsaetze des Mitarbeiters als JSON-String zurueck
'
' Parameter:
'   MA_ID - Die ID des Mitarbeiters
'   AnzahlTage - Zeitraum in Tagen (Standard: 30)
'
' Rueckgabe:
'   JSON-String mit Array der naechsten Einsaetze
'   Format: [{"VADatum":"2026-01-10","Auftrag":"Event XYZ","VA_Start":"08:00","VA_Ende":"16:00","VA_ID":123},...]
'-------------------------------------------------------------------------------
Public Function GetMA_NaechsteEinsaetze(MA_ID As Long, Optional AnzahlTage As Integer = 30) As String
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim strJSON As String
    Dim strDatum As String
    Dim strStart As String
    Dim strEnde As String
    Dim strAuftrag As String
    Dim lngVA_ID As Long
    Dim intCount As Integer
    Const MAX_EINSAETZE As Integer = 5

    ' Initialisierung
    strJSON = "[]"
    intCount = 0

    Set db = CurrentDb()

    ' SQL-Abfrage: Naechste Einsaetze im Zeitraum
    ' INNER JOIN mit Auftragstabelle fuer Auftragsname
    strSQL = "SELECT TOP " & MAX_EINSAETZE & " " & _
             "z.VA_ID, z.VADatum, z.VA_Start, z.VA_Ende, " & _
             "a.Auftrag, a.AuftragNr " & _
             "FROM tbl_MA_VA_Zuordnung AS z " & _
             "INNER JOIN tbl_VA_Auftragstamm AS a ON z.VA_ID = a.VA_ID " & _
             "WHERE z.MA_ID = " & MA_ID & " " & _
             "AND z.VADatum >= Date() " & _
             "AND z.VADatum <= DateAdd('d', " & AnzahlTage & ", Date()) " & _
             "AND (z.Status IS NULL OR z.Status NOT IN ('Abgesagt','Storniert')) " & _
             "ORDER BY z.VADatum, z.VA_Start"

    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)

    ' JSON-Array aufbauen
    strJSON = "["

    Do While Not rs.EOF And intCount < MAX_EINSAETZE
        ' Werte sicher auslesen
        If Not IsNull(rs!VADatum) Then
            strDatum = Format(rs!VADatum, "yyyy-mm-dd")
        Else
            strDatum = ""
        End If

        If Not IsNull(rs!VA_Start) Then
            strStart = Format(rs!VA_Start, "hh:nn")
        Else
            strStart = ""
        End If

        If Not IsNull(rs!VA_Ende) Then
            strEnde = Format(rs!VA_Ende, "hh:nn")
        Else
            strEnde = ""
        End If

        If Not IsNull(rs!Auftrag) Then
            strAuftrag = EscapeJSONString(CStr(rs!Auftrag))
        Else
            strAuftrag = ""
        End If

        If Not IsNull(rs!VA_ID) Then
            lngVA_ID = rs!VA_ID
        Else
            lngVA_ID = 0
        End If

        ' Komma vor jedem Element ausser dem ersten
        If intCount > 0 Then
            strJSON = strJSON & ","
        End If

        ' JSON-Objekt hinzufuegen
        strJSON = strJSON & "{" & _
                  """VADatum"":""" & strDatum & """," & _
                  """Auftrag"":""" & strAuftrag & """," & _
                  """VA_Start"":""" & strStart & """," & _
                  """VA_Ende"":""" & strEnde & """," & _
                  """VA_ID"":" & lngVA_ID & "}"

        intCount = intCount + 1
        rs.MoveNext
    Loop

    strJSON = strJSON & "]"

Cleanup:
    If Not rs Is Nothing Then
        rs.Close
        Set rs = Nothing
    End If
    Set db = Nothing

    GetMA_NaechsteEinsaetze = strJSON
    Exit Function

ErrorHandler:
    LogError MODULE_NAME, "GetMA_NaechsteEinsaetze", Err.Number, Err.Description
    strJSON = "[]"
    Resume Cleanup
End Function

'===============================================================================
' AKTIONEN
'===============================================================================

'-------------------------------------------------------------------------------
' MA_SendMail
' Oeffnet Outlook mit der E-Mail-Adresse des Mitarbeiters
'
' Parameter:
'   MA_ID - Die ID des Mitarbeiters
'-------------------------------------------------------------------------------
Public Sub MA_SendMail(MA_ID As Long)
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim strEmail As String
    Dim strVorname As String
    Dim strNachname As String
    Dim objOutlook As Object
    Dim objMail As Object

    ' E-Mail-Adresse des Mitarbeiters abrufen
    strSQL = "SELECT Email, Vorname, Nachname " & _
             "FROM tbl_MA_Stamm " & _
             "WHERE MA_ID = " & MA_ID

    Set db = CurrentDb()
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)

    If rs.EOF Then
        MsgBox "Mitarbeiter nicht gefunden.", vbExclamation, "Fehler"
        GoTo Cleanup
    End If

    ' E-Mail-Adresse pruefen
    If IsNull(rs!Email) Or Trim(rs!Email & "") = "" Then
        MsgBox "Keine E-Mail-Adresse fuer diesen Mitarbeiter hinterlegt.", _
               vbExclamation, "Fehler"
        GoTo Cleanup
    End If

    strEmail = Trim(rs!Email)
    strVorname = Nz(rs!Vorname, "")
    strNachname = Nz(rs!Nachname, "")

    rs.Close
    Set rs = Nothing

    ' Outlook oeffnen und neue Mail erstellen
    On Error Resume Next
    Set objOutlook = GetObject(, "Outlook.Application")
    If objOutlook Is Nothing Then
        Set objOutlook = CreateObject("Outlook.Application")
    End If
    On Error GoTo ErrorHandler

    If objOutlook Is Nothing Then
        ' Fallback: mailto-Link verwenden
        Shell "cmd /c start mailto:" & strEmail, vbHide
    Else
        ' Outlook-Mail erstellen
        Set objMail = objOutlook.CreateItem(0) ' olMailItem = 0

        With objMail
            .To = strEmail
            .Subject = ""
            .Body = "Hallo " & strVorname & "," & vbCrLf & vbCrLf
            .Display ' Mail anzeigen (nicht automatisch senden)
        End With
    End If

Cleanup:
    If Not rs Is Nothing Then
        rs.Close
        Set rs = Nothing
    End If
    Set db = Nothing
    Set objMail = Nothing
    Set objOutlook = Nothing
    Exit Sub

ErrorHandler:
    MsgBox "Fehler beim Oeffnen von Outlook: " & vbCrLf & _
           Err.Description, vbCritical, "Fehler"
    Resume Cleanup
End Sub

'-------------------------------------------------------------------------------
' MA_OpenEinsatzplan
' Oeffnet den Dienstplan-Bericht fuer den Mitarbeiter
'
' Parameter:
'   MA_ID - Die ID des Mitarbeiters
'-------------------------------------------------------------------------------
Public Sub MA_OpenEinsatzplan(MA_ID As Long)
    On Error GoTo ErrorHandler

    Dim strReportName As String
    Dim strFilter As String

    ' Name des Berichts (anpassen falls anders benannt)
    strReportName = "rpt_MA_Einsatzplan"

    ' Alternative Berichtsnamen pruefen
    If Not ReportExists(strReportName) Then
        strReportName = "rpt_MA_Dienstplan"
    End If

    If Not ReportExists(strReportName) Then
        strReportName = "rpt_Mitarbeiter_Einsatzplan"
    End If

    If Not ReportExists(strReportName) Then
        MsgBox "Der Einsatzplan-Bericht wurde nicht gefunden." & vbCrLf & _
               "Erwartet: rpt_MA_Einsatzplan", vbExclamation, "Bericht fehlt"
        Exit Sub
    End If

    ' Filter fuer den Mitarbeiter
    strFilter = "MA_ID = " & MA_ID

    ' Bericht oeffnen
    DoCmd.OpenReport strReportName, acViewPreview, , strFilter

    Exit Sub

ErrorHandler:
    MsgBox "Fehler beim Oeffnen des Einsatzplans: " & vbCrLf & _
           Err.Description, vbCritical, "Fehler"
End Sub

'-------------------------------------------------------------------------------
' MA_OpenDokumente
' Oeffnet das Dokumentenverzeichnis des Mitarbeiters
'
' Parameter:
'   MA_ID - Die ID des Mitarbeiters
'-------------------------------------------------------------------------------
Public Sub MA_OpenDokumente(MA_ID As Long)
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim strBasePath As String
    Dim strMAPath As String
    Dim strPersonalNr As String
    Dim strNachname As String
    Dim strVorname As String
    Dim strFolderName As String

    ' Basispfad fuer Dokumente (anpassen!)
    ' Aus Systemkonfiguration lesen oder Standardpfad verwenden
    strBasePath = GetSystemSetting("DokumentePfad", _
                                   "\\Server\Freigabe\MA_Dokumente\")

    ' Mitarbeiterdaten abrufen fuer Ordnername
    strSQL = "SELECT PersonalNr, Nachname, Vorname " & _
             "FROM tbl_MA_Stamm " & _
             "WHERE MA_ID = " & MA_ID

    Set db = CurrentDb()
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)

    If rs.EOF Then
        MsgBox "Mitarbeiter nicht gefunden.", vbExclamation, "Fehler"
        GoTo Cleanup
    End If

    strPersonalNr = Nz(rs!PersonalNr, "")
    strNachname = Nz(rs!Nachname, "")
    strVorname = Nz(rs!Vorname, "")

    rs.Close
    Set rs = Nothing

    ' Ordnernamen generieren
    ' Format: PersonalNr_Nachname_Vorname oder nur MA_ID falls keine PersonalNr
    If strPersonalNr <> "" Then
        strFolderName = SanitizeFolderName(strPersonalNr & "_" & strNachname & "_" & strVorname)
    Else
        strFolderName = SanitizeFolderName("MA_" & MA_ID & "_" & strNachname & "_" & strVorname)
    End If

    strMAPath = strBasePath & strFolderName

    ' Pruefen ob Ordner existiert
    If Dir(strMAPath, vbDirectory) = "" Then
        ' Ordner erstellen?
        If MsgBox("Das Dokumentenverzeichnis existiert noch nicht:" & vbCrLf & _
                  strMAPath & vbCrLf & vbCrLf & _
                  "Soll es erstellt werden?", _
                  vbQuestion + vbYesNo, "Verzeichnis erstellen") = vbYes Then
            MkDir strMAPath
        Else
            GoTo Cleanup
        End If
    End If

    ' Ordner im Explorer oeffnen
    Shell "explorer.exe """ & strMAPath & """", vbNormalFocus

Cleanup:
    If Not rs Is Nothing Then
        rs.Close
        Set rs = Nothing
    End If
    Set db = Nothing
    Exit Sub

ErrorHandler:
    MsgBox "Fehler beim Oeffnen des Dokumentenverzeichnisses: " & vbCrLf & _
           Err.Description, vbCritical, "Fehler"
    Resume Cleanup
End Sub

'===============================================================================
' HILFSFUNKTIONEN
'===============================================================================

'-------------------------------------------------------------------------------
' TableExists
' Prueft ob eine Tabelle in der Datenbank existiert
'-------------------------------------------------------------------------------
Private Function TableExists(TableName As String) As Boolean
    On Error Resume Next
    Dim tdf As DAO.TableDef
    Set tdf = CurrentDb.TableDefs(TableName)
    TableExists = (Err.Number = 0)
    Err.Clear
End Function

'-------------------------------------------------------------------------------
' ReportExists
' Prueft ob ein Bericht in der Datenbank existiert
'-------------------------------------------------------------------------------
Private Function ReportExists(ReportName As String) As Boolean
    On Error Resume Next
    Dim obj As AccessObject
    Set obj = CurrentProject.AllReports(ReportName)
    ReportExists = (Err.Number = 0)
    Err.Clear
End Function

'-------------------------------------------------------------------------------
' EscapeJSONString
' Escaped Sonderzeichen fuer JSON-Strings
'-------------------------------------------------------------------------------
Private Function EscapeJSONString(strInput As String) As String
    Dim strResult As String

    strResult = strInput

    ' Backslash muss zuerst escaped werden
    strResult = Replace(strResult, "\", "\\")
    ' Anfuehrungszeichen
    strResult = Replace(strResult, """", "\""")
    ' Steuerzeichen
    strResult = Replace(strResult, vbCr, "\r")
    strResult = Replace(strResult, vbLf, "\n")
    strResult = Replace(strResult, vbTab, "\t")

    EscapeJSONString = strResult
End Function

'-------------------------------------------------------------------------------
' SanitizeFolderName
' Entfernt ungueltige Zeichen aus Ordnernamen
'-------------------------------------------------------------------------------
Private Function SanitizeFolderName(strInput As String) As String
    Dim strResult As String
    Dim strInvalid As String
    Dim i As Integer

    strResult = strInput
    strInvalid = "\/:*?""<>|"

    For i = 1 To Len(strInvalid)
        strResult = Replace(strResult, Mid(strInvalid, i, 1), "_")
    Next i

    ' Mehrfache Unterstriche reduzieren
    Do While InStr(strResult, "__") > 0
        strResult = Replace(strResult, "__", "_")
    Loop

    ' Fuehrende/abschliessende Unterstriche entfernen
    strResult = Trim(strResult)
    If Left(strResult, 1) = "_" Then strResult = Mid(strResult, 2)
    If Right(strResult, 1) = "_" Then strResult = Left(strResult, Len(strResult) - 1)

    SanitizeFolderName = strResult
End Function

'-------------------------------------------------------------------------------
' GetSystemSetting
' Liest eine Systemeinstellung aus der Konfigurationstabelle
'-------------------------------------------------------------------------------
Private Function GetSystemSetting(SettingName As String, DefaultValue As String) As String
    On Error Resume Next

    Dim strResult As String

    strResult = DefaultValue

    ' Versuche aus Systemtabelle zu lesen
    If TableExists("tbl_System_Settings") Then
        strResult = Nz(DLookup("SettingValue", "tbl_System_Settings", _
                              "SettingName = '" & SettingName & "'"), DefaultValue)
    ElseIf TableExists("tbl_Systemkonfiguration") Then
        strResult = Nz(DLookup("Wert", "tbl_Systemkonfiguration", _
                              "Schluessel = '" & SettingName & "'"), DefaultValue)
    End If

    GetSystemSetting = strResult
End Function

'-------------------------------------------------------------------------------
' LogError
' Protokolliert Fehler (optional in Tabelle oder Debug-Fenster)
'-------------------------------------------------------------------------------
Private Sub LogError(ModuleName As String, ProcName As String, _
                     ErrNum As Long, ErrDesc As String)
    ' Debug-Ausgabe
    Debug.Print Now() & " - ERROR in " & ModuleName & "." & ProcName & _
                ": [" & ErrNum & "] " & ErrDesc

    ' Optional: In Fehlertabelle schreiben
    On Error Resume Next
    If TableExists("tbl_ErrorLog") Then
        Dim strSQL As String
        strSQL = "INSERT INTO tbl_ErrorLog (ErrorDate, ModuleName, ProcName, ErrNumber, ErrDescription) " & _
                 "VALUES (Now(), '" & ModuleName & "', '" & ProcName & "', " & ErrNum & ", '" & _
                 Replace(ErrDesc, "'", "''") & "')"
        CurrentDb.Execute strSQL, dbFailOnError
    End If
End Sub

'===============================================================================
' ERWEITERTE FUNKTIONEN (OPTIONAL)
'===============================================================================

'-------------------------------------------------------------------------------
' GetMA_QuickInfoSummary
' Gibt alle Quick-Info-Daten als JSON-String zurueck
' Nuetzlich fuer WebView2-Integration
'-------------------------------------------------------------------------------
Public Function GetMA_QuickInfoSummary(MA_ID As Long) As String
    On Error GoTo ErrorHandler

    Dim strJSON As String
    Dim lngEinsaetze As Long
    Dim dblStunden As Double
    Dim dblZuverlaessigkeit As Double
    Dim dblRating As Double
    Dim strNaechsteEinsaetze As String

    ' Alle Statistiken abrufen
    lngEinsaetze = GetMA_EinsaetzeJahr(MA_ID)
    dblStunden = GetMA_StundenJahr(MA_ID)
    dblZuverlaessigkeit = GetMA_Zuverlaessigkeit(MA_ID)
    dblRating = GetMA_Rating(MA_ID)
    strNaechsteEinsaetze = GetMA_NaechsteEinsaetze(MA_ID)

    ' JSON zusammenbauen
    strJSON = "{" & _
              """MA_ID"":" & MA_ID & "," & _
              """EinsaetzeJahr"":" & lngEinsaetze & "," & _
              """StundenJahr"":" & Replace(CStr(Round(dblStunden, 2)), ",", ".") & "," & _
              """Zuverlaessigkeit"":" & Replace(CStr(dblZuverlaessigkeit), ",", ".") & "," & _
              """Rating"":" & Replace(CStr(dblRating), ",", ".") & "," & _
              """NaechsteEinsaetze"":" & strNaechsteEinsaetze & _
              "}"

    GetMA_QuickInfoSummary = strJSON
    Exit Function

ErrorHandler:
    LogError MODULE_NAME, "GetMA_QuickInfoSummary", Err.Number, Err.Description
    GetMA_QuickInfoSummary = "{""error"":""" & EscapeJSONString(Err.Description) & """}"
End Function

'-------------------------------------------------------------------------------
' GetMA_LetzteEinsaetze
' Gibt die letzten (vergangenen) Einsaetze als JSON zurueck
'-------------------------------------------------------------------------------
Public Function GetMA_LetzteEinsaetze(MA_ID As Long, Optional AnzahlMax As Integer = 5) As String
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim strJSON As String
    Dim intCount As Integer

    Set db = CurrentDb()

    strSQL = "SELECT TOP " & AnzahlMax & " " & _
             "z.VA_ID, z.VADatum, z.VA_Start, z.VA_Ende, " & _
             "a.Auftrag " & _
             "FROM tbl_MA_VA_Zuordnung AS z " & _
             "INNER JOIN tbl_VA_Auftragstamm AS a ON z.VA_ID = a.VA_ID " & _
             "WHERE z.MA_ID = " & MA_ID & " " & _
             "AND z.VADatum < Date() " & _
             "ORDER BY z.VADatum DESC, z.VA_Start DESC"

    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)

    strJSON = "["
    intCount = 0

    Do While Not rs.EOF
        If intCount > 0 Then strJSON = strJSON & ","

        strJSON = strJSON & "{" & _
                  """VADatum"":""" & Format(Nz(rs!VADatum, ""), "yyyy-mm-dd") & """," & _
                  """Auftrag"":""" & EscapeJSONString(Nz(rs!Auftrag, "")) & """," & _
                  """VA_Start"":""" & Format(Nz(rs!VA_Start, ""), "hh:nn") & """," & _
                  """VA_Ende"":""" & Format(Nz(rs!VA_Ende, ""), "hh:nn") & """," & _
                  """VA_ID"":" & Nz(rs!VA_ID, 0) & "}"

        intCount = intCount + 1
        rs.MoveNext
    Loop

    strJSON = strJSON & "]"

Cleanup:
    If Not rs Is Nothing Then
        rs.Close
        Set rs = Nothing
    End If
    Set db = Nothing

    GetMA_LetzteEinsaetze = strJSON
    Exit Function

ErrorHandler:
    LogError MODULE_NAME, "GetMA_LetzteEinsaetze", Err.Number, Err.Description
    GetMA_LetzteEinsaetze = "[]"
    Resume Cleanup
End Function

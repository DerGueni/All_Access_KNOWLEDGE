Attribute VB_Name = "mod_N_Ausweis_Create_Bridge"
' ========================================
' mod_N_Ausweis_Create_Bridge
' WebView2-Bridge für frm_Ausweis_Create
' ========================================

Public Sub Ausweis_Create_SendMitarbeiterDaten(ByVal webview As Object)
    ' Sendet alle aktiven Mitarbeiter an Browser
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim json As String
    Dim firstRow As Boolean

    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE IstAktiv = True ORDER BY Nachname, Vorname", dbOpenSnapshot)

    ' JSON Header
    json = "{""mitarbeiter"": ["
    firstRow = True

    ' Alle MA durchlaufen
    Do While Not rs.EOF
        If Not firstRow Then json = json & ","

        json = json & "{"
        json = json & """ID"": " & Nz(rs!ID, 0) & ","
        json = json & """Nachname"": """ & EscapeJSON(Nz(rs!Nachname, "")) & ""","
        json = json & """Vorname"": """ & EscapeJSON(Nz(rs!Vorname, "")) & ""","
        json = json & """DienstausweisNr"": """ & EscapeJSON(Nz(rs!DienstausweisNr, "")) & ""","

        ' Gültigkeitsdatum formatieren
        Dim gueltBis As String
        If Not IsNull(rs!Ausweis_GueltBis) Then
            gueltBis = Format(rs!Ausweis_GueltBis, "yyyy-mm-dd")
        Else
            gueltBis = ""
        End If
        json = json & """gueltBis"": """ & gueltBis & """"
        json = json & "}"

        firstRow = False
        rs.MoveNext
    Loop

    json = json & "]}"

    rs.Close
    Set rs = Nothing
    Set db = Nothing

    ' An Browser senden
    webview.PostWebMessageAsJson json

    Debug.Print "[Ausweis Bridge] " & rs.RecordCount & " Mitarbeiter gesendet"
    Exit Sub

ErrorHandler:
    Debug.Print "[Ausweis Bridge] Fehler: " & Err.Description
    MsgBox "Fehler beim Laden der Mitarbeiter: " & Err.Description, vbExclamation
End Sub

Public Sub Ausweis_Create_CreateBadge(ByVal employees As Collection, ByVal badgeType As String, ByVal validUntil As String)
    ' Erstellt Ausweise für ausgewählte Mitarbeiter
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim emp As Variant
    Dim count As Long

    Set db = CurrentDb

    ' Temporäre Tabelle leeren
    db.Execute "DELETE FROM tbl_TEMP_AusweisListe"

    ' Ausgewählte MA eintragen
    For Each emp In employees
        db.Execute "INSERT INTO tbl_TEMP_AusweisListe (MA_ID, Nachname, Vorname, AusweisNr, GueltBis, AusweisTyp) " & _
                   "VALUES (" & emp("id") & ", '" & Replace(emp("nachname"), "'", "''") & "', " & _
                   "'" & Replace(emp("vorname"), "'", "''") & "', '" & emp("ausweisNr") & "', " & _
                   "#" & validUntil & "#, '" & badgeType & "')"
        count = count + 1
    Next

    ' Passenden Report öffnen
    Dim reportName As String
    Select Case badgeType
        Case "Einsatzleitung"
            reportName = "rpt_Dienstausweis_Einsatzleitung"
        Case "Bereichsleiter"
            reportName = "rpt_Dienstausweis_Bereichsleiter"
        Case "Security"
            reportName = "rpt_Dienstausweis_Security"
        Case "Service"
            reportName = "rpt_Dienstausweis_Service"
        Case "Platzanweiser"
            reportName = "rpt_Dienstausweis_Platzanweiser"
        Case "Staff"
            reportName = "rpt_Dienstausweis_Staff"
        Case Else
            MsgBox "Unbekannter Ausweis-Typ: " & badgeType, vbExclamation
            Exit Sub
    End Select

    ' Prüfen ob Report existiert
    If Not ReportExists(reportName) Then
        MsgBox "Report '" & reportName & "' existiert nicht!" & vbCrLf & _
               "Bitte Report für " & badgeType & " erstellen.", vbExclamation
        Exit Sub
    End If

    ' Report öffnen
    DoCmd.OpenReport reportName, acViewPreview

    Debug.Print "[Ausweis Bridge] " & count & " Ausweise erstellt (" & badgeType & ")"
    Exit Sub

ErrorHandler:
    Debug.Print "[Ausweis Bridge] Fehler: " & Err.Description
    MsgBox "Fehler beim Erstellen der Ausweise: " & Err.Description, vbExclamation
End Sub

Public Sub Ausweis_Create_PrintCard(ByVal employees As Collection, ByVal cardType As String, ByVal printer As String, ByVal validUntil As String)
    ' Druckt Karten auf Kartendrucker
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim emp As Variant
    Dim count As Long
    Dim originalPrinter As String

    Set db = CurrentDb

    ' Aktuellen Drucker merken
    originalPrinter = Application.Printer.DeviceName

    ' Temporäre Tabelle leeren
    db.Execute "DELETE FROM tbl_TEMP_AusweisListe"

    ' Ausgewählte MA eintragen
    For Each emp In employees
        db.Execute "INSERT INTO tbl_TEMP_AusweisListe (MA_ID, Nachname, Vorname, AusweisNr, GueltBis, AusweisTyp) " & _
                   "VALUES (" & emp("id") & ", '" & Replace(emp("nachname"), "'", "''") & "', " & _
                   "'" & Replace(emp("vorname"), "'", "''") & "', '" & emp("ausweisNr") & "', " & _
                   "#" & validUntil & "#, '" & cardType & "')"
        count = count + 1
    Next

    ' Passenden Report bestimmen
    Dim reportName As String
    Select Case cardType
        Case "Sicherheit"
            reportName = "rpt_Karte_Sicherheit"
        Case "Service"
            reportName = "rpt_Karte_Service"
        Case "Rueckseite"
            reportName = "rpt_Karte_Rueckseite"
        Case "Sonder"
            reportName = "rpt_Karte_Sonder"
        Case Else
            MsgBox "Unbekannter Karten-Typ: " & cardType, vbExclamation
            Exit Sub
    End Select

    ' Prüfen ob Report existiert
    If Not ReportExists(reportName) Then
        MsgBox "Report '" & reportName & "' existiert nicht!" & vbCrLf & _
               "Bitte Report für " & cardType & " erstellen.", vbExclamation
        Exit Sub
    End If

    ' Drucker setzen (falls spezifiziert und verfügbar)
    If printer <> "" And printer <> "DefaultPrinter" Then
        On Error Resume Next
        Application.Printer = Application.Printers(printer)
        If Err.Number <> 0 Then
            MsgBox "Drucker '" & printer & "' nicht gefunden. Verwende Standard-Drucker.", vbInformation
            Err.Clear
        End If
        On Error GoTo ErrorHandler
    End If

    ' Report drucken
    DoCmd.OpenReport reportName, acViewNormal  ' acViewNormal = direkter Druck

    ' Originalen Drucker wiederherstellen
    Application.Printer = Application.Printers(originalPrinter)

    Debug.Print "[Ausweis Bridge] " & count & " Karten gedruckt (" & cardType & " auf " & printer & ")"
    MsgBox count & " Karten erfolgreich gedruckt.", vbInformation
    Exit Sub

ErrorHandler:
    Debug.Print "[Ausweis Bridge] Fehler: " & Err.Description
    MsgBox "Fehler beim Drucken der Karten: " & Err.Description, vbExclamation

    ' Drucker zurücksetzen
    On Error Resume Next
    Application.Printer = Application.Printers(originalPrinter)
End Sub

' ========================================
' HELPER FUNCTIONS
' ========================================

Private Function EscapeJSON(ByVal text As String) As String
    ' Escaped Sonderzeichen für JSON
    EscapeJSON = Replace(text, "\", "\\")
    EscapeJSON = Replace(EscapeJSON, """", "\""")
    EscapeJSON = Replace(EscapeJSON, vbCrLf, "\n")
    EscapeJSON = Replace(EscapeJSON, vbCr, "\n")
    EscapeJSON = Replace(EscapeJSON, vbLf, "\n")
    EscapeJSON = Replace(EscapeJSON, vbTab, "\t")
End Function

Private Function ReportExists(ByVal reportName As String) As Boolean
    ' Prüft ob Report existiert
    On Error Resume Next
    Dim obj As AccessObject
    For Each obj In CurrentProject.AllReports
        If obj.Name = reportName Then
            ReportExists = True
            Exit Function
        End If
    Next
    ReportExists = False
End Function

Private Function ParseJSONEmployees(ByVal jsonArray As String) As Collection
    ' Parst JSON-Array von Employees (vereinfacht)
    ' HINWEIS: Für echte JSON-Parsing JsonConverter verwenden!

    Dim coll As New Collection
    Dim emp As Object

    ' TODO: Echtes JSON-Parsing implementieren
    ' Beispiel mit JsonConverter:
    ' Dim parsed As Collection
    ' Set parsed = JsonConverter.ParseJson(jsonArray)

    Set ParseJSONEmployees = coll
End Function

' ========================================
' VBA-BRIDGE WRAPPER FUNCTIONS
' ========================================

Public Function Ausweis_Drucken(ByVal MA_ID As Long, Optional ByVal badgeType As String = "Security", Optional ByVal printer As String = "") As String
    ' Wrapper-Funktion für VBA-Bridge Server
    ' Druckt Ausweis für einen einzelnen Mitarbeiter
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim employees As New Collection
    Dim emp As Object

    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & MA_ID, dbOpenSnapshot)

    If rs.EOF Then
        Ausweis_Drucken = "FEHLER: Mitarbeiter ID " & MA_ID & " nicht gefunden"
        rs.Close
        Set rs = Nothing
        Set db = Nothing
        Exit Function
    End If

    ' Employee-Objekt erstellen
    Set emp = CreateObject("Scripting.Dictionary")
    emp("id") = MA_ID
    emp("nachname") = Nz(rs!Nachname, "")
    emp("vorname") = Nz(rs!Vorname, "")
    emp("ausweisNr") = Nz(rs!DienstausweisNr, "")

    employees.Add emp

    rs.Close
    Set rs = Nothing
    Set db = Nothing

    ' Gültigkeit: 1 Jahr ab heute
    Dim validUntil As String
    validUntil = Format(DateAdd("yyyy", 1, Date), "mm/dd/yyyy")

    ' Ausweis erstellen (Vorschau)
    Call Ausweis_Create_CreateBadge(employees, badgeType, validUntil)

    Ausweis_Drucken = "OK"
    Exit Function

ErrorHandler:
    Ausweis_Drucken = "FEHLER: " & Err.Description
End Function

Public Function Ausweis_Nr_Vergeben(ByVal MA_ID As Long) As Long
    ' Wrapper-Funktion für VBA-Bridge Server
    ' Vergibt nächste Ausweis-Nummer an Mitarbeiter
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim nextNr As Long

    Set db = CurrentDb

    ' Prüfen ob MA existiert
    If IsNull(TLookup("ID", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID)) Then
        Ausweis_Nr_Vergeben = 0
        Exit Function
    End If

    ' Nächste Ausweis-Nummer ermitteln
    nextNr = Nz(DMax("DienstausweisNr", "tbl_MA_Mitarbeiterstamm"), 0) + 1

    ' In MA-Stamm speichern
    db.Execute "UPDATE tbl_MA_Mitarbeiterstamm SET DienstausweisNr = '" & nextNr & "' WHERE ID = " & MA_ID

    Ausweis_Nr_Vergeben = nextNr

    Set db = Nothing
    Exit Function

ErrorHandler:
    Ausweis_Nr_Vergeben = 0
End Function

Public Function CreateTestPlanung(ByVal MA_ID As Long, ByVal VA_ID As Long, ByVal VADatum_ID As Long, ByVal VAStart_ID As Long, ByVal StatusID As Integer) As String
    ' Wrapper-Funktion für VBA-Bridge Server
    ' Erstellt Test-Planungsdaten für E2E-Tests
    ' Status_ID: 1=Geplant, 2=Benachrichtigt, 3=Zugesagt, 4=Abgesagt
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim sql As String
    Dim vaDatum As Date
    Dim mvaStart As Date
    Dim mvaEnde As Date

    Set db = CurrentDb

    ' 1. Alte Test-Records löschen
    db.Execute "DELETE FROM tbl_MA_VA_Planung WHERE MA_ID=" & MA_ID & " AND VA_ID=" & VA_ID & " AND VADatum_ID=" & VADatum_ID, dbFailOnError

    ' 2. Datum und Zeiten aus tbl_VA_AnzTage und tbl_VA_Start ermitteln
    vaDatum = Nz(TLookup("VADatum", "tbl_VA_AnzTage", "ID = " & VADatum_ID), Date())
    mvaStart = Nz(TLookup("MVA_Start", "tbl_VA_Start", "ID = " & VAStart_ID), Now())
    mvaEnde = Nz(TLookup("MVA_Ende", "tbl_VA_Start", "ID = " & VAStart_ID), Now())

    ' 3. Neuen Planungs-Eintrag erstellen mit allen Feldern (Locale-unabhängig)
    sql = "INSERT INTO tbl_MA_VA_Planung (MA_ID, VA_ID, VADatum_ID, VAStart_ID, Status_ID, VADatum, MVA_Start, MVA_Ende, Erst_von, Erst_am) " & _
          "VALUES (" & MA_ID & ", " & VA_ID & ", " & VADatum_ID & ", " & VAStart_ID & ", " & StatusID & ", " & _
          "#" & Month(vaDatum) & "/" & Day(vaDatum) & "/" & Year(vaDatum) & "#, " & _
          "#" & Month(mvaStart) & "/" & Day(mvaStart) & "/" & Year(mvaStart) & " " & Hour(mvaStart) & ":" & Minute(mvaStart) & ":" & Second(mvaStart) & "#, " & _
          "#" & Month(mvaEnde) & "/" & Day(mvaEnde) & "/" & Year(mvaEnde) & " " & Hour(mvaEnde) & ":" & Minute(mvaEnde) & ":" & Second(mvaEnde) & "#, " & _
          "'" & Environ("USERNAME") & "', #" & Month(Now()) & "/" & Day(Now()) & "/" & Year(Now()) & " " & Hour(Now()) & ":" & Minute(Now()) & ":" & Second(Now()) & "#)"
    db.Execute sql, dbFailOnError

    ' 4. Bestätigung
    CreateTestPlanung = "OK"

    Set db = Nothing
    Exit Function

ErrorHandler:
    CreateTestPlanung = "FEHLER: " & Err.Description
End Function

Public Function GetPlanungStatus(ByVal MA_ID As Long, ByVal VA_ID As Long, ByVal VADatum_ID As Long) As String
    ' Wrapper-Funktion für VBA-Bridge Server
    ' Prüft aktuellen Status einer Planung
    ' Status_ID: 1=Geplant, 2=Benachrichtigt, 3=Zugesagt, 4=Abgesagt
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim status As Integer

    Set db = CurrentDb

    sql = "SELECT Status_ID FROM tbl_MA_VA_Planung " & _
          "WHERE MA_ID=" & MA_ID & " AND VA_ID=" & VA_ID & " AND VADatum_ID=" & VADatum_ID

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    If rs.EOF Then
        GetPlanungStatus = "NICHT_GEFUNDEN"
    Else
        status = Nz(rs!Status_ID, 0)

        ' Status-Namen zurückgeben
        Select Case status
            Case 1
                GetPlanungStatus = "GEPLANT"
            Case 2
                GetPlanungStatus = "BENACHRICHTIGT"
            Case 3
                GetPlanungStatus = "ZUGESAGT"
            Case 4
                GetPlanungStatus = "ABGESAGT"
            Case Else
                GetPlanungStatus = "UNBEKANNT_" & status
        End Select
    End If

    rs.Close
    Set rs = Nothing
    Set db = Nothing
    Exit Function

ErrorHandler:
    GetPlanungStatus = "FEHLER: " & Err.Description
End Function

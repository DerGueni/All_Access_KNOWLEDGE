' ============================================
' mod_N_HTML_Bridge - VBA Modul fuer HTML-Formular Integration
' ============================================
' Dieses Modul stellt die Verbindung zwischen Access und den
' HTML-Formularen her. Es laedt Daten aus dem Backend und
' sendet sie an das WebBrowser-Control.
'
' VERWENDUNG:
' 1. Formular mit WebBrowser-Control erstellen (Name: ctlWebBrowser)
' 2. Im Form_Load Event: HTML_Bridge_Init Me.ctlWebBrowser, "frm_N_Kundenstammblatt"
' 3. Das HTML wird geladen und Daten werden automatisch befuellt
' ============================================

' Pfad zu den HTML-Dateien (aktualisiert auf frms_HTML_alle Ordner)
Private Const HTML_PATH As String = "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML\frms_HTML_alle\"

' Backend-Pfad (KORRIGIERT: Echtes Backend)
Private Const BACKEND_PATH As String = "S:\CONSEC\CONSEC PLANUNG AKTUELL\Consec_BE_V1.55ANALYSETEST.accdb"

' Aktives WebBrowser Control
Private mActiveWebBrowser As Object
Private mCurrentFormType As String

' ============================================
' INITIALISIERUNG
' ============================================

Public Sub HTML_Bridge_Init(webBrowser As Object, formType As String)
    ' Initialisiert die Bridge fuer ein bestimmtes HTML-Formular
    '
    ' Parameter:
    '   webBrowser - Das WebBrowser-Control im Access-Formular
    '   formType - Name des HTML-Formulars (z.B. "frm_N_Kundenstammblatt")

    Set mActiveWebBrowser = webBrowser
    mCurrentFormType = formType

    ' HTML-Datei laden
    Dim htmlFile As String
    htmlFile = HTML_PATH & formType & ".html"

    If Dir(htmlFile) = "" Then
        MsgBox "HTML-Datei nicht gefunden: " & htmlFile, vbCritical
        Exit Sub
    End If

    ' WebBrowser navigieren
    webBrowser.Navigate htmlFile

    ' Warten bis geladen
    Do While webBrowser.readyState <> 4 ' READYSTATE_COMPLETE
        DoEvents
    Loop

    ' Initiale Daten laden
    HTML_Bridge_LoadInitialData formType
End Sub

Public Sub HTML_Bridge_LoadInitialData(formType As String)
    ' Laedt die initialen Daten je nach Formulartyp

    Select Case formType
        Case "frm_N_Kundenstammblatt"
            Call LoadKundenListe
            Call LoadKundeDetails(27) ' Erster Kunde als Default

        Case "frm_N_Mitarbeiterstammblatt"
            Call LoadMitarbeiterListe
            Call LoadMADetails(707) ' Erster MA als Default

        Case "frm_N_Abwesenheitsplanung"
            Call LoadMitarbeiterListe

        Case "frm_N_Dienstplanuebersicht"
            Call LoadMitarbeiterFuerDienstplan
            Call LoadDienstplanDaten(Date)

        Case "frm_N_Mitarbeiterauswahl"
            Call LoadAuftragsdaten

    End Select
End Sub

' ============================================
' JAVASCRIPT AUFRUFEN
' ============================================

Private Sub CallJavaScript(functionName As String, ParamArray args() As Variant)
    ' Ruft eine JavaScript-Funktion im HTML auf
    '
    ' Beispiel: CallJavaScript "setKundenListe", jsonString

    On Error GoTo ErrorHandler

    If mActiveWebBrowser Is Nothing Then Exit Sub

    Dim script As String
    Dim i As Integer

    script = functionName & "("

    For i = LBound(args) To UBound(args)
        If i > LBound(args) Then script = script & ", "

        ' String-Parameter in Anfuehrungszeichen
        If VarType(args(i)) = vbString Then
            ' Escapen von Sonderzeichen
            Dim escaped As String
            escaped = Replace(args(i), "\", "\\")
            escaped = Replace(escaped, "'", "\'")
            escaped = Replace(escaped, vbCrLf, "\n")
            escaped = Replace(escaped, vbCr, "\n")
            escaped = Replace(escaped, vbLf, "\n")
            script = script & "'" & escaped & "'"
        Else
            script = script & CStr(args(i))
        End If
    Next i

    script = script & ")"

    ' JavaScript ausfuehren
    mActiveWebBrowser.Document.parentWindow.execScript script, "JavaScript"

    Exit Sub
ErrorHandler:
    Debug.Print "JavaScript Fehler: " & Err.description
End Sub

' ============================================
' DATEN ZU JSON KONVERTIEREN
' ============================================

Private Function RecordsetToJSON(rs As DAO.Recordset) As String
    ' Konvertiert ein Recordset zu JSON

    Dim json As String
    Dim field As DAO.field
    Dim firstRow As Boolean
    Dim firstField As Boolean

    json = "["
    firstRow = True

    Do While Not rs.EOF
        If Not firstRow Then json = json & ","
        firstRow = False

        json = json & "{"
        firstField = True

        For Each field In rs.fields
            If Not firstField Then json = json & ","
            firstField = False

            json = json & """" & field.Name & """:"

            If IsNull(field.Value) Then
                json = json & "null"
            ElseIf VarType(field.Value) = vbString Then
                ' String escapen
                Dim val As String
                val = Replace(field.Value, "\", "\\")
                val = Replace(val, """", "\""")
                val = Replace(val, vbCrLf, "\n")
                val = Replace(val, vbCr, "\n")
                val = Replace(val, vbLf, "\n")
                json = json & """" & val & """"
            ElseIf VarType(field.Value) = vbBoolean Then
                json = json & IIf(field.Value, "true", "false")
            ElseIf VarType(field.Value) = vbDate Then
                json = json & """" & Format(field.Value, "dd.mm.yyyy") & """"
            Else
                json = json & CStr(field.Value)
            End If
        Next field

        json = json & "}"
        rs.MoveNext
    Loop

    json = json & "]"
    RecordsetToJSON = json
End Function

Private Function SingleRecordToJSON(rs As DAO.Recordset) As String
    ' Konvertiert einen einzelnen Datensatz zu JSON

    If rs.EOF Then
        SingleRecordToJSON = "{}"
        Exit Function
    End If

    Dim json As String
    Dim field As DAO.field
    Dim firstField As Boolean

    json = "{"
    firstField = True

    For Each field In rs.fields
        If Not firstField Then json = json & ","
        firstField = False

        json = json & """" & field.Name & """:"

        If IsNull(field.Value) Then
            json = json & "null"
        ElseIf VarType(field.Value) = vbString Then
            Dim val As String
            val = Replace(field.Value, "\", "\\")
            val = Replace(val, """", "\""")
            val = Replace(val, vbCrLf, "\n")
            val = Replace(val, vbCr, "\n")
            val = Replace(val, vbLf, "\n")
            json = json & """" & val & """"
        ElseIf VarType(field.Value) = vbBoolean Then
            json = json & IIf(field.Value, "true", "false")
        ElseIf VarType(field.Value) = vbDate Then
            json = json & """" & Format(field.Value, "dd.mm.yyyy") & """"
        Else
            json = json & CStr(field.Value)
        End If
    Next field

    json = json & "}"
    SingleRecordToJSON = json
End Function

' ============================================
' KUNDENSTAMMBLATT FUNKTIONEN
' ============================================

Public Sub LoadKundenListe()
    ' Laedt alle Kunden fuer die Liste

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = OpenDatabase(BACKEND_PATH)

    sql = "SELECT kun_Id, kun_Firma, kun_IstAktiv, kun_Ort as adr_Ort " & _
          "FROM tbl_KD_Kundenstamm " & _
          "ORDER BY kun_Firma"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    Dim json As String
    json = RecordsetToJSON(rs)

    rs.Close
    db.Close

    CallJavaScript "setKundenListe", json
End Sub

Public Sub LoadKundeDetails(kundeId As Long)
    ' Laedt Details eines Kunden

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = OpenDatabase(BACKEND_PATH)

    sql = "SELECT * FROM tbl_KD_Kundenstamm WHERE kun_Id = " & kundeId

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    Dim json As String
    json = SingleRecordToJSON(rs)

    rs.Close
    db.Close

    CallJavaScript "setKundeDetails", json
End Sub

Public Sub SaveKunde(jsonData As String)
    ' Speichert Kundendaten
    ' jsonData enthaelt die Felder als JSON

    ' TODO: JSON parsen und UPDATE ausfuehren
    Debug.Print "Kunde speichern: " & jsonData
End Sub

' ============================================
' MITARBEITERSTAMMBLATT FUNKTIONEN
' ============================================

Public Sub LoadMitarbeiterListe()
    ' Laedt alle Mitarbeiter fuer die Liste

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = OpenDatabase(BACKEND_PATH)

    sql = "SELECT ID, Nachname, Vorname, Ort, IstAktiv " & _
          "FROM tbl_MA_Mitarbeiterstamm " & _
          "ORDER BY Nachname, Vorname"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    Dim json As String
    json = RecordsetToJSON(rs)

    rs.Close
    db.Close

    CallJavaScript "setMitarbeiterListe", json
End Sub

Public Sub LoadMADetails(maId As Long)
    ' Laedt Details eines Mitarbeiters

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = OpenDatabase(BACKEND_PATH)

    sql = "SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & maId

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    Dim json As String
    json = SingleRecordToJSON(rs)

    rs.Close
    db.Close

    CallJavaScript "setMADetails", json
End Sub

' ============================================
' ABWESENHEITSPLANUNG FUNKTIONEN
' ============================================

Public Sub LoadAbwesenheiten(maId As Long)
    ' Laedt Abwesenheiten eines Mitarbeiters

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = OpenDatabase(BACKEND_PATH)

    sql = "SELECT ID, vonDat, bisDat, Grund, Bemerkung " & _
          "FROM tbl_MA_NVerfuegZeiten " & _
          "WHERE MA_ID = " & maId & " " & _
          "ORDER BY vonDat"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    Dim json As String
    json = RecordsetToJSON(rs)

    rs.Close
    db.Close

    CallJavaScript "setAbwesenheiten", json
End Sub

Public Sub SaveAbwesenheit(jsonData As String)
    ' Speichert eine Abwesenheit
    Debug.Print "Abwesenheit speichern: " & jsonData
End Sub

Public Sub DeleteAbwesenheit(abwesenheitId As Long)
    ' Loescht eine Abwesenheit

    Dim db As DAO.Database
    Set db = OpenDatabase(BACKEND_PATH)

    db.Execute "DELETE FROM tbl_MA_NVerfuegZeiten WHERE ID = " & abwesenheitId

    db.Close
End Sub

' ============================================
' DIENSTPLANUEBERSICHT FUNKTIONEN
' ============================================

Public Sub LoadMitarbeiterFuerDienstplan()
    ' Laedt Mitarbeiter fuer die Dienstplanuebersicht

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = OpenDatabase(BACKEND_PATH)

    sql = "SELECT ID, Nachname, Vorname " & _
          "FROM tbl_MA_Mitarbeiterstamm " & _
          "WHERE IstAktiv = True " & _
          "ORDER BY Nachname, Vorname"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    Dim json As String
    json = RecordsetToJSON(rs)

    rs.Close
    db.Close

    CallJavaScript "setMitarbeiterData", json
End Sub

Public Sub LoadDienstplanDaten(StartDatum As Date)
    ' Laedt Planungsdaten ab einem bestimmten Datum

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim endDatum As Date

    endDatum = StartDatum + 6 ' 7 Tage

    Set db = OpenDatabase(BACKEND_PATH)

    sql = "SELECT p.MA_ID, p.VADatum, p.VA_Start, p.VA_Ende, a.Auftrag " & _
          "FROM tbl_MA_VA_Planung p " & _
          "LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.VA_ID " & _
          "WHERE p.VADatum >= #" & Format(StartDatum, "yyyy-mm-dd") & "# " & _
          "AND p.VADatum <= #" & Format(endDatum, "yyyy-mm-dd") & "# " & _
          "ORDER BY p.VADatum, p.VA_Start"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    Dim json As String
    json = RecordsetToJSON(rs)

    rs.Close
    db.Close

    CallJavaScript "setPlanungData", json
End Sub

' ============================================
' MITARBEITERAUSWAHL FUNKTIONEN
' ============================================

Public Sub LoadAuftragsdaten()
    ' Laedt Auftraege fuer die Mitarbeiterauswahl

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = OpenDatabase(BACKEND_PATH)

    ' Auftraege der naechsten 30 Tage
    sql = "SELECT a.VA_ID, a.Auftrag, a.Objekt, t.VADatum " & _
          "FROM tbl_VA_Auftragstamm a " & _
          "INNER JOIN tbl_VA_AnzTage t ON a.VA_ID = t.VA_ID " & _
          "WHERE t.VADatum >= Date() " & _
          "AND t.VADatum <= Date() + 30 " & _
          "ORDER BY t.VADatum"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    Dim json As String
    json = "{""auftraege"":" & RecordsetToJSON(rs) & "}"

    rs.Close
    db.Close

    CallJavaScript "setAuftragsdaten", json
End Sub

Public Sub LoadSchichtenFuerAuftrag(vaId As Long, VADatum As Date)
    ' Laedt Schichten fuer einen Auftrag

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = OpenDatabase(BACKEND_PATH)

    sql = "SELECT VAStart_ID, VA_ID, VADatum, VA_Start, VA_Ende, MA_Anzahl, MA_Anzahl_Ist " & _
          "FROM tbl_VA_Start " & _
          "WHERE VA_ID = " & vaId & " " & _
          "AND VADatum = #" & Format(VADatum, "yyyy-mm-dd") & "# " & _
          "ORDER BY VA_Start"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    Dim json As String
    json = RecordsetToJSON(rs)

    rs.Close
    db.Close

    CallJavaScript "setSchichten", json
End Sub

Public Sub LoadVerfuegbareMA(vaStartID As Long)
    ' Laedt verfuegbare Mitarbeiter fuer eine Schicht

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = OpenDatabase(BACKEND_PATH)

    ' Alle aktiven MA die nicht bereits geplant sind
    sql = "SELECT m.ID as MA_ID, m.Nachname & ' ' & m.Vorname as Name, m.IstAktiv " & _
          "FROM tbl_MA_Mitarbeiterstamm m " & _
          "WHERE m.IstAktiv = True " & _
          "ORDER BY m.Nachname, m.Vorname"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    Dim json As String
    json = RecordsetToJSON(rs)

    rs.Close
    db.Close

    CallJavaScript "setVerfuegbareMA", json
End Sub

Public Sub LoadGeplanteMA(vaStartID As Long)
    ' Laedt bereits geplante MA fuer eine Schicht

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = OpenDatabase(BACKEND_PATH)

    sql = "SELECT p.MA_ID, m.Nachname, m.Vorname, p.VA_Start as Beginn " & _
          "FROM tbl_MA_VA_Planung p " & _
          "INNER JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID " & _
          "WHERE p.VAStart_ID = " & vaStartID & " " & _
          "ORDER BY m.Nachname, m.Vorname"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    Dim json As String
    json = RecordsetToJSON(rs)

    rs.Close
    db.Close

    CallJavaScript "setGeplanteMA", json
End Sub

' ============================================
' EVENT HANDLER FUER WEBBROWSER
' ============================================

Public Sub HTML_Bridge_HandleNotify(eventData As String)
    ' Verarbeitet Events vom HTML (via window.external.notify)
    '
    ' Wird aufgerufen aus dem WebBrowser_BeforeNavigate2 Event
    ' wenn die URL mit "about:blank#" beginnt

    Dim parts() As String
    Dim action As String
    Dim param As String

    ' Format: "ACTION:PARAMETER" oder "ACTION:PARAM1:PARAM2"
    parts = Split(eventData, ":")

    If UBound(parts) >= 0 Then
        action = parts(0)
    End If

    If UBound(parts) >= 1 Then
        param = parts(1)
    End If

    Select Case action
        Case "HTML_READY"
            ' HTML ist geladen, initiale Daten senden
            HTML_Bridge_LoadInitialData mCurrentFormType

        Case "LOAD_KUNDE"
            LoadKundeDetails CLng(param)

        Case "LOAD_MA"
            LoadMADetails CLng(param)

        Case "LOAD_ABWESENHEITEN"
            LoadAbwesenheiten CLng(param)

        Case "DATE_CHANGED"
            ' Datum im Dienstplan geaendert
            LoadDienstplanDaten CDate(param)

        Case "LOAD_AUFTRAG"
            ' Auftrag gewaehlt
            ' TODO: Schichten laden

        Case "LOAD_MA_FOR_SCHICHT"
            LoadVerfuegbareMA CLng(param)
            LoadGeplanteMA CLng(param)

        Case "NAVIGATE"
            ' Zu anderem Formular navigieren
            DoCmd.OpenForm param

        Case "ACTION"
            ' Spezielle Aktionen
            HandleAction param

        Case "SAVE_KUNDE"
            SaveKunde parts(1)

        Case "SAVE_ABWESENHEIT"
            SaveAbwesenheit parts(1)

        Case "DELETE_ABWESENHEIT"
            DeleteAbwesenheit CLng(param)

    End Select
End Sub

Private Sub HandleAction(actionName As String)
    ' Verarbeitet spezielle Aktionen

    Select Case actionName
        Case "NEUER_KUNDE"
            ' Neuen Kunden anlegen
            DoCmd.OpenForm "frm_KundeNeu"

        Case "NEUER_MA"
            ' Neuen MA anlegen
            DoCmd.OpenForm "frm_MANeu"

        Case "DIENSTPLAENE_SENDEN"
            ' Dienstplaene per Mail senden
            ' TODO: Implementieren

        Case "UEBERSICHT_DRUCKEN"
            ' Dienstplanuebersicht drucken
            ' TODO: Implementieren

    End Select
End Sub

' ============================================
' HILFSFUNKTIONEN
' ============================================

Public Sub HTML_Bridge_Refresh()
    ' Aktualisiert die Daten im HTML
    HTML_Bridge_LoadInitialData mCurrentFormType
End Sub

Public Sub HTML_Bridge_Close()
    ' Raumt auf beim Schliessen
    Set mActiveWebBrowser = Nothing
    mCurrentFormType = ""
End Sub
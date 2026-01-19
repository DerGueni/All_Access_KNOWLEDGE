' ============================================
' mod_N_HTML_DataBridge - Datenbruecke fuer HTML-Formulare
' ============================================
' Laedt Daten aus dem Backend und stellt sie als JSON bereit
' fuer die HTML-Formulare.
'
' Die HTML-Formulare rufen diese Funktionen via JavaScript auf
' um echte Daten zu laden.
' ============================================

' ============================================
' JSON HELPER FUNKTIONEN
' ============================================

Private Function EscapeJSON(ByVal s As String) As String
    ' Escaped einen String fuer JSON
    If IsNull(s) Or s = "" Then
        EscapeJSON = ""
        Exit Function
    End If
    s = Replace(s, "\", "\\")
    s = Replace(s, """", "\""")
    s = Replace(s, vbCrLf, "\n")
    s = Replace(s, vbCr, "\n")
    s = Replace(s, vbLf, "\n")
    s = Replace(s, vbTab, "\t")
    EscapeJSON = s
End Function

Private Function FieldToJSON(fld As DAO.field) As String
    ' Konvertiert ein Feld zu JSON
    Dim result As String

    If IsNull(fld.Value) Then
        result = "null"
    ElseIf fld.Type = dbBoolean Then
        result = IIf(fld.Value, "true", "false")
    ElseIf fld.Type = dbDate Then
        result = """" & Format(fld.Value, "dd.mm.yyyy") & """"
    ElseIf fld.Type = dbText Or fld.Type = dbMemo Then
        result = """" & EscapeJSON(CStr(fld.Value)) & """"
    ElseIf IsNumeric(fld.Value) Then
        result = CStr(fld.Value)
    Else
        result = """" & EscapeJSON(CStr(fld.Value)) & """"
    End If

    FieldToJSON = result
End Function

Private Function RecordsetToJSON(rs As DAO.Recordset) As String
    ' Konvertiert ein Recordset zu JSON Array
    Dim json As String
    Dim fld As DAO.field
    Dim firstRow As Boolean
    Dim firstField As Boolean

    json = "["
    firstRow = True

    Do While Not rs.EOF
        If Not firstRow Then json = json & ","
        firstRow = False

        json = json & "{"
        firstField = True

        For Each fld In rs.fields
            If Not firstField Then json = json & ","
            firstField = False
            json = json & """" & fld.Name & """:" & FieldToJSON(fld)
        Next fld

        json = json & "}"
        rs.MoveNext
    Loop

    json = json & "]"
    RecordsetToJSON = json
End Function

' ============================================
' MITARBEITER DATEN
' ============================================

Public Function GetMitarbeiterListe(Optional nurAktive As Boolean = True) As String
    ' Liefert alle Mitarbeiter als JSON
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = CurrentDb

    sql = "SELECT ID, Nachname, Vorname, Tel_Mobil, Email, IstAktiv, Ort " & _
          "FROM tbl_MA_Mitarbeiterstamm "

    If nurAktive Then
        sql = sql & "WHERE IstAktiv = True "
    End If

    sql = sql & "ORDER BY Nachname, Vorname"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    GetMitarbeiterListe = RecordsetToJSON(rs)
    rs.Close
End Function

Public Function GetMitarbeiterDetails(maId As Long) As String
    ' Liefert Details eines Mitarbeiters als JSON
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim json As String
    Dim fld As DAO.field
    Dim firstField As Boolean

    Set db = CurrentDb

    sql = "SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & maId

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    If rs.EOF Then
        GetMitarbeiterDetails = "{}"
        rs.Close
        Exit Function
    End If

    json = "{"
    firstField = True

    For Each fld In rs.fields
        If Not firstField Then json = json & ","
        firstField = False
        json = json & """" & fld.Name & """:" & FieldToJSON(fld)
    Next fld

    json = json & "}"
    GetMitarbeiterDetails = json
    rs.Close
End Function

' ============================================
' KUNDEN DATEN
' ============================================

Public Function GetKundenListe(Optional nurAktive As Boolean = True) As String
    ' Liefert alle Kunden als JSON
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = CurrentDb

    sql = "SELECT kun_Id, kun_Firma, kun_IstAktiv, kun_Ort " & _
          "FROM tbl_KD_Kundenstamm "

    If nurAktive Then
        sql = sql & "WHERE kun_IstAktiv = True "
    End If

    sql = sql & "ORDER BY kun_Firma"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    GetKundenListe = RecordsetToJSON(rs)
    rs.Close
End Function

Public Function GetKundeDetails(kundeId As Long) As String
    ' Liefert Details eines Kunden als JSON
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim json As String
    Dim fld As DAO.field
    Dim firstField As Boolean

    Set db = CurrentDb

    sql = "SELECT * FROM tbl_KD_Kundenstamm WHERE kun_Id = " & kundeId

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    If rs.EOF Then
        GetKundeDetails = "{}"
        rs.Close
        Exit Function
    End If

    json = "{"
    firstField = True

    For Each fld In rs.fields
        If Not firstField Then json = json & ","
        firstField = False
        json = json & """" & fld.Name & """:" & FieldToJSON(fld)
    Next fld

    json = json & "}"
    GetKundeDetails = json
    rs.Close
End Function

' ============================================
' DIENSTPLAN DATEN
' ============================================

Public Function GetDienstplanDaten(StartDatum As Date, anzahlTage As Integer) As String
    ' Liefert Dienstplan-Daten fuer einen Zeitraum
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim endDatum As Date

    endDatum = StartDatum + anzahlTage - 1

    Set db = CurrentDb

    sql = "SELECT p.MA_ID, p.VADatum, p.VA_Start, p.VA_Ende, " & _
          "a.Auftrag, a.Objekt, m.Nachname, m.Vorname " & _
          "FROM ((tbl_MA_VA_Planung AS p " & _
          "LEFT JOIN tbl_VA_Auftragstamm AS a ON p.VA_ID = a.ID) " & _
          "LEFT JOIN tbl_MA_Mitarbeiterstamm AS m ON p.MA_ID = m.ID) " & _
          "WHERE p.VADatum >= #" & Format(StartDatum, "mm/dd/yyyy") & "# " & _
          "AND p.VADatum <= #" & Format(endDatum, "mm/dd/yyyy") & "# " & _
          "ORDER BY p.VADatum, p.VA_Start"

    On Error Resume Next
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    If Err.Number <> 0 Then
        GetDienstplanDaten = "[]"
        Exit Function
    End If
    On Error GoTo 0

    GetDienstplanDaten = RecordsetToJSON(rs)
    rs.Close
End Function

' ============================================
' AUFTRAGS DATEN
' ============================================

Public Function GetAuftragListe(Optional vonDatum As Date, Optional bisDatum As Date) As String
    ' Liefert Auftraege mit Schichten
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = CurrentDb

    If vonDatum = 0 Then vonDatum = Date
    If bisDatum = 0 Then bisDatum = Date + 30

    sql = "SELECT s.ID AS VAStart_ID, s.VA_ID, s.VADatum, s.VA_Start, s.VA_Ende, " & _
          "s.MA_Anzahl, s.MA_Anzahl_Ist, a.Auftrag, a.Objekt, " & _
          "k.kun_Firma AS Kunde " & _
          "FROM ((tbl_VA_Start AS s " & _
          "LEFT JOIN tbl_VA_Auftragstamm AS a ON s.VA_ID = a.ID) " & _
          "LEFT JOIN tbl_KD_Kundenstamm AS k ON a.Veranstalter_ID = k.kun_Id) " & _
          "WHERE s.VADatum >= #" & Format(vonDatum, "mm/dd/yyyy") & "# " & _
          "AND s.VADatum <= #" & Format(bisDatum, "mm/dd/yyyy") & "# " & _
          "ORDER BY s.VADatum, s.VA_Start"

    On Error Resume Next
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    If Err.Number <> 0 Then
        GetAuftragListe = "[]"
        Exit Function
    End If
    On Error GoTo 0

    GetAuftragListe = RecordsetToJSON(rs)
    rs.Close
End Function

Public Function GetSchichtenFuerAuftrag(vaId As Long, VADatum As Date) As String
    ' Liefert alle Schichten fuer einen Auftrag an einem Tag
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = CurrentDb

    sql = "SELECT ID AS VAStart_ID, VA_ID, VADatum, VA_Start, VA_Ende, " & _
          "MA_Anzahl, MA_Anzahl_Ist " & _
          "FROM tbl_VA_Start " & _
          "WHERE VA_ID = " & vaId & " " & _
          "AND VADatum = #" & Format(VADatum, "mm/dd/yyyy") & "# " & _
          "ORDER BY VA_Start"

    On Error Resume Next
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    If Err.Number <> 0 Then
        GetSchichtenFuerAuftrag = "[]"
        Exit Function
    End If
    On Error GoTo 0

    GetSchichtenFuerAuftrag = RecordsetToJSON(rs)
    rs.Close
End Function

' ============================================
' ABWESENHEITEN
' ============================================

Public Function GetAbwesenheiten(maId As Long) As String
    ' Liefert Abwesenheiten eines Mitarbeiters
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = CurrentDb

    sql = "SELECT ID, MA_ID, vonDat, bisDat, Bemerkung, Zeittyp_ID " & _
          "FROM tbl_MA_NVerfuegZeiten " & _
          "WHERE MA_ID = " & maId & " " & _
          "ORDER BY vonDat DESC"

    On Error Resume Next
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    If Err.Number <> 0 Then
        GetAbwesenheiten = "[]"
        Exit Function
    End If
    On Error GoTo 0

    GetAbwesenheiten = RecordsetToJSON(rs)
    rs.Close
End Function

Public Function SaveAbwesenheit(maId As Long, vonDat As Date, bisDat As Date, _
                                 Optional zeitTypId As Long = 1, Optional Bemerkung As String = "") As Boolean
    ' Speichert eine neue Abwesenheit
    Dim db As DAO.Database
    Dim sql As String

    On Error GoTo ErrHandler

    Set db = CurrentDb

    sql = "INSERT INTO tbl_MA_NVerfuegZeiten (MA_ID, vonDat, bisDat, Zeittyp_ID, Bemerkung, Erst_von, Erst_am) " & _
          "VALUES (" & maId & ", #" & Format(vonDat, "mm/dd/yyyy") & "#, " & _
          "#" & Format(bisDat, "mm/dd/yyyy") & "#, " & zeitTypId & ", " & _
          """" & EscapeJSON(Bemerkung) & """, """ & Environ("USERNAME") & """, #" & Format(Now, "mm/dd/yyyy hh:nn:ss") & "#)"

    db.Execute sql, dbFailOnError
    SaveAbwesenheit = True
    Exit Function

ErrHandler:
    SaveAbwesenheit = False
End Function

Public Function DeleteAbwesenheit(abwesenheitId As Long) As Boolean
    ' Loescht eine Abwesenheit
    Dim db As DAO.Database

    On Error GoTo ErrHandler

    Set db = CurrentDb
    db.Execute "DELETE FROM tbl_MA_NVerfuegZeiten WHERE ID = " & abwesenheitId, dbFailOnError
    DeleteAbwesenheit = True
    Exit Function

ErrHandler:
    DeleteAbwesenheit = False
End Function

' ============================================
' MA PLANUNG
' ============================================

Public Function GetGeplanteMitarbeiter(vaStartID As Long) As String
    ' Liefert geplante Mitarbeiter fuer eine Schicht
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = CurrentDb

    sql = "SELECT p.ID, p.MA_ID, p.VA_Start, p.VA_Ende, p.Status_ID, " & _
          "m.Nachname, m.Vorname, m.Tel_Mobil " & _
          "FROM tbl_MA_VA_Planung AS p " & _
          "LEFT JOIN tbl_MA_Mitarbeiterstamm AS m ON p.MA_ID = m.ID " & _
          "WHERE p.VAStart_ID = " & vaStartID & " " & _
          "ORDER BY m.Nachname, m.Vorname"

    On Error Resume Next
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    If Err.Number <> 0 Then
        GetGeplanteMitarbeiter = "[]"
        Exit Function
    End If
    On Error GoTo 0

    GetGeplanteMitarbeiter = RecordsetToJSON(rs)
    rs.Close
End Function

Public Function GetVerfuegbareMitarbeiter(VADatum As Date, vaStart As String, vaEnde As String) As String
    ' Liefert verfuegbare Mitarbeiter fuer einen Zeitraum
    ' (aktive MA die keine Abwesenheit und keinen anderen Einsatz haben)
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = CurrentDb

    ' Vereinfachte Version - alle aktiven MA
    sql = "SELECT ID AS MA_ID, Nachname & ' ' & Vorname AS Name, " & _
          "Tel_Mobil, IstAktiv " & _
          "FROM tbl_MA_Mitarbeiterstamm " & _
          "WHERE IstAktiv = True " & _
          "ORDER BY Nachname, Vorname"

    On Error Resume Next
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    If Err.Number <> 0 Then
        GetVerfuegbareMitarbeiter = "[]"
        Exit Function
    End If
    On Error GoTo 0

    GetVerfuegbareMitarbeiter = RecordsetToJSON(rs)
    rs.Close
End Function

Public Function PlanMitarbeiter(vaStartID As Long, maId As Long, vaStart As String, vaEnde As String) As Boolean
    ' Plant einen Mitarbeiter fuer eine Schicht ein
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim vaId As Long
    Dim VADatum As Date
    Dim vaDatumID As Long

    On Error GoTo ErrHandler

    Set db = CurrentDb

    ' Schicht-Daten holen
    Set rs = db.OpenRecordset("SELECT VA_ID, VADatum, VADatum_ID FROM tbl_VA_Start WHERE ID = " & vaStartID)
    If rs.EOF Then
        PlanMitarbeiter = False
        Exit Function
    End If

    vaId = rs!VA_ID
    VADatum = rs!VADatum
    vaDatumID = Nz(rs!VADatum_ID, 0)
    rs.Close

    ' Eintrag erstellen
    sql = "INSERT INTO tbl_MA_VA_Planung " & _
          "(VA_ID, VADatum_ID, VAStart_ID, VA_Start, VA_Ende, MA_ID, VADatum, " & _
          "Erst_von, Erst_am, Status_ID) VALUES (" & _
          vaId & ", " & vaDatumID & ", " & vaStartID & ", " & _
          """" & vaStart & """, """ & vaEnde & """, " & maId & ", " & _
          "#" & Format(VADatum, "mm/dd/yyyy") & "#, " & _
          """" & Environ("USERNAME") & """, #" & Format(Now, "mm/dd/yyyy hh:nn:ss") & "#, 1)"

    db.Execute sql, dbFailOnError

    ' MA_Anzahl_Ist aktualisieren
    db.Execute "UPDATE tbl_VA_Start SET MA_Anzahl_Ist = Nz(MA_Anzahl_Ist,0) + 1 WHERE ID = " & vaStartID

    PlanMitarbeiter = True
    Exit Function

ErrHandler:
    PlanMitarbeiter = False
End Function

Public Function EntferneMitarbeiter(planungId As Long) As Boolean
    ' Entfernt einen Mitarbeiter aus der Planung
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim vaStartID As Long

    On Error GoTo ErrHandler

    Set db = CurrentDb

    ' VAStart_ID holen
    Set rs = db.OpenRecordset("SELECT VAStart_ID FROM tbl_MA_VA_Planung WHERE ID = " & planungId)
    If rs.EOF Then
        EntferneMitarbeiter = False
        Exit Function
    End If
    vaStartID = rs!VAStart_ID
    rs.Close

    ' Loeschen
    db.Execute "DELETE FROM tbl_MA_VA_Planung WHERE ID = " & planungId, dbFailOnError

    ' MA_Anzahl_Ist aktualisieren
    db.Execute "UPDATE tbl_VA_Start SET MA_Anzahl_Ist = IIf(Nz(MA_Anzahl_Ist,0) > 0, MA_Anzahl_Ist - 1, 0) WHERE ID = " & vaStartID

    EntferneMitarbeiter = True
    Exit Function

ErrHandler:
    EntferneMitarbeiter = False
End Function

' ============================================
' KUNDEN SPEICHERN
' ============================================

Public Function SaveKunde(kundeId As Long, firma As String, Strasse As String, _
                          PLZ As String, Ort As String, telefon As String, _
                          Email As String) As Boolean
    ' Speichert Kundendaten
    Dim db As DAO.Database
    Dim sql As String

    On Error GoTo ErrHandler

    Set db = CurrentDb

    sql = "UPDATE tbl_KD_Kundenstamm SET " & _
          "kun_Firma = """ & EscapeJSON(firma) & """, " & _
          "kun_Strasse = """ & EscapeJSON(Strasse) & """, " & _
          "kun_PLZ = """ & EscapeJSON(PLZ) & """, " & _
          "kun_Ort = """ & EscapeJSON(Ort) & """, " & _
          "kun_telefon = """ & EscapeJSON(telefon) & """, " & _
          "kun_eMail = """ & EscapeJSON(Email) & """ " & _
          "WHERE kun_Id = " & kundeId

    db.Execute sql, dbFailOnError
    SaveKunde = True
    Exit Function

ErrHandler:
    SaveKunde = False
End Function

' ============================================
' NAVIGATION / FORMULARE OEFFNEN
' ============================================

Public Sub OpenFormular(formName As String, Optional filter As String = "")
    ' Oeffnet ein Access-Formular
    On Error Resume Next
    If filter <> "" Then
        DoCmd.OpenForm formName, , , filter
    Else
        DoCmd.OpenForm formName
    End If
End Sub

Public Sub OpenBericht(berichtName As String, Optional filter As String = "")
    ' Oeffnet einen Access-Bericht
    On Error Resume Next
    If filter <> "" Then
        DoCmd.OpenReport berichtName, acViewPreview, , filter
    Else
        DoCmd.OpenReport berichtName, acViewPreview
    End If
End Sub

' ============================================
' TEST FUNKTION
' ============================================

Public Sub TestDataBridge()
    ' Testet die Datenbruecke
    Dim result As String

    Debug.Print "=== TEST DATA BRIDGE ==="

    Debug.Print vbCrLf & "Mitarbeiter (erste 100 Zeichen):"
    result = GetMitarbeiterListe(True)
    Debug.Print Left(result, 100) & "..."

    Debug.Print vbCrLf & "Kunden (erste 100 Zeichen):"
    result = GetKundenListe(True)
    Debug.Print Left(result, 100) & "..."

    Debug.Print vbCrLf & "Auftraege (erste 100 Zeichen):"
    result = GetAuftragListe(Date, Date + 30)
    Debug.Print Left(result, 100) & "..."

    Debug.Print vbCrLf & "=== TEST ENDE ==="
End Sub
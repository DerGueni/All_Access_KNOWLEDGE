' ============================================
' Modul: mod_N_WebForm_Handler
' Zweck: Bridge-Kommunikation für HTML-WebForms
' Tabelle: tbl_MA_Mitarbeiterstamm
' Form: frm_MA_Mitarbeiterstamm
' ============================================

' Globals
Global gCurrentRecordID As Long
Global gRecordList As Collection
Global gFormIsLoading As Boolean

' ============================================
' LOAD FORM DATA
' Sendet Daten an HTML-Form bei Öffnung
' ============================================
Public Sub LoadForm(formName As String, Optional recordId As Long = 0)
  On Error GoTo ErrorHandler

  Dim db As DAO.Database
  Dim rs As DAO.Recordset
  Dim fullRecord As Object
  Dim recordArray As Collection
  Dim sql As String

  Set db = CurrentDb
  gFormIsLoading = True

  ' --- HAUPTDATENSATZ LADEN ---
  If recordId > 0 Then
    gCurrentRecordID = recordId
    Set rs = db.OpenRecordset("SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & recordId)
  Else
    Set rs = db.OpenRecordset("SELECT * FROM tbl_MA_Mitarbeiterstamm")
    If Not rs.EOF Then
      rs.MoveFirst
      gCurrentRecordID = rs!ID
    End If
  End If

  If Not rs.EOF Then
    Set fullRecord = RecordsetToJSON(rs)
  End If
  rs.Close

  ' --- MITARBEITERLISTE LADEN (mit Filter) ---
  sql = "SELECT ID, Nachname, Vorname, Ort FROM tbl_MA_Mitarbeiterstamm " & _
        "WHERE Anstellungsart_ID IN (3, 5) ORDER BY Nachname, Vorname"
  Set rs = db.OpenRecordset(sql)
  Set recordArray = New Collection

  Do Until rs.EOF
    recordArray.Add RecordsetToJSON(rs)
    rs.MoveNext
  Loop
  rs.Close

  ' --- SENDE EVENT ZU HTML ---
  SendToWebForm "loadForm", CreateObject("Scripting.Dictionary"), Array(fullRecord, recordArray)

  gFormIsLoading = False
  Exit Sub

ErrorHandler:
  MsgBox "LoadForm Error: " & Err.Description
  gFormIsLoading = False
End Sub

' ============================================
' NAVIGATE RECORD
' ============================================
Public Sub NavigateRecord(direction As String)
  On Error GoTo ErrorHandler

  Dim db As DAO.Database
  Dim rs As DAO.Recordset
  Dim sql As String
  Dim newRecordID As Long
  Dim newRecord As Object

  Set db = CurrentDb

  ' --- POSITION BESTIMMEN ---
  sql = "SELECT ID FROM tbl_MA_Mitarbeiterstamm " & _
        "WHERE Anstellungsart_ID IN (3, 5) ORDER BY Nachname, Vorname"
  Set rs = db.OpenRecordset(sql)

  Dim recordArray As Collection
  Set recordArray = New Collection

  Do Until rs.EOF
    recordArray.Add rs!ID
    rs.MoveNext
  Loop
  rs.Close

  ' --- NEUE POSITION FINDEN ---
  Dim currentIndex As Long
  Dim newIndex As Long
  currentIndex = 1

  Dim i As Long
  For i = 1 To recordArray.Count
    If recordArray(i) = gCurrentRecordID Then
      currentIndex = i
      Exit For
    End If
  Next i

  Select Case direction
    Case "first"
      newIndex = 1
    Case "last"
      newIndex = recordArray.Count
    Case "next"
      newIndex = Application.Min(currentIndex + 1, recordArray.Count)
    Case "prev"
      newIndex = Application.Max(currentIndex - 1, 1)
  End Select

  ' --- NEUEN DATENSATZ LADEN ---
  If newIndex > 0 And newIndex <= recordArray.Count Then
    newRecordID = recordArray(newIndex)
    gCurrentRecordID = newRecordID

    Set rs = db.OpenRecordset("SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & newRecordID)
    If Not rs.EOF Then
      Set newRecord = RecordsetToJSON(rs)
      SendToWebForm "recordChanged", CreateObject("Scripting.Dictionary"), Array(newRecord)
    End If
    rs.Close
  End If

  Exit Sub

ErrorHandler:
  MsgBox "NavigateRecord Error: " & Err.Description
End Sub

' ============================================
' FIELD CHANGED
' Wird aufgerufen, wenn HTML-Field sich ändert
' ============================================
Public Sub FieldChanged(fieldName As String, fieldValue As Variant, recordId As Long)
  On Error GoTo ErrorHandler

  ' Hier könnte Validierung stattfinden
  ' Z.B. Email-Format, PLZ-Format, etc.

  ' Vorläufig nur loggen
  Debug.Print "FieldChanged: " & fieldName & " = " & fieldValue

  Exit Sub

ErrorHandler:
  ' Stille Fehlerbehandlung für Logging
End Sub

' ============================================
' SAVE RECORD
' Speichert Änderungen in der Datenbank mit Validierung
' ============================================
Public Sub SaveRecord(recordData As Object)
  On Error GoTo ErrorHandler

  Dim db As DAO.Database
  Dim rs As DAO.Recordset
  Dim recordId As Long
  Dim key As Variant
  Dim validationError As String

  Set db = CurrentDb
  recordId = recordData("ID")

  ' --- VALIDIERUNG ---
  validationError = ValidateRecord(recordData)
  If validationError <> "" Then
    SendToWebForm "error", CreateObject("Scripting.Dictionary"), Array(validationError)
    Exit Sub
  End If

  ' --- DATENSATZ ÖFFNEN ---
  Set rs = db.OpenRecordset("SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & recordId)

  If rs.EOF Then
    ' Neuer Datensatz
    rs.AddNew
  Else
    ' Existierender Datensatz
    rs.Edit
  End If

  ' --- FELDER AKTUALISIEREN ---
  For Each key In recordData.Keys
    If key <> "ID" Then ' ID nicht überschreiben
      On Error Resume Next
      Dim fieldValue As Variant
      fieldValue = recordData(key)

      ' Leere Strings zu Null konvertieren für optionale Felder
      If fieldValue = "" Then
        rs(CStr(key)) = Null
      Else
        rs(CStr(key)) = fieldValue
      End If
      On Error GoTo ErrorHandler
    End If
  Next key

  rs.Update
  rs.Close
  Set rs = Nothing

  ' --- BESTÄTIGUNG SENDEN ---
  SendToWebForm "recordSaved", CreateObject("Scripting.Dictionary"), Array(recordId)

  ' --- NACHRICHTEN UPDATEN ---
  gCurrentRecordID = recordId

  Exit Sub

ErrorHandler:
  If Not rs Is Nothing Then
    On Error Resume Next
    rs.Close
  End If
  SendToWebForm "error", CreateObject("Scripting.Dictionary"), Array("Fehler beim Speichern: " & Err.Description)
End Sub

' ============================================
' DELETE RECORD
' Löscht einen Datensatz
' ============================================
Public Sub DeleteRecord(recordId As Long)
  On Error GoTo ErrorHandler

  Dim db As DAO.Database
  Dim rs As DAO.Recordset

  Set db = CurrentDb

  ' --- SICHERHEITSPRÜFUNG ---
  If recordId <= 0 Then
    SendToWebForm "error", CreateObject("Scripting.Dictionary"), _
      Array("Keine gültige ID zum Löschen")
    Exit Sub
  End If

  ' --- LÖSCHEN ---
  Set rs = db.OpenRecordset("SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & recordId)
  If Not rs.EOF Then
    rs.Delete
  End If
  rs.Close

  ' --- BESTÄTIGUNG ---
  SendToWebForm "recordDeleted", CreateObject("Scripting.Dictionary"), Array(recordId)

  ' --- NÄCHSTEN DATENSATZ LADEN ---
  NavigateRecord "next"

  Exit Sub

ErrorHandler:
  MsgBox "DeleteRecord Error: " & Err.Description
End Sub

' ============================================
' VALIDATE RECORD
' Validiert Formulardaten vor dem Speichern
' ============================================
Private Function ValidateRecord(recordData As Object) As String
  Dim errors As String
  errors = ""

  ' Nachname prüfen (erforderlich)
  If Not recordData.Exists("Nachname") Or recordData("Nachname") = "" Then
    errors = errors & "Nachname ist erforderlich. "
  End If

  ' Vorname prüfen (erforderlich)
  If Not recordData.Exists("Vorname") Or recordData("Vorname") = "" Then
    errors = errors & "Vorname ist erforderlich. "
  End If

  ' Email-Format prüfen (optional, aber wenn vorhanden dann Format)
  If recordData.Exists("Email") And recordData("Email") <> "" Then
    If Not IsValidEmail(recordData("Email")) Then
      errors = errors & "Email-Format ungültig. "
    End If
  End If

  ' PLZ-Format prüfen (optional, aber wenn vorhanden)
  If recordData.Exists("PLZ") And recordData("PLZ") <> "" Then
    If Not IsValidPLZ(recordData("PLZ")) Then
      errors = errors & "PLZ-Format ungültig (5 Ziffern). "
    End If
  End If

  ' IBAN-Format prüfen (optional, aber wenn vorhanden)
  If recordData.Exists("IBAN") And recordData("IBAN") <> "" Then
    If Not IsValidIBAN(recordData("IBAN")) Then
      errors = errors & "IBAN-Format ungültig. "
    End If
  End If

  ValidateRecord = errors
End Function

' ============================================
' VALIDATE EMAIL
' Prüft Email-Format mit Regex-ähnlicher Logik
' ============================================
Private Function IsValidEmail(email As String) As Boolean
  Dim atPos As Long
  Dim dotPos As Long

  email = Trim(email)

  ' Muss @ enthalten
  atPos = InStr(1, email, "@")
  If atPos <= 1 Then
    IsValidEmail = False
    Exit Function
  End If

  ' Muss . nach @ enthalten
  dotPos = InStr(atPos, email, ".")
  If dotPos <= atPos + 1 Or dotPos >= Len(email) Then
    IsValidEmail = False
    Exit Function
  End If

  ' Nur ein @ erlaubt
  If InStr(atPos + 1, email, "@") > 0 Then
    IsValidEmail = False
    Exit Function
  End If

  IsValidEmail = True
End Function

' ============================================
' VALIDATE PLZ
' Prüft PLZ-Format (5 Ziffern)
' ============================================
Private Function IsValidPLZ(plz As String) As Boolean
  Dim i As Integer

  plz = Trim(plz)

  ' Muss genau 5 Ziffern sein
  If Len(plz) <> 5 Then
    IsValidPLZ = False
    Exit Function
  End If

  For i = 1 To 5
    If Not (Mid(plz, i, 1) >= "0" And Mid(plz, i, 1) <= "9") Then
      IsValidPLZ = False
      Exit Function
    End If
  Next i

  IsValidPLZ = True
End Function

' ============================================
' VALIDATE IBAN
' Basis-Check (Länge 20-34, Buchstaben am Anfang)
' ============================================
Private Function IsValidIBAN(iban As String) As Boolean
  iban = Trim(iban)

  ' IBAN muss 20-34 Zeichen sein
  If Len(iban) < 20 Or Len(iban) > 34 Then
    IsValidIBAN = False
    Exit Function
  End If

  ' Erste 2 Zeichen müssen Buchstaben sein
  If Not (Mid(iban, 1, 1) >= "A" And Mid(iban, 1, 1) <= "Z") Then
    IsValidIBAN = False
    Exit Function
  End If

  If Not (Mid(iban, 2, 1) >= "A" And Mid(iban, 2, 1) <= "Z") Then
    IsValidIBAN = False
    Exit Function
  End If

  IsValidIBAN = True
End Function

' ============================================
' HELPER: RECORDSET TO JSON
' Konvertiert Recordset-Row zu Dictionary
' ============================================
Private Function RecordsetToJSON(rs As DAO.Recordset) As Object
  Dim dict As Object
  Dim fieldIndex As Integer

  Set dict = CreateObject("Scripting.Dictionary")

  For fieldIndex = 0 To rs.Fields.Count - 1
    On Error Resume Next
    dict.Add rs.Fields(fieldIndex).Name, rs.Fields(fieldIndex).Value
    On Error GoTo 0
  Next fieldIndex

  Set RecordsetToJSON = dict
End Function

' ============================================
' HELPER: SEND TO WEBFORM
' Sendet Event an HTML-Form über Bridge
' ============================================
Private Sub SendToWebForm(eventType As String, args As Object, payload As Variant)
  On Error GoTo ErrorHandler

  ' Diese Funktion wird vom Access Frontend (WebView2) aufgerufen
  ' Die Nachricht wird dann ans HTML gesendet

  Dim msg As Object
  Set msg = CreateObject("Scripting.Dictionary")

  msg.Add "kind", "event"
  msg.Add "type", eventType
  msg.Add "payload", payload(0)

  ' Falls 2. Parameter: als recordList hinzufügen
  If UBound(payload) > 0 Then
    msg.Add "recordList", payload(1)
  End If

  ' Debug-Ausgabe
  Debug.Print "SendToWebForm: " & eventType

  Exit Sub

ErrorHandler:
  ' Fehlerbehandlung
End Sub

' ============================================
' PRINT EMPLOYEE LIST
' ============================================
Public Sub PrintEmployeeList()
  On Error GoTo ErrorHandler

  ' Placeholder für Druck-Funktionalität
  MsgBox "Mitarbeiterliste-Druck wird eingeleitet...", vbInformation

  Exit Sub

ErrorHandler:
  MsgBox "PrintEmployeeList Error: " & Err.Description
End Sub

' ============================================
' OPEN TIME ACCOUNT FORMS
' ============================================
Public Sub OpenTimeAccountForm(empId As Long)
  ' Placeholder für Zeitkonto-Formulare
  MsgBox "Zeitkonto-Formular wird geöffnet für MA #" & empId, vbInformation
End Sub

Public Sub OpenTimeAccountFixed(empId As Long)
  MsgBox "Festzeitkonto wird geöffnet für MA #" & empId, vbInformation
End Sub

Public Sub OpenTimeAccountMini(empId As Long)
  MsgBox "Mini-Zeitkonto wird geöffnet für MA #" & empId, vbInformation
End Sub

Public Sub OpenStaffTable()
  ' Öffnet Mitarbeiterlisten-Ansicht
  MsgBox "Mitarbeiterlisten-Ansicht wird geöffnet", vbInformation
End Sub

' ============================================
' TEST FUNCTION
' ============================================
Public Sub Test_LoadForm()
  LoadForm "frm_MA_Mitarbeiterstamm", 437
End Sub

Public Sub Test_NavigateRecord()
  NavigateRecord "next"
End Sub

Public Sub Test_DeleteRecord()
  If MsgBox("Test-Datensatz wirklich löschen?", vbYesNo) = vbYes Then
    DeleteRecord gCurrentRecordID
  End If
End Sub

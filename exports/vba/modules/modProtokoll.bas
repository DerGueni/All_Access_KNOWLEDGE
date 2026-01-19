Attribute VB_Name = "modProtokoll"
Option Compare Database
Option Explicit

Declare PtrSafe Function GetUserName Lib "advapi32.dll" _
        Alias "GetUserNameA" _
        (ByVal lpBuffer As String, nSize As Long) As Long

Declare PtrSafe Function GetComputerName Lib "kernel32" _
        Alias "GetComputerNameA" _
        (ByVal lpBuffer As String, nSize As Long) As Long

Public arrProtokoll(1 To 250, 1 To 8) As String
Public cntProtokoll As Integer

Public Function Änderungsprotokoll()

  On Error Resume Next
  DoCmd.OpenForm "Änderungsprotokoll", , , , , acDialog
  If Err <> 0 Then
    Beep
    MsgBox "Formular 'Änderungsprotokoll' nicht gefunden!", _
           vbOKOnly + vbCritical, "Änderungsprotokoll:"
    Exit Function
  End If
  
End Function

Public Function Datensatzlöschung()
  Dim db As DAO.Database
  Dim rs As DAO.Recordset
  Dim f As Form, ctl As control
  Dim strText As String
  
  On Error Resume Next
  Set db = CurrentDb()
  Set rs = db.OpenRecordset("Protokoll", dbOpenDynaset)
  If Err <> 0 Then
    Beep
    MsgBox "Fehler beim Zugriff auf Tabelle 'Protokoll'...", _
           vbOKOnly + vbExclamation, "Protokollieren:"
    Exit Function
  End If
  Err = 0
  Set f = Screen.ActiveForm
  If Err <> 0 Then
    Beep
    MsgBox "Kein Formular geöffnet...", _
           vbOKOnly + vbExclamation, "Protokollieren:"
    Exit Function
  End If
  
  For Each ctl In f.Controls
    If TypeOf ctl Is TextBox Or _
       TypeOf ctl Is ListBox Or _
       TypeOf ctl Is CheckBox Or _
       TypeOf ctl Is OptionGroup Or _
       TypeOf ctl Is ToggleButton Or _
       TypeOf ctl Is ComboBox Then
    strText = strText & ctl.Name & ": " & CStr(ctl.Value) & vbCrLf
    End If
  Next ctl
  
  rs.AddNew
  rs("pDatenbank") = db.Name
  rs("pFormularName") = f.Name
  rs("pFeldName") = "Datensatzlöschung!"
  rs("pAlterWert") = strText
  rs("pNeuerWert") = "Gelöscht!"
  rs("pGeaendertAm") = Now
  rs("pGeaendertVon") = NetworkUserName() & "/" & NetworkComputerName()
  rs.update
  rs.Close
  
  Set rs = Nothing
  Set db = Nothing

End Function

Function NetworkComputerName() As String
  Dim lngMaxLen As Long, lngResult As Long
  Dim strComputerName As String
  
  lngMaxLen = 16
  strComputerName = String$(lngMaxLen, 0)
  lngResult = GetComputerName(strComputerName, lngMaxLen)
  If lngResult <> 0 Then
    NetworkComputerName = Trim$(Left$(strComputerName, lngMaxLen))
  Else
    NetworkComputerName = "???"
  End If

End Function

Function NetworkUserName() As String
  Dim lngMaxLen As Long, lngResult As Long
  Dim strUserName As String

  strUserName = String$(254, 0)
  lngMaxLen = 255
  lngResult = GetUserName(strUserName, lngMaxLen)
  If lngResult <> 0 Then
    NetworkUserName = Left$(strUserName, lngMaxLen - 1)
  Else
    NetworkUserName = ""
  End If

End Function



Public Function Protokollieren()
  Dim f As Form, c As control, ctl As control
  Dim strID As String
  
  On Error Resume Next
  Set f = Screen.ActiveForm
  Set c = Screen.ActiveControl
  If Err <> 0 Then
    Beep
    MsgBox "Kein Formular geöffnet oder kein Steuerelement aktiviert...", _
           vbOKOnly + vbExclamation, "Protokollieren:"
    Exit Function
  End If
  
  strID = ""
  For Each ctl In f.Controls
    If ctl.TAG = "DSID" Then
      strID = strID & CStr(ctl.Value)
    End If
  Next ctl
  If strID = "" Then
    Beep
    MsgBox "Kein Feld als 'DSID' gekennzeichnet!", _
           vbOKOnly + vbExclamation, "Protokollieren:"
    Exit Function
  End If
  
  cntProtokoll = cntProtokoll + 1
  arrProtokoll(cntProtokoll, 1) = CurrentDb.Name
  arrProtokoll(cntProtokoll, 2) = f.Name
  arrProtokoll(cntProtokoll, 3) = c.Name
  arrProtokoll(cntProtokoll, 4) = CStr(c.OldValue)
  arrProtokoll(cntProtokoll, 5) = CStr(c.Value)
  arrProtokoll(cntProtokoll, 6) = Now
  arrProtokoll(cntProtokoll, 7) = NetworkUserName() & "/" & NetworkComputerName()
  arrProtokoll(cntProtokoll, 8) = strID
  
End Function

Function ProtokollEnde()
  Dim db As DAO.Database
  Dim rs As DAO.Recordset
  Dim i As Long
  
  On Error Resume Next
  Set db = CurrentDb()
  Set rs = db.OpenRecordset("Protokoll", dbOpenDynaset)
  If Err <> 0 Then
    Beep
    MsgBox "Fehler beim Zugriff auf Tabelle 'Protokoll'...", _
           vbOKOnly + vbExclamation, "Protokollieren:"
    cntProtokoll = 0  'Neue Protokollierung starten
    Exit Function
  End If
  
  For i = 1 To cntProtokoll
    rs.AddNew
    rs("pDatenbank") = arrProtokoll(i, 1)
    rs("pFormularName") = arrProtokoll(i, 2)
    rs("pFeldName") = arrProtokoll(i, 3)
    rs("pAlterWert") = arrProtokoll(i, 4)
    rs("pNeuerWert") = arrProtokoll(i, 5)
    rs("pGeaendertAm") = arrProtokoll(i, 6)
    rs("pGeaendertVon") = arrProtokoll(i, 7)
    rs("pDSID") = arrProtokoll(i, 8)
    rs.update
  Next i
  rs.Close
  
  Set rs = Nothing
  Set db = Nothing
  
  Erase arrProtokoll  'Temporäres Protokoll löschen
  cntProtokoll = 0    'Neue Protokollierung starten

End Function



Function Protokollstart()

  Erase arrProtokoll  'Temporäres Protokoll löschen
  cntProtokoll = 0    'Neue Protokollierung starten
  
End Function



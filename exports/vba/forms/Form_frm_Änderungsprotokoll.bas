VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_Änderungsprotokoll"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Dim f As Form
Dim rs As DAO.Recordset


Private Sub btnDone_Click()

  On Error Resume Next
  DoCmd.Close acForm, Me.Name, acSavePrompt
  
End Sub

Private Sub btnDSLöschungen_Click()

  On Error Resume Next
  DoCmd.OpenForm "Datensatzlöschungen", acNormal, , "[pFormularName]= '" & f.Name & "'", acFormReadOnly, acDialog
  
End Sub

Private Sub btnUndo_Click()
  Dim rs As DAO.Recordset
  Dim lngAnz As Long, i As Long
  Dim strField As String, varValue As Variant
  
  On Error Resume Next
  DoCmd.RunCommand acCmdSaveRecord
  Set rs = Me.RecordsetClone
  rs.MoveLast
  lngAnz = rs.RecordCount
  rs.MoveFirst
  For i = 1 To lngAnz
    If rs("pRueckgaengig") Then
      strField = rs("pFeldName")
      varValue = rs("pAlterWert")
      f.Controls(strField).Value = varValue
    End If
    rs.MoveNext
  Next i
  rs.Close
  Set rs = Nothing
  Beep
  MsgBox "Änderungen wurden rückgängig gemacht!", _
         vbOKOnly + vbInformation, "Rückgängig:"
  DoCmd.Close acForm, Me.Name, acSavePrompt
  
End Sub

Private Sub Form_Load()

  Dim strSQL As String
  Dim lngNumRecs As Long, i As Long
  Dim strID As String, strDB As String
  Dim ctl As control
  
  On Error Resume Next
  Set f = Screen.ActiveForm 'Globale Variable
  If Err <> 0 Then
    Beep
    MsgBox "Kein Formular geöffnet!", _
           vbOKOnly + vbExclamation, "Änderungsprotokoll:"
    DoCmd.Close acForm, Me.Name, acSavePrompt
    GoTo Exit_Proc
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
           vbOKOnly + vbExclamation, "Änderungsprotokoll:"
    DoCmd.Close acForm, Me.Name, acSavePrompt
    GoTo Exit_Proc
  End If
  
  DoCmd.SetWarnings False
  DoCmd.RunSQL "UPDATE Protokoll SET Protokoll.pRueckgaengig = No;", False
  DoCmd.SetWarnings True
  
  strDB = CurrentDb.Name
  strSQL = "select * from [Protokoll] where [pDatenbank]= '" & _
           strDB & "' and [pFormularName]= '" & _
           f.Name & "' and [pDSID]= '" & _
           strID & "' order by pGeaendertAm desc;"
  Me.recordSource = strSQL
  
  Err = 0
  Set rs = Me.RecordsetClone
  rs.MoveLast
  lngNumRecs = rs.RecordCount
  If Err <> 0 Or lngNumRecs = 0 Then
    Beep
    MsgBox "Es sind keine Änderungen für diesen Datensatz protokolliert!" & vbCrLf & vbCrLf & _
           "Datenbank: " & strDB & vbCrLf & _
           "Formular: " & f.Name, _
           vbOKOnly + vbExclamation, "Änderungsprotokoll:"
    rs.Close
    Set rs = Nothing
    DoCmd.Close acForm, Me.Name, acSavePrompt
    GoTo Exit_Proc
  End If
  rs.MoveFirst
  
Exit_Proc:
  DoEvents
  Err.clear

End Sub



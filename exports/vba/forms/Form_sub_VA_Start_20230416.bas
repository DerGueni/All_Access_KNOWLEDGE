VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_VA_Start_20230416"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Compare Database
Option Explicit


Private Sub Form_AfterUpdate()

    ' Zuordnung aktualisieren
    Call Me.Parent.Form.Controls("sub_MA_VA_Zuordnung").Form.Current
    'Me.Parent.Form.Controls("sub_MA_VA_Zuordnung").Form.Controls("Bemerkungen").SetFocus
    'Me.Parent.Form.Controls("sub_MA_VA_Zuordnung").Form.Controls("Bemerkungen").Value = ""
    'Me.Parent.Forms.sub_MA_VA_Zuordnung.Form.Requery
    
End Sub

Private Sub Form_BeforeUpdate(Cancel As Integer)

Dim al As Single
Dim dt As Date

'On Error Resume Next

If Len(Trim(Nz(Me!VA_Start))) = 0 Then
    MsgBox "Zumindest Startzeit eingeben!"
    Cancel = True
    Exit Sub
End If
If Len(Trim(Nz(Me!MA_Anzahl))) <= 0 Then
    MsgBox "Anzahl muss größer 0 sein!"
    Cancel = True
    Exit Sub
End If

    Me!VADatum = Me.Parent!cboVADatum.Column(1)
    Me!MVA_Start = Startzeit_G(Me!VADatum, Me!VA_Start)
    Me!MVA_Ende = Endezeit_G(Me!VADatum, Me!VA_Start, Me!VA_Ende)

End Sub



Private Sub Form_Current()
    'Debug.Print "VA_Start: " & Me.Dirty
    Me!VADatum_ID.RowSource = "SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum FROM tbl_VA_AnzTage WHERE (((tbl_VA_AnzTage.VA_ID) = " & Me!VA_ID & "));"
End Sub


Function Zeit_Test(st) As Date
Dim m As Long
Dim s As Long

    st = Trim(Nz(st))

    If st = "" Then Exit Function
    If IsNumeric(st) And InStr(st, ":") = 0 And _
        InStr(st, ",") = 0 Then
'        Zeit_Test.NumberFormat = "[hh]:mm"
        If Len(st) > 2 Then
            s = Left(st, Len(st) - 2)
            m = Mid(st, 3)
        Else
            s = st
            m = 0
        End If
        Zeit_Test = "#" & s & ":" & m & "#"
    End If

End Function

Private Sub ID_KeyPress(KeyAscii As Integer)
If Len(ID) = 2 Then ID = ID & ":00"
If Len(ID) = 3 And Right(ID, 1) = ":" Then ID = ID & "00"
End Sub


'Private Sub MA_Anzahl_AfterUpdate()
''If KeyCode = 0 Then
''Forms!sub_MA_VA_Zuordnung.SetFocus
''End If
'
'End Sub


'
'Private Sub MA_Anzahl_KeyDown(KeyCode As Integer, Shift As Integer)
'If Me!MA_Anzahl = "" Then
'Forms!frm_va_auftragstamm!sub_MA_VA_Zuordnung.SetFocus
'End If
'End Sub

Private Sub VA_Start_AfterUpdate()
Dim iVAStart_ID As Long
Dim dt1 As Date

On Error GoTo Err
    iVAStart_ID = Me!ID
    dt1 = Me!VA_Start
    dt1 = CDate(dt1 - Fix(dt1))
    
    CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.aend_von = '" & atCNames(1) & "', tbl_MA_VA_Zuordnung.aend_am = '" & DateTimeForSQL(Now()) & "', tbl_MA_VA_Zuordnung.MA_Start = " & DateTimeForSQL(dt1) & " WHERE (((tbl_MA_VA_Zuordnung.VAStart_ID)= " & iVAStart_ID & "));")
    Me.Parent!sub_MA_VA_Zuordnung.Form.Requery
    'If KeyCode = 9 Or KeyCode = 13 Then
    'Me!VA_Ende.SetFocus
    'End If
Err:

End Sub

Private Sub VA_Ende_AfterUpdate()

Dim iVAStart_ID As Long
Dim dt1 As Date

iVAStart_ID = Me!ID
If Not IsNull(Me.VA_Ende) Then
    dt1 = Me.VA_Ende
    dt1 = CDate(dt1 - Fix(dt1))

    CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.aend_von = '" & atCNames(1) & "', tbl_MA_VA_Zuordnung.aend_am = '" & DateTimeForSQL(Now()) & "', tbl_MA_VA_Zuordnung.MA_Ende = " & DateTimeForSQL(dt1) & " WHERE (((tbl_MA_VA_Zuordnung.VAStart_ID)= " & iVAStart_ID & "));")

Else
    CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.aend_von = '" & atCNames(1) & "', tbl_MA_VA_Zuordnung.aend_am = '" & DateTimeForSQL(Now()) & "', tbl_MA_VA_Zuordnung.MA_Ende = Null WHERE (((tbl_MA_VA_Zuordnung.VAStart_ID)= " & iVAStart_ID & "));")

End If
Me.Parent!sub_MA_VA_Zuordnung.Form.Requery
'Me.Recordset.MoveNext
'Me!MA_Anzahl.SetFocus
'If Me!MA_Anzahl = "" Then
'Forms!Form_sub_MA_VA_Zuordnung.SetFocus
'Forms!Form_sub_MA_VA_Zuordnung.cboMA_Ausw.SetFocus
'End If


End Sub
'
Private Sub VA_Ende_KeyDown(KeyCode As Integer, Shift As Integer)
On Error Resume Next

Dim st
Dim s As Long
Dim m As Long
Dim uz As Date

    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        'KeyCode = 0
        st = Me!VA_Ende.Text
        Select Case True
            Case Len(st) = 1 And IsNumeric(st) = False
                st = "00:00"
            Case Len(st) = 1 And IsNumeric(st)
                st = "0" & st & ":00"
            Case Len(st) = 2 And Right(st, 1) = ":"
                st = "0" & st & "00"
            Case Len(st) = 2
                st = st & ":00"
            Case Len(st) = 3 And Right(st, 1) = ":"
                st = st & "00"
        End Select
        Me.VA_Ende.Text = st
        
        
        If Me.Recordset.EOF = False Then
            Me.Recordset.MoveNext
            Me.MA_Anzahl.SetFocus
        Else
            'Absprung bei tab
            If KeyCode = vbKeyTab Then
                Me.Parent.sub_MA_VA_Zuordnung.SetFocus
            Else 'neuer Satz bei enter
                Me.Recordset.AddNew
                Me.Recordset.MoveNext
                Me.MA_Anzahl.SetFocus
            End If
        End If
    End If
End Sub


Private Sub VA_Start_KeyDown(KeyCode As Integer, Shift As Integer)

Dim st
 
    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        'KeyCode = 0
        st = Me!VA_Start.Text
        Select Case True
            Case Len(st) = 1 And IsNumeric(st) = False
                st = "00:00"
            Case Len(st) = 1 And IsNumeric(st)
                st = "0" & st & ":00"
            Case Len(st) = 2 And Right(st, 1) = ":"
                st = "0" & st & "00"
            Case Len(st) = 2
                st = st & ":00"
            Case Len(st) = 3 And Right(st, 1) = ":"
                st = st & "00"
        End Select
        Me.VA_Start.Text = st
        If st <> "" Then Me.VA_Ende.SetFocus
    End If
End Sub
'
'Private Sub VA_Zeitpunkt_KeyDown(KeyCode As Integer, Shift As Integer)
'Dim st
'Dim s As Long
'Dim m As Long
'Dim uz As Date
'
'    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
'        KeyCode = 0
'        st = Me!VA_Zeitpunkt.Text
'        If Not IsNumeric(st) Then Exit Sub
'        If Len(Trim(Nz(st))) < 3 Then
'            s = st
'            m = 0
'        Else
'            s = Left(st, 2)
'            m = Mid(st, 3)
'        End If
'        uz = CDate(TimeSerial(s, m, 0))
'        Me!VA_Zeitpunkt = uz
'    End If
'
'End Sub


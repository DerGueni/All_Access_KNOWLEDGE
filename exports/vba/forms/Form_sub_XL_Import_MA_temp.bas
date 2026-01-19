VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_XL_Import_MA_temp"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Beginn_KeyDown(KeyCode As Integer, Shift As Integer)
Dim st
Dim s As Long
Dim m As Long
Dim uz As Date

    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        KeyCode = 0
        st = Me!Beginn.Text
        If Not IsNumeric(st) Then Exit Sub
        If Len(Trim(Nz(st))) < 3 Then
            s = st
            m = 0
        Else
            s = Left(st, 2)
            m = Mid(st, 3)
        End If
        uz = CDate(TimeSerial(s, m, 0))
        Me!Beginn = uz
    End If

End Sub

Private Sub Ende_KeyDown(KeyCode As Integer, Shift As Integer)
Dim st
Dim s As Long
Dim m As Long
Dim uz As Date

    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        KeyCode = 0
        st = Me!Ende.Text
        If Not IsNumeric(st) Then Exit Sub
        If Len(Trim(Nz(st))) < 3 Then
            s = st
            m = 0
        Else
            s = Left(st, 2)
            m = Mid(st, 3)
        End If
        uz = CDate(TimeSerial(s, m, 0))
        Me!Ende = uz
    End If


End Sub

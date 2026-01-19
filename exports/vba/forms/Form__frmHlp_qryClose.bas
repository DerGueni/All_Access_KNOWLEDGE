VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form__frmHlp_qryClose"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit
Dim repName As String

Private Sub btnCloseRep_Click()
repName = Me.OpenArgs

DoCmd.Close acQuery, repName, acSaveNo
DoCmd.Close acForm, Me.Name, acSaveNo
End Sub

Private Sub btnDruck_Click()

On Error Resume Next
repName = Me.OpenArgs
' Bildschirmanzeige zum aktiven Objekt machen
DoCmd.SelectObject acQuery, repName, False
    
' Ausdruck über Druckerdialog
DoCmd.RunCommand acCmdPrint
DoCmd.Close acQuery, repName, acSaveNo
DoCmd.Close acForm, Me.Name, acSaveNo



End Sub

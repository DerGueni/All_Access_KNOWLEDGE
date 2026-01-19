VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Report_rpt_Ausweis_ohne_Namen_service"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Befehl61_Click()
Dim repName As String
'repname = Me.OpenArgs

DoCmd.Close acQuery, acSaveNo
'DoCmd.Close acForm, Me.Name, acSaveNo
On Error Resume Next
repName = Me.OpenArgs
' Bildschirmanzeige zum aktiven Objekt machen
DoCmd.SelectObject acReport, repName, False
    
' Ausdruck über Druckerdialog
DoCmd.RunCommand acCmdPrint
DoCmd.Close acReport, repName, acSaveNo
Forms!frm_ausweis_create!lstMA_Ausweis.clear
End Sub

Private Sub btnDruck_Click()
Dim repName
On Error Resume Next
repName = Me.OpenArgs
' Bildschirmanzeige zum aktiven Objekt machen
DoCmd.SelectObject acReport, repName, False
  DoCmd.PrintOut acPages
  DoCmd.Close acPages
' Ausdruck über Druckerdialog
DoCmd.RunCommand acCmdPrint
DoCmd.Close acReport, repName, acSaveNo
'Forms!frm_ausweis_create!lstMA_Ausweis.Clear

End Sub

Private Sub Report_Close()
DoCmd.Close acForm, "_frmHlp_rptClose", acSaveNo
End Sub

Private Sub Report_Current()
DoCmd.Maximize
End Sub

Private Sub Report_Load()
'DoCmd.Maximize
End Sub

Private Sub Report_Open(Cancel As Integer)
DoCmd.OpenForm "_frmHlp_rptClose", , , , , , Me.Name
'DoCmd.Close acForm, "_frmHlp_rptClose", acSaveNo

End Sub

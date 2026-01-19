VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form__frmHlp_rptClose"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

'_frmHlp_rptClose
Dim repName As String
Dim KARTENDRUCKER As String


Private Sub btnCloseRep_Click()
On Error Resume Next
repName = Me.OpenArgs

DoCmd.Close acReport, repName, acSaveNo
DoCmd.Close acForm, Me.Name, acSaveNo
End Sub

Private Sub btnDruck_Click()

On Error Resume Next
repName = Me.OpenArgs
' Bildschirmanzeige zum aktiven Objekt machen
DoCmd.SelectObject acReport, repName, False
    
' Ausdruck über Druckerdialog
DoCmd.RunCommand acCmdPrint

End Sub


'Drucken
Private Sub Befehl4_Click()

On Error Resume Next

    KARTENDRUCKER = Get_Priv_Property("prp_Kartendrucker")
    repName = Me.OpenArgs
    
    ' Bildschirmanzeige zum aktiven Objekt machen
    DoCmd.SelectObject acReport, repName, False
        
    If Reports(repName).Printer.DeviceName <> Application.Printers(KARTENDRUCKER).DeviceName Then
        ' Ausdruck über Druckerdialog
        DoCmd.RunCommand acCmdPrint
    Else
        DoCmd.OpenReport repName, acViewNormal
    End If
    
    btnCloseRep_Click
    
End Sub


Private Sub Befehl5_Click()
    btnCloseRep_Click
End Sub




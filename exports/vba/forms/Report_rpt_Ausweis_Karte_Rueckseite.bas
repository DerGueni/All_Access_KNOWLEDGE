VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Report_rpt_Ausweis_Karte_Rueckseite"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Const frmHlp = "_frmHlp_rptClose"

Dim KARTENDRUCKER As String 'Papierformat: CR80 !


Private Sub Report_Load()

Dim repName As String

    KARTENDRUCKER = Get_Priv_Property("prp_Kartendrucker")
    repName = Me.Name
    
    If Me.Printer.DeviceName <> Application.Printers(KARTENDRUCKER).DeviceName Then
        If fctIsFormOpen(frmHlp) Then DoCmd.Close acForm, frmHlp, acSaveNo
        DoCmd.Close acReport, repName, acSaveNo
        'Querformat
        AusrichtungSetzen repName, False, KARTENDRUCKER
        'öffnen
        DoCmd.OpenReport repName, acViewReport
    End If

End Sub


Private Sub Report_Open(Cancel As Integer)
    
    'Hilfsformular
    If Not fctIsFormOpen(frmHlp) Then DoCmd.OpenForm frmHlp, , , , , , Me.Name

End Sub


Private Sub Report_Current()

    DoCmd.Maximize
    
End Sub


Private Sub Report_Close()
    
    If fctIsFormOpen(frmHlp) Then
        DoCmd.Close acForm, frmHlp, acSaveNo
    End If
    
End Sub

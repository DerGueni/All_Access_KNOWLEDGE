VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_N_AuswahlMaster"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Befehl0_Click()
Auto_Festangestellte_Zuordnen
DoCmd.Close

End Sub

Private Sub Befehl2_Click()

    On Error GoTo ErrorHandler
    

    
    ' Vollständiger Workflow starten
    mod_N_Loewensaal.RunLoewensaalSync_WithWebScan
    
    ' Formular aktualisieren
    Me.Requery
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Fehler bei Synchronisation:" & vbCrLf & Err.description, vbCritical
    DoCmd.Close
    
End Sub


Private Sub Befehl3_Click()
DoCmd.Close

End Sub

Private Sub Befehl5_Click()
Auto_MA_Zuordnung_Sport_Venues
DoCmd.Close

End Sub
'
'Private Sub Befehl6_Click()
'RunLoewensaalSync
'Auto_Festangestellte_Zuordnen
'Auto_MA_Zuordnung_Sport_Venues
'End Sub

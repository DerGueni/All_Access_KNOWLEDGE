VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_JJJJJJ"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdN_TemplateAction_Click()
    On Error GoTo ErrorHandler
    
    ' Template-Button Action
    MsgBox "Template-Button wurde geklickt!" & vbCrLf & _
           "Formular: frm_template" & vbCrLf & _
           "Button: cmdN_TemplateAction" & vbCrLf & _
           "Zeit: " & Now(), vbInformation, "Template Action"
    
    ' Hier können weitere Template-Aktionen hinzugefügt werden
    ' Beispiel: DoCmd.OpenForm "frm_N_NeuesFormular"
    ' Beispiel: Call Template_Funktion()
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Fehler in cmdN_TemplateAction_Click: " & Err.description, vbCritical, "Fehler"
End Sub



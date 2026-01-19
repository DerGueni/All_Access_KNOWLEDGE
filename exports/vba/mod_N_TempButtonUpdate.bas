Attribute VB_Name = "mod_N_TempButtonUpdate"
Option Compare Database
Option Explicit


Public Sub UpdateHTMLAnsichtButton()
    On Error GoTo ErrorHandler
    
    Dim frm As Form
    Dim ctl As control
    
    ' Formular im Entwurfsmodus oeffnen
    DoCmd.OpenForm "frm_va_Auftragstamm", acDesign
    Set frm = Forms("frm_va_Auftragstamm")
    
    ' Button finden und OnClick aendern
    For Each ctl In frm.Controls
        If ctl.Name = "btnHTMLAnsicht" Then
            ctl.OnClick = "=OpenAuftragstamm_WebView2([ID])"
            Debug.Print "Button OnClick geaendert auf: " & ctl.OnClick
            Exit For
        End If
    Next ctl
    
    ' Formular speichern und schliessen
    DoCmd.Close acForm, "frm_va_Auftragstamm", acSaveYes
    
    MsgBox "Button 'HTML Ansicht' wurde aktualisiert!" & vbCrLf & _
           "Neue Funktion: OpenAuftragstamm_WebView2([ID])", vbInformation, "CONSYS"
    Exit Sub
    
ErrorHandler:
    MsgBox "Fehler: " & Err.description, vbCritical
    DoCmd.Close acForm, "frm_va_Auftragstamm", acSaveNo
End Sub



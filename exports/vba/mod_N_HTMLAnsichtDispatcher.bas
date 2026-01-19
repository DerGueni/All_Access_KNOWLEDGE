Attribute VB_Name = "mod_N_HTMLAnsichtDispatcher"
Option Compare Database
Option Explicit


Public Function HTMLAnsichtOeffnen() As Boolean
    On Error GoTo ErrorHandler
    
    Dim frmName As String
    Dim recordId As Long
    
    ' Aktives Formular ermitteln
    If Screen.ActiveForm Is Nothing Then
        MsgBox "Kein Formular aktiv!", vbExclamation
        HTMLAnsichtOeffnen = False
        Exit Function
    End If
    
    frmName = Screen.ActiveForm.Name
    
    ' Je nach Formular die richtige WebView2-Funktion aufrufen
    Select Case frmName
        Case "frm_va_Auftragstamm"
            recordId = Nz(Screen.ActiveForm!ID, 0)
            Call OpenAuftragstamm_WebView2(recordId)
            
        Case "frm_MA_Mitarbeiterstamm", "frm_ma_Mitarbeiterstamm"
            recordId = Nz(Screen.ActiveForm!ID, 0)
            Call OpenMitarbeiterstamm_WebView2(recordId)
            
        Case "frm_KD_Kundenstamm"
            recordId = Nz(Screen.ActiveForm!kun_ID, 0)
            Call OpenKundenstamm_WebView2(recordId)
            
        Case "frm_OB_Objekt"
            recordId = Nz(Screen.ActiveForm!ID, 0)
            Call OpenObjekt_WebView2(recordId)
            
        Case "frm_DP_Dienstplan_Objekt", "frm_N_DP_Dienstplan_MA"
            Call OpenDienstplan_WebView2(Date)
            
        Case Else
            MsgBox "Fuer Formular '" & frmName & "' ist keine HTML-Ansicht konfiguriert.", vbInformation
            HTMLAnsichtOeffnen = False
            Exit Function
    End Select
    
    HTMLAnsichtOeffnen = True
    Exit Function
    
ErrorHandler:
    MsgBox "Fehler beim Oeffnen der HTML-Ansicht:" & vbCrLf & Err.description, vbCritical
    HTMLAnsichtOeffnen = False
End Function


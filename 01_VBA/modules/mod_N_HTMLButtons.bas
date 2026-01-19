Attribute VB_Name = "mod_N_HTMLButtons"
' =====================================================
' mod_N_HTMLButtons
' Button-Handler für HTML-Formulare
' KORRIGIERT: 13.01.2026 - Verwendet Browser-Modus (forms3)
' =====================================================

' Aufruf aus Mitarbeiterstamm: =btnHTMLAnsicht_MA_Click([ID])
Public Function btnHTMLAnsicht_MA_Click(MA_ID As Long)
    mod_N_WebView2_forms3.OpenMitarbeiterstamm_Browser MA_ID
End Function

' Aufruf aus Kundenstamm: =btnHTMLAnsicht_KD_Click([kun_Id])
Public Function btnHTMLAnsicht_KD_Click(KD_ID As Long)
    mod_N_WebView2_forms3.OpenKundenstamm_Browser KD_ID
End Function

' Aufruf aus Auftragsverwaltung: =btnHTMLAnsicht_VA_Click([ID])
Public Function btnHTMLAnsicht_VA_Click(VA_ID As Long)
    mod_N_WebView2_forms3.OpenAuftragstamm_Browser VA_ID
End Function

' Aufruf aus Objektverwaltung: =btnHTMLAnsicht_OB_Click([ID])
Public Function btnHTMLAnsicht_OB_Click(OB_ID As Long)
    mod_N_WebView2_forms3.OpenObjekt_Browser OB_ID
End Function

' Direkter Test
Public Sub TestHTMLForms()
    MsgBox "HTML-Forms Integration aktiv!" & vbCrLf & _
           "API Server: http://localhost:5000" & vbCrLf & _
           "Öffne Auftragsverwaltung...", vbInformation, "CONSYS HTML Test"
    ' Test mit Auftrag ID 9391
    mod_N_WebView2_forms3.OpenAuftragstamm_Browser 9391
End Sub

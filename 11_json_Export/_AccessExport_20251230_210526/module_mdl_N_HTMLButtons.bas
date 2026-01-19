
' Button-Handler für HTML-Formulare
Option Compare Database
Option Explicit

' Aufruf aus Mitarbeiterstamm: =btnHTMLAnsicht_MA_Click([ID])
Public Function btnHTMLAnsicht_MA_Click(MA_ID As Long)
    Call OpenMitarbeiterstammHTML(MA_ID)
End Function

' Aufruf aus Kundenstamm: =btnHTMLAnsicht_KD_Click([kun_Id])
Public Function btnHTMLAnsicht_KD_Click(KD_ID As Long)
    Call OpenKundenstammHTML(KD_ID)
End Function

' Aufruf aus Auftragsverwaltung: =btnHTMLAnsicht_VA_Click([ID])
Public Function btnHTMLAnsicht_VA_Click(VA_ID As Long)
    Call OpenAuftragsverwaltungHTML(VA_ID)
End Function

' Direkter Test
Public Sub TestHTMLForms()
    MsgBox "HTML-Forms Integration aktiv!", vbInformation, "Test"
    ' Test mit Mitarbeiter ID 707
    Call OpenMitarbeiterstammHTML(707)
End Sub
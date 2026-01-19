' CONSEC ULTRA-SIMPLE - NUR DAS NÖTIGSTE
' ================================================
' Eine einzige Funktion die funktioniert
' ================================================

Option Compare Database
Option Explicit

Public Sub Start()
    MsgBox "CONSEC System ist bereit!", vbInformation, "CONSEC"
    
    ' Dashboard-Formular öffnen falls vorhanden
    Dim frm As AccessObject
    For Each frm In CurrentProject.AllForms
        If frm.Name Like "*Dashboard*" Or frm.Name Like "*Haupt*" Or frm.Name Like "*Menu*" Then
            DoCmd.OpenForm frm.Name
            Exit Sub
        End If
    Next frm
    
    MsgBox "Kein Hauptformular gefunden.", vbInformation
End Sub

Public Function GetStatus() As String
    GetStatus = "System läuft - " & Now()
End Function
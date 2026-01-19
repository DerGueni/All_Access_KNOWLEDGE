Option Compare Database
Option Explicit

Public Sub Insert_Form_Code()
    Dim vbProj As Object
    Dim vbComp As Object
    Dim codeMod As Object
    
    Set vbProj = Application.vbe.ActiveVBProject
    
    ' Code für frm_MA_Mitarbeiterstamm
    Dim codeMA As String
    codeMA = "Private Sub btn_Dokumente_Click()" & vbCrLf & _
             "    If Not IsNull(Me.ID) Then" & vbCrLf & _
             "        DoCmd.OpenForm ""frm_MA_Dokumente"", , , ""MA_ID="" & Me.ID" & vbCrLf & _
             "    Else" & vbCrLf & _
             "        MsgBox ""Bitte zuerst Mitarbeiter auswählen!"", vbExclamation" & vbCrLf & _
             "    End If" & vbCrLf & _
             "End Sub" & vbCrLf & vbCrLf & _
             "Private Sub btn_OrdnerOeffnen_Click()" & vbCrLf & _
             "    If Not IsNull(Me.ID) Then" & vbCrLf & _
             "        OeffnePersonalaktenOrdner Me.ID" & vbCrLf & _
             "    Else" & vbCrLf & _
             "        MsgBox ""Bitte zuerst Mitarbeiter auswählen!"", vbExclamation" & vbCrLf & _
             "    End If" & vbCrLf & _
             "End Sub"
    
    On Error Resume Next
    Set vbComp = vbProj.VBComponents("frm_MA_Mitarbeiterstamm")
    On Error GoTo 0
    
    If Not vbComp Is Nothing Then
        Set codeMod = vbComp.codeModule
        Dim lineCount As Long
        lineCount = codeMod.CountOfLines
        codeMod.InsertLines lineCount + 1, codeMA
        MsgBox "Code zu frm_MA_Mitarbeiterstamm hinzugefügt", vbInformation
    Else
        MsgBox "Formular frm_MA_Mitarbeiterstamm nicht gefunden oder hat kein Code-Modul", vbExclamation
    End If
    
    Set codeMod = Nothing
    Set vbComp = Nothing
    Set vbProj = Nothing
End Sub
Attribute VB_Name = "mdl_TEMP_CodeInserter"
Option Compare Database
Option Explicit

Public Sub Insert_Form_Code()
    Dim vbproj As Object
    Dim vbcomp As Object
    Dim codeMod As Object
    
    Set vbproj = Application.vbe.ActiveVBProject
    
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
    Set vbcomp = vbproj.VBComponents("frm_MA_Mitarbeiterstamm")
    On Error GoTo 0
    
    If Not vbcomp Is Nothing Then
        Set codeMod = vbcomp.codeModule
        Dim lineCount As Long
        lineCount = codeMod.CountOfLines
        codeMod.InsertLines lineCount + 1, codeMA
        MsgBox "Code zu frm_MA_Mitarbeiterstamm hinzugefügt", vbInformation
    Else
        MsgBox "Formular frm_MA_Mitarbeiterstamm nicht gefunden oder hat kein Code-Modul", vbExclamation
    End If
    
    Set codeMod = Nothing
    Set vbcomp = Nothing
    Set vbproj = Nothing
End Sub


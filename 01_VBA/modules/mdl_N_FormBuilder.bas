Attribute VB_Name = "mdl_N_FormBuilder"
Public Function FindPositionFunction() As String
    On Error Resume Next
    Dim vbcomp As Object
    Dim codeModule As Object
    Dim result As String
    Dim i As Long
    Dim lineText As String
    result = "Suche nach OpenPositionszuordnungFromAuftrag:" & vbCrLf
    For Each vbcomp In Application.vbe.ActiveVBProject.VBComponents
        Set codeModule = vbcomp.codeModule
        For i = 1 To codeModule.CountOfLines
            lineText = codeModule.lines(i, 1)
            If InStr(1, lineText, "OpenPositionszuordnungFromAuftrag", vbTextCompare) > 0 Then
                result = result & vbcomp.Name & " Line " & i & ": " & Left(lineText, 80) & vbCrLf
            End If
        Next i
    Next vbcomp
    FindPositionFunction = result
End Function

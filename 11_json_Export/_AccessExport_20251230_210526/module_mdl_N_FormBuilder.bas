Public Function FindPositionFunction() As String
    On Error Resume Next
    Dim vbComp As Object
    Dim codeModule As Object
    Dim result As String
    Dim i As Long
    Dim lineText As String
    result = "Suche nach OpenPositionszuordnungFromAuftrag:" & vbCrLf
    For Each vbComp In Application.vbe.ActiveVBProject.VBComponents
        Set codeModule = vbComp.codeModule
        For i = 1 To codeModule.CountOfLines
            lineText = codeModule.lines(i, 1)
            If InStr(1, lineText, "OpenPositionszuordnungFromAuftrag", vbTextCompare) > 0 Then
                result = result & vbComp.Name & " Line " & i & ": " & Left(lineText, 80) & vbCrLf
            End If
        Next i
    Next vbComp
    FindPositionFunction = result
End Function
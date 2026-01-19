Attribute VB_Name = "mdl_CodeUpdater"
Option Compare Database
Option Explicit

Public Sub UpdateButtonCode()
    Dim vbe As Object
    Dim mod1 As Object
    Dim i As Long, startLine As Long, endLine As Long
    Dim found As Boolean
    
    Set vbe = Application.vbe.VBProjects(1).VBComponents("Form_frm_VA_Auftragstamm").codeModule
    
    For i = 1 To vbe.CountOfLines
        If InStr(vbe.lines(i, 1), "btn_Posliste_oeffnen_Click") > 0 Then
            startLine = i
            found = True
        End If
        If found And InStr(vbe.lines(i, 1), "End Sub") > 0 And i > startLine Then
            endLine = i
            Exit For
        End If
    Next i
    
    If found Then
        vbe.DeleteLines startLine, endLine - startLine + 1
    End If
End Sub

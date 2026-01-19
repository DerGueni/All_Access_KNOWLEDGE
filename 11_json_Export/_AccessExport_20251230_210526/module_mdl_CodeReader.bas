Public Function ReadFormModule() As String
    Dim cm As Object
    Set cm = Application.vbe.VBProjects(1).VBComponents("Form_frm_N_MA_VA_Positionszuordnung").codeModule
    ReadFormModule = cm.lines(1, cm.CountOfLines)
End Function
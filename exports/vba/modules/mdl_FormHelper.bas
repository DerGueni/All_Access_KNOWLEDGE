Attribute VB_Name = "mdl_FormHelper"
Public Function CheckFormCode(strFormName As String, strSearch As String) As Boolean
    Dim frm As Form
    Dim mdl As Module
    
    DoCmd.OpenForm strFormName, acDesign, , , , acHidden
    Set frm = Forms(strFormName)
    Set mdl = frm.Module
    
    CheckFormCode = (InStr(1, mdl.lines(1, mdl.CountOfLines), strSearch) > 0)
    
    DoCmd.Close acForm, strFormName, acSaveNo
End Function

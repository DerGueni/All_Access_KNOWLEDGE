Attribute VB_Name = "mdl_CreateReport"
Public Sub FixReportLayout()
    On Error Resume Next
    
    Dim rpt As Report
    Dim ctl As control
    
    DoCmd.OpenReport "rpt_Ordnerkonzept", acViewDesign
    Set rpt = Reports("rpt_Ordnerkonzept")
    
    ' Alle Controls aus Layout entfernen
    For Each ctl In rpt.Controls
        ctl.InSelection = True
    Next
    
    DoCmd.RunCommand acCmdRemoveLayout
    
    ' Header-Hoehe setzen
    rpt.Section(3).height = 1500
    rpt.Section(0).height = 400
    
    DoCmd.Close acReport, "rpt_Ordnerkonzept", acSaveYes
End Sub

Attribute VB_Name = "mdl_ReportBuilder"
Public Sub CreateOrdnerkonzeptReport()
    Dim rpt As Report
    Dim ctl As control
    Dim lngTop As Long
    Dim lngLeft As Long
    Dim i As Integer
    
    On Error Resume Next
    DoCmd.DeleteObject acReport, "rpt_Ordnerkonzept"
    On Error GoTo 0
    
    Set rpt = CreateReport
    
    rpt.width = 15000
    rpt.Section(3).height = 1500
    rpt.Section(0).height = 400
    
    lngTop = 50
    
    Set ctl = CreateReportControl(rpt.Name, acLabel, 3, , "CONSEC SECURITY NUERNBERG", 100, lngTop, 8000, 350)
    ctl.Name = "lblFirma"
    ctl.FontSize = 14
    ctl.FontBold = True
    
    Set ctl = CreateReportControl(rpt.Name, acLabel, 3, , "Veranstaltungsservice & Sicherheitsdienst oHG", 8200, lngTop, 6000, 350)
    ctl.Name = "lblFirma2"
    ctl.FontSize = 10
    
    lngTop = 450
    
    Set ctl = CreateReportControl(rpt.Name, acTextBox, 3, , , 100, lngTop, 2500, 300)
    ctl.Name = "txtAuftrag"
    
    Set ctl = CreateReportControl(rpt.Name, acTextBox, 3, , , 3500, lngTop, 1500, 300)
    ctl.Name = "txtOrt"
    
    Set ctl = CreateReportControl(rpt.Name, acTextBox, 3, , , 5200, lngTop, 2000, 300)
    ctl.Name = "txtObjekt"
    
    Set ctl = CreateReportControl(rpt.Name, acTextBox, 3, , , 7400, lngTop, 2000, 300)
    ctl.Name = "txtDatum"
    
    Set ctl = CreateReportControl(rpt.Name, acTextBox, 3, , , 12000, lngTop, 2500, 300)
    ctl.Name = "txtVeranstalter"
    
    lngTop = 800
    
    Set ctl = CreateReportControl(rpt.Name, acLabel, 3, , "Einlass:", 100, lngTop, 700, 250)
    Set ctl = CreateReportControl(rpt.Name, acTextBox, 3, , , 850, lngTop, 1000, 250)
    ctl.Name = "txtEinlass"
    
    Set ctl = CreateReportControl(rpt.Name, acLabel, 3, , "Show:", 2500, lngTop, 600, 250)
    Set ctl = CreateReportControl(rpt.Name, acTextBox, 3, , , 3150, lngTop, 1000, 250)
    ctl.Name = "txtShow"
    
    Set ctl = CreateReportControl(rpt.Name, acLabel, 3, , "Ende:", 4800, lngTop, 600, 250)
    Set ctl = CreateReportControl(rpt.Name, acTextBox, 3, , , 5450, lngTop, 1200, 250)
    ctl.Name = "txtEnde"
    
    Set ctl = CreateReportControl(rpt.Name, acLabel, 3, , "Dienstbeginn", 7000, lngTop, 1500, 250)
    
    lngTop = 1150
    
    Set ctl = CreateReportControl(rpt.Name, acLabel, 3, , "Gesamt", 100, lngTop, 800, 250)
    ctl.FontBold = True
    
    Set ctl = CreateReportControl(rpt.Name, acLabel, 3, , "Security-Position", 1000, lngTop, 3000, 250)
    ctl.FontBold = True
    
    Set ctl = CreateReportControl(rpt.Name, acLabel, 3, , "Info", 4200, lngTop, 1500, 250)
    ctl.FontBold = True
    
    lngLeft = 5800
    For i = 1 To 4
        Set ctl = CreateReportControl(rpt.Name, acTextBox, 3, , , lngLeft, lngTop, 900, 250)
        ctl.Name = "txtZeit" & i
        lngLeft = lngLeft + 1000
    Next i
    
    Set ctl = CreateReportControl(rpt.Name, acLabel, 3, , "Name", 10000, lngTop, 4000, 250)
    ctl.FontBold = True
    
    lngTop = 50
    
    Set ctl = CreateReportControl(rpt.Name, acTextBox, 0, , , 100, lngTop, 800, 300)
    ctl.Name = "txtAnzahl"
    
    Set ctl = CreateReportControl(rpt.Name, acTextBox, 0, , , 1000, lngTop, 3000, 300)
    ctl.Name = "txtGruppe"
    
    Set ctl = CreateReportControl(rpt.Name, acTextBox, 0, , , 4200, lngTop, 1500, 300)
    ctl.Name = "txtZusatztext"
    
    lngLeft = 5800
    For i = 1 To 4
        Set ctl = CreateReportControl(rpt.Name, acTextBox, 0, , , lngLeft, lngTop, 900, 300)
        ctl.Name = "txtAnzZeit" & i
        lngLeft = lngLeft + 1000
    Next i
    
    Set ctl = CreateReportControl(rpt.Name, acTextBox, 0, , , 10000, lngTop, 4000, 300)
    ctl.Name = "txtMAName"
    
    DoCmd.Save acReport, rpt.Name
    DoCmd.Close acReport, rpt.Name, acSaveYes
    
    DoCmd.Rename "rpt_Ordnerkonzept", acReport, rpt.Name
    
    MsgBox "Report rpt_Ordnerkonzept erstellt!", vbInformation
End Sub

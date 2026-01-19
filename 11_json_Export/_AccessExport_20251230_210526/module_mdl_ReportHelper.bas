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
    rpt.Name = "rpt_Ordnerkonzept_Temp"
    
    ' Report-Eigenschaften
    rpt.width = 15000  ' ca. 26 cm
    rpt.Section(acHeader).height = 1500
    rpt.Section(acDetail).height = 400
    
    ' === KOPFBEREICH (Header) ===
    lngTop = 50
    
    ' Zeile 1: CONSEC SECURITY NUERNBERG
    Set ctl = CreateReportControl(rpt.Name, acLabel, acHeader, , "CONSEC SECURITY NÜRNBERG", 100, lngTop, 8000, 350)
    ctl.Name = "lblFirma"
    ctl.FontSize = 14
    ctl.FontBold = True
    
    Set ctl = CreateReportControl(rpt.Name, acLabel, acHeader, , "Veranstaltungsservice & Sicherheitsdienst oHG", 8200, lngTop, 6000, 350)
    ctl.Name = "lblFirma2"
    ctl.FontSize = 10
    
    lngTop = 450
    
    ' Zeile 2: Auftrag, Ort, Objekt, Datum, Veranstalter
    Set ctl = CreateReportControl(rpt.Name, acTextBox, acHeader, , , 100, lngTop, 2500, 300)
    ctl.Name = "txtAuftrag"
    ctl.ControlSource = "Auftrag"
    ctl.FontBold = True
    
    Set ctl = CreateReportControl(rpt.Name, acTextBox, acHeader, , , 3500, lngTop, 1500, 300)
    ctl.Name = "txtOrt"
    ctl.ControlSource = "Ort"
    
    Set ctl = CreateReportControl(rpt.Name, acTextBox, acHeader, , , 5200, lngTop, 2000, 300)
    ctl.Name = "txtObjekt"
    ctl.ControlSource = "Objekt"
    
    Set ctl = CreateReportControl(rpt.Name, acTextBox, acHeader, , , 7400, lngTop, 2000, 300)
    ctl.Name = "txtDatum"
    ctl.ControlSource = "VADatum"
    ctl.Format = "dd.mm.yyyy"
    
    Set ctl = CreateReportControl(rpt.Name, acTextBox, acHeader, , , 12000, lngTop, 2500, 300)
    ctl.Name = "txtVeranstalter"
    ctl.ControlSource = "kun_Firma"
    
    lngTop = 800
    
    ' Zeile 3: Einlass, Show, Ende, Dienstbeginn
    Set ctl = CreateReportControl(rpt.Name, acLabel, acHeader, , "Einlass:", 100, lngTop, 700, 250)
    Set ctl = CreateReportControl(rpt.Name, acTextBox, acHeader, , , 850, lngTop, 1000, 250)
    ctl.Name = "txtEinlass"
    
    Set ctl = CreateReportControl(rpt.Name, acLabel, acHeader, , "Show:", 2500, lngTop, 600, 250)
    Set ctl = CreateReportControl(rpt.Name, acTextBox, acHeader, , , 3150, lngTop, 1000, 250)
    ctl.Name = "txtShow"
    
    Set ctl = CreateReportControl(rpt.Name, acLabel, acHeader, , "Ende:", 4800, lngTop, 600, 250)
    Set ctl = CreateReportControl(rpt.Name, acTextBox, acHeader, , , 5450, lngTop, 1200, 250)
    ctl.Name = "txtEnde"
    
    Set ctl = CreateReportControl(rpt.Name, acLabel, acHeader, , "Dienstbeginn", 7000, lngTop, 1500, 250)
    
    lngTop = 1150
    
    ' Zeile 4: Header fuer Positionen
    Set ctl = CreateReportControl(rpt.Name, acLabel, acHeader, , "Gesamt", 100, lngTop, 800, 250)
    ctl.FontBold = True
    
    Set ctl = CreateReportControl(rpt.Name, acLabel, acHeader, , "Security-Position", 1000, lngTop, 3000, 250)
    ctl.FontBold = True
    
    Set ctl = CreateReportControl(rpt.Name, acLabel, acHeader, , "Info", 4200, lngTop, 1500, 250)
    ctl.FontBold = True
    
    ' Zeit-Spalten (4 Stueck) - werden spaeter dynamisch befuellt
    lngLeft = 5800
    For i = 1 To 4
        Set ctl = CreateReportControl(rpt.Name, acTextBox, acHeader, , , lngLeft, lngTop, 900, 250)
        ctl.Name = "txtZeit" & i
        ctl.Format = "hh:nn"
        lngLeft = lngLeft + 1000
    Next i
    
    Set ctl = CreateReportControl(rpt.Name, acLabel, acHeader, , "Name", 10000, lngTop, 4000, 250)
    ctl.FontBold = True
    
    ' === DETAILBEREICH ===
    lngTop = 50
    
    ' Gesamt (Anzahl)
    Set ctl = CreateReportControl(rpt.Name, acTextBox, acDetail, , , 100, lngTop, 800, 300)
    ctl.Name = "txtAnzahl"
    ctl.ControlSource = "Anzahl"
    
    ' Security-Position (Gruppe)
    Set ctl = CreateReportControl(rpt.Name, acTextBox, acDetail, , , 1000, lngTop, 3000, 300)
    ctl.Name = "txtGruppe"
    ctl.ControlSource = "Gruppe"
    
    ' Info (Zusatztext)
    Set ctl = CreateReportControl(rpt.Name, acTextBox, acDetail, , , 4200, lngTop, 1500, 300)
    ctl.Name = "txtZusatztext"
    ctl.ControlSource = "Zusatztext"
    
    ' Zeit-Spalten Detail (4 Stueck) - fuer Anzahl pro Schicht
    lngLeft = 5800
    For i = 1 To 4
        Set ctl = CreateReportControl(rpt.Name, acTextBox, acDetail, , , lngLeft, lngTop, 900, 300)
        ctl.Name = "txtAnzZeit" & i
        lngLeft = lngLeft + 1000
    Next i
    
    ' Name
    Set ctl = CreateReportControl(rpt.Name, acTextBox, acDetail, , , 10000, lngTop, 4000, 300)
    ctl.Name = "txtMAName"
    
    DoCmd.Close acReport, rpt.Name, acSaveYes
    DoCmd.Rename "rpt_Ordnerkonzept", acReport, "rpt_Ordnerkonzept_Temp"
    
    MsgBox "Report rpt_Ordnerkonzept erstellt!", vbInformation
End Sub
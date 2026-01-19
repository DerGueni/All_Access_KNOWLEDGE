Option Compare Database
Option Explicit


Function Stundenliste_erstellen(VA_ID As Long, Optional MA_ID As Long)

Dim xlApp As Object, xlWb As Object, xlWs As Object, i As Integer, sql As String, rs As Recordset, rows As Integer, Count As Integer, Datum_Datei As String, _
VADatum As Date, MA_Start As Date, MA_Ende As Date, StdGes As Double, StdTag As Double, stdNACHT As Double, stdSONNTAG As Double, StdFeiertag As Double

    
    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = True
    xlApp.WindowState = -4137 'xlMaximized
    Set xlWb = xlApp.Workbooks.Add
    Set xlWs = xlWb.Sheets(1)

   
    
    With xlWs
        .Range("A2") = TLookup("Auftrag", AUFTRAGSTAMM, "ID = " & VA_ID)
        .Range("D2") = TLookup("Ort", AUFTRAGSTAMM, "ID = " & VA_ID)
        .Range("F2") = TLookup("Objekt", AUFTRAGSTAMM, "ID = " & VA_ID)
        If Not IsInitial(MA_ID) Then .Range("A2") = .Range("A2") & " " & TLookup("Nachname", MASTAMM, "ID = " & MA_ID) & " " & TLookup("Vorname", MASTAMM, "ID = " & MA_ID)
        .Range("A2").Font.FontStyle = "Fett"
        .Range("A4") = "Datum"
        .Range("B4") = "Name"
        .Range("C4") = "Vorname"
        .Range("D4") = "von"
        .Range("E4") = "bis"
        .Range("F4") = "Gesamt"
        .Range("G4") = "Tag"
        .Range("H4") = "Nacht"
        .Range("I4") = "Sonntag"
        .Range("J4") = "Feiertag"
        .Range("K4") = "Bezeichnung"
        .Range("A4:K4").Font.FontStyle = "Fett"
        
        sql = "SELECT * FROM " & ZUORDNUNG & " WHERE VA_ID = " & VA_ID
        
        If Not IsInitial(MA_ID) Then sql = sql & " AND MA_ID = " & MA_ID
        
        Set rs = CurrentDb.OpenRecordset(sql, 8)
        i = 5
        Do
             VADatum = rs.fields("VADatum")
             MA_Start = Format(rs.fields("MA_Start"), "HH:MM")
             MA_Ende = rs.fields("MA_Ende")
             StdGes = Round(stunden(MA_Start, MA_Ende), 2)
             stdNACHT = Round(Stunden_Zuschlag(VADatum, MA_Start, MA_Ende, "NACHT"), 2)
             stdSONNTAG = Round(Stunden_Zuschlag(VADatum, MA_Start, MA_Ende, "SONNTAG") + Stunden_Zuschlag(VADatum, MA_Start, MA_Ende, "SONNTAGNACHT"), 2)
             StdFeiertag = Round(Stunden_Zuschlag(VADatum, MA_Start, MA_Ende, "FEIERTAG") + Stunden_Zuschlag(VADatum, MA_Start, MA_Ende, "FEIERTAGNACHT"), 2)
             StdTag = Round(StdGes - stdNACHT - stdSONNTAG - StdFeiertag, 2)
            .Range("A" & i) = VADatum
            .Range("B" & i) = TLookup("Nachname", MASTAMM, "ID = " & rs.fields("MA_ID"))
            .Range("C" & i) = TLookup("Vorname", MASTAMM, "ID = " & rs.fields("MA_ID"))
            .Range("D" & i) = rs.fields("MA_Start")
            .Range("D" & i).NumberFormat = "hh:mm;@"
            .Range("E" & i) = rs.fields("MA_Ende")
            .Range("E" & i).NumberFormat = "hh:mm;@"
            .Range("F" & i) = StdGes
            .Range("G" & i) = StdTag
            .Range("H" & i) = stdNACHT
            .Range("I" & i) = stdSONNTAG
            .Range("J" & i) = StdFeiertag
            .Range("K" & i) = rs.fields("Bemerkungen")
            .Range("F:J").HorizontalAlignment = xlRight
            .Range("D:E").HorizontalAlignment = xlCenter
            .Range("B:C").EntireColumn.AutoFit
            .Range("K:K").EntireColumn.AutoFit

            rs.MoveNext
            i = i + 1
            
        Loop Until rs.EOF
        
        rows = i - 4
        Count = .UsedRange.rows.Count
        '.rows(4).AutoFilter
        
    End With
    
    With xlWs.Sort
        .SortFields.clear
        .SortFields.Add key:=xlWs.Range("A4:A" & Count + 1), SortOn:=0, Order:=1, DataOption:=0 ', SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortNormal
        .SortFields.Add key:=xlWs.Range("D4:D" & Count + 1), SortOn:=0, Order:=1, DataOption:=0
        .SortFields.Add key:=xlWs.Range("B4:B" & Count + 1), SortOn:=0, Order:=1, DataOption:=0
        .SetRange xlWs.Range("A4:K" & Count + 1)
        .Header = 1
        .MatchCase = False
        .Orientation = 1
        .SortMethod = 1
        .Apply
        
    End With
    
    With xlWs
        .Range("A5:A" & .UsedRange.rows.Count + 1).NumberFormat = "DDD. DD.MM.YY"
        .Range("F" & Count + 3).FormulaR1C1 = "=SUM(R[-" & rows & "]C:R[-2]C)"
        .Range("G" & Count + 3).FormulaR1C1 = "=SUM(R[-" & rows & "]C:R[-2]C)"
        .Range("H" & Count + 3).FormulaR1C1 = "=SUM(R[-" & rows & "]C:R[-2]C)"
        .Range("I" & Count + 3).FormulaR1C1 = "=SUM(R[-" & rows & "]C:R[-2]C)"
        .Range("J" & Count + 3).FormulaR1C1 = "=SUM(R[-" & rows & "]C:R[-2]C)"
        .PageSetup.Orientation = 2 'xlLandscape
        .PageSetup.PaperSize = 9 'xlPaperA4
        .PageSetup.Zoom = False
        .PageSetup.FitToPagesWide = 1
        .PageSetup.FitToPagesTall = 1
        .PageSetup.PrintArea = .UsedRange.address
        
    End With
        

    
    Datum_Datei = Format(xlWs.Range("A5"), "MM-DD-YY")
    xlWb.SaveAs PfadPlanungAktuell & Datum_Datei & " " & xlWs.Range("A2") & " Namensliste" & ".xlsx"
    
End Function

'Function Stundenliste_erstellen(VA_ID As Long)
'
'Dim xlApp As Object, xlWB As Object, xlWS As Object, i As Integer, SQL As String, rs As Recordset, rows As Integer, count As Integer, Datum_Datei As String, _
'VADatum As Date, MA_Start As Date, MA_Ende As Date, StdGes As Double, StdTag As Double, stdNACHT As Double, stdSONNTAG As Double, StdFeiertag As Double
'
'
'    Set xlApp = CreateObject("Excel.Application")
'    xlApp.Visible = True
'    Set xlWB = xlApp.Workbooks.Add
'    Set xlWS = xlWB.sheets(1)
'
'    With xlWS
'        .Range("A2") = TLookup("Auftrag", "tbl_VA_Auftragstamm", "ID = " & VA_ID)
'        .Range("A2").Font.FontStyle = "Fett"
'        .Range("A4") = "Datum"
'        .Range("B4") = "Name"
'        .Range("C4") = "Vorname"
'        .Range("D4") = "von"
'        .Range("E4") = "bis"
'        .Range("F4") = "Gesamt"
'        .Range("G4") = "Tag"
'        .Range("H4") = "Nacht"
'        .Range("I4") = "Sonntag"
'        .Range("J4") = "Feiertag"
'        .Range("K4") = "Bezeichnung"
'        .Range("A4:K4").Font.FontStyle = "Fett"
'
'
'        SQL = "SELECT * FROM " & ZUORDNUNG & " WHERE VA_ID = " & VA_ID
'        Set rs = CurrentDb.OpenRecordset(SQL, 8)
'        i = 5
'        Do
'             VADatum = rs.Fields("VADatum")
'             MA_Start = Format(rs.Fields("MA_Start"), "HH:MM")
'             MA_Ende = rs.Fields("MA_Ende")
'             StdGes = Round(Stunden(MA_Start, MA_Ende), 2)
'             stdNACHT = Round(Stunden_Zuschlag(VADatum, MA_Start, MA_Ende, "NACHT"), 2)
'             stdSONNTAG = Round(Stunden_Zuschlag(VADatum, MA_Start, MA_Ende, "SONNTAG") + Stunden_Zuschlag(VADatum, MA_Start, MA_Ende, "SONNTAGNACHT"), 2)
'             StdFeiertag = Round(Stunden_Zuschlag(VADatum, MA_Start, MA_Ende, "FEIERTAG") + Stunden_Zuschlag(VADatum, MA_Start, MA_Ende, "FEIERTAGNACHT"), 2)
'             StdTag = Round(StdGes - stdNACHT - stdSONNTAG - StdFeiertag, 2)
'
'            .Range("A" & i) = Format(VADatum, "DDD. DD.MM.YY")
'            .Range("B" & i) = TLookup("Nachname", MASTAMM, "ID = " & rs.Fields("MA_ID"))
'            .Range("C" & i) = TLookup("Vorname", MASTAMM, "ID = " & rs.Fields("MA_ID"))
'            .Range("D" & i) = rs.Fields("MA_Start")
'            .Range("D" & i).NumberFormat = "h:mm;@"
'            .Range("E" & i) = rs.Fields("MA_Ende")
'            .Range("E" & i).NumberFormat = "h:mm;@"
'            .Range("F" & i) = StdGes
'            .Range("G" & i) = StdTag
'            .Range("H" & i) = stdNACHT
'            .Range("I" & i) = stdSONNTAG
'            .Range("J" & i) = StdFeiertag
'            .Range("K" & i) = rs.Fields("Bemerkungen")
'
'            rs.MoveNext
'            i = i + 1
'        Loop Until rs.EOF
'
'        rows = i - 4
'        count = xlWS.usedrange.rows.count
'        'xlWS.rows(4).AutoFilter
'        With xlWS.Sort
'            .SortFields.clear
'            .SortFields.Add Key:=xlWS.Range("A4:A" & count + 1), SortOn:=0, Order:=1, DataOption:=0 ', SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortNormal
'            .SortFields.Add Key:=xlWS.Range("D4:D" & count + 1), SortOn:=0, Order:=1, DataOption:=0
'            .SortFields.Add Key:=xlWS.Range("B4:B" & count + 1), SortOn:=0, Order:=1, DataOption:=0
'            .SetRange xlWS.Range("A4:K" & count + 1)
'            .Header = 1
'            .MatchCase = False
'            .Orientation = 1
'            .SortMethod = 1
'            .Apply
'        End With
'        With xlWS
'            .Range("F" & count + 3).FormulaR1C1 = "=SUM(R[-" & rows & "]C:R[-2]C)"
'            .Range("G" & count + 3).FormulaR1C1 = "=SUM(R[-" & rows & "]C:R[-2]C)"
'            .Range("H" & count + 3).FormulaR1C1 = "=SUM(R[-" & rows & "]C:R[-2]C)"
'            .Range("I" & count + 3).FormulaR1C1 = "=SUM(R[-" & rows & "]C:R[-2]C)"
'            .Range("J" & count + 3).FormulaR1C1 = "=SUM(R[-" & rows & "]C:R[-2]C)"
'        End With
'
'    End With
'
'    Datum_Datei = Format(xlWS.Range("A5"), "MM-DD-YY")
'    xlWB.SaveAs PfadPlanungAktuell & Datum_Datei & " " & xlWS.Range("A2") & " Namensliste"
'
'End Function
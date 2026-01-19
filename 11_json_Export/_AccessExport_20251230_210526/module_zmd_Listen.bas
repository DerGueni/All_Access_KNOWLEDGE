Function Stundenliste_erstellen(VA_ID As Long, Optional MA_ID As Long, Optional kun_ID As Long)

'ESS Sonderlocken:
'Kun_id 20730 ESS 1 Bereichswachen
'Kun_id 20760 ESS 2 Standwachen
'Kun_id 20761 ESS 3 Standpartys
    
Dim xlApp As Object, xlWb As Object, xlWs As Object, i As Integer, sql As String, rs As Recordset, rows As Integer, Count As Integer, Datum_Datei As String, _
VADatum As Date, MA_Start As Date, MA_Ende As Date, StdGes As Double, StdTag As Double, stdNACHT As Double, stdSONNTAG As Double, StdFeiertag As Double

'ESS Variablen
Dim sBemerkung As String, arrWords() As String, sHalle As String
Dim sVorHalle As String, sNachHalle As String
Dim j As Integer, iHalleIdx As Integer

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
        
        i = 4
        .Range("A" & i) = "Datum"
        .Range("B" & i) = "Name"
        .Range("C" & i) = "Vorname"
        .Range("D" & i) = "von"
        .Range("E" & i) = "bis"
        .Range("F" & i) = "Gesamt"
        .Range("G" & i) = "Tag"
        .Range("H" & i) = "Nacht"
        .Range("I" & i) = "Sonntag"
        .Range("J" & i) = "Feiertag"
        .Range("K" & i) = "Bezeichnung"
        .Range("L" & i) = "Fahrtkosten"
        .Range("A" & i & ":L" & i).Font.FontStyle = "Fett"
        
        'ESS Spaltenueberschriften
        If kun_ID = 20730 Or kun_ID = 20760 Or kun_ID = 20761 Then
            .Range("L" & i) = "Ist-Position"
            .Range("M" & i) = "Halle / Stand"
            .Range("N" & i) = "Name Standbetreiber"
            .Range("O" & i) = "Kommentar ESS"
            .Range("M" & i & ":N" & i).Font.FontStyle = "Fett"
            .Range("O" & i).Font.color = vbRed
        End If
        
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
            
            'Spalten K, L, M, N je nach Kunde
            If kun_ID = 20730 Or kun_ID = 20760 Or kun_ID = 20761 Then
                'ESS Sonderlogik
                .Range("L" & i).NumberFormat = "@"
                
                'Spalte K - Bezeichnung
                If kun_ID = 20730 Then .Range("K" & i) = "Bereichswache"
                If kun_ID = 20760 Then .Range("K" & i) = "Standwache"
                If kun_ID = 20761 Then .Range("K" & i) = "Standparty"
                
                'Bemerkungen splitten
                sBemerkung = Nz(rs.fields("Bemerkungen"), "")
                iHalleIdx = -1
                sVorHalle = ""
                sNachHalle = ""
                sHalle = ""
                
                'Halle-Position finden
                If InStr(sBemerkung, "Halle") > 0 Then
                    arrWords = Split(sBemerkung, " ")
                    For j = 0 To UBound(arrWords)
                        If arrWords(j) = "Halle" Then
                            iHalleIdx = j
                            Exit For
                        End If
                    Next j
                End If
                
                If kun_ID = 20760 Then
                    'Standwachen: Halle+Nr in M, Rest in N, L bleibt leer
                    If iHalleIdx >= 0 Then
                        If iHalleIdx + 1 <= UBound(arrWords) Then
                            .Range("M" & i) = arrWords(iHalleIdx) & " " & arrWords(iHalleIdx + 1)
                            If iHalleIdx + 2 <= UBound(arrWords) Then
                                sNachHalle = ""
                                For j = iHalleIdx + 2 To UBound(arrWords)
                                    sNachHalle = sNachHalle & arrWords(j) & " "
                                Next j
                                .Range("N" & i) = Trim(sNachHalle)
                            End If
                        End If
                    End If
                    
                ElseIf kun_ID = 20730 Then
                    'Bereichswachen: Mit Halle -> Halle in M, Rest in L. Ohne Halle -> alles in L
                    If iHalleIdx >= 0 Then
                        If iHalleIdx + 1 <= UBound(arrWords) Then
                            .Range("M" & i) = arrWords(iHalleIdx) & " " & arrWords(iHalleIdx + 1)
                            sVorHalle = ""
                            sNachHalle = ""
                            If iHalleIdx > 0 Then
                                For j = 0 To iHalleIdx - 1
                                    sVorHalle = sVorHalle & arrWords(j) & " "
                                Next j
                            End If
                            If iHalleIdx + 2 <= UBound(arrWords) Then
                                For j = iHalleIdx + 2 To UBound(arrWords)
                                    sNachHalle = sNachHalle & arrWords(j) & " "
                                Next j
                            End If
                            .Range("L" & i) = Trim(sVorHalle & sNachHalle)
                        End If
                    Else
                        'Kein Halle - alles in Spalte L
                        .Range("L" & i) = sBemerkung
                    End If
                    
                ElseIf kun_ID = 20761 Then
                    'Standpartys: Mit Halle -> Halle in M, alles NACH Halle in N, L bleibt leer. Ohne Halle -> alles in L
                    If iHalleIdx >= 0 Then
                        If iHalleIdx + 1 <= UBound(arrWords) Then
                            .Range("M" & i) = arrWords(iHalleIdx) & " " & arrWords(iHalleIdx + 1)
                            If iHalleIdx + 2 <= UBound(arrWords) Then
                                sNachHalle = ""
                                For j = iHalleIdx + 2 To UBound(arrWords)
                                    sNachHalle = sNachHalle & arrWords(j) & " "
                                Next j
                                .Range("N" & i) = Trim(sNachHalle)
                            End If
                        End If
                    Else
                        'Kein Halle - alles in Spalte L
                        .Range("L" & i) = sBemerkung
                    End If
                End If
                
            Else
                'Nicht-ESS Kunden - Standardverhalten
                .Range("K" & i) = rs.fields("Bemerkungen")
                .Range("L" & i) = rs.fields("PKW")
                .Range("L" & i).NumberFormat = "#,##0.00 " & Chr(128)
            End If
            
            rs.MoveNext
            i = i + 1
            
        Loop Until rs.EOF
        
        rows = i - 4
        Count = .UsedRange.rows.Count
        
    End With
    
    With xlWs.Sort
        .SortFields.clear
        .SortFields.Add key:=xlWs.Range("A4:A" & Count + 1), SortOn:=0, Order:=1, DataOption:=0
        .SortFields.Add key:=xlWs.Range("D4:D" & Count + 1), SortOn:=0, Order:=1, DataOption:=0
        .SortFields.Add key:=xlWs.Range("B4:B" & Count + 1), SortOn:=0, Order:=1, DataOption:=0
        .SetRange xlWs.Range("A4:N" & Count + 1)
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
        .Range("F:J").HorizontalAlignment = xlRight
        .Range("D:E").HorizontalAlignment = xlCenter
        .Range("B:C").EntireColumn.AutoFit
        .Range("K:K").EntireColumn.AutoFit
        .Range("L:L").EntireColumn.AutoFit
        
        'ESS Summen und Preise
        If kun_ID = 20730 Or kun_ID = 20760 Or kun_ID = 20761 Then
            .Range("M:M").EntireColumn.AutoFit
            .Range("N:N").EntireColumn.AutoFit
            .Range("F" & Count + 5) = "SVS"
            .Range("G" & Count + 5) = TLookup("StdPreis", SPREISE, "kun_ID=" & kun_ID & " AND Preisart_ID=1")
            .Range("H" & Count + 5) = .Range("G" & Count + 5) + TLookup("StdPreis", SPREISE, "kun_ID=" & kun_ID & " AND Preisart_ID=11")
            .Range("I" & Count + 5) = .Range("G" & Count + 5) + TLookup("StdPreis", SPREISE, "kun_ID=" & kun_ID & " AND Preisart_ID=12")
            .Range("J" & Count + 5) = .Range("G" & Count + 5) + TLookup("StdPreis", SPREISE, "kun_ID=" & kun_ID & " AND Preisart_ID=13")
            .Range("F" & Count + 6) = "Betrag"
            .Range("G" & Count + 6) = .Range("G" & Count + 3) * .Range("G" & Count + 5)
            .Range("H" & Count + 6) = .Range("H" & Count + 3) * .Range("H" & Count + 5)
            .Range("I" & Count + 6) = .Range("I" & Count + 3) * .Range("I" & Count + 5)
            .Range("J" & Count + 6) = .Range("J" & Count + 3) * .Range("J" & Count + 5)
            .Range("F" & Count + 7) = "Ges. Netto"
            .Range("G" & Count + 7) = .Range("G" & Count + 6) + .Range("H" & Count + 6) + .Range("I" & Count + 6) + .Range("J" & Count + 6)
            .Range("F" & Count + 8) = "19% MwSt"
            .Range("G" & Count + 8) = .Range("G" & Count + 7) * 0.19
            .Range("F" & Count + 9) = "Ges. Brutto"
            .Range("G" & Count + 9) = .Range("G" & Count + 7) + .Range("G" & Count + 8)
            .Range("G" & Count + 5).NumberFormat = "#,##0.00 " & Chr(128)
            .Range("H" & Count + 5).NumberFormat = "#,##0.00 " & Chr(128)
            .Range("I" & Count + 5).NumberFormat = "#,##0.00 " & Chr(128)
            .Range("J" & Count + 5).NumberFormat = "#,##0.00 " & Chr(128)
            .Range("G" & Count + 6).NumberFormat = "#,##0.00 " & Chr(128)
            .Range("H" & Count + 6).NumberFormat = "#,##0.00 " & Chr(128)
            .Range("I" & Count + 6).NumberFormat = "#,##0.00 " & Chr(128)
            .Range("J" & Count + 6).NumberFormat = "#,##0.00 " & Chr(128)
            .Range("F" & Count + 7).Font.Underline = 2
            .Range("G" & Count + 7).NumberFormat = "#,##0.00 " & Chr(128)
            .Range("G" & Count + 7).Font.Underline = 2
            .Range("G" & Count + 8).NumberFormat = "#,##0.00 " & Chr(128)
            .Range("F" & Count + 9).Font.Underline = 2
            .Range("G" & Count + 9).Font.Underline = 2
            .Range("G" & Count + 9).NumberFormat = "#,##0.00 " & Chr(128)
            .Range("K" & Count + 8) = "Gepr" & Chr(252) & "ft ESS:"
            .Range("K" & Count + 8).Font.color = vbRed
        Else
            .Range("L" & Count + 3).FormulaR1C1 = "=SUM(R[-" & rows & "]C:R[-2]C)"
            .Range("L" & Count + 3).NumberFormat = "#,##0.00 " & Chr(128)
        End If
        
        .PageSetup.Orientation = 2
        .PageSetup.PaperSize = 9
        .PageSetup.Zoom = False
        .PageSetup.FitToPagesWide = 1
        .PageSetup.FitToPagesTall = 1
        .PageSetup.PrintArea = .UsedRange.address
    End With
    
    Datum_Datei = Format(xlWs.Range("A5"), "MM-DD-YY")
    xlWb.SaveAs PfadPlanungAktuell & Datum_Datei & " " & xlWs.Range("A2") & " Namensliste" & ".xlsx"
    
End Function
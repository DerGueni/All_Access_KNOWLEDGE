Private Function GruppiereSchichten(ByRef colSchichten As Collection) As Object
    Dim dict As Object, arr As Variant, schluessel As String, i As Long
    Dim colStandorte As Collection, bestehendes As Variant
    
    Set dict = CreateObject("Scripting.Dictionary")
    For i = 1 To colSchichten.Count
        arr = colSchichten(i)
        schluessel = CStr(CLng(CDate(arr(2)))) & "|" & Format(CDate(arr(3)), "HH:MM") & "|" & Format(CDate(arr(4)), "HH:MM")
        If Not dict.exists(schluessel) Then
            Set colStandorte = New Collection
            colStandorte.Add CStr(arr(1))
            dict.Add schluessel, Array(arr(2), arr(3), arr(4), 1, colStandorte)
        Else
            bestehendes = dict(schluessel)
            bestehendes(3) = bestehendes(3) + 1
            bestehendes(4).Add CStr(arr(1))
            dict(schluessel) = bestehendes
        End If
    Next i
    Set GruppiereSchichten = dict
End Function

Private Function ExecuteImport(ByRef colSchichten As Collection) As Long
    On Error GoTo ErrHandler
    
    Dim newVA_ID As Long, minDate As Date, maxDate As Date
    Dim dictDates As Object, dictVADatum As Object, dictGruppiert As Object
    Dim arr As Variant, d As Date, i As Long, vaDatumID As Long, vaStartID As Long
    Dim dateKey As Variant, schluessel As Variant, gruppenDaten As Variant
    Dim colStandorte As Collection, j As Long
    Dim startDT As Date, endeDT As Date, maAnzahl As Long
    Dim sql As String, tmpID As Variant, sumMA As Variant, standortStr As String
    
    Set dictDates = CreateObject("Scripting.Dictionary")
    Set dictVADatum = CreateObject("Scripting.Dictionary")
    Set dictGruppiert = GruppiereSchichten(colSchichten)
    
    minDate = #12/31/2099#
    maxDate = #1/1/1900#
    For i = 1 To colSchichten.Count
        arr = colSchichten(i)
        d = CDate(arr(2))
        If d < minDate Then minDate = d
        If d > maxDate Then maxDate = d
        If Not dictDates.exists(CLng(d)) Then dictDates.Add CLng(d), d
    Next i
    
    DoCmd.SetWarnings False
    
    tmpID = DLookup("ID", "tbl_VA_Auftragstamm", "Auftrag = 'Spielwarenmesse Bereichswachen' AND Dat_VA_Von = " & FmtD(minDate))
    If IsNull(tmpID) Then
        sql = "INSERT INTO tbl_VA_Auftragstamm (Auftrag, Objekt, Ort, Treffpunkt, Dienstkleidung, Veranstalter_ID, " & _
              "Dat_VA_Von, Dat_VA_Bis, AnzTg, Erst_von, Erst_am, Veranst_Status_ID) VALUES (" & _
              "'Spielwarenmesse Bereichswachen', 'Messezentrum', 'Nuernberg', " & _
              "'15 min vor DB an der SCU', 'schwarz neutral', 10730, " & _
              FmtD(minDate) & ", " & FmtD(maxDate) & ", " & dictDates.Count & ", " & _
              "'" & Environ("USERNAME") & "', Now(), 1)"
        DoCmd.RunSQL sql
        newVA_ID = DMax("ID", "tbl_VA_Auftragstamm", "Auftrag = 'Spielwarenmesse Bereichswachen'")
        Debug.Print "Neuer Auftrag angelegt ID: " & newVA_ID
    Else
        newVA_ID = tmpID
        Debug.Print "Auftrag existiert bereits ID: " & newVA_ID
    End If
    
    For Each dateKey In dictDates.Keys
        d = dictDates(dateKey)
        tmpID = DLookup("ID", "tbl_VA_AnzTage", "VA_ID = " & newVA_ID & " AND VADatum = " & FmtD(d))
        If IsNull(tmpID) Then
            sql = "INSERT INTO tbl_VA_AnzTage (VA_ID, VADatum, TVA_Soll, TVA_Ist) VALUES (" & newVA_ID & ", " & FmtD(d) & ", 0, 0)"
            DoCmd.RunSQL sql
            tmpID = DLookup("ID", "tbl_VA_AnzTage", "VA_ID = " & newVA_ID & " AND VADatum = " & FmtD(d))
        End If
        dictVADatum.Add CLng(d), CLng(tmpID)
    Next dateKey
    
    For Each schluessel In dictGruppiert.Keys
        gruppenDaten = dictGruppiert(schluessel)
        d = CDate(gruppenDaten(0))
        vaDatumID = dictVADatum(CLng(d))
        maAnzahl = gruppenDaten(3)
        Set colStandorte = gruppenDaten(4)
        
        startDT = CDate(gruppenDaten(0)) + CDate(gruppenDaten(1))
        endeDT = CDate(gruppenDaten(0)) + CDate(gruppenDaten(2))
        If CDate(gruppenDaten(2)) < CDate(gruppenDaten(1)) Then endeDT = endeDT + 1
        
        tmpID = DLookup("ID", "tbl_VA_Start", "VA_ID = " & newVA_ID & " AND VADatum = " & FmtD(d) & " AND VA_Start = " & FmtT(CDate(gruppenDaten(1))) & " AND VA_Ende = " & FmtT(CDate(gruppenDaten(2))))
        If IsNull(tmpID) Then
            sql = "INSERT INTO tbl_VA_Start (VA_ID, VADatum_ID, VADatum, MA_Anzahl, VA_Start, VA_Ende, MVA_Start, MVA_Ende) VALUES (" & _
                  newVA_ID & ", " & vaDatumID & ", " & FmtD(d) & ", " & maAnzahl & ", " & _
                  FmtT(CDate(gruppenDaten(1))) & ", " & FmtT(CDate(gruppenDaten(2))) & ", " & FmtDT(startDT) & ", " & FmtDT(endeDT) & ")"
            DoCmd.RunSQL sql
            vaStartID = DMax("ID", "tbl_VA_Start", "VA_ID = " & newVA_ID)
        Else
            vaStartID = tmpID
        End If
        
        For j = 1 To colStandorte.Count
            standortStr = Replace(colStandorte(j), "'", "''")
            tmpID = DLookup("ID", "tbl_MA_VA_Zuordnung", "VA_ID = " & newVA_ID & " AND VAStart_ID = " & vaStartID & " AND Bemerkungen = '" & standortStr & "'")
            If IsNull(tmpID) Then
                sql = "INSERT INTO tbl_MA_VA_Zuordnung (VA_ID, VADatum_ID, VAStart_ID, VADatum, MVA_Start, MVA_Ende, Bemerkungen, Erst_von, Erst_am) VALUES (" & _
                      newVA_ID & ", " & vaDatumID & ", " & vaStartID & ", " & FmtD(d) & ", " & FmtDT(startDT) & ", " & FmtDT(endeDT) & ", " & _
                      "'" & standortStr & "', '" & Environ("USERNAME") & "', Now())"
                DoCmd.RunSQL sql
            End If
        Next j
    Next schluessel
    
    For Each dateKey In dictVADatum.Keys
        vaDatumID = dictVADatum(dateKey)
        sumMA = DSum("MA_Anzahl", "tbl_VA_Start", "VADatum_ID = " & vaDatumID)
        If IsNull(sumMA) Then sumMA = 0
        sql = "UPDATE tbl_VA_AnzTage SET TVA_Soll = " & sumMA & " WHERE ID = " & vaDatumID
        DoCmd.RunSQL sql
    Next dateKey
    
    DoCmd.SetWarnings True
    ExecuteImport = newVA_ID
    Exit Function
ErrHandler:
    DoCmd.SetWarnings True
    Debug.Print "!!! IMPORT-FEHLER: " & Err.description
    ExecuteImport = 0
End Function

Private Function FmtD(d As Date) As String
    FmtD = "#" & Month(d) & "/" & Day(d) & "/" & Year(d) & "#"
End Function

Private Function FmtT(t As Date) As String
    FmtT = "#" & Hour(t) & ":" & minute(t) & ":" & Second(t) & "#"
End Function

Private Function FmtDT(dt As Date) As String
    FmtDT = "#" & Month(dt) & "/" & Day(dt) & "/" & Year(dt) & " " & Hour(dt) & ":" & minute(dt) & ":" & Second(dt) & "#"
End Function
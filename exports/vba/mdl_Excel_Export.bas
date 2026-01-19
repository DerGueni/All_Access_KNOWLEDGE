Attribute VB_Name = "mdl_Excel_Export"
Option Compare Database
Option Explicit

Dim xl As New clsExcel

Function fXL_Export_Auftrag(VA_ID As Long, XLPfad As String, XLName As String)

Dim iAnzMA As Long
Dim iAnzZeiten As Long
Dim iAnzPg As Long
Dim iAnzZl As Long
Dim xlVorlage As String
Dim wkb As Object
Dim iZeile As Long
Dim iSpalte As Long
Dim imaxzwi As Long

Dim strCol As String
Dim strColName As String

Dim datvgl As Date

Dim SheetnameArr() As String

Dim rg
Dim i As Long
Dim iLst As Long
Dim iZlLst As Long

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, DAOARRAY_Name1, iZl As Long, iCol As Long
Dim ArrFill_DAO_OK2 As Boolean, recsetSQL2 As String, iZLMax2 As Long, iColMax2 As Long, DAOARRAY2, iZl2 As Long, iCol2 As Long

xlVorlage = Get_Priv_Property("prp_XL_DocVorlage")

iAnzMA = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "VA_ID = " & VA_ID), 0)
iAnzZeiten = Nz(TCount("*", "tbl_VA_Start", "VA_ID = " & VA_ID), 0)
iAnzPg = iAnzMA \ 41
iAnzZl = iAnzZeiten - 3
If iAnzZl < 0 Then iAnzZl = 0

Set wkb = xl.XL_Wkb_Add(xlVorlage)
Sleep 20
DoEvents
ReDim SheetnameArr(iAnzPg)
SheetnameArr(0) = "Liste"

xl.XL_Visible True

If iAnzPg > 0 Then

    wkb.Sheets("Liste (2)").Visible = True
    DoEvents
    wkb.Sheets("Liste (2)").Name = "Liste 2"
    SheetnameArr(1) = "Liste 2"
    Select Case iAnzPg
        Case 2
            wkb.Sheets("Liste (3)").Visible = True
            wkb.Sheets("Liste (3)").Name = "Liste 3"
            SheetnameArr(2) = "Liste 3"
    
        Case 3
            wkb.Sheets("Liste (3)").Visible = True
            wkb.Sheets("Liste (3)").Name = "Liste 3"
             
            wkb.Sheets("Liste 3").Copy after:=wkb.Sheets("Liste 3")
            wkb.Sheets("Liste 3 (2)").Name = "Liste 4"
        
            SheetnameArr(2) = "Liste 3"
            SheetnameArr(3) = "Liste 4"
        
        Case 4
            wkb.Sheets("Liste (3)").Visible = True
            wkb.Sheets("Liste (3)").Name = "Liste 3"
             
            wkb.Sheets("Liste 3").Copy after:=wkb.Sheets("Liste 3")
            wkb.Sheets("Liste 3 (2)").Name = "Liste 4"
            
            wkb.Sheets("Liste 4").Copy after:=wkb.Sheets("Liste 4")
            wkb.Sheets("Liste 4 (2)").Name = "Liste 5"
        
            SheetnameArr(2) = "Liste 3"
            SheetnameArr(3) = "Liste 4"
            SheetnameArr(4) = "Liste 5"
            
    End Select
End If

'Teil 1 Kopf schreiben
'#####################

recsetSQL1 = "SELECT * FROM qry_Excel_Export_Teil1 WHERE VA_ID = " & VA_ID
recsetSQL2 = "Select * FROM qry_Excel_Sel_Import_Felder WHERE TabTyp = 1"

ArrFill_DAO_OK1 = ArrFill_DAO(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1, DAOARRAY_Name1)
ArrFill_DAO_OK2 = ArrFill_DAO_Acc(recsetSQL2, iZLMax2, iColMax2, DAOARRAY2)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>

datvgl = CDate(DAOARRAY1(1, 0))

iZl = 0  ' Teil 1 nur eine Zeile
If ArrFill_DAO_OK1 Then
    For iLst = 0 To UBound(SheetnameArr)
        xl.SelectSheet (SheetnameArr(iLst))
        For iCol = 0 To iColMax1
            strCol = CStr(Nz(DAOARRAY1(iCol, iZl)))
            strColName = CStr(Nz(DAOARRAY_Name1(iCol, 0)))
            For i = 0 To iZLMax2
                If CStr(DAOARRAY2(1, i)) = strColName Then
                    Exit For
                End If
            Next i
            If i <= iZLMax2 Then
                If CStr(DAOARRAY2(1, i)) = strColName Then
                    iSpalte = CLng(DAOARRAY2(3, i))
                    iZeile = CLng(DAOARRAY2(4, i))
                    Debug.Print strColName, strCol, iSpalte, iZeile
                    
                    'If strColName = "Sicherheitspersonal" Then Stop
                    
                    Set rg = xl.SetRange(iZeile, iSpalte, iZeile, iSpalte)
                    rg(1, 1) = strCol
                End If
            End If
        Next iCol
    Next iLst
End If
    
Set DAOARRAY1 = Nothing
Set DAOARRAY_Name1 = Nothing
Set DAOARRAY2 = Nothing
    
'Teil 3 MA schreiben
'#####################


recsetSQL1 = "SELECT * FROM qry_Excel_Export_Teil3 WHERE VA_ID = " & VA_ID & " ORDER BY VADatum, PosNr"
recsetSQL2 = "Select * FROM qry_Excel_Sel_Import_Felder WHERE TabTyp = 3"

ArrFill_DAO_OK1 = ArrFill_DAO(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1, DAOARRAY_Name1)
ArrFill_DAO_OK2 = ArrFill_DAO_Acc(recsetSQL2, iZLMax2, iColMax2, DAOARRAY2)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>

iZl = 0
If ArrFill_DAO_OK1 Then
    For iLst = 0 To UBound(SheetnameArr)
        xl.SelectSheet (SheetnameArr(iLst))
        For iZlLst = 0 To 45                 'ANZAHL NUTZZEILEN IN DER EINSATZLISTE
            If iZl > iZLMax1 Then Exit For
            For iCol = 1 To iColMax1
                strCol = CStr(Nz(DAOARRAY1(iCol, iZl)))
                strColName = CStr(Nz(DAOARRAY_Name1(iCol, 0)))
                If strColName = "VA_Datumstr" Then
                    If CDate(strCol) = datvgl And Not (iLst > 0 And iZlLst = 0) Then
                        strCol = ""
                    Else
                        datvgl = CDate(strCol)
                    End If
                End If
                If strColName = "Beginnstr" Or strColName = "Endestr" Then
                    If strCol = "00:00" Then strCol = "24:00"
                End If
                For i = 0 To iZLMax2
                    If CStr(DAOARRAY2(1, i)) = strColName Then
                        Exit For
                    End If
                Next i
                If i <= iZLMax2 Then
                    If Not (strColName = "VA_Datumstr" And iLst = 0 And iZl = 0) Then
                        If CStr(DAOARRAY2(1, i)) = strColName Then
                            iSpalte = CLng(DAOARRAY2(3, i))
                            iZeile = CLng(DAOARRAY2(4, i)) + iZlLst
                            Set rg = xl.SetRange(iZeile, iSpalte, iZeile, iSpalte)
                            rg(1, 1) = strCol
                        End If
                    End If
                End If
            Next iCol
            iZl = iZl + 1
        Next iZlLst
    Next iLst
End If
    
Set DAOARRAY1 = Nothing
Set DAOARRAY_Name1 = Nothing
Set DAOARRAY2 = Nothing
    
'Teil 2 Schichten schreiben
'##########################

recsetSQL1 = "SELECT * FROM qry_Excel_Export_Teil2 WHERE VA_ID = " & VA_ID & " ORDER BY vonStr, BisStr"
recsetSQL2 = "Select * FROM qry_Excel_Sel_Import_Felder WHERE TabTyp = 2"

ArrFill_DAO_OK1 = ArrFill_DAO(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1, DAOARRAY_Name1)
ArrFill_DAO_OK2 = ArrFill_DAO_Acc(recsetSQL2, iZLMax2, iColMax2, DAOARRAY2)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>

If ArrFill_DAO_OK1 Then
    For iLst = 0 To UBound(SheetnameArr)
        imaxzwi = iZLMax1
        If imaxzwi > 2 Then imaxzwi = 2
        For iZl = 0 To imaxzwi
           xl.SelectSheet (SheetnameArr(iLst))
           For iCol = 1 To iColMax1
               strCol = CStr(Nz(DAOARRAY1(iCol, iZl)))
               strColName = CStr(Nz(DAOARRAY_Name1(iCol, 0)))
               For i = 0 To iZLMax2
                   If CStr(DAOARRAY2(1, i)) = strColName Then
                       Exit For
                   End If
               Next i
               If i <= iZLMax2 Then
                   If CStr(DAOARRAY2(1, i)) = strColName Then
                       iSpalte = CLng(DAOARRAY2(3, i))
                       iZeile = CLng(DAOARRAY2(4, i))
                       Debug.Print strColName, strCol, iSpalte, iZeile
                       
    '                   If strColName = "Std_satz_KD_1_Nettostr" Then Stop
                       
                       Set rg = xl.SetRange(iZeile, iSpalte, iZeile, iSpalte)
                       rg(1, 1) = strCol
                   End If
               End If
           Next iCol
        Next iZl
    Next iLst
End If

Set DAOARRAY1 = Nothing
Set DAOARRAY_Name1 = Nothing
Set DAOARRAY2 = Nothing
    
xl.XL_actWkb_SaveAs (XLPfad & XLName)
'XL.XL_Close_Sure
CurrentDb.Execute ("UPDATE tbl_VA_Auftragstamm SET tbl_VA_Auftragstamm.Excel_Dateiname = '" & XLName & "', tbl_VA_Auftragstamm.Excel_Path = '" & XLPfad & "' WHERE (((tbl_VA_Auftragstamm.ID)=" & VA_ID & "));")

End Function
Function FCreate_Dienstplan_Excel_Send(Art As Long)
Dim dt As Date
Dim strdoc As String
Dim strPfad As String

FCreate_Dienstplan_Excel Art, True


If Art = 1 Then  ' Objekt
    dt = TLookup("Startdat", "tbltmp_DP_Grund_2")
    strdoc = "DP_Obj_" & Format(dt, "dd.mm.yy", 2, 2) & ".xlsm"
ElseIf Art = 2 Then  ' MA
    dt = TLookup("Startdat", "tbltmp_DP_MA_Grund_FI")
    strdoc = "DP_MA_" & Format(dt, "dd.mm.yy", 2, 2) & ".xlsm"
End If

strPfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 13")

If File_exist(strPfad & strdoc) Then Kill strPfad & strdoc
DoEvents

xl.XL_actWkb_SaveAs (strPfad & strdoc)
'XL.XL_Close_Sure

DoEvents

DoCmd.OpenForm ("frmOff_Outlook_aufrufen")
Form_frmOff_Outlook_aufrufen.VAOpen (strPfad & strdoc)

End Function

Function FCreate_Dienstplan_Excel(Art As Long, Optional bVisible As Boolean = True)
' 1 = Objekt - tbltmp_DP_Grund
' 2 = MA    - tbltmp_DP_MA_Grund

Dim strVgl As String

Dim wkb As Object
Dim sht As Object

Dim iUdl As Long
Dim i As Long
Dim j As Long
Dim k As Long
Dim dt As Date
Dim iXl As Long
Dim bFrag As Boolean

Dim iAnzMA As Long
Dim iAnzZeiten As Long
Dim iAnzPg As Long
Dim iAnzZl As Long
Dim xlVorlage As String
Dim iZeile As Long
Dim iSpalte As Long
Dim imaxzwi As Long

Dim strCol As String
Dim strColName As String

Dim datvgl As Date

Dim SheetnameArr() As String

Dim rg
Dim iLst As Long
Dim iZlLst As Long

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, DAOARRAY_Name1, iZl As Long, iCol As Long
'Dim ArrFill_DAO_OK2 As Boolean, recsetSQL2 As String, iZLMax2 As Long, iColMax2 As Long, DAOARRAY2, iZl2 As Long, iCol2 As Long

'Start in Spalte 5
    'Zuo_Id
    'MA_ID
    'Name
    'fraglich
    'von
    'bis
'Spalte 1 = Startdat

'Datum von bis C2
'dat B3, E3, H3, K3, N3, Q3, T3
'MA zweifelhaft andere Farbe

'On Error Resume Next

If Art = 1 Then  ' Objekt
    recsetSQL1 = "SELECT * FROM tbltmp_DP_Grund_2 ORDER BY ID"
    xlVorlage = Get_Priv_Property("prp_XL_DienstObjVorlage")

    'Spalte 2 = ObjOrt
    'Spalte 3 = ObjOrt_Anzeige
    
    'Zwischen den Objekten DICKER Strich
    'NV Objekte grau
    'Unbesetzte Obj gelb

ElseIf Art = 2 Then  ' MA
    recsetSQL1 = "SELECT * FROM tbltmp_DP_MA_Grund_FI ORDER BY ID"
    xlVorlage = Get_Priv_Property("prp_XL_DienstMAVorlage")
    'Spalte 2 = MA_ID
    'Spalte 3 = MAName

End If

ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>

Set wkb = xl.XL_Wkb_Add(xlVorlage)
Sleep 20
DoEvents

xl.XL_Visible bVisible
xl.SelectSheet

iZl = 0
If ArrFill_DAO_OK1 Then

'######## Header

' Datumswerte setzen
'dat B3, E3, H3, K3, N3, Q3, T3
    dt = CDate(DAOARRAY1(1, 0))
    j = 2
    For i = 0 To 6
        Set rg = xl.SetRange(3, j, 3, j)
        rg(1, 1) = Format(dt + i, "ddd. dd.mm.yy", 2, 2)
        j = j + 3
    Next i
    'Datum von bis C2
    Set rg = xl.SetRange(2, 2, 2, 2)
    rg(1, 1) = Format(dt, "dd.mm.", 2, 2) & " - " & Format(dt + 6, "dd.mm.yy", 2, 2)
    
'####### Pro Zeile
    
    For iZl = 0 To iZLMax1
        iXl = iZl + 4
        Set rg = xl.SetRange(iXl, 1, iXl, 1)
        rg(1, 1) = CStr(DAOARRAY1(3, iZl))

        'Testen ob neues Objekt beginnt - iUdl = 1 wenn ja
        If iZl < iZLMax1 Then
            If CStr(DAOARRAY1(2, iZl)) <> CStr(DAOARRAY1(2, iZl + 1)) Then
                iUdl = 1
            Else
                iUdl = 0
            End If
        Else
            iUdl = 1
        End If
        
        ' j = Startpunkt in Tabelle Feld Name ( Erster Wert 0)
        ' k = Startpunkt in XL Feld Name ( Erster Wert 1)
        j = 7
        k = 2
        For i = 1 To 7
            'Namen von und bis setzen
            Set rg = xl.SetRange(iXl, k, iXl, k)
            rg(1, 1) = CStr(Nz(DAOARRAY1(j, iZl)))
            Set rg = xl.SetRange(iXl, k + 1, iXl, k + 1)
            rg(1, 1) = CStr(Nz(DAOARRAY1(j + 2, iZl)))
            Set rg = xl.SetRange(iXl, k + 2, iXl, k + 2)
            rg(1, 1) = CStr(Nz(DAOARRAY1(j + 3, iZl)))
            
            ' Wenn MA fraglich, orange markieren
            bFrag = DAOARRAY1(j + 1, iZl)
            If bFrag Then
                Set rg = xl.SetRange(iXl, k, iXl, k)
                    
                With rg.Interior
                    .pattern = 1
                    .PatternColorIndex = -4105
            '        .Color = 65535  ' Gelb
 '                   .Color = 49407  ' Orange
                    .color = 16766999 ' Türkisblau
                    .TintAndShade = 0
                    .PatternTintAndShade = 0
                End With
                
            End If
            
            If Art = 1 Then  ' Nur bei Objekt - Nicht bei MA
                'Fehlende MA gelb markieren
                If CLng(Nz(DAOARRAY1(j - 2, iZl), 0)) > 0 And CLng(Nz(DAOARRAY1(j - 1, iZl), 0)) = 0 Then
                    Set rg = xl.SetRange(iXl, k, iXl, k)
                
                    With rg.Interior
                        .pattern = 1
                        .PatternColorIndex = -4105
                        .color = 10092543  ' Hellgelb
                '        .Color = 49407  ' Orange
                        .TintAndShade = 0
                        .PatternTintAndShade = 0
                    End With
            
                End If
                
                'Undef grau markieren
                If CLng(Nz(DAOARRAY1(j - 2, iZl), 0)) = 0 And CLng(Nz(DAOARRAY1(j - 1, iZl), 0)) = 0 Then
                    If IsNull(DAOARRAY1(j - 2, iZl)) Then
                        Set rg = xl.SetRange(iXl, k, iXl, k + 2)
                
                        With rg.Interior
                             .pattern = 1          ' = 1
                             .PatternColorIndex = -4105   ' = -4105
                             .ThemeColor = 1    ' = 1
                             .TintAndShade = -0.14996795556505
                             .PatternTintAndShade = 0
                         End With
            
'                    ElseIf DAOARRAY1(j - 2, iZl) = 0 Then
                    End If
            
                End If
               
                ' Begremzumgslinie Objekt
                If iUdl = 1 Then
                    Set rg = xl.SetRange(iXl, 1, iXl, 22)
                    With rg.Borders(9)  ' = 9
                       .LineStyle = 1  ' = 1
                       .ColorIndex = 0
                       .TintAndShade = 0
                       .Weight = 4  ' = 4
                    End With
                End If
        
            End If
            j = j + 6
            k = k + 3
        Next i
    
    Next iZl
    ' Begremzumgslinie Objekt am Ende
    Set rg = xl.SetRange(iZLMax1 + 4, 1, iZLMax1 + 4, 22)
    With rg.Borders(9)  ' = 9
       .LineStyle = 1  ' = 1
       .ColorIndex = 0
       .TintAndShade = 0
       .Weight = 4  ' = 4
    End With
    
    'Nach letzter Reihe alles löschen
    Set rg = xl.SetRangeToLastRow(iZLMax1 + 5)
    rg.Delete

    Set DAOARRAY1 = Nothing

    xl.XL_Visible True

End If

End Function

Function fxltstEz()
'Call FCreate_Dienstplan_MA_Einzel_Excel(152, #11/16/2015#)
Call FCreate_Dienstplan_MA_Einzel_Excel(152, #11/23/2015#)
End Function


Function FCreate_Dienstplan_MA_Einzel_Excel(iMA_ID As Long, ByVal startdt As Date)
' 1 = Objekt - tbltmp_DP_Grund
' 2 = MA    - tbltmp_DP_MA_Grund

Dim strVgl As String

Dim wkb As Object
Dim sht As Object

Dim iUdl As Long
Dim i As Long
Dim j As Long
Dim k As Long
Dim dt As Date
Dim iXl As Long
Dim bFrag As Boolean

Dim iAnzMA As Long
Dim iAnzZeiten As Long
Dim iAnzPg As Long
Dim iAnzZl As Long
Dim xlVorlage As String
Dim iZeile As Long
Dim iSpalte As Long
Dim imaxzwi As Long

Dim strCol As String
Dim strColName As String

Dim datvgl As Date
Dim enddt As Date
Dim iKW As Long

Dim SheetnameArr() As String

Dim rg
Dim iLst As Long
Dim iZlLst As Long
Dim iwkday As Long
Dim ixlCol As Long
Dim xlrow As Long
Dim ixlrowstart As Long

iwkday = Weekday(startdt, 2)
startdt = startdt - iwkday + 1
enddt = startdt + 6
iKW = TLookup("KW_D", "_tblAlleTage", "dtDatum = " & SQLDatum(startdt))

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, DAOARRAY_Name1, iZl As Long, iCol As Long
'Dim ArrFill_DAO_OK2 As Boolean, recsetSQL2 As String, iZLMax2 As Long, iColMax2 As Long, DAOARRAY2, iZl2 As Long, iCol2 As Long


'    C2 Name
'    E2  KW nn
'    F2  12.11.2015 - 19.11.2015
'
'    B bis H Wochentage Mo bis So
'
'    B3  Mo.12.10.
'
'    Wiederholen so oft Aufträge pro Tag
'
'    B4 Auftrag
'    B5 Ort
'    B6 Location
'    B7  Gesamtanz MA pro Schicht
'    B8 Dienstbeginn
'    B9 Ende
'    B10 Treffp Zeit
'    B11 Treffp.Ort
'    B12 Dienstkleidung
'    B13 - leer - Fahrer zum Einsatzort  (default selbst)
'    B14 - leer - Position am Einsatzort
'    B15 -leer - Aufgabenbeschreibung
'    B16 Auftraggeber
'    B17 Ansprechpartner
'    B18 - leer Zusatzinformation
'
'    B19 leer
'
'    B20 - 34 Auftrag 2 ...
'
'    B35 leer
'
'    B36 - 50 Auftrag 3


'On Error Resume Next

    recsetSQL1 = "SELECT * FROM qry_MA_VA_EinzelExcel_Alle WHERE MA_ID = " & iMA_ID & " AND VADatum BETWEEN " & SQLDatum(startdt) & " AND " & SQLDatum(enddt) & " ORDER BY MA_ID, VADatum, MA_Start"
    xlVorlage = Get_Priv_Property("prp_XL_DienstMAVorlage_Einzel")

    'Spalte 2 = ObjOrt
    'Spalte 3 = ObjOrt_Anzeige
    
    'Zwischen den Objekten DICKER Strich
    'NV Objekte grau
    'Unbesetzte Obj gelb

ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then

    Set wkb = xl.XL_Wkb_Add(xlVorlage)
    Sleep 20
    DoEvents
    
    xl.XL_Visible True
    xl.SelectSheet
    
    iZl = 0
    
'  qry_MA_VA_EinzelExcel_Alle

'######## Header

'    C2 Name
'    E2  KW nn
'    F2  12.11. - 19.11.2015
'
'    B bis H Wochentage Mo bis So

' Datumswerte setzen
'dat B3 bis H3

'Woche
    Set rg = xl.SetRange(2, 5, 2, 5)  ' Row Column
    rg(1, 1) = " KW " & iKW
    
'Zeitraum
    Set rg = xl.SetRange(2, 6, 2, 6)  ' Row Column
    rg(1, 1) = Format(startdt, "dd.mm.", 2, 2) & " - " & Format(enddt, "dd.mm.yy", 2, 2)
    
 'Wochentage
    dt = startdt
    j = 2
    For i = 0 To 6
        Set rg = xl.SetRange(3, 2 + i, 3, 2 + i)  ' Row Column
        rg(1, 1) = Format(dt + i, "ddd. dd.mm.", 2, 2)
        j = j + 1
    Next i
    
'####### Pro Zeile
    
'qry_MA_VA_EinzelExcel_Alle
'Field Name
'==========
' 0            VA_ID          4            Long Integer
' 1            VADatum_ID     4            Long Integer
' 2            VAStart_ID     4            Long Integer
' 3            MA_ID          4            Long Integer
' 4            VADatum        8            Date/Time
' 5            MA_Start       8            Date/Time
' 6            MA_Ende        8            Date/Time
' 7            MA_Anzahl      4            Long Integer
' 8            IstSubunternehmer            1            Yes/No
' 9            Name           10           Text
' 10           Auftrag        10           Text
' 11           Ort            10           Text
' 12           Objekt         10           Text
' 13           VA_Treffpunkt  10           Text
' 14           Treffpunkt     10           Text
' 15           VA_Zeitpunkt   8            Date/Time
' 16           Treffp_Zeit    8            Date/Time
' 17           Dienstkleidung               10           Text
' 18           kun_Firma      10           Text
' 19           Ansprechpartner              10           Text
'==========

'    B4 Auftrag
'    B5 Ort
'    B6 Location
'    B7  Gesamtanz MA pro Schicht
'    B8 Dienstbeginn
'    B9 Ende
'    B10 Treffp Zeit
'    B11 Treffp.Ort
'    B12 Dienstkleidung
'    B13 - leer - Fahrer zum Einsatzort  (default selbst)
'    B14 - leer - Position am Einsatzort
'    B15 -leer - Aufgabenbeschreibung
'    B16 Auftraggeber
'    B17 Ansprechpartner
'    B18 - leer Zusatzinformation

    datvgl = DateSerial(1990, 1, 1)
'    datvgl = CDate(DAOARRAY1(4, iZl))
'Name C2
    Set rg = xl.SetRange(2, 3, 2, 3)  ' Row Column
    rg(1, 1) = CStr(DAOARRAY1(9, iZl))

    ixlrowstart = 4
    k = ixlrowstart
    
    For iZl = 0 To iZLMax1
        
        iwkday = Weekday(CDate(DAOARRAY1(4, iZl)), 2)

        ixlCol = 1 + iwkday

        If CDate(DAOARRAY1(4, iZl)) = datvgl Then
            ixlrowstart = ixlrowstart + 16
            If k < ixlrowstart Then k = ixlrowstart
        Else
            ixlrowstart = 4
            datvgl = CDate(DAOARRAY1(4, iZl))
        End If

'    B4 Auftrag - 10
        xlrow = ixlrowstart
        Set rg = xl.SetRange(xlrow, ixlCol, xlrow, ixlCol)  ' Row Column
        rg(1, 1) = CStr(Nz(DAOARRAY1(10, iZl)))

'    B5 Ort - 11
        xlrow = ixlrowstart + 1
        Set rg = xl.SetRange(xlrow, ixlCol, xlrow, ixlCol)  ' Row Column
        rg(1, 1) = CStr(Nz(DAOARRAY1(11, iZl)))

'    B6 Location - 12
        xlrow = ixlrowstart + 2
        Set rg = xl.SetRange(xlrow, ixlCol, xlrow, ixlCol)  ' Row Column
        rg(1, 1) = CStr(Nz(DAOARRAY1(12, iZl)))

'    B7  Gesamtanz MA pro Schicht - 7
        xlrow = ixlrowstart + 3
        Set rg = xl.SetRange(xlrow, ixlCol, xlrow, ixlCol)  ' Row Column
        rg(1, 1) = CLng(Nz(DAOARRAY1(7, iZl), 0))

'    B8 Dienstbeginn - 5
        xlrow = ixlrowstart + 4
        Set rg = xl.SetRange(xlrow, ixlCol, xlrow, ixlCol)  ' Row Column
        rg(1, 1) = Format(CDate(DAOARRAY1(5, iZl)), "hh:nn") & " h"

'    B9 Ende - 6
        xlrow = ixlrowstart + 5
        Set rg = xl.SetRange(xlrow, ixlCol, xlrow, ixlCol)  ' Row Column
        If Len(Trim(Nz(DAOARRAY1(6, iZl)))) > 0 Then
            rg(1, 1) = Format(CDate(DAOARRAY1(6, iZl)), "hh:nn") & " h"
        End If

'    B10 Treffp Zeit  15 + 16 - Sonderlocke
        xlrow = ixlrowstart + 6
        Set rg = xl.SetRange(xlrow, ixlCol, xlrow, ixlCol)  ' Row Column
        If Len(Trim(Nz(DAOARRAY1(15, iZl)))) = 0 Then
            If Len(Trim(Nz(DAOARRAY1(16, iZl)))) > 0 Then
                rg(1, 1) = Format(CDate(DAOARRAY1(16, iZl)), "hh:nn") & " h"
            End If
        Else
            rg(1, 1) = Format(CDate(DAOARRAY1(15, iZl)), "hh:nn") & " h"
        End If

'    B11 Treffp.Ort  13 + 14 - Sonderlocke
        xlrow = ixlrowstart + 7
        Set rg = xl.SetRange(xlrow, ixlCol, xlrow, ixlCol)  ' Row Column
        If Len(Trim(Nz(DAOARRAY1(13, iZl)))) = 0 Then
            rg(1, 1) = CStr(Nz(DAOARRAY1(14, iZl)))
        Else
            rg(1, 1) = CStr(Nz(DAOARRAY1(13, iZl)))
        End If
        
'    B12 Dienstkleidung - 17
        xlrow = ixlrowstart + 8
        Set rg = xl.SetRange(xlrow, ixlCol, xlrow, ixlCol)  ' Row Column
        rg(1, 1) = CStr(Nz(DAOARRAY1(17, iZl)))

'    B13 - leer - Fahrer zum Einsatzort  (default selbst)
'    B14 - leer - Position am Einsatzort
'    B15 -leer - Aufgabenbeschreibung
'    B16 Auftraggeber - 18
        xlrow = ixlrowstart + 10
        Set rg = xl.SetRange(xlrow, ixlCol, xlrow, ixlCol)  ' Row Column
        rg(1, 1) = CStr(Nz(DAOARRAY1(18, iZl)))

'    B17 Ansprechpartner - 19
        xlrow = ixlrowstart + 11
        Set rg = xl.SetRange(xlrow, ixlCol, xlrow, ixlCol)  ' Row Column
        rg(1, 1) = CStr(Nz(DAOARRAY1(19, iZl)))

'    B18 - leer Zusatzinformation

    Next iZl

'Ende löschen
    j = k + 12
    Set rg = xl.SetRangeToLastRow(j)
    rg.Delete
'
    Set DAOARRAY1 = Nothing
'
Else
    MsgBox "Keine Schichten für diese Woche vorhanden"
End If

End Function

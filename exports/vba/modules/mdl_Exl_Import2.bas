Attribute VB_Name = "mdl_Exl_Import2"
Option Compare Database
Option Explicit

Dim db As DAO.Database
Dim rst1 As DAO.Recordset
Dim rst2 As DAO.Recordset
Dim rst3 As DAO.Recordset
Dim xl As New clsExcel

Function dirkurz(da As String)
dirkurz = Dir(da)
End Function

Function Cons_XL_Import_1()

Dim dtName As String
Dim sPath As String
Dim sName As String
Dim iID As Long

DoEvents

Set db = CurrentDb

Set rst1 = db.OpenRecordset("SELECT * FROM tblZZZ_XL_Auftrag;")
Set rst2 = db.OpenRecordset("SELECT * FROM tblZZZ_XL_Auftrag_ZeitVorgabe;")
Set rst3 = db.OpenRecordset("SELECT * FROM tblZZZ_XL_Auftrag_MA_Einsatz;")

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
recsetSQL1 = "Select strPath, Dateiname, ID FROM Import_Auftraege_2015_09_09 WHERE IstNichtImportiert = False AND IstErledigt = False;"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1
        sPath = DAOARRAY1(0, iZl)
        sName = DAOARRAY1(1, iZl)
        iID = DAOARRAY1(2, iZl)
        dtName = sPath & sName
        If File_exist(dtName) Then
        
            CurrentDb.Execute ("DELETE * FROM tblZZZ_XL_Auftrag_ZeitVorgabe WHERE VA_ID = " & iID & ";")
            CurrentDb.Execute ("DELETE * FROM tblZZZ_XL_Auftrag_MA_Einsatz WHERE VA_ID = " & iID & ";")
            DoEvents

            Call Cons_XL_Import_2(dtName, iID)
            
            DoEvents
            DBEngine.Idle dbRefreshCache
            DBEngine.Idle dbFreeLocks
            DoEvents
            
'            CurrentDb.Execute ("UPDATE Import_Auftraege_2015_09_09 SET Import_Auftraege_2015_09_09.IstErledigt = True WHERE (((Import_Auftraege_2015_09_09.ID)=" & iID & "));")

        End If
    Next iZl
    Set DAOARRAY1 = Nothing
End If

rst1.Close
rst2.Close
rst3.Close

Set rst1 = Nothing
Set rst2 = Nothing
Set rst3 = Nothing


End Function

Function Cons_XL_Import_2(dtName As String, iID As Long)

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
Dim i As Long, jj As Long, j As Long, k As Long, l As Long, iwd As Long
Dim iAufNr As Long
Dim rg
Dim iZeile As Long, iSpalte As Long
Dim iKorr As Long
Dim iKorrAuf As Long
Dim istOk As Boolean
Dim FldInh
Dim iZeileOrg As Long
Dim iWieder As Long
Dim fldName As String

Dim rst As Object
Dim iLauf As Long
Dim iStart As Long

Dim stxlLstNam As String

'rg = Row, column
'################

On Error Resume Next

xl.XL_Wkb_Open_RDOnly (dtName)
Sleep 20
DoEvents

iWieder = 1

If xl.SelectSheet_Test("Liste") = False Then
    GoTo XL_Ende
End If

'If XL.xlSheetCount <> 2 Then GoTo XL_Ende

If xl.SelectSheet_Test("Liste 2") = True Then iWieder = 2
If xl.SelectSheet_Test("Liste 3") = True Then iWieder = 3

iwd = 1

RepeatDat:

If iwd <= iWieder Then
    If iwd = 1 Then
        stxlLstNam = "Liste"
    Else
        stxlLstNam = "Liste " & iwd
    End If
    iwd = iwd + 1
Else
    GoTo XL_Ende
End If

xl.SelectSheet (stxlLstNam)
DoEvents

If Not xl.SelectSheet_Test(stxlLstNam) Then GoTo RepeatDat
    
    'Public Function SetRange(IRow As Long, iCol As Long, IRowEnd As Long, IColEnd As Long) As Object
    ' Set rg = XL.SetRange(1, 1, ilarow, 3)
    
    ' Test auf Zeile 17 und Spalte 41 "PKW"
    
    iZeile = 9
    iSpalte = 34
    Set rg = xl.SetRange(iZeile, iSpalte, iZeile + 1, iSpalte)
    
    istOk = False
    If Left(Nz(rg(2, 1)), 10) = "Auftraggeb" Then
        istOk = True
        iKorrAuf = 1
    ElseIf Left(Nz(rg(1, 1)), 10) = "Auftraggeb" Then
        istOk = True
        iKorrAuf = 0
    End If
    
    If istOk Then
        iZeile = 17
        iSpalte = 41
        Set rg = xl.SetRange(iZeile, iSpalte, iZeile + 9, iSpalte)
        
        istOk = False
        
        'Max 10 Schichten - pro Schicht eine Zeile
        For i = 0 To 9
            If Nz(rg(1 + i, 1)) = "PKW" Then
                istOk = True
                iKorr = i
                Exit For
            End If
        Next i
    End If
    
    
    jj = 1
    If istOk And iwd = 2 Then
        recsetSQL1 = "Select Feldname, AnzZeilen, Zeile, Spalte FROM qry_Excel_Sel_Import_Felder WHERE TabTyp = " & jj & ";"
        Set rst = rst1
        With rst
            ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
        
            'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
            If ArrFill_DAO_OK1 Then
                .FindFirst "ID = " & iID
                .Edit
                For iZl = 0 To iZLMax1
                    fldName = DAOARRAY1(0, iZl)
                    iZeile = DAOARRAY1(2, iZl)
                    iSpalte = DAOARRAY1(3, iZl)
                    If fldName = "Auftraggeber" Then iZeile = iZeile + iKorrAuf
                    Set rg = xl.SetRange(iZeile, iSpalte, iZeile, iSpalte)
                    FldInh = Nz(rg(1, 1))
                    If Not (fldName = "DatumVonStr" And Len(Trim(Nz(FldInh))) = 0) Then
                        .fields(fldName) = FldInh
                    End If
                Next iZl
                .fields("Import_OK_Stufe_1") = True
                Set DAOARRAY1 = Nothing
                .update
            End If
        End With
    End If
    
    jj = 2
    k = 2
    If istOk And iwd = 2 Then
        recsetSQL1 = "Select Feldname, AnzZeilen, Zeile, Spalte FROM qry_Excel_Sel_Import_Felder WHERE TabTyp = " & jj & ";"
        Set rst = rst2
        With rst
            ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
        
            'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
            If ArrFill_DAO_OK1 Then
                For i = 0 To k
                    Set rg = xl.SetRange(13 + i, 2, 13 + i, 2) ' Anzahl Ma absolute Spalte Zeile
                    FldInh = Nz(rg(1, 1))
                    If Len(Trim(Nz(FldInh))) > 0 Then
                        .AddNew
                            .fields("VA_ID") = iID
                            For iZl = 0 To iZLMax1
                                iZeile = 0
                                iZeileOrg = DAOARRAY1(2, iZl)
                                fldName = DAOARRAY1(0, iZl)
                                iSpalte = DAOARRAY1(3, iZl)
                                iZeile = iZeileOrg + i
                                Set rg = xl.SetRange(iZeile, iSpalte, iZeile, iSpalte)
                                FldInh = Nz(rg(1, 1))
                                .fields(fldName) = FldInh
                            Next iZl
                        .update
                    End If
                Next i
                Set DAOARRAY1 = Nothing
            End If
        End With
    End If
    
    jj = 3
    k = 99
    If istOk Then
        recsetSQL1 = "Select Feldname, AnzZeilen, Zeile, Spalte FROM qry_Excel_Sel_Import_Felder WHERE TabTyp = " & jj & ";"
        Set rst = rst3
        With rst
            ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
        
            'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
            If ArrFill_DAO_OK1 Then
                l = 0 + iKorr
                For i = l To k
                    Set rg = xl.SetRange(18 + i, 16, 18 + i, 16)  ' Pos Nr absolute Spalte Zeile
                    FldInh = Nz(rg(1, 1))
                    If Len(Trim(Nz(FldInh))) > 0 And FldInh > 0 Then
                      .AddNew
                          .fields("VA_ID") = iID
                           For iZl = 0 To iZLMax1
                                iZeile = 0
                                iZeileOrg = DAOARRAY1(2, iZl)
                                fldName = DAOARRAY1(0, iZl)
                                iSpalte = DAOARRAY1(3, iZl)
                                iZeile = iZeileOrg + i
                                Set rg = xl.SetRange(iZeile, iSpalte, iZeile, iSpalte)
                                FldInh = Nz(rg(1, 1))
                                .fields(fldName) = FldInh
                            Next iZl
                      .update
                    End If
                Next i
                Set DAOARRAY1 = Nothing
            End If
        End With
    End If
    
If iWieder > 1 And iwd <= iWieder Then GoTo RepeatDat
    
XL_Ende:

xl.XL_Close_Sure

End Function


Function Cons_XL_Import_Test()

DoEvents

Set db = CurrentDb

        CurrentDb.Execute ("DELETE * FROM tblZZZ_XL_Auftrag_ZeitVorgabe WHERE VA_ID In(355, 312)")
        CurrentDb.Execute ("DELETE * FROM tblZZZ_XL_Auftrag_MA_Einsatz WHERE VA_ID In(355, 312)")
        DoEvents

Set rst1 = db.OpenRecordset("SELECT * FROM tblZZZ_XL_Auftrag;")
Set rst2 = db.OpenRecordset("SELECT * FROM tblZZZ_XL_Auftrag_ZeitVorgabe;")
Set rst3 = db.OpenRecordset("SELECT * FROM tblZZZ_XL_Auftrag_MA_Einsatz;")

    Cons_XL_Import_2 "C:\Kunden\CONSEC (Siegert)\PGM\Import\10-03-15 Greuther Fürth -Bochum.xls", 355
    Cons_XL_Import_2 "C:\Kunden\CONSEC (Siegert)\PGM\Import\09-17-15 Streetfood im Parks.xls", 312
    
rst1.Close
rst2.Close
rst3.Close

Set rst1 = Nothing
Set rst2 = Nothing
Set rst3 = Nothing

End Function


Function Cons_XL_Import_Einzel(DateinamePfad As String) As Long

Dim stPfad As String
Dim stDateiname As String
Dim stDatumvon As String
Dim dtDatum As Date
Dim stObjekt As String

Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim ID As Long
Dim ID1 As Long
Dim bImportOK As Boolean

Dim bIDNeu As Boolean

Dim i As Long

DoEvents

i = InStrRev(DateinamePfad, "\")
stPfad = Left(DateinamePfad, i)
stDateiname = Mid(DateinamePfad, i + 1)
stObjekt = Mid(stDateiname, 10)
i = InStrRev(stObjekt, ".")
stObjekt = Left(stObjekt, i - 1)
stDatumvon = Mid(stDateiname, 4, 2) & "." & Left(stDateiname, 2) & ".20" & Mid(stDateiname, 7, 2)

dtDatum = DateSerial(CLng("20" & Mid(stDateiname, 7, 2)), CLng(Left(stDateiname, 2)), CLng(Mid(stDateiname, 4, 2)))

ID = Nz(TLookup("ID", "tblZZZ_XL_Auftrag", "Dateiname = '" & stDateiname & "'"), 0)
ID1 = Nz(TLookup("ID", "tbl_VA_Auftragstamm", "ID = " & ID), 0)
If ID1 = 0 Then
    ID1 = Nz(TLookup("ID", "tbl_VA_Auftragstamm", "Excel_Dateiname = '" & stDateiname & "'"), 0)
End If
Set db = CurrentDb

If ID > 0 Then
    CurrentDb.Execute ("DELETE * FROM tblZZZ_XL_Auftrag_ZeitVorgabe WHERE VA_ID = " & ID)
    CurrentDb.Execute ("DELETE * FROM tblZZZ_XL_Auftrag_MA_Einsatz WHERE VA_ID = " & ID)
    CurrentDb.Execute ("DELETE * FROM tblZZZ_XL_AnzTage WHERE VA_ID = " & ID)
    CurrentDb.Execute ("DELETE * FROM tblZZZ_XL_Start WHERE VA_ID = " & ID)
    CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag SET tblZZZ_XL_Auftrag.Fehlerprotokoll = '', tblZZZ_XL_Auftrag.Aend_von = atcnames(1), tblZZZ_XL_Auftrag.Aend_am = Now(), tblZZZ_XL_Auftrag.ImportAlt_Vorhanden = True, tblZZZ_XL_Auftrag.NeuImport = False WHERE (((tblZZZ_XL_Auftrag.ID)= " & ID & "));")

    DoEvents
    bIDNeu = False
    
    If ID1 = 0 Then ' Auftrag
        Set rst = db.OpenRecordset("SELECT TOP 1 * FROM tbl_VA_Auftragstamm;")
        With rst
        'Add Kopfzeile leer tbl_VA_Auftragstamm
            .AddNew
                .fields("Auftrag") = stObjekt
                .fields("Dat_VA_Von") = dtDatum
                .fields("Dat_VA_Bis") = dtDatum
                .fields("Excel_Path") = stPfad
                .fields("Excel_Dateiname") = stDateiname
                .fields("Erst_von") = "System"
                .fields("Erst_am") = Now()
            .update
            DoEvents
            .Close
        End With
        Set rst = Nothing
        ID = Nz(TMax("ID", "tbl_VA_Auftragstamm"), 0)
    End If
    
Else
    bIDNeu = True
    Set rst = db.OpenRecordset("SELECT TOP 1 * FROM tbl_VA_Auftragstamm;")
    With rst
    'Add Kopfzeile leer tbl_VA_Auftragstamm
        .AddNew
            .fields("Auftrag") = stObjekt
            .fields("Dat_VA_Von") = dtDatum
            .fields("Dat_VA_Bis") = dtDatum
            .fields("Excel_Path") = stPfad
            .fields("Excel_Dateiname") = stDateiname
            .fields("Erst_von") = "System"
            .fields("Erst_am") = Now()
        .update
        DoEvents
        .Close
    End With
    Set rst = Nothing
    ID = Nz(TMax("ID", "tbl_VA_Auftragstamm"), 0)
 
    'Add Kopfzeile leer tblZZZ_XL_Auftrag
    Set rst = db.OpenRecordset("SELECT TOP 1 * FROM tblZZZ_XL_Auftrag;")
    With rst
        ID = Nz(TMax("ID", "tblZZZ_XL_Auftrag"), 0) + 1
        .AddNew
            .fields("ID") = ID
            .fields("Auftrag") = stObjekt
            .fields("DatumVonStr") = stDatumvon
            .fields("Dateipfad") = stPfad
            .fields("Dateiname") = stDateiname
            .fields("NeuImport") = True
            .fields("Erst_von") = "System"
            .fields("Erst_am") = Now()
        .update
        .Close
    End With
    Set rst = Nothing
End If

Set rst1 = db.OpenRecordset("SELECT * FROM tblZZZ_XL_Auftrag;")
Set rst2 = db.OpenRecordset("SELECT * FROM tblZZZ_XL_Auftrag_ZeitVorgabe;")
Set rst3 = db.OpenRecordset("SELECT * FROM tblZZZ_XL_Auftrag_MA_Einsatz;")

'########################################################################
'  import in Temp-Tabellen
'########################################################################
    Cons_XL_Import_2 DateinamePfad, ID
    DoEvents
'########################################################################
    
rst1.Close
rst2.Close
rst3.Close

Set rst1 = Nothing
Set rst2 = Nothing
Set rst3 = Nothing

'########################################################################
'  Berechnen der Übertragswerte der XL_Temp-Tabellen ...
'########################################################################
    bImportOK = Cons_XL_Import_3(ID)
'########################################################################
    
Cons_XL_Import_Einzel = ID

End Function


Function Cons_XL_Import_3(ID As Long) As Boolean

Dim strLog As String
Dim strSQL As String

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag SET tblZZZ_XL_Auftrag.DatumVon = CDate([DatumvonStr]) WHERE (((Len(Trim(Nz([DatumVonStr]))))<>0) AND (tblZZZ_XL_Auftrag.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag SET tblZZZ_XL_Auftrag.DatumBis = CDate([DatumbisStr]) WHERE (((Len(Trim(Nz([DatumBisStr]))))<>0) AND (tblZZZ_XL_Auftrag.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag SET tblZZZ_XL_Auftrag.DatumBis = [Datumvon] WHERE (((Len(Trim(Nz([DatumBisStr]))))=0) AND (tblZZZ_XL_Auftrag.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag SET tblZZZ_XL_Auftrag.Auftraggeber_ID = fget_kunID(NZ([Auftraggeber])) WHERE ((tblZZZ_XL_Auftrag.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag SET tblZZZ_XL_Auftrag.TreffpZeit = CDate(CDbl([TreffpZeitStr])) WHERE (((Left(Trim(Nz([TreffpZeitStr])),2))='0,') AND (tblZZZ_XL_Auftrag.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag SET tblZZZ_XL_Auftrag.TreffpOrt = [TreffpOrtstr] & ' ' & [TreffpZeitstr] WHERE (((Len(Trim(Nz([TreffpZeit]))))=0) AND ((Len(Trim(Nz([TreffpZeitstr]))))>0) AND (tblZZZ_XL_Auftrag.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag SET tblZZZ_XL_Auftrag.Std_satz_KD_1_Netto = Str(Nz([Std_satz_KD_1_Nettostr])), tblZZZ_XL_Auftrag.Std_satz_KD_3_Netto = Str(Nz([Std_satz_KD_3_Nettostr])), tblZZZ_XL_Auftrag.Std_Lohn_netto = Str(Nz([Std_Lohn_nettostr])), tblZZZ_XL_Auftrag.Fahrtkost_MA_Netto = Str(Nz([Fahrtkost_MA_Nettostr])), tblZZZ_XL_Auftrag.Fahrtkost_KD_Netto = Str(Nz([Fahrtkost_KD_Nettostr])) WHERE ((tblZZZ_XL_Auftrag.ID = " & ID & "));")

DateVervoll ID

strSQL = "UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.VA_Datum = CDate([VA_Datumstr]) WHERE (((Len(Trim(Nz([VA_Datumstr]))))<>0) AND (tblZZZ_XL_Auftrag_MA_Einsatz.ID = " & ID & "));"
CurrentDb.Execute (strSQL)

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.Beginnstr = '0' & Mid([Beginnstr],2) WHERE ((tblZZZ_XL_Auftrag_MA_Einsatz.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.Beginnstr = '0,0' WHERE ((Len(Trim(Nz([Beginnstr])))=0 OR tblZZZ_XL_Auftrag_MA_Einsatz.Beginnstr='1') AND (tblZZZ_XL_Auftrag_MA_Einsatz.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.Beginn = CDate(CDbl([Beginnstr])) WHERE ((tblZZZ_XL_Auftrag_MA_Einsatz.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.Endestr = '0' & Mid([Endestr],2) WHERE ((tblZZZ_XL_Auftrag_MA_Einsatz.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.Endestr = '0,0' WHERE ((Len(Trim(Nz([Endestr])))=0 OR tblZZZ_XL_Auftrag_MA_Einsatz.Endestr='1') AND (tblZZZ_XL_Auftrag_MA_Einsatz.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.Ende = CDate(CDbl([Endestr])) WHERE ((tblZZZ_XL_Auftrag_MA_Einsatz.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE qry_MA_ID INNER JOIN tblZZZ_XL_Auftrag_MA_Einsatz ON qry_MA_ID.NName = tblZZZ_XL_Auftrag_MA_Einsatz.Mitarbeiter SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_ID = [qry_MA_ID].[ID]  WHERE ((tblZZZ_XL_Auftrag_MA_Einsatz.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_NZug = 0 WHERE ((tblZZZ_XL_Auftrag_MA_Einsatz.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_NZug = 1 WHERE (((Len(Trim(Nz([Mitarbeiter]))))>0) AND ((tblZZZ_XL_Auftrag_MA_Einsatz.MA_ID)=0) AND (tblZZZ_XL_Auftrag_MA_Einsatz.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_NZug = 2 WHERE (((Len(Trim(Nz([Mitarbeiter]))))=0) AND ((tblZZZ_XL_Auftrag_MA_Einsatz.MA_ID)=0) AND (tblZZZ_XL_Auftrag_MA_Einsatz.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_PKWAnz = 0 WHERE ((tblZZZ_XL_Auftrag_MA_Einsatz.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_PKWAnz = 1 WHERE ((MA_PKW LIKE '*A*') AND (tblZZZ_XL_Auftrag_MA_Einsatz.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_PKWAnz = [MA_PKWAnz]+Nz([MA_PKW],0) WHERE (((IsNumeric(Nz([MA_PKW],0)))=True) AND (tblZZZ_XL_Auftrag_MA_Einsatz.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_Std = cdbl(Nz([MA_Stdstr],0)) WHERE ((IsNumeric(Nz([MA_Stdstr],0))=True) AND (tblZZZ_XL_Auftrag_MA_Einsatz.ID = " & ID & "));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_Std = FA_Runden(timeberech_G([VA_Datum],[Beginn],[Ende])) WHERE (([MA_Std] = 0) AND (tblZZZ_XL_Auftrag_MA_Einsatz.ID = " & ID & "));")


'-------------

CurrentDb.Execute ("INSERT INTO tblZZZ_XL_AnzTage ( VA_ID, VA_Datum, Anz_Soll ) SELECT tblZZZ_XL_Auftrag_MA_Einsatz.VA_ID, tblZZZ_XL_Auftrag_MA_Einsatz.VA_Datum, tblZZZ_XL_Auftrag_MA_Einsatz.ID AS Anz_Soll FROM tblZZZ_XL_Auftrag_MA_Einsatz WHERE ((tblZZZ_XL_Auftrag_MA_Einsatz.ID = " & ID & "));")

CurrentDb.Execute ("INSERT INTO tblZZZ_XL_Start ( VA_ID, VA_Datum, Beginn, MinEnde, MaxEnde, Anz_MA ) SELECT VA_ID, VA_Datum, Beginn, MinvonEnde, MaxvonEnde, Anz_MA FROM qry_XL_Start_Add WHERE ((VA_ID = " & ID & "));")



Cons_XL_Import_3 = True

End Function



Function Cons_XL_Import_3_Test() As Boolean
' UpdateArt 1 = Nur MA, Zeiten und PKW, d.h. Part 3 des Imports
'           2 = 1 + Schichten d.h. Part 2 und 3 des Imports
'           3 = 2 + Kopf  d.h. Alles - Kopf, Part 2 und 3 des Imports

Dim strLog As String

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag SET tblZZZ_XL_Auftrag.DatumVon = CDate([DatumvonStr]) WHERE (((Len(Trim(Nz([DatumVonStr]))))<>0) AND (1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag SET tblZZZ_XL_Auftrag.DatumBis = CDate([DatumbisStr]) WHERE (((Len(Trim(Nz([DatumBisStr]))))<>0) AND (1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag SET tblZZZ_XL_Auftrag.DatumBis = [Datumvon] WHERE (((Len(Trim(Nz([DatumBisStr]))))=0) AND (1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag SET tblZZZ_XL_Auftrag.Auftraggeber_ID = fget_kunID(NZ([Auftraggeber])) WHERE ((1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag SET tblZZZ_XL_Auftrag.TreffpZeit = CDate(CDbl([TreffpZeitStr])) WHERE (((Left(Trim(Nz([TreffpZeitStr])),2))='0,') AND (1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag SET tblZZZ_XL_Auftrag.TreffpOrt = [TreffpOrtstr] & ' ' & [TreffpZeitstr] WHERE (((Len(Trim(Nz([TreffpZeit]))))=0) AND ((Len(Trim(Nz([TreffpZeitstr]))))>0) AND (1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag SET tblZZZ_XL_Auftrag.Std_satz_KD_1_Netto = Str(Nz([Std_satz_KD_1_Nettostr])), tblZZZ_XL_Auftrag.Std_satz_KD_3_Netto = Str(Nz([Std_satz_KD_3_Nettostr])), tblZZZ_XL_Auftrag.Std_Lohn_netto = Str(Nz([Std_Lohn_nettostr])), tblZZZ_XL_Auftrag.Fahrtkost_MA_Netto = Str(Nz([Fahrtkost_MA_Nettostr])), tblZZZ_XL_Auftrag.Fahrtkost_KD_Netto = Str(Nz([Fahrtkost_KD_Nettostr])) WHERE ((1=1));")

DateVervoll

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.VA_Datum = CDate([VA_Datumstr]) WHERE (((Len(Trim(Nz([VA_Datumstr]))))<>0) AND (1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.Beginnstr = '0' & Mid([Beginnstr],2) WHERE ((1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.Beginnstr = '0,0' WHERE ((Len(Trim(Nz([Beginnstr])))=0 OR tblZZZ_XL_Auftrag_MA_Einsatz.Beginnstr='1') AND (1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.Beginn = CDate(CDbl([Beginnstr])) WHERE ((1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.Endestr = '0' & Mid([Endestr],2) WHERE ((1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.Endestr = '0,0' WHERE ((Len(Trim(Nz([Endestr])))=0 OR tblZZZ_XL_Auftrag_MA_Einsatz.Endestr='1') AND (1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.Ende = CDate(CDbl([Endestr])) WHERE ((1=1));")

CurrentDb.Execute ("UPDATE qry_MA_ID INNER JOIN tblZZZ_XL_Auftrag_MA_Einsatz ON qry_MA_ID.NName = tblZZZ_XL_Auftrag_MA_Einsatz.Mitarbeiter SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_ID = [qry_MA_ID].[ID]  WHERE ((1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_NZug = 0 WHERE ((1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_NZug = 1 WHERE (((Len(Trim(Nz([Mitarbeiter]))))>0) AND ((tblZZZ_XL_Auftrag_MA_Einsatz.MA_ID)=0) AND (1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_NZug = 2 WHERE (((Len(Trim(Nz([Mitarbeiter]))))=0) AND ((tblZZZ_XL_Auftrag_MA_Einsatz.MA_ID)=0) AND (1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_PKWAnz = 0 WHERE ((1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_PKWAnz = 1 WHERE ((MA_PKW LIKE '*A*') AND (1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_PKWAnz = [MA_PKWAnz]+Nz([MA_PKW],0) WHERE (((IsNumeric(Nz([MA_PKW],0)))=True) AND ((1)=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_Std = cdbl(Nz([MA_Stdstr],0)) WHERE ((IsNumeric(Nz([MA_Stdstr],0))=True) AND (1=1));")

CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz SET tblZZZ_XL_Auftrag_MA_Einsatz.MA_Std = FA_Runden(timeberech_G([VA_Datum],[Beginn],[Ende])) WHERE (([MA_Std] = 0) AND (1=1));")



'-------------

CurrentDb.Execute ("INSERT INTO tblZZZ_XL_AnzTage ( VA_ID, VA_Datum, Anz_Soll ) SELECT tblZZZ_XL_Auftrag_MA_Einsatz.VA_ID, tblZZZ_XL_Auftrag_MA_Einsatz.VA_Datum, tblZZZ_XL_Auftrag_MA_Einsatz.ID AS Anz_Soll FROM tblZZZ_XL_Auftrag_MA_Einsatz WHERE ((1=1));")

CurrentDb.Execute ("INSERT INTO tblZZZ_XL_Start ( VA_ID, VA_Datum, Beginn, MinEnde, MaxEnde, Anz_MA ) SELECT VA_ID, VA_Datum, Beginn, MinvonEnde, MaxvonEnde, Anz_MA FROM qry_XL_Start_Add WHERE ((1=1));")



Cons_XL_Import_3_Test = True

End Function

Function fget_kunID(s As String) As Variant
Dim i As Long
fget_kunID = 0
If Len(Trim(Nz(s))) > 0 Then
    i = Nz(TLookup("kun_ID", "tbl_KD_Kundenstamm", "kun_Firma Like '*" & s & "*'"))
End If
If i = 0 Then
    i = Nz(TLookup("kun_ID", "tbl_KD_Kundenstamm", "kun_Matchcode Like '*" & s & "*'"))
End If

If i > 0 Then fget_kunID = i

End Function


Function Import_Teil2(ID As Long, bExists As Boolean)

Dim strSQL As String

    strSQL = ""
    strSQL = strSQL & "INSERT INTO tbl_MA_VA_Zuordnung ( VA_ID, VADatum, VAStart_ID, VADatum_ID, PosNr, MA_ID, Bemerkungen, MA_Start, MA_Ende, PreisArt_ID, PKW_Anzahl )"
    strSQL = strSQL & " SELECT tblZZZ_XL_Auftrag_MA_Einsatz.VA_ID, tblZZZ_XL_Auftrag_MA_Einsatz.VA_Datum, tbl_VA_Start.ID AS VAStart_ID, tbl_VA_Start.VADatum_ID, tblZZZ_XL_Auftrag_MA_Einsatz.VA_Lfd, tblZZZ_XL_Auftrag_MA_Einsatz.MA_ID, "
    strSQL = strSQL & " tblZZZ_XL_Auftrag_MA_Einsatz.Mitarbeiter, tblZZZ_XL_Auftrag_MA_Einsatz.Beginn, tblZZZ_XL_Auftrag_MA_Einsatz.Ende, 1 AS Ausdr1, tblZZZ_XL_Auftrag_MA_Einsatz.MA_PKWAnz"
    strSQL = strSQL & " FROM tblZZZ_XL_Auftrag_MA_Einsatz INNER JOIN tbl_VA_Start ON (tbl_VA_Start.VA_Start = tblZZZ_XL_Auftrag_MA_Einsatz.Beginn) AND (tbl_VA_Start.VADatum = tblZZZ_XL_Auftrag_MA_Einsatz.VA_Datum) AND (tblZZZ_XL_Auftrag_MA_Einsatz.VA_ID = tbl_VA_Start.VA_ID)"
    strSQL = strSQL & " WHERE (((tblZZZ_XL_Auftrag_MA_Einsatz.VA_ID)= " & ID & "));"

    If bExists = False Then   ' Neuer Auftrag
    
 'Neuer Auftrag
 '##############################
 ' Insert AnzTage
        CurrentDb.Execute ("INSERT INTO tbl_VA_AnzTage ( VA_ID, VADatum, TVA_Soll, TVA_Ist, PKW_Anzahl ) SELECT tblZZZ_XL_AnzTage.VA_ID, tblZZZ_XL_AnzTage.VA_Datum, tblZZZ_XL_AnzTage.Anz_Soll, 0 AS Ausdr1, 0 AS Ausdr2 FROM tblZZZ_XL_AnzTage WHERE (((tblZZZ_XL_AnzTage.VA_ID)= " & ID & "));")
 ' Insert VA_Start
        CurrentDb.Execute ("INSERT INTO tbl_VA_Start ( VA_ID, VADatum, MA_Anzahl, VA_Start, VA_Ende ) SELECT tblZZZ_XL_Start.VA_ID, tblZZZ_XL_Start.VA_Datum, tblZZZ_XL_Start.Anz_MA, tblZZZ_XL_Start.Beginn, fTimeReuck([MinEnde],[MaxEnde]) AS Endez FROM tblZZZ_XL_Start WHERE (((tblZZZ_XL_Start.VA_ID)= " & ID & "));")
 ' Update Ziel VA_Start mit ID von VA_Datum
        CurrentDb.Execute ("UPDATE tbl_VA_AnzTage INNER JOIN tbl_VA_Start ON (tbl_VA_Start.VADatum = tbl_VA_AnzTage.VADatum) AND (tbl_VA_AnzTage.VA_ID = tbl_VA_Start.VA_ID) SET tbl_VA_Start.VADatum_ID = [tbl_VA_AnzTage].[ID] WHERE (((tbl_VA_Start.VA_ID)= " & ID & "));")
 ' Update Quelle  tblZZZ_XL_Auftrag_MA_Einsatz mit ID von VA_Datum und ID von VA_Start
        CurrentDb.Execute ("UPDATE tbl_VA_Start INNER JOIN tblZZZ_XL_Auftrag_MA_Einsatz ON (tbl_VA_Start.VA_Start = tblZZZ_XL_Auftrag_MA_Einsatz.Beginn) AND (tbl_VA_Start.VA_ID = tblZZZ_XL_Auftrag_MA_Einsatz.VA_ID) AND (tbl_VA_Start.VADatum = tblZZZ_XL_Auftrag_MA_Einsatz.VA_Datum) SET tblZZZ_XL_Auftrag_MA_Einsatz.VADatum_ID = [tbl_VA_Start].[VADatum_ID], tblZZZ_XL_Auftrag_MA_Einsatz.VAStart_ID = [tbl_VA_Start].[ID] WHERE (((tblZZZ_XL_Auftrag_MA_Einsatz.ID)= " & ID & "));")
        DoEvents
                
'Insert MA in tbl_MA_VA_Zuordnung
        CurrentDb.Execute (strSQL)
    
    Else
' Bestehender Auftrag
'##############################
'Update bestehende Zeiten
        CurrentDb.Execute ("UPDATE tblZZZ_XL_Auftrag_MA_Einsatz INNER JOIN tbl_MA_VA_Zuordnung ON (tblZZZ_XL_Auftrag_MA_Einsatz.VAStart_ID = tbl_MA_VA_Zuordnung.VAStart_ID) AND (tblZZZ_XL_Auftrag_MA_Einsatz.VADatum_ID = tbl_MA_VA_Zuordnung.VADatum_ID) AND (tblZZZ_XL_Auftrag_MA_Einsatz.MA_ID = tbl_MA_VA_Zuordnung.MA_ID) AND (tblZZZ_XL_Auftrag_MA_Einsatz.VA_ID = tbl_MA_VA_Zuordnung.VA_ID) SET tbl_MA_VA_Zuordnung.MA_Start = [Beginn], tbl_MA_VA_Zuordnung.MA_Ende = [Ende], tbl_MA_VA_Zuordnung.PKW_Anzahl = [MA_PKWAnz] WHERE (((tbl_MA_VA_Zuordnung.VA_ID)= " & ID & "));")

 'Wegen Unique Key nur Neue inserten, bestehende sollten den Unique Key verletzen
        CurrentDb.Execute (strSQL)
        
'Auftragsstatus auf abgeschlossen setzen
        CurrentDb.Execute ("UPDATE tbl_VA_Auftragstamm SET tbl_VA_Auftragstamm.Veranst_Status_ID = 3 WHERE (((tbl_VA_Auftragstamm.ID)=" & ID & "));")
    
    End If

End Function

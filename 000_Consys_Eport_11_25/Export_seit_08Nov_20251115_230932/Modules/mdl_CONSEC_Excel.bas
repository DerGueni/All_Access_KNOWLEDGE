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
Dim iAufArt As Long

CurrentDb.Execute ("DELETE * FROM tblZZZ_XL_Auftrag;")
CurrentDb.Execute ("DELETE * FROM tblZZZ_XL_Auftrag_ZeitVorgabe;")
CurrentDb.Execute ("DELETE * FROM tbl_XL_Auftrag_Einsatz;")

DoEvents

Set db = CurrentDb

Set rst1 = db.OpenRecordset("SELECT * FROM tblZZZ_XL_Auftrag;")
Set rst2 = db.OpenRecordset("SELECT * FROM tblZZZ_XL_Auftrag_ZeitVorgabe;")
Set rst3 = db.OpenRecordset("SELECT * FROM tbl_XL_Auftrag_Einsatz;")

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
recsetSQL1 = "Select Path, FDName, AuftrArt FROM tbl_XL_Auftrag_ZZZ_Dateinamen;"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1
        sPath = DAOARRAY1(0, iZl)
        sName = DAOARRAY1(1, iZl)
        iAufArt = DAOARRAY1(2, iZl)
        dtName = sPath & sName
        If File_exist(dtName) Then
            Call Cons_XL_Import_2(dtName, iAufArt)
            
            DoEvents
            DBEngine.Idle dbRefreshCache
            DBEngine.Idle dbFreeLocks
            DoEvents

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

Function Cons_XL_Import_2(dtName As String, iAufArt As Long)

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
Dim i As Long, jj As Long, j As Long
Dim iAufNr As Long
Dim rg
Dim iZeile As Long, iSpalte As Long
Dim iKorr As Long
Dim istOk As Boolean

Dim rst As Object
Dim iLauf As Long
Dim iStart As Long
'rg = Row, column
'################

xl.XL_Wkb_Open_RDOnly (dtName)
Sleep 20
DoEvents

If xl.SelectSheet_Test("Liste") = False Then GoTo XL_Ende
'If XL.xlSheetCount <> 2 Then GoTo XL_Ende

xl.SelectSheet ("Liste")
DoEvents

'Public Function SetRange(IRow As Long, iCol As Long, IRowEnd As Long, IColEnd As Long) As Object
' Set rg = XL.SetRange(1, 1, ilarow, 3)

' Test auf Zeile 17 und Spalte 41 "PKW"

iZeile = 17
iSpalte = 41
Set rg = xl.SetRange(iZeile, iSpalte, iZeile + 1, iSpalte)

istOk = False
If Nz(rg(1, 1)) = "PKW" Then
    istOk = True
    iKorr = 0
ElseIf Nz(rg(2, 1)) = "PKW" Then
    istOk = True
    iKorr = 1
End If

If istOk Then
    For jj = 1 To 3
        If jj = 1 Then
            Set rst = rst1
        ElseIf jj = 2 Then
            Set rst = rst2
        ElseIf jj = 3 Then
            Set rst = rst3
        End If
        recsetSQL1 = "Select Feldname, AnzZeilen, Zeile, Spalte FROM tbl_XL_Auftrag_ZZ_Interne_PositionsNr WHERE TabTyp = " & jj & ";"
        
        ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
        'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
        iStart = 1
        If ArrFill_DAO_OK1 Then
            iLauf = DAOARRAY1(1, 0)
            If jj = 2 Then
                iLauf = iLauf + iKorr
            End If
            If jj = 3 Then
                iStart = iStart + iKorr
                iLauf = iLauf - iKorr
            End If
            With rst
                For j = iStart To iLauf
                   .AddNew
                        If jj = 1 Then
                            .fields("ImpArt") = iAufArt
                            .fields("Dateiname") = dtName
                        Else
                            .fields("Auf_ID") = iAufNr
                        End If
                        For iZl = 0 To iZLMax1
                            iZeile = DAOARRAY1(2, iZl) + j - 1
                            iSpalte = DAOARRAY1(3, iZl)
                            Set rg = xl.SetRange(iZeile, iSpalte, iZeile, iSpalte)
                            .fields(DAOARRAY1(0, iZl)) = Nz(rg(1, 1))
                            If DAOARRAY1(0, iZl) = "Gname" And Len(Trim(Nz(rg(1, 1)))) = 0 Then
                                Exit For
                            End If
                        Next iZl
                   If jj = 3 Then
                        If Len(Trim(Nz(.fields("Gname")))) > 0 Then
                            .update
                        End If
                   ElseIf jj = 2 Then
                        If Len(Trim(Nz(.fields("Anz")))) > 0 Then
                            .update
                        End If
                   Else
                       .update
                    End If
                Next j
                DoEvents
                If jj = 1 Then
                    iAufNr = TMax("ID", "tblZZZ_XL_Auftrag")
                End If
                Set DAOARRAY1 = Nothing
            End With
        End If
    Next jj
End If

XL_Ende:

xl.XL_Close_Sure

End Function


Function Cons_XL_Import_Test()

CurrentDb.Execute ("DELETE * FROM tblZZZ_XL_Auftrag;")
CurrentDb.Execute ("DELETE * FROM tblZZZ_XL_Auftrag_ZeitVorgabe;")
CurrentDb.Execute ("DELETE * FROM tbl_XL_Auftrag_Einsatz;")

DoEvents

Set db = CurrentDb

Set rst1 = db.OpenRecordset("SELECT * FROM tblZZZ_XL_Auftrag;")
Set rst2 = db.OpenRecordset("SELECT * FROM tblZZZ_XL_Auftrag_ZeitVorgabe;")
Set rst3 = db.OpenRecordset("SELECT * FROM tbl_XL_Auftrag_Einsatz;")


    Cons_XL_Import_2 "C:\Kunden\CONSEC (Siegert)\Aufträge_alt\01-05-15 Single Party Terminal 90.xlsm", 1
    Cons_XL_Import_2 "C:\Kunden\CONSEC (Siegert)\Aufträge_alt\03-04-15 IWA 2015.xls", 1
    
rst1.Close
rst2.Close
rst3.Close

Set rst1 = Nothing
Set rst2 = Nothing
Set rst3 = Nothing

End Function
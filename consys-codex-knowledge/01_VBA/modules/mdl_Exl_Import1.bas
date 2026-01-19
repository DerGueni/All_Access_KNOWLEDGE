Attribute VB_Name = "mdl_Exl_Import1"
Option Compare Database
Option Explicit

Function fTimeReuck(s1 As Date, s2 As Date) As Date
Dim d As Date
If Left(s1, 1) = 0 And Left(s2, 1) = 2 Then
    d = s1
Else
    d = s2
End If
fTimeReuck = d
End Function

Function fbackRev(s As String) As String
Dim i As Long
i = InStrRev(s, "\")
fbackRev = s
If i > 0 Then
    fbackRev = Mid(s, i + 1)
End If
End Function

Function fkurz(s As String) As String
Dim i As Long
Dim pk As String
fkurz = s
pk = Chr(46)
i = InStrRev(s, pk, , vbTextCompare)
If i > 0 Then
    fkurz = Left(s, i - 1)
    fkurz = Mid(fkurz, 10)
End If
End Function

Function fDt(s As String) As Date
Dim tt As Long
Dim mm As Long
Dim jj As Long
mm = Left(s, 2)
tt = Mid(s, 4, 2)
jj = 2000 + Mid(s, 7, 2)
fDt = DateSerial(jj, mm, tt)
End Function

Function fZtAdd(s, t) As Date
Dim si As Single
Dim dt As Date
Dim s2 As Single
Dim s3 As Single

si = CDbl(Nz(s, 0))
s2 = CDbl(Nz(t, 0)) / 24#
s3 = si + s2
If s3 >= 1 Then s3 = s3 - Fix(s3)
fZtAdd = CDate(s3)

End Function

Function fZt(s) As Date
Dim si As Single
Dim dt As Date

On Error Resume Next

si = CDbl(Nz(s, 0))
If si >= 1 Then si = si - Fix(si)
fZt = CDate(si)

End Function


Function ftst()

Dim ID As Long, strName As String, strPath As String

On Error Resume Next

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
recsetSQL1 = "Select ID, Dateiname, strPath from Import_Auftraege_2015_09_09;"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1
        ID = DAOARRAY1(0, iZl)
        strName = DAOARRAY1(1, iZl)
        strPath = DAOARRAY1(2, iZl)
            Call DoCmd.TransferSpreadsheet(acImport, 8, "T_" & Right("000" & ID, 3), strPath & strName, False, "Liste!A:DA")
        DoEvents
    Next iZl
    Set DAOARRAY1 = Nothing
End If

End Function

Function ftst1()

Dim ID As Long, strName As String, strPath As String

On Error Resume Next

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
recsetSQL1 = "Select ID, Dateiname, strPath from Import_Auftraege_2015_09_09;"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1
        ID = DAOARRAY1(0, iZl)
        strName = DAOARRAY1(1, iZl)
        strPath = DAOARRAY1(2, iZl)
            Call DoCmd.TransferSpreadsheet(acLink, 8, "L_" & Right("000" & ID, 3), strPath & strName, False)
        DoEvents
    Next iZl
    Set DAOARRAY1 = Nothing
End If

End Function

Function DateVervoll(Optional VA_ID As Long = 0)

Dim db As DAO.Database
Dim rst As DAO.Recordset

Dim vglDat As String

Set db = CurrentDb
If VA_ID = 0 Then
    Set rst = db.OpenRecordset("SELECT * FROM tblZZZ_XL_Auftrag_MA_Einsatz ORDER BY VA_ID, ID;")
Else
    Set rst = db.OpenRecordset("SELECT * FROM tblZZZ_XL_Auftrag_MA_Einsatz WHERE VA_ID = " & VA_ID & " ORDER BY VA_ID, ID;")
End If
With rst
    Do While Not .EOF
        If Len(Trim(Nz(.fields("VA_DatumStr")))) = 0 Then
            .Edit
                .fields("VA_DatumStr") = vglDat
            .update
        Else
            vglDat = .fields("VA_DatumStr")
        End If
        .MoveNext
    Loop
End With

End Function

Function fAlteID_Neu(Optional iID As Long = 210)

Dim db As DAO.Database
Dim rst As DAO.Recordset

Dim vglDat As String
Dim i As Long

i = iID

Set db = CurrentDb
Set rst = db.OpenRecordset("SELECT * FROM qry_IDAlt_Upd ORDER By DatumVon;")
With rst
    Do While Not .EOF
        .Edit
            .fields("IDAlt") = i
        .update
        i = i + 1
        .MoveNext
    Loop
    .Close
End With
Set rst = Nothing
End Function

Function fAnzTage_erst(VA_ID As Long, Startdat As Date, endedat As Date) As Long

Dim i As Long
Dim j As Long
Dim dtk As Date
Dim db As DAO.Database
Dim rst As DAO.Recordset
   On Error GoTo fAnzTage_erst_Error

Set db = CurrentDb

fAnzTage_erst = 0

'On Error Resume Next

Set rst = db.OpenRecordset("Select top 1 * From tbl_VA_AnzTage;")
With rst
j = DateDiff("d", Startdat, endedat, 2, 2)
dtk = Startdat
For i = 0 To j
    .AddNew
        .fields(1) = VA_ID
        .fields(2) = dtk
        .fields(3) = 0
        .fields(4) = 0
        .fields(5) = True
        .fields(6) = 0
    .update
    dtk = dtk + 1
Next i
.Close
End With
Set rst = Nothing

   On Error GoTo 0
   Exit Function

fAnzTage_erst_Error:
    If Err.Number = 3022 Or Err.Number = 3201 Then
        Err.clear
        Resume Next
    Else
        MsgBox "Error " & Err.Number & " (" & Err.description & ") in procedure fAnzTage_erst of Modul Modul1"
    End If
End Function

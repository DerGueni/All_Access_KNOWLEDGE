Attribute VB_Name = "mdlSonstiges5"
Option Compare Database
Option Explicit


Function TextFileLesen(strFile As String, tblArray As Variant)

Dim intFile As Integer
'Dim strFile As String
Dim strIn As String
Dim i As Long
  
  i = 0
  ReDim tblArray(0)
  intFile = FreeFile()
  'strFile = "C:\Folder\MyData.txt"
  Open strFile For Input As #intFile
  Do While Not EOF(intFile)
    ReDim Preserve tblArray(i)
    Line Input #intFile, strIn
    tblArray(i) = strIn
    i = i + 1
  Loop

  Close #intFile
End Function

Function TextFileSchreibenArr(strFile As String, tblArray As Variant)


Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long


Dim intFile As Integer
'Dim strFile As String
Dim strIn As String
Dim i As Long

intFile = FreeFile()
Open strFile For Output As #intFile

iZLMax1 = UBound(tblArray)

For iZl = 0 To iZLMax1

      Print #intFile, CStr(tblArray(iZl))
'          Print #intFile, ""

Next iZl

Close #intFile
  
End Function

Function TextFileSchreiben(strFile As String, strSQL As String)


Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long


Dim intFile As Integer
'Dim strFile As String
Dim strIn As String
Dim i As Long

intFile = FreeFile()
Open strFile For Output As #intFile

recsetSQL1 = strSQL
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1

          Print #intFile, CStr(DAOARRAY1(0, iZl))
'          Print #intFile, ""

    Next iZl
    Set DAOARRAY1 = Nothing
End If

Close #intFile
  
End Function




Function create_subfolder_from_Recordset(strPath As String, strSQL As String) As Boolean
'Idee: Um (hauptsächlich für Bilder) ein eigenes Subdirectory pro ArtikelNr automatisch zu generieren
' strPath = Pfad des Hauptdirectories, (Beispiel: "C:\Kunden\Kloy\Artikel\Images") Darunter werden die Directories angelegt
' strSQL ist ein Recordset wobei die erste Spalte als Namensgeber für das Subdir fungiert

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
Dim pfnam As String

If Len(Trim(Nz(strSQL))) = 0 Then
    Exit Function
End If

If Not Path_erzeugen(strPath, False, True) Then
    Exit Function
End If

If Right(strPath, 1) <> "\" Then
    strPath = strPath & "\"
End If

recsetSQL1 = strSQL
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1
        pfnam = DAOARRAY1(0, iZl)
        MkDir strPath & pfnam
    Next iZl
    Set DAOARRAY1 = Nothing
End If

MsgBox "Alle SubDirs erzeugt"

End Function


'Public Function GetWordConstants()
'' need to add Reference library TypeLib information
'
'    Dim theLibrary As TypeLibInfo
'    Dim theLibraryPath
'    theLibraryPath = "C:\Program Files (x86)\Microsoft Office\Office15\Excel.exe"
''    theLibraryPath = "C:\Program Files (x86)\Microsoft Office\Office15\MSWord.olb"
''    theLibraryPath = "C:\Program Files (x86)\Microsoft Office\Office15\MSAcc.olb"
''    theLibraryPath = "C:\Program Files (x86)\Microsoft Office\Office15\MSOutl.olb"
''    theLibraryPath = "C:\Program Files (x86)\Microsoft Office\Office15\MSPPT.olb"
''    theLibraryPath = "C:\Program Files (x86)\Common Files\DESIGNER\MSADDNDR.OLB"
''    theLibraryPath = "C:\Program Files (x86)\Common Files\Microsoft Shared\VBA\VBA6\VBE6EXT.OLB"
''    theLibraryPath = "C:\Windows\SysWow64\VEN2232.OLB"
''    theLibraryPath = "C:\Windows\Microsoft.NET\Framework\v2.0.50727\vsavb7.olb"
'' Get information from the Object library
'    Set theLibrary = TypeLibInfoFromFile(theLibraryPath)
'' Open file for output.
'    Open "C:\Test\DiversConstants.txt" For Output As #1
'
'    Dim theRecord, theMember
'    For Each theRecord In theLibrary.Constants
'        For Each theMember In theRecord.Members
'            '            Print #1, "Private const " & theMember.Name & " = " & theMember.Value
''            Print #1, theMember.Name
'            Print #1, Chr$(34) & theMember.Name & Chr$(34) & ";" & theMember.Value & ";" & Chr$(34) & "Private const " & theMember.Name & " = " & theMember.Value & Chr$(34) & ";" & Chr$(34) & theRecord.Name & Chr$(34) & ";" & Chr$(34) & UCase(Left(theMember.Name, 2)) & Chr$(34) & ";" & Chr$(34) & "Off2013" & Chr$(34)
'        Next theMember
'    Next theRecord
'    Set theLibrary = Nothing
'    Close #1
'End Function
'


''''Call getzerodatasummary("c:\summary.txt")
''''Add Reference Microsoft DAO 3.6 Library or Microsoft Office xx.0 Access database engine Object Library
'''
''''If I understand the code correctly, that VBA code creates a document, giving ONE percentage for each table,
''''saying how much of the NUMERIC fields are = 0
''''The variable ithr contains the number of records of each table, but is not used here.
''''Interesting for BI calculations of a cube (Filling mode).
'''
'''Sub getzerodatasummary(filename As String)
'''Dim dbs As dao.Database, fldObj As dao.Field, rs As dao.Recordset
'''Dim I As Integer, tablename As String, N As Integer, M As Integer, jthf As Integer, ithr As Long, fieldname As String
'''Dim Total As Double, zeros As Double, percentage As Double
'''On Error GoTo Error_Handler
'''Set dbs = CurrentDb
'''N = dbs.TableDefs.Count
'''If (N > 0) Then
'''    Open filename For Output As #1
'''    For I = 0 To N - 1
'''        tablename = dbs.TableDefs(I).Name
'''        If (InStr(tablename, "MSys") <> 1) Then
'''            Set rs = dbs.OpenRecordset("SELECT * FROM [" & tablename & "];", dbOpenDynaset)
'''            Total = 0
'''            zeros = 0
'''            If Not rs.EOF Then
'''                With rs
'''                    M = rs.Fields.Count
'''                    .MoveFirst
'''                    ithr = 0
'''                    Do Until .EOF
'''                        ithr = ithr + 1
'''                        For jthf = 0 To M - 1
'''                            ft = .Fields(jthf).Type
'''                            If (ft = dbInteger Or ft = dbLong Or ft = dbCurrency Or ft = dbDecimal Or ft = dbDouble Or ft = dbFloat) Then
'''                                Total = Total + 1
'''                                If (.Fields(jthf).Value = 0) Then zeros = zeros + 1
'''                            End If
'''                        Next
'''                        .MoveNext
'''                    Loop
'''                End With
'''            End If
'''            percentage = zeros / Total
'''            Print #1, tablename & " " & percentage
'''        End If
'''    Next I
'''    Close #1
'''End If
'''dbs.Close
'''Set dbs = Nothing
'''Set rs = Nothing
'''Exit Sub
'''Error_Handler:
'''MsgBox err.Number & ":" & err.Description
'''End Sub
 


Function rstDcount(fld As String, ByVal rsrc As String, Optional strwh As String = "") As Variant

Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim i As Long
Dim strSQL As String

On Error Resume Next

rstDcount = ""

If Len(Trim(Nz(rsrc))) = 0 Or Len(Trim(Nz(fld))) = 0 Then Exit Function

rsrc = Trim(rsrc)
If Right(rsrc, 1) = ";" Then
    rsrc = Left(rsrc, Len(rsrc) - 1)
End If

If Len(Trim(Nz(strwh))) > 0 Then
    strSQL = "SELECT count(" & fld & ") FROM (" & rsrc & ") WHERE " & strwh & ";"
Else
    strSQL = "SELECT count(" & fld & ") FROM (" & rsrc & ");"
End If

Set db = CurrentDb
Set rst = db.OpenRecordset(strSQL, dbOpenSnapshot)
If rst.EOF Then
    rstDcount = 0
Else
    rstDcount = Nz(rst.fields(0), 0)
End If
rst.Close
Set rst = Nothing
Set db = Nothing
End Function

Function rstDMax(fld As String, ByVal rsrc As String, Optional strwh As String = "") As Variant

Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim i As Long
Dim strSQL As String

On Error Resume Next

rstDMax = ""

If Len(Trim(Nz(rsrc))) = 0 Or Len(Trim(Nz(fld))) = 0 Or fld = "*" Then Exit Function

rsrc = Trim(rsrc)
If Right(rsrc, 1) = ";" Then
    rsrc = Left(rsrc, Len(rsrc) - 1)
End If

If Len(Trim(Nz(strwh))) > 0 Then
    strSQL = "SELECT max(" & fld & ") FROM (" & rsrc & ") WHERE " & strwh & ";"
Else
    strSQL = "SELECT max(" & fld & ") FROM (" & rsrc & ");"
End If

Set db = CurrentDb
Set rst = db.OpenRecordset(strSQL, dbOpenSnapshot)
If rst.EOF Then
    rstDMax = ""
Else
    rstDMax = Nz(rst.fields(0))
End If
rst.Close
Set rst = Nothing
Set db = Nothing
End Function

Function rstDMin(fld As String, ByVal rsrc As String, Optional strwh As String = "") As Variant

Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim i As Long
Dim strSQL As String

On Error Resume Next

rstDMin = ""

If Len(Trim(Nz(rsrc))) = 0 Or Len(Trim(Nz(fld))) = 0 Or fld = "*" Then Exit Function

rsrc = Trim(rsrc)
If Right(rsrc, 1) = ";" Then
    rsrc = Left(rsrc, Len(rsrc) - 1)
End If

If Len(Trim(Nz(strwh))) > 0 Then
    strSQL = "SELECT Min(" & fld & ") FROM (" & rsrc & ") WHERE " & strwh & ";"
Else
    strSQL = "SELECT Min(" & fld & ") FROM (" & rsrc & ");"
End If

Set db = CurrentDb
Set rst = db.OpenRecordset(strSQL, dbOpenSnapshot)
If rst.EOF Then
    rstDMin = ""
Else
    rstDMin = Nz(rst.fields(0))
End If
rst.Close
Set rst = Nothing
Set db = Nothing
End Function



Function rstDLookUp(fld As String, ByVal rsrc As String, Optional strwh As String = "") As Variant

Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim i As Long
Dim strSQL As String

On Error Resume Next

rstDLookUp = ""

If Len(Trim(Nz(rsrc))) = 0 Or Len(Trim(Nz(fld))) = 0 Or fld = "*" Then Exit Function

rsrc = Trim(rsrc)
If Right(rsrc, 1) = ";" Then
    rsrc = Left(rsrc, Len(rsrc) - 1)
End If

If Len(Trim(Nz(strwh))) > 0 Then
    strSQL = "SELECT TOP 1 " & fld & " FROM (" & rsrc & " WHERE " & strwh & ");"
Else
    strSQL = "SELECT TOP 1 " & fld & " FROM (" & rsrc & ");"
End If

Set db = CurrentDb
Set rst = db.OpenRecordset(strSQL, dbOpenSnapshot)
If rst.EOF Then
    rstDLookUp = ""
Else
    rstDLookUp = Nz(rst.fields(0))
End If
rst.Close
Set rst = Nothing
Set db = Nothing
End Function



Function rdTst()
Dim myArray As Variant
Dim i As Long

Call TextFileLesen("C:\Kunden\erioTec (Kirchner - Siemens)\20140402_SVN\xxx.txt", myArray)

For i = 0 To 2
    Debug.Print myArray(i)
Next i
End Function

Function txt2bin(xstr As String) As String
Dim i As Long
Dim xs As Long

txt2bin = ""
xstr = Trim(Nz(xstr))
For i = 1 To Len(xstr)
    xs = Asc(Mid(xstr, i, 1))
    txt2bin = txt2bin & Right(Long2Bin(xs), 8) & " "
Next i
txt2bin = Trim(txt2bin)
End Function

Function bin2txt(xstr As String, xdelim As String) As String

Dim TestArray() As String, AnzWd
Dim i As Long

bin2txt = ""
AnzWd = ExtractWords(xstr, TestArray(), xdelim, False)
For i = LBound(TestArray) To UBound(TestArray)
    bin2txt = bin2txt & Chr$(Bin2Long(TestArray(i)))
'    Debug.Print "   String " & i & " : " & TestArray(i)
Next i

End Function

Function tst_bin2txt()
' 01100100 01100001 01110100 01100001 00100000 01101001 01110011 00100000 01100011 01101111 01101111 01101100
Dim xstr As String
Dim xdel As String
xstr = "01100100 01100001 01110100 01100001 00100000 01101001 01110011 00100000 01100011 01101111 01101111 01101100"
Debug.Print xstr
xdel = " "
tst_bin2txt = bin2txt(xstr, xdel)
Debug.Print txt2bin(CStr(tst_bin2txt))
End Function


Function fCnvQM(ByVal strString As String) As String
    'Funktion, die Hochkommata - Chr(39) - innerhalb eines Strings verdoppelt,
    'um Strings, die Hochkommata beinhalten an SQL-Syntax übergeben zu können

    Dim i As Integer
    Dim strStringNew As String

    For i = 1 To Len(strString)
        If Mid(strString, i, 1) = Chr(39) Then
            strStringNew = strStringNew & Chr(39) & Chr(39)
        Else
            strStringNew = strStringNew & Mid(strString, i, 1)
        End If
    Next i

    'Return Value
    fCnvQM = strStringNew
End Function


'Korrekturtyp(Euro, Stunden, Beides)
Public Function fcnGetKorrType() As Boolean

    fcnGetKorrType = Get_Priv_Property("prp_Korr_Stunden")
    
End Function

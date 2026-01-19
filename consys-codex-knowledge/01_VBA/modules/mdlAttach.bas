Attribute VB_Name = "mdlAttach"
Option Compare Database
Option Explicit

Function f_btnNeuAttach(iID As Long, iTable As Long)

Dim fn As String
Dim Dlen As Long
Dim dtfdate As Date
Dim Drive As String, DirName As String, fName As String, Ext As String
Dim db As DAO.Database
Dim rst As DAO.Recordset


fn = AlleSuch()

If File_exist(fn) = False Then

    MsgBox " Keine / Falsche Datei ausgewählt ", vbCritical + vbOKOnly, "Zuordnung fehlgeschlagen"
    Exit Function

End If


Call FParsePath(fn, Drive, DirName, fName, Ext)

Set db = CurrentDb
Set rst = db.OpenRecordset("SELECT TOP 1 * FROM tbl_Zusatzdateien")

    Dlen = fileLen(fn)
    dtfdate = FileDateTime(fn)

    rst.AddNew
        rst.fields(1) = iTable
        rst.fields(2) = iID
        rst.fields(3) = fn
        rst.fields(4) = dtfdate
        rst.fields(5) = Dlen
        rst.fields(6) = Ext
        rst.fields(7) = ""
        rst.fields(8) = ""
        rst.fields(9) = 0
        rst.fields(10) = atCNames(1)
        rst.fields(11) = Date
        rst.fields(12) = atCNames(1)
        rst.fields(13) = Date
    rst.update

rst.Close
Set rst = Nothing

MsgBox " Dateiname zugeordnet "

End Function
'
'
'Function f_Artikelbilder_Attach()
'
'Dim xstr As String
'Dim xstr1 As String
'Dim xstr2 As String
'
'Dim myArray
'Dim fn As String
'Dim i As Long
'Dim j As Long
'Dim k As Long
'
'Dim iID As Long
'Dim dtfdate As Date
'Dim Dlen As Long
'
'Dim artnr As String
'Dim dtnam As String
'
'Dim db As DAO.Database
'Dim rst As DAO.Recordset
'Dim FullPath As String, Drive As String, DirName As String, fname As String, Ext As String, Ext1 As String
'
'xstr2 = TLookup("Pfad", "_tblEigeneFirma_Pfade", "PfadArt = 'Artikelbilder'")
'If Right(xstr2, 1) = "\" Then
'    xstr = Left(xstr2, Len(xstr2) - 1)
'Else
'    xstr = xstr2
'End If
'xstr1 = "DIR /S /B " & Chr$(34) & xstr & Chr$(34) & " > " & Chr$(34) & xstr & "\x.xxx" & Chr$(34)
'Call LaunchApp32DOS(xstr1, True)
'
'CurrentDb.Execute ("DELETE * FROM tbl_Zusatzdateien WHERE TabellenID = 2")
'
'Set db = CurrentDb
'Set rst = db.OpenRecordset("SELECT TOP 1 * FROM tbl_Zusatzdateien")
'
'TextFileLesen xstr & "\x.xxx", myArray
'DoEvents
'For i = LBound(myArray) To UBound(myArray)
'    fn = myArray(i)
'' Beispiel fn = C:\Kunden\Kloy GmbH\Bilder\Artikel\01-001\Hugo.docx
'    If File_exist(fn) Then  ' File oder Directory existiert
'        If Not Dir_Exist(fn) Then ' Datei aber nicht Directory
'            j = InStrRev(fn, "\")
'            k = InStrRev(fn, "\", j - 1)
'            artnr = Mid(fn, k + 1, j - k - 1)
'            dtnam = Mid(fn, j + 1)
'            If dtnam <> "x.xxx" Then
''                Debug.Print fn
''                Debug.Print artnr, dtnam
'                j = InStr(1, artnr, "-")
'                If j > 0 Then
'                    artnr = Trim(Left(artnr, j - 1) & Nz(Mid(artnr, j + 1)))
''                    Debug.Print artnr
'                End If
'                iID = TLookup("a_int_ID", "tblStamm_Artikel", "a_strArtikelID = '" & artnr & "'")
'
'                If LCase(Left(Nz(fn), 4)) = "www." Then fn = "http://" & fn
'                If LCase(Left(Nz(fn), 4)) = "http" Then
'                    Ext1 = "HTM"
'                ElseIf LCase(Left(Nz(fn), 7)) = "mailto:" Then
'                    Ext1 = "MAIL"
'                Else
'                    Call FParsePath(fn, Drive, DirName, fname, Ext)
'                    Ext1 = UCase(Mid(Ext, 2))
'                End If
'                If IsNull(TLookup("[Typ]", "tbl_Texttyp", "[Typ] = '" & UCase(Ext1) & "'")) Then Ext1 = "SONST"
'
'                Dlen = FileLen(fn)
'                dtfdate = FileDateTime(fn)
'
'                rst.AddNew
'                    rst.Fields(1) = 2
'                    rst.Fields(2) = iID
'                    rst.Fields(3) = fn
'                    rst.Fields(4) = dtfdate
'                    rst.Fields(5) = Dlen
'                    rst.Fields(6) = Ext1
'                    rst.Fields(7) = ""
'                    rst.Fields(8) = ""
'                    rst.Fields(9) = 0
'                    rst.Fields(10) = atCNames(1)
'                    rst.Fields(11) = Date
'                    rst.Fields(12) = atCNames(1)
'                    rst.Fields(13) = Date
'                rst.Update
'
'            End If
'        End If
'    End If
'Next i
'rst.Close
'Set rst = Nothing
'Kill xstr & "\x.xxx"
'Set myArray = Nothing
'MsgBox "Ferdsch"
'
'
'End Function
'
'

Option Compare Database
Option Explicit

Function xxtst()
Call TSQL_TableDescription("C:\Access2\NeueTabellen_PLZ_BLZ_2013_03\TSQL_CreateTableDesc.sql", False)
End Function


Public Function ShowIndexNames()
    Dim tdf As TableDef
    Dim idx As Index
    Dim idf As field
    Dim num_indexes As Long

On Error GoTo ErrorHandler

    For Each tdf In CurrentDb.TableDefs
        num_indexes = tdf.Indexes.Count
        If Left$(tdf.Name, 4) <> "MSys" Then
            If num_indexes > 0 Then
                For Each idx In tdf.Indexes
                    Debug.Print CurrentDb.Name, tdf.Name, idx.Name, idx.Primary, idx.Foreign, idx.Unique
'                    For Each idf In idx.Fields
'                        Debug.Print , CurrentDb.Name, idx.Name, idf.Name
'                    Next idf
                Next idx
            End If
         End If
    Next tdf

ExitHere:
    Exit Function

ErrorHandler:
    Select Case Err.Number
    Case 3110
        'Could not read definitions; no read definitions '
        'permission for table or query '<Name>'. '
        Debug.Print "No read definitions permission for " _
            & tdf.Name
        num_indexes = 0
        Resume Next
    Case Else
        Debug.Print Err.Number & "-> " & Err.description
        GoTo ExitHere
    End Select
End Function

Public Function WriteIndexNames()
    Dim tdf As TableDef
    Dim idx As Index
    Dim idf
    Dim num_indexes As Long
    
    Dim db As DAO.Database
'    Dim rst As DAO.Recordset
    Dim rst1 As DAO.Recordset

On Error GoTo ErrorHandler

'    CurrentDb.Execute ("DELETE * FROM _tblTabIndex;")
    CurrentDb.Execute ("DELETE * FROM _tblTabIndexFeld;")
    DoEvents
    
    Set db = CurrentDb
'    Set rst = db.OpenRecordset("SELECT * FROM _tblTabIndex;")
    Set rst1 = db.OpenRecordset("SELECT * FROM _tblTabIndexFeld;")

    For Each tdf In CurrentDb.TableDefs
        num_indexes = tdf.Indexes.Count
        If Left$(tdf.Name, 4) <> "MSys" Then
            If num_indexes > 0 Then
                For Each idx In tdf.Indexes
'                    Debug.Print CurrentDb.Name, tdf.Name, idx.Name, idx.Primary
'                    rst.AddNew
'                        rst.Fields("Datenbankname") = CurrentDb.Name
'                        rst.Fields("Tabellenname") = tdf.Name
'                        rst.Fields("Indexname") = idx.Name
'                        rst.Fields("istPK") = idx.Primary
'                    rst.Update
                        
                    For Each idf In idx.fields
'                        Debug.Print , CurrentDb.Name, idx.Name, idf.Name
                    rst1.AddNew
                        rst1.fields("Datenbankname") = CurrentDb.Name
                        rst1.fields("Indexname") = idx.Name
                        rst1.fields("Tabellenname") = tdf.Name
                        rst1.fields("Feldname") = idf.Name
                        rst1.fields("istPK") = idx.Primary
                        rst1.fields("IndexIstUnique") = idx.Unique
                        rst1.fields("IndexIstReferentiell") = idx.Foreign
                    rst1.update
                    Next idf
                Next idx
            End If
         End If
    Next tdf

'    rst.Close
    rst1.Close
    
'    Set rst = Nothing
    Set rst1 = Nothing
    
ExitHere:
    Exit Function

ErrorHandler:
    Select Case Err.Number
    Case 3110
        'Could not read definitions; no read definitions '
        'permission for table or query '<Name>'. '
        Debug.Print "No read definitions permission for " _
            & tdf.Name
        num_indexes = 0
        Resume Next
    Case Else
        Debug.Print Err.Number & "-> " & Err.description
        GoTo ExitHere
    End Select
End Function


Function TableInfoTab(strTableName As String, Optional dbname As String = "")
   ' Alison Brown / geändert: KObd
   ' Purpose: Print in the immediate window the field names, types, and sizes for any table.
   ' Argument: name of a table in the current database.
   Dim db As DAO.Database
'   Dim tdf As TableDef
   Dim tdf As DAO.Recordset
   Dim i As Integer
   Dim fldnam As String, fldtyp As String, fldsiz As String, flddes As String
   Dim prp As Properties
   Set db = DBEngine(0)(0)
   On Error GoTo TableInfoTabErr
'   Set tdf = db.TableDefs(strTableName)
   Set tdf = db.OpenRecordset(strTableName, dbOpenDynaset, dbSeeChanges)
   Dim dbs As DAO.Database
   Dim rst As DAO.Recordset
                
'   If Not AccessEigenschaftEinstellen(tdf, "Description", dbText, False) Then
'       MsgBox "Adding Description Property to tables did not work"
'       Exit Function
'   End If
   Set dbs = CurrentDb
   Set rst = dbs.OpenRecordset("SELECT TOP 1 * FROM _tblTabFelder;", dbOpenDynaset, dbSeeChanges)
   
   On Error GoTo TableInfoTabErrPrint
'   Debug.Print strTableName
'   Debug.Print "FIELD NAME", , "FIELD TYPE", "SIZE", "DESCRIPTION"
'   Debug.Print "==========", , "==========", "====", "==========="
   For i = 0 To tdf.fields.Count - 1
   
     
     fldnam = tdf.fields(i).Name
     fldtyp = fieldType(tdf.fields(i).Type)
     fldsiz = tdf.fields(i).Size
        On Error Resume Next
     flddes = ""
     flddes = tdf.fields(i).Properties("Description")
        Err.clear
        On Error GoTo TableInfoTabErrPrint
          
'     Debug.Print fldnam, ,
'     Debug.Print fldtyp,
'     Debug.Print fldsiz,
'     Debug.Print flddes
          
      rst.AddNew
         rst.fields("Datenbankname").Value = dbname
         rst.fields("Tabellenname").Value = strTableName
         rst.fields("TabFeldname").Value = fldnam
         rst.fields("FldTypNr").Value = tdf.fields(i).Type
         rst.fields("FldTypDesc").Value = fldtyp
         rst.fields("FldLaenge").Value = fldsiz
         rst.fields("FldDesc").Value = flddes
      rst.update
      
'      Debug.Print tdf.Fields(I).Name,
'      Debug.Print FieldType(tdf.Fields(I).Type),
'      Debug.Print tdf.Fields(I).Size,
'      Debug.Print tdf.Fields(I).Properties("Description")
   
   Next
'   Debug.Print "==========", , "==========", "====", "==========";
'   Debug.Print
'   Debug.Print

   rst.Close
   Set rst = Nothing

TableInfoTabExit:
db.Close
   Exit Function

TableInfoTabErrPrint:
' Needed because a non existing Description within a field always causes an Error
' and just a "Resume Next" would print the following fieldname within the same line
      
 If Err = 3270 Then
      Debug.Print
      Resume Next
 Else
      Debug.Print "Unerwarteter Fehler : " & Err
      Resume Next
 End If

TableInfoTabErr:
Select Case Err
   Case 3265   ' Supplied table name invalid
       MsgBox strTableName & " table doesn't exist"
       Resume TableInfoTabExit
   Case Else
       Debug.Print "TableInfo() Error " & Err & ": " & Error
   End Select
   End Function
   
Function TableInfoTest(strTableName As String)
   ' Alison Brown / geändert: KObd
   ' Purpose: Print in the immediate window the field names, types, and sizes for any table.
   ' Argument: name of a table in the current database.
   Dim db As DAO.Database, tdf As DAO.Recordset, i As Integer, j As Long
   Dim fldnam As String, fldtyp As String, fldsiz As String, flddes As String, flddes2 As String
   Dim prp As Properties
   Set db = DBEngine(0)(0)
   On Error GoTo TableInfoErr
'   Set tdf = db.TableDefs(strTableName)
   Set tdf = db.OpenRecordset(strTableName, dbOpenDynaset, dbSeeChanges)
                
'   If Not AccessEigenschaftEinstellen(tdf, "Description", dbText, False) Then
'       MsgBox "Adding Description Property to tables did not work"
'       Exit Function
'   End If
   On Error GoTo TableInfoErrPrint
   Debug.Print strTableName
   Debug.Print "FIELD NAME" ', , "FIELD TYPE", "SIZE", "DESCRIPTION"
   Debug.Print "==========" ', , "==========", "====", "==========="
   For i = 0 To tdf.fields.Count - 1
   
     fldnam = tdf.fields(i).Name
     fldtyp = fieldType(tdf.fields(i).Type)
     fldsiz = tdf.fields(i).Size
        On Error Resume Next
     flddes = ""
   For j = 0 To tdf.fields(i).Properties.Count - 1
     flddes = ""
     flddes2 = ""
     flddes = tdf.fields(i).Properties(j).Name
     flddes2 = tdf.fields(i).Properties(j).Value
        Debug.Print , flddes, flddes2
     flddes2 = ""
     flddes = ""
    Next j
        Err.clear
        On Error GoTo TableInfoErrPrint
          
     Debug.Print i, fldnam
'     Debug.Print fldnam, tdf.Fields(i).Type
'     Debug.Print fldnam   ', ,
'     Debug.Print i & " - " & fldnam   ', ,
'     Debug.Print fldtyp,
'     Debug.Print fldsiz,
     Debug.Print flddes
          
'      Debug.Print tdf.Fields(I).Name,
'      Debug.Print FieldType(tdf.Fields(I).Type),
'      Debug.Print tdf.Fields(I).Size,
'      Debug.Print tdf.Fields(I).Properties("Description")
   
   Next
   Debug.Print "==========" ', , "==========", "====", "==========";
   Debug.Print
   Debug.Print

TableInfoExit:
db.Close
   Exit Function

TableInfoErrPrint:
' Needed because a non existing Description within a field always causes an Error
' and just a "Resume Next" would print the following fieldname within the same line
      
 If Err = 3270 Then
      Debug.Print
      Resume Next
 Else
      Debug.Print "Unerwarteter Fehler : " & Err
      Resume Next
 End If

TableInfoErr:
Select Case Err
   Case 3265   ' Supplied table name invalid
       MsgBox strTableName & " table doesn't exist"
       Resume TableInfoExit
   Case Else
       Debug.Print "TableInfo() Error " & Err & ": " & Error
   End Select
   End Function
      
   
Function TableInfo(strTableName As String)
   ' Alison Brown / geändert: KObd
   ' Purpose: Print in the immediate window the field names, types, and sizes for any table.
   ' Argument: name of a table in the current database.
   Dim db As DAO.Database, tdf As DAO.Recordset, i As Integer
   Dim fldnam As String, fldtyp As String, fldsiz As String, flddes As String
   Dim prp As Properties
   Set db = DBEngine(0)(0)
   On Error GoTo TableInfoErr
'   Set tdf = db.TableDefs(strTableName)
   Set tdf = db.OpenRecordset(strTableName, dbOpenDynaset, dbSeeChanges)
                
'   If Not AccessEigenschaftEinstellen(tdf, "Description", dbText, False) Then
'       MsgBox "Adding Description Property to tables did not work"
'       Exit Function
'   End If
   On Error GoTo TableInfoErrPrint
   Debug.Print strTableName
   Debug.Print "FIELD NAME" ', , "FIELD TYPE", "SIZE", "DESCRIPTION"
   Debug.Print "==========" ', , "==========", "====", "==========="
'   Debug.Print """ID""" & "; " & """Feldname""" & "; " & """Feldtyp"""
   For i = 0 To tdf.fields.Count - 1
   
     fldnam = tdf.fields(i).Name
     fldtyp = fieldType(tdf.fields(i).Type)
     fldsiz = tdf.fields(i).Size
        On Error Resume Next
     flddes = ""
'     flddes = tdf.Fields(I).Properties("Description")
        Err.clear
        On Error GoTo TableInfoErrPrint
          
'     Debug.Print i, fldnam
'     Debug.Print fldnam
'''               Als Textdatei ausgeben und dann Import als Tabelle
'     Debug.Print i + 1 & "; " & Chr$(34) & fldnam & Chr$(34) & "; " & tdf.Fields(i).Type
     Debug.Print i, fldnam, tdf.fields(i).Type, fieldType(tdf.fields(i).Type)
'     Debug.Print fldnam   ', ,
'     Debug.Print i & " - " & fldnam   ', ,
'     Debug.Print "$$" & strTableName & "." & fldnam & " = [" & strTableName & "1].[" & fldnam & "], $!$"
'     Debug.Print fldtyp,
'     Debug.Print fldsiz,
'     Debug.Print flddes
          
'      Debug.Print tdf.Fields(I).Name,
'      Debug.Print FieldType(tdf.Fields(I).Type),
'      Debug.Print tdf.Fields(I).Size,
'      Debug.Print tdf.Fields(I).Properties("Description")
   
   Next
   Debug.Print "==========" ', , "==========", "====", "==========";
   Debug.Print
   Debug.Print

TableInfoExit:
db.Close
   Exit Function

TableInfoErrPrint:
' Needed because a non existing Description within a field always causes an Error
' and just a "Resume Next" would print the following fieldname within the same line
      
 If Err = 3270 Then
      Debug.Print
      Resume Next
 Else
      Debug.Print "Unerwarteter Fehler : " & Err
      Resume Next
 End If

TableInfoErr:
Select Case Err
   Case 3265   ' Supplied table name invalid
       MsgBox strTableName & " table doesn't exist"
       Resume TableInfoExit
   Case Else
       Debug.Print "TableInfo() Error " & Err & ": " & Error
   End Select
   End Function
   
Function TableInfoConst(strTableName As String)
   ' Alison Brown / geändert: KObd
   ' Purpose: Print in the immediate window the field names, types, and sizes for any table.
   ' Argument: name of a table in the current database.
   Dim db As DAO.Database, tdf As DAO.Recordset, i As Integer
   Dim fldnam As String, fldtyp As String, fldsiz As String, flddes As String
   Dim prp As Properties
   Set db = DBEngine(0)(0)
   On Error GoTo TableInfoErr
'   Set tdf = db.TableDefs(strTableName)
   Set tdf = db.OpenRecordset(strTableName, dbOpenDynaset, dbSeeChanges)
                
'   If Not AccessEigenschaftEinstellen(tdf, "Description", dbText, False) Then
'       MsgBox "Adding Description Property to tables did not work"
'       Exit Function
'   End If
   On Error GoTo TableInfoErrPrint
   Debug.Print Chr$(39) & " " & strTableName
'   Debug.Print "FIELD NAME" ', , "FIELD TYPE", "SIZE", "DESCRIPTION"
'   Debug.Print "==========" ', , "==========", "====", "==========="
   For i = 0 To tdf.fields.Count - 1
   
     fldnam = tdf.fields(i).Name
     fldtyp = fieldType(tdf.fields(i).Type)
     fldsiz = tdf.fields(i).Size
        On Error Resume Next
     flddes = ""
'     flddes = tdf.Fields(I).Properties("Description")
        Err.clear
        On Error GoTo TableInfoErrPrint
          
     Debug.Print "Const fn_" & fldnam & " AS LONG = " & i
'     Debug.Print fldnam, tdf.Fields(i).Type
'     Debug.Print fldnam   ', ,
'     Debug.Print i & " - " & fldnam   ', ,
'     Debug.Print fldtyp,
'     Debug.Print fldsiz,
'     Debug.Print flddes
          
'      Debug.Print tdf.Fields(I).Name,
'      Debug.Print FieldType(tdf.Fields(I).Type),
'      Debug.Print tdf.Fields(I).Size,
'      Debug.Print tdf.Fields(I).Properties("Description")
   
   Next
   Debug.Print Chr$(39) & "---"
'   Debug.Print "==========" ', , "==========", "====", "==========";
   Debug.Print
   Debug.Print

TableInfoExit:
db.Close
   Exit Function

TableInfoErrPrint:
' Needed because a non existing Description within a field always causes an Error
' and just a "Resume Next" would print the following fieldname within the same line
      
 If Err = 3270 Then
      Debug.Print
      Resume Next
 Else
      Debug.Print "Unerwarteter Fehler : " & Err
      Resume Next
 End If

TableInfoErr:
Select Case Err
   Case 3265   ' Supplied table name invalid
       MsgBox strTableName & " table doesn't exist"
       Resume TableInfoExit
   Case Else
       Debug.Print "TableInfo() Error " & Err & ": " & Error
   End Select
   End Function
   
Function TableInfoMit(strTableName As String)
   ' Alison Brown / geändert: KObd
   ' Purpose: Print in the immediate window the field names, types, and sizes for any table.
   ' Argument: name of a table in the current database.
   Dim db As DAO.Database, tdf As DAO.Recordset, i As Integer
   Dim fldnam As String, fldtyp As String, fldsiz As String, flddes As String
   Dim prp As Properties
   Set db = DBEngine(0)(0)
   On Error GoTo TableInfoErr
'   Set tdf = db.TableDefs(strTableName)
   Set tdf = db.OpenRecordset(strTableName, dbOpenDynaset, dbSeeChanges)
                
'   If Not AccessEigenschaftEinstellen(tdf, "Description", dbText, False) Then
'       MsgBox "Adding Description Property to tables did not work"
'       Exit Function
'   End If
   On Error GoTo TableInfoErrPrint
   Debug.Print strTableName
   Debug.Print "ID", "FIELD NAME", "FIELD TYPE", "SIZE", "DESCRIPTION"
   Debug.Print "=========", "==========", "==========", "====", "==========="
   For i = 0 To tdf.fields.Count - 1
   
     fldnam = tdf.fields(i).Name
     fldtyp = fieldType(tdf.fields(i).Type)
     fldsiz = tdf.fields(i).Size
        On Error Resume Next
     flddes = ""
     flddes = tdf.fields(i).Properties("Description")
        Err.clear
        On Error GoTo TableInfoErrPrint
          
     Debug.Print i + 1,
     Debug.Print fldnam,
     Debug.Print fldtyp,
     Debug.Print fldsiz,
     Debug.Print flddes
          
'      Debug.Print tdf.Fields(i).Name,
'      Debug.Print FieldType(tdf.Fields(i).Type),
'      Debug.Print tdf.Fields(i).Size,
'      Debug.Print tdf.Fields(i).Properties("Description")
'
   Next
   Debug.Print "=========", "==========", "==========", "====", "==========="
   Debug.Print
   Debug.Print

TableInfoExit:
db.Close
   Exit Function

TableInfoErrPrint:
' Needed because a non existing Description within a field always causes an Error
' and just a "Resume Next" would print the following fieldname within the same line
      
 If Err = 3270 Then
      Debug.Print
      Resume Next
 Else
      Debug.Print "Unerwarteter Fehler : " & Err
      Resume Next
 End If

TableInfoErr:
Select Case Err
   Case 3265   ' Supplied table name invalid
       MsgBox strTableName & " table doesn't exist"
       Resume TableInfoExit
   Case Else
       Debug.Print "TableInfo() Error " & Err & ": " & Error
   End Select
   End Function
   
Function fieldType(n) As String
   ' Korrigierte Version
   ' Purpose: Converts the numeric results of DAO fieldtype to Text.
   Select Case n
   Case dbBoolean
        fieldType = "Yes/No"        '1
   Case dbByte
        fieldType = "Byte"          '2
   Case dbInteger
      fieldType = "Integer"         '3
   Case dbLong
      fieldType = "Long Integer"    '4
   Case dbCurrency
      fieldType = "Currency"        '5
   Case dbSingle
      fieldType = "Single"          '6
   Case dbDouble
      fieldType = "Double"          '7
    Case dbDate
      fieldType = "Date/Time"       '8
    Case dbText
      fieldType = "Text"            '10
    Case dbLongBinary
      fieldType = "OLE Object"      '11
    Case dbMemo
      fieldType = "Memo"            '12
    Case dbDecimal
      fieldType = "Decimal"         '20
    Case Else
      fieldType = "Unknown Type: " & n
   End Select
   
   End Function

Function AccessEigenschaftEinstellen(obj As Object, strName As String, _
        intTyp As Integer, varEinstellung As Variant) As Boolean
    Dim prp As Property
    Const conEigNichtGef As Integer = 3270

    On Error GoTo FehlerAccessEigenschaftEinstellen
    ' Explizit auf die Auflistung "Properties" verweisen.
    obj.Properties(strName) = varEinstellung
    obj.Properties.Refresh
    AccessEigenschaftEinstellen = True
            
BeendenAccessEigenschaftEinstellen:
    Exit Function

FehlerAccessEigenschaftEinstellen:
    If Err = conEigNichtGef Then
        ' Eigenschaft erstellen, Typ festlegen, Anfangswert einstellen.
        Set prp = obj.CreateProperty(strName, intTyp, varEinstellung)
        ' Eigenschaft-Objekt an die Auflistung "Properties" anfügen.
        obj.Properties.append prp
        obj.Properties.Refresh
        AccessEigenschaftEinstellen = True
        Resume BeendenAccessEigenschaftEinstellen
    Else
        MsgBox Err & ": " & vbCrLf & Err.description

AccessEigenschaftEinstellen = False
        Resume BeendenAccessEigenschaftEinstellen
    End If
End Function


'---------------------------------------------------------------------------------------
' Procedure : TSQL_TableDescription
' Author    : Klaus Oberdalhoff (kobd@gmx.de)
' Date      : 18.09.2013
' Purpose   : Erstellen einer T-SQL Datei, die einem die Beschreibung von Tabellenfeldern übernimmt.
'           : Script erzeugt zuerst ein sp_CreateExtendedProperty und anschliessend nochmal ein
'           : UpdateExtendedProperty um ggf vorhandene Beschreibungen zu überschreiben
'           :
'---------------------------------------------------------------------------------------
'
Function TSQL_TableDescription(sPath As String, Optional InclLinkTables As Boolean = True, Optional MitUpdate As Boolean = True)
Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim dbname As String
Dim handle As Integer

Dim strSQL As String

   On Error GoTo tstxx_Error

    CurrentDb.Execute ("DELETE * FROM _tblTabFelder")
    If InclLinkTables Then
        strSQL = "Select * From qryMDBTable2 WHERE Type = 1 Or Type = 6;"
    Else
        strSQL = "Select * From qryMDBTable2 WHERE Type = 1;"
    End If
    
    Set db = CurrentDb
    Set rst = db.OpenRecordset(strSQL)
    With rst
        Do While Not .EOF
            If !Type = 1 Then
                dbname = CurrentDb.Name
            Else
                dbname = !Database
            End If
            Call TableInfoTab(!objName, dbname)
            .MoveNext
        Loop
        .Close
    End With
    
    strSQL = "Select * From _tblTabFelder WHERE len(trim(Nz([fldDesc]))) > 0;"
    Set rst = db.OpenRecordset(strSQL)
             
    handle = FreeFile
    Open sPath For Output Access Write As #handle
    
    ' Tabellenname
    ' TabFeldname
    ' FldDesc
    
    Print #handle, "-- ============================================================================================================================"
    Print #handle, "-- == SQLScript (Autor: siegert@consec-nuernberg.de) zur Übernahme der Tabellenfeldbeschreibungen von MS Access - "
    Print #handle, "-- == " & CurrentDb.Name
    Print #handle, "-- == " & Now()
    Print #handle, "-- == Bitte die USE Datenbank anpassen "
    Print #handle, "-- ============================================================================================================================"
    Print #handle, "    "
    Print #handle, "USE  Yourdatase"
    Print #handle, "GO"
    Print #handle, "    "
    Print #handle, "-- ============================================================================================================================"
    
    With rst
        Do While Not .EOF
            Print #handle, "-- ------------------------------------------------------------------------------------"
            Print #handle, "-- Tabelle " & !Tabellenname & " -- Feld " & !TabFeldname
            Print #handle, "-- Beschr: " & !FldDesc
            Print #handle, "-- ------------------------------------------------------------------------------------"
            Print #handle, "EXEC sys.sp_addextendedproperty"
            Print #handle, "@name=N'MS_Description',"
            Print #handle, "@value=N'" & !FldDesc & "' ,"
            Print #handle, "@level0type=N'SCHEMA',"
            Print #handle, "@level0name=N'dbo',"
            Print #handle, "@level1type=N'TABLE',"
            Print #handle, "@level1name=N'" & !Tabellenname & "',"
            Print #handle, "@level2type=N'COLUMN',"
            Print #handle, "@level2name=N'" & !TabFeldname & "'"
            Print #handle, "GO"
            Print #handle, "-- ------------------------------------------------------------------------------------"
            Print #handle, " "
            .MoveNext
        Loop
        
        If MitUpdate Then
           
           .MoveFirst
            
            Print #handle, "-- ============================================================================================================================"
            Print #handle, "-- == Updatescript im Falle die ext. Property existiert    "
            Print #handle, "-- ----------------------------------------------------------------------------------------------------------------------------"
            Print #handle, "-- == SQLScript (Autor: ) zur Übernahme der Tabellenfeldbeschreibungen von MS Access - "
            Print #handle, "-- == " & CurrentDb.Name
            Print #handle, "-- == " & Now()
            Print #handle, "-- ============================================================================================================================"
        
            Do While Not .EOF
                Print #handle, "-- ------------------------------------------------------------------------------------"
                Print #handle, "-- Tabelle " & !Tabellenname & " -- Feld " & !TabFeldname
                Print #handle, "-- Beschr: " & !FldDesc
                Print #handle, "-- ------------------------------------------------------------------------------------"
                Print #handle, "EXEC sys.sp_updateextendedproperty"
                Print #handle, "@name=N'MS_Description',"
                Print #handle, "@value=N'" & !FldDesc & "' ,"
                Print #handle, "@level0type=N'SCHEMA',"
                Print #handle, "@level0name=N'dbo',"
                Print #handle, "@level1type=N'TABLE',"
                Print #handle, "@level1name=N'" & !Tabellenname & "',"
                Print #handle, "@level2type=N'COLUMN',"
                Print #handle, "@level2name=N'" & !TabFeldname & "'"
                Print #handle, "GO"
                Print #handle, "-- ------------------------------------------------------------------------------------"
                Print #handle, " "
                .MoveNext
            Loop
            
        End If
        
        .Close
    End With
    
    Close handle
    Set rst = Nothing

   On Error GoTo 0
   Exit Function

tstxx_Error:

    MsgBox "Error " & Err.Number & " (" & Err.description & ") in procedure TSQL_TableDescription of Modul mdlTstTabField"

End Function


'Function ListPK(tbl As String) As String
''List primary keys for passed table.
''Must reference ADOX library:
''Microsoft ADO Ext. 2.8 for DDL and Security.
'Dim cat As New ADOX.Catalog
'Dim tblADOX As New ADOX.Table
'Dim idxADOX As New ADOX.Index
'Dim colADOX As New ADOX.Column
'cat.ActiveConnection = CurrentProject.AccessConnection
'On Error GoTo errHandler
'For Each tblADOX In cat.Tables
'    If tblADOX.Name = tbl Then
'        If tblADOX.Indexes.Count <> 0 Then
'            For Each idxADOX In tblADOX.Indexes
'                With idxADOX
'                    If .PrimaryKey Then
'                        For Each colADOX In .Columns
'                            ListPK = colADOX.Name & ", " & ListPK
'                        Next
'                    End If
'                End With
'            Next
'        End If
'    End If
'Next
'If ListPK = "" Then
'    ListPK = "No primary key"
'Else
'    ListPK = Left(ListPK, Len(ListPK) - 2)
'End If
'Set cat = Nothing
'Set tblADOX = Nothing
'Set idxADOX = Nothing
'Set colADOX = Nothing
'
'Exit Function
'errHandler:  MsgBox Err.Number & ": " & Err.Description, vbOKOnly, _
'"Error"
'
'Set cat = Nothing
'Set tblADOX = Nothing
'Set idxADOX = Nothing
'Set colADOX = Nothing
'End Function
'
Option Compare Database
Option Explicit

' Funktionen (bzw.Subs) in diesem Modul:
'#######################################
'SysBeep                    Beep Beep Beep
'ArrFill_DAO_Acc            Erstellt ein Array aus einer Abfrage oder einer Tabelle oder einem SELECT String - nur Access
'ArrFill_DAO                Erstellt ein Array aus einer Abfrage oder einer Tabelle oder einem SELECT String - Excel oder Access - zusätzlich Feldnamen
'ArrFill_DAO_Redim          Vergrößert ein Array aus einer Abfrage oder einer Tabelle oder einem SELECT String
'ArrFill_Transform2d        Transformiert ein 2D Array von/nach 0 0 von/nach 1 1 Spalte / Zeile
'ArrTestFill                Test dazu
'Fill_Tbl                   Array in Tabelle schreiben
'CompactDB                  Compact
'ReSizeAllControls          Alle Controls resizen
'GetRefs                    Alle Referenzen
'SetAllowBypassKey          ByPass Key Allowance in fremder MDB setzen - DAO
'SetAllowByPassKeyADP       ByPass Key Allowance in fremder MDB setzen - ADP
'translateNATO              Wort in Nato-Alphabet übersetzen
'CreateQuery                Erzeugen einer Abfrage aus einem SQLString
'CreateQueryPathThru        Erzeugen einer Path-Trough Abfrage aus einem SQLString
'addXLSModule               Von Access aus in Excel ein Modul einfügen
'getUmrechnungskurs         Einen Umrechnungskurs von http://www.ecb.europa.eu/ holen
'getUmrechnungskursAlle     Alle Umrechnungskurse von http://www.ecb.europa.eu/ holen
'getUmrechnungskursCopy     Alle Umrechnungskurse kopieren
'A2XGetQryType              Ermittelt den Abfragetypen
'IsTableDataOpen            Ist Datentabelle offen
'GetA2XWorkgroupFile        Ermittelt den Pfad und den Namen der Workgroup-Datei
'A2XCompiled                Ist mdb Compiled ?
'A2XGetCtlType              Ermittelt den Type eines Controls
'chgbrightness              Ändert die Helligkeit der übergebenen Farbe
'minl                       Gibt den Kleineren von 2 Werten zurück
'maxl                       Gibt den Größeren von 2 Werten zurück
'Treeview_Stufe_neu_setzen  Treeview Hilfsfunktion: Errechnet automatisch die Stufentiefe aus der ID und der VaterID
'NamConv                    konvertiert einen String "NACHNAME, VORNAME" nach "Nachname" bzw "Vorname"
'ExcelTransferspreadsheet   Transferspreadsheet mit zusätzlichem ID-Autowert Feld beim Import
'ChgColLabelName_general    Changing label names to "lbl_" & Caption (useful for Datasheet forms)
'OpenPasswordProtectedDB    OpenPasswordProtectedDB
'ConvertLinkedTable2Intern  ConvertLinkedTable2Intern


'Heinz-Josef Bomanns, Redaktionsbuero
'> ich möchte die Tonwahltöne einer Telefonnummer über den Lautsprecher
'> ausgeben lassen. Tipps dazu ?

Declare PtrSafe Function SysBeep Lib "kernel32" Alias "Beep" _
                (ByVal dwFrequency As Long, _
                 ByVal dwDuration As Long) As Long

'Aufruf z.B. "SysBeep 800, 250"

'Die passenden Frequenzen und Längen musste Dir aber selbst rausfieseln

'   ***** Code Start *****
'Compact Current Database            Author Juan M. Afan de Ribera
 
'For Access 2000 and Access 2002. Here is a snippet of code for compacting the
'current database. It uses the accDoDefaultAction method, that performs the
'specified Object 's default action, and can be run from a command button on a form.
'
'accDoDefaultAction is a method of the hidden IAccessible Class in Office library.
'

Function ArrFill_DAO_Acc(ByVal recsetSQL As String, ByRef iZLMax As Long, ByRef iColMax As Long, ByRef DAOARRAY) As Boolean

Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim i As Long

'Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl as long, iCol as long
'recsetSQL1 = ""
'ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1,iZLMax1,iColMax1,DAOARRAY1)
''Info:   'AccessArray(iSpalte,iZeile) <0, 0>
'If ArrFill_DAO_OK1 Then
'    For iZl = 0 To iZLMax1
'
'
'
'    Next iZl
'    Set DAOARRAY1 = Nothing
'End If


ArrFill_DAO_Acc = False

    Set db = CurrentDb
    Set rst = db.OpenRecordset(recsetSQL, dbOpenSnapshot, dbSeeChanges)
    If rst.RecordCount <> 0 Then
        rst.MoveLast
        i = rst.RecordCount
        rst.MoveFirst
        DAOARRAY = rst.GetRows(i)

    'Achtung Zeile und Spalte 0-basiert
    'RowArray(iFldNr,iRecNr)
    'RowArray(iSpalte,iZeile)
        iZLMax = UBound(DAOARRAY, 2)
        iColMax = UBound(DAOARRAY, 1)
        ArrFill_DAO_Acc = True
    End If
    rst.Close
    Set rst = Nothing

End Function

'Neue Version

Function ArrFill_DAO(ByVal recsetSQL As String, ByRef iZLMax As Long, ByRef iColMax As Long, ByRef DAOARRAY, Optional ByRef DAOARRAY_Name, Optional AsExcel As Boolean = False) As Boolean
'Zusatztabelle mit Feldnamen (Zeile 0) und Feldtypen als Long (Zeile 1) und als Text (Zeile 2)
            
Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim i As Long
Dim j As Long

'Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, DAOARRAY_Name1, iZl as long, iCol as long
'recsetSQL1 = ""
'ArrFill_DAO_OK1 = ArrFill_DAO(recsetSQL1,iZLMax1,iColMax1,DAOARRAY1,DAOARRAY_Name1)
''Info:   'AccessArray(iSpalte,iZeile) <0, 0>       'ExcelArray(iZeile, iSpalte) <1, 1>
'If ArrFill_DAO_OK1 Then
'    For iZl = 0 To iZLMax1
'
'
'
'    Next iZl
'    Set DAOARRAY1 = Nothing
'End If
            
Dim NumArray
Dim NumtxtArray

Dim tmpArry
Dim iLbound As Long
Dim iCol As Long

NumArray = Array(dbBigInt, dbBinary, dbBoolean, dbByte, dbChar, dbCurrency, dbDate, dbDecimal, dbDouble, dbFloat, dbGUID, dbInteger, dbLong, dbLongBinary, dbMemo, dbNumeric, dbSingle, dbText, dbTime, dbTimeStamp, dbVarBinary)
NumtxtArray = Array("dbBigInt", "dbBinary", "dbBoolean", "dbByte", "dbChar", "dbCurrency", "dbDate", "dbDecimal", "dbDouble", "dbFloat", "dbGUID", "dbInteger", "dbLong", "dbLongBinary", "dbMemo", "dbNumeric", "dbSingle", "dbText", "dbTime", "dbTimeStamp", "dbVarBinary")
                       
ArrFill_DAO = False

    Set db = CurrentDb
    Set rst = db.OpenRecordset(recsetSQL, dbOpenSnapshot, dbSeeChanges)
    If rst.RecordCount <> 0 Then
        rst.MoveLast
        i = rst.RecordCount
        rst.MoveFirst
        
        If AsExcel = True Then
          tmpArry = rst.GetRows(i)
          iLbound = 1
          Call ArrFill_Transform2d(tmpArry, DAOARRAY, True, iZLMax, iColMax)
          Erase tmpArry
          Set tmpArry = Nothing
          ArrFill_DAO = True
        Else
          DAOARRAY = rst.GetRows(i)
          iLbound = 0
          iZLMax = UBound(DAOARRAY, 2)
          iColMax = UBound(DAOARRAY, 1)
          ArrFill_DAO = True
        End If

    'Function ArrFill_DAO(ByVal recsetSQL As String, ByRef iZLMax As Long, ByRef iColMax As Long, ByRef DAOARRAY) As Boolean
    
    'Achtung Zeile und Spalte 0-basiert
    'RowArray(iFldNr,iRecNr)
    'AccessArray(iSpalte,iZeile) <0, 0>
    'ExcelArray(iZeile, iSpalte) <1, 1>
    
     'Zusatztabelle mit Feldnamen (Zeile 0) und Feldtypen als Long (Zeile 1) und als Text (Zeile 2)
      If Not IsMissing(DAOARRAY_Name) Then
            
        If AsExcel = True Then
          'ExcelArray(iZeile, iSpalte) <1, 1>
          ReDim DAOARRAY_Name(iLbound To 2 + iLbound, iLbound To iColMax)
        
          For iCol = iLbound To iColMax
            DAOARRAY_Name(iLbound, iCol) = rst.fields(iCol - iLbound).Name
            DAOARRAY_Name(iLbound + 1, iCol) = rst.fields(iCol - iLbound).Type
            For j = 0 To UBound(NumArray)
              If NumArray(j) = rst.fields(iCol - iLbound).Type Then
                DAOARRAY_Name(iLbound + 2, iCol) = NumtxtArray(j)
                Exit For
              End If
            Next j
          Next iCol
        
        Else
          'AccessArray(iSpalte, iZeile) <0, 0>
          ReDim DAOARRAY_Name(iLbound To iColMax, iLbound To 2 + iLbound)
        
          For iCol = iLbound To iColMax
            DAOARRAY_Name(iCol, iLbound) = rst.fields(iCol).Name
            DAOARRAY_Name(iCol, iLbound + 1) = rst.fields(iCol).Type
            For j = 0 To UBound(NumArray)
              If NumArray(j) = rst.fields(iCol).Type Then
                DAOARRAY_Name(iCol, iLbound + 2) = NumtxtArray(j)
                Exit For
              End If
            Next j
          Next iCol
        
        End If
      End If
    
    End If
    rst.Close
    Set rst = Nothing

End Function



Function ArrFill_Transform2d(InArray, OutArray, bToExcel As Boolean, iZLMaxOut As Long, iColMaxOut As Long) As Boolean
'bToExcel = True -- von Access nach Excel
'bToExcel = False -- von Excel nach Access

'Access-Arrays:
    'Achtung Zeile und Spalte 0-basiert
    'AccessArray(iFldNr, iRecNr)
    'AccessArray(iSpalte, iZeile) <0, 0>

'Excel-Arrays:
    'Achtung Zeile und Spalte 1-basiert
    'ExcelArray(iRecNr, iFldNr)
    'ExcelArray(iZeile, iSpalte) <1, 1>


'Dim ArrFill_Transform2d_OK1 As Boolean, InArray1, OutArray1, iZLMaxOut1, iColMaxOut1, iZl as long, iCol as long
'ArrFill_Transform2d_OK1 = ArrFill_Transform2d(InArray1,OutArray1,True, iZLMaxOut1,iColMaxOut1)
''Info:   'AccessArray(iSpalte,iZeile) <0, 0>       'ExcelArray(iZeile, iSpalte) <1, 1>

Dim i As Long, ii As Long, j As Long
Dim IZlIn As Long
Dim IColIn As Long
Dim IZl2In As Long
Dim ICol2In As Long

On Error GoTo Fehl

ArrFill_Transform2d = True

If bToExcel = True Then
    ii = 1  ' Ziel Array Excel: 1 größer
Else
    ii = -1 ' Ziel Array Access: 1 kleiner
End If

If bToExcel = False Then ' Von Excel Nach Access
    'OutArray(iSpalte, iZeile)
    
    IColIn = LBound(InArray, 2)
    ICol2In = UBound(InArray, 2)
    IZlIn = LBound(InArray, 1)
    IZl2In = UBound(InArray, 1)
    
    ReDim OutArray(IColIn + ii To ICol2In + ii, IZlIn + ii To IZl2In + ii)

    For i = IZlIn To IZl2In
        For j = IColIn To ICol2In
            OutArray(j + ii, i + ii) = InArray(i, j)
        Next j
    Next i

Else ' Von Access Nach Excel
    'OutArray(iZeile, iSpalte)
    
    IColIn = LBound(InArray, 1)
    ICol2In = UBound(InArray, 1)
    IZlIn = LBound(InArray, 2)
    IZl2In = UBound(InArray, 2)
    
    ReDim OutArray(IZlIn + ii To IZl2In + ii, IColIn + ii To ICol2In + ii)

    For i = IZlIn To IZl2In
        For j = IColIn To ICol2In
            OutArray(i + ii, j + ii) = InArray(j, i)
        Next j
    Next i
End If

iZLMaxOut = IZl2In + ii
iColMaxOut = ICol2In + ii

Exit Function

Fehl:

ArrFill_Transform2d = False

MsgBox "Error - something went wrong"

End Function


Function Fill_Tbl(ByVal recsetSQL As String, ByRef DAOARRAY As Variant) As Boolean

'Dim Fill_Tbl_OK1 As Boolean, trecsetSQL1 As String, InArray1
'Fill_Tbl_OK1 = Fill_Tbl((recsetSQL1,InArray1)
''Info:   'AccessArray(iSpalte,iZeile) <0, 0>       'ExcelArray(iZeile, iSpalte) <1, 1>

Dim iZl As Long
Dim iCol As Long

Dim i As Long
Dim j As Long
Dim k As Long

    'AccessArray(iSpalte,iZeile) <0, 0>
    'ExcelArray(iZeile, iSpalte) <1, 1>

Dim db As DAO.Database
Dim rst As DAO.Recordset


 '  On Error GoTo Fill_Tbl_Error

k = LBound(DAOARRAY, 1)

If k = 0 Then 'Access
  iCol = UBound(DAOARRAY, 1)
  iZl = UBound(DAOARRAY, 2)
Else  'Excel
  iCol = UBound(DAOARRAY, 2)
  iZl = UBound(DAOARRAY, 1)
End If

Set db = CurrentDb
    Set rst = db.OpenRecordset(recsetSQL, , dbSeeChanges)

With rst
    For i = k To iZl
        .AddNew
            For j = k To iCol
              On Error Resume Next
              If k = 0 Then
                .fields(j) = Nz(DAOARRAY(j, i))
              Else
                .fields(j - k) = Nz(DAOARRAY(i, j))
              End If
              On Error GoTo 0
            Next j
On Error Resume Next
        .update
On Error GoTo 0
    Next i
    .Close
End With

Set rst = Nothing

   On Error GoTo 0
   
   Fill_Tbl = True
   Exit Function

Fill_Tbl_Error:

Fill_Tbl = False
  MsgBox "Error " & Err.Number & " (" & Err.description & ") in procedure Fill_Tbl of Module mdlSonstiges4"

End Function


Function ArrFill_DAO_Redim(ByVal recSetVgl As String, ByRef iZLMax As Long, ByRef iColMax As Long, ByRef DAOARRAY)
'iZLMax = Input: Anzahl der Erhöhung der Zeilen, Rückgabe MaxZeilen gesamt, iColMax = Input Max anz Spalten neu

Dim TmpArr
Dim iZl1 As Long
Dim iCol1 As Long
Dim k As Long
Dim l As Long

    Call ArrFill_DAO(recSetVgl, iZl1, iCol1, TmpArr)

    ReDim Preserve DAOARRAY(iColMax, iZLMax + iZl1 + 1)
    For k = 0 To iZl1
        For l = 0 To iCol1
            DAOARRAY(l, iZLMax + 1 + k) = TmpArr(l, k)
        Next l
    Next k
    
    iZLMax = iZLMax + iZl1 + 1
    
    Set TmpArr = Nothing
            
End Function

Function ArrTestFill()
Dim i As Long
Dim j As Long
Dim AsExcel As Boolean

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, DAOARRAY_Name1, iZl As Long, iCol As Long
'ArrFill_DAO_OK1 = ArrFill_DAO(recsetSQL1,iZLMax1,iColMax1,DAOARRAY1,DAOARRAY_Name1, False)
''Info: DAOARRAY1(iSpalte,iZeile)  <0, 0>

Dim sqlstr1 As String

recsetSQL1 = "SELECT * FROM tblSpeisenAusgaben;"

AsExcel = True
ArrFill_DAO_OK1 = ArrFill_DAO(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1, DAOARRAY_Name1, AsExcel)

If Not AsExcel Then
    'AccessArray(iSpalte, iZeile) <0, 0>
  Debug.Print "AusgDatum = " & DAOARRAY1(3, 0)
  Debug.Print "Bier = " & DAOARRAY_Name1(3, 0)
  Debug.Print "Bier = " & DAOARRAY_Name1(3, 1)
  Debug.Print "Bier = " & DAOARRAY_Name1(3, 2)
Else
      'ExcelArray(iZeile, iSpalte) <1, 1>
  Debug.Print "AusgDatum = " & DAOARRAY1(1, 4)
  Debug.Print "Bier = " & DAOARRAY_Name1(1, 4)
  Debug.Print "Bier = " & DAOARRAY_Name1(2, 4)
  Debug.Print "Bier = " & DAOARRAY_Name1(3, 4)
End If

Dim Fill_Tbl_OK1 As Boolean, trecsetSQL1 As String, iFirstCol As Long, InArray1

CurrentDb.Execute ("DELETE * FROM tblSpeisenAusgaben_Test;")

trecsetSQL1 = "SELECT * FROM tblSpeisenAusgaben_Test;"
iFirstCol = 1

Fill_Tbl_OK1 = Fill_Tbl(trecsetSQL1, DAOARRAY1)
''Info:   'AccessArray(iSpalte,iZeile) <0, 0>       'ExcelArray(iZeile, iSpalte) <1, 1>


'Stop
End Function



Public Sub CompactDB()

   CommandBars("Menu Bar"). _
   Controls("Tools"). _
   Controls("Database utilities"). _
   Controls("Compact and repair database..."). _
   accDoDefaultAction

End Sub
'   ***** Code End  *****


Function vbnl() As String
vbnl = vbNewLine
End Function


Function ReSizeAllControls(strFormName As String, Optional dblresize As Double = 1, Optional strFontName As String = "Arial", Optional iFontsize As Long = 10)

'Konstante Steuerelement
'#######################
'acBoundObjectFrame Gebundenes Objektfeld
'acCheckBox Kontrollkästchen
'acComboBox Kombinationsfeld *
'acListBox Listenfeld *
'acCommandButton Befehlsschaltfläche *
'acCustomControl ActiveX - Steuerelement
'acImage Bild
'acLabel Bezeichnungsfeld *
'acLine Linie
'acObjectFrame ungebundenes Objektfeld oder Diagramm
'acOptionButton Optionsschaltfläche
'acOptionGroup Optionsgruppe
'acPage Page
'acPageBreak Seitenwechsel
'acRectangle Rechteck
'acSubform Unterformular / -bericht
'acTabCtl Registersteuerelement *
'acTextBox Textfeld *
'acToggleButton Umschaltfläche *

'If C.ControlType = acComboBox Or _
'   C.ControlType = acListBox Or _
'   C.ControlType = acCommandButton Or _
'   C.ControlType = acLabel Or _
'   C.ControlType = acTextBox Or _
'   C.ControlType = acTabCtl Or _
'   C.ControlType = acToggleButton _
'     Then

Dim i As Integer, Anz As Integer
Dim bOne As Boolean
Dim c As control

bOne = False

DoCmd.OpenForm strFormName, acDesign
Anz = forms(strFormName).Controls.Count ' liefert die Anzahl Steuerelemente im Formular
If Anz <= 0 Then Exit Function ' keine Steuerelemente da
For i = 0 To Anz - 1
    Set c = forms(strFormName).Controls(i)
'    Debug.Print C.ControlType, C.Name
    
    If c.ControlType = acComboBox Or _
       c.ControlType = acListBox Or _
       c.ControlType = acCommandButton Or _
       c.ControlType = acLabel Or _
       c.ControlType = acTextBox Or _
       c.ControlType = acTabCtl Or _
       c.ControlType = acToggleButton _
         Then
    
        c.FontName = strFontName
        c.FontSize = iFontsize
    
'         C.Value = "" ' Inhalt löschen
    End If
Next i
    
' Ein Register muss zuerst gesetzt werden
For i = 0 To Anz - 1
    Set c = forms(strFormName).Controls(i)
    If c.ControlType = 123 Then ' Register
        c.Top = c.Top * dblresize
        c.Left = c.Left * dblresize
        c.height = c.height * dblresize
        c.width = c.width * dblresize
    End If
Next i
    
For i = 0 To Anz - 1
    Set c = forms(strFormName).Controls(i)
    
    If Not (c.ControlType = 124 Or c.ControlType = 123) Then  ' TabRegisterKarte (124) eines Registers (123)
            
        c.Top = c.Top * dblresize
        c.Left = c.Left * dblresize
        c.height = c.height * dblresize
        c.width = c.width * dblresize
    End If
                
Next i

DoCmd.Close acForm, strFormName, acSaveYes

DoCmd.OpenForm strFormName

End Function

Public Function GetRefs()
 '====================================================================
 ' Name: GetRefs
 ' Purpose: Get a list of the current database references
 '
 ' Author:  Arvin Meyer
 ' Date: April 10, 1999
 ' Comment:
 '
 '====================================================================
On Error GoTo Err_GetRefs
Dim i As Integer

For i = 1 To Application.References.Count

    Debug.Print Application.References(i).fullPath

Next i

Exit_GetRefs:
   Exit Function

Err_GetRefs:

   Debug.Print "Missing Reference"
   Resume Next

End Function

Function RefOtherDB(strDatabase As String)

    Dim db As DAO.Database
    Dim ws As Workspace
    
    Dim appAccess As Object
    Set appAccess = CreateObject("Access.Application")


    On Error GoTo HandleErr
    Set ws = appAccess.DBEngine.Workspaces(0)
    Set db = ws.OpenDatabase(strDatabase)
    
'    Set db = DBEngine.Workspaces(0).OpenDatabase(Me.txtDBPfad)
    
Dim i As Integer

Debug.Print appAccess.References.Count

For i = 1 To appAccess.References.Count

    Debug.Print appAccess.References(i).fullPath

Next i


ExitHere:
    Exit Function

HandleErr:
    GoTo ExitHere

End Function

Function SetAllowBypassKey(strDatabase As String, _
 fSet As Boolean) As Boolean
    ' Returns True if the property is set,
    ' False on any error
    ' Author: Mary Chipman

    Dim db As DAO.Database
    Dim ws As Workspace
    Dim Prop As Property
    Const conPropNotFound = 3270


    On Error GoTo HandleErr
    Set ws = DBEngine.Workspaces(0)
    Set db = ws.OpenDatabase(strDatabase)
    db.Properties("AllowByPassKey") = fSet
    SetAllowBypassKey = True


ExitHere:
    Exit Function


HandleErr:
    If Err = conPropNotFound Then
        ' If the property doesn't already exist,
        ' you have to create it
        Set Prop = db.CreateProperty("AllowByPassKey", _
          dbBoolean, False)
        db.Properties.append Prop
        Resume
    Else
        MsgBox Err & ": " & Err.description, , "Error in SetAllowBypassKey."
        SetAllowBypassKey = False
        GoTo ExitHere
    End If
End Function

Function SetAllowByPassKeyADP(Optional onoff As Boolean = False)
    Dim prp As AccessObjectProperty
    Const AllowByPassKey As String = "AllowByPassKey"

    On Error Resume Next
    Set prp = CurrentProject.Properties(AllowByPassKey)
    If Err.Number = 2455 Then
         CurrentProject.Properties.Add AllowByPassKey, onoff
    Else
        prp.Value = onoff
    End If
    SetAllowByPassKeyADP = onoff
End Function


Function translateNATO(strMsg As String)
Dim strWords()
Dim strOut As String
Dim i As Long
    'strMsg = InputBox("Enter text:")
    
    strWords = Array("Alpha", "Bravo", "Charlie", "Delta", _
                    "Echo", "Foxtrot", "Golf", "Hotel", _
                    "India", "Juliet", "Kilo", "Lima", _
                    "Mike", "November", "Oscar", "Papa", _
                    "Quebec", "Romeo", "Sierra", "Tango", _
                    "Uniform", "Victor", "Whiskey", "Xray", _
                    "Yankee", "Zulu")
                
    If strMsg <> "" Then
        For i = 1 To Len(strMsg)
            If (Asc(LCase(Mid(strMsg, i, 1))) >= 97) And (Asc(LCase(Mid(strMsg, i, 1))) <= 122) Then
                    strOut = strOut & "-" & strWords(Asc(LCase(Mid(strMsg, i, 1))) - 97)
            Else
                If IsNumeric(Mid(strMsg, i, 1)) Then
                    strOut = strOut & "-" & Mid(strMsg, i, 1)
                Else
                    strOut = strOut & "-"
                End If
            End If
        Next
        MsgBox (strMsg & vbNewLine & "---------------" & vbNewLine & Mid(strOut, 2))
    End If
    translateNATO = Mid(strOut, 2)
End Function


Function CreateQuery(strSQL As String, Optional queryName As String = "qrySorting") As Boolean

Dim dbs As DAO.Database
Dim qdf As DAO.QueryDef

   On Error GoTo CreateQuery_Error

Set dbs = CurrentDb
If ObjectExists("Query", queryName) Then
    DoCmd.DeleteObject acQuery, queryName
End If
Set qdf = dbs.CreateQueryDef(queryName, strSQL)

DoEvents

   CreateQuery = True
   On Error GoTo 0
   Exit Function

CreateQuery_Error:

'    MsgBox "Error " & Err.Number & " (" & Err.Description & ") in procedure CreateQuery of Modul DataFunctions"
CreateQuery = False

End Function

Function CreateQueryPathThru(strConnServer As String, strConnDB As String, strConnTyp As String, strSQL As String, strAbfragename As String, Optional ReturnsRecords As Boolean = True, Optional IsExecute As Boolean = False) As Boolean

'strConnServer = "N2319021"                    ' Servername
'strConnServer = "123.123.123.123,1234"        ' IP und Port

'strConnDB = "Prj_Bio_Dim"                     ' Datenbankname

'strConnTyp = "Trusted_Connection=Yes"         ' integrated Windows Security
'strConnTyp = "Uid=myUsername;Pwd=myPasword"   ' SQL Server User und Password

    Dim db As DAO.Database
    Dim qdfAbfrage As DAO.QueryDef

    CreateQueryPathThru = False

    On Error GoTo CreateQueryPathThru_Error


   ' Eine Datenbank öffnen, aus der QueryDef-Objekte erstellt werden können.
   ' Set db = OpenDatabase("DB1.mdb")

   Set db = CurrentDb

'Exitstierende Abfrage löschen
If ObjectExists("Query", strAbfragename) Then
    DoCmd.DeleteObject acQuery, strAbfragename
End If

   ' Ein nicht temporäres QueryDef-Objekt erstellen, um
   ' Daten von einer Microsoft SQL Server-Datenbank abzurufen.
Set qdfAbfrage = db.CreateQueryDef(strAbfragename)
With qdfAbfrage

'ODBC;DRIVER={SQL Server};SERVER=N2319021;DATABASE=Prj_Bio_Data;Trusted_Connection=Yes;
'ODBC;DRIVER={SQL Server};SERVER=N2319021;DATABASE=Prj_Bio_Data;Uid=myUsername;Pwd=myPasword;

      .Connect = "ODBC;DRIVER={SQL Server};SERVER=" & strConnServer & ";DATABASE=" & strConnDB & ";" & strConnTyp & ";"
      .ReturnsRecords = ReturnsRecords


'strSQL = "SELECT * FROM Test;"

       .sql = strSQL
       
       If IsExecute Then
           .Execute
       End If

       .Close
End With
DoEvents
CreateQueryPathThru = True
Exit Function

CreateQueryPathThru_Error:

CreateQueryPathThru = False
MsgBox "Fehler #" & CStr(Err.Number) & " von """ & Err.Source & """: " & Err.description
Err.clear

End Function


Function CreateQueryPathThruConnStr(strConnString As String, strSQL As String, strAbfragename As String, Optional ReturnsRecords As Boolean = True, Optional IsExecute As Boolean = False) As Boolean

    Dim db As DAO.Database
    Dim qdfAbfrage As DAO.QueryDef

    CreateQueryPathThruConnStr = False

    On Error GoTo CreateQueryPathThru_Error


   ' Eine Datenbank öffnen, aus der QueryDef-Objekte erstellt werden können.
   ' Set db = OpenDatabase("DB1.mdb")

   Set db = CurrentDb

'Exitstierende Abfrage löschen
If ObjectExists("Query", strAbfragename) Then
    DoCmd.DeleteObject acQuery, strAbfragename
End If

   ' Ein nicht temporäres QueryDef-Objekt erstellen, um
   ' Daten von einer Microsoft SQL Server-Datenbank abzurufen.
Set qdfAbfrage = db.CreateQueryDef(strAbfragename)
With qdfAbfrage

      .Connect = strConnString
      .ReturnsRecords = ReturnsRecords
      
'strSQL = "SELECT * FROM Test;"

       .sql = strSQL
       If IsExecute Then
           .Execute
       End If
       .Close
End With
DoEvents


CreateQueryPathThruConnStr = True
Exit Function

CreateQueryPathThru_Error:

CreateQueryPathThruConnStr = False
MsgBox "CreateQueryPathThruConnStr - Fehler #" & CStr(Err.Number) & " von """ & Err.Source & """: " & Err.description
Err.clear

End Function


''##############################################################
'' Von Access aus in Excel ein Modul einfügen ...
'' Henry Habermacher
'
''wenn 's ein bisschen hidden Functions sein dürfen geht's in etwa
''folgendermassen:
'
'Public Function addXLSModule()
'  Dim appXLS As New Excel.Application
'  Dim wbk As Excel.Workbook
'  Dim mdl As Excel.Module
'  Set wbk = appXLS.Workbooks.Add
'  appXLS.Visible = True
'  wbk.Modules.Add
'  wbk.Modules(1).Name = "MyModule"
'  Set mdl = wbk.Sheets("MyModule")
'  mdl.InsertFile "c:\test.bas"
'  Stop
'End Function

'Das Modul, das Du einfügen willst, legst Du als c:\test.bas ab und wenn Du
'dann diese Funktion laufen lässt hat das Workbook ein Modul namens MyModule
'mit dem Inhalt von c:\test.bas. Option Explicit wird automatisch eingefügt
'wenn so eingestellt, muss also nicht im test.bas drin stehen.
'##############################################################


'> Ich brauche eine Aggregatfunktion die Felder
'> aus verschiedenen Datensätzen in einer Tabelle multipliziert.
'>
'> Also anstelle von
'> SELECT SUM(Feld1) Group By AndresFeld FROM Tabelle
'>
'> Möchte Ich gerne
'> SELECT Multiply(?)(Feld1) Group By AndresFeld FROM Tabelle
'>
'> Geht so etwas, und wenn ja wie?
'
'Ja, wenn man sich die Tatsache zu Nutze macht,
'dass x*y = e^(ln x + ln y).
'Also:
'SELECT Exp(Sum(Log([EineZahl]))) AS Produkt
'FROM tblZahlen;




'Anwendungszweck
'Normalerweise bindet man die Daten in Unterberichten an die des Hauptberichts, sodass der Unterbericht
'beispielsweise die Projekte zu einem Kunden anzeigt. Manchmal geht dies allerdings nicht, weil die Daten
'von Haupt- und Unterbericht nicht entsprechend verknüpft sind.
'
'Abfrage vorbereiten
'Als Abfrage kann man eine x-beliebige Abfrage verwenden - hauptsache, sie ist unter dem gewünschten
'Namen gespeichert und wird nicht für irgendeinen anderen Zweck benötigt. Stellen Sie dann die
'Eigenschaft Datenherkunft des Unterberichts auf diese Abfrage ein.
'
'Datenherkunft Anpassen
'Das Anpassen der Datenherkunft des Unterformulars findet dann in der Beim Öffnen-Ereignisprozedur
'des Hauptberichts statt. Dort heißt es dann beispielsweise:
'
'Private Sub Report_Open(Cancel As Integer)
'
'    Dim db As DAO.Database
'
'    Dim strSQL As String
'
'    Set db = CurrentDb
'
'    strSQL = "SELECT * FROM Artikel WHERE Artikelname LIKE 'C*'"
'
'    db.QueryDefs("qryArtikelDummy").sql = strSQL
'
'End Sub
'
'Am Unterberichts selbst ändert diese Routine gar nichts, sondern nur an der zugrunde
'liegenden Abfrage: Der weist sie den neuen SQL-Ausdruck zu. Nach dem Öffnen zeigt der
'Unterbericht schließlich die gewünschten Datensätze an.
'
'


Public Function c()
 '====================================================================
 ' Name:    GetRefs
 ' Purpose: Get a list of the current database references
 '
 ' Author:  Arvin Meyer
 ' Date:    April 10, 1999
 ' Comment:
 '
 '====================================================================
On Error GoTo Err_GetRefs
Dim i As Integer

For i = 1 To Application.References.Count

    Debug.Print Application.References(i).fullPath

Next i

Exit_GetRefs:
    Exit Function

Err_GetRefs:

    Debug.Print "Missing Reference"
    Resume Next

End Function



Public Function A2XGetQryType(psQry As String, Optional pdbs As DAO.Database) As String
  '// =====================================================
  '// Methode   | Ermittelt den Abfragetypen
  '// -----------------------------------------------------
  '// Parameter | psQry - Name der Abfrage
  '//             Optional  pdbs -Datenbankobjekt (CurrentDb)
  '// -----------------------------------------------------
  '// Rückgabe  | String - Bezeichnung des Abfragetyps
  '// -----------------------------------------------------
  '// Erstellt  | Manuela Kulpa
  '//           | EDV Innovation & Consulting - Dormagen
  '// -----------------------------------------------------
  '// Beispielaufruf:
  '// ?A2XGetQryType(CurrentDb,"qryTest")
  '// =====================================================
 
  Dim qdf As DAO.QueryDef
  Dim sType As String
 
  On Error GoTo A2XGetQryType_Error
 
  If IsMissing(pdbs) Or (pdbs Is Nothing) Then
    Set pdbs = CurrentDb
  End If
 
  Set qdf = pdbs.QueryDefs(psQry)
 
  Select Case qdf.Type
    Case dbQSelect: sType = "Auswahlabfrage"
    Case dbQAction: sType = "Aktionsabfrage"
    Case dbQCrosstab: sType = "Kreuztabellenabfrage"
    Case dbQDelete: sType = "Löschabfrage"
    Case dbQUpdate: sType = "Aktualisierungsabfrage"
    Case dbQAppend: sType = "Anfügeabfrage"
    Case dbQMakeTable: sType = "Tabellenerstellungsabfrage"
    Case dbQDDL: sType = "Datendefinitionsabfrage"
    Case dbQSQLPassThrough: sType = "Pass-through-Abfrage"
    Case dbQSetOperation: sType = "Unionabfrage"
  End Select
 
  A2XGetQryType = sType
 
A2XGetQryType_Exit:
  On Error GoTo 0
  Exit Function
 
A2XGetQryType_Error:
  Select Case Err.Number
    Case Else
      MsgBox "Fehler " & Err.Number & ": " & _
             Err.description, vbCritical, _
             "modData.A2XGetQryType"
  End Select
  Resume A2XGetQryType_Exit
 
End Function


' Sind Tabellen-Daten in Verwendung?
Public Function IsTableDataOpen(psTable As String) As Boolean
  '// -----------------------------------------------------
  '// Methode   | Überprüft, ob eine Tabelle bereits
  '               irgendwo in Verwendung ist
  '// -----------------------------------------------------
  '// Parameter | psTable - Name der Tabelle, die überprüft
  '                         werden soll
  '// -----------------------------------------------------
  '// Rückgabe  | Boolean - True = Tabelle wird verwendet
  '// -----------------------------------------------------
  '// Erstellt  | Manuela Kulpa
  '//           | EDV Innovation & Consulting - Dormagen
  '// -----------------------------------------------------
  '// Beispielaufruf:
  '   Public Sub TestFormularData()
  '    If IsTableDataOpen("Personal") = True Then
  '      MsgBox "Das Formular kann nicht geöffnet werden!", _
  '      vbInformation, "Hinweis"
  '    Else
  '      DoCmd.OpenForm "frmPersonal"
  '    End If
  '   End Sub
  '// -----------------------------------------------------
 
  Dim rst As DAO.Recordset
 
  On Error Resume Next
  '* Über die Option dbDenyWrite wird verhindert,
  '  dass andere Benutzer Datensätze ändern oder
  '  hinzufügen können
  '* Die Option dbDenyRead verhindert, dass andere
  '  Benutzer Daten in Tabellen lesen können
  Set rst = CurrentDb.OpenRecordset(psTable, dbOpenDynaset, dbDenyWrite + dbDenyRead)
  IsTableDataOpen = (Err.Number <> 0)
 
IsTableDataOpen_Exit:
  On Error GoTo 0
  If Not rst Is Nothing Then rst.Close: Set rst = Nothing
  Exit Function
 
End Function


Public Function GetA2XWorkgroupFile() As String
  '// =====================================================
  '// Methode   | Ermittelt den Pfad und den Namen der
  '//           | Sicherheitsinformationsdatei
  '// -----------------------------------------------------
  '// Rückgabe  | String - s.o.
  '// -----------------------------------------------------
  '// Erstellt  | Manuela Kulpa
  '//           | EDV Innovation & Consulting - Dormagen
  '// =====================================================
 
  GetA2XWorkgroupFile = Application.SysCmd( _
                            acSysCmdGetWorkgroupFile)
 
End Function

Public Sub A2XCompiled()
  '// =====================================================
  '// Methode   | Kompiliert das aktuelle Visual Basic
  '//           | Projekt
  '// -----------------------------------------------------
  '// Hinweis   | undokumentierte SysCmd-Methode
  '// -----------------------------------------------------
  '// Erstellt  | Manuela Kulpa
  '//           | EDV Innovation & Consulting - Dormagen
  '// =====================================================
 
  Call SysCmd(504, 16483)
 
End Sub


Public Function A2XGetCtlType(pctl As control) As String
 
  '// =====================================================
  '// Methode   | Ermittelt den Type eines Controls
  '// -----------------------------------------------------
  '// Parameter | pctl - Control
  '// -----------------------------------------------------
  '// Rückgabe  | String - Controltyp
  '// -----------------------------------------------------
  '// Erstellt  | Manuela Kulpa
  '//           | EDV Innovation & Consulting - Dormagen
  '// -----------------------------------------------------
  '// Beispielaufruf:
  '// ?A2XGetCtlType(Me!txtData)
  '// =====================================================
  Dim sType As String
 
  On Error GoTo A2XGetCtlType_Error
 
  Select Case pctl.ControlType
    Case acLabel
      sType = "Bezeichnungsfeld"
    Case acRectangle
      sType = "Rechteck"
    Case acLine
      sType = "Linie"
    Case acImage
      sType = "Bild"
    Case acCommandButton
      sType = "Befehlsschaltfläche"
    Case acOptionButton
      sType = "Optionsfeld"
    Case acCheckBox
      sType = "Kontrollkästchen"
    Case acOptionGroup
      sType = "Optionsgruppe"
    Case acBoundObjectFrame
      sType = "Gebundenes Objektfeld"
    Case acTextBox
      sType = "Textfeld"
    Case acListBox
      sType = "Listenfeld"
    Case acComboBox
      sType = "Kombinationsfeld"
    Case acSubform
      sType = "Unterformular / -bericht"
    Case acObjectFrame
      sType = "Objektfeld oder Diagramm"
    Case acPageBreak
      sType = "Seitenumbruch"
    Case 124
      sType = "Seite"
    Case 123
      sType = "Register"
    Case acCustomControl
      sType = "ActiveX-Control"
    Case acToggleButton
      sType = "Umschaltfläche"
  End Select
 
  A2XGetCtlType = sType
 
A2XGetCtlType_Exit:
  On Error GoTo 0
  Exit Function
 
A2XGetCtlType_Error:
  Select Case Err.Number
    Case Else
      MsgBox "Fehler " & Err.Number & ": " & _
             Err.description, vbCritical, _
             "modFrm.A2XGetCtlType"
  End Select
  Resume A2XGetCtlType_Exit
 
End Function



Public Function chgbrightness(ByVal ccolor As Long, ByVal hell As Long) As Long
'Ändert die Helligkeit der übergebenen Farbe, wobei der Farbton erhalten bleibt
'Es wird also nie schwarz(RGB(000) bzw weiß RGB(255,255,255) erreicht
'sondern stattdessen die ürsprüngliche Farbe zurückgeliefert

Dim c As Long

Dim red As Long
Dim green As Long
Dim blue As Long

'Farbe in rgb aufteilen
red = ccolor And 255
green = ccolor \ 256 And 255
blue = ccolor \ 256 ^ 2 And 255

'Bereich 0-255 sicherstellen
If hell > 0 Then 'Heller machen aber nur bis eine Farbe 255 ist
    c = maxl(red, maxl(green, blue))
    hell = minl(hell, 255 - c)
ElseIf hell < 0 Then ' Dunkler macher aber nur bis eine Farbe 0 ist
    c = minl(red, minl(green, blue))
    hell = maxl(hell, -c)
End If

If hell = 0 Then 'Nix ändern
    chgbrightness = ccolor
Else
   'Helligkeit einzeln anpassen
    red = red + hell
    green = green + hell
    blue = blue + hell

    'RGB in Farbwert zurückverwandeln
    chgbrightness = RGB(red, green, blue)
End If
End Function

Function minl(ByVal x As Long, ByVal y As Long) As Long
10 If x < y Then
20     minl = x
30 Else
40     minl = y
50 End If
End Function

Function maxl(ByVal x As Long, ByVal y As Long) As Long
10 If x > y Then
20     maxl = x
30 Else
40     maxl = y
50 End If
End Function


Function Treeview_Stufe_neu_setzen(Optional ByVal tabname As String = "tblTreeView", Optional ByVal ndxStufe As Long = 3, Optional ByVal ndxID = 0, Optional ByVal ndxVater = 10)

Dim i As Long
Dim j As Long
Dim k As Long
Dim iStf As Long

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, DAOARRAY_Name1, iZl As Long, iCol As Long
recsetSQL1 = tabname
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
''Info:   'AccessArray(iSpalte,iZeile) <0, 0>       'ExcelArray(iZeile, iSpalte) <1, 1>
If ArrFill_DAO_OK1 Then
    Debug.Print "Anzahl: " & iZLMax1
    k = 0
    For iZl = 0 To iZLMax1
        i = DAOARRAY1(ndxID, iZl)
        j = DAOARRAY1(ndxVater, iZl)
        iStf = 0
        If j = 0 Then
            DAOARRAY1(ndxStufe, iZl) = iStf
        Else
            Do
                iStf = iStf + 1
                j = Init_Stufe_Tree_Rek(DAOARRAY1, iZLMax1, j, iStf, ndxStufe, ndxID, ndxVater)
            Loop Until j = 0
        End If
        DAOARRAY1(ndxStufe, iZl) = iStf
        DoEvents
        k = k + 1
        If k Mod 100 = 0 Then Debug.Print k
    Next iZl
End If

CurrentDb.Execute ("DELETE * FROM " & tabname & ";")
DoEvents
If Fill_Tbl(tabname, DAOARRAY1) Then
    MsgBox "Stufe gefüllt"
Else
    MsgBox "Fehler"
End If


End Function

Private Function Init_Stufe_Tree_Rek(ByVal DAOARRAY1, ByVal iZLMax1, ByVal ID As Long, ByVal Stufe As Long, Optional ByVal ndxStufe As Long = 3, Optional ByVal ndxID = 0, Optional ByVal ndxVater = 10) As Long
Dim db As DAO.Database
Dim rstInTree As DAO.Recordset
Dim i As Long
Dim ifind As Long

Init_Stufe_Tree_Rek = 0
For i = 0 To iZLMax1
    If ID = CLng(DAOARRAY1(ndxID, i)) Then
        Init_Stufe_Tree_Rek = CLng(DAOARRAY1(ndxVater, i))
        Exit For
    End If
Next i

End Function


'
'Function TreeVaterFill(Stufenr As Long, VaterNr As Long, IDNr As Long, SortNr As Long)
'
''Tabelle Treefill - für Treeview mit Vaterwerten füllen, wenn Stufe korrekt gefüllt ist
''Erste Zeile muss als Startpunkt gefüllt sein ...
'
'Dim TreeZlMax As Long, TreeColMax As Long, TreeArray As Variant
'
'Dim HlpStufeVater(10) As Long
'Dim iVglStufe As Long
'Dim I As Long
'Dim J As Long
'Dim K As Long
'
'
''    Call ArrFill_DAO("a0_00_ab4", iDAOKFZZlMax, iDAOKFZColMax, DAOArrayKFZ)
'    'Achtung Zeile und Spalte 0-basiert
'    'RowArray(iFldNr,iRecNr)
'    'RowArray(iSpalte,iZeile)
'
'For I = 0 To 10
'    HlpStufeVater(I) = 0
'Next I
'
'If ArrFill_DAO("SELECT * FROM tblTreefill;", TreeZlMax, TreeColMax, TreeArray) Then
'    ' Sich den ersten Vater merken (muss immer gefüllt sein)
'    HlpStufeVater(TreeArray(Stufenr, 0)) = TreeArray(VaterNr, 0)
'    HlpStufeVater(TreeArray(Stufenr, 0) + 1) = TreeArray(IDNr, 0)
'    iVglStufe = TreeArray(Stufenr, 0)
'    J = 0
'    For I = 1 To TreeZlMax
'        If TreeArray(Stufenr, I) <> iVglStufe Then
'            J = 1
'        Else
'            J = J + 1
'        End If
'        If TreeArray(Stufenr, I) = iVglStufe + 1 Then
'            HlpStufeVater(TreeArray(Stufenr, I)) = TreeArray(IDNr, I - 1)
'            HlpStufeVater(TreeArray(Stufenr, I) + 1) = TreeArray(IDNr, I)
'        Else
'            HlpStufeVater(TreeArray(Stufenr, I) + 1) = TreeArray(IDNr, I)
'        End If
'        TreeArray(SortNr, I) = J
'        TreeArray(VaterNr, I) = HlpStufeVater(TreeArray(Stufenr, I))
'        iVglStufe = TreeArray(Stufenr, I)
'    Next I
'
'    CurrentDb.Execute ("DELETE * FROM tblTreefill;")
'    Call Fill_Tbl("SELECT * FROM tblTreefill;", 1, TreeArray)
'
'End If
'
'End Function


Function NamConv(strnam As String, VN As Long, Optional sKom As String = ",")
'Funktion konvertiert einen String "NACHNAME, VORNAME" nach "Nachname" bzw "Vorname"
'VN = 1 Nachname (vor dem Komma) VN <> 1 Vorname (nach dem Komma)

Dim x As String
Dim i As Long

x = strnam
i = InStr(1, x, sKom)
If i = 0 Then
    NamConv = StrConv(x, 3)
    Exit Function
Else
    If VN = 1 Then ' Nachname (Vor dem Komma)
        x = Trim(Left(x, i - 1))
    Else ' Vorname (nach dem Komma)
        x = Trim(Mid(x, i + 1))
    End If
    x = StrConv(x, 3)
End If
NamConv = x

End Function


Function ExcelTransferspreadsheet(strDateiname As String, strTabname As String, iWahlLinkImport As Long, _
    Optional IstMitHeader As Boolean = True, Optional IstMitID As Boolean = True, Optional strFromTab As String = "", _
    Optional StrFromCell As String = "", Optional StrToCell As String = "", Optional XLVersion As Long = 9) As Boolean
    
    Dim rng As String
    Dim iRet As Long
    
    Dim strSQL As String
    Dim strTabnameOrg As String
    
    On Error GoTo ExcelTransferspreadsheet_Error
    
    ExcelTransferspreadsheet = False
    
    If Len(Trim(Nz(strDateiname))) > 0 Then
    
    ' TabA!A1:B3
            
        rng = ""
        If Len(Trim(Nz(strFromTab))) > 0 And Len(Trim(Nz(StrFromCell))) > 0 And Len(Trim(Nz(StrToCell))) > 0 Then
            If Right(strFromTab, 1) <> "!" Then strFromTab = strFromTab & "!"
            rng = strFromTab & StrFromCell & ":" & StrToCell
        Else
            If Len(Trim(Nz(strFromTab))) > 0 Then
                If Right(strFromTab, 1) <> "!" Then strFromTab = strFromTab & "!"
                rng = strFromTab
            Else
                rng = ""
            End If
            If Len(Trim(Nz(StrFromCell))) > 0 Then
                rng = rng & StrFromCell
            End If
            If Len(Trim(Nz(StrToCell))) > 0 And Len(Trim(Nz(StrFromCell))) > 0 Then
                rng = rng & ":" & StrToCell
            ElseIf Len(Trim(Nz(StrToCell))) > 0 Then
                rng = rng & "A1:" & StrToCell
            End If
        End If
        
        strTabnameOrg = strTabname
        
        If iWahlLinkImport = 0 Then
            If table_exist(strTabname) Then
                If vbOK = MsgBox("Tabelle existiert, überschreiben?", vbQuestion + vbOKCancel, strTabname) Then
                    DoCmd.DeleteObject acTable, strTabname
                Else
                    Exit Function
                End If
            End If
            
            If IstMitID = True Then
                strTabname = strTabname & "_Temp"
                If table_exist(strTabname) Then DoCmd.DeleteObject acTable, strTabname
            End If
            
        End If
        
        If iWahlLinkImport = 1 Then
            If File_exist(strDateiname) And Get_Priv_Property("prp_GL_XL_MehrfachTabs") = 0 Then
                iRet = MsgBox("Dateiname existiert, überschreiben?", vbQuestion + vbYesNoCancel, strDateiname)
                If iRet = vbYes Then
                    Kill strDateiname
                ElseIf iRet = vbCancel Then
                    Exit Function
                End If
            End If
        End If
        
        
'Range:   TabA!A1:B3 ''- nur link und import
'Range:   A1:A5
'Range:   B5
        
' iWahlLinkImport 0 = Import
' iWahlLinkImport 1 = Export
' iWahlLinkImport 2 = Link

'acSpreadsheetTypeExcel8        8   Microsoft Excel 97-Format        XLS
'acSpreadsheetTypeExcel9        8   Microsoft Excel 2000-Format      XLS

'acSpreadsheetTypeExcel12       9   Microsoft Excel 2010-Format      XLSX  - hier als Default verwendet
'acSpreadsheetTypeExcel12XML    10  Microsoft Excel 2010-Format      XML

'Ältere und andere Versionen
'acSpreadsheetTypeLotusWJ2      4   Nur japanische Version
'acSpreadsheetTypeLotusWK1      2   Lotus 1-2-3 WK1-Format
'acSpreadsheetTypeLotusWK3      3   Lotus 1-2-3 WK3-Format
'acSpreadsheetTypeLotusWK4      7   Lotus 1-2-3 WK4-Format
'acSpreadsheetTypeExcel3        0   Microsoft Excel 3.0-Format
'acSpreadsheetTypeExcel4        6   Microsoft Excel 4.0-Format
'acSpreadsheetTypeExcel5        5   Microsoft Excel 5.0-Format
'acSpreadsheetTypeExcel7        5   Microsoft Excel 95-Format


DoCmd.TransferSpreadsheet iWahlLinkImport, XLVersion, strTabname, strDateiname, IstMitHeader, rng
        
Call Set_Priv_Property("prp_XL_tmpFileName_exp", strDateiname)

        If iWahlLinkImport = 0 And IstMitID = True Then
            
            strSQL = "SELECT 0 as ID, * INTO " & strTabnameOrg & " From " & strTabname & " WHERE 0 = 1;"
            CurrentDb.Execute (strSQL)
            
            strSQL = "ALTER TABLE " & strTabnameOrg & " ALTER COLUMN ID COUNTER PRIMARY KEY;"
            CurrentDb.Execute (strSQL)
            
            strSQL = "INSERT INTO " & strTabnameOrg & " SELECT * FROM " & strTabname & ";"
            CurrentDb.Execute (strSQL)
            
            DoCmd.DeleteObject acTable, strTabname
            
        End If
        
        ExcelTransferspreadsheet = True
        
    Else
        MsgBox "No filename selected !", vbCritical + vbOKOnly, "Cancel"
    End If

    On Error GoTo 0
    Exit Function

ExcelTransferspreadsheet_Error:

    MsgBox "Error " & Err.Number & " (" & Err.description & ") in procedure ExcelTransferspreadsheet of Modul mdlSonstiges4"

End Function

Function fstrTeilen(ByVal xin As String, Optional leftright As Long = 1, Optional Dummy As Variant) As String

Dim i As Long
Dim strzw As String

strzw = xin
If leftright = 1 Then 'left
    i = InStr(1, xin, " ")
    If i > 0 Then
        strzw = Mid(xin, i + 1)
    End If
Else
    i = InStr(1, xin, " ")
    If i > 1 Then
        strzw = Left(xin, i - 1)
    End If
End If

fstrTeilen = strzw

End Function



Function Acc_ruecksetz()
    On Error Resume Next

    ' Access auf normal zurücksetzen
    DoCmd.Hourglass False
    Application.Echo True
    DoCmd.SetWarnings True
    Application.SetOption "Built-In Toolbars Available", True
'    Me.Repaint
End Function


Function DirTest(strDir As String) As Boolean

Dim strxx As String

DirTest = False
strxx = ""
On Error Resume Next
strxx = Dir(strDir, 16)

If Len(strxx) > 0 Then
    DirTest = True
End If

End Function

Public Function DelTreeVB(ByVal path As String) As Boolean
' Löscht mit reinen Visual Basic-Methoden einen
' Verzeichnisbaum (sofern möglich), indem rekursiv mit
' Dir$, Kill und RmDir gearbeitet wird.
' Kann der Baum nicht komplett gelöscht werden, wird als
' Funktionsrückgabewert FALSE verwendet.
' Hinweis: Die Dateien werden direkt gelöscht, nicht
' lediglich in den Papierkorb verschoben (VB-Funktion Kill)!
Dim sName As String
  ' Backslash-Zeichen notwendigenfalls anhängen
  If Right$(path, 1) <> "\" Then
 path = path & "\"
  End If
  ' Ziel: Funktionsrückgabewert TRUE
  DelTreeVB = True
  On Error GoTo Error_DelTreeVB
  ' Das erste Element in Path suchen
  sName = Dir$(path & "*.*", vbHidden + vbDirectory)
  ' Solange Elemente gefunden werden...
  While Len(sName)
 ' Pseudo-Verzeichnisse "." und ".." ignorieren
 If (sName <> ".") And (sName <> "..") Then
   ' Untersuchen, ob die Fundstelle eine Datei
   ' oder ein Verzeichnis ist:
   If (GetAttr(path & sName) Or vbDirectory) = vbDirectory Then
  ' Es handelt sich um ein Verzeichnis.
  DelTreeVB = DelTreeVB(path & sName & "\")
  sName = Dir$(path & "*.*", vbHidden + vbDirectory)
   Else
  ' Es handelt sich um eine Datei
  SetAttr path & sName, vbNormal ' Attribute zurücksetzen
  Kill path & sName  ' Datei löschen
  sName = Dir$()  ' nächste Datei suchen
   End If
 Else
   ' Bei "." oder ".." nächstes Element suchen
   sName = Dir$()
 End If
  Wend
  ' Unterverzeichnis durchlaufen - keine Dateien oder
  ' Unterverzeichnisse mehr vorhanden: Das Verzeichnis
  ' selber kann nun geloescht werden.
  RmDir path
Exit_DelTreeVB:
  Exit Function
Error_DelTreeVB:
  ' Funktiosrückgabewert FALSE
  DelTreeVB = False
  Resume Next
'  ' Optional: Interaktion mit dem Anwender (Beispiel):
'  Select Case MsgBox(Path & sName & vbNewLine _
'   & "konnte nicht gelöscht werden:" _
'   & vbNewLine & Err.Description, _
'   vbAbortRetryIgnore + vbDefaultButton2, _
'   "Fehler beim Löschen")
' Case vbAbort:  Resume Exit_DelTreeVB
' Case vbRetry:  Resume 0
' Case vbIgnore: Resume Next
'  End Select
End Function


Function DateinameTest(datname As String, Optional backslaskOK As Boolean = False)

Dim tstname As String
Dim strChr As String

'In Dateinamen verboten sind:
'\  092
'/  047
':  058
'*  042
'?  063
'"  034
'<  060
'>  062
'|  124
' und werden durch _ ersetzt
' Leerzeichen wird ebenfalls durch _ ersetzt

Dim i As Long, j As Long
tstname = ""

j = Len(datname)
For i = 1 To j
    strChr = Mid(datname, i, 1)

    Select Case strChr
        
        Case "/", ":", "*", "?", Chr$(34), "<", ">", "|", " "
           tstname = tstname & "_"
        
        Case "\"
            If backslaskOK Then
                tstname = tstname & "\"
            Else
                tstname = tstname & "_"
            End If
        
        Case Else
           tstname = tstname & strChr
    
    End Select
Next i

DateinameTest = tstname

End Function


Function ChgColLabelName_general(frmName As String)
'---------------------------------------------------------------------------------------
' Procedure : ChgColLabelName_general
' Author    : Klaus Oberdalhoff
' Date      : 04.06.2011
' Purpose   : On a freshly auto-generated form especially for Datasheet forms the label-names are Label1 to nnn
'           : On Datasheet-Forms the Label-Caption generally is shown as the control-Name
'           : To simplify the changing of the caption (for showing the control name)
'           : this function names the labels to "lbl_" & caption (which is the control-name)
'           : and fixes the bug to not stick all labels (the ones in the second row) to the control.
'---------------------------------------------------------------------------------------
'
  Dim frm As Form
  Dim ctl As control
  Dim Ctl1 As control
  Dim ctl1Name As String, ctlName As String
  Dim XTop As Variant, XLeft As Variant
  Dim XWidth As Variant, XHeight As Variant

  DoCmd.OpenForm frmName, acDesign
  Set frm = forms(frmName)
 
  For Each ctl In frm
    If ctl.ControlType = acLabel Then
        ctlName = ctl.Name
        ctl1Name = ctl.caption
        XTop = ctl.Top
        XLeft = ctl.Left
        XWidth = ctl.width
        XHeight = ctl.height
        DeleteControl frm.Name, ctl.Name
        Set ctl = CreateControl(frm.Name, acLabel, , ctl1Name, , XLeft, XTop, XWidth, XHeight)
        ctl.Name = "lbl_" & ctl1Name
        ctl.caption = ctl1Name
    End If
  Next ctl
   
  DoCmd.Close acForm, frmName, acSaveYes
  Set frm = Nothing
End Function

'#########################################################################################

Public Function ChgSaSoCondition(frm As Form, iMon As Variant, iJahr As Variant, Optional dwidth As Variant = 1.5)
  'Autor Klaus Oberdalhoff
  ' Bedingung: Form enthält 31 Felder: T01 bis T31 und 31 Labels lbl_T01 bis lbl_T31
  '
  ' Wenn eine Datatasheetform die Felder T01, T02  bis T31 sowie die passenden Labels lbl_T01, ... lbl_T31 enthält
  ' wird die Überschrift auf "01 Mo", "02 Di" ... geändert sowie die Samstage und Sonntage per Conditional FOrmating rosa ringefärbt

'  Dim frm As Form
  Dim ctl As control

  Dim i As Long
  Dim j As Long
  Dim k As Long
  Dim l As Long
  Dim dt1 As Date
  Dim dt2 As Date
  Dim dt3 As Date
  Dim WkTag
  Dim strTag As String
  Dim fcd As FormatCondition
  
  WkTag = Array(, "Mo", "Di", "Mi", "Do", "Fr", "Sa", "So")
 
  dt1 = DateSerial(iJahr, iMon, 1)
  dt2 = DateSerial(iJahr, iMon + 1, 0)
  j = Format(dt2, "d", 2, 2)
 
 
  For i = 1 To 31
    Set ctl = frm("T" & Right("00" & i, 2))

    ctl.ColumnHidden = False
    ctl.ColumnWidth = dwidth * 567
    k = Weekday(DateSerial(iJahr, iMon, i), 2)
    
    With ctl.FormatConditions
        .Delete
    
        If k = 6 Then ' Samstag
           l = 15395583
            'l = TLookup("FarbNrHint", "_tblFarben", "FarbID = 7")
            'bei acExpression wird der 2. Parameter ignoriert
            'Dummy-Expression um die gesamte Spalte einzufärben
            Set fcd = .Add(acExpression, acEqual, "1 = 1")
            fcd.backColor = l
        
        ElseIf k = 7 Then ' Sonntag
            l = 14145535
    'l = TLookup("FarbNrHint", "_tblFarben", "FarbID = 8")
            'bei acExpression wird der 2. Parameter ignoriert
            'Dummy-Expression um die gesamte Spalte einzufärben
            Set fcd = .Add(acExpression, acEqual, "1 = 1")
            fcd.backColor = l
        End If
    
    End With
    
    If i > j Then ' Monat hat weniger als 31 Tage
        ctl.ColumnHidden = True
    End If
'  Next i
        
'  For i = 1 To 31
    'Set Header
    '#####################################
    
    strTag = Right("00" & i, 2)
    Set ctl = frm("lbl_T" & strTag)
    strTag = strTag & " " & WkTag(Weekday(DateSerial(iJahr, iMon, i), 2))
    ctl.caption = strTag
        
  Next i
  
End Function


Function OpenPasswordProtectedDB(strDbName As String, strPwd As String)
'http://entwickler-forum.de/showthread.php?t=53956

Static acc As Access.Application
Dim db As DAO.Database
'Dim strDbName As String

strPwd = ";PWD=" & strPwd

'strDbName = "C:\TEMP\PDM\xammunition.mdb"
Set acc = New Access.Application
acc.Visible = True
Set db = acc.DBEngine.OpenDatabase(strDbName, False, False, strPwd)
acc.OpenCurrentDatabase strDbName
'acc.DoCmd.RunMacro "update PO MONITOR" ' ein macro in der 2ten MDB
Set db = Nothing
End Function

'##########################

'' Ab Access 2010
'Function ConvertLinkedTable2Intern(strTabelle As String)
'
'DoCmd.SelectObject acTable, strTabelle, True
'RunCommand acCmdConvertLinkedTableToLocal
'
'End Function

'###########################

''' ## Parameterabfragen
''' www.donkarl.com - access faq

''Dim db As DAO.Database
''Dim rs As DAO.Recordset
''Dim qdf As DAO.QueryDef
''
''Set db = CurrentDb
''Set qdf = db.QueryDefs("Meine_Parameter_Abfrage")
''qdf.Parameters!MeinParameter1 = "Wert_für_Parameter1_in_Anführungszeichen_falls_er_ein_Text_ist"
''qdf.Parameters!MeinParameter2 = Wert_für_Parameter2
'''usw.
''
''Set rs = qdf.OpenRecordset(dbOpenDynaset)
'''hier folgt brillanter Code, der mit dem Recordset arbeitet
'''…
'''am Ende so tun, als wär nix gewesen:
''qdf.Close: Set qdf = Nothing
''rs.Close: Set rs = Nothing
''Set db = Nothing
''
''Falls du kein Recordset willst, sondern z.B. bloß eine Aktionsabfrage mit Parametern ausführen, sieht der Code ähnlich aus,
''nur folgt nach dem Zuweisen der Parameter kein "Set rs…" usw. sondern ein schlichtes:
''qdf.Execute
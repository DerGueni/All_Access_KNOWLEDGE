Attribute VB_Name = "mdl_DbAuswerten_Ver_2"
Option Compare Database
Option Explicit

Const Const_Eigenes_Modul As String = "mdl_DbAuswerten_Ver_2"

Dim ictrlAr
Dim strctrlAr
Dim JUcntAnz As Long
Dim db As DAO.Database
Dim rst As DAO.Recordset


' Es werden die Abfragen "qrymdb*" erzeugt
' Es werden die Tabellen "_int_tblObjektNamen", "_tblAlleFormularFelder", "_int_tblObjektNamen" erzeugt
' Zum Auswerten einfach dieses Modul in eine fremde Datenbank kopieren
' WICHTIG: Beim Kopieren Modulnamen beibehalten, oder die Konstante im Kopf ändern, sonst klappt's nicht

' Im Direktbereich

'  ?ModList()

'ausführen. Die kann bei größeren Datenbanken bis zu 15 Min dauern ...
' Im Direktbereich wird es angezeigt, wenn alles OK, dann entsprechende Meldung

'Danach enthält die Abfrage "qrymdb_Anzahl_Objekte" eine Summary der Objekte.
'Die Tabellen enthalten:

'Die Haupttabelle "_int_tblObjektNamen" enthält alle Objekte sowie alle Funktionen "Function und Sub etc" auch der Fornulare / Reports
' Die Zusatztabelle "_tblAlleFormularFelder" enthält alle Felder von Formularen und Reports
' Die Zusatztabelle "_int_tblObjektNamen" enthält alle Felder aller Tabellen

'Siehe auch Datenbank "Auswertung_fuer_Angebote.accdb" -- diese enthält eine Summary wenn mehrere mdb Verwendung finden

' Autor: Klaus Oberdalhoff
'##########################
'
'Untere Schmiedgasse 8
'D-90403 Nürnberg
'Germany
'
'Tel  : +49(0911)2369666
'Handy: 0152 33854642
'Fax  : +49(03212)1154718
'Skype: klaus.oberdalhoff
'email: kobd@ gmx.de
'Web:  http://www.sql-insider.de
'AboutMe: http://about.me/klaus_oberdalhoff
'LinkedIn: http://de.linkedin.com/in/klausoberdalhoff
'XING: https://www.xing.com/profile/Klaus_Oberdalhoff
'Ich unterstütze SQL PASS Deutschland e.V. (http://www.sqlpass.de)


Function ModList() As String

    Dim tmp As String
    Dim cnt As Container, doc As Document
    Dim i As Integer, j As Integer, x, nix, tblname As String
    Dim strSQL As String
    
    Set db = CurrentDb()
    tmp = ""
    
'Dim ictrlAr
'Dim strctrlAr
'Dim JUcntAnz As Long
    strctrlAr = Array("acBoundObjectFrame", "acCheckBox", "acComboBox", "acCommandButton", "acCustomControl", "acImage", "acLabel", "acLine", "acListBox", "acObjectFrame", "acOptionButton", "acOptionGroup", "acPage", "acPageBreak", "acRectangle", "acSubform", "acTabCtl", "acTextBox", "acToggleButton")
    ictrlAr = Array(acBoundObjectFrame, acCheckBox, acComboBox, acCommandButton, acCustomControl, acImage, acLabel, acLine, acListBox, acObjectFrame, acOptionButton, acOptionGroup, acPage, acPageBreak, acRectangle, acSubform, acTabCtl, acTextBox, acToggleButton)
    JUcntAnz = UBound(strctrlAr)

    Debug.Print "Start part 1 - Objektnamen " & Now()

    If Not table_exist("_int_tblObjektNamen") Then
        nix = FuncTableCreate("_int_tblObjektNamen")
    End If

    If Not table_exist("_int_tblQueryMain") Then
        nix = FuncTableCreate_Qry("_int_tblQueryMain")
    End If
    
    If Not table_exist("_int_tblTabellenBeschreibung") Then
        nix = DescTableCreate("_int_tblTabellenBeschreibung")
    End If
   
    If Not table_exist("_int_tblFrmFeldnamen") Then
    
        strSQL = "CREATE TABLE _int_tblFrmFeldnamen (frmTyp CHAR, frmName CHAR, ControlName CHAR, ControlTypeID INT, ControlType CHAR, IsVisible BIT, ControlCaption MEMO);"
        CurrentDb.Execute (strSQL)
        strSQL = "CREATE INDEX PK_int_tblFrmFeldnamen ON _int_tblFrmFeldnamen (frmTyp, frmName, ControlName) WITH PRIMARY;"
        CurrentDb.Execute (strSQL)
    End If

    CurrentDb.Execute ("DELETE * FROM _int_tblObjektNamen;")
    CurrentDb.Execute ("DELETE * FROM _int_tblQueryMain;")
    CurrentDb.Execute ("DELETE * FROM _int_tblFrmFeldnamen;")
    CurrentDb.Execute ("DELETE * FROM _int_tblTabellenBeschreibung;")

    Call Create_qrymdb_Queries

    DoCmd.Echo False
            
'   RestIns(False) = Bestehende Infos werden nicht gelöscht (nur hinzufügen)
'   RestIns(True) = Bestehende Infos werden vorher gelöscht
    Call RestIns(True)   ' Tabellen, Makros, Reports, Forms, Abfragen

    Debug.Print "Start part 2 - Modul Funktionen" & Now()
    'Module
'    DoCmd.Echo True
    DoCmd.Echo False
    For i = 0 To db.Containers.Count - 1
        Set cnt = db.Containers(i)
        For j = 0 To cnt.Documents.Count - 1
            Set doc = cnt.Documents(j)
 '           Debug.Print doc.Container
            If doc.Container = "Modules" Then
                If doc.Name <> Const_Eigenes_Modul Then
                    x = Func_SubsInModule(doc.Name, False)
                End If
    '            tmp = tmp & doc.Name & SEMICOLON
            End If
        Next
        DoEvents
    Next

'    ModList = tmp
    
    
    Debug.Print "Start part 3 - Forms Module " & Now()
    Set rst = db.OpenRecordset("SELECT TOP 1 * FROM _int_tblFrmFeldnamen;")

    x = Form_Mdl()      ' Module behind Forms

        Debug.Print "Start part 4 - Report Module " & Now()

    x = Report_Mdl()    ' Module behind Reports
    
    rst.Close
    Set rst = Nothing

    Debug.Print "Start part 5 - Tabellen " & Now()

    x = TblInfo_AllTab()
    
    Set rst = Nothing
    Set db = Nothing
    
    Debug.Print "Start part 6 - Abfragen SQL " & Now()

    CurrentDb.Execute ("UPDATE _int_tblObjektNamen SET [_int_tblObjektNamen].FunktionsParam = Null WHERE ((([_int_tblObjektNamen].Art)='Abfragen' Or ([_int_tblObjektNamen].Art)='Interne Abfragen'));")

    qry_QueryMain_Fill
    
    CurrentDb.Execute ("UPDATE _int_tblQueryMain INNER JOIN _int_tblObjektNamen ON [_int_tblQueryMain].Qry_Name = [_int_tblObjektNamen].ModulName SET [_int_tblObjektNamen].FunktionsParam = [qry_SQL] WHERE ((([_int_tblObjektNamen].Art)='Abfragen' Or ([_int_tblObjektNamen].Art)='Interne Abfragen'));")
    
    DoEvents
    
    DoCmd.Echo True
    Debug.Print "End of function now " & Now()

End Function



Function Create_qrymdb_Queries()

Dim strSQL As String

'The queries to create in beforehand: ' Tested up until Version Access 2013

''qrymdbForm
strSQL = "SELECT MSysObjects.Name as ObjName FROM MSysObjects WHERE (((MSysObjects.flags) = 0 Or (MSysObjects.flags) = 8) And ((MSysObjects.Type) = -32768) And ((Left([Name], 1)) <> " & Chr$(34) & "~" & Chr$(34) & ")) ORDER BY MSysObjects.Name;"
Call CreateQuery(strSQL, "qrymdbForm")
'
''qrymdbReport
strSQL = "SELECT MSysObjects.Name as ObjName FROM MSysObjects WHERE (((MSysObjects.flags) = 0 Or (MSysObjects.flags) = 8) And ((MSysObjects.Type) = -32764) And ((Left([Name], 1)) <> " & Chr$(34) & "~" & Chr$(34) & ")) ORDER BY MSysObjects.Name;"
Call CreateQuery(strSQL, "qrymdbReport")
'
''qrymdbModul
strSQL = "SELECT MSysObjects.Name as ObjName FROM MSysObjects WHERE (((MSysObjects.Type) = -32761) And ((MSysObjects.flags) = 0 Or (MSysObjects.flags) = 256 Or (MSysObjects.flags) = 8)) ORDER BY MSysObjects.Name;"
Call CreateQuery(strSQL, "qrymdbModul")
'
''qrymdbMacro
strSQL = "SELECT MSysObjects.Name as ObjName FROM MSysObjects WHERE (((MSysObjects.Type)=-32766) AND ((MSysObjects.Flags=0) OR (MSysObjects.Flags=8))) ORDER BY MSysObjects.Name;"
Call CreateQuery(strSQL, "qrymdbMacro")
'
''qrymdbQuery
strSQL = "SELECT MSysObjects.Name as ObjName FROM MSysObjects WHERE (((MSysObjects.flags) <> 3) And ((MSysObjects.Type) = 5)) ORDER BY MSysObjects.Flags, MSysObjects.Name;"
Call CreateQuery(strSQL, "qrymdbQuery")
'
''qrymdbQueryIntern
strSQL = "SELECT MSysObjects.Name as ObjName FROM MSysObjects WHERE (((MSysObjects.Type) = 5) And ((MSysObjects.flags) = 3)) ORDER BY MSysObjects.Name;"
Call CreateQuery(strSQL, "qrymdbQueryIntern")
'
''qrymdbTable  'Type 1 = internal,  4 = SQL Server, 6 = Access External
strSQL = "SELECT MSysObjects.Name AS ObjName, MSysObjects.Database, MSysObjects.Type FROM MSysObjects WHERE (((MSysObjects.Type) = 1) And ((MSysObjects.flags) = 0) And ((Left([Name], 1)) <> " & Chr$(34) & "~" & Chr$(34) & ")) Or (((MSysObjects.Type) = 4) And ((MSysObjects.flags) = 1048576) And ((Left([Name], 1)) <> " & Chr$(34) & "~" & Chr$(34) & ")) Or (((MSysObjects.Type) = 6) And ((MSysObjects.flags) = 2097152) And ((Left([Name], 1)) <> " & Chr$(34) & "~" & Chr$(34) & ")) ORDER BY MSysObjects.Type, MSysObjects.[Name];"
Call CreateQuery(strSQL, "qrymdbTable")

''qrymdb_InfoMsysObjects
strSQL = "SELECT MSysObjects.* FROM MSysObjects;"
Call CreateQuery(strSQL, "qrymdb_InfoMsysObjects")

DoEvents

End Function


Private Function CreateQuery(strSQL As String, Optional Queryname As String = "qrySorting") As Boolean

Dim dbs As DAO.Database
Dim qdf As DAO.QueryDef

   On Error GoTo CreateQuery_Error

Set dbs = CurrentDb
If ObjectExists("Query", Queryname) Then
    DoCmd.DeleteObject acQuery, Queryname
End If
Set qdf = dbs.CreateQueryDef(Queryname, strSQL)

DoEvents

   CreateQuery = True
   On Error GoTo 0
   Exit Function

CreateQuery_Error:

'    MsgBox "Error " & Err.Number & " (" & Err.Description & ") in procedure CreateQuery of Modul DataFunctions"
CreateQuery = False

End Function


Private Function ObjectExists(strObjectType As String, strObjectName As String) As Boolean
' Pass the Object type: Table, Query, Form, Report, Macro, or Module
' Pass the Object Name
     Dim db As DAO.Database
     Dim tbl As DAO.TableDef
     Dim QRY As DAO.QueryDef
     Dim i As Integer
     
     Set db = CurrentDb()
     ObjectExists = False
     
     If strObjectType = "Table" Then
          For Each tbl In db.TableDefs
               If tbl.Name = strObjectName Then
                    ObjectExists = True
                    Set db = Nothing
                    Exit Function
               End If
          Next tbl
     ElseIf strObjectType = "Query" Then
          For Each QRY In db.QueryDefs
               If QRY.Name = strObjectName Then
                    ObjectExists = True
                    Set db = Nothing
                    Exit Function
               End If
          Next QRY
     ElseIf strObjectType = "Form" Or strObjectType = "Report" Or strObjectType = "Module" Then
          For i = 0 To db.Containers(strObjectType & "s").Documents.Count - 1
               If db.Containers(strObjectType & "s").Documents(i).Name = strObjectName Then
                    ObjectExists = True
                    Set db = Nothing
                    Exit Function
               End If
          Next i
     ElseIf strObjectType = "Macro" Then
          For i = 0 To db.Containers("Scripts").Documents.Count - 1
               If db.Containers("Scripts").Documents(i).Name = strObjectName Then
                    ObjectExists = True
                    Set db = Nothing
                    Exit Function
               End If
          Next i
     Else
          MsgBox "Invalid Object Type passed, must be Table, Query, Form, Report, Macro, or Module"
     End If

Set db = Nothing
     
End Function



Function Form_Mdl()
        
        Dim db As DAO.Database, x, y As String
        Dim rst As DAO.Recordset
        Dim frm As Form, O_Typ As String
        Dim i As Long, Anz As Long, c As control
        Dim strCaption As String

        O_Typ = "frm"
        Set db = CurrentDb
'        Set rst = db.OpenRecordset("SELECT * FROM qrymdbFormModul;", dbOpenDynaset)
        Set rst = db.OpenRecordset("SELECT * FROM qrymdbForm", dbOpenDynaset)
                   
            Do While Not rst.EOF
                        
'                rst.Edit
                y = rst.fields(0)
                DoCmd.OpenForm y, acDesign
                If Forms(y).HasModule = True Then
                    x = Func_SubsInModule("Form_" & rst.fields(0), True)
                End If
                
                Set frm = Forms(y)
                Anz = frm.Controls.Count ' liefert die Anzahl Steuerelemente im Formular
                If Anz > 0 Then
                    For i = 0 To Anz - 1
                        Set c = frm.Controls(i)
                        strCaption = ""
                        On Error Resume Next
                            strCaption = Nz(c.caption, " ")
                        On Error GoTo 0
                '        If C.ControlType = acLabel Or C.ControlType = acCommandButton Then  ' wenn's n Label oder button ist
                '             Call Add_Label_To_Table(O_Typ, Y, C.ControlType, C.Visible, C.Name, strCaption)
                '        End If
                    Next i
                End If
    
                DoCmd.Close acForm, y, acSaveNo
                rst.MoveNext
                If rst.EOF Then Exit Do    ' für den Fall, daß wir uns auf dem letzten Datensatz befinden
 '               Stop
                DoEvents
            Loop
            
            rst.Close
        Set db = Nothing
        Set rst = Nothing

End Function

Function Report_Mdl()
        
        Dim db As DAO.Database, x, y As String
        Dim rst As DAO.Recordset
        Dim frm As Report, O_Typ As String
        Dim i As Long, Anz As Long, c As control
        Dim strCaption As String

        O_Typ = "rpt"
        Set db = CurrentDb
'        Set rst = db.OpenRecordset("SELECT * FROM qrymdbReportModul;", dbOpenDynaset)
        Set rst = db.OpenRecordset("SELECT * FROM qrymdbReport;", dbOpenDynaset)
                   
            Do While Not rst.EOF
                        
'                rst.Edit
                y = rst.fields(0)
                DoCmd.OpenReport y, acDesign
                If Reports(y).HasModule = True Then
                    x = Func_SubsInModule("Report_" & rst.fields(0), True)
                End If
                
                Set frm = Reports(y)
                Anz = frm.Controls.Count ' liefert die Anzahl Steuerelemente im Formular
                If Anz > 0 Then
                    For i = 0 To Anz - 1
                        Set c = frm.Controls(i)
                        strCaption = ""
                        On Error Resume Next
                            strCaption = Nz(c.caption, " ")
                        On Error GoTo 0
                        
                        If c.ControlType = acLabel Or c.ControlType = acCommandButton Then  ' wenn's n Label oder button ist
                             Call Add_Label_To_Table(O_Typ, y, c.ControlType, c.Visible, c.Name, strCaption)
                        End If
                    Next i
                End If
    
                DoCmd.Close acReport, y, acSaveNo
                rst.MoveNext
                If rst.EOF Then Exit Do    ' für den Fall, daß wir uns auf dem letzten Datensatz befinden
 '               Stop
                DoEvents
            Loop
            rst.Close
        Set db = Nothing
        Set rst = Nothing

End Function


Function Add_Label_To_Table(O_Typ As String, O_Formname As String, C_ControlType As Long, C_Visible As Boolean, C_Name As String, C_Caption As String)

With rst
'        strSQL = "CREATE TABLE _int_tblFrmFeldnamen (frmTyp CHARACTER, frmName CHARACTER, ControlName CHARACTER, ControlTypeID INTEGER, ControlType CHARACTER, " & _
'                 "IsVisible BIT, ControlCaption CHARACTER);"
    .AddNew
        .fields("frmTyp").Value = O_Typ
        .fields("frmName").Value = O_Formname
        .fields("ControlName").Value = C_Name
        .fields("ControlTypeID").Value = C_ControlType
        .fields("ControlType").Value = f_ctrlType(C_ControlType)
        .fields("IsVisible").Value = C_Visible
        .fields("ControlCaption").Value = C_Caption
    .update
End With

End Function

Private Function f_ctrlType(ictrl As Long) As String

'Name des ControlTypes des Formulars / Reports ermitteln

Dim i As Long

'Dim ictrlAr
'Dim strctrlAr
'Dim JUcntAnz As Long
'    strctrlAr = Array("acBoundObjectFrame", "acCheckBox", "acComboBox", "acCommandButton", "acCustomControl", "acImage", "acLabel", "acLine", "acListBox", "acObjectFrame", "acOptionButton", "acOptionGroup", "acPage", "acPageBreak", "acRectangle", "acSubform", "acTabCtl", "acTextBox", "acToggleButton")
'    ictrlAr = Array(acBoundObjectFrame, acCheckBox, acComboBox, acCommandButton, acCustomControl, acImage, acLabel, acLine, acListBox, acObjectFrame, acOptionButton, acOptionGroup, acPage, acPageBreak, acRectangle, acSubform, acTabCtl, acTextBox, acToggleButton)
'    JUcntAnz = ucount(strctrlAr)

f_ctrlType = ""
For i = 0 To JUcntAnz
    If ictrlAr(i) = ictrl Then
        f_ctrlType = strctrlAr(i)
        Exit For
    End If
Next i

End Function


Function Func_SubsInModule(strModulname As String, MBF As Boolean) As Long

    ' Fehlerbehandlung
    On Error GoTo Error_Func_SubsInModule

    ' Variablendimensionierung
    Dim mdl As Module, strTemp As String, i As Integer, funcnam As String, funcArt As Integer, nix
    Dim FuncxNam As String
    Dim ModulAnzahl As Integer

    ' Verweis auf "Module"-Objekt zurückgeben.
    DoCmd.OpenModule (strModulname)
    Set mdl = Modules(strModulname)

    ' Zahl der Zeilen des Moduls zurückgeben.
    Func_SubsInModule = mdl.CountOfLines

    ' Schleife
    ModulAnzahl = 0
    For i = 1 To Func_SubsInModule
        strTemp = Trim(mdl.lines(i, 1))
        
   '     Sub Function Property erkennen
'         funcArt = strgTest(strTemp, False, FuncxNam)
         funcArt = strgTest(strTemp, True, FuncxNam)
         If funcArt > 0 Then
          '  Debug.Print "strtemp: " & strtemp
            funcnam = strTemp
            ' Folgezeilen auch mit ausgeben
            Do While Right(Trim(strTemp), 1) = "_"
                funcnam = Left(Trim(funcnam), Len(funcnam) - 1)
                i = i + 1
                strTemp = Trim(mdl.lines(i, 1))
              '  Debug.Print "strtemp: " & strtemp
                funcnam = funcnam & " " & strTemp
            Loop
   '         Debug.Print "funcnam: " & funcnam & ", " & funcArt
'Public Function FunctNamesCreate(TableName As String, Modname As String, Funct As String, funcArt As Integer) As Boolean
            nix = FunctNamesCreate(strModulname, funcnam, MBF)
            ModulAnzahl = ModulAnzahl + 1
        End If
    
    Next
    If ModulAnzahl = 0 Then
        nix = FunctNamesCreate(strModulname, "Sub Keine()", MBF)
    End If
    
Exit_Func_SubsInModule:

    DoCmd.Close acModule, strModulname, acSaveNo
    Exit Function

Error_Func_SubsInModule:

    If Err.Number = 3022 Then ' Existiert bereits
        Resume Next
    Else
        If Err.Number = 3015 Then
            Func_SubsInModule = 0
            Exit Function
        Else
            MsgBox Err & ": " & Err.description
            Func_SubsInModule = -1
            Resume Exit_Func_SubsInModule
        End If
    End If

End Function

Private Function strgTest(strTemp As String, PrivJN As Boolean, FuncName As String) As Integer
'Hilfsfunktion zum Erkennen der Funktionsköpfe (Auch Klassenmodule)
'Private Functions werden nur erkannt, wenn PrivJN = True
'Rückgabe 1 - 5 für 1=sub, 2=function, 3=Property Let, 4=Property Get, 5=Property Set
'Rückgabe 101 - 105 für private 1=sub, 2=function, 3=Property Let, 4=Property Get, 5=Property Set

    '"Sub"
    '"Function"
    '"Property Let"
    '"Property Get"
    '"Property Set"
    '
    '"Public Sub"
    '"Public Function"
    '"Public Property Let"
    '"Public Property Get"
    '"Public Property Set"
    '
    '"Private Sub"
    '"Private Function"
    '"Private Property Let"
    '"Private Property Get"
    '"Private Property Set"

Dim st1 As String, Priv As Boolean
    
    Priv = False
    strgTest = 0

    'Leerzeichen löschen
    st1 = Trim(strTemp)
        
    'Das Wort "Private" löschen, wenn PrivJN = True
    If PrivJN = True Then
        If Left(st1, 7) = "Private" Then
            st1 = Right(st1, Len(st1) - 8)
            Priv = True
        End If
    End If
    
    'Das Wort "Public" löschen
    If Left(st1, 7) = "Public " Then
        st1 = Right(st1, Len(st1) - 7)
        strgTest = 0
    End If
    
        If Left(st1, 4) = "Sub " Then
            strgTest = strgTest + 1
            st1 = Right(st1, Len(st1) - 4)
        End If
                        
        If Left(st1, 9) = "Function " Then
            strgTest = strgTest + 2
            st1 = Right(st1, Len(st1) - 9)
        End If
    
        If Left(st1, 13) = "Property Let " Then
            strgTest = strgTest + 3
        End If
    
        If Left(st1, 13) = "Property Get " Then
            strgTest = strgTest + 4
        End If
    
        If Left(st1, 13) = "Property Set " Then
            strgTest = strgTest + 5
        End If
        If strgTest > 0 And Priv = True Then strgTest = strgTest + 100
    FuncName = st1
End Function


Public Function FunctNamesCreate(ModName As String, Funct As String, XMBF As Boolean) As Boolean

On Error GoTo Err_FunctNamesCreate
    
    Dim db As DAO.Database
    Dim rst As DAO.Recordset
    Dim mdlModulname As Module
    Dim FName As String
    Dim FParam As String
    Dim FRueck As String, i, j, k, xx
    Dim funcArt As String
    Dim ModTyp As String
    Dim funcPriv As Boolean
    funcPriv = False
    i = InStr(1, Funct, "(")
    FName = Left(Funct, i - 1)
    For k = Len(Funct) To 1 Step -1
        If Mid$(Funct, k, 1) = ")" Then
        j = k
        Exit For
      End If
    Next k
    If k = 1 Then
        j = 0
        i = 0
        FRueck = "(keine)"
        FParam = "(keine)"
    Else
        If j > i + 1 Then
            FParam = Mid(Funct, i + 1, (j - i - 1)) & ""
        Else
            FParam = "(keine)"
        End If
        If Len(Funct) > j Then
              FRueck = Mid(Funct, j + 1)
        Else
              FRueck = "(keine)"
        End If
    End If

    Set db = CurrentDb
    Set rst = db.OpenRecordset("SELECT * FROM _int_tblObjektNamen;", dbOpenDynaset)
      
    FName = Trim(FName)
    If Left(FName, 7) = "Public " Then
        FName = Right(FName, Len(FName) - 7)
    End If
    
    If Left(FName, 7) = "Private" Then
        FName = Right(FName, Len(FName) - 8)
        funcPriv = True
    End If
    
    FName = Trim(FName)
    
    If Left(FName, 4) = "Sub " Then
        funcArt = "Sub"
        FName = Right(FName, Len(FName) - 4)
    End If
                    
    If Left(FName, 9) = "Function " Then
        funcArt = "Function"
        FName = Right(FName, Len(FName) - 9)
    End If
        
    If Left(FName, 13) = "Property Let " Then
        funcArt = "Property Let"
        FName = Right(FName, Len(FName) - 13)
    End If

    If Left(FName, 13) = "Property Get " Then
        funcArt = "Property Get"
        FName = Right(FName, Len(FName) - 13)
    End If

    If Left(FName, 13) = "Property Set " Then
        funcArt = "Property Set"
        FName = Right(FName, Len(FName) - 13)
    End If
    
    Set mdlModulname = Modules(ModName)
    If mdlModulname.Type = acClassModule Then
        ModTyp = "Module Fct Class"
    Else
        ModTyp = "Module Fct Norm"
    End If
            
    With rst
            'Neuen Datensatz einfügen
            .AddNew
                !ModulName = Trim(ModName)
                !Art = Trim(ModTyp)
                !FunktionsName = Trim(FName)
                !FunktionsParam = Trim(FParam)
                !FunktionsRueck = Trim(FRueck)
                !FunktionsArt = Trim(funcArt)
                !Priv = funcPriv
                !MBF = XMBF
            .update
            
 '       .Close
    End With
       
Exit_FunctNamesCreate:
    Exit Function

Err_FunctNamesCreate:
    If Err.Number = 3022 Then ' Existiert bereits
        Resume Next
    Else
        MsgBox "FunctNamesCreate " & Err & ": " & Err.description
        Resume Exit_FunctNamesCreate
    End If

End Function

Sub GetProzName(ModulName As String)
    
    Dim lngAnzahlZeilenModul As Long            ' Anzahl der Zeilen im Modul
    Dim lngAnzahlZeilenDeklaration As Long      ' Anzahl der Zeilen im Deklarationsabschnitt
    Dim lngAktuelleZeile As Long                ' Aktuelle Zeile bei Programmdurchlauf
    Dim strProzName As String                   ' Name der Prozedur
    Dim lngProzTyp  As Long                     ' Typ der Prozedur (Rückgabe als Zahl)
    Dim lngZeileProzDefinition As Long          ' Zeile in der die Definition der Prozedur steht
    Dim mdlModulname As Module
    
    '***** Modul öffnen und Objektvariable setzen
    DoCmd.OpenModule ModulName
    Set mdlModulname = Modules(ModulName)
        
    '***** Die Anzahl der Zeilen des Moduls ermitteln
    lngAnzahlZeilenModul = mdlModulname.CountOfLines
    '***** Die Anzahl der Zeilen des Deklarationsabschnitts des Moduls ermitteln.
    lngAnzahlZeilenDeklaration = mdlModulname.CountOfDeclarationLines
    '***** aktuelle Zeile hinter den Deklarationsabschnitt setzen
    lngAktuelleZeile = lngAnzahlZeilenDeklaration + 1
    
    '***** Modul durchlaufen
    Do
        '***** Namen der Prozedur ermitteln
        strProzName$ = mdlModulname.ProcOfLine(lngAktuelleZeile, lngProzTyp)
                        
        '***********************
        Debug.Print strProzName$ '*************** Ausgabe
        '***********************
        
        '***** aktuelle Zeile auf nächste Prozedur setzen
        lngAktuelleZeile = lngAktuelleZeile + mdlModulname.ProcCountLines(strProzName$, lngProzTyp)
    Loop While (lngAktuelleZeile < lngAnzahlZeilenModul)

    '***** Modul schließen
    DoCmd.Close acModule, ModulName
    
End Sub

Function ModArt(ModName As String)
    Dim mdlModulname As Module
    
    DoCmd.Echo False
    DoCmd.OpenModule ModName
    Set mdlModulname = Modules(ModName)
    If mdlModulname.Type = acClassModule Then
        ModArt = "Class Module"
    Else
        ModArt = "Module"
    End If
    DoCmd.Close acModule, ModName, acSaveNo
    DoCmd.Echo True

End Function

'Form Makro Report Form Tabelle

Function RestIns(Optional ByVal XLoesch As Boolean = True)
'XLoesch = True - Bestehende Tabelle wird vorher gelöscht
'XLoesch = False - Bestehende Einträge werden nicht verändert (nur hinzufügen)

Dim Krit As String, nix

    If Not table_exist("_int_tblObjektNamen") Then
        nix = FuncTableCreate("_int_tblObjektNamen")
    End If
  
If XLoesch Then
    Krit = "DELETE * FROM _int_tblObjektNamen;"
    CurrentDb.Execute (Krit)
End If
  
    Krit = "INSERT INTO _int_tblObjektNamen ( ModulName, Art, FunktionsArt, FunktionsName, MBF ) "
    Krit = Krit & " SELECT qrymdbForm.ObjName, 'Formulare' AS Ausdr1, ' ' AS Ausdr2, ' ' AS Ausdr3, False AS Ausdr4 "
    Krit = Krit & " FROM qrymdbForm;"
    CurrentDb.Execute (Krit)
    
    Krit = "INSERT INTO _int_tblObjektNamen ( ModulName, Art, FunktionsArt, FunktionsName, MBF ) "
    Krit = Krit & " SELECT qrymdbMacro.ObjName, 'Makros' AS Ausdr1, ' ' AS Ausdr2, ' ' AS Ausdr3, False AS Ausdr4 "
    Krit = Krit & " FROM qrymdbMacro;"
    CurrentDb.Execute (Krit)
    
    Krit = "INSERT INTO _int_tblObjektNamen ( ModulName, Art, FunktionsArt, FunktionsName, MBF ) "
    Krit = Krit & " SELECT qrymdbQuery.ObjName, 'Abfragen' AS Ausdr1, ' ' AS Ausdr2, ' ' AS Ausdr3, False AS Ausdr4 "
    Krit = Krit & " FROM qrymdbQuery;"
    CurrentDb.Execute (Krit)
    
    Krit = "INSERT INTO _int_tblObjektNamen ( ModulName, Art, FunktionsArt, FunktionsName, MBF ) "
    Krit = Krit & " SELECT qrymdbReport.ObjName, 'Berichte' AS Ausdr1, ' ' AS Ausdr2, ' ' AS Ausdr3, False AS Ausdr4 "
    Krit = Krit & " FROM qrymdbReport;"
    CurrentDb.Execute (Krit)
    
    Krit = "INSERT INTO _int_tblObjektNamen ( ModulName, Art, FunktionsArt, FunktionsName, MBF ) "
    Krit = Krit & " SELECT qrymdbTable.ObjName, 'Tabellen' AS Ausdr1, Nz(qrymdbTable.Database, ' ') AS Ausdr2, ' ' AS Ausdr3, False AS Ausdr4 "
    Krit = Krit & " FROM qrymdbTable;"
    CurrentDb.Execute (Krit)

    Krit = "INSERT INTO _int_tblObjektNamen ( ModulName, Art, FunktionsArt, FunktionsName, MBF ) "
    Krit = Krit & " SELECT qrymdbModul.ObjName, 'Module' AS Ausdr1, ' ' AS Ausdr2, ' ' AS Ausdr3, False AS Ausdr4 "
    Krit = Krit & " FROM qrymdbModul;"
    CurrentDb.Execute (Krit)

    Krit = "INSERT INTO _int_tblObjektNamen ( ModulName, Art, FunktionsArt, FunktionsName, MBF ) "
    Krit = Krit & " SELECT qrymdbQueryIntern.ObjName, 'Interne Abfragen' AS Ausdr1, ' ' AS Ausdr2, ' ' AS Ausdr3, False AS Ausdr4 "
    Krit = Krit & " FROM qrymdbQueryIntern;"
    CurrentDb.Execute (Krit)
    
    ''qrymdb_Anzahl_Objekte
    Krit = "SELECT [_int_tblObjektNamen].Art, Count([_int_tblObjektNamen].ID) AS AnzahlvonID FROM _int_tblObjektNamen GROUP BY [_int_tblObjektNamen].Art;"
    Call CreateQuery(Krit, "qrymdb_Anzahl_Objekte")

End Function


Function FuncTableCreate(strTable As String) As Boolean
'-------------------------
'Purpose:  Creates A new table and sets field format
'Accepts:  strTable, the name of the new table
'Returns:  True (-1) on success, False on failure
'-------------------------

'Function provided by ATTAC Consulting Group, Ann Arbor, MI  USA

On Error GoTo ErrCT

Dim TDB As DAO.Database
Dim fld(18) As field
Dim fFormat2 As Property, fFormat3 As Property, fFormat4 As Property
Dim idxTbl As Index
Dim idxfld As field
Dim Newtbl As TableDef
Dim Newtbl2 As TableDef

FuncTableCreate = True

'First Create the table

Set TDB = CurrentDb()
Set Newtbl = TDB.CreateTableDef(strTable)

'                                           FeldTyp        Feldattribute
'Tabellenname        Feldname           FldNr         FeldTypNr   Feldgroesse   Feldbeschreibung
'_int_tblObjektNamen   ID                 1   Long Integer    4   17  4           Autowert und Primary Key
'_int_tblObjektNamen   Art                2   Text            10  2   50
'_int_tblObjektNamen   ModulName          3   Text            10  2   250
'_int_tblObjektNamen   FunktionsArt       4   Text            10  2   50
'_int_tblObjektNamen   FunktionsName      5   Text            10  2   250
'_int_tblObjektNamen   FunktionsParam     6   Memo            12  2   0
'_int_tblObjektNamen   FunktionsRueck     7   Text            10  2   250
'_int_tblObjektNamen   Priv               8   Yes/No          1   1   1
'_int_tblObjektNamen   Tabelle1           9   Text            10  2   50
'_int_tblObjektNamen   Tabelle2           10  Text            10  2   50
'_int_tblObjektNamen   bspFormular        11  Text            10  2   50
'_int_tblObjektNamen   Frage              12  Text            10  2   250
'_int_tblObjektNamen   Beschreibung       13  Text            10  2   255
'_int_tblObjektNamen   Herkunft           14  Text            10  2   50
'_int_tblObjektNamen   VersionsNr         15  Text            10  2   10
'_int_tblObjektNamen   MBF                16  Yes/No          1   1   1
'_int_tblObjektNamen   DemoFormName       17  Text            10  2   250
'_int_tblObjektNamen   VerDatum           18  Date/Time       8   1   8

'ID
Set fld(1) = Newtbl.CreateField("ID", dbLong)
fld(1).Attributes = fld(1).Attributes Or dbAutoIncrField
Newtbl.fields.append fld(1)

'Art
Set fld(2) = Newtbl.CreateField("Art", dbText, 50)
Newtbl.fields.append fld(2)

'ModulName
Set fld(3) = Newtbl.CreateField("ModulName", dbText, 250)
Newtbl.fields.append fld(3)

'FunktionsArt
Set fld(4) = Newtbl.CreateField("FunktionsArt", dbText, 50)
Newtbl.fields.append fld(4)

'FunktionsName
Set fld(5) = Newtbl.CreateField("FunktionsName", dbText, 250)
Newtbl.fields.append fld(5)

'FunktionsParam
Set fld(6) = Newtbl.CreateField("FunktionsParam", dbMemo)
Newtbl.fields.append fld(6)

'FunktionsRueck
Set fld(7) = Newtbl.CreateField("FunktionsRueck", dbText, 250)
Newtbl.fields.append fld(7)

'Priv
Set fld(8) = Newtbl.CreateField("Priv", dbBoolean)
Newtbl.fields.append fld(8)

'Tabelle1
Set fld(9) = Newtbl.CreateField("Tabelle1", dbText, 50)
Newtbl.fields.append fld(9)

'Tabelle2
Set fld(10) = Newtbl.CreateField("Tabelle2", dbText, 50)
Newtbl.fields.append fld(10)

'bspFormular
Set fld(11) = Newtbl.CreateField("bspFormular", dbText, 50)
Newtbl.fields.append fld(11)

'Frage
Set fld(12) = Newtbl.CreateField("Frage", dbText, 250)
Newtbl.fields.append fld(12)

'Beschreibung
Set fld(13) = Newtbl.CreateField("Beschreibung", dbMemo)
Newtbl.fields.append fld(13)

'Herkunft
Set fld(14) = Newtbl.CreateField("Herkunft", dbText, 50)
Newtbl.fields.append fld(14)

'VersionsNr
Set fld(15) = Newtbl.CreateField("VersionsNr", dbText, 10)
Newtbl.fields.append fld(15)

'MBF
Set fld(16) = Newtbl.CreateField("MBF", dbBoolean)
Newtbl.fields.append fld(16)

'DemoFormName
Set fld(17) = Newtbl.CreateField("DemoFormName", dbText, 250)
Newtbl.fields.append fld(17)

'VerDatum
Set fld(18) = Newtbl.CreateField("VerDatum", dbDate)
Newtbl.fields.append fld(18)

TDB.TableDefs.append Newtbl

'Create an index for our table.  Need to use a new tabledef
'object for the table or it doesn't work

Set Newtbl2 = TDB.TableDefs(strTable)
Set idxTbl = Newtbl2.CreateIndex("PrimaryKey")
idxTbl.Primary = -1
idxTbl.Unique = -1
Set idxfld = idxTbl.CreateField("Art")
idxTbl.fields.append idxfld
Set idxfld = idxTbl.CreateField("ModulName")
idxTbl.fields.append idxfld
Set idxfld = idxTbl.CreateField("FunktionsArt")
idxTbl.fields.append idxfld
Set idxfld = idxTbl.CreateField("FunktionsName")
idxTbl.fields.append idxfld

Newtbl2.Indexes.append idxTbl

TDB.Close
Set TDB = Nothing
    
ExitCT:
    Exit Function
ErrCT:
    If Err <> 91 Then
        MsgBox "Fehler Nr: " & Err.Number & " " & Err.description
        TDB.Close
    End If
    FuncTableCreate = False
    Resume ExitCT
End Function


Function FuncTableCreate_Qry(strTable As String) As Boolean

'-------------------------
'Purpose:  Creates A new table and sets field format
'Accepts:  strTable, the name of the new table
'Returns:  True (-1) on success, False on failure
'-------------------------

'Function provided by ATTAC Consulting Group, Ann Arbor, MI  USA

On Error GoTo ErrCT

Dim TDB As DAO.Database
Dim fld(18) As field
Dim fFormat2 As Property, fFormat3 As Property, fFormat4 As Property
Dim idxTbl As Index
Dim idxfld As field
Dim Newtbl As TableDef
Dim Newtbl2 As TableDef

FuncTableCreate_Qry = True

'First Create the table

Set TDB = CurrentDb()
Set Newtbl = TDB.CreateTableDef(strTable)

'                                           FeldTyp        Feldattribute
'Tabellenname        Feldname           FldNr         FeldTypNr   Feldgroesse   Feldbeschreibung
'_int_tblObjektNamen   ID                 1   Long Integer    4   17  4           Autowert und Primary Key
'_int_tblObjektNamen   Art                2   Text            10  2   50
'_int_tblObjektNamen   ModulName          3   Text            10  2   250
'_int_tblObjektNamen   FunktionsArt       4   Text            10  2   50
'_int_tblObjektNamen   FunktionsName      5   Text            10  2   250
'_int_tblObjektNamen   FunktionsParam     6   Memo            12  2   0
'_int_tblObjektNamen   FunktionsRueck     7   Text            10  2   250
'_int_tblObjektNamen   Priv               8   Yes/No          1   1   1
'_int_tblObjektNamen   Tabelle1           9   Text            10  2   50
'_int_tblObjektNamen   Tabelle2           10  Text            10  2   50
'_int_tblObjektNamen   bspFormular        11  Text            10  2   50
'_int_tblObjektNamen   Frage              12  Text            10  2   250
'_int_tblObjektNamen   Beschreibung       13  Text            10  2   255
'_int_tblObjektNamen   Herkunft           14  Text            10  2   50
'_int_tblObjektNamen   VersionsNr         15  Text            10  2   10
'_int_tblObjektNamen   MBF                16  Yes/No          1   1   1
'_int_tblObjektNamen   DemoFormName       17  Text            10  2   250
'_int_tblObjektNamen   VerDatum           18  Date/Time       8   1   8


'Qry_Name
Set fld(1) = Newtbl.CreateField("Qry_Name", dbText, 250)
Newtbl.fields.append fld(1)

'FunktionsParam
Set fld(2) = Newtbl.CreateField("qry_SQL", dbMemo)
Newtbl.fields.append fld(2)

TDB.TableDefs.append Newtbl

'Create an index for our table.  Need to use a new tabledef
'object for the table or it doesn't work

Set Newtbl2 = TDB.TableDefs(strTable)
Set idxTbl = Newtbl2.CreateIndex("PrimaryKey")
idxTbl.Primary = -1
idxTbl.Unique = -1
Set idxfld = idxTbl.CreateField("Qry_Name")
idxTbl.fields.append idxfld

Newtbl2.Indexes.append idxTbl

TDB.Close
Set TDB = Nothing

ExitCT:
    Exit Function
ErrCT:
    If Err <> 91 Then
        MsgBox "Fehler Nr: " & Err.Number & " " & Err.description
        TDB.Close
    End If
    FuncTableCreate_Qry = False
    Resume ExitCT
End Function

Function TblInfo_AllTab()

Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim tblname As String, nix

Set db = CurrentDb
Set rst = db.OpenRecordset("SELECT ModulName FROM _int_tblObjektNamen WHERE (Art='Tabellen');", dbOpenDynaset)

With rst
    .MoveFirst
    
    Do While Not .EOF
  '      .Edit

        tblname = Nz(.fields(0))
        nix = TableInfoCreate(tblname)

        .MoveNext
    Loop
    
    .Close
End With

Set rst = Nothing
Set db = Nothing

End Function


Function TableInfoCreate(strTableName As String)
   ' Alison Brown / geändert: KObd
   ' Purpose: Print in the immediate window the field names, types, and sizes for any table.
   ' Argument: name of a table in the current database.
   Dim db As DAO.Database, tdf As TableDef, i As Integer, j As Integer
   Dim fldnam As String, fldtyp As String, fldtypNr As Integer, fldsiz As Integer, flddes As String
   Dim Krit As String, fldatt As String
   Dim prp As Properties, nix, rst
   Dim idxLoop As Index, idxfld As field
    
   On Error GoTo TableInfoErr1
   
   Set db = DBEngine(0)(0)
   Set tdf = db.TableDefs(strTableName)
                
'   If Not AccessEigenschaftEinstellen(tdf, "Description", dbText, False) Then
'       MsgBox "Adding Description Property to tables did not work"
'       Exit Function
'   End If
   
    Krit = "DELETE * "
    Krit = Krit & " From _int_tblTabellenBeschreibung"
    Krit = Krit & " WHERE (Tabellenname= '" & strTableName & "');"
    
    Set rst = db.CreateQueryDef("", Krit)
    rst.Execute
   
    Set rst = Nothing
    Set rst = db.OpenRecordset("SELECT * FROM _int_tblTabellenBeschreibung;", dbOpenDynaset)
         
    For i = 0 To tdf.fields.Count - 1
        
        fldnam = tdf.fields(i).Name
        fldtypNr = tdf.fields(i).Type
        fldtyp = FieldType(tdf.fields(i).Type)
        fldatt = Nz(tdf.fields(i).Attributes)
        fldsiz = tdf.fields(i).size
            On Error Resume Next
            Err.clear
        flddes = ""
        flddes = tdf.fields(i).Properties("Description")
            On Error GoTo TableInfoErr1
        
        rst.AddNew
            rst.fields("Tabellenname") = strTableName
            rst.fields("Feldname") = fldnam
            rst.fields("FldNr") = i + 1
            rst.fields("IsIndex") = False
            rst.fields("FeldTyp") = fldtyp
            rst.fields("FeldTypNr") = fldtypNr
            rst.fields("Feldattribute") = fldatt
            rst.fields("Feldgroesse") = fldsiz
            If Len(Trim(Nz(flddes))) > 0 Then
                rst.fields("Feldbeschreibung") = flddes
            End If
        rst.update
   
   Next i
   
'No idea, what´s going wrong here ...

'   For Each idxLoop In tdf.Indexes
'      Debug.Print "    " & idxLoop.Name
'
'        J = 0
'        For Each idxfld In idxLoop
'              Debug.Print "             " & idxfld.Name
'            J = J + 1
'            rst.AddNew
'                rst.Fields("Tabellenname") = strTableName
'                rst.Fields("Indexname") = idxLoop.Name
'                rst.Fields("IsIndex") = True
'                rst.Fields("Feldname") = idxfld.Name
'                rst.Fields("FldNr") = J
'            rst.Update
'
'        Next idxfld
'
'   Next idxLoop
'
TableInfoExit:

rst.Close
db.Close
   
Set rst = Nothing
Set db = Nothing
      
   Exit Function

TableInfoErr1:
Select Case Err
   Case 3022    ' Tabelle / Feld existiert bereits
        Resume Next
   Case 3265   ' Supplied table name invalid
       MsgBox strTableName & " table doesn't exist"
       Resume TableInfoExit
   Case Else
       Debug.Print "TableInfo() Error " & Err & ": " & Error
   End Select
   End Function


Function DescTableCreate(strTable As String) As Boolean
'-------------------------
'Purpose:  Creates A new table and sets field format
'Accepts:  strTable, the name of the new table
'Returns:  True (-1) on success, False on failure
'-------------------------
'When you are creating a table using code you may want to set a field's format
'or number of decimal places.
'Alternately if you run a make table query using already formated fields as an
'input, you will find that the new table does not carry over the formatting of
'your input fields. Therefore in each situation, you need to set the format for
'the field.
'
'The format and decimal places properties of a field do not exist until they are
'created, so if you query a field's "format" property before it is created, you'll
'get an error saying there is no such property. So here's some code which creates
'a simple table, and then sets the format and decimal places properties for a couple
'of fields. You can strip out the code for the format section to create a new
'function for setting the format for a table after running a make table query.

'Function provided by ATTAC Consulting Group, Ann Arbor, MI  USA

On Error GoTo ErrCT

Dim TDB As DAO.Database
Dim fld1 As field, fld2 As field, fld3 As field, fld4 As field, fld5 As field, fld6 As field, fld7 As field, fld8 As field, fld9 As field, fld10 As field
Dim fFormat2 As Property, fFormat3 As Property, fFormat4 As Property
Dim idxTbl As Index
Dim idxfld As field
Dim Newtbl As TableDef
Dim Newtbl2 As TableDef

DescTableCreate = True

'First Create the table

Set TDB = CurrentDb()
Set Newtbl = TDB.CreateTableDef(strTable)

'Tabellenname
Set fld2 = Newtbl.CreateField("Tabellenname", dbText, 250)
Newtbl.fields.append fld2

'Feldname
Set fld3 = Newtbl.CreateField("Feldname", dbText, 250)
Newtbl.fields.append fld3

'Indexname
Set fld9 = Newtbl.CreateField("Indexname", dbText, 250)
Newtbl.fields.append fld9

'IsIndex
Set fld10 = Newtbl.CreateField("IsIndex", dbBoolean)
Newtbl.fields.append fld10

'FeldNr
Set fld1 = Newtbl.CreateField("FldNr", dbSingle)
'fld1.Attributes = fld1.Attributes Or dbAutoIncrField
Newtbl.fields.append fld1

'Feldtyp
Set fld4 = Newtbl.CreateField("FeldTyp", dbText, 25)
Newtbl.fields.append fld4

'FeldtypNr
Set fld7 = Newtbl.CreateField("FeldTypNr", dbSingle)
Newtbl.fields.append fld7

'Feldattribute
Set fld8 = Newtbl.CreateField("Feldattribute", dbText, 50)
Newtbl.fields.append fld8

'Feldgröße
Set fld5 = Newtbl.CreateField("Feldgroesse", dbSingle)
Newtbl.fields.append fld5

'Feldbeschreibung
Set fld6 = Newtbl.CreateField("Feldbeschreibung", dbText, 250)
Newtbl.fields.append fld6

TDB.TableDefs.append Newtbl

'Create an index for our table.  Need to use a new tabledef
'object for the table or it doesn't work

Set Newtbl2 = TDB.TableDefs(strTable)
Set idxTbl = Newtbl2.CreateIndex("PrimaryKey")
idxTbl.Primary = -1
idxTbl.Unique = -1
'Set idxFld = idxTbl.CreateField("IDTbl")
'idxTbl.Fields.Append idxFld
Set idxfld = idxTbl.CreateField("Tabellenname")
idxTbl.fields.append idxfld
Set idxfld = idxTbl.CreateField("Feldname")
idxTbl.fields.append idxfld

Newtbl2.Indexes.append idxTbl

' To add any comment to a field ("Beschreibung" hinzufügen)

Set fFormat4 = fld1.CreateProperty("Description", dbText, "Autowert und Primary Key")
fld1.Properties.append fFormat4
Set fFormat4 = fld2.CreateProperty("Description", dbText, "Tabellenname")
fld2.Properties.append fFormat4
Set fFormat4 = fld3.CreateProperty("Description", dbText, "Feldname")
fld3.Properties.append fFormat4
Set fFormat4 = fld4.CreateProperty("Description", dbText, "Feldtyp")
fld4.Properties.append fFormat4
Set fFormat4 = fld5.CreateProperty("Description", dbText, "Feldgröße")
fld5.Properties.append fFormat4
Set fFormat4 = fld6.CreateProperty("Description", dbText, "Feldbeschreibung")
fld6.Properties.append fFormat4
Set fFormat4 = fld7.CreateProperty("Description", dbText, "Nr des Feldtyps")
fld7.Properties.append fFormat4
Set fFormat4 = fld8.CreateProperty("Description", dbText, "Feldattribut")
fld8.Properties.append fFormat4

TDB.Close
Set TDB = Nothing
    
ExitCT:
    Exit Function
ErrCT:
    If Err <> 91 Then TDB.Close
    DescTableCreate = False
    Resume ExitCT
End Function

Private Function FieldType(n) As String
   ' Korrigierte Version
   ' Purpose: Converts the numeric results of DAO fieldtype to Text.
   Select Case n
   Case dbBoolean
        FieldType = "Yes/No"        '1
   Case dbByte
        FieldType = "Byte"          '2
   Case dbInteger
      FieldType = "Integer"         '3
   Case dbLong
      FieldType = "Long Integer"    '4
   Case dbCurrency
      FieldType = "Currency"        '5
   Case dbSingle
      FieldType = "Single"          '6
   Case dbDouble
      FieldType = "Double"          '7
    Case dbDate
      FieldType = "Date/Time"       '8
    Case dbText
      FieldType = "Text"            '10
    Case dbLongBinary
      FieldType = "OLE Object"      '11
    Case dbMemo
      FieldType = "Memo"            '12
    Case Else
      FieldType = "Unknown Type: " & n
   End Select
   
   End Function

Private Function AccessEigenschaftEinstellen(obj As Object, strName As String, _
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

Private Function table_exist(tableName As String) As Boolean
'**********************************************************************************
'Function Table_Exist()
'Prüft, ob die Tabelle in der MDB vorhanden ist
'auch für eingebundene Tabellen oder Queries
'
'Rückgabe: TRUE, tbl ist vorhanden oder eingebunden
'          FALSE, tbl ist nicht vorhanden
'**********************************************************************************

Dim db As DAO.Database
Dim tbl As DAO.Recordset
Dim nix

On Error GoTo table_exist_error

    Set db = CurrentDb
    Set tbl = db.OpenRecordset(tableName)
    table_exist = True
    Set tbl = Nothing
    Exit Function

table_exist_error:
    table_exist = False
    Set tbl = Nothing
    Exit Function

End Function

'==========================================================================================================================================

Private Function ArrFill_DAO_Acc(ByVal recsetSQL As String, ByRef iZLMax As Long, ByRef iColMax As Long, ByRef DAOARRAY) As Boolean

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
    Set rst = db.OpenRecordset(recsetSQL)
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


Function Auswert2()

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
Dim dbpfadname As String
Dim dbname As String
Dim strSQL As String

recsetSQL1 = "tblDBNamen"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
''Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
    CurrentDb.Execute ("DELETE * FROM _int_tblFrmFeldnamen_Alle;")
    CurrentDb.Execute ("DELETE * FROM _int_tblObjektNamen_Alle;")
    CurrentDb.Execute ("DELETE * FROM _int_tblTabellenBeschreibung_Alle;")
    
    For iZl = 0 To iZLMax1
    
    
        dbpfadname = DAOARRAY1(1, iZl)
        dbname = DAOARRAY1(2, iZl)
        If table_exist("_int_tblFrmFeldnamen") Then
            DoCmd.DeleteObject acTable, "_int_tblFrmFeldnamen"
        End If
        If table_exist("_int_tblObjektNamen") Then
            DoCmd.DeleteObject acTable, "_int_tblObjektNamen"
        End If
        If table_exist("_int_tblTabellenBeschreibung") Then
            DoCmd.DeleteObject acTable, "_int_tblTabellenBeschreibung"
        End If
        
        DoCmd.TransferDatabase acImport, "Microsoft Access", _
            dbpfadname, acTable, "_int_tblFrmFeldnamen", "_int_tblFrmFeldnamen"
        DoCmd.TransferDatabase acImport, "Microsoft Access", _
            dbpfadname, acTable, "_int_tblObjektNamen", "_int_tblObjektNamen"
        DoCmd.TransferDatabase acImport, "Microsoft Access", _
            dbpfadname, acTable, "_int_tblTabellenBeschreibung", "_int_tblTabellenBeschreibung"
                       
        strSQL = ""
        strSQL = "INSERT INTO _int_tblFrmFeldnamen_Alle ( dbname, frmTyp, frmName, ControlName, ControlTypeID, ControlType, IsVisible, ControlCaption ) SELECT '"
        strSQL = strSQL & dbname
        strSQL = strSQL & "' AS Ausdr1, frmTyp, frmName, ControlName, ControlTypeID, ControlType , IsVisible, ControlCaption FROM _int_tblFrmFeldnamen;"
        If CreateQuery(strSQL, "insFeldName") Then
            CurrentDb.Execute ("insFeldName")
        End If
        
        strSQL = ""
        strSQL = "INSERT INTO _int_tblObjektNamen_Alle ( dbname, Art, ModulName, FunktionsArt, FunktionsName, FunktionsParam, FunktionsRueck, Priv, Tabelle1, Tabelle2, bspFormular, Frage, Beschreibung, Herkunft, VersionsNr, MBF, DemoFormName, VerDatum ) SELECT '"
        strSQL = strSQL & dbname
        strSQL = strSQL & "' AS Ausdr1, Art, ModulName, FunktionsArt, FunktionsName, FunktionsParam, FunktionsRueck, Priv, Tabelle1, Tabelle2, bspFormular, Frage, Beschreibung, Herkunft, VersionsNr, MBF, DemoFormName, VerDatum FROM _int_tblObjektNamen;"
        If CreateQuery(strSQL, "insObjektnamen") Then
            CurrentDb.Execute ("insObjektnamen")
        End If
        
        strSQL = ""
        strSQL = "INSERT INTO _int_tblTabellenBeschreibung_Alle ( dbname, Tabellenname, Feldname, Indexname, IsIndex, FldNr, FeldTyp, FeldTypNr ) SELECT '"
        strSQL = strSQL & dbname
        strSQL = strSQL & "' AS Ausdr1, Tabellenname, Feldname, Indexname, IsIndex, FldNr, FeldTyp, FeldTypNr FROM _int_tblTabellenBeschreibung;"
        If CreateQuery(strSQL, "insTabellenBeschreibung") Then
            CurrentDb.Execute ("insTabellenBeschreibung")
        End If
    Next iZl
    
    If table_exist("_int_tblFrmFeldnamen") Then
        DoCmd.DeleteObject acTable, "_int_tblFrmFeldnamen"
    End If
    If table_exist("_int_tblObjektNamen") Then
        DoCmd.DeleteObject acTable, "_int_tblObjektNamen"
    End If
    If table_exist("_int_tblTabellenBeschreibung") Then
        DoCmd.DeleteObject acTable, "_int_tblTabellenBeschreibung"
    End If
    
    Set DAOARRAY1 = Nothing
End If

End Function

Function qry_QueryMain_Fill()
Dim dbs As DAO.Database
Dim i As Integer
Dim j As Integer
Dim strPath As String

Dim rst As DAO.Recordset
strPath = DBPfad()

CurrentDb.Execute ("DELETE * FROM _int_tblQueryMain;")
DoEvents

Set dbs = CurrentDb() ' use CurrentDb() to refresh Collections

Set rst = dbs.OpenRecordset("SELECT * FROM _int_tblQueryMain;")

'Call Path_erzeugen(strPath & "qry\")

Debug.Print "Anzahl Queries: " & dbs.QueryDefs.Count
For i = 0 To dbs.QueryDefs.Count - 1
    rst.AddNew
        rst.fields(0) = dbs.QueryDefs(i).Name
        rst.fields(1) = dbs.QueryDefs(i).sql
    rst.update

'' Um für jede Abfrage eine Text-Datei zu erzeugen
''Abfrage wird in Dir Qry der Datenbank erzeugt
''================================================
'    Application.SaveAsText acQuery, Dbs.QueryDefs(I).Name, strPath & "qry\" & Dbs.QueryDefs(I).Name & ".txt"
'    If I Mod 200 = 0 Then
'        Debug.Print I
'        DoEvents
'    End If
''################################################
Next i

rst.Close
Set rst = Nothing

End Function


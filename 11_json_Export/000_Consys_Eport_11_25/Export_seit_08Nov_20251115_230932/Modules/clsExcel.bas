Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'---------------------------------------------------------------------------------------
' Klassenmodul    : clsExcel
' DateTime        : 25.10.2007 20:33
' Author          : Klaus Oberdalhoff
' Purpose         : Diverse Excel-Funktionen (Sammelsurium) als Klasse zusammengefasst
'---------------------------------------------------------------------------------------
Option Compare Database
Option Explicit


'Diese Tabellen können nur aus dem VBA-Editor direkt oder per VBA wieder eingeblendet werden.
'per VBA über Sheets("Name_des_Blattes").Visible = xlVeryHidden - siehe als Ansatz dazu Arbeitsblatt ausblenden.
'Sheets("Tabelle1").Visible =  xlVeryHidden  =  2
'Sheets("Tabelle1").Visible = True

'ActiveSheet.Name = "Date (altered)"
'If you are renaming the first sheet use:
'Sheets(1).Name = "Date (altered)"
'If you are renaming a sheet with a specific name use:
'Sheets("Sheet1").Name = "Date (altered)"


' Benötigt die Klasse FileDialog
' ##############################
   
    Const xlMaximized As Long = -4137
    Const xlMinimized As Long = -4140
    Const xlNormal = -4143
    
    Const xlUp = -4162
    Const xlToLeft = -4159
    Const xlToRight = -4161
    Const xlDown = -4121
    
    Dim m_xlObj As Object
    Dim m_objActiveWkb As Object
    Dim m_objActSheet As Object
    Dim m_objActRange As Object
    Dim m_Sheetnames As Variant
    
'Ein Dummy ....
Dim m_FarbNoMatrix

    Dim m_NewWkb As Object
    
    Dim m_xl_ForeignOpen As Boolean
    Dim m_IsDirty As Boolean

    Dim m_xl_Col As Long
    Dim m_xl_Row As Long

    Dim m_xl_RowStart As Long
    Dim m_xl_ColStart As Long
    
    Dim m_xl_RowEnd As Long
    Dim m_xl_ColEnd As Long
       
    Dim m_xl_RdOnly As Boolean
    Dim m_SheetVersion As String

    Dim m_WkbDateiname As String

    Dim m_Actual_Sheet_No As Long
    '
    
Public Property Get xlSheetnameTable() As Object
    If Not IsArray(m_Sheetnames) Then
        SheetNames_read
    End If
    Set xlSheetnameTable = m_Sheetnames
End Property
   
Public Property Get xlSheetCount() As Integer
    xlSheetCount = m_objActiveWkb.Sheets.Count
End Property
   
Public Property Get xlSheetnameNum(Optional si As Variant) As Variant
    Dim i As Long
    If Not IsArray(m_Sheetnames) Then
        SheetNames_read
    End If
    If Len(Trim(Nz(si))) = 0 Then
        xlSheetnameNum = m_Sheetnames(1)
    ElseIf IsNumeric(si) And si <= UBound(m_Sheetnames) Then
        xlSheetnameNum = m_Sheetnames(si)
    Else
        xlSheetnameNum = -1
        For i = 1 To UBound(m_Sheetnames)
            If m_Sheetnames(i) = si Then
                xlSheetnameNum = i
                Exit For
            End If
        Next i
    End If
End Property

Private Function SheetNames_read()
Dim i As Long

ReDim m_Sheetnames(1)
For i = 1 To m_objActiveWkb.Sheets.Count
    ReDim Preserve m_Sheetnames(i)
    m_Sheetnames(i) = m_objActiveWkb.Sheets(i).Name
Next i

End Function

Public Function xl_wkb_Close()
If Not m_objActiveWkb Is Nothing Then
    m_objActiveWkb.Close
    Set m_objActiveWkb = Nothing
End If
End Function
   

'---------------------------------------------------------------------------------------
' Procedure : XL_Wkb_Open_RDOnly
' DateTime  : 25.10.2007 22:22
' Author    : Klaus Oberdalhoff
' Purpose   : Workbook Read Only öffnen
'---------------------------------------------------------------------------------------
'
Public Function XL_Wkb_Open_RDOnly(strDateiname As String, Optional Pwd As String = "") As Object
    
    On Error GoTo 0
      
    m_WkbDateiname = strDateiname
    
    If Not File_exist(m_WkbDateiname) Then
        m_WkbDateiname = XLSSuch()
    End If
    
    If Not File_exist(m_WkbDateiname) Then
        MsgBox "Kein gültiger Dateiname"
        Exit Function
    End If

    If m_xlObj Is Nothing Then
        Set m_xlObj = xlObj()
    End If

    DoEvents
    Sleep 10
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents
    
    With m_xlObj
    '   .Workbooks.Add  'neue Tabelle erstellen
       .Workbooks.Open m_WkbDateiname, 0, True, , Pwd, Pwd
       .Application.DisplayAlerts = False
 '      .Application.ActiveWorkbook.RejectAllChanges
       
       Set m_objActiveWkb = .Application.ActiveWorkbook
       m_FarbNoMatrix = m_objActiveWkb.Colors
    End With
    
    DoEvents
    Sleep 10
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents
    
    m_xl_RdOnly = True
    m_IsDirty = False
           
    SheetNames_read
    Set XL_Wkb_Open_RDOnly = m_objActiveWkb

End Function


'---------------------------------------------------------------------------------------
' Procedure : XL_Wkb_Open_RDWR
' DateTime  : 25.10.2007 22:22
' Author    : Klaus Oberdalhoff
' Purpose   : Workbook Read Write öffnen
'---------------------------------------------------------------------------------------
'
Public Function XL_Wkb_Open_RDWR(strDateiname As String, Optional Pwd As String = "") As Object
    
    On Error GoTo 0
    
    m_WkbDateiname = strDateiname
    
    If Not File_exist(m_WkbDateiname) Then
        m_WkbDateiname = XLSSuch()
    End If
    
    If Not File_exist(m_WkbDateiname) Then
        MsgBox "Kein gültiger Dateiname"
        Exit Function
    End If

    If m_xlObj Is Nothing Then
        Set m_xlObj = xlObj()
    End If

    With m_xlObj
    '   .Workbooks.Add  'neue Tabelle erstellen
       .Workbooks.Open m_WkbDateiname, 3, False, , Pwd, Pwd
       .Application.DisplayAlerts = True
 '      .Application.ActiveWorkbook.RejectAllChanges
       
       Set m_objActiveWkb = .Application.ActiveWorkbook
    End With
    
    m_xl_RdOnly = False
    m_IsDirty = True
    
    m_FarbNoMatrix = m_objActiveWkb.Colors
    SheetNames_read
    Set XL_Wkb_Open_RDWR = m_objActiveWkb

End Function

'---------------------------------------------------------------------------------------
' Procedure : XL_Wkb_Add
' DateTime  : 25.10.2007 22:27
' Author    : Klaus Oberdalhoff
' Purpose   : Neues Workbook öffnen
'---------------------------------------------------------------------------------------
'
Public Function XL_Wkb_Add(Optional xlVorl As String) As Object
       
    Dim xlVorlage As String
       
    If m_xlObj Is Nothing Then
        Set m_xlObj = xlObj()
    End If

    xlVorlage = ""
    If Len(Trim(Nz(xlVorl))) > 0 Then
        If Len(Trim(Dir(xlVorl))) > 0 Then
            xlVorlage = xlVorl
        End If
    End If

    With m_xlObj
        If Len(Trim(Nz(xlVorlage))) > 0 Then
           .Workbooks.Add xlVorlage  'neue Tabelle mit Vorlage erstellen
        Else
           .Workbooks.Add  'neue Tabelle erstellen
        End If
    
       Set m_objActiveWkb = .Application.ActiveWorkbook
'       m_objActiveWkb.AcceptAllChanges ' set Excel file read write
       
       .Application.DisplayAlerts = True
    End With

    m_xl_RdOnly = False
    m_IsDirty = True
    
    SheetNames_read
    Set XL_Wkb_Add = m_objActiveWkb
    
End Function


'---------------------------------------------------------------------------------------
' Procedure : XL_actWkb_SaveAs
' DateTime  : 25.10.2007 22:22
' Author    : Klaus Oberdalhoff
' Purpose   : Workbook speichern unter
'---------------------------------------------------------------------------------------
'
Public Function XL_actWkb_SaveAs(strDateiname As String)
       
    Dim m_WkbDateiname1 As String
    Const xlOpenXMLWorkbookMacroEnabled As Long = 52
    
    m_WkbDateiname1 = Nz(strDateiname)
    If Len(Trim(Nz(strDateiname))) = 0 Then
        m_WkbDateiname1 = XLSSuchNeu()
    End If
       
    If File_exist(m_WkbDateiname1) Then
        If vbYes = MsgBox("Achtung, Datei existiert bereits, überschreiben (J/N)", vbQuestion + vbYesNo, strDateiname) Then
            Kill m_WkbDateiname1
        Else
            Exit Function
        End If
    End If
    
    If File_exist(m_WkbDateiname1) Then
        MsgBox "Fehler: Dateiname existiert"
        Exit Function
    End If
      
    If m_xlObj Is Nothing Then
        MsgBox "Fehler: Excel nicht offen"
        Exit Function
    End If
    
    If m_objActiveWkb Is Nothing Then
        MsgBox "Fehler: Excel-Workbook nicht offen"
        Exit Function
    End If
    
    m_objActiveWkb.SaveAs fileName:=m_WkbDateiname1, FileFormat:=xlOpenXMLWorkbookMacroEnabled
    
    m_WkbDateiname = m_WkbDateiname1
    m_IsDirty = False
       
End Function


'---------------------------------------------------------------------------------------
' Procedure : xlObj
' DateTime  : 25.10.2007 20:35
' Author    : Klaus Oberdalhoff
' Purpose   : Excel öffnen und Excel-Main-Objekt zurückgeben
'---------------------------------------------------------------------------------------
'
Public Property Get xlObj() As Object

If m_xlObj Is Nothing Then
    On Error Resume Next 'See if Excel is running
        
    Set m_xlObj = GetObject(, "Excel.Application")
     If err.Number <> 0 Then 'Excel Not running
       err.clear   ' Clear Err object in case error occurred.
       'Create a new instance of Excel
       Set m_xlObj = CreateObject("Excel.Application")
       'Wenn Excel noch nicht gestartet war True, sonst False
       m_xl_ForeignOpen = False
     Else
       'Activate instance of Excel
         m_xlObj.Activate
         m_xl_ForeignOpen = True
     End If
    
    With m_xlObj
        'Alle Excel Events unterbinden
        .EnableEvents = False
        .WindowState = xlMaximized
    '        .Visible = False
        .Visible = True
    End With
    
End If

Set xlObj = m_xlObj

On Error GoTo 0

End Property

Public Function XL_Visible(x As Boolean)
If m_xlObj Is Nothing Then
    Exit Function
End If
m_xlObj.Visible = x
End Function


'---------------------------------------------------------------------------------------
' Procedure : XL_Close
' DateTime  : 25.10.2007 20:37
' Author    : Klaus Oberdalhoff
' Purpose   : Excel schliessen
'---------------------------------------------------------------------------------------
'
Public Function XL_Close()

   On Error GoTo XL_Close_Error

On Error GoTo XL_Close_Err

If m_xlObj Is Nothing Then
    Exit Function
End If

If Not m_xl_RdOnly = True And Len(Trim(Nz(m_WkbDateiname))) > 0 And m_IsDirty = True Then
    m_objActiveWkb.Save
'    If Len(Trim(Nz(Dir(m_WkbDateiname)))) > 0 Then Kill m_WkbDateiname
'
''Wenn Excel von hier gestartet wurde (boolXL = True), Excel wieder schließen
''If boolXL = True Then xlObj.Application.Quit
'
'    m_objActiveWkb.SaveAs filename:=m_WkbDateiname
End If

XL_Close_Err:
On Error Resume Next

If Not m_objActiveWkb Is Nothing Then
    m_objActiveWkb.Close
    Set m_objActiveWkb = Nothing
End If

'Nur wenn Excel von hier gestartet wurde (m_xl_ForeignOpen = False), Excel wieder schließen
If m_xl_ForeignOpen = True Then
    With m_xlObj
        .Activate = True
        .Visible = True
        .Application.ScreenUpdating = True
        .DisplayAlerts = True
        .EnableEvents = True
        .WindowState = xlMaximized
    End With
    DoEvents
Else
    m_xlObj.Application.Quit
    Set m_xlObj = Nothing
    DoEvents
End If
On Error GoTo 0

   On Error GoTo 0
   Exit Function

XL_Close_Error:

    MsgBox "Error " & err.Number & " (" & err.description & ") in procedure XL_Close of Klassenmodul clsExcel"
End Function


'---------------------------------------------------------------------------------------
' Procedure : XL_Close
' DateTime  : 25.10.2007 20:37
' Author    : Klaus Oberdalhoff
' Purpose   : Excel schliessen
'---------------------------------------------------------------------------------------
'
Public Function XL_Close_Sure()

   On Error GoTo XL_Close_Error

On Error GoTo XL_Close_Err

If m_xlObj Is Nothing Then
    Exit Function
End If

If Not m_xl_RdOnly = True And Len(Trim(Nz(m_WkbDateiname))) > 0 And m_IsDirty = True Then
    m_objActiveWkb.Save
'    If Len(Trim(Nz(Dir(m_WkbDateiname)))) > 0 Then Kill m_WkbDateiname
'
''Wenn Excel von hier gestartet wurde (boolXL = True), Excel wieder schließen
''If boolXL = True Then xlObj.Application.Quit
'
'    m_objActiveWkb.SaveAs filename:=m_WkbDateiname
End If

XL_Close_Err:
On Error Resume Next

If Not m_objActiveWkb Is Nothing Then
    m_objActiveWkb.Close
    Set m_objActiveWkb = Nothing
End If

DoEvents
Sleep 120
DoEvents

    m_xlObj.Application.Quit
    Set m_xlObj = Nothing
    
    DoEvents
    Sleep 10
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents


On Error GoTo 0

   Exit Function

XL_Close_Error:

    MsgBox "Error " & err.Number & " (" & err.description & ") in procedure XL_Close of Klassenmodul clsExcel"
End Function


'---------------------------------------------------------------------------------------
' Procedure : Class_Program_Version
' DateTime  : 25.10.2007 20:35
' Author    : Klaus Oberdalhoff
' Purpose   : Version der Klasse zurückgeben
'---------------------------------------------------------------------------------------
'
Public Property Get Class_Program_Version() As String
    Class_Program_Version = "1.3.2.1 - 25.10.2007 - Autor: Klaus Oberdalhoff"
End Property


'---------------------------------------------------------------------------------------
' Procedure : xlAktWbk
' DateTime  : 25.10.2007 20:36
' Author    : Klaus Oberdalhoff
' Purpose   : Aktives Workbook-Objekt zurückgeben sofern bereits geöffnet
'---------------------------------------------------------------------------------------
'
Public Property Get xlAktWbk() As Object
If m_objActiveWkb Is Nothing Then
    MsgBox "Fehler: Erst Workbook öffnen"
Else
    Set xlAktWbk = m_objActiveWkb
End If
End Property



'---------------------------------------------------------------------------------------
' Procedure : SetRange
' DateTime  : 25.10.2007 20:37
' Author    : Klaus Oberdalhoff
' Purpose   : Aus Zeilen und Spaltennummern das aktuelle Range-Objekt setzen
'---------------------------------------------------------------------------------------
'
Public Function SetRange(iRow As Long, iCol As Long, IRowEnd As Long, IColEnd As Long) As Object
m_xl_RowStart = iRow
m_xl_RowEnd = IRowEnd
m_xl_ColStart = iCol
m_xl_ColEnd = IColEnd

Set m_objActRange = m_objActSheet.Range(m_objActSheet.Cells(m_xl_RowStart, m_xl_ColStart), _
                                        m_objActSheet.Cells(m_xl_RowEnd, m_xl_ColEnd))
Set SetRange = m_objActRange
End Function

'---------------------------------------------------------------------------------------
' Procedure : SetRangeRow
' DateTime  : 25.10.2007 20:37
' Author    : Klaus Oberdalhoff
' Purpose   : Aus Zeilen und Spaltennummern das aktuelle Range-Objekt setzen
'---------------------------------------------------------------------------------------
'
Public Function SetRangeRow(iRow As Long, IRowEnd As Long) As Object
m_xl_RowStart = iRow
m_xl_RowEnd = IRowEnd

Set m_objActRange = m_objActSheet.Range(m_objActSheet.rows(m_xl_RowStart), _
                                        m_objActSheet.rows(m_xl_RowEnd))
Set SetRangeRow = m_objActRange
End Function

'---------------------------------------------------------------------------------------
' Procedure : SetRangeToLastRow
' DateTime  : 25.10.2007 20:37
' Author    : Klaus Oberdalhoff
' Purpose   : Aus Zeilen und Spaltennummern das aktuelle Range-Objekt setzen
'---------------------------------------------------------------------------------------
'
Public Function SetRangeToLastRow(iRow As Long) As Object
m_xl_RowStart = iRow

Set m_objActRange = m_objActSheet.Range(m_objActSheet.rows(m_xl_RowStart), _
                                        m_objActSheet.rows(m_objActSheet.rows.Count))
Set SetRangeToLastRow = m_objActRange
End Function



'---------------------------------------------------------------------------------------
' Procedure : ActSheetRange
' DateTime  : 25.10.2007 20:39
' Author    : Klaus Oberdalhoff
' Purpose   : "Used Range" des aktuellen Sheets zurückgeben
'---------------------------------------------------------------------------------------
'
Public Property Get ActSheetRange() As Object
Dim i As Long, r As Long, c As Long, t As Long
For i = 1 To 256 '&H100&
    t = m_objActSheet.Cells(&H10000, i).End(xlUp).row
    If t > r Then r = t
    If t > 1 Then c = i
Next i
Set m_objActRange = SetRange(1, 1, r, c)
m_xl_RowStart = 1
m_xl_RowEnd = r
m_xl_ColStart = 1
m_xl_ColEnd = c
Set ActSheetRange = m_objActRange
End Property


'---------------------------------------------------------------------------------------
' Procedure : LastRow
' DateTime  : 25.10.2007 20:39
' Author    : Klaus Oberdalhoff
' Purpose   : Höchste/letzte Zeilennummer einer bestimmten Spalte zurückgeben
'---------------------------------------------------------------------------------------
'
Public Property Get lastRow(Optional col As Long = &H1&) As Long ' Letzte Reihe
If col < 1 Then col = 1
If col > &H100& Then col = &H100&
m_xl_RowEnd = m_objActSheet.Cells(&H10000, col).End(xlUp).row
lastRow = m_xl_RowEnd
End Property


'---------------------------------------------------------------------------------------
' Procedure : LastCol
' DateTime  : 25.10.2007 20:40
' Author    : Klaus Oberdalhoff
' Purpose   : Höchste/letzte Spaltennummer einer bestimmten Zeile zurückgeben
'---------------------------------------------------------------------------------------
'
Public Property Get lastCol(Optional row As Long = &H1&) As Long  ' Letzte Spalte
If row < 1 Then row = 1
If row > &H10000 Then row = &H10000
m_xl_ColEnd = m_objActSheet.Cells(row, &H100&).End(xlToLeft).Column
lastCol = m_xl_ColEnd
End Property


'---------------------------------------------------------------------------------------
' Procedure : Row
' DateTime  : 25.10.2007 22:09
' Author    : Klaus Oberdalhoff
' Purpose   : Aktive Reihen-Nr lesen
'---------------------------------------------------------------------------------------
'
Public Property Get row() As Long
row = m_xl_Row
End Property

'---------------------------------------------------------------------------------------
' Procedure : Row
' DateTime  : 25.10.2007 22:09
' Author    : Klaus Oberdalhoff
' Purpose   : Aktive Reihen-Nr setzen
'---------------------------------------------------------------------------------------
'
Public Property Let row(iRow As Long)
If iRow >= 0 And iRow < 65000 Then
    m_xl_Row = iRow
Else
    m_xl_Row = 0
End If
End Property


'---------------------------------------------------------------------------------------
' Procedure : Col
' DateTime  : 25.10.2007 22:10
' Author    : Klaus Oberdalhoff
' Purpose   : Aktive Spalten-Nr lesen
'---------------------------------------------------------------------------------------
'
Public Property Get col() As Long
col = m_xl_Col
End Property


'---------------------------------------------------------------------------------------
' Procedure : Col
' DateTime  : 25.10.2007 22:10
' Author    : Klaus Oberdalhoff
' Purpose   : Aktive Spalten-Nr setzen
'---------------------------------------------------------------------------------------
'
Public Property Let col(iCol As Long)
If iCol >= 0 And iCol < 257 Then
    m_xl_Col = iCol
Else
    m_xl_Col = 0
End If
End Property

'---------------------------------------------------------------------------------------
' Procedure : RowStart
' DateTime  : 25.10.2007 22:11
' Author    : Klaus Oberdalhoff
' Purpose   : StartReihen-Nr lesen
'---------------------------------------------------------------------------------------
'
Public Property Get RowStart() As Long
RowStart = m_xl_RowStart
End Property

'---------------------------------------------------------------------------------------
' Procedure : RowStart
' DateTime  : 25.10.2007 22:11
' Author    : Klaus Oberdalhoff
' Purpose   : StartReihen-Nr setzen
'---------------------------------------------------------------------------------------
'
Public Property Let RowStart(iRow As Long)
If iRow >= 0 And iRow < 65000 Then
    m_xl_RowStart = iRow
Else
    m_xl_RowStart = 0
End If
End Property

'---------------------------------------------------------------------------------------
' Procedure : ColStart
' DateTime  : 25.10.2007 22:12
' Author    : Klaus Oberdalhoff
' Purpose   : StartSpaltenNr lesen
'---------------------------------------------------------------------------------------
'
Public Property Get ColStart() As Long
ColStart = m_xl_ColStart
End Property

'---------------------------------------------------------------------------------------
' Procedure : ColStart
' DateTime  : 25.10.2007 22:12
' Author    : Klaus Oberdalhoff
' Purpose   : StartSpaltenNr setzen
'---------------------------------------------------------------------------------------
'
Public Property Let ColStart(iCol As Long)
If iCol >= 0 And iCol < 257 Then
    m_xl_ColStart = iCol
Else
    m_xl_ColStart = 0
End If
End Property

'---------------------------------------------------------------------------------------
' Procedure : RowEnd
' DateTime  : 25.10.2007 22:12
' Author    : Klaus Oberdalhoff
' Purpose   : Endezeilen-Nr lesen
'---------------------------------------------------------------------------------------
'
Public Property Get RowEnd() As Long
RowEnd = m_xl_RowEnd
End Property

'---------------------------------------------------------------------------------------
' Procedure : RowEnd
' DateTime  : 25.10.2007 22:12
' Author    : Klaus Oberdalhoff
' Purpose   : Endezeilen-Nr setzen
'---------------------------------------------------------------------------------------
'
Public Property Let RowEnd(iRow As Long)
If iRow >= 0 And iRow < 65000 Then
    m_xl_RowEnd = iRow
Else
    m_xl_RowEnd = 0
End If
End Property

'---------------------------------------------------------------------------------------
' Procedure : ColEnd
' DateTime  : 25.10.2007 22:13
' Author    : Klaus Oberdalhoff
' Purpose   : EndeSpalten-Nr lesen
'---------------------------------------------------------------------------------------
'
Public Property Get ColEnd() As Long
ColEnd = m_xl_ColEnd
End Property

'---------------------------------------------------------------------------------------
' Procedure : ColEnd
' DateTime  : 25.10.2007 22:13
' Author    : Klaus Oberdalhoff
' Purpose   : EndeSpalten-Nr setzen
'---------------------------------------------------------------------------------------
'
Public Property Let ColEnd(iCol As Long)
If iCol >= 0 And iCol < 257 Then
    m_xl_ColEnd = iCol
Else
    m_xl_ColEnd = 0
End If
End Property

'---------------------------------------------------------------------------------------
' Procedure : AktCell
' DateTime  : 25.10.2007 22:14
' Author    : Klaus Oberdalhoff
' Purpose   : Aktive Zelle aus Zeilen- und Spaltennr
'---------------------------------------------------------------------------------------
'
Public Property Get AktCell() As Object
Set AktCell = m_objActSheet.Range(GetCellAsStr(m_xl_Row, m_xl_Col))
End Property

'---------------------------------------------------------------------------------------
' Procedure : StartCell
' DateTime  : 25.10.2007 22:15
' Author    : Klaus Oberdalhoff
' Purpose   : Start Zelle aus Zeilen- und Spaltennr
'---------------------------------------------------------------------------------------
'
Public Property Get StartCell() As Object
Set StartCell = m_objActSheet.Range(GetCellAsStr(m_xl_RowStart, m_xl_ColStart))
End Property

'---------------------------------------------------------------------------------------
' Procedure : EndCell
' DateTime  : 25.10.2007 22:15
' Author    : Klaus Oberdalhoff
' Purpose   : Ende Zelle aus Zeilen- und Spaltennr
'---------------------------------------------------------------------------------------
'
Public Property Get EndCell() As Object
Set EndCell = m_objActSheet.Range(GetCellAsStr(m_xl_RowEnd, m_xl_ColEnd))
End Property

'---------------------------------------------------------------------------------------
' Procedure : ActSheet
' DateTime  : 25.10.2007 22:16
' Author    : Klaus Oberdalhoff
' Purpose   : Active Sheet Objekt
'---------------------------------------------------------------------------------------
'
Public Property Get ActSheet() As Object
If m_objActiveWkb Is Nothing Then
    MsgBox "Fehler: Erst Workbook öffnen"
Else
    If m_objActSheet Is Nothing Then
        Set m_objActSheet = m_objActiveWkb.Worksheets(1)
    End If
    m_objActSheet.Select
    Set ActSheet = m_objActSheet
End If
End Property

'---------------------------------------------------------------------------------------
' Procedure : SelectSheet
' DateTime  : 25.10.2007 22:16
' Author    : Klaus Oberdalhoff
' Purpose   : Sheet auswählen entweder via Zahl oder "Name"
'---------------------------------------------------------------------------------------
'
Public Function SelectSheet(Optional ByVal Sheet As Variant = 1) As Object
'Sheet kann Index (numerisch) oder Name (Text) sein

If m_objActiveWkb Is Nothing Then
    MsgBox "Fehler: Erst Workbook öffnen"
Else
    Set m_objActSheet = Nothing
    Set m_objActSheet = m_objActiveWkb.Worksheets(Sheet)
    m_objActSheet.Select
    If m_objActSheet Is Nothing Then
        MsgBox "Fehler: Kein Sheet vorhanden"
    End If
End If
Set SelectSheet = m_objActSheet
End Function

Public Function SelectSheet_Test(Optional ByVal Sheet As Variant = 1) As Boolean
Dim obj As Object
   On Error GoTo SelectSheet_Test_Error

SelectSheet_Test = False
Set obj = SelectSheet(Sheet)
SelectSheet_Test = True

   On Error GoTo 0
   Exit Function

SelectSheet_Test_Error:

SelectSheet_Test = False
    err.clear
    
    DoEvents
    Sleep 10
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents

End Function

'---------------------------------------------------------------------------------------
' Procedure : GetRangeFromActSheet
' DateTime  : 25.10.2007 22:17
' Author    : Klaus Oberdalhoff
' Purpose   : Range aus Start- und Ende Zeile- und Spaltennr
'---------------------------------------------------------------------------------------
'
Public Function GetRangeFromActSheet() As Object
Set GetRangeFromActSheet = m_objActSheet.Range(m_objActSheet.Cells(m_xl_RowStart, m_xl_ColStart), m_objActSheet.Cells(m_xl_RowEnd, m_xl_ColEnd))
End Function


'---------------------------------------------------------------------------------------
' Procedure : CellStr2RowCol
' DateTime  : 25.10.2007 22:18
' Author    : Klaus Oberdalhoff
' Purpose   : Umrechnen Rangewert eines Strings z.B. "C1:G7" in Start- und Ende Zeile- und Spalten-Nr
'---------------------------------------------------------------------------------------
'
Public Function CellStr2RowCol(Cell1 As String)
Dim i As Long
Dim j As Long
Dim iCol As Long
Dim iRowEnd_Start As Long
Dim strRow As String
Dim Cell As String

Cell = UCase(Cell1)
If Len(Trim(Nz(Cell))) = 0 Then Exit Function

strRow = ""
j = Len(Cell)
iRowEnd_Start = InStr(1, Cell, ":")
    
If iRowEnd_Start > 0 Then
    j = iRowEnd_Start - 1
    For i = 1 To j
        If IsNumeric(Mid(Cell, i, 1)) Then
            strRow = strRow & Mid(Cell, i, 1)
        Else
            iCol = iCol + (Asc(Mid(Cell, i, 1)) - 64)
        End If
    Next i
    m_xl_RowStart = CLng(strRow)
    m_xl_ColStart = iCol
    
    iCol = 0
    strRow = ""
    
    j = Len(Cell)
    For i = iRowEnd_Start + 1 To j
        If IsNumeric(Mid(Cell, i, 1)) Then
            strRow = strRow & Mid(Cell, i, 1)
        Else
            iCol = iCol + (Asc(Mid(Cell, i, 1)) - 64)
        End If
    Next i
    m_xl_RowEnd = CLng(strRow)
    m_xl_ColEnd = iCol
    
    iCol = 0
    strRow = ""
Else
    j = Len(Cell)
    For i = 1 To j
        If IsNumeric(Mid(Cell, i, 1)) Then
            strRow = strRow & Mid(Cell, i, 1)
        Else
            iCol = iCol + (Asc(Mid(Cell, i, 1)) - 64)
        End If
    Next i
    m_xl_Row = CLng(strRow)
    m_xl_Col = iCol
    
    iCol = 0
    strRow = ""

End If

End Function

'---------------------------------------------------------------------------------------
' Procedure : GetCellAsStr
' DateTime  : 25.10.2007 22:19
' Author    : Klaus Oberdalhoff
' Purpose   : Stringwert einer Zelle z.B: "C7" aus Zeilen- und Spalten-Nr
'---------------------------------------------------------------------------------------
'
Public Function GetCellAsStr(iRow As Long, iCol As Long) As String
If Not (iCol > 256 Or iCol <= 0 Or iRow > 65000 Or iRow <= 0) Then
    If iCol > 26 Then
        GetCellAsStr = Chr$(64 + (iCol \ 26)) & Chr$(64 + (iCol Mod 26)) & CStr(iRow)
    Else
        GetCellAsStr = Chr$(64 + iCol) & CStr(iRow)
    End If
End If
End Function

'---------------------------------------------------------------------------------------
' Procedure : GetRangeAsStr
' DateTime  : 25.10.2007 22:21
' Author    : Klaus Oberdalhoff
' Purpose   : Stringwert einers Ranges z.B: "C7:G19" aus Start- und Ende- Zeilen- und Spalten-Nr
'---------------------------------------------------------------------------------------
'
Public Function GetRangeAsStr(ByVal iRow As Long, ByVal iCol As Long, Optional ByVal IRowEnd As Long = -1, Optional ByVal IColEnd As Long = -1) As String

If IRowEnd = -1 And IColEnd = -1 Then
    IRowEnd = iRow
    IColEnd = iCol
End If

If Not (iCol > 256 Or iCol <= 0 Or iRow > 65000 Or iRow <= 0 Or _
    IColEnd > 256 Or IColEnd <= 0 Or IRowEnd > 65000 Or IRowEnd <= 0) Then
    If iCol > 26 Then
        GetRangeAsStr = Chr$(64 + (iCol \ 26)) & Chr$(64 + (iCol Mod 26)) & CStr(iRow)
    Else
        GetRangeAsStr = Chr$(64 + iCol) & CStr(iRow)
    End If
    GetRangeAsStr = GetRangeAsStr & ":"
    If IColEnd > 26 Then
        GetRangeAsStr = GetRangeAsStr & Chr$(64 + (IColEnd \ 26)) & Chr$(64 + (IColEnd Mod 26)) & CStr(IRowEnd)
    Else
        GetRangeAsStr = GetRangeAsStr & Chr$(64 + IColEnd) & CStr(IRowEnd)
    End If
End If

End Function


'**********************************************************************************
'Function File_Exist ()
'
'   Überprüft, ob die Datei vorhanden ist
'   Rückgabe:  True, Datei vorhanden
'              False, Datei nicht vorhanden
'**********************************************************************************
Private Function File_exist(ByVal file As String) As Integer
Dim f

f = FreeFile
On Error GoTo File_existError
Open file For Input Access Read As #f
Close #f
File_exist = True
Exit Function

File_existError:
File_exist = False
Exit Function

End Function


'---------------------------------------------------------------------------------------
' Procedure : XLSSuch
' DateTime  : 25.10.2007 22:23
' Author    : Klaus Oberdalhoff
' Purpose   : Bestehenden XLS-Dateiname via FileDialog suchen (zum lesen öffnen)
' Purpose   : Verwendet Klassenmodul FileDialog
'---------------------------------------------------------------------------------------
'
Private Function XLSSuch(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "Exceldatei (*.xl*) suchen") As String

Dim fd As New FileDialog
         
Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2
   
   With fd  ' CommonDialog aufrufen
    ' Erläuterungen im Code des KlassenModuls FileDialog
      
      .DialogTitle = StBeschriftung
      .InitDir = startdir
      
      .DefaultExt = "XLS"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST
                      
' Hier können bis max. 5 Filter für Datei-Endungen definiert werden
      
      .Filter1Text = "Excel-Dateien (*.xl*)"
      .Filter1Suffix = "*.xl*"
      .Filter2Text = "Excel-Dateien (*.xls)"
      .Filter2Suffix = "*.xls"
      .Filter3Text = "Alle Dateien (*.*)"
      .Filter3Suffix = "*.*"
'      .Filter4Text = "MDB-Dateien (*.mdb)"
'      .Filter4Suffix = "*.mdb"
'      .Filter5Text = "MD*-Dateien (*.md*)"
'      .Filter5Suffix = "*.md*"

'      ... bis max. Filter5Text/Suffix ...
'
      .ShowOpen                          ' oder .ShowSave
   End With
   
XLSSuch = fd.fileName

End Function

'---------------------------------------------------------------------------------------
' Procedure : XLSSuchNeu
' DateTime  : 25.10.2007 22:24
' Author    : Klaus Oberdalhoff
' Purpose   : Noch nicht bestehenden XLS-Dateiname via FileDialog suchen (zum schreiben öffnen)
' Purpose   : Verwendet Klassenmodul FileDialog
'---------------------------------------------------------------------------------------
'
Private Function XLSSuchNeu(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "Exceldatei (*.txt) suchen") As String

Dim fd As New FileDialog
         
Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2
   
   With fd  ' CommonDialog aufrufen
    ' Erläuterungen im Code des KlassenModuls FileDialog
      
      .DialogTitle = StBeschriftung
      .InitDir = startdir
      
      .DefaultExt = "XLS"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST
      .Flags = OFN_OVERWRITEPROMPT Or OFN_PATHMUSTEXIST

' Hier können bis max. 5 Filter für Datei-Endungen definiert werden
      
      .Filter1Text = "Excel-Dateien (*.xl*)"
      .Filter1Suffix = "*.xl*"
      .Filter2Text = "Excel-Dateien (*.xls)"
      .Filter2Suffix = "*.xls"
      .Filter3Text = "Alle Dateien (*.*)"
      .Filter3Suffix = "*.*"
'      .Filter4Text = "MDB-Dateien (*.mdb)"
'      .Filter4Suffix = "*.mdb"
'      .Filter5Text = "MD*-Dateien (*.md*)"
'      .Filter5Suffix = "*.md*"

'      ... bis max. Filter5Text/Suffix ...
'
      '.ShowOpen
      '' oder
      .ShowSave
   
   End With
   
XLSSuchNeu = fd.fileName

End Function

'    Range("F23").Select
'    With Selection
'        .NumberFormat = "@"
'        .HorizontalAlignment = xlCenter
'        .VerticalAlignment = xlCenter
'        .WrapText = False
'        .AddIndent = False
'        .ShrinkToFit = True
'        .MergeCells = False
'        .Locked = False
'        .FormulaHidden = False
'        .Orientation = 0
'        .IndentLevel = 0
'        .ReadingOrder = xlLTR
'    End With
'    With Selection.Font
'        .Name = "Arial"
'        .FontStyle = "Standard"
'        .Size = 9
'        .Strikethrough = False
'        .Superscript = True
'        .Subscript = False
'        .OutlineFont = False
'        .Shadow = False
'        .Underline = xlUnderlineStyleNone
'        .ColorIndex = xlAutomatic

'XlUnderlineStyle kann eine der folgenden XlUnderlineStyle-Konstanten sein.
'
'xlUnderlineStyleNone
'xlUnderlineStyleSingle
'xlUnderlineStyleDouble
'
'xlUnderlineStyleSingleAccounting
'xlUnderlineStyleDoubleAccounting

'    End With
'
'    Range("F14:F17").Select
'    With Selection.Borders(xlDiagonalDown)
'        .LineStyle = xlContinuous
'        .Weight = xlThick
'        .ColorIndex = 50
'    End With
'    With Selection.Borders(xlDiagonalUp)
'        .LineStyle = xlContinuous
'        .Weight = xlThick
'        .ColorIndex = 50
'    End With
'    With Selection.Borders(xlEdgeLeft)
'        .LineStyle = xlContinuous
'        .Weight = xlThick
'        .ColorIndex = 45
'    End With
'    With Selection.Borders(xlEdgeTop)
'        .LineStyle = xlContinuous
'        .Weight = xlThick
'        .ColorIndex = 46
'    End With
'    With Selection.Borders(xlEdgeBottom)
'        .LineStyle = xlContinuous
'        .Weight = xlThick
'        .ColorIndex = 46
'    End With
'    With Selection.Borders(xlEdgeRight)
'        .LineStyle = xlContinuous
'        .Weight = xlThick
'        .ColorIndex = 50
'    End With
'    Selection.Borders(xlInsideHorizontal).LineStyle = xlNone
'
'    Range("DW20").Select
'    Selection.NumberFormat = "0.00"
'    ActiveCell.FormulaR1C1 = "=17*22"
'    Columns("DX:DZ").Select
'    Columns("DW:DW").ColumnWidth = 9.29
'    Range("DN7:FM7").Select
'

'##################################################################################
'  http://www.cpearson.com/excel/mainpage.aspx
'
'Functions For Working With Cell Colors
'##################################################################################
'
'Excel does not have any  built-in worksheet functions for working with the colors of cells or fonts.
'If you want to read or test the color of a cell, you have to use VBA procedure.
'This page describes several functions for counting and summing cells based on the
'color of the font or background.   All of these functions use the ColorIndex property.
'Excel worksheets can't have the vast amount of colors that other applications support.
'In Excel, you are limited to the 56 colors that are part of the Color Pallet for the workbook.
'You may assign any color you want to an entry in the Color Pallet, but each workbook is
'limited to a total of 56 different colors.
'
'The ColorIndex of a range is simply the offset of the color into the Color Pallet table.
'For example, ColorIndex 6 is simply the sixth entry in the Color Pallet.
'You can change the default colors in the Color Pallet of a workbook by using the Colors array.
'For example, to change ColorIndex 6 from yellow (the default) to red, use the following code:
'
'ThisWorkbook.Colors(6) = RGB(255, 0, 0)
'
'If you use the Color property of a cell's Font or Interior, Excel will change the value you assign to
'the closest match color that exists in the current Color Pallet.
'
'NOTE: When you change the background or font color of a cell, Excel does not consider this to
'be changing the value of the cell.  Therefore, it will not recalculate the worksheet, nor
'will it trigger a Worksheet_Change event procedure.  This means that the values returned by
'these functions may not be correct immediately after you change the color of a cell.  They
'will not return an updated value until you recalculate the worksheet by pressing ALT+F9 or by
'changing the actual value of a cell.  There is no practical work-around to this.  You could
'use the Worksheet_SelectionChange event procedure to force a calculation, but this could have
'a serious and detrimental impact on performance.
'
'NOTE:  These functions will not detect colors that are applied by Conditional Formatting.
'They will read only the default colors of the cell and its text.   For information about returning
'colors in effect by conditional formatting, see the Conditional Formatting Colors page.
'
'It is important to remember that if a cell has no color assigned to it, and therefore
'appears to be white, the ColorIndex is equal to the constant xlColorIndexNone, or -4142.
'It does not equal 2, the default ColorIndex value for white.
'Similarly, text that has not been assigned a color, and therefore appears to be black,
'has a ColorIndex value equal to the constant xlColorIndexAutomatic, or -4105. It does not equal 1,
'the default ColorIndex value for black.
'
'The sections below describe a number of VBA functions for working with cell colors.
'
'Returning The ColorIndex Of A Cell
'
'The following function will return the ColorIndex property of a cell.  InRange is the cell to
'examine, OfText indicates whether to return  the ColorIndex of the Font (if True) or the
'Interior (if False).  If  InRange contains more than one cell, the first cell (InRange(1,1))
'of the range is tested.
'
'Function CellColorIndex(InRange As Range, Optional _
'    OfText As Boolean = False) As Integer
'
' This function returns the ColorIndex value of a the Interior
' (background) of a cell, or, if OfText is true, of the Font in the cell.
'
'm_xlObj.Volatile True
'If OfText = True Then
'    CellColorIndex = InRange(1, 1).Font.ColorIndex
'Else
'    CellColorIndex = InRange(1, 1).Interior.ColorIndex
'End If
'
'End Function

'You can call this function from a worksheet cell with a formula like
'=CELLCOLORINDEX(A1,FALSE)
'
'Counting Cells With A Specific Color
'
'The following function will return the number of cells in a range that have either an
'Interior (background) or Font of a specified color.  InRange is the range of cells
'to examine, WhatColorIndex is the ColorIndex value to count, and OfText indicates
'whether to return  the ColorIndex of the Font (if OfText is True) or the Interior
'(if OfText is False or omitted).
''
'Function CountByColor(InRange As Range, _
'    WhatColorIndex As Integer, _
'    Optional OfText As Boolean = False) As Long
''
'' This function return the number of cells in InRange with
'' a background color, or if OfText is True a font color,
'' equal to WhatColorIndex.
''
'Dim Rng As Range
'm_xlObj.Volatile True
'
'For Each Rng In InRange.Cells
'If OfText = True Then
'    CountByColor = CountByColor - _
'            (Rng.Font.ColorIndex = WhatColorIndex)
'Else
'    CountByColor = CountByColor - _
'       (Rng.Interior.ColorIndex = WhatColorIndex)
'End If
'Next Rng
'
'End Function
'
'You can call this function from a worksheet cell with a formula like
'=COUNTBYCOLOR(A1:A10,3,FALSE)
'
'Summing The Values Of Cells With A Specific Color
'
'The following function will return the sum of cells in a range that have either an
'Interior (background) or Font of a specified colorindex.  InRange is the range of
'cells to examine, WhatColorIndex is the ColorIndex value to count, and OfText indicates
'whether to return  the ColorIndex of the Font (if True) or the Interior (if False).
'
'Function SumByColor(InRange As Range, WhatColorIndex As Integer, _
'    Optional OfText As Boolean = False) As Double
''
'' This function return the SUM of the values of cells in
'' InRange with a background color, or if OfText is True a
'' font color, equal to WhatColorIndex.
''
'Dim Rng As Range
'Dim OK As Boolean
'
'm_xlObj.Volatile True
'For Each Rng In InRange.Cells
'    If OfText = True Then
'        OK = (Rng.Font.ColorIndex = WhatColorIndex)
'    Else
'        OK = (Rng.Interior.ColorIndex = WhatColorIndex)
'    End If
'    If OK And IsNumeric(Rng.Value) Then
'        SumByColor = SumByColor + Rng.Value
'    End If
'Next Rng
'
'End Function
'
'You can call this function from a worksheet cell with a formula like
'=SUMBYCOLOR(A1:A10,3,FALSE)




'Summing The Values Of Cells Based On The Color Of Other Cells
'
'The following function will return the sum of cells in a range which correspond to cells in
'another range that have either an Interior (background) or Font of a specified color.
'InRange is the range of cells to examine, WhatColorIndex is the ColorIndex value to count,
'SumRange is the range of value to sum, and OfText indicates whether to return  the ColorIndex
'of the Font (if True) or the Interior (if False).
'
'Function SumIfByColor(InRange As Range, _
'    WhatColorIndex As Integer, SumRange As Range, _
'    Optional OfText As Boolean = False) As Variant
''
'' This function will return the SUM of the values of cells in
'' SumRange where the corresponding cell in InRange has a background
'' color (or font color, if OfText is true) equal to WhatColorIndex.
''
'Dim OK As Boolean
'Dim Ndx As Long
'
'm_xlObj.Volatile True
'
'If (InRange.Rows.Count <> SumRange.Rows.Count) Or _
'    (InRange.Columns.Count <> SumRange.Columns.Count) Then
'    SumIfByColor = CVErr(xlErrRef)
'    Exit Function
'End If
'
'For Ndx = 1 To InRange.Cells.Count
'    If OfText = True Then
'        OK = (InRange.Cells(Ndx).Font.ColorIndex = WhatColorIndex)
'    Else
'        OK = (InRange.Cells(Ndx).Interior.ColorIndex = WhatColorIndex)
'    End If
'    If OK And IsNumeric(SumRange.Cells(Ndx).Value) Then
'        SumIfByColor = SumIfByColor + SumRange.Cells(Ndx).Value
'    End If
'Next Ndx
'
'End Function
'
'You can call this function from a worksheet cell with a formula like
'=SUMIFBYCOLOR(A1:A10,3,B1:B10,FALSE)

'Getting The Range Of Cells With A Specific Color
'
'The following function will return a Range object consisting of those cells in a
'range that have either an Interior (background) or Font of a specified color.
'InRange is the range of cells to examine, WhatColorIndex is the ColorIndex value to count,
'and OfText indicates whether to use the ColorIndex of the Font (if OfText is True) or the
'Interior (if OfText False or omitted).  This function uses the AddRange function to combine
'two ranges into a single range, without the possible problems of the Application.Union method.
'See AddRange, below, for more details about this function.
'
'Function RangeOfColor(InRange As Range, _
'    WhatColorIndex As Integer, _
'    Optional OfText As Boolean = False) As Range
''
'' This function returns a Range of cells in InRange with a
'' background color, or if OfText is True a font color,
'' equal to WhatColorIndex.
''
'Dim Rng As Range
'm_xlObj.Volatile True
'
'For Each Rng In InRange.Cells
'    If OfText = True Then
'        If (Rng.Font.ColorIndex = WhatColorIndex) = True Then
'            Set RangeOfColor = AddRange(RangeOfColor, Rng)
'        End If
'    Else
'        If (Rng.Interior.ColorIndex = WhatColorIndex) = True Then
'            Set RangeOfColor = AddRange(RangeOfColor, Rng)
'        End If
'    End If
'Next Rng
'
'End Function
'
'
''The following function will return the address, as a string, of the range returned by RangeOfColor.
'
'Function AddressOfRangeOfColor(InRange As Range, _
'    WhatColorIndex As Integer, _
'    Optional OfText As Boolean = False) As String
''
'' This function returns the address of the result range of RangeOfColor.
''
'Dim Rng As Range
'Set Rng = RangeOfColor(InRange, WhatColorIndex, OfText)
'If Rng Is Nothing Then
'    AddressOfRangeOfColor = ""
'Else
'    AddressOfRangeOfColor = Rng.Address
'End If
'
'End Function
'
'
''Getting Range Of A Cell With A Specific Color
''
''The following function will return a Range object consisting of the cell in a
''range that has either an Interior (background) or Font of a specified color.
''InRange is the range of cells to examine, WhatColorIndex is the ColorIndex value to count,
''FindWhich indicates which cell to return, and OfText indicates whether to return  the
''ColorIndex of the Font (if True) or the Interior (if False). The value of FindWhich can
''be 0 to return the address of last cell with the specified color, or any positive integer
''to return that occurance (e.g., 3 to return the third occurance).
''
'Function FindColor(InRange As Range, WhatColorIndex As Integer, _
'    FindWhich As Long, Optional OfText As Boolean = False) As Range
''
'' This function returns the Range of a cell in InRange with a
'' background color, or if OfText is True a font color, equal
'' to WhatColorIndex. Which cell address is returned depends on
'' the value of FindWhich:
'' 0 = last occurance
'' 1 to n = the first, second, etc, nth occurance.
''
'Dim Rng As Range
'Dim Addr As String
'Dim OK As Boolean
'Dim Ndx As Long
'
'For Each Rng In InRange
'    If OfText = True Then
'        OK = (Rng.Font.ColorIndex = WhatColorIndex)
'    Else
'        OK = (Rng.Interior.ColorIndex = WhatColorIndex)
'    End If
'    If OK Then
'        Ndx = Ndx + 1
'        If FindWhich = 0 Then
'            Set FindColor = Rng
'        Else
'            If FindWhich = Ndx Then
'                Set FindColor = Rng
'                Exit Function
'            End If
'        End If
'    End If
'Next Rng
'
'End Function
'
'
''The following function will return the address, as a string, of the range returned by .
'
'Function AddressOfFindColor(InRange As Range, _
'   WhatColorIndex As Integer, FindWhich As Long, _
'   Optional OfText As Boolean = False) As String
''
'' This function returns the address of the result of FindColor.
''
'Dim Rng As Range
'Set Rng = FindColor(InRange, WhatColorIndex, FindWhich, OfText)
'If Rng Is Nothing Then
'    AddressOfFindColor = ""
'Else
'    AddressOfFindColor = Rng.Address
'End If
'
'End Function
'
'
''AddRange
''
''The following function will return a Range object that is the logical union of two ranges.
''Unlike the Application.Union method, AddRange will not return duplicate cells in the result.  For example,
''
''Application.Union(Range("A1:B3"), Range("B3:D5")).Cells.Count
''
''will return 15, since B3 is counted twice, once in each range.
''
''AddRange(Range("A1:B3"), Range("B3:D5")).Cells.Count
''
''willl return 14, counting B3 only once.
''
'Function AddRange(ByVal Range1 As Range, _
'    ByVal Range2 As Range) As Range
'Dim Rng As Range
'
'If Range1 Is Nothing Then
'    If Range2 Is Nothing Then
'        Set AddRange = Nothing
'    Else
'    Set AddRange = Range2
'    End If
'Else
'    If Range2 Is Nothing Then
'        Set AddRange = Range1
'    Else
'        Set AddRange = Range1
'        For Each Rng In Range2
'            If m_xlObj.Intersect(Rng, Range1) Is Nothing Then
'                Set AddRange = m_xlObj.Union(AddRange, Rng)
'            End If
'        Next Rng
'    End If
'End If
'
'End Function
'

 

'##################################################################################
'  http://www.cpearson.com/excel/mainpage.aspx
'
'Sorting By Color
'##################################################################################
'
'If you have color-code cells in your worksheet, you find that at times it is useful to sort
'rows by the colors of the cells.  That is, sort all the reds at the top, followed by the blues,
'followed by the yellows, and so on.
'Unfortunately, Excel provides no such tool. You have to do it manually.
'This page describes how to do it.
'
'The first thing you need to do is create an additional column that will contain the ColorIndex
'(click here for more information about the ColorIndex) of either the font or the background of the cell.
'To the right of the data you want to sort, insert a new column by selecting the cell the right of the
'data, and choosing Columns from the Insert menu.
'
'Next, you need a VBA function to return the ColorIndex value of the cell.
'Put the following code in a standard code module in your workbook.
'
'Function ColorIndexOfCell(Rng As Range, _
'    Optional OfText As Boolean, _
'    Optional DefaultAsIndex As Boolean = True) As Integer
'
'Dim C As Long
'If OfText = True Then
'    C = Rng.Font.ColorIndex
'Else
'    C = Rng.Interior.ColorIndex
'End If
'
'If (C < 0) And (DefaultAsIndex = True) Then
'    If OfText = True Then
'        C = GetBlack(Rng.Worksheet.Parent)
'    Else
'        C = GetWhite(Rng.Worksheet.Parent)
'    End If
'End If
'
'ColorIndexOfCell = C
'
'End Function
'
'
'Function GetWhite(WB As Workbook) As Long
'    Dim Ndx As Long
'    For Ndx = 1 To 56
'        If WB.Colors(Ndx) = &HFFFFFF Then
'            GetWhite = Ndx
'            Exit Function
'        End If
'    Next Ndx
'    GetWhite = 0
'End Function
'
'Function GetBlack(WB As Workbook) As Long
'    Dim Ndx As Long
'    For Ndx = 1 To 56
'        If WB.Colors(Ndx) = 0& Then
'            GetBlack = Ndx
'            Exit Function
'        End If
'    Next Ndx
'    GetBlack = 0
'End Function
'
'
''Then, in the newly created column, enter either of the following formulas:
''
''If you want to sort by the Background color of the cell, use the formula
''
''=ColorIndexOfCell(A1,FALSE,TRUE)
''
''If you want to sort by the Font color of the cell, use the formula
''
''=ColorIndexOfCell(A1,TRUE,TRUE)
''
''Of course, change the reference A1 to the first cell in the range.  Use Edit, Fill, Down to fill this
''formula down to the entire range of data you want to sort.
''
''In these cells, you'll see numbers between 1 and 56.  Each of the values indicates the ColorIndex of the cell.
''
''Now, you can sort your data in the normal way, but choose the new column as the primary or first sort key.
''The cells will be sorted in ascending (or descending) order of the ColorIndex values.
''
''So far, this is all well and good if you are happy with the default order of ColorIndex values.
''For example, by default, Red = 2, Blue= 5, and Yellow = 6.
''Therefore, when sorting by ColorIndex values, the data will list all the reds first,
''followed by the blues, then the yellows.
''
''If you want to modify this order, you will need to create a "custom list" and tell
''Excel to use this list as the sort order.  First, create a custom list by going to the
''Tools menu, Options item, Custom Lists tab, and selecting NEW LIST in the Custom Lists box.
''Then, enter the ColorIndex values in the order you want them to appear in ascending sorts,
''in the List Entries box. You can enter the numeric values (between 1 and 56) on separate lines
''in the List Entries box (create a new line by pressing ALT+ENTER) or by separating the entries
''with a comma all on the same line. (NOTE: Non-USA English users may have to use a semicolon
''rather than a comma.)  For example, to sort in order Blue, Yellow, Red, the custom list
''would be (without the quotes) "5,6,2".
''
''Then, in the Sort dialog box, click the Sort By drop down box, click the Options button, and choose
''this new list from the lists displayed.
''
''Yes, sorting by color is a bit tricky, and something that we all would like to see built in to Excel.
''However, until Microsoft provides this feature as a built in tool, we must make the best of what is available.
''
''NOTE: This method sorts by the color specified by the cell's properties.
''It does NOT work with colors that are displayed as a result of Conditional Formatting.
''
'
'
'
'
''##################################################################################
''  http://www.cpearson.com/excel/CFColors.htm
''
''Conditional Formatting Colors
''##################################################################################
''
''Unfortunately, the Color and ColorIndex properties of a Range don't return the color of a
''cell that is displayed if Conditional formatting is applied to the cell.  Nor does it allow
''you to determine whether a conditional format is currently in effect for a cell.
''In order to determine these, you need code that will test the format conditions. This page
''describes several VBA functions that will do this for you.
''
''ActiveCondition
''This function will return the number of the condition that is currently applied to the cell.
''If the cell does not have any conditional formatting defined, or none of the conditional formats
''are currently applied, it returns 0. Otherwise, it returns 1, 2, or 3, indicating with format
''condition is in effect. ActiveCondition requires the GetStrippedValue function at the bottom of this page.
''
''NOTE: ActiveCondition may result in an inaccurate result if the following are true:
''
''You are calling ActiveCondtion from a worksheet cell, AND
''The cell passed to ActiveCondtion uses a "Formula Is" rather than
''"Cell Value Is" condition, AND
''The formula used in the condition formula contains relative addresses
''To prevent this problem, you must use absolute cell address in the condition formula.
''
''ColorOfCF
''This function will return the RGB color in effect for either the text or the background of the cell.
''This function requires the ActiveCondition function. You can call this function directly from a
''worksheet cell with a formula like:
''=ColorOfCF(A1,FALSE)
''
''ColorIndexOfCF
''This function will return the color index in effect for either the text or the background of the cell.
''This function requires the ActiveCondition function.  You can call this function directly from a
''worksheet cell with a formula like:
''=ColorIndexOfCF(A1,FALSE)
''
''
''CountOfCF
''This function return the number of cells in a range that have a specified conditional format applied.
''Set the last argument to -1 to look at all format conditions, or a number between 1 and 3 to
''specify a particular condition.  This function requires the ActiveCondition function.
''You can call this function directly from a worksheet cell with a formula like:
''=CountOfCF(A1:A10,1)
''
''SumByCFColorIndex
''This function sums the cells that have a specified background color applied by conditional formatting.
''
'
'Function ActiveCondition(Rng As Range) As Integer
'Dim Ndx As Long
'Dim FC As Excel.FormatCondition
'Dim Temp As Variant
'Dim Temp2 As Variant
'
'If Rng.FormatConditions.Count = 0 Then
'    ActiveCondition = 0
'Else
'    For Ndx = 1 To Rng.FormatConditions.Count
'        Set FC = Rng.FormatConditions(Ndx)
'        Select Case FC.Type
'            Case xlCellValue
'            Select Case FC.Operator
'                Case xlBetween
'                    Temp = GetStrippedValue(FC.Formula1)
'                    Temp2 = GetStrippedValue(FC.Formula2)
'                    If IsNumeric(Temp) Then
'                       If CDbl(Rng.Value) >= CDbl(FC.Formula1) And _
'                           CDbl(Rng.Value) <= CDbl(FC.Formula2) Then
'                           ActiveCondition = Ndx
'                           Exit Function
'                       End If
'                   Else
'                      If Rng.Value >= Temp And _
'                         Rng.Value <= Temp2 Then
'                         ActiveCondition = Ndx
'                         Exit Function
'                      End If
'                   End If
'
'                Case xlGreater
'                    Temp = GetStrippedValue(FC.Formula1)
'                    If IsNumeric(Temp) Then
'                       If CDbl(Rng.Value) > CDbl(FC.Formula1) Then
'                          ActiveCondition = Ndx
'                          Exit Function
'                       End If
'                    Else
'                       If Rng.Value > Temp Then
'                          ActiveCondition = Ndx
'                          Exit Function
'                       End If
'                    End If
'
'                Case xlEqual
'                    Temp = GetStrippedValue(FC.Formula1)
'                    If IsNumeric(Temp) Then
'                       If CDbl(Rng.Value) = CDbl(FC.Formula1) Then
'                           ActiveCondition = Ndx
'                           Exit Function
'                       End If
'                    Else
'                       If Temp = Rng.Value Then
'                          ActiveCondition = Ndx
'                          Exit Function
'                       End If
'                    End If
'
'
'                Case xlGreaterEqual
'                    Temp = GetStrippedValue(FC.Formula1)
'                    If IsNumeric(Temp) Then
'                       If CDbl(Rng.Value) >= CDbl(FC.Formula1) Then
'                           ActiveCondition = Ndx
'                           Exit Function
'                       End If
'                    Else
'                       If Rng.Value >= Temp Then
'                          ActiveCondition = Ndx
'                          Exit Function
'                       End If
'                    End If
'
'
'                Case xlLess
'                    Temp = GetStrippedValue(FC.Formula1)
'                    If IsNumeric(Temp) Then
'                        If CDbl(Rng.Value) < CDbl(FC.Formula1) Then
'                           ActiveCondition = Ndx
'                           Exit Function
'                        End If
'                    Else
'                        If Rng.Value < Temp Then
'                           ActiveCondition = Ndx
'                           Exit Function
'                        End If
'                    End If
'
'                Case xlLessEqual
'                    Temp = GetStrippedValue(FC.Formula1)
'                    If IsNumeric(Temp) Then
'                       If CDbl(Rng.Value) <= CDbl(FC.Formula1) Then
'                          ActiveCondition = Ndx
'                          Exit Function
'                       End If
'                    Else
'                       If Rng.Value <= Temp Then
'                          ActiveCondition = Ndx
'                          Exit Function
'                       End If
'                    End If
'
'
'                Case xlNotEqual
'                    Temp = GetStrippedValue(FC.Formula1)
'                    If IsNumeric(Temp) Then
'                       If CDbl(Rng.Value) <> CDbl(FC.Formula1) Then
'                          ActiveCondition = Ndx
'                          Exit Function
'                       End If
'                    Else
'                       If Temp <> Rng.Value Then
'                          ActiveCondition = Ndx
'                          Exit Function
'                       End If
'                    End If
'
'               Case xlNotBetween
'                    Temp = GetStrippedValue(FC.Formula1)
'                    Temp2 = GetStrippedValue(FC.Formula2)
'                    If IsNumeric(Temp) Then
'                       If Not (CDbl(Rng.Value) <= CDbl(FC.Formula1)) And _
'                          (CDbl(Rng.Value) >= CDbl(FC.Formula2)) Then
'                          ActiveCondition = Ndx
'                          Exit Function
'                       End If
'                    Else
'                       If Not Rng.Value <= Temp And _
'                          Rng.Value >= Temp2 Then
'                          ActiveCondition = Ndx
'                          Exit Function
'                       End If
'                    End If
'
'               Case Else
'                    Debug.Print "UNKNOWN OPERATOR"
'           End Select
'
'
'        Case xlExpression
'            If m_xlObj.Evaluate(FC.Formula1) Then
'               ActiveCondition = Ndx
'               Exit Function
'            End If
'
'        Case Else
'            Debug.Print "UNKNOWN TYPE"
'       End Select
'
'    Next Ndx
'
'End If
'
'ActiveCondition = 0
'
'
'
'End Function
'
'
''''''''''''''''''''''''''''''''''''''''
'
'
'Function ColorIndexOfCF(Rng As Range, _
'    Optional OfText As Boolean = False) As Integer
'
'Dim AC As Integer
'AC = ActiveCondition(Rng)
'If AC = 0 Then
'    If OfText = True Then
'       ColorIndexOfCF = Rng.Font.ColorIndex
'    Else
'       ColorIndexOfCF = Rng.Interior.ColorIndex
'    End If
'Else
'    If OfText = True Then
'       ColorIndexOfCF = Rng.FormatConditions(AC).Font.ColorIndex
'    Else
'       ColorIndexOfCF = Rng.FormatConditions(AC).Interior.ColorIndex
'    End If
'End If
'
'End Function
'
'
''''''''''''''''''''''''''''''''''''''''
'
'
'Function ColorOfCF(Rng As Range, Optional OfText As Boolean = False) As Long
'
'Dim AC As Integer
'AC = ActiveCondition(Rng)
'If AC = 0 Then
'    If OfText = True Then
'       ColorOfCF = Rng.Font.Color
'    Else
'       ColorOfCF = Rng.Interior.Color
'    End If
'Else
'    If OfText = True Then
'       ColorOfCF = Rng.FormatConditions(AC).Font.Color
'    Else
'       ColorOfCF = Rng.FormatConditions(AC).Interior.Color
'    End If
'End If
'
'End Function
'
''''''''''''''''''''''''''''''''''''''''
'
'Function GetStrippedValue(cf As String) As String
'    Dim Temp As String
'    If InStr(1, cf, "=", vbTextCompare) Then
'       Temp = Mid(cf, 3, Len(cf) - 3)
'       If Left(Temp, 1) = "=" Then
'           Temp = Mid(Temp, 2)
'       End If
'    Else
'       Temp = cf
'    End If
'    GetStrippedValue = Temp
'End Function
'
'
''''''''''''''''''''''''''''''''''''''''
'
'Function CountOfCF(InRange As Range, _
'    Optional Condition As Integer = -1) As Long
'    Dim Count As Long
'    Dim Rng As Range
'    Dim FCNum As Integer
'
'    For Each Rng In InRange.Cells
'        FCNum = ActiveCondition(Rng)
'        If FCNum > 0 Then
'            If Condition = -1 Or Condition = FCNum Then
'                Count = Count + 1
'            End If
'        End If
'    Next Rng
'    CountOfCF = Count
'End Function
'
''''''''''''''''''''''''''''''''''''''''
'
'Function SumByCFColorIndex(Rng As Range, CI As Integer) As Double
'    Dim R As Range
'    Dim Total As Double
'    For Each R In Rng.Cells
'        If ColorIndexOfCF(R, False) = CI Then
'            Total = Total + R.Value
'        End If
'    Next R
'    SumByCFColorIndex = Total
'End Function
'
''RGB Colors
''
''A color is defined by a number made up of the Red, Green, and Blue components of the color.
''To convert the individual components to a color value, you can use the VBA function RGB.  For example,
''
''ActiveCell.Interior.Color = RGB(100, 123, 50)
''
''However, there is no built-in method to break out the individual color components from a color value.
''The procedure below will accomplish this.
'
'Sub GetRGB(ByVal RGB As Long, ByRef red As Integer, _
'    ByRef green As Integer, ByRef blue As Integer)
'    red = RGB And 255
'    green = RGB \ 256 And 255
'    blue = RGB \ 256 ^ 2 And 255
'End Sub
'
'Function GetRGBRed(RGB As Long) As Long
'   GetRGBRed = RGB And 255
'End Function
'
'Function GetRGBGreen(RGB As Long) As Long
'   GetRGBGreen = RGB \ 256 And 255
'End Function
'
'Function GetRGBBlue(RGB As Long) As Long
'   GetRGBBlue = RGB \ 256 ^ 2 And 255
'End Function
'
'
''Ist es möglich mittels VBA durch alle bedingten Formate eines Sheets
''gehen und bzw. alle bedingten Formatierungen finden.
''
''Falls es noch jemand brauchen kann:
''
'Sub Liste_Bedingter_Formatierungen() 'Ka Prucha 2007-10-10
' Dim Bedingt As Range, Zelle As Range
' Dim Adr$, oldadr$, TP$, OP$, Fo1$, Fo2$, Text$
' On Error Resume Next
' ActiveCell.SpecialCells(xlCellTypeAllFormatConditions).Select
' Set Bedingt = ActiveCell.SpecialCells(xlCellTypeAllFormatConditions)
' For Each Zelle In Bedingt
'  Adr = Zelle.MergeArea.Address
'  If Adr <> oldadr Then
'   oldadr = Adr     'Verbundene Zellen nur einmal ausgeben
'   With Range(Adr)
'    TP = .FormatConditions.item(1).Type
'    OP = .FormatConditions.item(1).Operator
'    Fo1 = .FormatConditions.item(1).Formula1
'    Fo2 = .FormatConditions.item(1).Formula2
'   End With
'   Text = Adr
'   Select Case TP
'    Case xlCellValue
'    Text = Text & ": Zellwert ist"
'    Select Case OP
'     Case xlBetween: Text = Text & " zwischen "
'     Case xlNotBetween: Text = Text & " nicht zwischen "
'     Case xlEqual: Text = Text & " gleich "
'     Case xlNotEqual: Text = Text & " ungleich "
'     Case xlGreater: Text = Text & " größer als "
'     Case xlLess: Text = Text & " kleiner als "
'     Case xlGreaterEqual: Text = Text & " größer gleich "
'     Case xlLessEqual: Text = Text & " kleiner gleich "
'     Case Else
'      MsgBox "Unbekannter Vergleichsoperator"
'    End Select
'    Case xlExpression: Text = Text & ": Formel ist "
'    Case Else
'     MsgBox "Unbekannter Bedingungstyp"
'   End Select
'   Text = Text & Fo1
'   If TP = xlCellValue Then
'    If OP = xlBetween Or OP = xlNotBetween Then
'     Text = Text & " und " & Fo2
'    End If
'   End If
'   Debug.Print Text
'  End If
' Next
'End Sub
'
'Function CreaComment(rg As Range, Kommentar As String, Optional FontSize As Long = 14, Optional ISBold As Boolean = False)
'
''Show Comments
''Application.DisplayCommentIndicator = xlCommentAndIndicator
'
''Hide Comments
''Application.DisplayCommentIndicator = xlCommentIndicatorOnly
'
''With Zelle.Comment
'''   Set Comment Background Color
''       .Shape.Fill.ForeColor.SchemeColor = VBA.ColorConstants.
''
'''   Set Comment TextColor
''       .Shape.TextFrame.Characters.Font.ColorIndex = VBA.ColorConstants.
''End With
'
'    rg.Select
'    rg.AddComment
'    rg.Comment.shape.TextFrame.Characters.Font.Size = FontSize
'    rg.Comment.shape.TextFrame.Characters.Font.Bold = ISBold
''    rg.Comment.Shape.TextFrame.Characters.Font.ColorIndex = 3 'Red
'    rg.Comment.Visible = False
'    rg.Comment.Text Text:=Kommentar
'    rg.Comment.shape.TextFrame.AutoSize = True
'
'End Function
'
''Sub Kommentar_Test()
''
''Set WS1 = Worksheets("Testdatei")
''
''    WS1.Range("C2:U459").SelectComments
''    Selection.ShapeRange.IncrementLeft -93#
''    Selection.ShapeRange.IncrementTop 14.25
''
''    With Selection.Font
''        .Name = "Arial"
''        .FontStyle = "Fett"
''        .Size = 12
''        .Strikethrough = False
''        .Superscript = False
''        .Subscript = False
''        .OutlineFont = False
''        .Shadow = False
''        .Underline = xlUnderlineStyleNone
''        .ColorIndex = 3
''    End With
''
''    With Selection
''        .HorizontalAlignment = xlLeft
''        .VerticalAlignment = xlCenter
''        .Orientation = xlHorizontal
''        .AutoSize = False
''    End With
''
''    Selection.ShapeRange.Line.Weight = 1#
''    Selection.ShapeRange.Line.DashStyle = msoLineSolid
''    Selection.ShapeRange.Line.Style = msoLineSingle
''    Selection.ShapeRange.Line.Transparency = 0#
''    Selection.ShapeRange.Line.Visible = msoTrue
''    Selection.ShapeRange.Line.ForeColor.RGB = RGB(0, 0, 0)
''    Selection.ShapeRange.Line.BackColor.RGB = RGB(255, 255, 255)
''    Selection.ShapeRange.Fill.Visible = msoTrue
''    Selection.ShapeRange.Fill.ForeColor.SchemeColor = 15
''    Selection.ShapeRange.Fill.Transparency = 0#
''    Selection.ShapeRange.Fill.OneColorGradient msoGradientHorizontal, 4, 0.35
''
''End Sub
''
''
''Private Sub Worksheet_Change(ByVal Target As Range)
''    On Error Resume Next
''    For Each Zelle In Cells.SpecialCells(xlCellTypeComments)
''        With Zelle.Font
''            .Name = "Arial"
''            .FontStyle = "Fett"
''            .Size = 12
''            .Strikethrough = False
''            .Superscript = False
''            .Subscript = False
''            .OutlineFont = False
''            .Shadow = False
''            .Underline = xlUnderlineStyleNone
''            .ColorIndex = 3
''        End With
''        With Zelle
''            .HorizontalAlignment = xlLeft
''            .VerticalAlignment = xlCenter
''            .Orientation = xlHorizontal
''            '.AutoSize = False
''        End With
''        With Zelle.Comment
''            .Shape.IncrementLeft -93#
''            .Shape.IncrementTop 14.25
''            .Shape.Line.Weight = 1#
''            .Shape.Line.DashStyle = msoLineSolid
''            .Shape.Line.Style = msoLineSingle
''            .Shape.Line.Transparency = 0#
''            .Shape.Line.Visible = msoTrue
''            .Shape.Line.ForeColor.RGB = RGB(0, 0, 0)
''            .Shape.Line.BackColor.RGB = RGB(255, 255, 255)
''            .Shape.Fill.Visible = msoTrue
''            .Shape.Fill.ForeColor.SchemeColor = 15
''            .Shape.Fill.Transparency = 0#
''            .Shape.Fill.OneColorGradient msoGradientHorizontal, 4, 0.35
''        End With
''    Next Zelle
''End Sub
'
'
'
''Public Sub Split_Array()
''Dim wsTemp          As Worksheet
''Dim arrValue        As Variant
''Dim arrColorIndex   As Variant
''Dim arrFontColorIndex As Variant
'
''   Set wsTemp = Worksheets.Add
''
''   Worksheets("Tabelle1").UsedRange.Copy wsTemp.Range("A1")
''
''   With wsTemp.UsedRange
''      arrValue = .Value
''
''      'Formel für Hintergrundfarbe
''      ActiveWorkbook.Names.Add Name:="Format", RefersToR1C1:= _
''                               "=GET.CELL(63,Tabelle1!RC)"
''      .Formula = "=Format"
''      arrColorIndex = .Value
''
''      'Formel für Schirftfarbe
''      ActiveWorkbook.Names.Add Name:="Format", RefersToR1C1:= _
''                               "=GET.CELL(24,Tabelle1!RC)"
''      arrFontColorIndex = .Value
''   End With
''
''   Application.DisplayAlerts = False
''   wsTemp.DELETE
''   Application.DisplayAlerts = True
''
''End Sub
'''
''    ActiveWorkbook.Names.Add Name:="farbe", RefersToR1C1:= _
''        "=GET.CELL(63,Tabelle1!RC1)"
''    Worksheets("Tabelle2").Range("A:A").FormulaR1C1 = "=farbe"
'
''End Function
'
'
''Sub makelastcell()
''  'David McRitchie,  http://www.mvps.org/dmcritchie/excel/lastcell.htm
''  Dim x As Long     'revised 2001-08-09 to remove false indication
''  Dim str As String    'revised 2006-07-05 for lastcell to be is a merged cell
''  Dim xLong As Long, clong As Long, rlong As Long
''  On Error GoTo 0
''  x = MsgBox("Do you want the activecell to become " & _
''      "the lastcell" & Chr(10) & Chr(10) & _
''      "Press OK to Eliminate all cells beyond " _
''      & ActiveCell.Address(0, 0) & Chr(10) & _
''      "Press CANCEL to leave sheet as it is", _
''      vbOKCancel + vbCritical + vbDefaultButton2)
''  If x = vbCancel Then Exit Sub
''  str = ActiveCell.Address
''  Range(ActiveCell.Row + ActiveCell.MergeArea.Rows.Count & ":" & Cells.Rows.Count).DELETE
''  Range(Cells(1, ActiveCell.Column + ActiveCell.MergeArea.Columns.Count), _
''     Cells(Cells.Rows.Count, Cells.Columns.Count)).DELETE
''  xLong = ActiveSheet.UsedRange.Rows.Count   'see J-Walkenbach tip 73
''  xLong = ActiveSheet.UsedRange.Columns.Count 'might also help
''
''  Beep
''  rlong = Cells.SpecialCells(xlLastCell).Row
''  clong = Cells.SpecialCells(xlLastCell).Column
''  If rlong <= ActiveCell.Row And clong <= ActiveCell.Column Then Exit Sub
''  MsgBox "Sorry, Have failed to make " & str & " your last cell, " _
''     & "possible merged cells involved, check your results"
''End Sub
'
'
''GET.CELL
''
''Macro Sheets Only
''Returns information about the formatting, location, or contents of a cell. Use GET.CELL in a macro whose behavior is determined by the status of a particular cell.
''
''Syntax
''
''GET.CELL(type_num, reference)
''Type_num    is a number that specifies what type of cell information you want. The following list shows the possible values of type_num and the corresponding results.
''
''Type_num Returns
''
''1   Absolute reference of the upper-left cell in reference, as text in the current workspace reference style.
''2   Row number of the top cell in reference.
''3   Column number of the leftmost cell in reference.
''4   Same as TYPE(reference).
''5   Contents of reference.
''6   Formula in reference, as text, in either A1 or R1C1 style depending on the workspace setting.
''7   Number format of the cell, as text (for example, "m/d/yy" or "General").
'
''8   Number indicating the cell's horizontal alignment:
''        1 = General
''        2 = Left
''        3 = Center
''        4 = Right
''        5 = Fill
''        6 = Justify
''        7 = Center across cells
'
''9   Number indicating the left-border style assigned to the cell:
''        0 = No border
''        1 = Thin line
''        2 = Medium line
''        3 = Dashed line
''        4 = Dotted line
''        5 = Thick line
''        6 = Double line
''        7 = Hairline
''
''10  Number indicating the right-border style assigned to the cell. See type_num 9 for descriptions of the numbers returned.
''11  Number indicating the top-border style assigned to the cell. See type_num 9 for descriptions of the numbers returned.
''12  Number indicating the bottom-border style assigned to the cell. See type_num 9 for descriptions of the numbers returned.
''13  Number from 0 to 18, indicating the pattern of the selected cell as displayed in the Patterns tab of the Format Cells dialog box, which appears when you choose the Cells command from the Format menu. If no pattern is selected, returns 0.
''14  If the cell is locked, returns TRUE; otherwise, returns FALSE.
''15  If the cell's formula is hidden, returns TRUE; otherwise, returns FALSE.
''16  A two-item horizontal array containing the width of the active cell and a logical value indicating whether the cell's width is set to change as the standard width changes (TRUE) or is a custom width (FALSE).
''17  Row height of cell, in points.
''18  Name of font, as text.
''19  Size of font, in points.
''
''20  If all the characters in the cell, or only the first character, are bold, returns TRUE; otherwise, returns FALSE.
''21  If all the characters in the cell, or only the first character, are italic, returns TRUE; otherwise, returns FALSE.
''22  If all the characters in the cell, or only the first character, are underlined, returns TRUE; otherwise, returns FALSE.
''23  If all the characters in the cell, or only the first character, are struck through, returns TRUE; otherwise, returns FALSE.
''24  Font color of the first character in the cell, as a number in the range 1 to 56. If font color is automatic, returns 0.
''25  If all the characters in the cell, or only the first character, are outlined, returns TRUE; otherwise, returns FALSE. Outline font format is not supported by Microsoft Excel for Windows.
''26  If all the characters in the cell, or only the first character, are shadowed, returns TRUE; otherwise, returns FALSE. Shadow font format is not supported by Microsoft Excel for Windows.
''
''27  Number indicating whether a manual page break occurs at the cell:
''       0 = No break
''       1 = Row
''       2 = Column
''       3 = Both row and column
'
''28  Row level (outline).
''29  Column level (outline).
''30  If the row containing the active cell is a summary row, returns TRUE; otherwise, returns FALSE.
''31  If the column containing the active cell is a summary column, returns TRUE; otherwise, returns FALSE.
''32  Name of the workbook and sheet containing the cell If the window contains only a single sheet that has the same name as the workbook without its extension, returns only the name of the book, in the form BOOK1.XLS. Otherwise, returns the name of the sheet in the form "[Book1]Sheet1".
''33  If the cell is formatted to wrap, returns TRUE; otherwise, returns FALSE.
''34  Left-border color as a number in the range 1 to 56. If color is automatic, returns 0.
''35  Right-border color as a number in the range 1 to 56. If color is automatic, returns 0.
''
''36  Top-border color as a number in the range 1 to 56. If color is automatic, returns 0.
''37  Bottom-border color as a number in the range 1 to 56. If color is automatic, returns 0.
''38  Shade foreground color as a number in the range 1 to 56. If color is automatic, returns 0.
''39  Shade background color as a number in the range 1 to 56. If color is automatic, returns 0.
''40  Style of the cell, as text.
''41  Returns the formula in the active cell without translating it (useful for international macro sheets).
''42  The horizontal distance, measured in points, from the left edge of the active window to the left edge of the cell. May be a negative number if the window is scrolled beyond the cell.
''43  The vertical distance, measured in points, from the top edge of the active window to the top edge of the cell. May be a negative number if the window is scrolled beyond the cell.
''
''44  The horizontal distance, measured in points, from the left edge of the active window to the right edge of the cell. May be a negative number if the window is scrolled beyond the cell.
''45  The vertical distance, measured in points, from the top edge of the active window to the bottom edge of the cell. May be a negative number if the window is scrolled beyond the cell.
''46  If the cell contains a text note, returns TRUE; otherwise, returns FALSE.
''47  If the cell contains a sound note, returns TRUE; otherwise, returns FALSE.
''48  If the cells contains a formula, returns TRUE; if a constant, returns FALSE.
''49  If the cell is part of an array, returns TRUE; otherwise, returns FALSE.
'
''50  Number indicating the cell's vertical alignment:
''        1 = Top
''        2 = Center
''        3 = Bottom
''        4 = Justified
'
''51  Number indicating the cell's vertical orientation:
''        0 = Horizontal
''        1 = Vertical
''        2 = Upward
''        3 = Downward
'
''52  The cell prefix (or text alignment) character, or empty text ("") if the cell does not contain one.
''
''53  Contents of the cell as it is currently displayed, as text, including any additional numbers or symbols resulting from the cell's formatting.
''54  Returns the name of the PivotTable view containing the active cell.
''55  Returns the position of a cell within the PivotTableView.
''56  Returns the name of the field containing the active cell reference if inside a PivotTable view.
''57  Returns TRUE if all the characters in the cell, or only the first character, are  formatted with a superscript font; otherwise, returns FALSE.
''58  Returns the font style as text of all the characters in the cell, or only the first character as displayed in the Font tab of the Format Cells dialog box: for example, "Bold Italic".
''59  Returns the number for the underline style:
''        1 = none
''        2 = single
''        3 = double
''        4 = single accounting
''        5 = double accounting
''
''60  Returns TRUE if all the characters in the cell, or only the first characrter, are formatted with a subscript font; otherwise, it returns FALSE.
''61  Returns the name of the PivotTable item for the active cell, as text.
''62  Returns the name of the workbook and the current sheet in the form "[book1]sheet1".
''63  Returns the fill (background) color of the cell.
''64  Returns the pattern (foreground) color of the cell.
''65  Returns TRUE if the Add Indent alignment option is on (Far East versions of Microsoft Excel only); otherwise, it returns FALSE.
''66  Returns the book name of the workbook containing the cell in the form BOOK1.XLS.
''
'
'Public Function Split_Array()
'Dim wbk                       As Workbook
'Dim wsTemp                    As Worksheet
'Dim wsh02                     As Worksheet
'Dim rg                        As Range
'
'Dim LastRow                   As Long
'Dim LastCol                   As Long
'
'Dim strAktTabname             As String
'
'Debug.Print "Start " & Now
'
'
''
''    Dim m_xlObj As Object
''    Dim m_objActiveWkb As Object
''    Dim m_objActSheet As Object
''    Dim m_objActRange As Object
''
''    Dim m_NewWkb As Object
''
''
'
'
'    LastRow = m_objActSheet.Cells.Find(What:="*", _
'                                     SearchOrder:=xlByRows, _
'                                     SearchDirection:=xlPrevious).Row
'    LastCol = m_objActSheet.Cells.Find(What:="*", _
'                                     SearchOrder:=xlByColumns, _
'                                     SearchDirection:=xlPrevious).Column
'    Set rg = m_objActSheet.Range(Cells(1, 1), Cells(LastRow, LastCol))
'
'    strAktTabname = m_objActSheet.Name
'
'    Set wbk = m_xlObj.Workbooks.Add
'    Set wsTemp = wbk.Worksheets(1)
'
'    rg.Copy wsTemp.Range("A1")
'    Set rg = wsTemp.Range(rg.Address)
'
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "Value"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'    wbk.Names.Add Name:="Formatierung", RefersToR1C1:= _
'                  "=GET.CELL(63,!RC)"
'    rg.Formula = "=Formatierung"
'
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "ColorIndex"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'    'Formel für Fontname
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "FontName"
'    wbk.Names.Add Name:="Formatierung", RefersToR1C1:= _
'                  "=GET.CELL(18,!RC)"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'    'Formel für Schriftfarbe
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "FontColorIndex"
'    wbk.Names.Add Name:="Formatierung", RefersToR1C1:= _
'                  "=GET.CELL(24,!RC)"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'    'Formel für m_arrFontUnderline
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "FontUnderline"
'    wbk.Names.Add Name:="Formatierung", RefersToR1C1:= _
'                  "=GET.CELL(22,!RC)"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'    'Formel für m_arrFontBold
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "FontBold"
'    wbk.Names.Add Name:="Formatierung", RefersToR1C1:= _
'                  "=GET.CELL(20,!RC)"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'    'Formel für m_arrFontItalic
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "FontItalic"
'    wbk.Names.Add Name:="Formatierung", RefersToR1C1:= _
'                  "=GET.CELL(21,!RC)"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'    'Formel für m_arrFontStyle
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "FontStyle"
'    wbk.Names.Add Name:="Formatierung", RefersToR1C1:= _
'                  "=GET.CELL(58,!RC)"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'Debug.Print "m_arrFontStyle - 1"
'
'    'Formel für m_Pattern
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "Pattern"
'    wbk.Names.Add Name:="Formatierung", RefersToR1C1:= _
'                  "=GET.CELL(13,!RC)"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'    'Formel für m_PatternColorIndex
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "PatternColorIndex"
'    wbk.Names.Add Name:="Formatierung", RefersToR1C1:= _
'                  "=GET.CELL(64,!RC)"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'    'Formel für m_BDColLeft
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "BDColLeft"
'    wbk.Names.Add Name:="Formatierung", RefersToR1C1:= _
'                  "=GET.CELL(34,!RC)"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'    'Formel für m_BDColRight
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "BDColRight"
'    wbk.Names.Add Name:="Formatierung", RefersToR1C1:= _
'                  "=GET.CELL(35,!RC)"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'    'Formel für m_BDColUp
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "BDColUp"
'    wbk.Names.Add Name:="Formatierung", RefersToR1C1:= _
'                  "=GET.CELL(36,!RC)"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'    'Formel für m_BDColDown
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "BDColDown"
'    wbk.Names.Add Name:="Formatierung", RefersToR1C1:= _
'                  "=GET.CELL(37,!RC)"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'    'Formel für m_BDLinRight
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "BDLinRight"
'    wbk.Names.Add Name:="Formatierung", RefersToR1C1:= _
'                  "=GET.CELL(9,!RC)"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'    'Formel für m_BDLinLeft
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "BDLinLeft"
'    wbk.Names.Add Name:="Formatierung", RefersToR1C1:= _
'                  "=GET.CELL(10,!RC)"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'    'Formel für m_BDLinTop
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "BDLinTop"
'    wbk.Names.Add Name:="Formatierung", RefersToR1C1:= _
'                  "=GET.CELL(11,!RC)"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'    'Formel für m_BDLinBottom
'    Set wsh02 = wbk.Worksheets.Add
'    wsh02.Name = "BDLinBottom"
'    wbk.Names.Add Name:="Formatierung", RefersToR1C1:= _
'                  "=GET.CELL(12,!RC)"
'    wsh02.Range(rg.Address).Value = rg.Value
'
'Debug.Print "m_BDLinBottom Tl 1 - Ende"
'
'    ' Aufräumen
'    m_xlObj.DisplayAlerts = False
'    Set rg = Nothing
'    wsTemp.DELETE
'    wbk.Names("Formatierung").DELETE
'    m_xlObj.DisplayAlerts = True
'
'Debug.Print "m_BDLinBottom Tl 2 - Ende !!!!!!!!!!!!!!!!!!!!"
'
'Debug.Print "End " & Now
'
'End Function
'
'
'
'Sub ShadeAlternateRows(rngTarget As Range, intColor As Integer, lngStep As Long)
'' ################################################################################################
'' VBA macro tip contributed by Erlandsen Data Consulting
'' http://www.exceltip.com/st/Row_and_column_background_color_using_VBA_in_Microsoft_Excel/488.html
'' ################################################################################################
'' adds a background color = intColor to every lngStep rows in rngTarget
'' example: ShadeAlternateRows Range("A1:D50"), 27, 2
'' colors every 2 rows light yellow
'Dim R As Long
'    If rngTarget Is Nothing Then Exit Sub
'    With rngTarget
'        .Interior.ColorIndex = xlColorIndexNone
'        ' remove any previous shading
'        For R = lngStep To .Rows.Count Step lngStep
'            .Rows(R).Interior.ColorIndex = intColor
'        Next R
'    End With
'End Sub
'
'Sub ShadeAlternateColumns(rngTarget As Range, intColor As Integer, lngStep As Long)
'' ################################################################################################
'' VBA macro tip contributed by Erlandsen Data Consulting
'' http://www.exceltip.com/st/Row_and_column_background_color_using_VBA_in_Microsoft_Excel/488.html
'' ################################################################################################
'' adds a background color = intColor to every lngStep column in rngTarget
'' example: ShadeAlternateColumns Range("A1:J20"), 27, 2
'' colors every 2 columns light  yellow
'Dim C As Long
'    If rngTarget Is Nothing Then Exit Sub
'    With rngTarget
'        .Interior.ColorIndex = xlColorIndexNone
'        ' remove any previous shading
'        For C = lngStep To .Columns.Count Step lngStep
'            .Columns(C).Interior.ColorIndex = intColor
'        Next C
'    End With
'End Sub
'
'
'Function Xl_SpnachZahl(ByVal X As String) As Long
'Dim J As Long
'Dim I As Long
'Dim K As Long
'Dim L As Long
'Dim M As Long
'Dim N As Long
'Dim O As Long
'
'X = UCase(X)
'
'J = Len(X)
'M = 0
'N = 0
'O = 0
'L = 26
'For I = J To 1 Step -1
'    K = (L ^ O)
'    M = Asc(Mid(X, I, 1)) - 64
'    N = N + (M * K)
'    O = O + 1
'Next I
'Debug.Print N
'
'Xl_SpnachZahl = N
'
'End Function
'
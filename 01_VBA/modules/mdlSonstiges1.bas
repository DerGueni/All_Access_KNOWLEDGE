Attribute VB_Name = "mdlSonstiges1"
Option Compare Database
Option Explicit
Option Base 1

' Funktionen (bzw.Subs) in diesem Modul:
'   Sleep            - Warten
'   GetLinkedDBName  - Wie heißt die MDB einer eingebundenen Tabelle
'   GetShortPath     - Wie lautet der kurze Pfadnamen eines Langen Pfades
'   GetLongPathName  - Wie lautet der lange Pfad eines kurzen Pfadnamens
'   GetLongFileName  - Wie lautet der lange Dateiname (wird in GetLongPathName verwendet)
'   ZMittel          - Mittelwert
'   Mittelwert_3     - Mittelwert
'   Median           - Berechnet den Median einer Tabelle
'   Öffne_Bericht    - Wie öffne ich einen Bericht ?
'   Long2Bin         - Ausgabe einer Zahl(long) als Binärstring ("001001..")
'   Bin2Long         - Ausgabe eines Binärstrings als Zahl (Long)
'   findemax         - Maximalwert eines Arrays
'   SetSheetFeeder   - Sheedfeeter wechseln
'   B200STR          - Zahl --> Basis 200 umrechnen
'   B200INT          - Basis 200 --> Zahl umrechnen
'   PrintAllProcs    - Alle Proceduren ausdrucken
'   HideTbl          - Tabelle verstecken
'   acg_CreateTable  - Tabelle per VBA erstellen
'   FeldFuellen      - Feld (rechts- oder linksbündig) mit einem Wert versehen
'   RecordNumber     - Record X von Y berechnen
'   MusicRule        - jede 2. Zeile beim Druck grau hinterlegen
'   ExtractWords     - Worte oder Parameter aus einem String extrahieren
'   TstWd            - ExtractWords im Direktfenster testen
'   fCreateAutoNumberField - Autowert Feld via VBA DAO Code erzeugen
'   fTableWithHyperlink    - Hyperlinkfeld via VBA DAO Code erzeugen
'   NullTrim         - Abschneiden aller anhängenden / führenden (leading/trailing) Nullen Hex(0)
'   SavTxt           - Form als Textdatei speichern (leider nicht VB kompatibel)
'   LodTxt           - Textdatei als Form zurücksichern (leider nicht VB kompatibel)
'   BinImport        - Wie importiere ich eine Datei in ein OLE-Object eines Tabellenfeldes ?
'   BinExport        - Wie exportiere ich ein OLE-Object eines Tabellenfeldes in eine Datei ?
'   KillABK          - Hebt AllowByPass in anderer DB wieder auf oder schaltet wieder ein

'**********************************************************************************
' Deklarationen DiskFreeSpace
'**********************************************************************************
Declare PtrSafe Function GetDiskFreeSpace Lib "kernel32" Alias "GetDiskFreeSpaceA" _
    (ByVal lpRootPathName As String, lpSectorsPerCluster As Long, _
    lpBytesPerSector As Long, lpNumberOfFreeClusters As Long, _
    lpTotalNumberOfClusters As Long) As Long

'**********************************************************************************
' Deklarationen für kurzen  & langen Pfadnamen
'**********************************************************************************
Declare PtrSafe Function GetShortPathName Lib "kernel32" Alias "GetShortPathNameA" (ByVal lpszLongPath As String, ByVal lpszShortPath As String, ByVal cchBuffer As Long) As Long

Public Const MAX_PATH = 260
Public Const INVALID_HANDLE_VALUE = -1

Type FILETIME
    dwLowDateTime As Long
    dwHighDateTime As Long
End Type

Type WIN32_FIND_DATA
    dwFileAttributes As Long
    ftCreationTime As FILETIME
    ftLastAccessTime As FILETIME
    ftLastWriteTime As FILETIME
    nFileSizeHigh As Long
    nFileSizeLow As Long
    dwReserved0 As Long
    dwReserved1 As Long
    cFileName As String * MAX_PATH
    cAlternate As String * 14
End Type
  
Type str_DEVMODE
    strGZF As String * 94
End Type

Type type_DEVMODE
    strDeviceName As String * 16
    intSpecVersion As Integer
    intDriverVersion As Integer
    intSize As Integer
    intDriverExtra As Integer
    lngFields As Long
    intOrientation As Integer
    intPaperSize As Integer
    intPaperLength As Integer
    intPaperWidth As Integer
    intScale As Integer
    intCopies As Integer
    intDefaultSource As Integer
    intPrintQuality As Integer
    intColor As Integer
    intDuplex As Integer
    intResolution As Integer
    intTTOption As Integer
    intCollate As Integer
    strFormName As String * 16
    lngPad As Long
    lngBits As Long
    lngPW As Long
    lngPH As Long
    lngDFI As Long
    lngDFr As Long
End Type

Declare PtrSafe Function FindFirstFile Lib "kernel32" Alias "FindFirstFileA" _
    (ByVal lpFileName As String, lpFindFileData As WIN32_FIND_DATA) As Long
  
'**********************************************************************************
' Sub Sleep (Funktion um zu warten)
' Beispiel um 1 Sekunde zu warten:
' Call Sleep 1000
'**********************************************************************************
Public Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)


'**********************************************************************************
' Rückgabe des Datenbanknamens incl. Pfad, der zu einer eingelinkten Tabelle gehört
' The GetLinkedDBName() function requires the name of a
' linked Microsoft Access table, in quotation marks, as an
' argument. The function returns the full path of the originating
' database if successful, or returns 0 if unsuccessful.
'**********************************************************************************
Function GetLinkedDBName(TableName As String)
         
         Dim db As DAO.Database, ret
         On Error GoTo DBNameErr
         Set db = CurrentDb()
         ret = db.TableDefs(TableName).Connect
         GetLinkedDBName = Right(ret, Len(ret) - (InStr(1, ret, "DATABASE=") + 8))
      Exit Function
DBNameErr:
         GetLinkedDBName = ""

End Function

Function GetShortPath(LongPath As String) As String
'**********************************************************************************
' Diese Funktion gibt den Kurzen Pfadnamen zurück
'**********************************************************************************
' Aus www.basicworld.com
'Declare PtrSafe Function GetShortPathName Lib "kernel32" Alias "GetShortPathNameA" (ByVal lpszLongPath As String, ByVal lpszShortPath As String, ByVal cchBuffer As Long) As Long

Dim sBuffer As String, lLen As Long
sBuffer = Space$(512)
lLen = GetShortPathName(LongPath, sBuffer, Len(sBuffer))
GetShortPath = Left$(sBuffer, lLen)

End Function


Public Function GetLongPathName(ShortPath As String) As String
'**********************************************************************************
' Diese Funktion gibt den Langen Pfadnamen zurück
' Diese Funktion verwendet GetLongFileName()
'**********************************************************************************
' Aus www.basicworld.com
  Dim LongPath As String
  Dim pos As Integer
    ' Laufwerksangabe wg. Backslash einzeln behandeln
    pos = InStr(ShortPath, "\")
    LongPath = Left$(ShortPath, pos)
    pos = InStr(pos + 1, ShortPath, "\")
    ' erstes Verzeichnis suchen
    While pos   ' Verzeichnisebenen umwandeln
        LongPath = LongPath & GetLongFileName(Left$(ShortPath, pos - 1)) & "\"
        pos = InStr(pos + 1, ShortPath, "\")
    ' nächsten Backslash suchen
    Wend
    ' Den Dateinamen selbst hinzufügen, wenn kein Directory  'KOBD 1.8.2010
    If Len(Trim(Nz(Dir(ShortPath, vbDirectory)))) > 0 Then
        GetLongPathName = LongPath
    Else
        LongPath = LongPath & GetLongFileName(ShortPath)
        ' Die Fehlerabfrage klauen wir ganz gemütlich aus der GetLongFileName-Funktion.
        ' Auch GetLongPathName liefert bei Miserfolg einen Leerstring zurück:
        If GetLongFileName(LongPath) <> vbNullString Then
            GetLongPathName = LongPath
        Else
            GetLongPathName = vbNullString
        End If
    End If
End Function

  Public Function GetLongFileName(ShortPath As String) As String
'**********************************************************************************
' Diese Funktion gibt den Langen Dateinamen (ohne Pfad) zurück
'**********************************************************************************
' Aus www.basicworld.com
  Dim DateiInfo As WIN32_FIND_DATA
  Dim Retval As Long

    Retval = FindFirstFile(ShortPath, DateiInfo)

    If Retval <> INVALID_HANDLE_VALUE Then ' Abfrage, ob der Aufruf erfolgreich bearbeitet werden konnte
        GetLongFileName = Left$(DateiInfo.cFileName, InStr(DateiInfo.cFileName, vbNullChar) - 1)
    Else
        GetLongFileName = vbNullString ' wenn erfolglos, dann leeren String zurückgeben
    End If

  End Function

'--------------------------------------------------------
'Mittelwertberechnung eines beliebigen Datenarrays
'Günther Ritter
'14.01.1998
'--------------------------------------------------------
'die Funktion liefert den Mittelwert x eines
'beliebigen Arrays
Function ZMittel(ParamArray p() As Variant)
Dim i%, Q%, zähl%
If UBound(p) >= 0 Then
    i = UBound(p)
    For Q = 0 To i
        If Not IsNull(p(Q)) Then
            zähl = zähl + 1
            ZMittel = ZMittel + p(Q)
        End If
    Next Q
    On Error GoTo endefunktion
    ZMittel = ZMittel / zähl
End If

endefunktion:

End Function

Public Function Mittelwert_3(Kriterium As Integer) As Double
Dim dbs As DAO.Database, qdf As QueryDef
    Dim strSQL As String
    'SQL Definition, um aus einer Tabelle die 3 groessten Datensaetze auszufiltern
    strSQL = "select top 3 * from Tabelle where Feld = " & Kriterium & _
    "order by Mittelwert_Feld desc;"
    
    ' Verweis auf aktuelle Datenbank holen.
    Set dbs = CurrentDb
    ' Neues QueryDef-Objekt erstellen.
    Set qdf = dbs.CreateQueryDef("Top3", strSQL)
    Mittelwert_3 = DAvg("Spielzeit", "Top3")
    ' QueryDef-Objekt wieder loeschen.
    DoCmd.DeleteObject acQuery, "Top3"
    Set dbs = Nothing

End Function


Function median(tabelle As String, var As String) As Variant

'Berechnet den Median einer Tabelle
'Autor: Johanna Kirsch

Dim i As Integer
Dim Anz As Long
Dim pos As Long
Dim mitte As Integer
Dim val1 As field
Dim val2 As field
Dim MyDB As DAO.Database
Dim mytab As DAO.Recordset
Set MyDB = CurrentDb()
Set mytab = MyDB.OpenRecordset("SELECT * FROM " & tabelle & " ORDER BY " & var)

mytab.MoveLast
Anz = mytab.RecordCount
If (Anz Mod 2) > 0 Then
  pos = (Anz - 1) / 2
  mitte = 1
Else
  pos = (Anz / 2) - 1
  mitte = 0
End If

For i = 1 To pos
  mytab.MovePrevious
Next
If mitte = 1 Then
  median = mytab.fields(var)
Else
  Set val1 = mytab.fields(var)
  mytab.MovePrevious
  Set val2 = mytab.fields(var)
  median = (val1 + val2) / 2
End If
mytab.Close

End Function



'##------------------------------------------------------------
'## Öffne_Bericht
'##
'## Öffnet einen Bericht von einem Dialogfenster aus, entweder als Druck
'## oder als Vorschau und macht, solange der Bericht offen ist, das
'## aufrufende Formular unsichtbar.
'##
'## Parameter:
'## - F       : Das aufrufende Formular
'## - RName   : Der gewünschte Bericht
'## - DoPrint : True -> Drucken, False -> Vorschau
'##
'##------------------------------------------------------------
Sub Öffne_Bericht(f As Form, RName As String, DoPrint As Integer)

On Error GoTo Öffne_Bericht_Err

    Dim Ansicht As Integer

    '## Ausdruck (NORMAL) oder Vorschau?
    Ansicht = IIf(DoPrint, A_NORMAL, A_PREVIEW)

    '## Vorschau -> Dialogformular ausblenden
    If Ansicht = A_PREVIEW Then
        f.Visible = False
    End If
    
    '## Bericht öffnen
    DoCmd.OpenReport RName, Ansicht

    '## Vorschau -> solange ausgeblendet bleiben, bis Bericht wieder geschlossen
    If Ansicht = A_PREVIEW Then
        Do While IsReportLoad(RName)
            DoEvents
        Loop
        f.Visible = True
    End If
    
Öffne_Bericht_Exit:
    On Error Resume Next
    Exit Sub

Öffne_Bericht_Err:
    Select Case MsgBox(Error, 50, "Runtime-Error " & Err & " in Öffne_Bericht")
        Case 3: Resume Öffne_Bericht_Exit
        Case 4: Resume 0
        Case 5: Resume Next
    End Select

End Sub

Function Long2Bin(ByVal n As Long) As String
'**********************************************************************************
'Umwandlung einer Longinteger Zahl in einen Binärstring
'**********************************************************************************
' Wertebereichdarstellung von bis
'  2147483647 = 01111111111111111111111111111111
'        1000 = 00000000000000000000001111101000
'           1 = 00000000000000000000000000000001
'           0 = 00000000000000000000000000000000
'          -1 = 11111111111111111111111111111111
'       -1000 = 11111111111111111111110000011000
' -2147483648 = 10000000000000000000000000000000
'
'**********************************************************************************
Dim i As Integer
Dim e As String
    e = "0"
    If n < 0 Then
        e = "1"
        n = n And &H7FFFFFFF
    End If
    For i = 30 To 0 Step -1
        If (n And (2& ^ i)) <> 0 Then
            e = e + "1"
        Else
            e = e + "0"
        End If
    Next i
    Long2Bin = e
End Function


Function Bin2Long(xstr As String) As Long
'**********************************************************************************
' Umwandlung eines Binärstrings in eine Longinteger Zahl
'**********************************************************************************
' String sollte wie folgt aussehen: 100010111011. Die Umrechnung erfolgt analog zu
' Long2BinString. Jedes Zeichen ungleich "0" wird als "1" interpretiert.
' Der String wird immer auf 32 Stellen getrimmt, d.h. führende Nullen können entfallen.
' Die rechten 31 Stellen werden positiv umgerechnet. Wenn das erste Zeichen <> "0"
' ist, wird  der Wert als "kleiner Null" interpretiert, d.h. vom errechneten
' Ergebnis wird dez. 2147483648 (= 2^31) subtrahiert.
'
' Wertebereichdarstellung von bis
'  2147483647 = 01111111111111111111111111111111 ( = 2^31 - 1)
'        1000 = 00000000000000000000001111101000
'           1 = 00000000000000000000000000000001
'           0 = 00000000000000000000000000000000
'          -1 = 11111111111111111111111111111111
'       -1000 = 11111111111111111111110000011000
' -2147483648 = 10000000000000000000000000000000 (= 2^31)
'
'**********************************************************************************

Dim i As Integer
Dim j As Integer
Dim ZwSum As Long
Dim Neg As Boolean
Dim ZwString As String
Const NEGWERT = 2147483648#
Const VGLNULL = "0"

j = 0
ZwSum = 0
Neg = False

' ZwString rechtsbündig auf 32 Zeichen trimmen
ZwString = Right("00000000000000000000000000000000" & xstr, 32)

'Prüfung der ersten Stelle auf Negativ
If Left(ZwString, 1) <> VGLNULL Then
    Neg = True
End If

'Erste Stelle löschen
ZwString = Right(ZwString, 31)

' Die Stellen von rechts nach links umrechnen
For i = 31 To 1 Step -1
    If Mid(ZwString, i, 1) <> VGLNULL Then
       ZwSum = ZwSum + (2 ^ j)
    End If
    j = j + 1
Next i

' Ergebnis auf Negativ prüfen
If Neg Then
    ZwSum = ZwSum - NEGWERT
End If

Bin2Long = ZwSum

End Function

Public Function findemax(ParamArray p() As Variant)
Dim i As Integer, Q As Integer
If UBound(p) >= 0 Then 'wurden parameter übergeben?
    Debug.Print UBound(p)
    i = UBound(p) 'Anzahl der werte
    findemax = p(i) 'erster wert
    For Q = 0 To i 'alle durchgehen
        If p(Q) > findemax Then
            findemax = p(Q) 'finde den maximalwert ....
        End If
    Next Q
End If
End Function


Public Function SetSheetFeeder(RptName As String, nSheetFeeder As Integer)
'**********************************************************************************
'Papierschacht zuweisen
'**********************************************************************************
'vielleicht hat jemand von Euch eine Idee, wie ich via ein Modul einem
'Bericht einen bestimmten Drucker und einen bestimmten Papierschacht zuweisen kann.
'Ich brauche dies, weil ich die Kopie des Berichtes auf Recycling-Papier
'ausdrucken muss.
'
'Also, meinereiner nutzt diese Function dazu, leider funktioniert dies
'nicht bei *.mde Dateien, was ich sehr ärgerlich finde.
'**********************************************************************************
    Dim GeräteZF As str_DEVMODE
    Dim DM As type_DEVMODE
    Dim strGerätemodus As String
    Dim rpt As Report
    DoCmd.OpenReport RptName, acDesign
    Set rpt = Reports(RptName)
    If Not IsNull(rpt.PrtDevMode) Then
        strGerätemodus = rpt.PrtDevMode   ' Die Struktur DEVMODE lesen.
        GeräteZF.strGZF = strGerätemodus
        LSet DM = GeräteZF
        DM.intDefaultSource = nSheetFeeder
        LSet GeräteZF = DM          ' Die Eigenschaft aktualisieren.
        Mid(strGerätemodus, 1, 94) = GeräteZF.strGZF
        rpt.PrtDevMode = strGerätemodus
    Else
        MsgBox "Keine Printer Dev Mode"
    End If
    DoCmd.Close acReport, RptName, acSaveYes
    
End Function

Public Function B200STR(ByVal Zahl As Integer) As String
'Funktionen welche mit der Basis 200 rechnen
' Integer --> String
   B200STR = Chr(Zahl \ 200 + 48) + Chr(Zahl Mod 200 + 48)
End Function

Public Function B200INT(ByVal Zahl As String) As Integer
'Funktionen welche mit der Basis 200 rechnen
' String --> Integer
   Dim ix As Long
   Zahl = Right("00" + Zahl, 2)
   ix = 200! * (Asc(Mid(Zahl, 1)) - 48) + Asc(Mid(Zahl, 2)) - 48
   If ix <= 32767! Then
        B200INT = ix
   Else
        B200INT = 0
   End If
End Function

Sub PrintAllProcs()
' Anzeigen der Module im Testfenster
    Dim mdl As Module
    Dim lngCount As Long, lngCountDecl As Long, lngI As Long
    Dim strProcName As String, astrProcNames() As String
    Dim intI As Integer, strMsg As String
    Dim lngR As Long
    Dim dbs As DAO.Database, ctr As Container, doc As Document, strModuleName

    Set dbs = CurrentDb
    Set ctr = dbs.Containers!Modules

    For Each doc In ctr.Documents
        strModuleName = doc.Name
         ' Open specified Module object.
        DoCmd.OpenModule strModuleName
         ' Return reference to Module object.
        Set mdl = Modules(strModuleName)
         ' Count lines in module.
        lngCount = mdl.CountOfLines
         ' Count lines in Declaration section in module.

        lngCountDecl = mdl.CountOfDeclarationLines
         ' Determine name of first procedure.
        strProcName = mdl.ProcOfLine(lngCountDecl + 1, lngR)
         ' Initialize counter variable.
        intI = 0
         ' Redimension array.
        ReDim Preserve astrProcNames(intI)
         ' Store name of first procedure in array.
        astrProcNames(intI) = strProcName
         ' Determine procedure name for each line after declarations.
        For lngI = lngCountDecl + 1 To lngCount
         ' Compare procedure name with ProcOfLine property value.

            If strProcName < mdl.ProcOfLine(lngI, lngR) Then
             ' Increment counter.
                intI = intI + 1
                strProcName = mdl.ProcOfLine(lngI, lngR)
                ReDim Preserve astrProcNames(intI)
                 ' Assign unique procedure names to array.
                astrProcNames(intI) = strProcName
            End If
        Next lngI
        Debug.Print "Procedures in module '" & strModuleName & "': "
        For intI = 0 To UBound(astrProcNames)
            Debug.Print astrProcNames(intI)
        Next intI
         'the line below will close this module if open
        DoCmd.Close
    Next doc
    Set dbs = Nothing
End Sub




Function HideTbl(strTable As String, intHide As Integer) As Integer
'*********************************
'Purpose:   Hides or Shows Tables
'Accepts:   intHide: True (-1) to hide table, false (0) to unhide
'Returns:   True on Success, False on Failure
'********************************

' You may desire to have certain of your tables, such as set up information,
' hidden in normal use. Here's a couple of ways to do it.
' The non-code way is to prefix your table name with "USys_", this will make
' the table visible only if the user has "Show System Objects" set to true.
'
' The other way to hide a table is to set its attribute property to hidden.
' Unlike many other attributes, this one is read/write so it can be changed at
' any time. In addition in Access 95 and 97 if you hide your tables using this
' method, the user can't see it, even if they set the "Show Hidden Objects"
' option to true! Here's the code to do it:

' Problem is, that hidden tables are DELETED, while creating an MDE

' *******************************
On Error GoTo HT_ERR

Dim tDef As TableDef
Dim CurDB As DAO.Database

Set CurDB = CurrentDb()
Set tDef = CurDB.TableDefs(strTable)

Select Case intHide
    Case True
        If Not (tDef.attributes And DB_HIDDENOBJECT) Then
            tDef.attributes = tDef.attributes + DB_HIDDENOBJECT
        End If
    Case Else
        If (tDef.attributes And DB_HIDDENOBJECT) Then
            tDef.attributes = tDef.attributes - DB_HIDDENOBJECT
        End If
End Select

HideTbl = True

EXIT_HT:
    Exit Function
HT_ERR:
    HideTbl = False
    MsgBox "Error: " & Err & " " & Error, 48
    Resume EXIT_HT
    
End Function

Function TestFn()

Dim i As Long
Dim st1 As String
Dim st2 As String

For i = 0 To 90
    st1 = "Set fld(" & i & ") = Newtbl.CreateField(" & Chr$(34) & "MyStringField" & i & Chr$(34) & ", DB_TEXT, 75)"
    st2 = "Newtbl.Fields.Append fld(" & i & ")"
    Debug.Print st1
    Debug.Print st2
Next i

End Function


Function TestFNTbl()

On Error GoTo ErrCT

Dim TDB As DAO.Database
Dim Newtbl As TableDef
Dim fld(260) As field

Set TDB = CurrentDb()
Set Newtbl = TDB.CreateTableDef("Testtabelle1")

Set fld(0) = Newtbl.CreateField("MyStringField0", DB_TEXT, 75)
Newtbl.fields.append fld(0)
Set fld(1) = Newtbl.CreateField("MyStringField1", DB_TEXT, 75)
Newtbl.fields.append fld(1)
Set fld(2) = Newtbl.CreateField("MyStringField2", DB_TEXT, 75)
Newtbl.fields.append fld(2)
Set fld(3) = Newtbl.CreateField("MyStringField3", DB_TEXT, 75)
Newtbl.fields.append fld(3)
Set fld(4) = Newtbl.CreateField("MyStringField4", DB_TEXT, 75)
Newtbl.fields.append fld(4)
Set fld(5) = Newtbl.CreateField("MyStringField5", DB_TEXT, 75)
Newtbl.fields.append fld(5)
Set fld(6) = Newtbl.CreateField("MyStringField6", DB_TEXT, 75)
Newtbl.fields.append fld(6)
Set fld(7) = Newtbl.CreateField("MyStringField7", DB_TEXT, 75)
Newtbl.fields.append fld(7)
Set fld(8) = Newtbl.CreateField("MyStringField8", DB_TEXT, 75)
Newtbl.fields.append fld(8)
Set fld(9) = Newtbl.CreateField("MyStringField9", DB_TEXT, 75)
Newtbl.fields.append fld(9)
Set fld(10) = Newtbl.CreateField("MyStringField10", DB_TEXT, 75)
Newtbl.fields.append fld(10)
Set fld(11) = Newtbl.CreateField("MyStringField11", DB_TEXT, 75)
Newtbl.fields.append fld(11)
Set fld(12) = Newtbl.CreateField("MyStringField12", DB_TEXT, 75)
Newtbl.fields.append fld(12)
Set fld(13) = Newtbl.CreateField("MyStringField13", DB_TEXT, 75)
Newtbl.fields.append fld(13)
Set fld(14) = Newtbl.CreateField("MyStringField14", DB_TEXT, 75)
Newtbl.fields.append fld(14)
Set fld(15) = Newtbl.CreateField("MyStringField15", DB_TEXT, 75)
Newtbl.fields.append fld(15)
Set fld(16) = Newtbl.CreateField("MyStringField16", DB_TEXT, 75)
Newtbl.fields.append fld(16)
Set fld(17) = Newtbl.CreateField("MyStringField17", DB_TEXT, 75)
Newtbl.fields.append fld(17)
Set fld(18) = Newtbl.CreateField("MyStringField18", DB_TEXT, 75)
Newtbl.fields.append fld(18)
Set fld(19) = Newtbl.CreateField("MyStringField19", DB_TEXT, 75)
Newtbl.fields.append fld(19)
Set fld(20) = Newtbl.CreateField("MyStringField20", DB_TEXT, 75)
Newtbl.fields.append fld(20)
Set fld(21) = Newtbl.CreateField("MyStringField21", DB_TEXT, 75)
Newtbl.fields.append fld(21)
Set fld(22) = Newtbl.CreateField("MyStringField22", DB_TEXT, 75)
Newtbl.fields.append fld(22)
Set fld(23) = Newtbl.CreateField("MyStringField23", DB_TEXT, 75)
Newtbl.fields.append fld(23)
Set fld(24) = Newtbl.CreateField("MyStringField24", DB_TEXT, 75)
Newtbl.fields.append fld(24)
Set fld(25) = Newtbl.CreateField("MyStringField25", DB_TEXT, 75)
Newtbl.fields.append fld(25)
Set fld(26) = Newtbl.CreateField("MyStringField26", DB_TEXT, 75)
Newtbl.fields.append fld(26)
Set fld(27) = Newtbl.CreateField("MyStringField27", DB_TEXT, 75)
Newtbl.fields.append fld(27)
Set fld(28) = Newtbl.CreateField("MyStringField28", DB_TEXT, 75)
Newtbl.fields.append fld(28)
Set fld(29) = Newtbl.CreateField("MyStringField29", DB_TEXT, 75)
Newtbl.fields.append fld(29)
Set fld(30) = Newtbl.CreateField("MyStringField30", DB_TEXT, 75)
Newtbl.fields.append fld(30)
Set fld(31) = Newtbl.CreateField("MyStringField31", DB_TEXT, 75)
Newtbl.fields.append fld(31)
Set fld(32) = Newtbl.CreateField("MyStringField32", DB_TEXT, 75)
Newtbl.fields.append fld(32)
Set fld(33) = Newtbl.CreateField("MyStringField33", DB_TEXT, 75)
Newtbl.fields.append fld(33)
Set fld(34) = Newtbl.CreateField("MyStringField34", DB_TEXT, 75)
Newtbl.fields.append fld(34)
Set fld(35) = Newtbl.CreateField("MyStringField35", DB_TEXT, 75)
Newtbl.fields.append fld(35)
Set fld(36) = Newtbl.CreateField("MyStringField36", DB_TEXT, 75)
Newtbl.fields.append fld(36)
Set fld(37) = Newtbl.CreateField("MyStringField37", DB_TEXT, 75)
Newtbl.fields.append fld(37)
Set fld(38) = Newtbl.CreateField("MyStringField38", DB_TEXT, 75)
Newtbl.fields.append fld(38)
Set fld(39) = Newtbl.CreateField("MyStringField39", DB_TEXT, 75)
Newtbl.fields.append fld(39)
Set fld(40) = Newtbl.CreateField("MyStringField40", DB_TEXT, 75)
Newtbl.fields.append fld(40)
Set fld(41) = Newtbl.CreateField("MyStringField41", DB_TEXT, 75)
Newtbl.fields.append fld(41)
Set fld(42) = Newtbl.CreateField("MyStringField42", DB_TEXT, 75)
Newtbl.fields.append fld(42)
Set fld(43) = Newtbl.CreateField("MyStringField43", DB_TEXT, 75)
Newtbl.fields.append fld(43)
Set fld(44) = Newtbl.CreateField("MyStringField44", DB_TEXT, 75)
Newtbl.fields.append fld(44)
Set fld(45) = Newtbl.CreateField("MyStringField45", DB_TEXT, 75)
Newtbl.fields.append fld(45)
Set fld(46) = Newtbl.CreateField("MyStringField46", DB_TEXT, 75)
Newtbl.fields.append fld(46)
Set fld(47) = Newtbl.CreateField("MyStringField47", DB_TEXT, 75)
Newtbl.fields.append fld(47)
Set fld(48) = Newtbl.CreateField("MyStringField48", DB_TEXT, 75)
Newtbl.fields.append fld(48)
Set fld(49) = Newtbl.CreateField("MyStringField49", DB_TEXT, 75)
Newtbl.fields.append fld(49)
Set fld(50) = Newtbl.CreateField("MyStringField50", DB_TEXT, 75)
Newtbl.fields.append fld(50)
Set fld(51) = Newtbl.CreateField("MyStringField51", DB_TEXT, 75)
Newtbl.fields.append fld(51)
Set fld(52) = Newtbl.CreateField("MyStringField52", DB_TEXT, 75)
Newtbl.fields.append fld(52)
Set fld(53) = Newtbl.CreateField("MyStringField53", DB_TEXT, 75)
Newtbl.fields.append fld(53)
Set fld(54) = Newtbl.CreateField("MyStringField54", DB_TEXT, 75)
Newtbl.fields.append fld(54)
Set fld(55) = Newtbl.CreateField("MyStringField55", DB_TEXT, 75)
Newtbl.fields.append fld(55)
Set fld(56) = Newtbl.CreateField("MyStringField56", DB_TEXT, 75)
Newtbl.fields.append fld(56)
Set fld(57) = Newtbl.CreateField("MyStringField57", DB_TEXT, 75)
Newtbl.fields.append fld(57)
Set fld(58) = Newtbl.CreateField("MyStringField58", DB_TEXT, 75)
Newtbl.fields.append fld(58)
Set fld(59) = Newtbl.CreateField("MyStringField59", DB_TEXT, 75)
Newtbl.fields.append fld(59)
Set fld(60) = Newtbl.CreateField("MyStringField60", DB_TEXT, 75)
Newtbl.fields.append fld(60)
Set fld(61) = Newtbl.CreateField("MyStringField61", DB_TEXT, 75)
Newtbl.fields.append fld(61)
Set fld(62) = Newtbl.CreateField("MyStringField62", DB_TEXT, 75)
Newtbl.fields.append fld(62)
Set fld(63) = Newtbl.CreateField("MyStringField63", DB_TEXT, 75)
Newtbl.fields.append fld(63)
Set fld(64) = Newtbl.CreateField("MyStringField64", DB_TEXT, 75)
Newtbl.fields.append fld(64)
Set fld(65) = Newtbl.CreateField("MyStringField65", DB_TEXT, 75)
Newtbl.fields.append fld(65)
Set fld(66) = Newtbl.CreateField("MyStringField66", DB_TEXT, 75)
Newtbl.fields.append fld(66)
Set fld(67) = Newtbl.CreateField("MyStringField67", DB_TEXT, 75)
Newtbl.fields.append fld(67)
Set fld(68) = Newtbl.CreateField("MyStringField68", DB_TEXT, 75)
Newtbl.fields.append fld(68)
Set fld(69) = Newtbl.CreateField("MyStringField69", DB_TEXT, 75)
Newtbl.fields.append fld(69)
Set fld(70) = Newtbl.CreateField("MyStringField70", DB_TEXT, 75)
Newtbl.fields.append fld(70)
Set fld(71) = Newtbl.CreateField("MyStringField71", DB_TEXT, 75)
Newtbl.fields.append fld(71)
Set fld(72) = Newtbl.CreateField("MyStringField72", DB_TEXT, 75)
Newtbl.fields.append fld(72)
Set fld(73) = Newtbl.CreateField("MyStringField73", DB_TEXT, 75)
Newtbl.fields.append fld(73)
Set fld(74) = Newtbl.CreateField("MyStringField74", DB_TEXT, 75)
Newtbl.fields.append fld(74)
Set fld(75) = Newtbl.CreateField("MyStringField75", DB_TEXT, 75)
Newtbl.fields.append fld(75)
Set fld(76) = Newtbl.CreateField("MyStringField76", DB_TEXT, 75)
Newtbl.fields.append fld(76)
Set fld(77) = Newtbl.CreateField("MyStringField77", DB_TEXT, 75)
Newtbl.fields.append fld(77)
Set fld(78) = Newtbl.CreateField("MyStringField78", DB_TEXT, 75)
Newtbl.fields.append fld(78)
Set fld(79) = Newtbl.CreateField("MyStringField79", DB_TEXT, 75)
Newtbl.fields.append fld(79)
Set fld(80) = Newtbl.CreateField("MyStringField80", DB_TEXT, 75)
Newtbl.fields.append fld(80)
Set fld(81) = Newtbl.CreateField("MyStringField81", DB_TEXT, 75)
Newtbl.fields.append fld(81)
Set fld(82) = Newtbl.CreateField("MyStringField82", DB_TEXT, 75)
Newtbl.fields.append fld(82)
Set fld(83) = Newtbl.CreateField("MyStringField83", DB_TEXT, 75)
Newtbl.fields.append fld(83)
Set fld(84) = Newtbl.CreateField("MyStringField84", DB_TEXT, 75)
Newtbl.fields.append fld(84)
Set fld(85) = Newtbl.CreateField("MyStringField85", DB_TEXT, 75)
Newtbl.fields.append fld(85)
Set fld(86) = Newtbl.CreateField("MyStringField86", DB_TEXT, 75)
Newtbl.fields.append fld(86)
Set fld(87) = Newtbl.CreateField("MyStringField87", DB_TEXT, 75)
Newtbl.fields.append fld(87)
Set fld(88) = Newtbl.CreateField("MyStringField88", DB_TEXT, 75)
Newtbl.fields.append fld(88)
Set fld(89) = Newtbl.CreateField("MyStringField89", DB_TEXT, 75)
Newtbl.fields.append fld(89)
Set fld(90) = Newtbl.CreateField("MyStringField90", DB_TEXT, 75)
Newtbl.fields.append fld(90)
Set fld(91) = Newtbl.CreateField("MyStringField91", DB_TEXT, 75)
Newtbl.fields.append fld(91)
Set fld(92) = Newtbl.CreateField("MyStringField92", DB_TEXT, 75)
Newtbl.fields.append fld(92)
Set fld(93) = Newtbl.CreateField("MyStringField93", DB_TEXT, 75)
Newtbl.fields.append fld(93)
Set fld(94) = Newtbl.CreateField("MyStringField94", DB_TEXT, 75)
Newtbl.fields.append fld(94)
Set fld(95) = Newtbl.CreateField("MyStringField95", DB_TEXT, 75)
Newtbl.fields.append fld(95)
Set fld(96) = Newtbl.CreateField("MyStringField96", DB_TEXT, 75)
Newtbl.fields.append fld(96)
Set fld(97) = Newtbl.CreateField("MyStringField97", DB_TEXT, 75)
Newtbl.fields.append fld(97)
Set fld(98) = Newtbl.CreateField("MyStringField98", DB_TEXT, 75)
Newtbl.fields.append fld(98)
Set fld(99) = Newtbl.CreateField("MyStringField99", DB_TEXT, 75)
Newtbl.fields.append fld(99)
Set fld(100) = Newtbl.CreateField("MyStringField100", DB_TEXT, 75)
Newtbl.fields.append fld(100)
Set fld(101) = Newtbl.CreateField("MyStringField101", DB_TEXT, 75)
Newtbl.fields.append fld(101)
Set fld(102) = Newtbl.CreateField("MyStringField102", DB_TEXT, 75)
Newtbl.fields.append fld(102)
Set fld(103) = Newtbl.CreateField("MyStringField103", DB_TEXT, 75)
Newtbl.fields.append fld(103)
Set fld(104) = Newtbl.CreateField("MyStringField104", DB_TEXT, 75)
Newtbl.fields.append fld(104)
Set fld(105) = Newtbl.CreateField("MyStringField105", DB_TEXT, 75)
Newtbl.fields.append fld(105)
Set fld(106) = Newtbl.CreateField("MyStringField106", DB_TEXT, 75)
Newtbl.fields.append fld(106)
Set fld(107) = Newtbl.CreateField("MyStringField107", DB_TEXT, 75)
Newtbl.fields.append fld(107)
Set fld(108) = Newtbl.CreateField("MyStringField108", DB_TEXT, 75)
Newtbl.fields.append fld(108)
Set fld(109) = Newtbl.CreateField("MyStringField109", DB_TEXT, 75)
Newtbl.fields.append fld(109)
Set fld(110) = Newtbl.CreateField("MyStringField110", DB_TEXT, 75)
Newtbl.fields.append fld(110)
Set fld(111) = Newtbl.CreateField("MyStringField111", DB_TEXT, 75)
Newtbl.fields.append fld(111)
Set fld(112) = Newtbl.CreateField("MyStringField112", DB_TEXT, 75)
Newtbl.fields.append fld(112)
Set fld(113) = Newtbl.CreateField("MyStringField113", DB_TEXT, 75)
Newtbl.fields.append fld(113)
Set fld(114) = Newtbl.CreateField("MyStringField114", DB_TEXT, 75)
Newtbl.fields.append fld(114)
Set fld(115) = Newtbl.CreateField("MyStringField115", DB_TEXT, 75)
Newtbl.fields.append fld(115)
Set fld(116) = Newtbl.CreateField("MyStringField116", DB_TEXT, 75)
Newtbl.fields.append fld(116)
Set fld(117) = Newtbl.CreateField("MyStringField117", DB_TEXT, 75)
Newtbl.fields.append fld(117)
Set fld(118) = Newtbl.CreateField("MyStringField118", DB_TEXT, 75)
Newtbl.fields.append fld(118)
Set fld(119) = Newtbl.CreateField("MyStringField119", DB_TEXT, 75)
Newtbl.fields.append fld(119)
Set fld(120) = Newtbl.CreateField("MyStringField120", DB_TEXT, 75)
Newtbl.fields.append fld(120)
Set fld(121) = Newtbl.CreateField("MyStringField121", DB_TEXT, 75)
Newtbl.fields.append fld(121)
Set fld(122) = Newtbl.CreateField("MyStringField122", DB_TEXT, 75)
Newtbl.fields.append fld(122)
Set fld(123) = Newtbl.CreateField("MyStringField123", DB_TEXT, 75)
Newtbl.fields.append fld(123)
Set fld(124) = Newtbl.CreateField("MyStringField124", DB_TEXT, 75)
Newtbl.fields.append fld(124)
Set fld(125) = Newtbl.CreateField("MyStringField125", DB_TEXT, 75)
Newtbl.fields.append fld(125)
Set fld(126) = Newtbl.CreateField("MyStringField126", DB_TEXT, 75)
Newtbl.fields.append fld(126)
Set fld(127) = Newtbl.CreateField("MyStringField127", DB_TEXT, 75)
Newtbl.fields.append fld(127)
Set fld(128) = Newtbl.CreateField("MyStringField128", DB_TEXT, 75)
Newtbl.fields.append fld(128)
Set fld(129) = Newtbl.CreateField("MyStringField129", DB_TEXT, 75)
Newtbl.fields.append fld(129)
Set fld(130) = Newtbl.CreateField("MyStringField130", DB_TEXT, 75)
Newtbl.fields.append fld(130)
Set fld(131) = Newtbl.CreateField("MyStringField131", DB_TEXT, 75)
Newtbl.fields.append fld(131)
Set fld(132) = Newtbl.CreateField("MyStringField132", DB_TEXT, 75)
Newtbl.fields.append fld(132)
Set fld(133) = Newtbl.CreateField("MyStringField133", DB_TEXT, 75)
Newtbl.fields.append fld(133)
Set fld(134) = Newtbl.CreateField("MyStringField134", DB_TEXT, 75)
Newtbl.fields.append fld(134)
Set fld(135) = Newtbl.CreateField("MyStringField135", DB_TEXT, 75)
Newtbl.fields.append fld(135)
Set fld(136) = Newtbl.CreateField("MyStringField136", DB_TEXT, 75)
Newtbl.fields.append fld(136)
Set fld(137) = Newtbl.CreateField("MyStringField137", DB_TEXT, 75)
Newtbl.fields.append fld(137)
Set fld(138) = Newtbl.CreateField("MyStringField138", DB_TEXT, 75)
Newtbl.fields.append fld(138)
Set fld(139) = Newtbl.CreateField("MyStringField139", DB_TEXT, 75)
Newtbl.fields.append fld(139)
Set fld(140) = Newtbl.CreateField("MyStringField140", DB_TEXT, 75)
Newtbl.fields.append fld(140)
Set fld(141) = Newtbl.CreateField("MyStringField141", DB_TEXT, 75)
Newtbl.fields.append fld(141)
Set fld(142) = Newtbl.CreateField("MyStringField142", DB_TEXT, 75)
Newtbl.fields.append fld(142)
Set fld(143) = Newtbl.CreateField("MyStringField143", DB_TEXT, 75)
Newtbl.fields.append fld(143)
Set fld(144) = Newtbl.CreateField("MyStringField144", DB_TEXT, 75)
Newtbl.fields.append fld(144)
Set fld(145) = Newtbl.CreateField("MyStringField145", DB_TEXT, 75)
Newtbl.fields.append fld(145)
Set fld(146) = Newtbl.CreateField("MyStringField146", DB_TEXT, 75)
Newtbl.fields.append fld(146)
Set fld(147) = Newtbl.CreateField("MyStringField147", DB_TEXT, 75)
Newtbl.fields.append fld(147)
Set fld(148) = Newtbl.CreateField("MyStringField148", DB_TEXT, 75)
Newtbl.fields.append fld(148)
Set fld(149) = Newtbl.CreateField("MyStringField149", DB_TEXT, 75)
Newtbl.fields.append fld(149)
Set fld(150) = Newtbl.CreateField("MyStringField150", DB_TEXT, 75)
Newtbl.fields.append fld(150)
Set fld(151) = Newtbl.CreateField("MyStringField151", DB_TEXT, 75)
Newtbl.fields.append fld(151)
Set fld(152) = Newtbl.CreateField("MyStringField152", DB_TEXT, 75)
Newtbl.fields.append fld(152)
Set fld(153) = Newtbl.CreateField("MyStringField153", DB_TEXT, 75)
Newtbl.fields.append fld(153)
Set fld(154) = Newtbl.CreateField("MyStringField154", DB_TEXT, 75)
Newtbl.fields.append fld(154)
Set fld(155) = Newtbl.CreateField("MyStringField155", DB_TEXT, 75)
Newtbl.fields.append fld(155)
Set fld(156) = Newtbl.CreateField("MyStringField156", DB_TEXT, 75)
Newtbl.fields.append fld(156)
Set fld(157) = Newtbl.CreateField("MyStringField157", DB_TEXT, 75)
Newtbl.fields.append fld(157)
Set fld(158) = Newtbl.CreateField("MyStringField158", DB_TEXT, 75)
Newtbl.fields.append fld(158)
Set fld(159) = Newtbl.CreateField("MyStringField159", DB_TEXT, 75)
Newtbl.fields.append fld(159)
Set fld(160) = Newtbl.CreateField("MyStringField160", DB_TEXT, 75)
Newtbl.fields.append fld(160)
Set fld(161) = Newtbl.CreateField("MyStringField161", DB_TEXT, 75)
Newtbl.fields.append fld(161)
Set fld(162) = Newtbl.CreateField("MyStringField162", DB_TEXT, 75)
Newtbl.fields.append fld(162)
Set fld(163) = Newtbl.CreateField("MyStringField163", DB_TEXT, 75)
Newtbl.fields.append fld(163)
Set fld(164) = Newtbl.CreateField("MyStringField164", DB_TEXT, 75)
Newtbl.fields.append fld(164)
Set fld(165) = Newtbl.CreateField("MyStringField165", DB_TEXT, 75)
Newtbl.fields.append fld(165)
Set fld(166) = Newtbl.CreateField("MyStringField166", DB_TEXT, 75)
Newtbl.fields.append fld(166)
Set fld(167) = Newtbl.CreateField("MyStringField167", DB_TEXT, 75)
Newtbl.fields.append fld(167)
Set fld(168) = Newtbl.CreateField("MyStringField168", DB_TEXT, 75)
Newtbl.fields.append fld(168)
Set fld(169) = Newtbl.CreateField("MyStringField169", DB_TEXT, 75)
Newtbl.fields.append fld(169)
Set fld(170) = Newtbl.CreateField("MyStringField170", DB_TEXT, 75)
Newtbl.fields.append fld(170)
Set fld(171) = Newtbl.CreateField("MyStringField171", DB_TEXT, 75)
Newtbl.fields.append fld(171)
Set fld(172) = Newtbl.CreateField("MyStringField172", DB_TEXT, 75)
Newtbl.fields.append fld(172)
Set fld(173) = Newtbl.CreateField("MyStringField173", DB_TEXT, 75)
Newtbl.fields.append fld(173)
Set fld(174) = Newtbl.CreateField("MyStringField174", DB_TEXT, 75)
Newtbl.fields.append fld(174)
Set fld(175) = Newtbl.CreateField("MyStringField175", DB_TEXT, 75)
Newtbl.fields.append fld(175)
Set fld(176) = Newtbl.CreateField("MyStringField176", DB_TEXT, 75)
Newtbl.fields.append fld(176)
Set fld(177) = Newtbl.CreateField("MyStringField177", DB_TEXT, 75)
Newtbl.fields.append fld(177)
Set fld(178) = Newtbl.CreateField("MyStringField178", DB_TEXT, 75)
Newtbl.fields.append fld(178)
Set fld(179) = Newtbl.CreateField("MyStringField179", DB_TEXT, 75)
Newtbl.fields.append fld(179)
Set fld(180) = Newtbl.CreateField("MyStringField180", DB_TEXT, 75)
Newtbl.fields.append fld(180)
Set fld(181) = Newtbl.CreateField("MyStringField181", DB_TEXT, 75)
Newtbl.fields.append fld(181)
Set fld(182) = Newtbl.CreateField("MyStringField182", DB_TEXT, 75)
Newtbl.fields.append fld(182)
Set fld(183) = Newtbl.CreateField("MyStringField183", DB_TEXT, 75)
Newtbl.fields.append fld(183)
Set fld(184) = Newtbl.CreateField("MyStringField184", DB_TEXT, 75)
Newtbl.fields.append fld(184)
Set fld(185) = Newtbl.CreateField("MyStringField185", DB_TEXT, 75)
Newtbl.fields.append fld(185)
Set fld(186) = Newtbl.CreateField("MyStringField186", DB_TEXT, 75)
Newtbl.fields.append fld(186)
Set fld(187) = Newtbl.CreateField("MyStringField187", DB_TEXT, 75)
Newtbl.fields.append fld(187)
Set fld(188) = Newtbl.CreateField("MyStringField188", DB_TEXT, 75)
Newtbl.fields.append fld(188)
Set fld(189) = Newtbl.CreateField("MyStringField189", DB_TEXT, 75)
Newtbl.fields.append fld(189)
Set fld(190) = Newtbl.CreateField("MyStringField190", DB_TEXT, 75)
Newtbl.fields.append fld(190)
Set fld(191) = Newtbl.CreateField("MyStringField191", DB_TEXT, 75)
Newtbl.fields.append fld(191)
Set fld(192) = Newtbl.CreateField("MyStringField192", DB_TEXT, 75)
Newtbl.fields.append fld(192)
Set fld(193) = Newtbl.CreateField("MyStringField193", DB_TEXT, 75)
Newtbl.fields.append fld(193)
Set fld(194) = Newtbl.CreateField("MyStringField194", DB_TEXT, 75)
Newtbl.fields.append fld(194)
Set fld(195) = Newtbl.CreateField("MyStringField195", DB_TEXT, 75)
Newtbl.fields.append fld(195)
Set fld(196) = Newtbl.CreateField("MyStringField196", DB_TEXT, 75)
Newtbl.fields.append fld(196)
Set fld(197) = Newtbl.CreateField("MyStringField197", DB_TEXT, 75)
Newtbl.fields.append fld(197)
Set fld(198) = Newtbl.CreateField("MyStringField198", DB_TEXT, 75)
Newtbl.fields.append fld(198)
Set fld(199) = Newtbl.CreateField("MyStringField199", DB_TEXT, 75)
Newtbl.fields.append fld(199)
Set fld(200) = Newtbl.CreateField("MyStringField200", DB_TEXT, 75)
Newtbl.fields.append fld(200)
Set fld(201) = Newtbl.CreateField("MyStringField201", DB_TEXT, 75)
Newtbl.fields.append fld(201)
Set fld(202) = Newtbl.CreateField("MyStringField202", DB_TEXT, 75)
Newtbl.fields.append fld(202)
Set fld(203) = Newtbl.CreateField("MyStringField203", DB_TEXT, 75)
Newtbl.fields.append fld(203)
Set fld(204) = Newtbl.CreateField("MyStringField204", DB_TEXT, 75)
Newtbl.fields.append fld(204)
Set fld(205) = Newtbl.CreateField("MyStringField205", DB_TEXT, 75)
Newtbl.fields.append fld(205)
Set fld(206) = Newtbl.CreateField("MyStringField206", DB_TEXT, 75)
Newtbl.fields.append fld(206)
Set fld(207) = Newtbl.CreateField("MyStringField207", DB_TEXT, 75)
Newtbl.fields.append fld(207)
Set fld(208) = Newtbl.CreateField("MyStringField208", DB_TEXT, 75)
Newtbl.fields.append fld(208)
Set fld(209) = Newtbl.CreateField("MyStringField209", DB_TEXT, 75)
Newtbl.fields.append fld(209)
Set fld(210) = Newtbl.CreateField("MyStringField210", DB_TEXT, 75)
Newtbl.fields.append fld(210)
Set fld(211) = Newtbl.CreateField("MyStringField211", DB_TEXT, 75)
Newtbl.fields.append fld(211)
Set fld(212) = Newtbl.CreateField("MyStringField212", DB_TEXT, 75)
Newtbl.fields.append fld(212)
Set fld(213) = Newtbl.CreateField("MyStringField213", DB_TEXT, 75)
Newtbl.fields.append fld(213)
Set fld(214) = Newtbl.CreateField("MyStringField214", DB_TEXT, 75)
Newtbl.fields.append fld(214)
Set fld(215) = Newtbl.CreateField("MyStringField215", DB_TEXT, 75)
Newtbl.fields.append fld(215)
Set fld(216) = Newtbl.CreateField("MyStringField216", DB_TEXT, 75)
Newtbl.fields.append fld(216)
Set fld(217) = Newtbl.CreateField("MyStringField217", DB_TEXT, 75)
Newtbl.fields.append fld(217)
Set fld(218) = Newtbl.CreateField("MyStringField218", DB_TEXT, 75)
Newtbl.fields.append fld(218)
Set fld(219) = Newtbl.CreateField("MyStringField219", DB_TEXT, 75)
Newtbl.fields.append fld(219)
Set fld(220) = Newtbl.CreateField("MyStringField220", DB_TEXT, 75)
Newtbl.fields.append fld(220)
Set fld(221) = Newtbl.CreateField("MyStringField221", DB_TEXT, 75)
Newtbl.fields.append fld(221)
Set fld(222) = Newtbl.CreateField("MyStringField222", DB_TEXT, 75)
Newtbl.fields.append fld(222)
Set fld(223) = Newtbl.CreateField("MyStringField223", DB_TEXT, 75)
Newtbl.fields.append fld(223)
Set fld(224) = Newtbl.CreateField("MyStringField224", DB_TEXT, 75)
Newtbl.fields.append fld(224)
Set fld(225) = Newtbl.CreateField("MyStringField225", DB_TEXT, 75)
Newtbl.fields.append fld(225)
Set fld(226) = Newtbl.CreateField("MyStringField226", DB_TEXT, 75)
Newtbl.fields.append fld(226)
Set fld(227) = Newtbl.CreateField("MyStringField227", DB_TEXT, 75)
Newtbl.fields.append fld(227)
Set fld(228) = Newtbl.CreateField("MyStringField228", DB_TEXT, 75)
Newtbl.fields.append fld(228)
Set fld(229) = Newtbl.CreateField("MyStringField229", DB_TEXT, 75)
Newtbl.fields.append fld(229)
Set fld(230) = Newtbl.CreateField("MyStringField230", DB_TEXT, 75)
Newtbl.fields.append fld(230)
Set fld(231) = Newtbl.CreateField("MyStringField231", DB_TEXT, 75)
Newtbl.fields.append fld(231)
Set fld(232) = Newtbl.CreateField("MyStringField232", DB_TEXT, 75)
Newtbl.fields.append fld(232)
Set fld(233) = Newtbl.CreateField("MyStringField233", DB_TEXT, 75)
Newtbl.fields.append fld(233)
Set fld(234) = Newtbl.CreateField("MyStringField234", DB_TEXT, 75)
Newtbl.fields.append fld(234)
Set fld(235) = Newtbl.CreateField("MyStringField235", DB_TEXT, 75)
Newtbl.fields.append fld(235)
Set fld(236) = Newtbl.CreateField("MyStringField236", DB_TEXT, 75)
Newtbl.fields.append fld(236)
Set fld(237) = Newtbl.CreateField("MyStringField237", DB_TEXT, 75)
Newtbl.fields.append fld(237)
Set fld(238) = Newtbl.CreateField("MyStringField238", DB_TEXT, 75)
Newtbl.fields.append fld(238)
Set fld(239) = Newtbl.CreateField("MyStringField239", DB_TEXT, 75)
Newtbl.fields.append fld(239)
Set fld(240) = Newtbl.CreateField("MyStringField240", DB_TEXT, 75)
Newtbl.fields.append fld(240)
Set fld(241) = Newtbl.CreateField("MyStringField241", DB_TEXT, 75)
Newtbl.fields.append fld(241)
Set fld(242) = Newtbl.CreateField("MyStringField242", DB_TEXT, 75)
Newtbl.fields.append fld(242)
Set fld(243) = Newtbl.CreateField("MyStringField243", DB_TEXT, 75)
Newtbl.fields.append fld(243)
Set fld(244) = Newtbl.CreateField("MyStringField244", DB_TEXT, 75)
Newtbl.fields.append fld(244)
Set fld(245) = Newtbl.CreateField("MyStringField245", DB_TEXT, 75)
Newtbl.fields.append fld(245)
Set fld(246) = Newtbl.CreateField("MyStringField246", DB_TEXT, 75)
Newtbl.fields.append fld(246)
Set fld(247) = Newtbl.CreateField("MyStringField247", DB_TEXT, 75)
Newtbl.fields.append fld(247)
Set fld(248) = Newtbl.CreateField("MyStringField248", DB_TEXT, 75)
Newtbl.fields.append fld(248)
Set fld(249) = Newtbl.CreateField("MyStringField249", DB_TEXT, 75)
Newtbl.fields.append fld(249)
Set fld(250) = Newtbl.CreateField("MyStringField250", DB_TEXT, 75)
Newtbl.fields.append fld(250)
Set fld(251) = Newtbl.CreateField("MyStringField251", DB_TEXT, 75)
Newtbl.fields.append fld(251)
Set fld(252) = Newtbl.CreateField("MyStringField252", DB_TEXT, 75)
Newtbl.fields.append fld(252)
Set fld(253) = Newtbl.CreateField("MyStringField253", DB_TEXT, 75)
Newtbl.fields.append fld(253)
Set fld(254) = Newtbl.CreateField("MyStringField254", DB_TEXT, 75)
Newtbl.fields.append fld(254)

TDB.TableDefs.append Newtbl

'Create an index for our table.  Need to use a new tabledef
'object for the table or it doesn't work

TDB.Close
    
ExitCT:
    Exit Function
ErrCT:
    If Err <> 91 Then TDB.Close
    TestFNTbl = False
    Resume ExitCT
End Function



Function acg_CreateTable(strTable As String) As Integer
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


Dim fld1 As field, fld2 As field, fld3 As field
Dim fFormat2 As Property, fFormat3 As Property, fFormat4 As Property
Dim idxTbl As Index
Dim idxFld As field
Dim Newtbl As TableDef
Dim Newtbl2 As TableDef

acg_CreateTable = True

'First Create the table

Set TDB = CurrentDb()
Set Newtbl = TDB.CreateTableDef(strTable)
Set fld1 = Newtbl.CreateField("MyStringField", DB_TEXT, 75)
Newtbl.fields.append fld1
Set fld2 = Newtbl.CreateField("MyNumberField", DB_SINGLE)
Newtbl.fields.append fld2
Set fld3 = Newtbl.CreateField("MyDateTimeField", DB_DATE)
Newtbl.fields.append fld3
TDB.TableDefs.append Newtbl

'Create an index for our table.  Need to use a new tabledef
'object for the table or it doesn't work

Set Newtbl2 = TDB.TableDefs(strTable)
Set idxTbl = Newtbl2.CreateIndex("PrimaryKey")
idxTbl.Primary = -1
idxTbl.Unique = -1
Set idxFld = idxTbl.CreateField("MyStringField")
idxTbl.fields.append idxFld
Newtbl2.Indexes.append idxTbl

'Format the single field to have two decimal places
'and the datetime field to be a medium time.
'Note that decimal places has no space in the name

Set fld2 = Newtbl2.fields("MyNumberField")
Set fFormat2 = fld2.CreateProperty("DecimalPlaces", DB_BYTE, 2)
fld2.Properties.append fFormat2
Set fld3 = Newtbl2.fields("MyDateTimeField")
Set fFormat3 = fld3.CreateProperty("Format", DB_TEXT, "Medium Time")
fld3.Properties.append fFormat3

' To add any comment to a field ("Beschreibung" hinzufügen)

Set fFormat4 = fld1.CreateProperty("Description", DB_TEXT, " Field 1 Description bla bla")
fld1.Properties.append fFormat4
Set fFormat4 = fld2.CreateProperty("Description", DB_TEXT, " Field 2 Description bla bla")
fld2.Properties.append fFormat4
Set fFormat4 = fld3.CreateProperty("Description", DB_TEXT, " Field 3 Description bla bla")
fld3.Properties.append fFormat4

TDB.Close
    
ExitCT:
    Exit Function
ErrCT:
    If Err <> 91 Then TDB.Close
    acg_CreateTable = False
    Resume ExitCT
End Function
 

Function FeldFuellen(MaxFeldLen As Integer, Inhalt As String, _
FuellZeichen As String, Ausrichtung As Boolean) As String

'Art.Nr.: D29890
'
'Frage:
'
'Ich möchte Kundendaten in eine Textdatei mit fester Feldlänge exportieren.
'Das Exportformat gibt einen bestimmten Feldaufbau vor. So muß es z.B. möglich
'sein, die Ausrichtung des Feldinhaltes zu bestimmen und es muß möglich sein,
'die Zeichen festzulegen, mit welchen der Feldinhalt aufgefüllt werden soll,
'falls dieser nicht den ganzen Feldbereich beansprucht.
'Wie kann ich vorgehen?
'
'Antwort:
'
'Diese Anforderungen übersteigen die Möglichkeiten der Format()-Funktion,
'aber Sie können das Problem über eine ACCESS BASIC Prozedur lösen.
'
'Schreiben Sie dazu folgenden Funktion in ein globales Modul Ihrer ACCESS-Anwendung:
'
'Anmerkung:
'In den folgenden Codebeispielen wird der Unterstrich (_) als
'Zeilenfortsetzungszeichen benutzt. Löschen Sie den Unterstrich und den
'folgenden Zeilenumbruch, wenn Sie den Code in einem Modul eingeben.
'
'Die Funktion erwartet folgende Parameter:
'
'MaxFeldLen Gibt die Länge des Feldes an
'Inhalt Stellt den Feldinhalt dar
'FuellZeichen Zeichen, mit welchem aufgefüllt werden soll
'Ausrichtung Gibt die Ausrichtung des Feldinhaltes an
'
'
'Der Aufruf dieser Funktion könnte beispielsweise als Ausdruck in einer Abfrage
'erfolgen.
'
'Ausdruck1: FeldFuellen(11;[Einzelpreis];"0";"Rechts")
'
'Dieser Ausdruck liefert einen Text-String, der auf eine Länge von 11 Zeichen
'mit führenden Nullen aufgefüllt wird. Der Inhalt wird rechtsbündig angeordnet.
'
'Alternativ könnten Sie als Füllzeichen das Leerzeichen (" ") oder den
'Stern ("*" ) verwenden.

Dim Rest As Integer

Rest = IIf(MaxFeldLen - Len(Trim(Inhalt)) < 0, 0, _
MaxFeldLen - Len(Trim(Inhalt)))

If UCase(Ausrichtung) = "RECHTS" Then
FeldFuellen = String(Rest, FuellZeichen) & Trim(Inhalt)
Else ' Links
FeldFuellen = Trim(Inhalt) & String(Rest, FuellZeichen)
End If

End Function


Function RecordNumber(pstrPreFix As String, pFrm As Form) As String

'How do I emulate the "Record X of Y" that Access displays in the navigation buttons
'
' The following function will do this for a form, just send any string and the form
' object as the parameters, e.g. in a ControlSource use
'
'=RecordNumber("Item",[Form])
'
'For code, use:
'strVariable = RecordNumber("Item", Me)
'or
'strVariable = RecordNumber("Item", Forms!MyForm)
'
'This will return something like "Item 4 of 899", if the form is on a new record it
'will return the string "New Record".

    On Error GoTo RecordNumber_Err
    Dim rst As DAO.Recordset
    Dim lngNumRecords As Long
    Dim lngCurrentRecord As Long
    Dim strTmp As String
    
    Set rst = pFrm.RecordsetClone
    rst.MoveLast
    rst.Bookmark = pFrm.Bookmark
    lngNumRecords = rst.RecordCount
    lngCurrentRecord = rst.AbsolutePosition + 1
    strTmp = pstrPreFix & " " & lngCurrentRecord & " von " & lngNumRecords
RecordNumber_Exit:
    On Error Resume Next
    RecordNumber = strTmp
    rst.Close
    Set rst = Nothing
    Exit Function
RecordNumber_Err:
    Select Case Err
        Case 3021
            strTmp = "New Record"
            Resume RecordNumber_Exit
        Case Else
            strTmp = "#" & Error
            Resume RecordNumber_Exit
    End Select
End Function
 

'To produce a tabular report with alternating shaded/not shaded rows:
'
'Create a Tabular Report (using the Wizard if necessary)
'
'In the Detail Section of the Report, create a textbox:
'Name:                  txtRowCount
'        ControlSource: =1
'RunningSum:            Over All
'Visible:               No
'Hide txtRowCount behind another control by using Format/Send to Back
'
'Set the Detail Section's OnFormat property to: =MusicRule([txtRowCount])

'Paste the following function into a module:

'Kommentar von Stefan Wirrer VOLKE_EE@csi.com dazu:
'###################
'Zu 'Wie hinterlege ich jede 2. Zeile beim Druck eines Berichts grau ?'
'(Function MusicRule) hätte ich eine Verbesserung.
'Der Titel ist etwas irreführend, da nicht der Detailbereich grau hinterlegt
'wird, sondern nur die Steuerelemente im Detailbereich (was nicht besonders
'schön aussieht). Daher meine Verbesserung:
'Statt
'For intN = 0 To rpt.Count - 1
'    If rpt(intN).section = 0 Then
'        rpt(intN).BackColor = lngC
'    End If
'Next
'ist es schöner mit
'rpt.section(acDetail).BackColor = lngC
'###################

Function MusicRule(ctl As control)

Dim lngC As Long
Dim intN As Integer
Dim rpt As Report
Set rpt = Screen.ActiveReport
'
If (ctl Mod 2) = 0 Then
    lngC = &HC0C0C0  'light grey on even numbered lines
Else
    lngC = &HFFFFFF  'white on odd numbered lines
End If
'
On Error GoTo MusicRule_Exit
For intN = 0 To rpt.Count - 1
    If rpt(intN).Section = 0 Then
        rpt(intN).backColor = lngC
    End If
Next

MusicRule_Exit:

End Function


'--------------------------------------------------------------------------------
'Extracting Words or Parameters From a String of Text
'S. Boban Dragojlovic of Los Angeles, California USA.
'
'This isn 't a "hidden trick" of Access, but it is a very useful function
'(for me, anyway).
'
'I often need to extract "words" or parameters from a string of text, and
'I wrote this routine for such occasions.
'
'For example, extracting each whole word from
'"The quick brown fox? It jumps over the lazy dog."
'(in this example, strDelims would be ".;'?! ")
'
'Or, looking at each POSITIONAL paramter in
'"ALPHA,,,DELTA,GAMMA,,PI,,"
'(in this example, strDelims would be "," and fCountDupes would be TRUE)
'
'This function parses out all words from a string (strFrom), and places each of
'them into a seperate element of raWords().
'
'    INPUT
'    strFrom  the string to parse
'    raWords()        the dynamic array where the words will be placed
'    strDelims        a string of single-character delimiters
'    fCountDupes      a flag.  If TRUE, then consecutive delimiters will
'                     count individually.  If FALSE, then consecutive
'                     delimiters will be treated as a single delimiter.
'For example, in the string "A,,,B" (assuming that the comma is the delimiter).
'fCountDupes=TRUE will interpret this string as having 2 words: "A" & "B".
'fCountDupes=FALSE will interpret this string as having 4
'words: "A" & "" & "" & "B"
'    OUTPUT
'    raWords() will contain the individual words
'    The function itself returns the number of words found.
'NOTE: A trailing delimiter (e.g. "A,B,") signifies that another word follows
'(albeit that word is blank) and this function will return 3 in this example.

Function ExtractWords(ByVal strFrom As String, raWords() As String, strDelims _
As String, fCountDupes As Integer) As Integer

    Dim intWC As Integer, intX As Integer, intLen As Integer
    Dim strWord As String


    ExtractWords = 0
    intLen = Len(strFrom)

    If (intLen = 0) Then
        Exit Function
    End If

    strWord = ""

    intWC = 1
    ReDim raWords(intWC)

    intX = 1
    Do While (intX <= intLen)
        If (InStr(strDelims, Mid$(strFrom, intX, 1)) > 0) Then
            
         ' current char is a delimiter

            raWords(intWC) = strWord
             intWC = intWC + 1
            ReDim Preserve raWords(intWC)
            strWord = ""

            If Not fCountDupes Then
              ' skip contiguous delimiters
                Do Until (intX > intLen) _
                     Or (InStr(strDelims, Mid$(strFrom, intX, 1)) = 0)
                    intX = intX + 1
                Loop
                If (intX <= intLen) Then
                    strWord = Mid$(strFrom, intX, 1)
                End If
            End If

        Else    ' current char is NOT a delimiter

            strWord = strWord + Mid$(strFrom, intX, 1)

        End If

        intX = intX + 1
    Loop

    raWords(intWC) = strWord
    ExtractWords = intWC

End Function

Function TstWd()
'ExtractWords im Direktfenster testen
Dim TestArray() As String, AnzWd, i
AnzWd = ExtractWords("Hugo;Caesar;;Anton;Berta;Meier;;Müller", TestArray(), ";", True)
Debug.Print
Debug.Print "---------------------"
Debug.Print "  Test ExtractWords  "
Debug.Print "---------------------"
Debug.Print
Debug.Print "Input Teststring: " & "Hugo;Caesar;;Anton;Berta;Meier;;Müller"
Debug.Print "Input Delimiter:  " & ";"
Debug.Print

Debug.Print "fCountDupes True "
Debug.Print "Anzahl gefundene Teilstrings: " & AnzWd
Debug.Print "Lbound " & LBound(TestArray)
Debug.Print "Ubound " & UBound(TestArray)
For i = LBound(TestArray) To UBound(TestArray)
    Debug.Print "   String " & i & " : " & TestArray(i)
Next i

Debug.Print
Debug.Print "---------------------"
Debug.Print

AnzWd = ExtractWords("Hugo;Caesar;;Anton;Berta;Meier;;Müller", TestArray(), ";", False)
Debug.Print "fCountDupes False "
Debug.Print "Anzahl gefundene Teilstrings: " & AnzWd
Debug.Print "Lbound " & LBound(TestArray)
Debug.Print "Ubound " & UBound(TestArray)
For i = LBound(TestArray) To UBound(TestArray)
    Debug.Print "   String " & i & " : " & TestArray(i)
Next i

Debug.Print
Debug.Print "---------------------"

End Function

Function fCreateAutoNumberField( _
                ByVal strTableName As String, _
                ByVal strFieldName As String) _
                As Boolean
'
' Autor: Dev Ashish
'
'Creating an AutoNumber field from code
'
'There are two methods to create an AutoNumber field from code.  One requires you to run a
'SQL DDL "Create Table" statement, and the other uses VBA to append dbAutoIncrField flag to a
'new field's Attributes property.
'
'To create the field using SQL DDL statements, refer to this Knowledge Base article:
'
' Article ID Q116145
'ACC: Create and Drop Tables and Relationships Using SQL DDL
'
'To create the field using VBA and DAO,  you can use this function.

'   Creates an Autonumber field with name=strFieldName
'   in table strTableName.
'   Accepts
'       strTableName:   Name of table in which to create the field
'       strFieldName:    Name of the new field
'   Returns True on success, false otherwise
'

On Error GoTo ErrHandler
Dim db As DAO.Database
Dim fld As DAO.field
Dim tdf As DAO.TableDef

    Set db = Application.CurrentDb
    Set tdf = db.TableDefs(strTableName)
    '   First create a field with datatype = Long Integer
    Set fld = tdf.CreateField(strFieldName, dbLong)
    With fld
        '   Appending dbAutoIncrField to Attributes
        '   tells Jet that it's an Autonumber field
        .attributes = .attributes Or dbAutoIncrField
    End With
    With tdf.fields
        .append fld
        .Refresh
    End With
    
    fCreateAutoNumberField = True
    
ExitHere:
    Set fld = Nothing
    Set tdf = Nothing
    Set db = Nothing
    Exit Function
ErrHandler:
    fCreateAutoNumberField = False
    With Err
        MsgBox "Error " & .Number & vbCrLf & .description, _
            vbOKOnly Or vbCritical, "CreateAutonumberField"
    End With
    Resume ExitHere
End Function


Function fTableWithHyperlink(stTablename As String) As Boolean
'---Posted by Dev Ashish---
'
'Create Hyperlink Field from code
'(Q)    I'm unable to create a Hyperlink Field in a table from code.   What are the steps that
'       I need to take or is this possible?
'
'(A)    To create a Hyperlink field, you need to set the Attributes to dbHyperlinkField.
'
'    Try this function as an example.
'
   On Local Error GoTo fTableWithHyperlink_Err
Dim msg As String ' for error handling
Dim db As DAO.Database
Dim tdf As TableDef
Dim fld As field
    Set db = CurrentDb
    Set tdf = db.CreateTableDef(stTablename)
    Set fld = tdf.CreateField("HyperlinkTest", dbMemo)
    fld.attributes = dbHyperlinkField
    tdf.fields.append fld
    tdf.fields.Refresh
    db.TableDefs.append tdf
    db.TableDefs.Refresh
    Set fld = Nothing
    Set tdf = Nothing
    Set db = Nothing
   
    fTableWithHyperlink = True

fTableWithHyperlink_End:
   Exit Function

fTableWithHyperlink_Err:
   fTableWithHyperlink = False
   msg = "Error Information..." & vbCrLf & vbCrLf
   msg = msg & "Function: fTableWithHyperlink" & vbCrLf
   msg = msg & "Description: " & Err.description & vbCrLf
   msg = msg & "Error #: " & Format$(Err.Number) & vbCrLf
   MsgBox msg, vbInformation, "fTableWithHyperlink"
   Resume fTableWithHyperlink_End
End Function

Sub SavTxt(frmName As String, Dateiname As String, Optional ByVal AcArt As Long = acForm)

'Application.SaveAsText acForm, "frmWinWord aufrufen", "C:\frmxx.txt"
Application.SaveAsText AcArt, frmName, Dateiname

'
End Sub
'
Sub LodTxt(frmName As String, Dateiname As String, Optional AcArt As Long = acForm)

'Application.LoadFromText acForm, "Testform", "D:\Basic\Zip\Csetxlat\Frmcnvt.frm"
Application.LoadFromText AcArt, frmName, Dateiname

End Sub


Function NullTrim(ByVal XString As String, Optional AllNum As Integer = 3) As String

'AllNum = 1 Ltrim
'AllNum = 2 RTrim
'AllNum = 3 LTrim und RTrim

Dim Xlng As Integer, i As Integer
Dim Vgl1 As Integer

XString = Nz(XString)
Xlng = Len(XString)

'Übergebener String > 0
If Xlng = 0 Then
    NullTrim = ""
    Exit Function
End If

If AllNum < 1 Or AllNum > 3 Then AllNum = 3

If AllNum = 1 Or AllNum = 3 Then
    'Enthält der linke Teil eines Strings Hex(0)
    Vgl1 = 0
    For i = 1 To Xlng
        If Mid(XString, i, 1) = Chr(0) Then
            Vgl1 = i
        Else
            Exit For
        End If
    Next i
    'Wenn Ja, entfernen
    If Vgl1 > 0 Then
        XString = Mid(XString, Vgl1 + 1)
    End If
End If

Xlng = Len(XString)
If AllNum = 2 Or AllNum = 3 Then
    'Enthält der rechte Teil eines Strings Hex(0)
    Vgl1 = 0
    For i = Xlng To 1 Step -1
        If Mid(XString, i, 1) = Chr(0) Then
            Vgl1 = i
        Else
            Exit For
        End If
    Next i
    'Wenn Ja, entfernen
    If Vgl1 > 0 Then
        XString = Left(XString, Vgl1 - 1)
    End If
End If

NullTrim = XString

End Function

Function NullTrimTest()
Dim x As String


x = "Keine Nullen"
Debug.Print "!" & x & "!"
Debug.Print "!" & NullTrim(x) & "!"

x = Chr(0) & Chr(0) & Chr(0) & "Hat Nullen" & Chr(0) & Chr(0) & Chr(0)
Debug.Print "!" & x & "!"
Debug.Print "!" & NullTrim(x) & "!"

End Function


Function BinImport(tabelle As String, PfadDatei As String, BinaryFeld As String, Optional Kurztext As String, Optional ID As Long = 0)

' Eine Datei als OLE-Object in ein Tabellenfeld importieren

'Autor: Günther Ritter  www.ostfrieslandweb.de

' tabelle    = Tabellenname, in die importiert werden soll
' PfadDatei  = Dateiname incl. Pfad der zu importierenden Datei
' BinaryFeld = Name des OLE-Object Feldes

'Achtung, absolute Feldnamen: BytesAnz, DateiName, KurzText

'Aufbau der Tabelle _tblPicture:
'-----------------------------
'ID         - Autowert
'BytesAnz   - Zahl / Long Integer
'DateiName  - Memo
'Kurztext   - Text 100
'LangText   - Memo
'Picture    - OLE-Object

Dim db As DAO.Database, rs As DAO.Recordset, i As Long, Nr As Long, BinaryData() As Byte

Set db = CurrentDb
Set rs = db.OpenRecordset(tabelle)

Nr = FreeFile

  Open PfadDatei For Binary As #Nr
  
  ReDim BinaryData(LOF(Nr))
  
  Get #Nr, , BinaryData()
  
  rs.AddNew
  
If ID > 0 Then
  rs("ID") = ID
End If
  rs("BytesAnz") = LOF(Nr)
  rs("DateiName") = PfadDatei
  rs("KurzText") = Nz(Kurztext)
  rs("Erst_am") = Now()
  rs("Erst_von") = atCNames(1)
  rs(BinaryFeld).AppendChunk BinaryData
  rs.update
  Close #Nr
  
  Erase BinaryData
  
  rs.Close
  db.Close
  Set rs = Nothing
  Set db = Nothing
  
End Function


Function BinExport(tabelle As String, PfadDatei As String, BinaryFeld As String, IDNr As Long) As Boolean

' Ein OLE-Object eines Tabellenfeldes in eine Datei exportieren

'Autor: Günther Ritter  www.ostfrieslandweb.de

' tabelle    = Tabellenname
' PfadDatei  = Dateiname incl. Pfad
' BinaryFeld = Name des OLE-Object Feldes
' IDNr       = ID-Nummer des Datensatzes der Tabelle

'Achtung, absolute Feldnamen: ID

'Aufbau der Tabelle _tblPicture:
'-----------------------------
'ID         - Autowert
'BytesAnz   - Zahl / Long Integer
'DateiName  - Memo
'Kurztext   - Text 100
'LangText   - Memo
'Picture    - OLE-Object

Dim db As DAO.Database, rs As DAO.Recordset, i As Long, Nr As Long, BinaryData() As Byte

On Error GoTo xxerr

Set db = CurrentDb
Set rs = db.OpenRecordset("select " & BinaryFeld & " from " & tabelle & " where id=" & IDNr)

Nr = FreeFile

  Open PfadDatei For Binary As #Nr
  
    rs.MoveFirst
  
    ReDim BinaryData(rs(BinaryFeld).FieldSize)
     
    BinaryData() = rs(BinaryFeld).GetChunk(0, rs(BinaryFeld).FieldSize)
    Put #Nr, , BinaryData()
    
  Close #Nr
   
xxend:
  On Error Resume Next
  Erase BinaryData
   
  rs.Close
  db.Close
  Set rs = Nothing
  Set db = Nothing
  
  BinExport = True
  
    Exit Function
    
xxerr:
    
    BinExport = False
    MsgBox "Fehler: " & Err.description & " " & Err.Number & " On BinExport (mdlSonstiges1)"
    Err.clear
    GoTo xxend

End Function


Public Function KillABK(strDbName$, strSchalter$)
'Autor: Harald Langer
'Hebt AllowByPass in anderer DB wieder auf oder schaltet wieder ein

Dim db As DAO.Database
Set db = DBEngine.Workspaces(0).OpenDatabase(strDbName)

Select Case strSchalter
 Case "Aus"
  db.Properties!AllowByPassKey = True
 Case "Ein"
  db.Properties!AllowByPassKey = False
End Select

db.Close

End Function


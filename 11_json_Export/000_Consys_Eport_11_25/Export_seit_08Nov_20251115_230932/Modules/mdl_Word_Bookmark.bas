Option Compare Database
Option Explicit

'Dim wdApp As Word.Application
'Dim wdDoc As Word.Document
'Dim wdRng As Word.Range
'Dim wdTab As Word.Table
'Dim wdRng2 As Word.Range
'Dim Ins As Word.InlineShape
'Dim wdTmp As Word.TEMPLATE

Dim wdApp As Object
Dim wdDoc As Object
Dim wdRng As Object
Dim wdTab As Object
Dim wdRng2 As Object
Dim Ins As Object
Dim wdTmp As Object

Const wdToggle = 9999998
Const wdSortByName = 0
Const wdCharacter = 1
Const wdLine = 5

Const wdStory As Long = 6
Const wdPrintView As Long = 3
Const wdGoToBookmark As Long = -1
Const wdOpenFormatAuto As Long = 0
Const wdUseDestinationStylesRecovery As Long = 19
Const wdUndefined As Long = 9999999
Const wdReplaceAll As Long = 2
Const wdFindContinue As Long = 1
Const wdWithInTable As Long = 12
Const wdFormatPDF As Long = 17


Function WD_template_NonBookmark_Ausles_Test()
'Alle gelisteten Wordvorlagen neu einlesen / dem System bekanntmachen - Felder in Tabelle speichern
'Ruft die Arbeitsfunktion "WD_template_NonBookmark_Ausles" auf, in der die eigentliche Arbeit erledigt wird
'####################################################################################################

Dim iDocNr As Long, Doc_Template_Pfad_Name As String, CONSYS_Grund_Pfad As String

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long

CONSYS_Grund_Pfad = Get_Priv_Property("prp_CONSYS_GrundPfad")

recsetSQL1 = "SELECT ID, DocPfad, Docname FROM _tblEigeneFirma_TB_Dok_Dateinamen"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1
        iDocNr = Nz(DAOARRAY1(0, iZl), 0)
        Doc_Template_Pfad_Name = Nz(DAOARRAY1(1, iZl))
        If Right(Doc_Template_Pfad_Name, 1) <> "\" Then Doc_Template_Pfad_Name = Doc_Template_Pfad_Name & "\"
        Doc_Template_Pfad_Name = CONSYS_Grund_Pfad & Doc_Template_Pfad_Name & Nz(DAOARRAY1(2, iZl))
        WD_template_NonBookmark_Ausles iDocNr, Doc_Template_Pfad_Name

    Next iZl
    Set DAOARRAY1 = Nothing
End If


wdApp.Quit False

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

'iDocNr = 1
'Doc_Template_Pfad_Name = "C:\Kunden\CONSEC (Siegert)\Rechnungsschreibung\Neu\CONSEC_Template_Rch.docx"
'
'WD_template_NonBookmark_Ausles iDocNr, Doc_Template_Pfad_Name
'
End Function

Function WD_template_NonBookmark_Ausles(iDokNr As Long, Doc_Template_Pfad_Name As String)
'Einzelne Wordvorlage neu einlesen / dem System bekanntmachen - Felder in Tabelle speichern
'#############################################################################################################################

Dim tTmp As String

Dim Bmk() As String
Dim x As Integer, j As Integer
Dim i As Long

Dim Fill_Tbl_OK1 As Boolean, recsetSQL1 As String, InArray1

Dim firstTerm As String
Dim secondTerm As String
Dim documentText As String

Dim startPos As Long 'Stores the starting position of firstTerm
Dim stopPos As Long 'Stores the starting position of secondTerm based on first term's location
Dim nextPosition As Long 'The next position to search for the firstTerm

On Error Resume Next
Set wdApp = GetObject(, "Word.Application")
If wdApp Is Nothing Then
    err.clear
    Set wdApp = CreateObject("Word.Application")
End If
On Error GoTo 0

tTmp = Doc_Template_Pfad_Name

Set wdDoc = wdApp.Documents.Add(tTmp)

'wdApp.Visible = False
wdApp.Visible = True
'wdApp.ScreenUpdating = False   ' buggy - dont use
'wdApp.Visible = False

nextPosition = 1

'First and Second terms as defined by your example.  Obviously, this will have to be more dynamic
'if you want to parse more than justpatientFirstname.
firstTerm = "["
secondTerm = "]"

'Get all the document text and store it in a variable.
Set wdRng = wdDoc.Range
'Maximum limit of a string is 2 billion characters.
'So, hopefully your document is not bigger than that.  However, expect declining performance based on how big doucment is
documentText = wdRng.Text

i = 0
'Loop documentText till you can't find any more matching "terms"
Do Until nextPosition = 0
    startPos = InStr(nextPosition, documentText, firstTerm, vbTextCompare)
    If startPos = 0 And i = 0 Then
        Exit Function
    End If
    stopPos = InStr(startPos, documentText, secondTerm, vbTextCompare)
    ReDim Preserve Bmk(1, i)
    Bmk(0, i) = iDokNr
'    Bmk(1, i) = Mid$(documentText, startPos + Len(firstTerm), stopPos - startPos - Len(secondTerm))  '' ohne [ ]
    Bmk(1, i) = Mid$(documentText, startPos - 1 + Len(firstTerm), stopPos - startPos + 2 - Len(secondTerm))   '' mit  [ ]
'    Debug.Print Mid$(documentText, startPos + Len(firstTerm), stopPos - startPos - Len(secondTerm))
    nextPosition = InStr(stopPos, documentText, firstTerm, vbTextCompare)
    i = i + 1
Loop

'MsgBox "I'm done First Step"

Const wdFormatHTML As Long = 8
Const wdFormatXPS As Long = 18
Const wdFormatPDF As Long = 17

'wdDoc.SaveAs2 "C:\Test\Test_" & iDokNr & ".pdf", wdFormatPDF  'WdSaveFormat-Enum  - wdFormatPDF - 17
'
CurrentDb.Execute ("DELETE * FROM _tblEigeneFirma_TB_Dok_Feldnamen WHERE DokNr = " & iDokNr)
DoEvents
recsetSQL1 = "SELECT DokNr, Feldname FROM _tblEigeneFirma_TB_Dok_Feldnamen"

'  0 = ID
'  1 = DokNr
'  2 = Feldname

Fill_Tbl_OK1 = Fill_Tbl(recsetSQL1, Bmk)
''Info:   'AccessArray(iSpalte,iZeile) <0, 0>       'ExcelArray(iZeile, iSpalte) <1, 1>
DoEvents

wdDoc.Close False

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

End Function


Function WordReplace(Doc_Template_Pfad_Name As String, Doc_Save_Pfad_Name As String)
'Die in Tabelle tbltmp_Textbaustein_Ersetzung bereits vorbereiteten und ersetzten Felder in Word ersetzen und Dokument sichern
'#############################################################################################################################
Dim myStoryRange
Dim SearchStr As String
Dim ReplaceStr As String
Dim tTmp As String
Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
Dim FiCrLf As String
Dim ergCr As String
Dim ergCr1 As String

   On Error GoTo WordReplace_Error

WDStart:

Sleep 100

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

On Error Resume Next
Set wdApp = GetObject(, "Word.Application")
If wdApp Is Nothing Then
    err.clear
    
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents
    
    Set wdApp = CreateObject("Word.Application")
End If

   On Error GoTo WordReplace_Error

tTmp = Doc_Template_Pfad_Name

Set wdDoc = wdApp.Documents.Add(tTmp)

'wdApp.Visible = False
wdApp.Visible = True
wdApp.ScreenUpdating = False   ' buggy - dont use
'wdApp.Visible = False

err.clear
On Error GoTo 0

'Warum in Word der Zeilenumbruch mit Chr$(11) Funktioniert, aber nicht mir CRLF wird mir ewig ein Rätsel bleiben
FiCrLf = vbCrLf
ergCr = Chr$(11)

recsetSQL1 = "Select TB_Name_Kl, Ersetzung FROM tbltmp_Textbaustein_Ersetzung"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1
        SearchStr = Nz(DAOARRAY1(0, iZl))
        'Text Trim
        ReplaceStr = Trim(Nz(DAOARRAY1(1, iZl)))
        'CrLf für Word durch Lf ersetzt
        ReplaceStr = Replace(ReplaceStr, FiCrLf, ergCr, , , vbTextCompare)
        ' Seltsames Phänomen, das Zeichen 129 bei Nürnberg zwischen ü und r zu setzen, eliminiert
        ReplaceStr = Replace(ReplaceStr, Chr$(129), "", , , vbTextCompare)
                
        For Each myStoryRange In wdDoc.StoryRanges
            With myStoryRange.Find
                .Text = SearchStr
                .Replacement.Text = ReplaceStr
                .Wrap = wdFindContinue
              '  .ClearFormatting
              '  .Replacement.ClearFormatting
                .Replacement.Highlight = wdUndefined
                .Execute Replace:=wdReplaceAll
            End With
        Next myStoryRange
    

    Next iZl
    Set DAOARRAY1 = Nothing
End If

'wdApp.ActiveDocument.SaveAs2 Chr(34) & Doc_Save_Pfad_Name & Chr(34)
wdDoc.SaveAs2 Chr(34) & Doc_Save_Pfad_Name & Chr(34)

wdApp.Visible = True
wdApp.ScreenUpdating = True   ' buggy - dont use

'wdDoc.Close False
'
'DoEvents
'DBEngine.Idle dbRefreshCache
'DBEngine.Idle dbFreeLocks
'DoEvents
'
'wdApp.Quit False
'
'DoEvents
'DBEngine.Idle dbRefreshCache
'DBEngine.Idle dbFreeLocks
'DoEvents

   On Error GoTo 0
   Exit Function

WordReplace_Error:
    If err.Number = 429 Then
        Set wdApp = Nothing
        Sleep 200
        DoEvents
        DBEngine.Idle dbRefreshCache
        DBEngine.Idle dbFreeLocks
        DoEvents
        Sleep 100
        DoEvents
        GoTo WDStart

Else
    MsgBox "Error " & err.Number & " (" & err.description & ") in procedure WordReplace of Modul mdl_Word_Bookmark"
End If

End Function


Function Word_Insert_Table(Doc_Save_Pfad_Name As String)
'Positions-Tabelle in Word (Artikel Menge Preis) füllen und Dokument sichern
'###########################################################################
Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, DAOARRAY_Name1, iZl As Long, iCol As Long
  Dim i As Long
  Dim j As Long
  Dim strErsatz As Variant
  
  'Recordset muss identisch mit Tabellenpositionsfeldern sein
  recsetSQL1 = "Select PosNr, Art_Beschreibung, Anz_MA, Menge, ME, EZPreis, GesPreis FROM tbltmp_Position order by PosNr"
  ArrFill_DAO_OK1 = ArrFill_DAO(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1, DAOARRAY_Name1)
   'Zusatztabelle mit Feldnamen (Zeile 0) und Feldtypen als Long (Zeile 1) und als Text (Zeile 2)
   'NumArray = Array(dbBigInt, dbBinary, dbBoolean, dbByte, dbChar, dbCurrency, dbDate, dbDecimal, dbDouble, dbFloat, dbGUID, dbInteger, dbLong, dbLongBinary, dbMemo, dbNumeric, dbSingle, dbText, dbTime, dbTimeStamp, dbVarBinary)
   'NumtxtArray = Array("dbBigInt", "dbBinary", "dbBoolean", "dbByte", "dbChar", "dbCurrency", "dbDate", "dbDecimal", "dbDouble", "dbFloat", "dbGUID", "dbInteger", "dbLong", "dbLongBinary", "dbMemo", "dbNumeric", "dbSingle", "dbText", "dbTime", "dbTimeStamp", "dbVarBinary")
   'Info:   'AccessArray(iSpalte,iZeile) <0, 0>       'ExcelArray(iZeile, iSpalte) <1, 1>
    'Tabelle Tabelle_Pos
    If ArrFill_DAO_OK1 Then
    ' i = Anzahl der Überschriftszeilen
        i = 1
        Set wdTab = wdDoc.Bookmarks("Tabelle_Pos").Range.tables(1)
        For iZl = 0 To iZLMax1
            i = i + 1
            'Felder für Word "schön" formatieren....
            For j = 0 To iColMax1
                If DAOARRAY_Name1(j, 1) = dbCurrency Then
                    strErsatz = FormatCurrency(Nz(DAOARRAY1(j, iZl)))
                ElseIf DAOARRAY_Name1(j, 1) = dbDouble Or DAOARRAY_Name1(j, 1) = dbFloat Or DAOARRAY_Name1(j, 1) = dbSingle Then
                    strErsatz = FormatNumber(Nz(DAOARRAY1(j, iZl)), 2)
                Else
                    strErsatz = Nz(DAOARRAY1(j, iZl))
                End If
                '.... bevor der Wert nach Word gesetzt wird
                wdTab.Cell(i, j + 1).Range.Text = strErsatz
            Next j
            If iZl < iZLMax1 Then
                wdTab.rows.Add
            End If
        Next iZl
        Set DAOARRAY1 = Nothing
    End If

'wdApp.ActiveDocument.SaveAs2 Chr(34) & Doc_Save_Pfad_Name & Chr(34)
wdDoc.SaveAs2 Chr(34) & Doc_Save_Pfad_Name & Chr(34)

End Function

Function Ust_Loesch(ustname As String, Doc_Save_Pfad_Name As String)
'Word: Tabellenzeile (mit UstWert = 0) löschen und Dokument sichern
'###################################################################
Dim oTable As Object
Dim oCurrentRow As Object
wdApp.Selection.GoTo What:=wdGoToBookmark, Name:=ustname

If Not wdApp.Selection.Information(wdWithInTable) Then
Exit Function
End If

wdApp.Selection.rows(1).Delete

'wdApp.ActiveDocument.SaveAs2 Chr(34) & Doc_Save_Pfad_Name & Chr(34)
wdDoc.SaveAs2 Chr(34) & Doc_Save_Pfad_Name & Chr(34)

End Function

Function PDF_Print(Doc_Save_Pfad_Name As String)
' Word Dokument als PDF ausgeben
'################################
    Dim i As Long
    Dim strdoc As String
    i = InStrRev(Doc_Save_Pfad_Name, ".")
    If i > 0 Then
        strdoc = Left(Doc_Save_Pfad_Name, i) & "pdf"
        wdDoc.SaveAs2 strdoc, wdFormatPDF   'WdSaveFormat-Enum  - wdFormatPDF - 17
    End If
End Function



Function Reset_Word_Objekt()

Set wdDoc = Nothing
Set wdApp = Nothing

End Function


Function wd_Close_All()

On Error Resume Next

wdApp.Quit False

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

End Function



'For Each myStoryRange In ActiveDocument.StoryRanges
'    With myStoryRange.Find
'        .Text = "string to be searched"
'        .Replacement.Text = "string to be replaced"
'        .Wrap = wdFindContinue
'        .ClearFormatting
'        .Replacement.ClearFormatting
'        .Replacement.Highlight = False
'        .Execute Replace:=wdReplaceAll
'    End With
'Next myStoryRange

''Function PDF_Print(iDokNr As Long)
''    Dim p
''    p = wdApp.ActivePrinter
''    wdApp.ActivePrinter = "PDFCreator"
''    wdApp.Options.PrintBackground = False
''    wdDoc.PrintOut 'Outputfilename:="C:\test\test_" & iDokNr & ".pdf", PrintToFile:=True
''    DoEvents
''    wdApp.ActivePrinter = p
''    Stop
''End Function
'
'
'' neuen COM-Schnittstelle im PDF-Creator 2.
'Sub PdfWithPDFCreatorZwei()
'
'Dim pdfJob              As Object
'Dim printJob            As Object
'Dim wshNetwork          As Object
'
'Dim bolSendAsAttach     As Boolean
'
'Const Drucker1          As String = "PDFCreator"
'Dim Drucker2    '       As String = "Samsung ML-2850 Series"
'
'Drucker2 = wdApp.ActivePrinter
'
'If MsgBox("Soll die Datei nach dem Erstellen versendet werden?", 36, "Senden?") = vbYes Then bolSendAsAttach = True
'
'On Error GoTo Ende
'
'Set pdfJob = CreateObject("PDFCreatorBeta.JobQueue")
'
'    pdfJob.Initialize
'
'Set wshNetwork = CreateObject("WScript.Network")
'    wshNetwork.SetDefaultPrinter Drucker1 'Standarddrucker auf PDFCreator setzen
'
'    Worksheets("Tabelle1").PrintOut
'
'    pdfJob.WaitForJob (10)
'
'    Set printJob = pdfJob.NextJob
'
'        With printJob
'            .SetProfileByGuid ("DefaultGuid")
'
'            If bolSendAsAttach Then
'              .SetProfileSetting "EmailClient.Enabled", "true" 'Datei als Email senden einschalten
'              .SetProfileSetting "EmailClient.Subject", "Test" 'Betreff
'              .SetProfileSetting "EmailClient.Content", "Hallo,<br><br>anbei gewünschte Unterlagen." & _
'                                                        "<br><br>Gruß, Max<br><br>" 'Body
'              .SetProfileSetting "EmailClient.Recipients", "test@server.de;test2@server.de" 'Empfänger
'            End If
'
'            .ConvertTo (Environ("USERPROFILE") & "\Desktop\Test.pdf") 'Pfad und Dateiname für PDF-Datei, und konvertieren
'
'           If .IsFinished = True Then
'              pdfJob.ReleaseCom 'PDFCreator-Instanz beenden
'              wshNetwork.SetDefaultPrinter Drucker2 'Standarddrucker wiederherstellen
'           End If
'        End With
'
'Exit Sub
'
'Ende:
'pdfJob.ReleaseCom
'End Sub
'
'


' Alte PDFCreator Version vor 12.73
'Sub PrintToPDF_Early(iDokNr As Long)
'     'Author       : Ken Puls ([url]www.excelguru.ca[/url])
'     'Macro Purpose: Print to PDF file using PDFCreator
'     '   (Download from [url]http://sourceforge.net/projects/pdfcreator/[/url])
'     '   Designed for early bind, set reference to PDFCreator
'
'
'   Dim pdfJob As PDFCreator.clsPDFCreator
''    Private WithEvents pdfjob As PDFCreator.clsPDFCreator
'    Dim pdfApp As Object
''    Dim pdfjob As Object
'    Dim sPDFName As String
'    Dim sPDFPath As String
'
'
'
'     Dim p
'    p = wdApp.ActivePrinter
'
'     '/// Change the output file name here! ///
'    sPDFName = "test_" & iDokNr & ".pdf"
'    sPDFPath = "C:\Test\"
'    sPDFPath = ActiveDocument.path & Application.PathSeparator
'
''    On Error Resume Next
''    'Set pdfjob = GetObject(, "PDFCreator.clsPDFCreator")
''    Set pdfApp = GetObject(, "PDFCreator")
''    If pdfApp Is Nothing Then
''        Err.Clear
''    '    Set pdfjob = CreateObject("PDFCreator.clsPDFCreator")
''        Set pdfApp = CreateObject("PDFCreator")
''    End If
''    On Error GoTo 0
'
'    'Early Binding
'    Set pdfJob = New PDFCreator.clsPDFCreator
'
'    With pdfJob
'        If .cStart("/NoProcessingAtStartup") = False Then
'            MsgBox "Can't initialize PDFCreator.", vbCritical + _
'            vbOKOnly, "PrtPDFCreator"
'            Exit Sub
'        End If
'        .cOption("UseAutosave") = 1
'        .cOption("UseAutosaveDirectory") = 1
'        .cOption("AutosaveDirectory") = sPDFPath
'        .cOption("AutosaveFilename") = sPDFName
'        .cOption("AutosaveFormat") = 0 ' 0 = PDF
'        .cClearCache
'    End With
'
'     'Print the document to PDF
'    wdApp.ActivePrinter = "PDFCreator"
'    wdDoc.PrintOut
'
'     'Wait until the print job has entered the print queue
'    Do Until pdfJob.cCountOfPrintjobs = 1
'        DoEvents
'    Loop
'    pdfJob.cPrinterStop = False
'
'     'Wait until PDF creator is finished then release the objects
'    Do Until pdfJob.cCountOfPrintjobs = 0
'        DoEvents
'    Loop
'    pdfJob.cClose
'    Set pdfJob = Nothing
'
'    wdApp.ActivePrinter = p
'
'    Stop
'
'End Sub
'


''' ########### VBA Teilstücke

''Dim Doc_Template_Pfad As String
''Dim Doc_Template_Name As String
'
'Function WD_template_Bookmark_Ausles_Test()
'
'Dim iDocNr As Long, Doc_Template_Pfad_Name As String
'
'iDocNr = 1
'Doc_Template_Pfad_Name = "C:\Kunden\CONSEC (Siegert)\Rechnungsschreibung\Neu\CONSEC_Template_Rch.docx"
'
'WD_template_Bookmark_Ausles iDocNr, Doc_Template_Pfad_Name
'
'End Function
'
'
'Function WD_template_Bookmark_Ausles(iDocNr As Long, Doc_Template_Pfad_Name As String)
'
'Dim tTmp As String
'
'Dim Bmk() As String
'Dim x As Integer, J As Integer
'
'Dim Fill_Tbl_OK1 As Boolean, recsetSQL1 As String, InArray1
'
''Doc_Template_Pfad = "C:\Kunden\CONSEC (Siegert)\Rechnungsschreibung\Neu\"
''Doc_Template_Name = "CONSEC_Template_Rch.docx"
'
'On Error Resume Next
'Set wdApp = GetObject(, "Word.Application")
'If wdApp Is Nothing Then
'    Err.Clear
'    Set wdApp = CreateObject("Word.Application")
'End If
'On Error GoTo 0
'
'tTmp = Doc_Template_Pfad_Name
'Set wdDoc = wdApp.Documents.Add(tTmp)
'
''wdApp.Visible = False
'wdApp.Visible = True
''wdApp.ScreenUpdating = False   ' buggy - dont use
''wdApp.Visible = False
'
'x = wdDoc.Bookmarks.count
'ReDim Bmk(2, x - 1)
'For J = 0 To x - 1
'    Bmk(0, J) = iDocNr
'    Bmk(1, J) = Nz(wdDoc.Bookmarks(J + 1).Name)
'    Bmk(2, J) = Nz(wdDoc.Bookmarks(J + 1).Range.Text)
'Next J
'
'recsetSQL1 = "SELECT DOkNr, Bookmark_Name, Bookmark_Content FROM tbl_Textbaustein_Dokumente"
'
''  0 = ID
''  1 = Pfad
''  2 = Name
''  3 = Bookmark_Name
''  4 = Bookmark_Content
'
'Fill_Tbl_OK1 = Fill_Tbl(recsetSQL1, Bmk)
'''Info:   'AccessArray(iSpalte,iZeile) <0, 0>       'ExcelArray(iZeile, iSpalte) <1, 1>
'
'End Function



'            Set wdRng = wdDoc.Range
'            'Maximum limit of a string is 2 billion characters.
'            'So, hopefully your document is not bigger than that.  However, expect declining performance based on how big doucment is
'             wdRng.Text = documentText
'
'
'
'            'x = wdDoc.Bookmarks.count
'            'ReDim Preserve Bmk(2, x - 1)
'            'For J = 0 To x - 1
'            '    Bmk(0, J) = 1
'            '    Bmk(1, J) = Nz(wdDoc.Bookmarks(J + 1).Name)
'            '    Bmk(2, J) = Nz(wdDoc.Bookmarks(J + 1).Range.Text)
'            'Next J


'Sub findTest()
'
'    Dim firstTerm As String
'    Dim secondTerm As String
'    Dim myRange As Range
'    Dim documentText As String
'
'    Dim startPos As Long 'Stores the starting position of firstTerm
'    Dim stopPos As Long 'Stores the starting position of secondTerm based on first term's location
'    Dim nextPosition As Long 'The next position to search for the firstTerm
'
'    nextPosition = 1
'
'    'First and Second terms as defined by your example.  Obviously, this will have to be more dynamic
'    'if you want to parse more than justpatientFirstname.
'    firstTerm = "["
'    secondTerm = "]"
'
'    'Get all the document text and store it in a variable.
'    Set wdRng = wdDoc.Range
'    'Maximum limit of a string is 2 billion characters.
'    'So, hopefully your document is not bigger than that.  However, expect declining performance based on how big doucment is
'    documentText = wdRng.Text
'
'    'Loop documentText till you can't find any more matching "terms"
'    Do Until nextPosition = 0
'        startPos = InStr(nextPosition, documentText, firstTerm, vbTextCompare)
'        stopPos = InStr(startPos, documentText, secondTerm, vbTextCompare)
'        Debug.Print Mid$(documentText, startPos + Len(firstTerm), stopPos - startPos - Len(secondTerm))
'        nextPosition = InStr(stopPos, documentText, firstTerm, vbTextCompare)
'    Loop
'
'    MsgBox "I'm done"
'
'End Sub



'Sub ReplaceWithBookmarks()
'    Dim rng As Range
'    Dim iBookmarkSuffix As Integer
'    Dim strBookMarkPrefix
'
'    strBookMarkPrefix = "BM"
'
'    Set rng = ActiveDocument.Range
'    With rng.Find
'        .Text = "XXX"
'        Do While .Execute
'            rng.Text = "" 'clear the "XXX" (optional)
'            iBookmarkSuffix = iBookmarkSuffix + 1
'            ActiveDocument.Bookmarks.Add strBookMarkPrefix & iBookmarkSuffix, rng
'        Loop
'    End With
'End Sub


'With ActiveDocument.Range.Find
'    .Text = "Suchtext"
'    .Replacement.Text = "neuer Text"
'    .Execute
'End With
'
'
'Dim orng As Range
'Set orng = ActiveDocument.Range
'orng.Start = orng.Bookmarks("StartBM").Range.End
'orng.End = orng.Bookmarks("EndBM").Range.Start
'orng.Select
Option Explicit

Dim accApp, dbPath, fso, outputPath

dbPath = "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"
outputPath = "C:\Users\guenther.siegert\Documents\AccessExport\"

Set fso = CreateObject("Scripting.FileSystemObject")

' Beende alle Access Prozesse
On Error Resume Next
Dim objWMI, colProcesses, objProcess
Set objWMI = GetObject("winmgmts:\\.\root\cimv2")
Set colProcesses = objWMI.ExecQuery("SELECT * FROM Win32_Process WHERE Name = 'MSACCESS.EXE'")
For Each objProcess in colProcesses
    objProcess.Terminate()
Next
On Error GoTo 0

WScript.Sleep 3000

Set accApp = CreateObject("Access.Application")
accApp.Visible = True
accApp.OpenCurrentDatabase dbPath
WScript.Sleep 5000

On Error Resume Next

' Erstelle neues Modul fuer Excel-Import
Dim vbe, proj, comp, codeModule

Set vbe = accApp.VBE
Set proj = vbe.VBProjects(1)

' Pruefe ob Modul bereits existiert
Dim moduleExists
moduleExists = False
For Each comp In proj.VBComponents
    If comp.Name = "mdl_PositionslistenImport" Then
        moduleExists = True
        Set codeModule = comp.CodeModule
        Exit For
    End If
Next

If Not moduleExists Then
    Set comp = proj.VBComponents.Add(1) ' vbext_ct_StdModule
    comp.Name = "mdl_PositionslistenImport"
    Set codeModule = comp.CodeModule
    WScript.Echo "Modul mdl_PositionslistenImport erstellt"
End If

' Loesche bestehenden Code und fuege neuen ein
If codeModule.CountOfLines > 0 Then
    codeModule.DeleteLines 1, codeModule.CountOfLines
End If

Dim importCode
importCode = "Option Compare Database" & vbCrLf & _
"Option Explicit" & vbCrLf & vbCrLf & _
"' Excel-Import fuer Positionslisten" & vbCrLf & _
"' Erwartet Excel-Datei mit Spalten: PosNr, Gruppe, Zusatztext, Zeit1, Zeit2, Zeit3, Zeit4" & vbCrLf & vbCrLf & _
"Public Sub ImportPositionslisteFromExcel(strFilePath As String, lngObjektID As Long)" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    Dim xlApp As Object" & vbCrLf & _
"    Dim xlWb As Object" & vbCrLf & _
"    Dim xlWs As Object" & vbCrLf & _
"    Dim db As DAO.Database" & vbCrLf & _
"    Dim rs As DAO.Recordset" & vbCrLf & _
"    Dim lngRow As Long" & vbCrLf & _
"    Dim lngLastRow As Long" & vbCrLf & _
"    Dim lngImported As Long" & vbCrLf & _
"    Dim strSQL As String" & vbCrLf & _
"    " & vbCrLf & _
"    ' Pruefe ob Objekt-ID gueltig" & vbCrLf & _
"    If lngObjektID = 0 Then" & vbCrLf & _
"        MsgBox ""Bitte erst ein Objekt auswaehlen!"", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    ' Excel oeffnen" & vbCrLf & _
"    Set xlApp = CreateObject(""Excel.Application"")" & vbCrLf & _
"    xlApp.Visible = False" & vbCrLf & _
"    xlApp.DisplayAlerts = False" & vbCrLf & _
"    " & vbCrLf & _
"    Set xlWb = xlApp.Workbooks.Open(strFilePath)" & vbCrLf & _
"    Set xlWs = xlWb.Sheets(1)" & vbCrLf & _
"    " & vbCrLf & _
"    ' Letzte Zeile finden" & vbCrLf & _
"    lngLastRow = xlWs.Cells(xlWs.Rows.Count, 1).End(-4162).Row ' xlUp = -4162" & vbCrLf & _
"    " & vbCrLf & _
"    Set db = CurrentDb" & vbCrLf & _
"    Set rs = db.OpenRecordset(""tbl_OB_Objekt_Positionen"", dbOpenDynaset)" & vbCrLf & _
"    " & vbCrLf & _
"    lngImported = 0" & vbCrLf & _
"    " & vbCrLf & _
"    ' Ab Zeile 2 (Zeile 1 = Header)" & vbCrLf & _
"    For lngRow = 2 To lngLastRow" & vbCrLf & _
"        ' Pruefe ob Zeile Daten enthaelt" & vbCrLf & _
"        If Not IsEmpty(xlWs.Cells(lngRow, 1).Value) Then" & vbCrLf & _
"            rs.AddNew" & vbCrLf & _
"            rs!OB_Objekt_Kopf_ID = lngObjektID" & vbCrLf & _
"            rs!PosNr = Nz(xlWs.Cells(lngRow, 1).Value, lngRow - 1)" & vbCrLf & _
"            rs!Gruppe = Nz(xlWs.Cells(lngRow, 2).Value, """")" & vbCrLf & _
"            rs!Zusatztext = Nz(xlWs.Cells(lngRow, 3).Value, """")" & vbCrLf & _
"            rs!Zeit1 = Nz(xlWs.Cells(lngRow, 4).Value, 0)" & vbCrLf & _
"            rs!Zeit2 = Nz(xlWs.Cells(lngRow, 5).Value, 0)" & vbCrLf & _
"            rs!Zeit3 = Nz(xlWs.Cells(lngRow, 6).Value, 0)" & vbCrLf & _
"            rs!Zeit4 = Nz(xlWs.Cells(lngRow, 7).Value, 0)" & vbCrLf & _
"            rs!Sort = lngRow - 1" & vbCrLf & _
"            rs.Update" & vbCrLf & _
"            lngImported = lngImported + 1" & vbCrLf & _
"        End If" & vbCrLf & _
"    Next lngRow" & vbCrLf & _
"    " & vbCrLf & _
"    rs.Close" & vbCrLf & _
"    xlWb.Close False" & vbCrLf & _
"    xlApp.Quit" & vbCrLf & _
"    " & vbCrLf & _
"    Set rs = Nothing" & vbCrLf & _
"    Set db = Nothing" & vbCrLf & _
"    Set xlWs = Nothing" & vbCrLf & _
"    Set xlWb = Nothing" & vbCrLf & _
"    Set xlApp = Nothing" & vbCrLf & _
"    " & vbCrLf & _
"    MsgBox lngImported & "" Positionen erfolgreich importiert!"", vbInformation" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    If Not rs Is Nothing Then rs.Close" & vbCrLf & _
"    If Not xlWb Is Nothing Then xlWb.Close False" & vbCrLf & _
"    If Not xlApp Is Nothing Then xlApp.Quit" & vbCrLf & _
"    MsgBox ""Fehler beim Import: "" & Err.Description, vbCritical" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Public Sub ImportPositionslisteDialog(lngObjektID As Long)" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    Dim fd As Object" & vbCrLf & _
"    Dim strFile As String" & vbCrLf & _
"    Dim intChoice As Integer" & vbCrLf & _
"    " & vbCrLf & _
"    If lngObjektID = 0 Then" & vbCrLf & _
"        MsgBox ""Bitte erst ein Objekt auswaehlen!"", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    ' Frage ob bestehende Positionen geloescht werden sollen" & vbCrLf & _
"    intChoice = MsgBox(""Sollen die bestehenden Positionen vor dem Import geloescht werden?"" & vbCrLf & vbCrLf & _" & vbCrLf & _
"        ""Ja = Alle bestehenden Positionen loeschen"" & vbCrLf & _" & vbCrLf & _
"        ""Nein = Neue Positionen hinzufuegen"" & vbCrLf & _" & vbCrLf & _
"        ""Abbrechen = Import abbrechen"", vbYesNoCancel + vbQuestion, ""Positionsliste importieren"")" & vbCrLf & _
"    " & vbCrLf & _
"    If intChoice = vbCancel Then Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"    If intChoice = vbYes Then" & vbCrLf & _
"        ' Bestehende Positionen loeschen" & vbCrLf & _
"        CurrentDb.Execute ""DELETE FROM tbl_OB_Objekt_Positionen WHERE OB_Objekt_Kopf_ID = "" & lngObjektID" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    ' FileDialog oeffnen" & vbCrLf & _
"    Set fd = Application.FileDialog(1) ' msoFileDialogFilePicker" & vbCrLf & _
"    fd.Title = ""Excel-Positionsliste auswaehlen""" & vbCrLf & _
"    fd.Filters.Clear" & vbCrLf & _
"    fd.Filters.Add ""Excel-Dateien"", ""*.xlsx;*.xls""" & vbCrLf & _
"    fd.AllowMultiSelect = False" & vbCrLf & _
"    " & vbCrLf & _
"    If fd.Show = -1 Then" & vbCrLf & _
"        strFile = fd.SelectedItems(1)" & vbCrLf & _
"        ImportPositionslisteFromExcel strFile, lngObjektID" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    MsgBox ""Fehler: "" & Err.Description, vbCritical" & vbCrLf & _
"End Sub"

codeModule.InsertLines 1, importCode

If Err.Number <> 0 Then
    WScript.Echo "Fehler beim Erstellen des Moduls: " & Err.Description
Else
    WScript.Echo "Excel-Import Modul erfolgreich erstellt"
End If

' Jetzt den Button-Code im Formular aktualisieren
WScript.Echo "Aktualisiere Button-Code in frm_OB_Objekt..."

For Each comp In proj.VBComponents
    If comp.Name = "Form_frm_OB_Objekt" Then
        Set codeModule = comp.CodeModule
        Dim lineCount, i, lineText
        lineCount = codeModule.CountOfLines

        ' Suche nach btnUploadPositionen_Click
        For i = 1 To lineCount
            lineText = codeModule.Lines(i, 1)
            If InStr(lineText, "btnUploadPositionen_Click") > 0 And InStr(lineText, "Private Sub") > 0 Then
                WScript.Echo "btnUploadPositionen_Click gefunden in Zeile " & i

                ' Finde End Sub
                Dim endLine
                For endLine = i + 1 To lineCount
                    If InStr(codeModule.Lines(endLine, 1), "End Sub") > 0 Then
                        ' Loesche alte Prozedur
                        codeModule.DeleteLines i, endLine - i + 1

                        ' Fuege neue Prozedur ein
                        Dim newButtonCode
                        newButtonCode = "Private Sub btnUploadPositionen_Click()" & vbCrLf & _
                            "    On Error GoTo ErrHandler" & vbCrLf & _
                            "    " & vbCrLf & _
                            "    Dim lngObjektID As Long" & vbCrLf & _
                            "    lngObjektID = Nz(Me.ID, 0)" & vbCrLf & _
                            "    " & vbCrLf & _
                            "    If lngObjektID = 0 Then" & vbCrLf & _
                            "        MsgBox ""Bitte erst ein Objekt auswaehlen!"", vbExclamation" & vbCrLf & _
                            "        Exit Sub" & vbCrLf & _
                            "    End If" & vbCrLf & _
                            "    " & vbCrLf & _
                            "    ' Import-Dialog aufrufen" & vbCrLf & _
                            "    ImportPositionslisteDialog lngObjektID" & vbCrLf & _
                            "    " & vbCrLf & _
                            "    ' Unterformular aktualisieren" & vbCrLf & _
                            "    Me.sub_OB_Objekt_Positionen.Requery" & vbCrLf & _
                            "    " & vbCrLf & _
                            "    Exit Sub" & vbCrLf & _
                            "    " & vbCrLf & _
                            "ErrHandler:" & vbCrLf & _
                            "    MsgBox ""Fehler: "" & Err.Description, vbCritical" & vbCrLf & _
                            "End Sub"

                        codeModule.InsertLines i, newButtonCode
                        WScript.Echo "Button-Code aktualisiert"
                        Exit For
                    End If
                Next
                Exit For
            End If
        Next
        Exit For
    End If
Next

On Error GoTo 0

accApp.CloseCurrentDatabase
accApp.Quit
Set accApp = Nothing

WScript.Echo "Fertig"

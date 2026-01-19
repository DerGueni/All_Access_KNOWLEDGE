Option Explicit

Dim accApp, dbPath, fso

dbPath = "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"

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

Dim vbe, proj, comp, codeModule

Set vbe = accApp.VBE
Set proj = vbe.VBProjects(1)

' ========================================
' FEATURE 1: Excel-Export
' ========================================
WScript.Echo "=== Feature 1: Excel-Export ==="

Dim exportModuleExists
exportModuleExists = False

For Each comp In proj.VBComponents
    If comp.Name = "mdl_PositionslistenExport" Then
        exportModuleExists = True
        Set codeModule = comp.CodeModule
        Exit For
    End If
Next

If Not exportModuleExists Then
    Set comp = proj.VBComponents.Add(1)
    comp.Name = "mdl_PositionslistenExport"
    Set codeModule = comp.CodeModule
    WScript.Echo "Modul mdl_PositionslistenExport erstellt"
End If

If codeModule.CountOfLines > 0 Then
    codeModule.DeleteLines 1, codeModule.CountOfLines
End If

Dim exportCode
exportCode = "Option Compare Database" & vbCrLf & _
"Option Explicit" & vbCrLf & vbCrLf & _
"' Excel-Export fuer Positionslisten" & vbCrLf & vbCrLf & _
"Public Sub ExportPositionslisteToExcel(lngObjektID As Long)" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    If lngObjektID = 0 Then" & vbCrLf & _
"        MsgBox ""Bitte erst ein Objekt auswaehlen!"", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    Dim xlApp As Object, xlWb As Object, xlWs As Object" & vbCrLf & _
"    Dim db As DAO.Database, rs As DAO.Recordset" & vbCrLf & _
"    Dim strSQL As String, strObjektNr As String" & vbCrLf & _
"    Dim lngRow As Long" & vbCrLf & _
"    Dim strFileName As String" & vbCrLf & _
"    Dim fd As Object" & vbCrLf & _
"    " & vbCrLf & _
"    ' Objektnummer holen" & vbCrLf & _
"    strObjektNr = Nz(DLookup(""ObjektNr"", ""tbl_OB_Objekt"", ""ID = "" & lngObjektID), ""Objekt_"" & lngObjektID)" & vbCrLf & _
"    " & vbCrLf & _
"    ' Speichern-Dialog" & vbCrLf & _
"    Set fd = Application.FileDialog(2) ' msoFileDialogSaveAs" & vbCrLf & _
"    fd.Title = ""Positionsliste speichern als""" & vbCrLf & _
"    fd.InitialFileName = ""Positionsliste_"" & strObjektNr & ""_"" & Format(Now, ""yyyymmdd"") & "".xlsx""" & vbCrLf & _
"    " & vbCrLf & _
"    If fd.Show <> -1 Then Exit Sub" & vbCrLf & _
"    strFileName = fd.SelectedItems(1)" & vbCrLf & _
"    If Right(LCase(strFileName), 5) <> "".xlsx"" Then strFileName = strFileName & "".xlsx""" & vbCrLf & _
"    " & vbCrLf & _
"    ' Excel starten" & vbCrLf & _
"    Set xlApp = CreateObject(""Excel.Application"")" & vbCrLf & _
"    xlApp.Visible = False" & vbCrLf & _
"    xlApp.DisplayAlerts = False" & vbCrLf & _
"    Set xlWb = xlApp.Workbooks.Add" & vbCrLf & _
"    Set xlWs = xlWb.Sheets(1)" & vbCrLf & _
"    xlWs.Name = ""Positionen""" & vbCrLf & _
"    " & vbCrLf & _
"    ' Header schreiben" & vbCrLf & _
"    xlWs.Cells(1, 1).Value = ""PosNr""" & vbCrLf & _
"    xlWs.Cells(1, 2).Value = ""Gruppe""" & vbCrLf & _
"    xlWs.Cells(1, 3).Value = ""Zusatztext""" & vbCrLf & _
"    xlWs.Cells(1, 4).Value = Nz(DLookup(""Zeit1_Label"", ""tbl_OB_Objekt"", ""ID = "" & lngObjektID), ""Zeit1"")" & vbCrLf & _
"    xlWs.Cells(1, 5).Value = Nz(DLookup(""Zeit2_Label"", ""tbl_OB_Objekt"", ""ID = "" & lngObjektID), ""Zeit2"")" & vbCrLf & _
"    xlWs.Cells(1, 6).Value = Nz(DLookup(""Zeit3_Label"", ""tbl_OB_Objekt"", ""ID = "" & lngObjektID), ""Zeit3"")" & vbCrLf & _
"    xlWs.Cells(1, 7).Value = Nz(DLookup(""Zeit4_Label"", ""tbl_OB_Objekt"", ""ID = "" & lngObjektID), ""Zeit4"")" & vbCrLf & _
"    xlWs.Cells(1, 8).Value = ""Gesamt""" & vbCrLf & _
"    " & vbCrLf & _
"    ' Header formatieren" & vbCrLf & _
"    xlWs.Range(""A1:H1"").Font.Bold = True" & vbCrLf & _
"    xlWs.Range(""A1:H1"").Interior.Color = RGB(200, 200, 200)" & vbCrLf & _
"    " & vbCrLf & _
"    ' Daten holen" & vbCrLf & _
"    Set db = CurrentDb" & vbCrLf & _
"    strSQL = ""SELECT PosNr, Gruppe, Zusatztext, Zeit1, Zeit2, Zeit3, Zeit4 "" & _" & vbCrLf & _
"             ""FROM tbl_OB_Objekt_Positionen WHERE OB_Objekt_Kopf_ID = "" & lngObjektID & _" & vbCrLf & _
"             "" ORDER BY Sort, PosNr""" & vbCrLf & _
"    Set rs = db.OpenRecordset(strSQL)" & vbCrLf & _
"    " & vbCrLf & _
"    lngRow = 2" & vbCrLf & _
"    Do While Not rs.EOF" & vbCrLf & _
"        xlWs.Cells(lngRow, 1).Value = Nz(rs!PosNr, lngRow - 1)" & vbCrLf & _
"        xlWs.Cells(lngRow, 2).Value = Nz(rs!Gruppe, """")" & vbCrLf & _
"        xlWs.Cells(lngRow, 3).Value = Nz(rs!Zusatztext, """")" & vbCrLf & _
"        xlWs.Cells(lngRow, 4).Value = Nz(rs!Zeit1, 0)" & vbCrLf & _
"        xlWs.Cells(lngRow, 5).Value = Nz(rs!Zeit2, 0)" & vbCrLf & _
"        xlWs.Cells(lngRow, 6).Value = Nz(rs!Zeit3, 0)" & vbCrLf & _
"        xlWs.Cells(lngRow, 7).Value = Nz(rs!Zeit4, 0)" & vbCrLf & _
"        xlWs.Cells(lngRow, 8).Formula = ""=SUM(D"" & lngRow & "":G"" & lngRow & "")""" & vbCrLf & _
"        lngRow = lngRow + 1" & vbCrLf & _
"        rs.MoveNext" & vbCrLf & _
"    Loop" & vbCrLf & _
"    rs.Close" & vbCrLf & _
"    " & vbCrLf & _
"    ' Summenzeile" & vbCrLf & _
"    If lngRow > 2 Then" & vbCrLf & _
"        xlWs.Cells(lngRow, 3).Value = ""SUMME:""" & vbCrLf & _
"        xlWs.Cells(lngRow, 3).Font.Bold = True" & vbCrLf & _
"        xlWs.Cells(lngRow, 4).Formula = ""=SUM(D2:D"" & (lngRow - 1) & "")""" & vbCrLf & _
"        xlWs.Cells(lngRow, 5).Formula = ""=SUM(E2:E"" & (lngRow - 1) & "")""" & vbCrLf & _
"        xlWs.Cells(lngRow, 6).Formula = ""=SUM(F2:F"" & (lngRow - 1) & "")""" & vbCrLf & _
"        xlWs.Cells(lngRow, 7).Formula = ""=SUM(G2:G"" & (lngRow - 1) & "")""" & vbCrLf & _
"        xlWs.Cells(lngRow, 8).Formula = ""=SUM(H2:H"" & (lngRow - 1) & "")""" & vbCrLf & _
"        xlWs.Range(""A"" & lngRow & "":H"" & lngRow).Font.Bold = True" & vbCrLf & _
"        xlWs.Range(""A"" & lngRow & "":H"" & lngRow).Interior.Color = RGB(220, 220, 220)" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    ' Spaltenbreite anpassen" & vbCrLf & _
"    xlWs.Columns(""A:H"").AutoFit" & vbCrLf & _
"    " & vbCrLf & _
"    ' Speichern" & vbCrLf & _
"    xlWb.SaveAs strFileName, 51 ' xlOpenXMLWorkbook" & vbCrLf & _
"    xlWb.Close False" & vbCrLf & _
"    xlApp.Quit" & vbCrLf & _
"    " & vbCrLf & _
"    Set rs = Nothing: Set db = Nothing" & vbCrLf & _
"    Set xlWs = Nothing: Set xlWb = Nothing: Set xlApp = Nothing" & vbCrLf & _
"    " & vbCrLf & _
"    MsgBox ""Positionsliste erfolgreich exportiert!"" & vbCrLf & strFileName, vbInformation" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    If Not rs Is Nothing Then rs.Close" & vbCrLf & _
"    If Not xlWb Is Nothing Then xlWb.Close False" & vbCrLf & _
"    If Not xlApp Is Nothing Then xlApp.Quit" & vbCrLf & _
"    MsgBox ""Fehler beim Export: "" & Err.Description, vbCritical" & vbCrLf & _
"End Sub"

codeModule.InsertLines 1, exportCode
WScript.Echo "Excel-Export Code eingefuegt"

' ========================================
' FEATURE 2: Verbesserte Zeit-Validierung
' ========================================
WScript.Echo "=== Feature 2: Verbesserte Zeit-Validierung ==="

' Aktualisiere mdl_ZeitHeader mit Validierungsfunktion
For Each comp In proj.VBComponents
    If comp.Name = "mdl_ZeitHeader" Then
        Set codeModule = comp.CodeModule

        ' Fuege Validierungsfunktion am Ende hinzu
        Dim validationCode
        validationCode = vbCrLf & vbCrLf & _
"' Validiert einen Zeit-Wert (max 24 Stunden)" & vbCrLf & _
"Public Function ValidateZeitWert(ByVal varValue As Variant, ByRef strMsg As String) As Boolean" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    ValidateZeitWert = True" & vbCrLf & _
"    strMsg = """"" & vbCrLf & _
"    " & vbCrLf & _
"    If IsNull(varValue) Or varValue = """" Then Exit Function" & vbCrLf & _
"    " & vbCrLf & _
"    ' Muss numerisch sein" & vbCrLf & _
"    If Not IsNumeric(varValue) Then" & vbCrLf & _
"        ValidateZeitWert = False" & vbCrLf & _
"        strMsg = ""Bitte nur Zahlen eingeben!""" & vbCrLf & _
"        Exit Function" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    Dim lngVal As Long" & vbCrLf & _
"    lngVal = CLng(varValue)" & vbCrLf & _
"    " & vbCrLf & _
"    ' Keine negativen Werte" & vbCrLf & _
"    If lngVal < 0 Then" & vbCrLf & _
"        ValidateZeitWert = False" & vbCrLf & _
"        strMsg = ""Negative Werte sind nicht erlaubt!""" & vbCrLf & _
"        Exit Function" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    ' Warnung bei mehr als 24 Stunden" & vbCrLf & _
"    If lngVal > 24 Then" & vbCrLf & _
"        If MsgBox(""Der eingegebene Wert ("" & lngVal & "" Stunden) ist ungewoehnlich hoch."" & vbCrLf & _" & vbCrLf & _
"                  ""Moechten Sie diesen Wert trotzdem speichern?"", vbYesNo + vbQuestion) = vbNo Then" & vbCrLf & _
"            ValidateZeitWert = False" & vbCrLf & _
"            strMsg = ""Eingabe abgebrochen""" & vbCrLf & _
"            Exit Function" & vbCrLf & _
"        End If" & vbCrLf & _
"    End If" & vbCrLf & _
"End Function"

        codeModule.InsertLines codeModule.CountOfLines + 1, validationCode
        WScript.Echo "Validierungsfunktion zu mdl_ZeitHeader hinzugefuegt"
        Exit For
    End If
Next

' ========================================
' FEATURE 4, 5: Kopieren und Vorlagen
' ========================================
WScript.Echo "=== Feature 4 & 5: Kopieren und Vorlagen ==="

Dim vorlagenModuleExists
vorlagenModuleExists = False

For Each comp In proj.VBComponents
    If comp.Name = "mdl_PositionsVorlagen" Then
        vorlagenModuleExists = True
        Set codeModule = comp.CodeModule
        Exit For
    End If
Next

If Not vorlagenModuleExists Then
    Set comp = proj.VBComponents.Add(1)
    comp.Name = "mdl_PositionsVorlagen"
    Set codeModule = comp.CodeModule
    WScript.Echo "Modul mdl_PositionsVorlagen erstellt"
End If

If codeModule.CountOfLines > 0 Then
    codeModule.DeleteLines 1, codeModule.CountOfLines
End If

Dim vorlagenCode
vorlagenCode = "Option Compare Database" & vbCrLf & _
"Option Explicit" & vbCrLf & vbCrLf & _
"' Modul fuer Positionslisten-Vorlagen und Kopieren" & vbCrLf & vbCrLf & _
"' FEATURE 4: Kopiert Positionen von einem Objekt zu einem anderen" & vbCrLf & _
"Public Sub KopierePositionen(lngQuellObjektID As Long, lngZielObjektID As Long, Optional blnLoescheZiel As Boolean = False)" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    If lngQuellObjektID = 0 Or lngZielObjektID = 0 Then" & vbCrLf & _
"        MsgBox ""Quell- und Ziel-Objekt muessen angegeben werden!"", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    If lngQuellObjektID = lngZielObjektID Then" & vbCrLf & _
"        MsgBox ""Quell- und Ziel-Objekt duerfen nicht identisch sein!"", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    Dim db As DAO.Database" & vbCrLf & _
"    Set db = CurrentDb" & vbCrLf & _
"    " & vbCrLf & _
"    ' Optional: Bestehende Positionen im Ziel loeschen" & vbCrLf & _
"    If blnLoescheZiel Then" & vbCrLf & _
"        db.Execute ""DELETE FROM tbl_OB_Objekt_Positionen WHERE OB_Objekt_Kopf_ID = "" & lngZielObjektID" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    ' Positionen kopieren" & vbCrLf & _
"    Dim strSQL As String" & vbCrLf & _
"    strSQL = ""INSERT INTO tbl_OB_Objekt_Positionen "" & _" & vbCrLf & _
"             ""(OB_Objekt_Kopf_ID, PosNr, Gruppe, Zusatztext, Zeit1, Zeit2, Zeit3, Zeit4, Sort) "" & _" & vbCrLf & _
"             ""SELECT "" & lngZielObjektID & "", PosNr, Gruppe, Zusatztext, Zeit1, Zeit2, Zeit3, Zeit4, Sort "" & _" & vbCrLf & _
"             ""FROM tbl_OB_Objekt_Positionen WHERE OB_Objekt_Kopf_ID = "" & lngQuellObjektID" & vbCrLf & _
"    db.Execute strSQL" & vbCrLf & _
"    " & vbCrLf & _
"    MsgBox db.RecordsAffected & "" Positionen erfolgreich kopiert!"", vbInformation" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    MsgBox ""Fehler beim Kopieren: "" & Err.Description, vbCritical" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"' Dialog zum Kopieren von Positionen" & vbCrLf & _
"Public Sub KopierePositionenDialog(lngAktuellesObjektID As Long)" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    If lngAktuellesObjektID = 0 Then" & vbCrLf & _
"        MsgBox ""Bitte erst ein Objekt auswaehlen!"", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    ' Oeffne Auswahl-Formular" & vbCrLf & _
"    DoCmd.OpenForm ""frm_PositionenKopieren"", , , , , acDialog, lngAktuellesObjektID" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    MsgBox ""Fehler: "" & Err.Description, vbCritical" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"' FEATURE 5: Speichert aktuelle Positionen als Vorlage" & vbCrLf & _
"Public Sub SpeichereAlsVorlage(lngObjektID As Long)" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    If lngObjektID = 0 Then" & vbCrLf & _
"        MsgBox ""Bitte erst ein Objekt auswaehlen!"", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    Dim strVorlageName As String" & vbCrLf & _
"    strVorlageName = InputBox(""Bitte geben Sie einen Namen fuer die Vorlage ein:"", ""Vorlage speichern"")" & vbCrLf & _
"    " & vbCrLf & _
"    If strVorlageName = """" Then Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"    Dim db As DAO.Database" & vbCrLf & _
"    Dim lngVorlageID As Long" & vbCrLf & _
"    Set db = CurrentDb" & vbCrLf & _
"    " & vbCrLf & _
"    ' Pruefe ob Vorlagen-Tabelle existiert" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    db.Execute ""SELECT TOP 1 * FROM tbl_Positions_Vorlagen""" & vbCrLf & _
"    If Err.Number <> 0 Then" & vbCrLf & _
"        Err.Clear" & vbCrLf & _
"        ' Tabelle erstellen" & vbCrLf & _
"        db.Execute ""CREATE TABLE tbl_Positions_Vorlagen (ID AUTOINCREMENT PRIMARY KEY, VorlageName TEXT(100), ErstelltAm DATETIME, ErstelltVon TEXT(50))""" & vbCrLf & _
"        db.Execute ""CREATE TABLE tbl_Positions_Vorlagen_Details (ID AUTOINCREMENT PRIMARY KEY, Vorlage_ID LONG, PosNr INTEGER, Gruppe TEXT(100), Zusatztext TEXT(255), Zeit1 INTEGER, Zeit2 INTEGER, Zeit3 INTEGER, Zeit4 INTEGER, Sort INTEGER)""" & vbCrLf & _
"    End If" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    ' Vorlage-Kopf erstellen" & vbCrLf & _
"    db.Execute ""INSERT INTO tbl_Positions_Vorlagen (VorlageName, ErstelltAm, ErstelltVon) VALUES ("" & _" & vbCrLf & _
"               ""'"" & strVorlageName & ""', Now(), '"" & Environ(""USERNAME"") & ""')""" & vbCrLf & _
"    lngVorlageID = DMax(""ID"", ""tbl_Positions_Vorlagen"")" & vbCrLf & _
"    " & vbCrLf & _
"    ' Positionen kopieren" & vbCrLf & _
"    db.Execute ""INSERT INTO tbl_Positions_Vorlagen_Details "" & _" & vbCrLf & _
"               ""(Vorlage_ID, PosNr, Gruppe, Zusatztext, Zeit1, Zeit2, Zeit3, Zeit4, Sort) "" & _" & vbCrLf & _
"               ""SELECT "" & lngVorlageID & "", PosNr, Gruppe, Zusatztext, Zeit1, Zeit2, Zeit3, Zeit4, Sort "" & _" & vbCrLf & _
"               ""FROM tbl_OB_Objekt_Positionen WHERE OB_Objekt_Kopf_ID = "" & lngObjektID" & vbCrLf & _
"    " & vbCrLf & _
"    MsgBox ""Vorlage '"" & strVorlageName & ""' mit "" & db.RecordsAffected & "" Positionen gespeichert!"", vbInformation" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    MsgBox ""Fehler beim Speichern: "" & Err.Description, vbCritical" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"' Laedt eine Vorlage in ein Objekt" & vbCrLf & _
"Public Sub LadeVorlage(lngVorlageID As Long, lngZielObjektID As Long, Optional blnLoescheZiel As Boolean = True)" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    If lngVorlageID = 0 Or lngZielObjektID = 0 Then" & vbCrLf & _
"        MsgBox ""Vorlage und Ziel-Objekt muessen angegeben werden!"", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    Dim db As DAO.Database" & vbCrLf & _
"    Set db = CurrentDb" & vbCrLf & _
"    " & vbCrLf & _
"    If blnLoescheZiel Then" & vbCrLf & _
"        db.Execute ""DELETE FROM tbl_OB_Objekt_Positionen WHERE OB_Objekt_Kopf_ID = "" & lngZielObjektID" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    db.Execute ""INSERT INTO tbl_OB_Objekt_Positionen "" & _" & vbCrLf & _
"               ""(OB_Objekt_Kopf_ID, PosNr, Gruppe, Zusatztext, Zeit1, Zeit2, Zeit3, Zeit4, Sort) "" & _" & vbCrLf & _
"               ""SELECT "" & lngZielObjektID & "", PosNr, Gruppe, Zusatztext, Zeit1, Zeit2, Zeit3, Zeit4, Sort "" & _" & vbCrLf & _
"               ""FROM tbl_Positions_Vorlagen_Details WHERE Vorlage_ID = "" & lngVorlageID" & vbCrLf & _
"    " & vbCrLf & _
"    MsgBox db.RecordsAffected & "" Positionen aus Vorlage geladen!"", vbInformation" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    MsgBox ""Fehler beim Laden: "" & Err.Description, vbCritical" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"' Dialog zum Laden einer Vorlage" & vbCrLf & _
"Public Sub LadeVorlageDialog(lngZielObjektID As Long)" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    If lngZielObjektID = 0 Then" & vbCrLf & _
"        MsgBox ""Bitte erst ein Objekt auswaehlen!"", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    DoCmd.OpenForm ""frm_VorlageAuswahl"", , , , , acDialog, lngZielObjektID" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    MsgBox ""Fehler: "" & Err.Description, vbCritical" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"' Loescht eine Vorlage" & vbCrLf & _
"Public Sub LoescheVorlage(lngVorlageID As Long)" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    If MsgBox(""Moechten Sie diese Vorlage wirklich loeschen?"", vbYesNo + vbQuestion) = vbNo Then Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"    Dim db As DAO.Database" & vbCrLf & _
"    Set db = CurrentDb" & vbCrLf & _
"    " & vbCrLf & _
"    db.Execute ""DELETE FROM tbl_Positions_Vorlagen_Details WHERE Vorlage_ID = "" & lngVorlageID" & vbCrLf & _
"    db.Execute ""DELETE FROM tbl_Positions_Vorlagen WHERE ID = "" & lngVorlageID" & vbCrLf & _
"    " & vbCrLf & _
"    MsgBox ""Vorlage geloescht!"", vbInformation" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    MsgBox ""Fehler beim Loeschen: "" & Err.Description, vbCritical" & vbCrLf & _
"End Sub"

codeModule.InsertLines 1, vorlagenCode
WScript.Echo "Vorlagen- und Kopier-Code eingefuegt"

' ========================================
' FEATURE 6: Filter und Suche
' ========================================
WScript.Echo "=== Feature 6: Filter und Suche ==="

Dim filterModuleExists
filterModuleExists = False

For Each comp In proj.VBComponents
    If comp.Name = "mdl_ObjektFilter" Then
        filterModuleExists = True
        Set codeModule = comp.CodeModule
        Exit For
    End If
Next

If Not filterModuleExists Then
    Set comp = proj.VBComponents.Add(1)
    comp.Name = "mdl_ObjektFilter"
    Set codeModule = comp.CodeModule
    WScript.Echo "Modul mdl_ObjektFilter erstellt"
End If

If codeModule.CountOfLines > 0 Then
    codeModule.DeleteLines 1, codeModule.CountOfLines
End If

Dim filterCode
filterCode = "Option Compare Database" & vbCrLf & _
"Option Explicit" & vbCrLf & vbCrLf & _
"' Modul fuer Objekt-Filterung und Suche" & vbCrLf & vbCrLf & _
"' Filtert das Objekt-Listenfeld nach Suchbegriff" & vbCrLf & _
"Public Sub FilterObjektListe(frm As Form, strSuchbegriff As String)" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    " & vbCrLf & _
"    Dim strBaseSQL As String" & vbCrLf & _
"    Dim strFilterSQL As String" & vbCrLf & _
"    " & vbCrLf & _
"    ' Basis-SQL fuer das Listenfeld (anpassen an tatsaechliche Struktur)" & vbCrLf & _
"    strBaseSQL = ""SELECT ID, ObjektNr, Bezeichnung FROM tbl_OB_Objekt""" & vbCrLf & _
"    " & vbCrLf & _
"    If Len(strSuchbegriff) > 0 Then" & vbCrLf & _
"        strFilterSQL = strBaseSQL & "" WHERE "" & _" & vbCrLf & _
"            ""ObjektNr LIKE '*"" & strSuchbegriff & ""*' OR "" & _" & vbCrLf & _
"            ""Bezeichnung LIKE '*"" & strSuchbegriff & ""*' OR "" & _" & vbCrLf & _
"            ""Ort LIKE '*"" & strSuchbegriff & ""*' OR "" & _" & vbCrLf & _
"            ""Strasse LIKE '*"" & strSuchbegriff & ""*'""" & vbCrLf & _
"    Else" & vbCrLf & _
"        strFilterSQL = strBaseSQL" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    strFilterSQL = strFilterSQL & "" ORDER BY ObjektNr""" & vbCrLf & _
"    " & vbCrLf & _
"    ' Aktualisiere Listenfeld" & vbCrLf & _
"    frm!lstObjekte.RowSource = strFilterSQL" & vbCrLf & _
"    frm!lstObjekte.Requery" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"' Setzt Filter zurueck" & vbCrLf & _
"Public Sub ResetObjektFilter(frm As Form)" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    frm!txtSuche = """"" & vbCrLf & _
"    FilterObjektListe frm, """"" & vbCrLf & _
"End Sub"

codeModule.InsertLines 1, filterCode
WScript.Echo "Filter-Code eingefuegt"

' ========================================
' FEATURE 7: Farbcodierung
' ========================================
WScript.Echo "=== Feature 7: Farbcodierung ==="

' Fuege Farbcodierung zu mdl_ZeitHeader hinzu
For Each comp In proj.VBComponents
    If comp.Name = "mdl_ZeitHeader" Then
        Set codeModule = comp.CodeModule

        Dim farbCode
        farbCode = vbCrLf & vbCrLf & _
"' FEATURE 7: Farbcodierung nach Gruppe" & vbCrLf & _
"Public Function GetGruppenFarbe(strGruppe As String) As Long" & vbCrLf & _
"    ' Gibt eine Farbe basierend auf der Gruppe zurueck" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    " & vbCrLf & _
"    Select Case UCase(Left(Nz(strGruppe, """"), 3))" & vbCrLf & _
"        Case ""SEC"", ""SIC"" ' Security/Sicherheit" & vbCrLf & _
"            GetGruppenFarbe = RGB(255, 230, 230) ' Hellrot" & vbCrLf & _
"        Case ""EMP"", ""EIN"" ' Empfang/Einlass" & vbCrLf & _
"            GetGruppenFarbe = RGB(230, 255, 230) ' Hellgruen" & vbCrLf & _
"        Case ""PAR"", ""PKW"" ' Parking/Parkplatz" & vbCrLf & _
"            GetGruppenFarbe = RGB(230, 230, 255) ' Hellblau" & vbCrLf & _
"        Case ""VIP"" ' VIP-Bereich" & vbCrLf & _
"            GetGruppenFarbe = RGB(255, 255, 200) ' Hellgelb" & vbCrLf & _
"        Case ""TEC"", ""TEK"" ' Technik" & vbCrLf & _
"            GetGruppenFarbe = RGB(255, 230, 200) ' Hellorange" & vbCrLf & _
"        Case ""LOG"", ""LAG"" ' Logistik/Lager" & vbCrLf & _
"            GetGruppenFarbe = RGB(230, 255, 255) ' Hellcyan" & vbCrLf & _
"        Case ""BUE"", ""OFF"" ' Buero/Office" & vbCrLf & _
"            GetGruppenFarbe = RGB(245, 230, 255) ' Helllila" & vbCrLf & _
"        Case Else" & vbCrLf & _
"            GetGruppenFarbe = RGB(255, 255, 255) ' Weiss (Standard)" & vbCrLf & _
"    End Select" & vbCrLf & _
"End Function" & vbCrLf & vbCrLf & _
"' Wendet Farbcodierung auf Datenblatt an (wird im Form_Current des Unterformulars aufgerufen)" & vbCrLf & _
"Public Sub ApplyFarbcodierung(frm As Form)" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    " & vbCrLf & _
"    Dim strGruppe As String" & vbCrLf & _
"    strGruppe = Nz(frm!Gruppe, """")" & vbCrLf & _
"    " & vbCrLf & _
"    ' Bei Datenblatt-Ansicht: Detail-Sektion faerben" & vbCrLf & _
"    frm.Section(0).BackColor = GetGruppenFarbe(strGruppe)" & vbCrLf & _
"End Sub"

        codeModule.InsertLines codeModule.CountOfLines + 1, farbCode
        WScript.Echo "Farbcodierung zu mdl_ZeitHeader hinzugefuegt"
        Exit For
    End If
Next

' ========================================
' FEATURE 8: Inline-Bearbeitung Zeit-Labels
' ========================================
WScript.Echo "=== Feature 8: Inline-Bearbeitung Zeit-Labels ==="

' Fuege Code zu mdl_ZeitHeader hinzu
For Each comp In proj.VBComponents
    If comp.Name = "mdl_ZeitHeader" Then
        Set codeModule = comp.CodeModule

        Dim inlineCode
        inlineCode = vbCrLf & vbCrLf & _
"' FEATURE 8: Inline-Bearbeitung der Zeit-Labels" & vbCrLf & _
"Public Sub BearbeiteZeitLabels(frm As Form)" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    Dim lngObjektID As Long" & vbCrLf & _
"    lngObjektID = Nz(frm!ID, 0)" & vbCrLf & _
"    " & vbCrLf & _
"    If lngObjektID = 0 Then" & vbCrLf & _
"        MsgBox ""Bitte erst ein Objekt auswaehlen!"", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    ' Hole aktuelle Werte" & vbCrLf & _
"    Dim strZeit1 As String, strZeit2 As String" & vbCrLf & _
"    Dim strZeit3 As String, strZeit4 As String" & vbCrLf & _
"    strZeit1 = Nz(frm!Zeit1_Label, ""08:00"")" & vbCrLf & _
"    strZeit2 = Nz(frm!Zeit2_Label, ""12:00"")" & vbCrLf & _
"    strZeit3 = Nz(frm!Zeit3_Label, ""16:00"")" & vbCrLf & _
"    strZeit4 = Nz(frm!Zeit4_Label, ""20:00"")" & vbCrLf & _
"    " & vbCrLf & _
"    ' Einfacher Dialog mit InputBox (Alternative: eigenes Formular)" & vbCrLf & _
"    Dim strInput As String" & vbCrLf & _
"    strInput = InputBox(""Geben Sie die 4 Zeitslots ein (getrennt durch Komma):"" & vbCrLf & _" & vbCrLf & _
"        ""Beispiel: 08:00, 12:00, 16:00, 20:00"", ""Zeit-Labels bearbeiten"", _" & vbCrLf & _
"        strZeit1 & "", "" & strZeit2 & "", "" & strZeit3 & "", "" & strZeit4)" & vbCrLf & _
"    " & vbCrLf & _
"    If strInput = """" Then Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"    ' Parsen" & vbCrLf & _
"    Dim arrZeiten() As String" & vbCrLf & _
"    arrZeiten = Split(strInput, "","")" & vbCrLf & _
"    " & vbCrLf & _
"    If UBound(arrZeiten) >= 0 Then frm!Zeit1_Label = Trim(arrZeiten(0))" & vbCrLf & _
"    If UBound(arrZeiten) >= 1 Then frm!Zeit2_Label = Trim(arrZeiten(1))" & vbCrLf & _
"    If UBound(arrZeiten) >= 2 Then frm!Zeit3_Label = Trim(arrZeiten(2))" & vbCrLf & _
"    If UBound(arrZeiten) >= 3 Then frm!Zeit4_Label = Trim(arrZeiten(3))" & vbCrLf & _
"    " & vbCrLf & _
"    ' Speichern" & vbCrLf & _
"    If frm.Dirty Then frm.Dirty = False" & vbCrLf & _
"    " & vbCrLf & _
"    ' Header aktualisieren" & vbCrLf & _
"    UpdateZeitHeaderLabels frm" & vbCrLf & _
"    " & vbCrLf & _
"    MsgBox ""Zeit-Labels aktualisiert!"", vbInformation" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    MsgBox ""Fehler: "" & Err.Description, vbCritical" & vbCrLf & _
"End Sub"

        codeModule.InsertLines codeModule.CountOfLines + 1, inlineCode
        WScript.Echo "Inline-Bearbeitung zu mdl_ZeitHeader hinzugefuegt"
        Exit For
    End If
Next

If Err.Number <> 0 Then
    WScript.Echo "Fehler: " & Err.Description
End If

On Error GoTo 0

WScript.Echo ""
WScript.Echo "=== Alle Module erstellt ==="
WScript.Echo "Schliesse Datenbank..."

accApp.CloseCurrentDatabase
accApp.Quit
Set accApp = Nothing

WScript.Echo "Fertig - Teil 1 abgeschlossen"

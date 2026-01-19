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

Dim db
Set db = accApp.CurrentDb

' ========================================
' Tabellen umbenennen
' ========================================

WScript.Echo "=== Benenne Tabellen um ==="

' Methode: Neue Tabelle erstellen, Daten kopieren, alte loeschen
Dim tdf, tblExists

' Pruefe tbl_Positions_Vorlagen
tblExists = False
For Each tdf In db.TableDefs
    If tdf.Name = "tbl_Positions_Vorlagen" Then
        tblExists = True
        Exit For
    End If
Next

If tblExists Then
    ' Erstelle neue Tabelle
    On Error Resume Next
    db.Execute "SELECT * INTO tbl_N_Positions_Vorlagen FROM tbl_Positions_Vorlagen"
    If Err.Number = 0 Then
        db.Execute "DROP TABLE tbl_Positions_Vorlagen"
        WScript.Echo "tbl_Positions_Vorlagen -> tbl_N_Positions_Vorlagen"
    Else
        WScript.Echo "Fehler bei tbl_Positions_Vorlagen: " & Err.Description
    End If
    Err.Clear
End If

' Pruefe tbl_Positions_Vorlagen_Details
tblExists = False
For Each tdf In db.TableDefs
    If tdf.Name = "tbl_Positions_Vorlagen_Details" Then
        tblExists = True
        Exit For
    End If
Next

If tblExists Then
    On Error Resume Next
    db.Execute "SELECT * INTO tbl_N_Positions_Vorlagen_Details FROM tbl_Positions_Vorlagen_Details"
    If Err.Number = 0 Then
        db.Execute "DROP TABLE tbl_Positions_Vorlagen_Details"
        WScript.Echo "tbl_Positions_Vorlagen_Details -> tbl_N_Positions_Vorlagen_Details"
    Else
        WScript.Echo "Fehler bei tbl_Positions_Vorlagen_Details: " & Err.Description
    End If
    Err.Clear
End If

' Falls neue Tabellen nicht existieren, erstelle sie
tblExists = False
For Each tdf In db.TableDefs
    If tdf.Name = "tbl_N_Positions_Vorlagen" Then
        tblExists = True
        Exit For
    End If
Next

If Not tblExists Then
    db.Execute "CREATE TABLE tbl_N_Positions_Vorlagen (ID AUTOINCREMENT PRIMARY KEY, VorlageName TEXT(100), ErstelltAm DATETIME, ErstelltVon TEXT(50))"
    WScript.Echo "tbl_N_Positions_Vorlagen erstellt"
End If

tblExists = False
For Each tdf In db.TableDefs
    If tdf.Name = "tbl_N_Positions_Vorlagen_Details" Then
        tblExists = True
        Exit For
    End If
Next

If Not tblExists Then
    db.Execute "CREATE TABLE tbl_N_Positions_Vorlagen_Details (ID AUTOINCREMENT PRIMARY KEY, Vorlage_ID LONG, PosNr INTEGER, Gruppe TEXT(100), Zusatztext TEXT(255), Zeit1 INTEGER, Zeit2 INTEGER, Zeit3 INTEGER, Zeit4 INTEGER, Sort INTEGER)"
    WScript.Echo "tbl_N_Positions_Vorlagen_Details erstellt"
End If

' ========================================
' Erstelle Formulare mit N_ Prefix
' ========================================

WScript.Echo ""
WScript.Echo "=== Erstelle Formulare mit N_ Prefix ==="

' Loesche alte Formulare falls vorhanden
On Error Resume Next
accApp.DoCmd.DeleteObject 2, "frm_N_PositionenKopieren"
accApp.DoCmd.DeleteObject 2, "frm_N_VorlageAuswahl"
Err.Clear
On Error GoTo 0

On Error Resume Next

' ========================================
' Formular 1: frm_N_PositionenKopieren
' ========================================

WScript.Echo "Erstelle frm_N_PositionenKopieren..."

Dim frmKopieren
Set frmKopieren = accApp.CreateForm
frmKopieren.Caption = "Positionen kopieren"
frmKopieren.RecordSource = ""
frmKopieren.NavigationButtons = False
frmKopieren.RecordSelectors = False
frmKopieren.ScrollBars = 0
frmKopieren.PopUp = True
frmKopieren.Modal = True
frmKopieren.BorderStyle = 3

accApp.DoCmd.Save 2, , "frm_N_PositionenKopieren"
accApp.DoCmd.Close 2, "frm_N_PositionenKopieren", 1
WScript.Sleep 500

' Oeffne in Design und fuege Controls hinzu
accApp.DoCmd.OpenForm "frm_N_PositionenKopieren", 1
WScript.Sleep 1000

Set frmKopieren = accApp.Forms("frm_N_PositionenKopieren")

Dim ctl

Set ctl = accApp.CreateControl("frm_N_PositionenKopieren", 100, 0, "", "", 200, 200, 5000, 500)
ctl.Name = "lblAnleitung"
ctl.Caption = "Waehlen Sie das Quell-Objekt, von dem kopiert werden soll:"

Set ctl = accApp.CreateControl("frm_N_PositionenKopieren", 100, 0, "", "", 200, 800, 1200, 300)
ctl.Name = "lblQuell"
ctl.Caption = "Quell-Objekt:"

Set ctl = accApp.CreateControl("frm_N_PositionenKopieren", 111, 0, "", "", 1500, 800, 3500, 300)
ctl.Name = "cboQuellObjekt"
ctl.RowSourceType = "Table/Query"
ctl.RowSource = "SELECT ID, ObjektNr, Bezeichnung FROM tbl_OB_Objekt ORDER BY ObjektNr"
ctl.ColumnCount = 3
ctl.ColumnWidths = "0;1200;2000"
ctl.BoundColumn = 1

Set ctl = accApp.CreateControl("frm_N_PositionenKopieren", 106, 0, "", "", 200, 1300, 300, 300)
ctl.Name = "chkLoescheZiel"

Set ctl = accApp.CreateControl("frm_N_PositionenKopieren", 100, 0, "", "", 550, 1300, 4000, 300)
ctl.Name = "lblChk"
ctl.Caption = "Bestehende Positionen im Ziel loeschen"

Set ctl = accApp.CreateControl("frm_N_PositionenKopieren", 104, 0, "", "", 1200, 1800, 1500, 400)
ctl.Name = "btnOK"
ctl.Caption = "Kopieren"
ctl.OnClick = "[Event Procedure]"

Set ctl = accApp.CreateControl("frm_N_PositionenKopieren", 104, 0, "", "", 2900, 1800, 1500, 400)
ctl.Name = "btnAbbrechen"
ctl.Caption = "Abbrechen"
ctl.OnClick = "[Event Procedure]"

accApp.DoCmd.Close 2, "frm_N_PositionenKopieren", 1
WScript.Echo "frm_N_PositionenKopieren erstellt"

' ========================================
' Formular 2: frm_N_VorlageAuswahl
' ========================================

WScript.Echo "Erstelle frm_N_VorlageAuswahl..."

Dim frmVorlage
Set frmVorlage = accApp.CreateForm
frmVorlage.Caption = "Vorlage auswaehlen"
frmVorlage.RecordSource = ""
frmVorlage.NavigationButtons = False
frmVorlage.RecordSelectors = False
frmVorlage.ScrollBars = 0
frmVorlage.PopUp = True
frmVorlage.Modal = True
frmVorlage.BorderStyle = 3

accApp.DoCmd.Save 2, , "frm_N_VorlageAuswahl"
accApp.DoCmd.Close 2, "frm_N_VorlageAuswahl", 1
WScript.Sleep 500

accApp.DoCmd.OpenForm "frm_N_VorlageAuswahl", 1
WScript.Sleep 1000

Set frmVorlage = accApp.Forms("frm_N_VorlageAuswahl")

Set ctl = accApp.CreateControl("frm_N_VorlageAuswahl", 100, 0, "", "", 200, 200, 4000, 300)
ctl.Name = "lblVorlagen"
ctl.Caption = "Verfuegbare Vorlagen:"

Set ctl = accApp.CreateControl("frm_N_VorlageAuswahl", 110, 0, "", "", 200, 550, 4800, 1800)
ctl.Name = "lstVorlagen"
ctl.RowSourceType = "Table/Query"
ctl.RowSource = "SELECT ID, VorlageName, Format(ErstelltAm,'dd.mm.yyyy') FROM tbl_N_Positions_Vorlagen ORDER BY VorlageName"
ctl.ColumnCount = 3
ctl.ColumnWidths = "0;2800;1500"
ctl.BoundColumn = 1

Set ctl = accApp.CreateControl("frm_N_VorlageAuswahl", 106, 0, "", "", 200, 2500, 300, 300)
ctl.Name = "chkLoescheZiel"
ctl.DefaultValue = -1

Set ctl = accApp.CreateControl("frm_N_VorlageAuswahl", 100, 0, "", "", 550, 2500, 3500, 300)
ctl.Name = "lblChkV"
ctl.Caption = "Bestehende Positionen loeschen"

Set ctl = accApp.CreateControl("frm_N_VorlageAuswahl", 104, 0, "", "", 200, 2950, 1400, 400)
ctl.Name = "btnLaden"
ctl.Caption = "Laden"
ctl.OnClick = "[Event Procedure]"

Set ctl = accApp.CreateControl("frm_N_VorlageAuswahl", 104, 0, "", "", 1750, 2950, 1400, 400)
ctl.Name = "btnLoeschen"
ctl.Caption = "Loeschen"
ctl.OnClick = "[Event Procedure]"

Set ctl = accApp.CreateControl("frm_N_VorlageAuswahl", 104, 0, "", "", 3300, 2950, 1400, 400)
ctl.Name = "btnSchliessen"
ctl.Caption = "Schliessen"
ctl.OnClick = "[Event Procedure]"

accApp.DoCmd.Close 2, "frm_N_VorlageAuswahl", 1
WScript.Echo "frm_N_VorlageAuswahl erstellt"

' ========================================
' Code zu Formularen hinzufuegen
' ========================================

WScript.Echo ""
WScript.Echo "=== Fuege Code zu Formularen hinzu ==="

Dim vbe, proj, comp, codeModule

Set vbe = accApp.VBE
Set proj = vbe.VBProjects(1)

' Code fuer frm_N_PositionenKopieren
For Each comp In proj.VBComponents
    If comp.Name = "Form_frm_N_PositionenKopieren" Then
        Set codeModule = comp.CodeModule

        Dim kopierenCode
        kopierenCode = "Option Compare Database" & vbCrLf & _
"Option Explicit" & vbCrLf & vbCrLf & _
"Private Sub Form_Load()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    If Len(Nz(Me.OpenArgs, """")) > 0 Then Me.Tag = Me.OpenArgs" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnOK_Click()" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    If IsNull(Me.cboQuellObjekt) Then" & vbCrLf & _
"        MsgBox ""Bitte Quell-Objekt auswaehlen!"", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & _
"    KopierePositionen CLng(Me.cboQuellObjekt), CLng(Nz(Me.Tag, 0)), Nz(Me.chkLoescheZiel, False)" & vbCrLf & _
"    DoCmd.Close acForm, Me.Name" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    MsgBox ""Fehler: "" & Err.Description, vbCritical" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnAbbrechen_Click()" & vbCrLf & _
"    DoCmd.Close acForm, Me.Name" & vbCrLf & _
"End Sub"

        If codeModule.CountOfLines > 0 Then codeModule.DeleteLines 1, codeModule.CountOfLines
        codeModule.InsertLines 1, kopierenCode
        WScript.Echo "Code fuer frm_N_PositionenKopieren eingefuegt"
        Exit For
    End If
Next

' Code fuer frm_N_VorlageAuswahl
For Each comp In proj.VBComponents
    If comp.Name = "Form_frm_N_VorlageAuswahl" Then
        Set codeModule = comp.CodeModule

        Dim vorlageCode
        vorlageCode = "Option Compare Database" & vbCrLf & _
"Option Explicit" & vbCrLf & vbCrLf & _
"Private Sub Form_Load()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    If Len(Nz(Me.OpenArgs, """")) > 0 Then Me.Tag = Me.OpenArgs" & vbCrLf & _
"    Me.lstVorlagen.Requery" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnLaden_Click()" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    If IsNull(Me.lstVorlagen) Then" & vbCrLf & _
"        MsgBox ""Bitte Vorlage auswaehlen!"", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & _
"    LadeVorlage CLng(Me.lstVorlagen), CLng(Nz(Me.Tag, 0)), Nz(Me.chkLoescheZiel, True)" & vbCrLf & _
"    DoCmd.Close acForm, Me.Name" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    MsgBox ""Fehler: "" & Err.Description, vbCritical" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnLoeschen_Click()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    If IsNull(Me.lstVorlagen) Then Exit Sub" & vbCrLf & _
"    LoescheVorlage CLng(Me.lstVorlagen)" & vbCrLf & _
"    Me.lstVorlagen.Requery" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnSchliessen_Click()" & vbCrLf & _
"    DoCmd.Close acForm, Me.Name" & vbCrLf & _
"End Sub"

        If codeModule.CountOfLines > 0 Then codeModule.DeleteLines 1, codeModule.CountOfLines
        codeModule.InsertLines 1, vorlageCode
        WScript.Echo "Code fuer frm_N_VorlageAuswahl eingefuegt"
        Exit For
    End If
Next

' ========================================
' Aktualisiere Referenzen zu neuen Formularnamen
' ========================================

WScript.Echo ""
WScript.Echo "=== Aktualisiere Formular-Referenzen im Code ==="

Dim lineCount, j, lineText, newLineText

For Each comp In proj.VBComponents
    If comp.Type = 1 Or comp.Type = 100 Then
        Set codeModule = comp.CodeModule
        lineCount = codeModule.CountOfLines

        If lineCount > 0 Then
            For j = 1 To lineCount
                lineText = codeModule.Lines(j, 1)
                newLineText = lineText

                ' Ersetze Formular-Referenzen
                newLineText = Replace(newLineText, """frm_PositionenKopieren""", """frm_N_PositionenKopieren""")
                newLineText = Replace(newLineText, """frm_VorlageAuswahl""", """frm_N_VorlageAuswahl""")

                ' Ersetze Tabellen-Referenzen
                newLineText = Replace(newLineText, "tbl_Positions_Vorlagen_Details", "tbl_N_Positions_Vorlagen_Details")
                newLineText = Replace(newLineText, "tbl_Positions_Vorlagen", "tbl_N_Positions_Vorlagen")

                If newLineText <> lineText Then
                    codeModule.ReplaceLine j, newLineText
                End If
            Next
        End If
    End If
Next

WScript.Echo "Referenzen aktualisiert"

If Err.Number <> 0 Then
    WScript.Echo "Fehler: " & Err.Description
End If

On Error GoTo 0

accApp.CloseCurrentDatabase
accApp.Quit
Set accApp = Nothing

WScript.Echo ""
WScript.Echo "=== Umbenennung abgeschlossen ==="

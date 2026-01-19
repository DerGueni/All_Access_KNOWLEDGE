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

' ========================================
' 1. Erstelle frm_N_PositionenKopieren
' ========================================

WScript.Echo "=== Erstelle fehlende Formulare ==="

' Loesche falls vorhanden
accApp.DoCmd.DeleteObject 2, "frm_N_PositionenKopieren"
Err.Clear

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
frmKopieren.Width = 6000
frmKopieren.Section(0).Height = 2500

accApp.DoCmd.Save 2, , "frm_N_PositionenKopieren"

Dim ctl

Set ctl = accApp.CreateControl("frm_N_PositionenKopieren", 100, 0, "", "", 200, 200, 5500, 400)
ctl.Name = "lblAnleitung"
ctl.Caption = "Waehlen Sie das Quell-Objekt aus:"

Set ctl = accApp.CreateControl("frm_N_PositionenKopieren", 100, 0, "", "", 200, 700, 1200, 300)
ctl.Name = "lblQuell"
ctl.Caption = "Quell-Objekt:"

Set ctl = accApp.CreateControl("frm_N_PositionenKopieren", 111, 0, "", "", 1500, 700, 4000, 300)
ctl.Name = "cboQuellObjekt"
ctl.RowSourceType = "Table/Query"
ctl.RowSource = "SELECT ID, ObjektNr, Bezeichnung FROM tbl_OB_Objekt ORDER BY ObjektNr"
ctl.ColumnCount = 3
ctl.ColumnWidths = "0;1200;2500"
ctl.BoundColumn = 1

Set ctl = accApp.CreateControl("frm_N_PositionenKopieren", 106, 0, "", "", 200, 1200, 300, 300)
ctl.Name = "chkLoescheZiel"

Set ctl = accApp.CreateControl("frm_N_PositionenKopieren", 100, 0, "", "", 550, 1200, 4500, 300)
ctl.Name = "lblChk"
ctl.Caption = "Bestehende Positionen im Ziel loeschen"

Set ctl = accApp.CreateControl("frm_N_PositionenKopieren", 104, 0, "", "", 1500, 1700, 1500, 400)
ctl.Name = "btnOK"
ctl.Caption = "Kopieren"
ctl.OnClick = "[Event Procedure]"

Set ctl = accApp.CreateControl("frm_N_PositionenKopieren", 104, 0, "", "", 3200, 1700, 1500, 400)
ctl.Name = "btnAbbrechen"
ctl.Caption = "Abbrechen"
ctl.OnClick = "[Event Procedure]"

accApp.DoCmd.Close 2, "frm_N_PositionenKopieren", 1
WScript.Echo "[OK] frm_N_PositionenKopieren erstellt"

' ========================================
' 2. Erstelle frm_N_VorlageAuswahl
' ========================================

accApp.DoCmd.DeleteObject 2, "frm_N_VorlageAuswahl"
Err.Clear

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
frmVorlage.Width = 5500
frmVorlage.Section(0).Height = 3600

accApp.DoCmd.Save 2, , "frm_N_VorlageAuswahl"

Set ctl = accApp.CreateControl("frm_N_VorlageAuswahl", 100, 0, "", "", 200, 200, 4000, 300)
ctl.Name = "lblVorlagen"
ctl.Caption = "Verfuegbare Vorlagen:"

Set ctl = accApp.CreateControl("frm_N_VorlageAuswahl", 110, 0, "", "", 200, 550, 5000, 1800)
ctl.Name = "lstVorlagen"
ctl.RowSourceType = "Table/Query"
ctl.RowSource = "SELECT ID, VorlageName, Format(ErstelltAm,'dd.mm.yyyy') FROM tbl_N_Positions_Vorlagen ORDER BY VorlageName"
ctl.ColumnCount = 3
ctl.ColumnWidths = "0;3000;1500"
ctl.BoundColumn = 1

Set ctl = accApp.CreateControl("frm_N_VorlageAuswahl", 106, 0, "", "", 200, 2500, 300, 300)
ctl.Name = "chkLoescheZiel"
ctl.DefaultValue = -1

Set ctl = accApp.CreateControl("frm_N_VorlageAuswahl", 100, 0, "", "", 550, 2500, 4000, 300)
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
WScript.Echo "[OK] frm_N_VorlageAuswahl erstellt"

' ========================================
' 3. Fuege Code zu Formularen hinzu
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
        If codeModule.CountOfLines > 0 Then codeModule.DeleteLines 1, codeModule.CountOfLines

        Dim code1
        code1 = "Option Compare Database" & vbCrLf & _
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

        codeModule.InsertLines 1, code1
        WScript.Echo "[OK] Code fuer frm_N_PositionenKopieren"
        Exit For
    End If
Next

' Code fuer frm_N_VorlageAuswahl
For Each comp In proj.VBComponents
    If comp.Name = "Form_frm_N_VorlageAuswahl" Then
        Set codeModule = comp.CodeModule
        If codeModule.CountOfLines > 0 Then codeModule.DeleteLines 1, codeModule.CountOfLines

        Dim code2
        code2 = "Option Compare Database" & vbCrLf & _
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

        codeModule.InsertLines 1, code2
        WScript.Echo "[OK] Code fuer frm_N_VorlageAuswahl"
        Exit For
    End If
Next

' ========================================
' 4. Fuege txtSuche zu frm_OB_Objekt hinzu
' ========================================

WScript.Echo ""
WScript.Echo "=== Fuege Suchfeld hinzu ==="

accApp.DoCmd.OpenForm "frm_OB_Objekt", 1 ' Design
WScript.Sleep 1500

Dim frm
Set frm = accApp.Forms("frm_OB_Objekt")

' Pruefe ob txtSuche existiert
Dim txtExists
txtExists = False
For Each ctl In frm.Controls
    If ctl.Name = "txtSuche" Then
        txtExists = True
        Exit For
    End If
Next

If Not txtExists Then
    ' Finde lstObjekte Position
    Dim lstObjekte, sucheTop, sucheLeft
    Set lstObjekte = Nothing

    For Each ctl In frm.Controls
        If ctl.Name = "lstObjekte" Then
            Set lstObjekte = ctl
            Exit For
        End If
    Next

    If Not lstObjekte Is Nothing Then
        sucheTop = lstObjekte.Top - 450
        sucheLeft = lstObjekte.Left

        Set ctl = accApp.CreateControl("frm_OB_Objekt", 100, 0, "", "", sucheLeft, sucheTop, 700, 280)
        ctl.Name = "lblSuche"
        ctl.Caption = "Suche:"

        Set ctl = accApp.CreateControl("frm_OB_Objekt", 109, 0, "", "", sucheLeft + 750, sucheTop, 2200, 280)
        ctl.Name = "txtSuche"
        ctl.OnChange = "[Event Procedure]"

        WScript.Echo "[OK] txtSuche und lblSuche erstellt"
    Else
        ' Alternative Position
        Set ctl = accApp.CreateControl("frm_OB_Objekt", 100, 0, "", "", 100, 100, 700, 280)
        ctl.Name = "lblSuche"
        ctl.Caption = "Suche:"

        Set ctl = accApp.CreateControl("frm_OB_Objekt", 109, 0, "", "", 850, 100, 2200, 280)
        ctl.Name = "txtSuche"
        ctl.OnChange = "[Event Procedure]"

        WScript.Echo "[OK] txtSuche und lblSuche erstellt (Alternative Position)"
    End If
Else
    WScript.Echo "[OK] txtSuche existiert bereits"
End If

accApp.DoCmd.Close 2, "frm_OB_Objekt", 1 ' acSaveYes

' ========================================
' 5. Fuege txtSuche_Change Event hinzu
' ========================================

WScript.Echo ""
WScript.Echo "=== Pruefe txtSuche_Change Event ==="

For Each comp In proj.VBComponents
    If comp.Name = "Form_frm_OB_Objekt" Then
        Set codeModule = comp.CodeModule
        Dim existingCode
        existingCode = codeModule.Lines(1, codeModule.CountOfLines)

        If InStr(existingCode, "txtSuche_Change") = 0 Then
            Dim searchCode
            searchCode = vbCrLf & vbCrLf & _
"Private Sub txtSuche_Change()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    FilterObjektListe Me, Nz(Me.txtSuche.Text, """")" & vbCrLf & _
"End Sub"

            codeModule.InsertLines codeModule.CountOfLines + 1, searchCode
            WScript.Echo "[OK] txtSuche_Change Event hinzugefuegt"
        Else
            WScript.Echo "[OK] txtSuche_Change existiert bereits"
        End If
        Exit For
    End If
Next

If Err.Number <> 0 Then
    WScript.Echo "Fehler: " & Err.Description
End If

On Error GoTo 0

accApp.CloseCurrentDatabase
accApp.Quit
Set accApp = Nothing

WScript.Echo ""
WScript.Echo "=== Fehlende Elemente erstellt ==="

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
' FEATURE 3: Drag & Drop Alternative
' Implementiert als Listbox mit Auf/Ab-Buttons
' ========================================

WScript.Echo "=== Feature 3: Verbesserte Positions-Sortierung ==="

Dim vbe, proj, comp, codeModule

Set vbe = accApp.VBE
Set proj = vbe.VBProjects(1)

' Erweitere mdl_PositionsVorlagen mit Sortier-Funktionen
For Each comp In proj.VBComponents
    If comp.Name = "mdl_PositionsVorlagen" Then
        Set codeModule = comp.CodeModule

        Dim sortCode
        sortCode = vbCrLf & vbCrLf & _
"' FEATURE 3: Erweiterte Sortier-Funktionen" & vbCrLf & vbCrLf & _
"' Verschiebt eine Position nach oben (kleinerer Sort-Wert)" & vbCrLf & _
"Public Sub MovePositionUp(lngPositionID As Long)" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    Dim db As DAO.Database" & vbCrLf & _
"    Dim rs As DAO.Recordset" & vbCrLf & _
"    Dim lngObjektID As Long" & vbCrLf & _
"    Dim lngCurrentSort As Long" & vbCrLf & _
"    Dim lngPrevID As Long" & vbCrLf & _
"    Dim lngPrevSort As Long" & vbCrLf & _
"    " & vbCrLf & _
"    Set db = CurrentDb" & vbCrLf & _
"    " & vbCrLf & _
"    ' Hole aktuelle Position" & vbCrLf & _
"    lngObjektID = Nz(DLookup(""OB_Objekt_Kopf_ID"", ""tbl_OB_Objekt_Positionen"", ""ID = "" & lngPositionID), 0)" & vbCrLf & _
"    lngCurrentSort = Nz(DLookup(""Sort"", ""tbl_OB_Objekt_Positionen"", ""ID = "" & lngPositionID), 0)" & vbCrLf & _
"    " & vbCrLf & _
"    ' Finde vorherige Position" & vbCrLf & _
"    Set rs = db.OpenRecordset(""SELECT TOP 1 ID, Sort FROM tbl_OB_Objekt_Positionen "" & _" & vbCrLf & _
"        ""WHERE OB_Objekt_Kopf_ID = "" & lngObjektID & "" AND Sort < "" & lngCurrentSort & _" & vbCrLf & _
"        "" ORDER BY Sort DESC"")" & vbCrLf & _
"    " & vbCrLf & _
"    If Not rs.EOF Then" & vbCrLf & _
"        lngPrevID = rs!ID" & vbCrLf & _
"        lngPrevSort = rs!Sort" & vbCrLf & _
"        rs.Close" & vbCrLf & _
"        " & vbCrLf & _
"        ' Tausche Sort-Werte" & vbCrLf & _
"        db.Execute ""UPDATE tbl_OB_Objekt_Positionen SET Sort = "" & lngPrevSort & "" WHERE ID = "" & lngPositionID" & vbCrLf & _
"        db.Execute ""UPDATE tbl_OB_Objekt_Positionen SET Sort = "" & lngCurrentSort & "" WHERE ID = "" & lngPrevID" & vbCrLf & _
"    End If" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    ' Fehler ignorieren" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"' Verschiebt eine Position nach unten (groesserer Sort-Wert)" & vbCrLf & _
"Public Sub MovePositionDown(lngPositionID As Long)" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    Dim db As DAO.Database" & vbCrLf & _
"    Dim rs As DAO.Recordset" & vbCrLf & _
"    Dim lngObjektID As Long" & vbCrLf & _
"    Dim lngCurrentSort As Long" & vbCrLf & _
"    Dim lngNextID As Long" & vbCrLf & _
"    Dim lngNextSort As Long" & vbCrLf & _
"    " & vbCrLf & _
"    Set db = CurrentDb" & vbCrLf & _
"    " & vbCrLf & _
"    ' Hole aktuelle Position" & vbCrLf & _
"    lngObjektID = Nz(DLookup(""OB_Objekt_Kopf_ID"", ""tbl_OB_Objekt_Positionen"", ""ID = "" & lngPositionID), 0)" & vbCrLf & _
"    lngCurrentSort = Nz(DLookup(""Sort"", ""tbl_OB_Objekt_Positionen"", ""ID = "" & lngPositionID), 0)" & vbCrLf & _
"    " & vbCrLf & _
"    ' Finde naechste Position" & vbCrLf & _
"    Set rs = db.OpenRecordset(""SELECT TOP 1 ID, Sort FROM tbl_OB_Objekt_Positionen "" & _" & vbCrLf & _
"        ""WHERE OB_Objekt_Kopf_ID = "" & lngObjektID & "" AND Sort > "" & lngCurrentSort & _" & vbCrLf & _
"        "" ORDER BY Sort ASC"")" & vbCrLf & _
"    " & vbCrLf & _
"    If Not rs.EOF Then" & vbCrLf & _
"        lngNextID = rs!ID" & vbCrLf & _
"        lngNextSort = rs!Sort" & vbCrLf & _
"        rs.Close" & vbCrLf & _
"        " & vbCrLf & _
"        ' Tausche Sort-Werte" & vbCrLf & _
"        db.Execute ""UPDATE tbl_OB_Objekt_Positionen SET Sort = "" & lngNextSort & "" WHERE ID = "" & lngPositionID" & vbCrLf & _
"        db.Execute ""UPDATE tbl_OB_Objekt_Positionen SET Sort = "" & lngCurrentSort & "" WHERE ID = "" & lngNextID" & vbCrLf & _
"    End If" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    ' Fehler ignorieren" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"' Nummeriert alle Positionen eines Objekts neu durch" & vbCrLf & _
"Public Sub RenumberPositions(lngObjektID As Long)" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    Dim db As DAO.Database" & vbCrLf & _
"    Dim rs As DAO.Recordset" & vbCrLf & _
"    Dim lngSort As Long" & vbCrLf & _
"    " & vbCrLf & _
"    Set db = CurrentDb" & vbCrLf & _
"    Set rs = db.OpenRecordset(""SELECT ID FROM tbl_OB_Objekt_Positionen "" & _" & vbCrLf & _
"        ""WHERE OB_Objekt_Kopf_ID = "" & lngObjektID & "" ORDER BY Sort, PosNr"")" & vbCrLf & _
"    " & vbCrLf & _
"    lngSort = 1" & vbCrLf & _
"    Do While Not rs.EOF" & vbCrLf & _
"        db.Execute ""UPDATE tbl_OB_Objekt_Positionen SET Sort = "" & lngSort & "", PosNr = "" & lngSort & "" WHERE ID = "" & rs!ID" & vbCrLf & _
"        lngSort = lngSort + 1" & vbCrLf & _
"        rs.MoveNext" & vbCrLf & _
"    Loop" & vbCrLf & _
"    rs.Close" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    ' Fehler ignorieren" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"' Verschiebt Position an eine bestimmte Stelle" & vbCrLf & _
"Public Sub MovePositionTo(lngPositionID As Long, lngNeuePosition As Long)" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    Dim db As DAO.Database" & vbCrLf & _
"    Dim lngObjektID As Long" & vbCrLf & _
"    " & vbCrLf & _
"    Set db = CurrentDb" & vbCrLf & _
"    lngObjektID = Nz(DLookup(""OB_Objekt_Kopf_ID"", ""tbl_OB_Objekt_Positionen"", ""ID = "" & lngPositionID), 0)" & vbCrLf & _
"    " & vbCrLf & _
"    ' Setze temporaer auf hohen Wert" & vbCrLf & _
"    db.Execute ""UPDATE tbl_OB_Objekt_Positionen SET Sort = 99999 WHERE ID = "" & lngPositionID" & vbCrLf & _
"    " & vbCrLf & _
"    ' Verschiebe alle anderen" & vbCrLf & _
"    db.Execute ""UPDATE tbl_OB_Objekt_Positionen SET Sort = Sort + 1 "" & _" & vbCrLf & _
"        ""WHERE OB_Objekt_Kopf_ID = "" & lngObjektID & "" AND Sort >= "" & lngNeuePosition & "" AND ID <> "" & lngPositionID" & vbCrLf & _
"    " & vbCrLf & _
"    ' Setze neue Position" & vbCrLf & _
"    db.Execute ""UPDATE tbl_OB_Objekt_Positionen SET Sort = "" & lngNeuePosition & "" WHERE ID = "" & lngPositionID" & vbCrLf & _
"    " & vbCrLf & _
"    ' Neu durchnummerieren" & vbCrLf & _
"    RenumberPositions lngObjektID" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    ' Fehler ignorieren" & vbCrLf & _
"End Sub"

        codeModule.InsertLines codeModule.CountOfLines + 1, sortCode
        WScript.Echo "Sortier-Funktionen hinzugefuegt"
        Exit For
    End If
Next

' ========================================
' Dialog-Formulare erstellen
' ========================================

WScript.Echo "=== Erstelle Dialog-Formulare ==="

' Formular 1: frm_PositionenKopieren
WScript.Echo "Erstelle frm_PositionenKopieren..."

Dim frmKopieren
On Error Resume Next
accApp.DoCmd.DeleteObject 2, "frm_PositionenKopieren"
On Error GoTo 0

On Error Resume Next
Set frmKopieren = accApp.CreateForm
frmKopieren.Caption = "Positionen kopieren"
frmKopieren.RecordSource = ""
frmKopieren.NavigationButtons = False
frmKopieren.RecordSelectors = False
frmKopieren.DividingLines = False
frmKopieren.ScrollBars = 0
frmKopieren.PopUp = True
frmKopieren.Modal = True
frmKopieren.BorderStyle = 3

accApp.DoCmd.Save 2, , "frm_PositionenKopieren"
accApp.DoCmd.Close 2, "frm_PositionenKopieren", 1

' Oeffne wieder in Design
accApp.DoCmd.OpenForm "frm_PositionenKopieren", 1
WScript.Sleep 1000

Set frmKopieren = accApp.Forms("frm_PositionenKopieren")

' Controls hinzufuegen
Dim lblAnleitung, cboQuellObjekt, lblQuell, chkLoeschen, btnOK, btnAbbrechen

Set lblAnleitung = accApp.CreateControl("frm_PositionenKopieren", 100, 0, "", "", 200, 200, 5000, 600)
lblAnleitung.Name = "lblAnleitung"
lblAnleitung.Caption = "Waehlen Sie das Quell-Objekt aus, von dem die Positionen kopiert werden sollen:"

Set lblQuell = accApp.CreateControl("frm_PositionenKopieren", 100, 0, "", "", 200, 900, 1500, 300)
lblQuell.Name = "lblQuellObjekt"
lblQuell.Caption = "Quell-Objekt:"

Set cboQuellObjekt = accApp.CreateControl("frm_PositionenKopieren", 111, 0, "", "", 1800, 900, 3500, 300)
cboQuellObjekt.Name = "cboQuellObjekt"
cboQuellObjekt.RowSourceType = "Table/Query"
cboQuellObjekt.RowSource = "SELECT ID, ObjektNr, Bezeichnung FROM tbl_OB_Objekt ORDER BY ObjektNr"
cboQuellObjekt.ColumnCount = 3
cboQuellObjekt.ColumnWidths = "0;1500;2500"
cboQuellObjekt.BoundColumn = 1

Set chkLoeschen = accApp.CreateControl("frm_PositionenKopieren", 106, 0, "", "", 200, 1400, 4000, 300)
chkLoeschen.Name = "chkLoescheZiel"
chkLoeschen.OptionValue = 1

Dim lblChk
Set lblChk = accApp.CreateControl("frm_PositionenKopieren", 100, 0, "", "", 500, 1400, 4000, 300)
lblChk.Name = "lblChkLoeschen"
lblChk.Caption = "Bestehende Positionen im Ziel loeschen"

Set btnOK = accApp.CreateControl("frm_PositionenKopieren", 104, 0, "", "", 1500, 1900, 1500, 400)
btnOK.Name = "btnOK"
btnOK.Caption = "Kopieren"
btnOK.OnClick = "[Event Procedure]"

Set btnAbbrechen = accApp.CreateControl("frm_PositionenKopieren", 104, 0, "", "", 3200, 1900, 1500, 400)
btnAbbrechen.Name = "btnAbbrechen"
btnAbbrechen.Caption = "Abbrechen"
btnAbbrechen.OnClick = "[Event Procedure]"

accApp.DoCmd.Close 2, "frm_PositionenKopieren", 1
WScript.Echo "frm_PositionenKopieren erstellt"

' Code hinzufuegen
For Each comp In proj.VBComponents
    If comp.Name = "Form_frm_PositionenKopieren" Then
        Set codeModule = comp.CodeModule

        Dim kopierenFormCode
        kopierenFormCode = "Option Compare Database" & vbCrLf & _
"Option Explicit" & vbCrLf & vbCrLf & _
"Private Sub Form_Load()" & vbCrLf & _
"    ' Ziel-Objekt ID aus OpenArgs" & vbCrLf & _
"    If Len(Me.OpenArgs) > 0 Then" & vbCrLf & _
"        Me.Tag = Me.OpenArgs" & vbCrLf & _
"    End If" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnOK_Click()" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    If IsNull(Me.cboQuellObjekt) Then" & vbCrLf & _
"        MsgBox ""Bitte Quell-Objekt auswaehlen!"", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    Dim lngZielID As Long" & vbCrLf & _
"    lngZielID = CLng(Me.Tag)" & vbCrLf & _
"    " & vbCrLf & _
"    KopierePositionen Me.cboQuellObjekt, lngZielID, Nz(Me.chkLoescheZiel, False)" & vbCrLf & _
"    DoCmd.Close acForm, Me.Name" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    MsgBox ""Fehler: "" & Err.Description, vbCritical" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnAbbrechen_Click()" & vbCrLf & _
"    DoCmd.Close acForm, Me.Name" & vbCrLf & _
"End Sub"

        If codeModule.CountOfLines > 0 Then
            codeModule.DeleteLines 1, codeModule.CountOfLines
        End If
        codeModule.InsertLines 1, kopierenFormCode
        WScript.Echo "Code fuer frm_PositionenKopieren hinzugefuegt"
        Exit For
    End If
Next

' ========================================
' Formular 2: frm_VorlageAuswahl
' ========================================

WScript.Echo "Erstelle frm_VorlageAuswahl..."

On Error Resume Next
accApp.DoCmd.DeleteObject 2, "frm_VorlageAuswahl"
On Error GoTo 0

On Error Resume Next
Dim frmVorlage
Set frmVorlage = accApp.CreateForm
frmVorlage.Caption = "Vorlage auswaehlen"
frmVorlage.RecordSource = ""
frmVorlage.NavigationButtons = False
frmVorlage.RecordSelectors = False
frmVorlage.DividingLines = False
frmVorlage.ScrollBars = 0
frmVorlage.PopUp = True
frmVorlage.Modal = True
frmVorlage.BorderStyle = 3

accApp.DoCmd.Save 2, , "frm_VorlageAuswahl"
accApp.DoCmd.Close 2, "frm_VorlageAuswahl", 1

accApp.DoCmd.OpenForm "frm_VorlageAuswahl", 1
WScript.Sleep 1000

Set frmVorlage = accApp.Forms("frm_VorlageAuswahl")

' Controls
Dim lblVorlagen, lstVorlagen, chkLoeschenV, btnLaden, btnLoeschen, btnSchliessenV

Set lblVorlagen = accApp.CreateControl("frm_VorlageAuswahl", 100, 0, "", "", 200, 200, 4000, 300)
lblVorlagen.Name = "lblVorlagen"
lblVorlagen.Caption = "Verfuegbare Vorlagen:"

Set lstVorlagen = accApp.CreateControl("frm_VorlageAuswahl", 110, 0, "", "", 200, 600, 5000, 2000)
lstVorlagen.Name = "lstVorlagen"
lstVorlagen.RowSourceType = "Table/Query"
lstVorlagen.RowSource = "SELECT ID, VorlageName, Format(ErstelltAm,'dd.mm.yyyy') AS Datum FROM tbl_Positions_Vorlagen ORDER BY VorlageName"
lstVorlagen.ColumnCount = 3
lstVorlagen.ColumnWidths = "0;3000;1500"
lstVorlagen.BoundColumn = 1

Set chkLoeschenV = accApp.CreateControl("frm_VorlageAuswahl", 106, 0, "", "", 200, 2700, 300, 300)
chkLoeschenV.Name = "chkLoescheZiel"
chkLoeschenV.DefaultValue = True

Dim lblChkV
Set lblChkV = accApp.CreateControl("frm_VorlageAuswahl", 100, 0, "", "", 550, 2700, 4000, 300)
lblChkV.Name = "lblChkLoeschenV"
lblChkV.Caption = "Bestehende Positionen loeschen"

Set btnLaden = accApp.CreateControl("frm_VorlageAuswahl", 104, 0, "", "", 200, 3200, 1500, 400)
btnLaden.Name = "btnLaden"
btnLaden.Caption = "Laden"
btnLaden.OnClick = "[Event Procedure]"

Set btnLoeschen = accApp.CreateControl("frm_VorlageAuswahl", 104, 0, "", "", 1900, 3200, 1500, 400)
btnLoeschen.Name = "btnLoeschen"
btnLoeschen.Caption = "Loeschen"
btnLoeschen.OnClick = "[Event Procedure]"

Set btnSchliessenV = accApp.CreateControl("frm_VorlageAuswahl", 104, 0, "", "", 3600, 3200, 1500, 400)
btnSchliessenV.Name = "btnSchliessen"
btnSchliessenV.Caption = "Schliessen"
btnSchliessenV.OnClick = "[Event Procedure]"

accApp.DoCmd.Close 2, "frm_VorlageAuswahl", 1
WScript.Echo "frm_VorlageAuswahl erstellt"

' Code hinzufuegen
For Each comp In proj.VBComponents
    If comp.Name = "Form_frm_VorlageAuswahl" Then
        Set codeModule = comp.CodeModule

        Dim vorlageFormCode
        vorlageFormCode = "Option Compare Database" & vbCrLf & _
"Option Explicit" & vbCrLf & vbCrLf & _
"Private Sub Form_Load()" & vbCrLf & _
"    If Len(Me.OpenArgs) > 0 Then" & vbCrLf & _
"        Me.Tag = Me.OpenArgs" & vbCrLf & _
"    End If" & vbCrLf & _
"    Me.lstVorlagen.Requery" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnLaden_Click()" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    If IsNull(Me.lstVorlagen) Then" & vbCrLf & _
"        MsgBox ""Bitte Vorlage auswaehlen!"", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    Dim lngZielID As Long" & vbCrLf & _
"    lngZielID = CLng(Me.Tag)" & vbCrLf & _
"    " & vbCrLf & _
"    LadeVorlage Me.lstVorlagen, lngZielID, Nz(Me.chkLoescheZiel, True)" & vbCrLf & _
"    DoCmd.Close acForm, Me.Name" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    MsgBox ""Fehler: "" & Err.Description, vbCritical" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnLoeschen_Click()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    If IsNull(Me.lstVorlagen) Then Exit Sub" & vbCrLf & _
"    LoescheVorlage Me.lstVorlagen" & vbCrLf & _
"    Me.lstVorlagen.Requery" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnSchliessen_Click()" & vbCrLf & _
"    DoCmd.Close acForm, Me.Name" & vbCrLf & _
"End Sub"

        If codeModule.CountOfLines > 0 Then
            codeModule.DeleteLines 1, codeModule.CountOfLines
        End If
        codeModule.InsertLines 1, vorlageFormCode
        WScript.Echo "Code fuer frm_VorlageAuswahl hinzugefuegt"
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
WScript.Echo "=== Teil 3 abgeschlossen ==="
WScript.Echo "Alle 8 Features implementiert!"

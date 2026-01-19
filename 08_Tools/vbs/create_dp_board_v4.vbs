' ============================================
' PLANUNGS-DASHBOARD ERSTELLEN V4
' Mit DAO.DBEngine fuer Abfragen
' ============================================

Option Explicit

Dim access, dao, db, ws
Dim strFrontendPath

strFrontendPath = "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"

WScript.Echo "============================================"
WScript.Echo "PLANUNGS-DASHBOARD ERSTELLEN V4"
WScript.Echo "============================================"
WScript.Echo "Frontend: " & strFrontendPath

On Error Resume Next

' DAO Engine starten
WScript.Echo vbCrLf & "1. DAO Engine starten..."
Set dao = CreateObject("DAO.DBEngine.120")
If Err.Number <> 0 Then
    WScript.Echo "FEHLER DAO: " & Err.Description
    WScript.Quit 1
End If
Err.Clear

Set ws = dao.Workspaces(0)
Set db = ws.OpenDatabase(strFrontendPath, False, False)
If Err.Number <> 0 Then
    WScript.Echo "FEHLER Datenbank: " & Err.Description
    WScript.Quit 1
End If
WScript.Echo "  [OK] Datenbank geoeffnet via DAO"

' ============================================
' ABFRAGEN ERSTELLEN
' ============================================
WScript.Echo vbCrLf & "2. Abfragen erstellen..."

CreateQuery "qry_DP_Board_Objekt", _
    "SELECT tbl_VA_Start.ID AS StartID, tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID, " & _
    "tbl_VA_Start.VADatum AS TagDatum, Format(tbl_VA_Start.VADatum, 'dddd') AS Wochentag, " & _
    "tbl_VA_Auftragstamm.Auftrag AS Auftragsname, tbl_VA_Auftragstamm.Objekt AS ObjektName, " & _
    "tbl_VA_Auftragstamm.Veranstalter_ID AS KundeID, tbl_KD_Kundenstamm.kun_Firma AS KundeName, " & _
    "tbl_VA_Start.VA_Start AS ZeitVon, tbl_VA_Start.VA_Ende AS ZeitBis, " & _
    "tbl_VA_Start.MA_Anzahl AS Soll, Nz(tbl_VA_Start.MA_Anzahl_Ist, 0) AS Ist, " & _
    "IIf(Nz(tbl_VA_Start.MA_Anzahl, 0) - Nz(tbl_VA_Start.MA_Anzahl_Ist, 0) > 0, " & _
    "tbl_VA_Start.MA_Anzahl - Nz(tbl_VA_Start.MA_Anzahl_Ist, 0), 0) AS Offen " & _
    "FROM (tbl_VA_Start INNER JOIN tbl_VA_Auftragstamm ON tbl_VA_Start.VA_ID = tbl_VA_Auftragstamm.ID) " & _
    "LEFT JOIN tbl_KD_Kundenstamm ON tbl_VA_Auftragstamm.Veranstalter_ID = tbl_KD_Kundenstamm.kun_Id " & _
    "ORDER BY tbl_VA_Start.VADatum, tbl_VA_Start.VA_Start"

CreateQuery "qry_DP_Board_MA", _
    "SELECT tbl_MA_VA_Planung.ID AS PlanungID, tbl_MA_VA_Planung.MA_ID, " & _
    "tbl_MA_Mitarbeiterstamm.Nachname & ', ' & tbl_MA_Mitarbeiterstamm.Vorname AS MAName, " & _
    "tbl_MA_VA_Planung.VADatum AS TagDatum, Format(tbl_MA_VA_Planung.VADatum, 'dddd') AS Wochentag, " & _
    "tbl_MA_VA_Planung.VA_ID, tbl_VA_Auftragstamm.Auftrag AS Auftragsname, " & _
    "tbl_MA_VA_Planung.VA_Start AS ZeitVon, tbl_MA_VA_Planung.VA_Ende AS ZeitBis, " & _
    "tbl_MA_VA_Planung.Status_ID " & _
    "FROM (tbl_MA_VA_Planung INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Planung.MA_ID = tbl_MA_Mitarbeiterstamm.ID) " & _
    "LEFT JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Planung.VA_ID = tbl_VA_Auftragstamm.ID " & _
    "ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_VA_Planung.VADatum"

CreateQuery "qry_DP_MA_Verfuegbar", _
    "SELECT tbl_MA_Mitarbeiterstamm.ID AS MA_ID, " & _
    "tbl_MA_Mitarbeiterstamm.Nachname & ', ' & tbl_MA_Mitarbeiterstamm.Vorname AS MAName, " & _
    "tbl_MA_Mitarbeiterstamm.Tel_Mobil AS Mobil " & _
    "FROM tbl_MA_Mitarbeiterstamm " & _
    "WHERE tbl_MA_Mitarbeiterstamm.IstAktiv = True " & _
    "ORDER BY tbl_MA_Mitarbeiterstamm.Nachname"

db.Close
Set db = Nothing
Set ws = Nothing
Set dao = Nothing
WScript.Echo "  Abfragen erstellt, DAO geschlossen"

' ============================================
' ACCESS STARTEN FUER FORMULARE
' ============================================
WScript.Echo vbCrLf & "3. Access starten fuer Formulare..."
Set access = CreateObject("Access.Application")
If Err.Number <> 0 Then
    WScript.Echo "FEHLER Access: " & Err.Description
    WScript.Quit 1
End If
access.Visible = True
WScript.Echo "  Access gestartet"
WScript.Sleep 1000

access.OpenCurrentDatabase strFrontendPath, False
If Err.Number <> 0 Then
    WScript.Echo "FEHLER Oeffnen: " & Err.Description
    access.Quit
    WScript.Quit 1
End If
WScript.Echo "  Datenbank geoeffnet"
WScript.Sleep 2000

' ============================================
' VBA-MODUL ERSTELLEN
' ============================================
WScript.Echo vbCrLf & "4. VBA-Modul erstellen..."
CreateVBAModule

' ============================================
' FORMULARE ERSTELLEN
' ============================================
WScript.Echo vbCrLf & "5. Formulare erstellen..."
access.DoCmd.SetWarnings False

' Unterformular Objekt
CreateSubformAsDatasheet "frm_DP_Board_Objekt", "qry_DP_Board_Objekt", False

' Unterformular MA
CreateSubformAsDatasheet "frm_DP_Board_MA", "qry_DP_Board_MA", False

' Unterformular Verfuegbar
CreateSubformAsDatasheet "frm_DP_MA_Verfuegbar", "qry_DP_MA_Verfuegbar", True

' Hauptformular
CreateMainFormComplete

access.DoCmd.SetWarnings True

' ============================================
' FERTIG
' ============================================
WScript.Echo vbCrLf & "============================================"
WScript.Echo "FERTIG!"
WScript.Echo "============================================"
WScript.Echo "Oeffne Dashboard mit: DoCmd.OpenForm ""frm_DP_Board"""

On Error Resume Next
access.CloseCurrentDatabase
access.Quit
Set access = Nothing

WScript.Quit 0

' ============================================
' ABFRAGE ERSTELLEN
' ============================================
Sub CreateQuery(strName, strSQL)
    On Error Resume Next
    Err.Clear

    ' Alte Abfrage loeschen
    Dim qd
    For Each qd In db.QueryDefs
        If qd.Name = strName Then
            db.QueryDefs.Delete strName
            Exit For
        End If
    Next
    Err.Clear

    ' Neue Abfrage erstellen
    db.CreateQueryDef strName, strSQL

    If Err.Number = 0 Then
        WScript.Echo "  [OK] " & strName
    Else
        WScript.Echo "  [!] " & strName & ": " & Err.Description
        Err.Clear
    End If
End Sub

' ============================================
' VBA-MODUL ERSTELLEN
' ============================================
Sub CreateVBAModule()
    On Error Resume Next
    Err.Clear

    Dim vbe, proj, comp, codeMod
    Dim strModuleName, strCode
    Dim c

    strModuleName = "mod_N_DP_Board"

    Set vbe = access.VBE
    If Err.Number <> 0 Or vbe Is Nothing Then
        WScript.Echo "  [!] VBE nicht verfuegbar"
        WScript.Echo "      Trust Center > Makroeinstellungen >"
        WScript.Echo "      'Zugriff auf VBA-Projektobjektmodell vertrauen' aktivieren"
        Err.Clear
        Exit Sub
    End If

    Set proj = vbe.ActiveVBProject
    If Err.Number <> 0 Or proj Is Nothing Then
        WScript.Echo "  [!] VBProject nicht verfuegbar"
        Err.Clear
        Exit Sub
    End If

    ' Pruefen ob Modul existiert
    Dim moduleExists
    moduleExists = False
    For Each c In proj.VBComponents
        If c.Name = strModuleName Then
            moduleExists = True
            Set comp = c
            Set codeMod = comp.CodeModule
            If codeMod.CountOfLines > 0 Then
                codeMod.DeleteLines 1, codeMod.CountOfLines
            End If
            Exit For
        End If
    Next

    If Not moduleExists Then
        Set comp = proj.VBComponents.Add(1)
        comp.Name = strModuleName
        Set codeMod = comp.CodeModule
    End If

    strCode = BuildVBACode()
    codeMod.AddFromString strCode

    If Err.Number = 0 Then
        WScript.Echo "  [OK] " & strModuleName
    Else
        WScript.Echo "  [!] " & strModuleName & ": " & Err.Description
        Err.Clear
    End If
End Sub

Function BuildVBACode()
    Dim s
    s = "Option Compare Database" & vbCrLf
    s = s & "Option Explicit" & vbCrLf & vbCrLf
    s = s & "' ===== PLANUNGS-DASHBOARD =====" & vbCrLf
    s = s & "' Erstellt: " & Now() & vbCrLf & vbCrLf

    s = s & "Public g_DatumVon As Date" & vbCrLf
    s = s & "Public g_DatumBis As Date" & vbCrLf
    s = s & "Public g_KundeID As Long" & vbCrLf
    s = s & "Public g_AnsichtModus As Integer" & vbCrLf & vbCrLf

    ' Filter anwenden
    s = s & "Public Sub DP_Board_Filter_Anwenden(frm As Form)" & vbCrLf
    s = s & "    On Error Resume Next" & vbCrLf
    s = s & "    g_DatumVon = Nz(frm!txtVon, Date)" & vbCrLf
    s = s & "    g_DatumBis = Nz(frm!txtBis, DateAdd(""d"", 7, Date))" & vbCrLf
    s = s & "    g_KundeID = Nz(frm!cboKunde, 0)" & vbCrLf
    s = s & "    Dim sFilter As String" & vbCrLf
    s = s & "    sFilter = ""TagDatum >= #"" & Format(g_DatumVon, ""yyyy-mm-dd"") & ""# "" & _" & vbCrLf
    s = s & "              ""AND TagDatum <= #"" & Format(g_DatumBis, ""yyyy-mm-dd"") & ""#""" & vbCrLf
    s = s & "    If g_KundeID > 0 Then sFilter = sFilter & "" AND KundeID = "" & g_KundeID" & vbCrLf
    s = s & "    frm!subBoard.Form.Filter = sFilter" & vbCrLf
    s = s & "    frm!subBoard.Form.FilterOn = True" & vbCrLf
    s = s & "    frm!subMA_Verfuegbar.Form.Requery" & vbCrLf
    s = s & "End Sub" & vbCrLf & vbCrLf

    ' Ansicht umschalten
    s = s & "Public Sub DP_Board_Ansicht_Umschalten(frm As Form)" & vbCrLf
    s = s & "    On Error Resume Next" & vbCrLf
    s = s & "    g_AnsichtModus = Nz(frm!optAnsicht, 1)" & vbCrLf
    s = s & "    If g_AnsichtModus = 1 Then" & vbCrLf
    s = s & "        frm!subBoard.SourceObject = ""Form.frm_DP_Board_Objekt""" & vbCrLf
    s = s & "    Else" & vbCrLf
    s = s & "        frm!subBoard.SourceObject = ""Form.frm_DP_Board_MA""" & vbCrLf
    s = s & "    End If" & vbCrLf
    s = s & "    frm!subBoard.Form.Requery" & vbCrLf
    s = s & "End Sub" & vbCrLf & vbCrLf

    ' MA Zuordnen
    s = s & "Public Sub DP_Board_MA_Zuordnen(lngMA_ID As Long, frm As Form)" & vbCrLf
    s = s & "    On Error GoTo ErrHandler" & vbCrLf
    s = s & "    Dim dbs As DAO.Database, rs As DAO.Recordset" & vbCrLf
    s = s & "    Dim lngVA_ID As Long, lngVAStart_ID As Long" & vbCrLf
    s = s & "    Dim dteVADatum As Date, dteVon As Date, dteBis As Date" & vbCrLf & vbCrLf
    s = s & "    With frm.Parent!subBoard.Form" & vbCrLf
    s = s & "        lngVA_ID = Nz(.!VA_ID, 0)" & vbCrLf
    s = s & "        lngVAStart_ID = Nz(.!StartID, 0)" & vbCrLf
    s = s & "        dteVADatum = Nz(.!TagDatum, Date)" & vbCrLf
    s = s & "        dteVon = Nz(.!ZeitVon, #8:00:00 AM#)" & vbCrLf
    s = s & "        dteBis = Nz(.!ZeitBis, #18:00:00 PM#)" & vbCrLf
    s = s & "    End With" & vbCrLf & vbCrLf
    s = s & "    If lngVA_ID = 0 Then" & vbCrLf
    s = s & "        MsgBox ""Bitte zuerst einen Einsatz auswaehlen!"", vbExclamation" & vbCrLf
    s = s & "        Exit Sub" & vbCrLf
    s = s & "    End If" & vbCrLf & vbCrLf
    s = s & "    If DCount(""ID"", ""tbl_MA_VA_Planung"", ""MA_ID="" & lngMA_ID & "" AND VAStart_ID="" & lngVAStart_ID) > 0 Then" & vbCrLf
    s = s & "        MsgBox ""Mitarbeiter ist bereits zugeordnet!"", vbExclamation" & vbCrLf
    s = s & "        Exit Sub" & vbCrLf
    s = s & "    End If" & vbCrLf & vbCrLf
    s = s & "    Set dbs = CurrentDb" & vbCrLf
    s = s & "    Set rs = dbs.OpenRecordset(""tbl_MA_VA_Planung"", dbOpenDynaset)" & vbCrLf
    s = s & "    rs.AddNew" & vbCrLf
    s = s & "    rs!VA_ID = lngVA_ID" & vbCrLf
    s = s & "    rs!VAStart_ID = lngVAStart_ID" & vbCrLf
    s = s & "    rs!VADatum = dteVADatum" & vbCrLf
    s = s & "    rs!VA_Start = dteVon" & vbCrLf
    s = s & "    rs!VA_Ende = dteBis" & vbCrLf
    s = s & "    rs!MA_ID = lngMA_ID" & vbCrLf
    s = s & "    rs!Status_ID = 1" & vbCrLf
    s = s & "    rs!Erst_von = Environ(""USERNAME"")" & vbCrLf
    s = s & "    rs!Erst_am = Now()" & vbCrLf
    s = s & "    rs.Update" & vbCrLf
    s = s & "    rs.Close" & vbCrLf & vbCrLf
    s = s & "    dbs.Execute ""UPDATE tbl_VA_Start SET MA_Anzahl_Ist = Nz(MA_Anzahl_Ist,0) + 1 WHERE ID = "" & lngVAStart_ID, dbFailOnError" & vbCrLf & vbCrLf
    s = s & "    frm.Parent!subBoard.Form.Requery" & vbCrLf
    s = s & "    frm.Requery" & vbCrLf
    s = s & "    MsgBox ""Mitarbeiter zugeordnet!"", vbInformation" & vbCrLf
    s = s & "    Exit Sub" & vbCrLf & vbCrLf
    s = s & "ErrHandler:" & vbCrLf
    s = s & "    MsgBox ""Fehler: "" & Err.Description, vbCritical" & vbCrLf
    s = s & "End Sub" & vbCrLf & vbCrLf

    ' Ampel-Funktion
    s = s & "Public Function DP_Board_Ampel(lngSoll As Long, lngIst As Long) As Long" & vbCrLf
    s = s & "    If lngSoll = 0 Then" & vbCrLf
    s = s & "        DP_Board_Ampel = vbWhite" & vbCrLf
    s = s & "    ElseIf lngIst >= lngSoll Then" & vbCrLf
    s = s & "        DP_Board_Ampel = RGB(198, 246, 213)" & vbCrLf
    s = s & "    ElseIf lngIst >= lngSoll * 0.5 Then" & vbCrLf
    s = s & "        DP_Board_Ampel = RGB(254, 243, 199)" & vbCrLf
    s = s & "    Else" & vbCrLf
    s = s & "        DP_Board_Ampel = RGB(254, 215, 215)" & vbCrLf
    s = s & "    End If" & vbCrLf
    s = s & "End Function" & vbCrLf & vbCrLf

    ' Dashboard oeffnen
    s = s & "Public Sub DP_Board_Oeffnen()" & vbCrLf
    s = s & "    DoCmd.OpenForm ""frm_DP_Board"", acNormal" & vbCrLf
    s = s & "End Sub" & vbCrLf

    BuildVBACode = s
End Function

' ============================================
' UNTERFORMULAR ALS DATENBLATT ERSTELLEN
' ============================================
Sub CreateSubformAsDatasheet(strName, strRecSource, blnWithDblClick)
    On Error Resume Next
    Err.Clear

    WScript.Echo "  Erstelle " & strName & "..."

    ' Loeschen falls vorhanden
    access.DoCmd.DeleteObject 2, strName
    Err.Clear

    ' Formular erstellen
    access.DoCmd.SelectObject 2, , True
    Dim frmName
    frmName = access.CreateForm()

    If Err.Number <> 0 Then
        WScript.Echo "    [!] CreateForm: " & Err.Description
        Err.Clear
        Exit Sub
    End If

    ' Umbenennen
    access.DoCmd.Close 2, frmName, 1
    access.DoCmd.Rename strName, 2, frmName
    Err.Clear

    ' Konfigurieren
    access.DoCmd.OpenForm strName, 0
    Dim frm
    Set frm = access.Forms(strName)

    If frm Is Nothing Then
        WScript.Echo "    [!] Formular nicht gefunden"
        Exit Sub
    End If

    frm.RecordSource = strRecSource
    frm.DefaultView = 2  ' Datenblatt
    frm.AllowAdditions = False
    frm.AllowDeletions = False
    frm.AllowEdits = False
    frm.NavigationButtons = False

    access.DoCmd.Close 2, strName, 1
    WScript.Echo "    [OK]"
End Sub

' ============================================
' HAUPTFORMULAR ERSTELLEN
' ============================================
Sub CreateMainFormComplete()
    On Error Resume Next
    Err.Clear

    Dim strName
    strName = "frm_DP_Board"

    WScript.Echo "  Erstelle " & strName & " (Hauptformular)..."

    ' Loeschen falls vorhanden
    access.DoCmd.DeleteObject 2, strName
    Err.Clear

    ' Formular erstellen
    access.DoCmd.SelectObject 2, , True
    Dim frmName
    frmName = access.CreateForm()

    If Err.Number <> 0 Then
        WScript.Echo "    [!] CreateForm: " & Err.Description
        Err.Clear
        Exit Sub
    End If

    ' Umbenennen
    access.DoCmd.Close 2, frmName, 1
    access.DoCmd.Rename strName, 2, frmName
    Err.Clear

    ' Konfigurieren
    access.DoCmd.OpenForm strName, 0
    Dim frm
    Set frm = access.Forms(strName)

    If frm Is Nothing Then
        WScript.Echo "    [!] Hauptformular nicht gefunden"
        Exit Sub
    End If

    frm.Caption = "Planungs-Dashboard"
    frm.DefaultView = 0
    frm.Width = 20000
    frm.Section(0).Height = 7500
    frm.Section(1).Height = 1200
    frm.RecordSelectors = False
    frm.NavigationButtons = False

    Dim ctl

    ' === HEADER ===
    ' Titel
    Set ctl = access.CreateControl(strName, 100, 1, "", "", 200, 100, 7000, 500)
    ctl.Name = "lblTitel"
    ctl.Caption = "PLANUNGS-DASHBOARD"
    ctl.FontSize = 18
    ctl.FontBold = True
    ctl.ForeColor = RGB(44, 82, 130)

    ' Von
    Set ctl = access.CreateControl(strName, 100, 1, "", "", 200, 700, 500, 250)
    ctl.Caption = "Von:"
    Set ctl = access.CreateControl(strName, 109, 1, "", "", 700, 700, 1500, 300)
    ctl.Name = "txtVon"
    ctl.DefaultValue = "=Date()"
    ctl.Format = "Short Date"

    ' Bis
    Set ctl = access.CreateControl(strName, 100, 1, "", "", 2400, 700, 500, 250)
    ctl.Caption = "Bis:"
    Set ctl = access.CreateControl(strName, 109, 1, "", "", 2900, 700, 1500, 300)
    ctl.Name = "txtBis"
    ctl.DefaultValue = "=DateAdd('d',7,Date())"
    ctl.Format = "Short Date"

    ' Kunde
    Set ctl = access.CreateControl(strName, 100, 1, "", "", 4700, 700, 700, 250)
    ctl.Caption = "Kunde:"
    Set ctl = access.CreateControl(strName, 111, 1, "", "", 5400, 700, 3500, 300)
    ctl.Name = "cboKunde"
    ctl.RowSource = "SELECT kun_Id, kun_Firma FROM tbl_KD_Kundenstamm WHERE kun_IstAktiv=True ORDER BY kun_Firma"
    ctl.ColumnCount = 2
    ctl.ColumnWidths = "0;3500"
    ctl.BoundColumn = 1

    ' Filter-Button
    Set ctl = access.CreateControl(strName, 104, 1, "", "", 9100, 700, 2000, 350)
    ctl.Name = "cmdFilter"
    ctl.Caption = "Filter anwenden"
    ctl.OnClick = "=DP_Board_Filter_Anwenden([Form])"

    ' === DETAIL ===
    ' Board-Unterformular (links)
    Set ctl = access.CreateControl(strName, 112, 0, "", "", 200, 200, 12000, 6500)
    ctl.Name = "subBoard"
    ctl.SourceObject = "Form.frm_DP_Board_Objekt"

    ' Label MA-Liste
    Set ctl = access.CreateControl(strName, 100, 0, "", "", 12400, 50, 6500, 300)
    ctl.Caption = "Verfuegbare Mitarbeiter (Doppelklick = Zuordnen)"
    ctl.FontBold = True
    ctl.ForeColor = RGB(44, 82, 130)

    ' MA-Unterformular (rechts)
    Set ctl = access.CreateControl(strName, 112, 0, "", "", 12400, 400, 6500, 6300)
    ctl.Name = "subMA_Verfuegbar"
    ctl.SourceObject = "Form.frm_DP_MA_Verfuegbar"

    access.DoCmd.Close 2, strName, 1
    WScript.Echo "    [OK]"
End Sub

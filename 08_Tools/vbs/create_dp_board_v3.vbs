' ============================================
' PLANUNGS-DASHBOARD ERSTELLEN V3
' Mit verbesserter Fehlerbehandlung
' ============================================

Option Explicit

Dim access, db
Dim strFrontendPath

' Frontend-Pfad direkt setzen
strFrontendPath = "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"

WScript.Echo "============================================"
WScript.Echo "PLANUNGS-DASHBOARD ERSTELLEN V3"
WScript.Echo "============================================"
WScript.Echo "Frontend: " & strFrontendPath

On Error Resume Next

' Access starten
WScript.Echo vbCrLf & "1. Access starten..."
Set access = CreateObject("Access.Application")
If Err.Number <> 0 Then
    WScript.Echo "FEHLER: " & Err.Description
    WScript.Quit 1
End If
Err.Clear

access.Visible = True
WScript.Echo "  Access gestartet"
WScript.Sleep 1000

' Datenbank oeffnen
WScript.Echo "  Oeffne Datenbank..."
access.OpenCurrentDatabase strFrontendPath, False
If Err.Number <> 0 Then
    WScript.Echo "FEHLER beim Oeffnen: " & Err.Description
    access.Quit
    WScript.Quit 1
End If
Err.Clear

WScript.Echo "  Datenbank geoeffnet"
WScript.Sleep 2000

' CurrentDb ueber Application-Objekt
WScript.Echo "  Hole CurrentDb..."
Set db = access.CurrentDb
If Err.Number <> 0 Then
    WScript.Echo "  CurrentDb Fehler: " & Err.Description
    ' Trotzdem weitermachen, Abfragen ueber DoCmd
    Err.Clear
End If

' ============================================
' ABFRAGEN ERSTELLEN
' ============================================
WScript.Echo vbCrLf & "2. Abfragen erstellen..."

' Abfragen via SQL-Strings
Dim arrQueries(2,1)
arrQueries(0,0) = "qry_DP_Board_Objekt"
arrQueries(0,1) = "SELECT tbl_VA_Start.ID AS StartID, tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID, " & _
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

arrQueries(1,0) = "qry_DP_Board_MA"
arrQueries(1,1) = "SELECT tbl_MA_VA_Planung.ID AS PlanungID, tbl_MA_VA_Planung.MA_ID, " & _
    "tbl_MA_Mitarbeiterstamm.Nachname & ', ' & tbl_MA_Mitarbeiterstamm.Vorname AS MAName, " & _
    "tbl_MA_VA_Planung.VADatum AS TagDatum, Format(tbl_MA_VA_Planung.VADatum, 'dddd') AS Wochentag, " & _
    "tbl_MA_VA_Planung.VA_ID, tbl_VA_Auftragstamm.Auftrag AS Auftragsname, " & _
    "tbl_MA_VA_Planung.VA_Start AS ZeitVon, tbl_MA_VA_Planung.VA_Ende AS ZeitBis, " & _
    "tbl_MA_VA_Planung.Status_ID " & _
    "FROM (tbl_MA_VA_Planung INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Planung.MA_ID = tbl_MA_Mitarbeiterstamm.ID) " & _
    "LEFT JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Planung.VA_ID = tbl_VA_Auftragstamm.ID " & _
    "ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_VA_Planung.VADatum"

arrQueries(2,0) = "qry_DP_MA_Verfuegbar"
arrQueries(2,1) = "SELECT tbl_MA_Mitarbeiterstamm.ID AS MA_ID, " & _
    "tbl_MA_Mitarbeiterstamm.Nachname & ', ' & tbl_MA_Mitarbeiterstamm.Vorname AS MAName, " & _
    "tbl_MA_Mitarbeiterstamm.Tel_Mobil AS Mobil " & _
    "FROM tbl_MA_Mitarbeiterstamm " & _
    "WHERE tbl_MA_Mitarbeiterstamm.IstAktiv = True " & _
    "ORDER BY tbl_MA_Mitarbeiterstamm.Nachname"

Dim i
For i = 0 To 2
    CreateQueryViaDoCmd arrQueries(i,0), arrQueries(i,1)
Next

' ============================================
' VBA-MODUL ERSTELLEN
' ============================================
WScript.Echo vbCrLf & "3. VBA-Modul erstellen..."
CreateVBAModule

' ============================================
' FORMULARE ERSTELLEN
' ============================================
WScript.Echo vbCrLf & "4. Formulare erstellen..."
CreateAllForms

' ============================================
' FERTIG
' ============================================
WScript.Echo vbCrLf & "============================================"
WScript.Echo "FERTIG!"
WScript.Echo "============================================"
WScript.Echo "Oeffne Dashboard mit: DP_Board_Oeffnen"

On Error Resume Next
access.CloseCurrentDatabase
access.Quit
Set access = Nothing

WScript.Quit 0

' ============================================
' ABFRAGE ERSTELLEN VIA DOCMD
' ============================================
Sub CreateQueryViaDoCmd(strName, strSQL)
    On Error Resume Next
    Err.Clear

    ' Alte Abfrage loeschen
    access.DoCmd.SetWarnings False
    access.DoCmd.DeleteObject 5, strName
    Err.Clear

    ' Abfrage per RunSQL erstellen (geht nicht direkt)
    ' Stattdessen via CurrentDb wenn verfuegbar
    If Not db Is Nothing Then
        Dim qdef
        Set qdef = db.CreateQueryDef(strName, strSQL)
        If Err.Number = 0 Then
            WScript.Echo "  [OK] " & strName
        Else
            WScript.Echo "  [!] " & strName & ": " & Err.Description
            Err.Clear
        End If
    Else
        ' Fallback: Abfrage in temporaerer Datei speichern
        WScript.Echo "  [SKIP] " & strName & " (kein CurrentDb)"
    End If

    access.DoCmd.SetWarnings True
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
        WScript.Echo "  [!] VBE nicht verfuegbar - Trust Center pruefen"
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
    s = s & "' ===== PLANUNGS-DASHBOARD =====" & vbCrLf & vbCrLf

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
' FORMULARE ERSTELLEN
' ============================================
Sub CreateAllForms()
    On Error Resume Next

    access.DoCmd.SetWarnings False

    ' Unterformular Objekt
    CreateSubform "frm_DP_Board_Objekt", "qry_DP_Board_Objekt"

    ' Unterformular MA
    CreateSubform "frm_DP_Board_MA", "qry_DP_Board_MA"

    ' Unterformular Verfuegbar
    CreateSubform "frm_DP_MA_Verfuegbar", "qry_DP_MA_Verfuegbar"

    ' Hauptformular
    CreateMainForm

    access.DoCmd.SetWarnings True
End Sub

Sub CreateSubform(strName, strRecSource)
    On Error Resume Next
    Err.Clear

    WScript.Echo "  Erstelle " & strName & "..."

    ' Loeschen
    access.DoCmd.DeleteObject 2, strName
    Err.Clear

    ' Erstellen
    Dim frmName
    frmName = access.CreateForm()

    access.DoCmd.Save 2, frmName, strName

    ' Konfigurieren
    access.DoCmd.OpenForm strName, 0  ' Design
    Dim frm
    Set frm = access.Forms(strName)

    If Not frm Is Nothing Then
        frm.RecordSource = strRecSource
        frm.DefaultView = 2  ' Datenblatt
        frm.AllowAdditions = False
        frm.AllowDeletions = False

        If strName = "frm_DP_MA_Verfuegbar" Then
            frm.AllowEdits = False
            frm.OnDblClick = "=DP_Board_MA_Zuordnen([MA_ID],[Form])"
        End If

        access.DoCmd.Close 2, strName, 1
        WScript.Echo "    [OK]"
    Else
        WScript.Echo "    [!] Formular nicht gefunden"
    End If
End Sub

Sub CreateMainForm()
    On Error Resume Next
    Err.Clear

    Dim strName
    strName = "frm_DP_Board"

    WScript.Echo "  Erstelle " & strName & " (Hauptformular)..."

    ' Loeschen
    access.DoCmd.DeleteObject 2, strName
    Err.Clear

    ' Erstellen
    Dim frmName
    frmName = access.CreateForm()
    access.DoCmd.Save 2, frmName, strName

    ' Konfigurieren
    access.DoCmd.OpenForm strName, 0
    Dim frm
    Set frm = access.Forms(strName)

    If frm Is Nothing Then
        WScript.Echo "    [!] Hauptformular nicht erstellt"
        Exit Sub
    End If

    frm.Caption = "Planungs-Dashboard"
    frm.DefaultView = 0
    frm.Width = 20000
    frm.Section(0).Height = 7500
    frm.Section(1).Height = 1200

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

    ' Ansicht
    Set ctl = access.CreateControl(strName, 100, 1, "", "", 11300, 700, 800, 250)
    ctl.Caption = "Ansicht:"
    Set ctl = access.CreateControl(strName, 105, 1, "", "", 12100, 650, 3000, 400)
    ctl.Name = "optAnsicht"
    ctl.DefaultValue = 1
    ctl.AfterUpdate = "=DP_Board_Ansicht_Umschalten([Form])"

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

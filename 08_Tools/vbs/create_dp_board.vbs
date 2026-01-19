' ============================================
' PLANUNGS-DASHBOARD ERSTELLEN
' VBScript fuer Access Automation
' ============================================

Option Explicit

Dim access, db, fso, shell
Dim strFrontendPath, strConfigPath
Dim objConfig, strConfigText

' Pfad zur config.json
strConfigPath = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName) & "\config.json"

' Config lesen
Set fso = CreateObject("Scripting.FileSystemObject")
Set objConfig = fso.OpenTextFile(strConfigPath, 1)
strConfigText = objConfig.ReadAll
objConfig.Close

' Frontend-Pfad extrahieren (einfaches Parsing)
Dim pos1, pos2
pos1 = InStr(strConfigText, """frontend_path""")
pos1 = InStr(pos1, strConfigText, ":") + 1
pos1 = InStr(pos1, strConfigText, """") + 1
pos2 = InStr(pos1, strConfigText, """")
strFrontendPath = Mid(strConfigText, pos1, pos2 - pos1)
strFrontendPath = Replace(strFrontendPath, "\\", "\")

WScript.Echo "============================================"
WScript.Echo "PLANUNGS-DASHBOARD ERSTELLEN"
WScript.Echo "============================================"
WScript.Echo "Frontend: " & strFrontendPath

On Error Resume Next

' Access starten
WScript.Echo vbCrLf & "1. Access starten..."
Set access = CreateObject("Access.Application")
If Err.Number <> 0 Then
    WScript.Echo "FEHLER: Access konnte nicht gestartet werden: " & Err.Description
    WScript.Quit 1
End If

access.Visible = False
access.OpenCurrentDatabase strFrontendPath
If Err.Number <> 0 Then
    WScript.Echo "FEHLER: Datenbank konnte nicht geoeffnet werden: " & Err.Description
    access.Quit
    WScript.Quit 1
End If

Set db = access.CurrentDb()

' ============================================
' ABFRAGEN ERSTELLEN
' ============================================
WScript.Echo vbCrLf & "2. Abfragen erstellen..."

Dim sqlObjekt, sqlMA, sqlVerfueg

' Objekt-Board Abfrage
sqlObjekt = "SELECT " & _
    "tbl_VA_Start.ID AS StartID, " & _
    "tbl_VA_Start.VA_ID, " & _
    "tbl_VA_Start.VADatum_ID, " & _
    "tbl_VA_Start.VADatum AS TagDatum, " & _
    "Format(tbl_VA_Start.VADatum, 'dddd') AS Wochentag, " & _
    "tbl_VA_Auftragstamm.Auftrag AS Auftragsname, " & _
    "tbl_VA_Auftragstamm.Objekt AS ObjektName, " & _
    "tbl_VA_Auftragstamm.Veranstalter_ID AS KundeID, " & _
    "tbl_KD_Kundenstamm.kun_Firma AS KundeName, " & _
    "tbl_VA_Start.VA_Start AS ZeitVon, " & _
    "tbl_VA_Start.VA_Ende AS ZeitBis, " & _
    "tbl_VA_Start.MA_Anzahl AS Soll, " & _
    "Nz(tbl_VA_Start.MA_Anzahl_Ist, 0) AS Ist, " & _
    "IIf(Nz(tbl_VA_Start.MA_Anzahl, 0) - Nz(tbl_VA_Start.MA_Anzahl_Ist, 0) > 0, " & _
    "tbl_VA_Start.MA_Anzahl - Nz(tbl_VA_Start.MA_Anzahl_Ist, 0), 0) AS Offen, " & _
    "tbl_VA_Auftragstamm.Veranst_Status_ID AS StatusID " & _
    "FROM ((tbl_VA_Start " & _
    "INNER JOIN tbl_VA_Auftragstamm ON tbl_VA_Start.VA_ID = tbl_VA_Auftragstamm.ID) " & _
    "LEFT JOIN tbl_KD_Kundenstamm ON tbl_VA_Auftragstamm.Veranstalter_ID = tbl_KD_Kundenstamm.kun_Id) " & _
    "ORDER BY tbl_VA_Start.VADatum, tbl_VA_Start.VA_Start"

' MA-Board Abfrage
sqlMA = "SELECT " & _
    "tbl_MA_VA_Planung.ID AS PlanungID, " & _
    "tbl_MA_VA_Planung.MA_ID, " & _
    "tbl_MA_Mitarbeiterstamm.Nachname & ', ' & tbl_MA_Mitarbeiterstamm.Vorname AS MAName, " & _
    "tbl_MA_VA_Planung.VADatum AS TagDatum, " & _
    "Format(tbl_MA_VA_Planung.VADatum, 'dddd') AS Wochentag, " & _
    "tbl_MA_VA_Planung.VA_ID, " & _
    "tbl_VA_Auftragstamm.Auftrag AS Auftragsname, " & _
    "tbl_VA_Auftragstamm.Objekt AS ObjektName, " & _
    "tbl_VA_Auftragstamm.Veranstalter_ID AS KundeID, " & _
    "tbl_MA_VA_Planung.VA_Start AS ZeitVon, " & _
    "tbl_MA_VA_Planung.VA_Ende AS ZeitBis, " & _
    "DateDiff('n', tbl_MA_VA_Planung.VA_Start, tbl_MA_VA_Planung.VA_Ende) / 60 AS Stunden, " & _
    "tbl_MA_VA_Planung.Status_ID, " & _
    "tbl_MA_Plan_Status.Status AS StatusText " & _
    "FROM ((tbl_MA_VA_Planung " & _
    "INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Planung.MA_ID = tbl_MA_Mitarbeiterstamm.ID) " & _
    "LEFT JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Planung.VA_ID = tbl_VA_Auftragstamm.ID) " & _
    "LEFT JOIN tbl_MA_Plan_Status ON tbl_MA_VA_Planung.Status_ID = tbl_MA_Plan_Status.ID " & _
    "ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_VA_Planung.VADatum"

' Verfuegbare MA Abfrage
sqlVerfueg = "SELECT " & _
    "tbl_MA_Mitarbeiterstamm.ID AS MA_ID, " & _
    "tbl_MA_Mitarbeiterstamm.Nachname & ', ' & tbl_MA_Mitarbeiterstamm.Vorname AS MAName, " & _
    "tbl_MA_Mitarbeiterstamm.Tel_Mobil AS Mobil, " & _
    "tbl_MA_Mitarbeiterstamm.IstAktiv, " & _
    "IIf(tbl_MA_Mitarbeiterstamm.HatSachkunde = True, 'SK', '') & " & _
    "IIf(tbl_MA_Mitarbeiterstamm.Hat_keine_34a = False, ' 34a', '') AS Quali " & _
    "FROM tbl_MA_Mitarbeiterstamm " & _
    "WHERE tbl_MA_Mitarbeiterstamm.IstAktiv = True " & _
    "ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname"

' Abfragen erstellen
Call CreateQuery("qry_DP_Board_Objekt", sqlObjekt)
Call CreateQuery("qry_DP_Board_MA", sqlMA)
Call CreateQuery("qry_DP_MA_Verfuegbar", sqlVerfueg)

' ============================================
' VBA-MODUL ERSTELLEN
' ============================================
WScript.Echo vbCrLf & "3. VBA-Modul erstellen..."
Call CreateVBAModule()

' ============================================
' FORMULARE ERSTELLEN
' ============================================
WScript.Echo vbCrLf & "4. Formulare erstellen..."

' Unterformular: frm_DP_Board_Objekt
Call CreateSubformDatenblatt("frm_DP_Board_Objekt", "qry_DP_Board_Objekt")

' Unterformular: frm_DP_Board_MA
Call CreateSubformDatenblatt("frm_DP_Board_MA", "qry_DP_Board_MA")

' Unterformular: frm_DP_MA_Verfuegbar
Call CreateSubformDatenblatt("frm_DP_MA_Verfuegbar", "qry_DP_MA_Verfuegbar")

' Hauptformular: frm_DP_Board
Call CreateMainForm()

' ============================================
' FERTIG
' ============================================
WScript.Echo vbCrLf & "============================================"
WScript.Echo "FERTIG! Planungs-Dashboard wurde erstellt."
WScript.Echo "============================================"
WScript.Echo vbCrLf & "Erstellte Objekte:"
WScript.Echo "  - qry_DP_Board_Objekt (Objekt-Ansicht)"
WScript.Echo "  - qry_DP_Board_MA (MA-Ansicht)"
WScript.Echo "  - qry_DP_MA_Verfuegbar (Verfuegbare MA)"
WScript.Echo "  - mod_N_DP_Board (VBA-Modul)"
WScript.Echo "  - frm_DP_Board (Hauptformular)"
WScript.Echo "  - frm_DP_Board_Objekt (Unterformular)"
WScript.Echo "  - frm_DP_Board_MA (Unterformular)"
WScript.Echo "  - frm_DP_MA_Verfuegbar (Unterformular)"

access.CloseCurrentDatabase
access.Quit
Set access = Nothing

WScript.Echo vbCrLf & "Druecken Sie eine Taste zum Beenden..."

' ============================================
' HILFSFUNKTIONEN
' ============================================

Sub CreateQuery(strName, strSQL)
    On Error Resume Next

    ' Alte Abfrage loeschen
    db.QueryDefs.Delete strName
    Err.Clear

    ' Neue Abfrage erstellen
    Dim qdef
    Set qdef = db.CreateQueryDef(strName, strSQL)
    If Err.Number = 0 Then
        WScript.Echo "  Abfrage '" & strName & "' erstellt"
    Else
        WScript.Echo "  FEHLER bei '" & strName & "': " & Err.Description
        Err.Clear
    End If
End Sub

Sub CreateSubformDatenblatt(strFormName, strRecordSource)
    On Error Resume Next

    ' Altes Formular loeschen
    access.DoCmd.DeleteObject 2, strFormName
    Err.Clear

    ' Neues Formular erstellen
    access.DoCmd.CreateForm
    access.DoCmd.Save 2, "", strFormName

    ' Formular oeffnen und konfigurieren
    access.DoCmd.OpenForm strFormName, 0  ' acDesign
    Dim frm
    Set frm = access.Forms(strFormName)

    frm.RecordSource = strRecordSource
    frm.DefaultView = 2  ' Datenblatt
    frm.AllowAdditions = False
    frm.AllowDeletions = False
    frm.AllowEdits = False

    access.DoCmd.Close 2, strFormName, 1  ' acSaveYes

    If Err.Number = 0 Then
        WScript.Echo "  Formular '" & strFormName & "' erstellt"
    Else
        WScript.Echo "  FEHLER bei '" & strFormName & "': " & Err.Description
        Err.Clear
    End If
End Sub

Sub CreateMainForm()
    On Error Resume Next

    Dim strFormName
    strFormName = "frm_DP_Board"

    ' Altes Formular loeschen
    access.DoCmd.DeleteObject 2, strFormName
    Err.Clear

    ' Neues Formular erstellen
    access.DoCmd.CreateForm
    access.DoCmd.Save 2, "", strFormName

    ' Formular oeffnen
    access.DoCmd.OpenForm strFormName, 0  ' acDesign
    Dim frm
    Set frm = access.Forms(strFormName)

    frm.DefaultView = 0  ' Einzelformular
    frm.Caption = "Planungs-Dashboard"
    frm.Width = 15000
    frm.Section(0).Height = 8000  ' Detail
    frm.Section(1).Height = 1500  ' Header

    ' Steuerelemente im Header erstellen
    Dim ctl

    ' Label Titel
    Set ctl = access.CreateControl(strFormName, 100, 1, "", "", 200, 100, 6000, 500)
    ctl.Name = "lblTitel"
    ctl.Caption = "PLANUNGS-DASHBOARD"
    ctl.FontSize = 16
    ctl.FontBold = True

    ' Datum Von
    Set ctl = access.CreateControl(strFormName, 100, 1, "", "", 200, 700, 800, 250)
    ctl.Caption = "Von:"
    Set ctl = access.CreateControl(strFormName, 109, 1, "", "", 1000, 700, 1500, 300)
    ctl.Name = "txtVon"
    ctl.Format = "Short Date"
    ctl.DefaultValue = "=Date()"

    ' Datum Bis
    Set ctl = access.CreateControl(strFormName, 100, 1, "", "", 2700, 700, 600, 250)
    ctl.Caption = "Bis:"
    Set ctl = access.CreateControl(strFormName, 109, 1, "", "", 3300, 700, 1500, 300)
    ctl.Name = "txtBis"
    ctl.Format = "Short Date"
    ctl.DefaultValue = "=DateAdd('d',7,Date())"

    ' Kunde Kombi
    Set ctl = access.CreateControl(strFormName, 100, 1, "", "", 5000, 700, 800, 250)
    ctl.Caption = "Kunde:"
    Set ctl = access.CreateControl(strFormName, 111, 1, "", "", 5800, 700, 3000, 300)
    ctl.Name = "cboKunde"
    ctl.RowSource = "SELECT kun_Id, kun_Firma FROM tbl_KD_Kundenstamm ORDER BY kun_Firma"
    ctl.ColumnCount = 2
    ctl.ColumnWidths = "0;3000"
    ctl.BoundColumn = 1

    ' Filter Button
    Set ctl = access.CreateControl(strFormName, 104, 1, "", "", 9000, 700, 1500, 350)
    ctl.Name = "cmdFilter"
    ctl.Caption = "Filter anwenden"
    ctl.OnClick = "=DP_Board_Filter_Anwenden([Form])"

    ' Optionsgruppe fuer Ansicht
    Set ctl = access.CreateControl(strFormName, 100, 1, "", "", 10800, 700, 800, 250)
    ctl.Caption = "Ansicht:"

    Set ctl = access.CreateControl(strFormName, 105, 1, "", "", 11600, 650, 2500, 400)
    ctl.Name = "optAnsicht"
    ctl.DefaultValue = 1

    ' Unterformular Board (links)
    Set ctl = access.CreateControl(strFormName, 112, 0, "", "", 200, 200, 9500, 5500)
    ctl.Name = "subBoard"
    ctl.SourceObject = "Form.frm_DP_Board_Objekt"

    ' Unterformular Verfuegbare MA (rechts)
    Set ctl = access.CreateControl(strFormName, 112, 0, "", "", 9900, 200, 4800, 5500)
    ctl.Name = "subMA_Verfuegbar"
    ctl.SourceObject = "Form.frm_DP_MA_Verfuegbar"

    ' Label ueber MA-Liste
    Set ctl = access.CreateControl(strFormName, 100, 0, "", "", 9900, 50, 4000, 250)
    ctl.Caption = "Verfuegbare Mitarbeiter (Doppelklick = Zuordnen)"
    ctl.FontBold = True

    access.DoCmd.Close 2, strFormName, 1  ' acSaveYes

    If Err.Number = 0 Then
        WScript.Echo "  Hauptformular '" & strFormName & "' erstellt"
    Else
        WScript.Echo "  FEHLER bei '" & strFormName & "': " & Err.Description
        Err.Clear
    End If
End Sub

Sub CreateVBAModule()
    On Error Resume Next

    Dim vbe, proj, comp, codeMod
    Dim strModuleName, strCode

    strModuleName = "mod_N_DP_Board"

    Set vbe = access.VBE
    Set proj = vbe.ActiveVBProject

    ' Pruefen ob Modul existiert
    Dim moduleExists
    moduleExists = False
    For Each comp In proj.VBComponents
        If comp.Name = strModuleName Then
            moduleExists = True
            Set codeMod = comp.CodeModule
            codeMod.DeleteLines 1, codeMod.CountOfLines
            Exit For
        End If
    Next

    If Not moduleExists Then
        Set comp = proj.VBComponents.Add(1)  ' vbext_ct_StdModule
        comp.Name = strModuleName
        Set codeMod = comp.CodeModule
    End If

    ' VBA Code
    strCode = "Option Compare Database" & vbCrLf & _
        "Option Explicit" & vbCrLf & vbCrLf & _
        "' ============================================" & vbCrLf & _
        "' PLANUNGS-DASHBOARD VBA-MODUL" & vbCrLf & _
        "' mod_N_DP_Board" & vbCrLf & _
        "' ============================================" & vbCrLf & vbCrLf & _
        "Public g_DatumVon As Date" & vbCrLf & _
        "Public g_DatumBis As Date" & vbCrLf & _
        "Public g_KundeID As Long" & vbCrLf & _
        "Public g_AnsichtModus As Integer" & vbCrLf & vbCrLf & _
        "Public Sub DP_Board_Filter_Anwenden(frm As Form)" & vbCrLf & _
        "    On Error Resume Next" & vbCrLf & _
        "    g_DatumVon = Nz(frm!txtVon, Date)" & vbCrLf & _
        "    g_DatumBis = Nz(frm!txtBis, DateAdd(""d"", 7, Date))" & vbCrLf & _
        "    g_KundeID = Nz(frm!cboKunde, 0)" & vbCrLf & _
        "    frm!subBoard.Form.Requery" & vbCrLf & _
        "    frm!subMA_Verfuegbar.Form.Requery" & vbCrLf & _
        "End Sub" & vbCrLf & vbCrLf & _
        "Public Sub DP_Board_Ansicht_Umschalten(frm As Form)" & vbCrLf & _
        "    On Error Resume Next" & vbCrLf & _
        "    g_AnsichtModus = Nz(frm!optAnsicht, 1)" & vbCrLf & _
        "    If g_AnsichtModus = 1 Then" & vbCrLf & _
        "        frm!subBoard.SourceObject = ""Form.frm_DP_Board_Objekt""" & vbCrLf & _
        "    Else" & vbCrLf & _
        "        frm!subBoard.SourceObject = ""Form.frm_DP_Board_MA""" & vbCrLf & _
        "    End If" & vbCrLf & _
        "    frm!subBoard.Form.Requery" & vbCrLf & _
        "End Sub" & vbCrLf & vbCrLf & _
        "Public Sub DP_Board_MA_Zuordnen(lngMA_ID As Long, frm As Form)" & vbCrLf & _
        "    On Error GoTo ErrHandler" & vbCrLf & _
        "    Dim db As DAO.Database" & vbCrLf & _
        "    Dim rs As DAO.Recordset" & vbCrLf & _
        "    Dim lngVA_ID As Long, lngVADatum_ID As Long, lngVAStart_ID As Long" & vbCrLf & _
        "    Dim dteVADatum As Date, dteVA_Start As Date, dteVA_Ende As Date" & vbCrLf & vbCrLf & _
        "    With frm.Parent!subBoard.Form" & vbCrLf & _
        "        lngVA_ID = Nz(.!VA_ID, 0)" & vbCrLf & _
        "        lngVADatum_ID = Nz(.!VADatum_ID, 0)" & vbCrLf & _
        "        lngVAStart_ID = Nz(.!StartID, 0)" & vbCrLf & _
        "        dteVADatum = Nz(.!TagDatum, Date)" & vbCrLf & _
        "        dteVA_Start = Nz(.!ZeitVon, #8:00:00 AM#)" & vbCrLf & _
        "        dteVA_Ende = Nz(.!ZeitBis, #18:00:00 PM#)" & vbCrLf & _
        "    End With" & vbCrLf & vbCrLf & _
        "    If lngVA_ID = 0 Then" & vbCrLf & _
        "        MsgBox ""Bitte zuerst einen Einsatz auswaehlen!"", vbExclamation" & vbCrLf & _
        "        Exit Sub" & vbCrLf & _
        "    End If" & vbCrLf & vbCrLf & _
        "    If DCount(""ID"", ""tbl_MA_VA_Planung"", ""MA_ID = "" & lngMA_ID & "" AND VAStart_ID = "" & lngVAStart_ID) > 0 Then" & vbCrLf & _
        "        MsgBox ""MA bereits zugeordnet!"", vbExclamation" & vbCrLf & _
        "        Exit Sub" & vbCrLf & _
        "    End If" & vbCrLf & vbCrLf & _
        "    Set db = CurrentDb" & vbCrLf & _
        "    Set rs = db.OpenRecordset(""tbl_MA_VA_Planung"", dbOpenDynaset)" & vbCrLf & _
        "    rs.AddNew" & vbCrLf & _
        "    rs!VA_ID = lngVA_ID" & vbCrLf & _
        "    rs!VADatum_ID = lngVADatum_ID" & vbCrLf & _
        "    rs!VAStart_ID = lngVAStart_ID" & vbCrLf & _
        "    rs!VADatum = dteVADatum" & vbCrLf & _
        "    rs!VA_Start = dteVA_Start" & vbCrLf & _
        "    rs!VA_Ende = dteVA_Ende" & vbCrLf & _
        "    rs!MA_ID = lngMA_ID" & vbCrLf & _
        "    rs!Status_ID = 1" & vbCrLf & _
        "    rs!Erst_von = Environ(""USERNAME"")" & vbCrLf & _
        "    rs!Erst_am = Now()" & vbCrLf & _
        "    rs.Update" & vbCrLf & _
        "    rs.Close" & vbCrLf & vbCrLf & _
        "    db.Execute ""UPDATE tbl_VA_Start SET MA_Anzahl_Ist = Nz(MA_Anzahl_Ist, 0) + 1 WHERE ID = "" & lngVAStart_ID, dbFailOnError" & vbCrLf & vbCrLf & _
        "    frm.Parent!subBoard.Form.Requery" & vbCrLf & _
        "    frm.Requery" & vbCrLf & _
        "    MsgBox ""MA zugeordnet!"", vbInformation" & vbCrLf & _
        "    Exit Sub" & vbCrLf & vbCrLf & _
        "ErrHandler:" & vbCrLf & _
        "    MsgBox ""Fehler: "" & Err.Description, vbCritical" & vbCrLf & _
        "End Sub" & vbCrLf & vbCrLf & _
        "Public Function DP_Board_Ampel_Farbe(lngSoll As Long, lngIst As Long) As Long" & vbCrLf & _
        "    If lngSoll = 0 Then" & vbCrLf & _
        "        DP_Board_Ampel_Farbe = vbWhite" & vbCrLf & _
        "    ElseIf lngIst >= lngSoll Then" & vbCrLf & _
        "        DP_Board_Ampel_Farbe = RGB(198, 246, 213)" & vbCrLf & _
        "    ElseIf lngIst >= lngSoll * 0.5 Then" & vbCrLf & _
        "        DP_Board_Ampel_Farbe = RGB(254, 243, 199)" & vbCrLf & _
        "    Else" & vbCrLf & _
        "        DP_Board_Ampel_Farbe = RGB(254, 215, 215)" & vbCrLf & _
        "    End If" & vbCrLf & _
        "End Function" & vbCrLf & vbCrLf & _
        "Public Sub DP_Board_Oeffnen()" & vbCrLf & _
        "    DoCmd.OpenForm ""frm_DP_Board"", acNormal" & vbCrLf & _
        "End Sub"

    codeMod.AddFromString strCode

    If Err.Number = 0 Then
        WScript.Echo "  VBA-Modul '" & strModuleName & "' erstellt"
    Else
        WScript.Echo "  FEHLER bei VBA-Modul: " & Err.Description
        Err.Clear
    End If
End Sub

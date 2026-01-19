' ============================================
' PLANUNGS-DASHBOARD ERSTELLEN V5
' Formulare mit DoCmd.Save direkt benennen
' ============================================

Option Explicit

Dim access
Dim strFrontendPath

strFrontendPath = "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"

WScript.Echo "============================================"
WScript.Echo "PLANUNGS-DASHBOARD ERSTELLEN V5"
WScript.Echo "============================================"
WScript.Echo "Frontend: " & strFrontendPath

On Error Resume Next

' ============================================
' ACCESS STARTEN
' ============================================
WScript.Echo vbCrLf & "1. Access starten..."
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
' ABFRAGEN VIA DOCMD.RUNSQL ERSTELLEN
' (Abfragen existieren bereits von v4)
' ============================================
WScript.Echo vbCrLf & "2. Abfragen pruefen..."
Dim db
Set db = access.CurrentDb
If db Is Nothing Then
    WScript.Echo "  [!] CurrentDb nicht verfuegbar"
Else
    CreateQueryIfNotExists "qry_DP_Board_Objekt", _
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

    CreateQueryIfNotExists "qry_DP_Board_MA", _
        "SELECT tbl_MA_VA_Planung.ID AS PlanungID, tbl_MA_VA_Planung.MA_ID, " & _
        "tbl_MA_Mitarbeiterstamm.Nachname & ', ' & tbl_MA_Mitarbeiterstamm.Vorname AS MAName, " & _
        "tbl_MA_VA_Planung.VADatum AS TagDatum, Format(tbl_MA_VA_Planung.VADatum, 'dddd') AS Wochentag, " & _
        "tbl_MA_VA_Planung.VA_ID, tbl_VA_Auftragstamm.Auftrag AS Auftragsname, " & _
        "tbl_MA_VA_Planung.VA_Start AS ZeitVon, tbl_MA_VA_Planung.VA_Ende AS ZeitBis, " & _
        "tbl_MA_VA_Planung.Status_ID " & _
        "FROM (tbl_MA_VA_Planung INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Planung.MA_ID = tbl_MA_Mitarbeiterstamm.ID) " & _
        "LEFT JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Planung.VA_ID = tbl_VA_Auftragstamm.ID " & _
        "ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_VA_Planung.VADatum"

    CreateQueryIfNotExists "qry_DP_MA_Verfuegbar", _
        "SELECT tbl_MA_Mitarbeiterstamm.ID AS MA_ID, " & _
        "tbl_MA_Mitarbeiterstamm.Nachname & ', ' & tbl_MA_Mitarbeiterstamm.Vorname AS MAName, " & _
        "tbl_MA_Mitarbeiterstamm.Tel_Mobil AS Mobil " & _
        "FROM tbl_MA_Mitarbeiterstamm " & _
        "WHERE tbl_MA_Mitarbeiterstamm.IstAktiv = True " & _
        "ORDER BY tbl_MA_Mitarbeiterstamm.Nachname"
End If

' ============================================
' FORMULARE ERSTELLEN MIT NEUER METHODE
' ============================================
WScript.Echo vbCrLf & "3. Formulare erstellen..."
access.DoCmd.SetWarnings False

' Unterformular Objekt
CreateSimpleForm "frm_DP_Board_Objekt", "qry_DP_Board_Objekt"

' Unterformular MA
CreateSimpleForm "frm_DP_Board_MA", "qry_DP_Board_MA"

' Unterformular Verfuegbar
CreateSimpleForm "frm_DP_MA_Verfuegbar", "qry_DP_MA_Verfuegbar"

' Hauptformular
CreateDashboardMain

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
' ABFRAGE ERSTELLEN WENN NICHT VORHANDEN
' ============================================
Sub CreateQueryIfNotExists(strName, strSQL)
    On Error Resume Next
    Err.Clear

    Dim qd, exists
    exists = False

    For Each qd In db.QueryDefs
        If qd.Name = strName Then
            exists = True
            WScript.Echo "  [OK] " & strName & " (existiert)"
            Exit For
        End If
    Next

    If Not exists Then
        db.CreateQueryDef strName, strSQL
        If Err.Number = 0 Then
            WScript.Echo "  [OK] " & strName & " (erstellt)"
        Else
            WScript.Echo "  [!] " & strName & ": " & Err.Description
            Err.Clear
        End If
    End If
End Sub

' ============================================
' EINFACHES FORMULAR ERSTELLEN
' ============================================
Sub CreateSimpleForm(strName, strRecSource)
    On Error Resume Next
    Err.Clear

    WScript.Echo "  Erstelle " & strName & "..."

    ' Pruefen ob existiert
    Dim exists
    exists = False
    Dim doc
    For Each doc In access.CurrentProject.AllForms
        If doc.Name = strName Then
            exists = True
            Exit For
        End If
    Next

    If exists Then
        ' Loeschen
        access.DoCmd.Close 2, strName, 2  ' acSaveNo
        access.DoCmd.DeleteObject 2, strName
        Err.Clear
    End If

    ' Neues Formular erstellen und sofort speichern
    access.DoCmd.SelectObject 2, , True
    Dim newForm
    Set newForm = access.CreateForm()

    If Err.Number <> 0 Then
        WScript.Echo "    [!] CreateForm: " & Err.Description
        Err.Clear
        Exit Sub
    End If

    ' Formular ist jetzt offen im Entwurfsmodus
    ' Direkt konfigurieren
    Dim frm
    Set frm = access.Screen.ActiveForm

    If frm Is Nothing Then
        WScript.Echo "    [!] ActiveForm nicht verfuegbar"
        Exit Sub
    End If

    frm.RecordSource = strRecSource
    frm.DefaultView = 2  ' Datenblatt
    frm.AllowAdditions = False
    frm.AllowDeletions = False
    frm.AllowEdits = False
    frm.NavigationButtons = False
    frm.RecordSelectors = False

    ' Mit Namen speichern
    access.DoCmd.Save 2, , strName
    access.DoCmd.Close 2, strName, 1

    If Err.Number = 0 Then
        WScript.Echo "    [OK]"
    Else
        WScript.Echo "    [!] Save: " & Err.Description
        Err.Clear
    End If
End Sub

' ============================================
' DASHBOARD HAUPTFORMULAR ERSTELLEN
' ============================================
Sub CreateDashboardMain()
    On Error Resume Next
    Err.Clear

    Dim strName
    strName = "frm_DP_Board"

    WScript.Echo "  Erstelle " & strName & " (Hauptformular)..."

    ' Pruefen ob existiert
    Dim exists
    exists = False
    Dim doc
    For Each doc In access.CurrentProject.AllForms
        If doc.Name = strName Then
            exists = True
            Exit For
        End If
    Next

    If exists Then
        access.DoCmd.Close 2, strName, 2
        access.DoCmd.DeleteObject 2, strName
        Err.Clear
    End If

    ' Neues Formular erstellen
    access.DoCmd.SelectObject 2, , True
    Dim newForm
    Set newForm = access.CreateForm()

    If Err.Number <> 0 Then
        WScript.Echo "    [!] CreateForm: " & Err.Description
        Err.Clear
        Exit Sub
    End If

    Dim frm
    Set frm = access.Screen.ActiveForm

    If frm Is Nothing Then
        WScript.Echo "    [!] ActiveForm nicht verfuegbar"
        Exit Sub
    End If

    frm.Caption = "Planungs-Dashboard"
    frm.DefaultView = 0  ' Einzelformular
    frm.ScrollBars = 0   ' Keine
    frm.RecordSelectors = False
    frm.NavigationButtons = False
    frm.Width = 20000

    ' Header vergroessern
    frm.Section(1).Height = 1200

    ' Detail vergroessern
    frm.Section(0).Height = 7000

    Dim frmNameTemp
    frmNameTemp = frm.Name

    ' === HEADER CONTROLS ===
    Dim ctl

    ' Titel
    Set ctl = access.CreateControl(frmNameTemp, 100, 1, "", "", 200, 100, 7000, 500)
    ctl.Name = "lblTitel"
    ctl.Caption = "PLANUNGS-DASHBOARD"
    ctl.FontSize = 18
    ctl.FontBold = True
    ctl.ForeColor = RGB(44, 82, 130)

    ' Von Label
    Set ctl = access.CreateControl(frmNameTemp, 100, 1, "", "", 200, 700, 500, 280)
    ctl.Caption = "Von:"

    ' Von Textbox
    Set ctl = access.CreateControl(frmNameTemp, 109, 1, "", "", 700, 700, 1500, 340)
    ctl.Name = "txtVon"
    ctl.DefaultValue = "=Date()"
    ctl.Format = "Short Date"

    ' Bis Label
    Set ctl = access.CreateControl(frmNameTemp, 100, 1, "", "", 2400, 700, 500, 280)
    ctl.Caption = "Bis:"

    ' Bis Textbox
    Set ctl = access.CreateControl(frmNameTemp, 109, 1, "", "", 2900, 700, 1500, 340)
    ctl.Name = "txtBis"
    ctl.DefaultValue = "=DateAdd('d',7,Date())"
    ctl.Format = "Short Date"

    ' Kunde Label
    Set ctl = access.CreateControl(frmNameTemp, 100, 1, "", "", 4700, 700, 700, 280)
    ctl.Caption = "Kunde:"

    ' Kunde Combobox
    Set ctl = access.CreateControl(frmNameTemp, 111, 1, "", "", 5400, 700, 3500, 340)
    ctl.Name = "cboKunde"
    ctl.RowSource = "SELECT kun_Id, kun_Firma FROM tbl_KD_Kundenstamm WHERE kun_IstAktiv=True ORDER BY kun_Firma"
    ctl.ColumnCount = 2
    ctl.ColumnWidths = "0;3500"
    ctl.BoundColumn = 1

    ' Filter Button
    Set ctl = access.CreateControl(frmNameTemp, 104, 1, "", "", 9100, 680, 2000, 380)
    ctl.Name = "cmdFilter"
    ctl.Caption = "Filter anwenden"
    ctl.OnClick = "=DP_Board_Filter_Anwenden([Form])"

    ' === DETAIL CONTROLS ===

    ' Board Unterformular (links)
    Set ctl = access.CreateControl(frmNameTemp, 112, 0, "", "", 200, 200, 11500, 6500)
    ctl.Name = "subBoard"
    ctl.SourceObject = "Form.frm_DP_Board_Objekt"

    ' MA-Liste Label
    Set ctl = access.CreateControl(frmNameTemp, 100, 0, "", "", 12000, 50, 7000, 340)
    ctl.Name = "lblMAListe"
    ctl.Caption = "Verfuegbare Mitarbeiter (Doppelklick = Zuordnen)"
    ctl.FontBold = True
    ctl.ForeColor = RGB(44, 82, 130)

    ' MA Unterformular (rechts)
    Set ctl = access.CreateControl(frmNameTemp, 112, 0, "", "", 12000, 400, 7000, 6300)
    ctl.Name = "subMA_Verfuegbar"
    ctl.SourceObject = "Form.frm_DP_MA_Verfuegbar"

    ' Speichern
    access.DoCmd.Save 2, , strName
    access.DoCmd.Close 2, strName, 1

    If Err.Number = 0 Then
        WScript.Echo "    [OK]"
    Else
        WScript.Echo "    [!] Save: " & Err.Description
        Err.Clear
    End If
End Sub

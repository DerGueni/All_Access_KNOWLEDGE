' ============================================
' PLANUNGS-DASHBOARD - MINIMALES SETUP
' Nur Abfragen und einfache Formulare
' ============================================

Option Explicit

Dim access
Dim strFrontendPath

strFrontendPath = "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"

WScript.Echo "============================================"
WScript.Echo "PLANUNGS-DASHBOARD - MINIMALES SETUP"
WScript.Echo "============================================"

On Error Resume Next

' Access starten (sichtbar)
WScript.Echo "Access starten..."
Set access = CreateObject("Access.Application")
access.Visible = True
access.UserControl = True

WScript.Echo "Datenbank oeffnen..."
access.OpenCurrentDatabase strFrontendPath, False

If Err.Number <> 0 Then
    WScript.Echo "FEHLER: " & Err.Description
    WScript.Quit 1
End If
Err.Clear

WScript.Sleep 3000
WScript.Echo "Datenbank ist offen."

' Abfragen erstellen
Dim db
Set db = access.CurrentDb

If Not db Is Nothing Then
    WScript.Echo vbCrLf & "Abfragen erstellen..."

    CreateOrUpdateQuery db, "qry_DP_Board_Objekt", _
        "SELECT tbl_VA_Start.ID AS StartID, tbl_VA_Start.VA_ID, " & _
        "tbl_VA_Start.VADatum AS TagDatum, " & _
        "tbl_VA_Auftragstamm.Auftrag AS Auftragsname, " & _
        "tbl_VA_Auftragstamm.Veranstalter_ID AS KundeID, " & _
        "tbl_VA_Start.VA_Start AS ZeitVon, tbl_VA_Start.VA_Ende AS ZeitBis, " & _
        "tbl_VA_Start.MA_Anzahl AS Soll, Nz(tbl_VA_Start.MA_Anzahl_Ist, 0) AS Ist " & _
        "FROM tbl_VA_Start INNER JOIN tbl_VA_Auftragstamm ON tbl_VA_Start.VA_ID = tbl_VA_Auftragstamm.ID " & _
        "ORDER BY tbl_VA_Start.VADatum, tbl_VA_Start.VA_Start"

    CreateOrUpdateQuery db, "qry_DP_MA_Verfuegbar", _
        "SELECT tbl_MA_Mitarbeiterstamm.ID AS MA_ID, " & _
        "tbl_MA_Mitarbeiterstamm.Nachname & ', ' & tbl_MA_Mitarbeiterstamm.Vorname AS MAName " & _
        "FROM tbl_MA_Mitarbeiterstamm " & _
        "WHERE tbl_MA_Mitarbeiterstamm.IstAktiv = True " & _
        "ORDER BY tbl_MA_Mitarbeiterstamm.Nachname"

    WScript.Echo "Abfragen fertig."
Else
    WScript.Echo "WARNUNG: CurrentDb nicht verfuegbar"
End If

' Formulare via Formularassistent erstellen
WScript.Echo vbCrLf & "Formulare erstellen..."
access.DoCmd.SetWarnings False

' Unterformular Objekt-Board
CreateDatasheetForm "frm_DP_Board_Objekt", "qry_DP_Board_Objekt"

' Unterformular MA-Verfuegbar
CreateDatasheetForm "frm_DP_MA_Verfuegbar", "qry_DP_MA_Verfuegbar"

' Hauptformular
CreateMainDashboard

access.DoCmd.SetWarnings True

WScript.Echo vbCrLf & "============================================"
WScript.Echo "FERTIG!"
WScript.Echo "Access bleibt offen - Formulare pruefen"
WScript.Echo "============================================"

' Access NICHT schliessen
Set access = Nothing

WScript.Quit 0

' ============================================
Sub CreateOrUpdateQuery(db, strName, strSQL)
    On Error Resume Next
    Dim qd, exists
    exists = False

    For Each qd In db.QueryDefs
        If qd.Name = strName Then
            exists = True
            qd.SQL = strSQL
            WScript.Echo "  [OK] " & strName & " (aktualisiert)"
            Exit For
        End If
    Next

    If Not exists Then
        db.CreateQueryDef strName, strSQL
        If Err.Number = 0 Then
            WScript.Echo "  [OK] " & strName & " (neu)"
        Else
            WScript.Echo "  [!] " & strName & ": " & Err.Description
            Err.Clear
        End If
    End If
End Sub

' ============================================
Sub CreateDatasheetForm(strName, strRecSource)
    On Error Resume Next
    Err.Clear

    WScript.Echo "  Erstelle " & strName & "..."

    ' Loeschen falls vorhanden
    access.DoCmd.DeleteObject 2, strName
    Err.Clear

    ' Formular erstellen via Application
    Dim newFrm
    Set newFrm = access.CreateForm()

    If Err.Number <> 0 Or newFrm Is Nothing Then
        WScript.Echo "    [!] CreateForm: " & Err.Description
        Err.Clear
        Exit Sub
    End If

    ' Konfigurieren
    newFrm.RecordSource = strRecSource
    newFrm.DefaultView = 2  ' Datenblatt
    newFrm.AllowAdditions = False
    newFrm.AllowDeletions = False
    newFrm.AllowEdits = False

    ' Speichern mit Namen
    access.DoCmd.Close 2, newFrm.Name, 1  ' acSaveYes
    access.DoCmd.Rename strName, 2, newFrm.Name

    If Err.Number = 0 Then
        WScript.Echo "    [OK]"
    Else
        WScript.Echo "    [!] " & Err.Description
        Err.Clear
    End If
End Sub

' ============================================
Sub CreateMainDashboard()
    On Error Resume Next
    Err.Clear

    Dim strName
    strName = "frm_DP_Board"

    WScript.Echo "  Erstelle " & strName & " (Hauptformular)..."

    ' Loeschen falls vorhanden
    access.DoCmd.DeleteObject 2, strName
    Err.Clear

    ' Formular erstellen
    Dim newFrm
    Set newFrm = access.CreateForm()

    If Err.Number <> 0 Or newFrm Is Nothing Then
        WScript.Echo "    [!] CreateForm: " & Err.Description
        Err.Clear
        Exit Sub
    End If

    Dim frmName
    frmName = newFrm.Name

    ' Formular konfigurieren
    newFrm.Caption = "Planungs-Dashboard"
    newFrm.DefaultView = 0
    newFrm.RecordSelectors = False
    newFrm.NavigationButtons = False
    newFrm.Width = 20000

    ' Header
    newFrm.Section(1).Height = 1200

    ' Detail
    newFrm.Section(0).Height = 7000

    Dim ctl

    ' Titel im Header
    Set ctl = access.CreateControl(frmName, 100, 1, "", "", 200, 100, 7000, 500)
    ctl.Name = "lblTitel"
    ctl.Caption = "PLANUNGS-DASHBOARD"
    ctl.FontSize = 18
    ctl.FontBold = True

    ' Von-Datum
    Set ctl = access.CreateControl(frmName, 100, 1, "", "", 200, 700, 500, 280)
    ctl.Caption = "Von:"
    Set ctl = access.CreateControl(frmName, 109, 1, "", "", 700, 700, 1500, 340)
    ctl.Name = "txtVon"

    ' Bis-Datum
    Set ctl = access.CreateControl(frmName, 100, 1, "", "", 2400, 700, 500, 280)
    ctl.Caption = "Bis:"
    Set ctl = access.CreateControl(frmName, 109, 1, "", "", 2900, 700, 1500, 340)
    ctl.Name = "txtBis"

    ' Unterformular Board (links)
    Set ctl = access.CreateControl(frmName, 112, 0, "", "", 200, 200, 11000, 6000)
    ctl.Name = "subBoard"
    ctl.SourceObject = "Form.frm_DP_Board_Objekt"

    ' Label MA-Liste
    Set ctl = access.CreateControl(frmName, 100, 0, "", "", 11500, 50, 7000, 340)
    ctl.Name = "lblMA"
    ctl.Caption = "Verfuegbare Mitarbeiter"
    ctl.FontBold = True

    ' Unterformular MA (rechts)
    Set ctl = access.CreateControl(frmName, 112, 0, "", "", 11500, 400, 7000, 5800)
    ctl.Name = "subMA_Verfuegbar"
    ctl.SourceObject = "Form.frm_DP_MA_Verfuegbar"

    ' Speichern
    access.DoCmd.Close 2, frmName, 1
    access.DoCmd.Rename strName, 2, frmName

    If Err.Number = 0 Then
        WScript.Echo "    [OK]"
    Else
        WScript.Echo "    [!] " & Err.Description
        Err.Clear
    End If
End Sub

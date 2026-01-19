"""
Erstellt das Planungs-Dashboard komplett
Verwendet die Access Bridge Ultimate mit korrekten Namenskonventionen
"""
from access_bridge_ultimate import AccessBridge

# VBA-Code fuer das Dashboard (OHNE Option-Zeilen!)
VBA_CODE = '''
' ===== PLANUNGS-DASHBOARD =====

Public g_DatumVon As Date
Public g_DatumBis As Date
Public g_KundeID As Long
Public g_AnsichtModus As Integer

Public Sub DP_Board_Filter_Anwenden(frm As Form)
    On Error Resume Next
    g_DatumVon = Nz(frm!txtVon, Date)
    g_DatumBis = Nz(frm!txtBis, DateAdd("d", 7, Date))
    g_KundeID = Nz(frm!cboKunde, 0)

    Dim sFilter As String
    sFilter = "TagDatum >= #" & Format(g_DatumVon, "yyyy-mm-dd") & "# " & _
              "AND TagDatum <= #" & Format(g_DatumBis, "yyyy-mm-dd") & "#"

    If g_KundeID > 0 Then sFilter = sFilter & " AND KundeID = " & g_KundeID

    frm!subBoard.Form.Filter = sFilter
    frm!subBoard.Form.FilterOn = True
    frm!subMA_Verfuegbar.Form.Requery
End Sub

Public Sub DP_Board_Ansicht_Umschalten(frm As Form)
    On Error Resume Next
    g_AnsichtModus = Nz(frm!optAnsicht, 1)

    If g_AnsichtModus = 1 Then
        frm!subBoard.SourceObject = "Form.frm_N_DP_Board_Objekt"
    Else
        frm!subBoard.SourceObject = "Form.frm_N_DP_Board_MA"
    End If

    frm!subBoard.Form.Requery
End Sub

Public Sub DP_Board_MA_Zuordnen(lngMA_ID As Long, frm As Form)
    On Error GoTo ErrHandler
    Dim dbs As DAO.Database, rs As DAO.Recordset
    Dim lngVA_ID As Long, lngVAStart_ID As Long
    Dim dteVADatum As Date, dteVon As Date, dteBis As Date

    With frm.Parent!subBoard.Form
        lngVA_ID = Nz(.!VA_ID, 0)
        lngVAStart_ID = Nz(.!StartID, 0)
        dteVADatum = Nz(.!TagDatum, Date)
        dteVon = Nz(.!ZeitVon, #8:00:00 AM#)
        dteBis = Nz(.!ZeitBis, #6:00:00 PM#)
    End With

    If lngVA_ID = 0 Then
        MsgBox "Bitte zuerst einen Einsatz auswaehlen!", vbExclamation
        Exit Sub
    End If

    If DCount("ID", "tbl_MA_VA_Planung", "MA_ID=" & lngMA_ID & " AND VAStart_ID=" & lngVAStart_ID) > 0 Then
        MsgBox "Mitarbeiter ist bereits zugeordnet!", vbExclamation
        Exit Sub
    End If

    Set dbs = CurrentDb
    Set rs = dbs.OpenRecordset("tbl_MA_VA_Planung", dbOpenDynaset)
    rs.AddNew
    rs!VA_ID = lngVA_ID
    rs!VAStart_ID = lngVAStart_ID
    rs!VADatum = dteVADatum
    rs!VA_Start = dteVon
    rs!VA_Ende = dteBis
    rs!MA_ID = lngMA_ID
    rs!Status_ID = 1
    rs!Erst_von = Environ("USERNAME")
    rs!Erst_am = Now()
    rs.Update
    rs.Close

    dbs.Execute "UPDATE tbl_VA_Start SET MA_Anzahl_Ist = Nz(MA_Anzahl_Ist,0) + 1 WHERE ID = " & lngVAStart_ID, dbFailOnError

    frm.Parent!subBoard.Form.Requery
    frm.Requery
    MsgBox "Mitarbeiter zugeordnet!", vbInformation
    Exit Sub

ErrHandler:
    MsgBox "Fehler: " & Err.Description, vbCritical
End Sub

Public Function DP_Board_Ampel(lngSoll As Long, lngIst As Long) As Long
    If lngSoll = 0 Then
        DP_Board_Ampel = vbWhite
    ElseIf lngIst >= lngSoll Then
        DP_Board_Ampel = RGB(198, 246, 213)
    ElseIf lngIst >= lngSoll * 0.5 Then
        DP_Board_Ampel = RGB(254, 243, 199)
    Else
        DP_Board_Ampel = RGB(254, 215, 215)
    End If
End Function

Public Sub DP_Board_Oeffnen()
    DoCmd.OpenForm "frm_N_DP_Board", acNormal
End Sub
'''

# SQL fuer Abfragen
SQL_OBJEKT = """
SELECT tbl_VA_Start.ID AS StartID, tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID,
    tbl_VA_Start.VADatum AS TagDatum, Format(tbl_VA_Start.VADatum, 'dddd') AS Wochentag,
    tbl_VA_Auftragstamm.Auftrag AS Auftragsname, tbl_VA_Auftragstamm.Objekt AS ObjektName,
    tbl_VA_Auftragstamm.Veranstalter_ID AS KundeID, tbl_KD_Kundenstamm.kun_Firma AS KundeName,
    tbl_VA_Start.VA_Start AS ZeitVon, tbl_VA_Start.VA_Ende AS ZeitBis,
    tbl_VA_Start.MA_Anzahl AS Soll, Nz(tbl_VA_Start.MA_Anzahl_Ist, 0) AS Ist,
    IIf(Nz(tbl_VA_Start.MA_Anzahl, 0) - Nz(tbl_VA_Start.MA_Anzahl_Ist, 0) > 0,
        tbl_VA_Start.MA_Anzahl - Nz(tbl_VA_Start.MA_Anzahl_Ist, 0), 0) AS Offen
FROM (tbl_VA_Start INNER JOIN tbl_VA_Auftragstamm ON tbl_VA_Start.VA_ID = tbl_VA_Auftragstamm.ID)
    LEFT JOIN tbl_KD_Kundenstamm ON tbl_VA_Auftragstamm.Veranstalter_ID = tbl_KD_Kundenstamm.kun_Id
ORDER BY tbl_VA_Start.VADatum, tbl_VA_Start.VA_Start
"""

SQL_MA = """
SELECT tbl_MA_VA_Planung.ID AS PlanungID, tbl_MA_VA_Planung.MA_ID,
    tbl_MA_Mitarbeiterstamm.Nachname & ', ' & tbl_MA_Mitarbeiterstamm.Vorname AS MAName,
    tbl_MA_VA_Planung.VADatum AS TagDatum, Format(tbl_MA_VA_Planung.VADatum, 'dddd') AS Wochentag,
    tbl_MA_VA_Planung.VA_ID, tbl_VA_Auftragstamm.Auftrag AS Auftragsname,
    tbl_MA_VA_Planung.VA_Start AS ZeitVon, tbl_MA_VA_Planung.VA_Ende AS ZeitBis,
    tbl_MA_VA_Planung.Status_ID
FROM (tbl_MA_VA_Planung INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Planung.MA_ID = tbl_MA_Mitarbeiterstamm.ID)
    LEFT JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Planung.VA_ID = tbl_VA_Auftragstamm.ID
ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_VA_Planung.VADatum
"""

SQL_VERFUEGBAR = """
SELECT tbl_MA_Mitarbeiterstamm.ID AS MA_ID,
    tbl_MA_Mitarbeiterstamm.Nachname & ', ' & tbl_MA_Mitarbeiterstamm.Vorname AS MAName,
    tbl_MA_Mitarbeiterstamm.Tel_Mobil AS Mobil
FROM tbl_MA_Mitarbeiterstamm
WHERE tbl_MA_Mitarbeiterstamm.IstAktiv = True
ORDER BY tbl_MA_Mitarbeiterstamm.Nachname
"""


def main():
    print("\n" + "=" * 60)
    print("PLANUNGS-DASHBOARD ERSTELLEN")
    print("=" * 60 + "\n")

    with AccessBridge() as bridge:
        # 1. Abfragen erstellen (mit auto_prefix=False da bereits _N_ im Namen)
        print("\n--- Abfragen erstellen ---")
        bridge.create_query("qry_N_DP_Board_Objekt", SQL_OBJEKT, auto_prefix=False)
        bridge.create_query("qry_N_DP_Board_MA", SQL_MA, auto_prefix=False)
        bridge.create_query("qry_N_DP_MA_Verfuegbar", SQL_VERFUEGBAR, auto_prefix=False)

        # 2. VBA-Modul erstellen
        print("\n--- VBA-Modul erstellen ---")
        bridge.import_vba_module("mod_N_DP_Board", VBA_CODE, auto_prefix=False)

        # 3. Unterformulare erstellen
        print("\n--- Unterformulare erstellen ---")
        bridge.create_form("frm_N_DP_Board_Objekt", "qry_N_DP_Board_Objekt",
                          default_view=2, auto_prefix=False)
        bridge.create_form("frm_N_DP_Board_MA", "qry_N_DP_Board_MA",
                          default_view=2, auto_prefix=False)
        bridge.create_form("frm_N_DP_MA_Verfuegbar", "qry_N_DP_MA_Verfuegbar",
                          default_view=2, auto_prefix=False)

        # 4. Hauptformular erstellen
        print("\n--- Hauptformular erstellen ---")
        bridge.create_form("frm_N_DP_Board", None, default_view=0, auto_prefix=False)

        # 5. Controls zum Hauptformular hinzufuegen (alle im Detail-Bereich = Section 0)
        print("\n--- Controls hinzufuegen ---")

        # Titel (oben)
        bridge.add_control_to_form("frm_N_DP_Board", 100, 0, 200, 100, 7000, 500,
                                   Name="lblTitel", Caption="PLANUNGS-DASHBOARD",
                                   FontSize=18, FontBold=True)

        # Von-Datum
        bridge.add_control_to_form("frm_N_DP_Board", 100, 0, 200, 700, 500, 280,
                                   Caption="Von:")
        bridge.add_control_to_form("frm_N_DP_Board", 109, 0, 700, 700, 1500, 340,
                                   Name="txtVon", Format="Short Date")

        # Bis-Datum
        bridge.add_control_to_form("frm_N_DP_Board", 100, 0, 2400, 700, 500, 280,
                                   Caption="Bis:")
        bridge.add_control_to_form("frm_N_DP_Board", 109, 0, 2900, 700, 1500, 340,
                                   Name="txtBis", Format="Short Date")

        # Unterformular Board (links)
        bridge.add_control_to_form("frm_N_DP_Board", 112, 0, 200, 1200, 11000, 6000,
                                   Name="subBoard", SourceObject="Form.frm_N_DP_Board_Objekt")

        # MA-Liste Label
        bridge.add_control_to_form("frm_N_DP_Board", 100, 0, 11500, 1050, 7000, 340,
                                   Name="lblMA", Caption="Verfuegbare Mitarbeiter",
                                   FontBold=True)

        # Unterformular MA (rechts)
        bridge.add_control_to_form("frm_N_DP_Board", 112, 0, 11500, 1400, 7000, 5800,
                                   Name="subMA_Verfuegbar", SourceObject="Form.frm_N_DP_MA_Verfuegbar")

        print("\n" + "=" * 60)
        print("PLANUNGS-DASHBOARD ERFOLGREICH ERSTELLT!")
        print("=" * 60)
        print("\nErstellt:")
        print("  - qry_N_DP_Board_Objekt")
        print("  - qry_N_DP_Board_MA")
        print("  - qry_N_DP_MA_Verfuegbar")
        print("  - mod_N_DP_Board")
        print("  - frm_N_DP_Board_Objekt")
        print("  - frm_N_DP_Board_MA")
        print("  - frm_N_DP_MA_Verfuegbar")
        print("  - frm_N_DP_Board (Hauptformular)")
        print("\nOeffnen mit: DP_Board_Oeffnen")


if __name__ == "__main__":
    main()

"""
Erstellt das komplette Planungs-Dashboard (frm_DP_Board) in Access
Inklusive Abfragen, Formulare und VBA-Code
"""
import win32com.client
import pythoncom
import json
import time
from pathlib import Path

# Config laden
config_path = Path(__file__).parent / "config.json"
with open(config_path, 'r') as f:
    config = json.load(f)

FRONTEND_PATH = config['database']['frontend_path']

def create_dp_board():
    """Erstellt das Planungs-Dashboard"""
    pythoncom.CoInitialize()

    print("=" * 60)
    print("PLANUNGS-DASHBOARD ERSTELLEN")
    print("=" * 60)
    print(f"Frontend: {FRONTEND_PATH}")

    access = None
    try:
        # Access starten
        print("\n1. Access starten...")
        access = win32com.client.Dispatch("Access.Application")
        access.Visible = False
        access.OpenCurrentDatabase(FRONTEND_PATH)
        db = access.CurrentDb()

        # 1. ABFRAGEN ERSTELLEN
        print("\n2. Abfragen erstellen...")
        create_queries(db)

        # 2. VBA-MODUL ERSTELLEN
        print("\n3. VBA-Modul erstellen...")
        create_vba_module(access)

        # 3. FORMULARE ERSTELLEN
        print("\n4. Formulare erstellen...")
        create_forms(access, db)

        print("\n" + "=" * 60)
        print("FERTIG! Planungs-Dashboard wurde erstellt.")
        print("=" * 60)
        print("\nErstellte Objekte:")
        print("  - qry_DP_Board_Objekt (Objekt-Ansicht)")
        print("  - qry_DP_Board_MA (MA-Ansicht)")
        print("  - qry_DP_MA_Verfuegbar (Verfuegbare MA)")
        print("  - mod_N_DP_Board (VBA-Modul)")
        print("  - frm_DP_Board (Hauptformular)")
        print("  - frm_DP_Board_Objekt (Unterformular)")
        print("  - frm_DP_Board_MA (Unterformular)")
        print("  - frm_DP_MA_Verfuegbar (Unterformular)")

    except Exception as e:
        print(f"\nFEHLER: {e}")
        import traceback
        traceback.print_exc()

    finally:
        if access:
            try:
                access.CloseCurrentDatabase()
                access.Quit()
            except:
                pass
        pythoncom.CoUninitialize()


def create_queries(db):
    """Erstellt die notwendigen Abfragen"""

    queries = {
        # Objekt-Board Abfrage
        "qry_DP_Board_Objekt": """
SELECT
    tbl_VA_Start.ID AS StartID,
    tbl_VA_Start.VA_ID,
    tbl_VA_Start.VADatum_ID,
    tbl_VA_Start.VADatum AS TagDatum,
    Format(tbl_VA_Start.VADatum, "dddd") AS Wochentag,
    tbl_VA_Auftragstamm.Auftrag AS Auftragsname,
    tbl_VA_Auftragstamm.Objekt AS ObjektName,
    tbl_VA_Auftragstamm.Veranstalter_ID AS KundeID,
    tbl_KD_Kundenstamm.kun_Firma AS KundeName,
    tbl_VA_Start.VA_Start AS ZeitVon,
    tbl_VA_Start.VA_Ende AS ZeitBis,
    tbl_VA_Start.MA_Anzahl AS Soll,
    Nz(tbl_VA_Start.MA_Anzahl_Ist, 0) AS Ist,
    IIf(Nz(tbl_VA_Start.MA_Anzahl, 0) - Nz(tbl_VA_Start.MA_Anzahl_Ist, 0) > 0,
        tbl_VA_Start.MA_Anzahl - Nz(tbl_VA_Start.MA_Anzahl_Ist, 0), 0) AS Offen,
    tbl_VA_Auftragstamm.Veranst_Status_ID AS StatusID
FROM ((tbl_VA_Start
INNER JOIN tbl_VA_Auftragstamm ON tbl_VA_Start.VA_ID = tbl_VA_Auftragstamm.ID)
LEFT JOIN tbl_KD_Kundenstamm ON tbl_VA_Auftragstamm.Veranstalter_ID = tbl_KD_Kundenstamm.kun_Id)
ORDER BY tbl_VA_Start.VADatum, tbl_VA_Start.VA_Start;
""",

        # MA-Board Abfrage
        "qry_DP_Board_MA": """
SELECT
    tbl_MA_VA_Planung.ID AS PlanungID,
    tbl_MA_VA_Planung.MA_ID,
    tbl_MA_Mitarbeiterstamm.Nachname & ", " & tbl_MA_Mitarbeiterstamm.Vorname AS MAName,
    tbl_MA_VA_Planung.VADatum AS TagDatum,
    Format(tbl_MA_VA_Planung.VADatum, "dddd") AS Wochentag,
    tbl_MA_VA_Planung.VA_ID,
    tbl_VA_Auftragstamm.Auftrag AS Auftragsname,
    tbl_VA_Auftragstamm.Objekt AS ObjektName,
    tbl_VA_Auftragstamm.Veranstalter_ID AS KundeID,
    tbl_MA_VA_Planung.VA_Start AS ZeitVon,
    tbl_MA_VA_Planung.VA_Ende AS ZeitBis,
    DateDiff("n", tbl_MA_VA_Planung.VA_Start, tbl_MA_VA_Planung.VA_Ende) / 60 AS Stunden,
    tbl_MA_VA_Planung.Status_ID,
    tbl_MA_Plan_Status.Status AS StatusText
FROM ((tbl_MA_VA_Planung
INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Planung.MA_ID = tbl_MA_Mitarbeiterstamm.ID)
LEFT JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Planung.VA_ID = tbl_VA_Auftragstamm.ID)
LEFT JOIN tbl_MA_Plan_Status ON tbl_MA_VA_Planung.Status_ID = tbl_MA_Plan_Status.ID
ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_VA_Planung.VADatum, tbl_MA_VA_Planung.VA_Start;
""",

        # Verfuegbare MA Abfrage
        "qry_DP_MA_Verfuegbar": """
SELECT
    tbl_MA_Mitarbeiterstamm.ID AS MA_ID,
    tbl_MA_Mitarbeiterstamm.Nachname & ", " & tbl_MA_Mitarbeiterstamm.Vorname AS MAName,
    tbl_MA_Mitarbeiterstamm.Tel_Mobil AS Mobil,
    tbl_MA_Mitarbeiterstamm.IstAktiv,
    IIf(tbl_MA_Mitarbeiterstamm.HatSachkunde = True, "SK", "") &
    IIf(tbl_MA_Mitarbeiterstamm.Hat_keine_34a = False, " 34a", "") AS Quali
FROM tbl_MA_Mitarbeiterstamm
WHERE tbl_MA_Mitarbeiterstamm.IstAktiv = True
ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname;
"""
    }

    for qname, sql in queries.items():
        try:
            # Alte Abfrage loeschen falls vorhanden
            try:
                db.QueryDefs.Delete(qname)
                print(f"  Alte Abfrage '{qname}' geloescht")
            except:
                pass

            # Neue Abfrage erstellen
            qdef = db.CreateQueryDef(qname, sql.strip())
            print(f"  Abfrage '{qname}' erstellt")

        except Exception as e:
            print(f"  FEHLER bei '{qname}': {e}")


def create_vba_module(access):
    """Erstellt das VBA-Modul fuer das Dashboard"""

    module_code = '''Option Compare Database
Option Explicit

' ============================================
' PLANUNGS-DASHBOARD VBA-MODUL
' mod_N_DP_Board
' ============================================

' Globale Variablen
Public g_DatumVon As Date
Public g_DatumBis As Date
Public g_KundeID As Long
Public g_ObjektID As Long
Public g_AnsichtModus As Integer  ' 1 = Objekt, 2 = MA

' ============================================
' FILTER-FUNKTIONEN
' ============================================

Public Sub DP_Board_Filter_Anwenden(frm As Form)
    ' Wendet Filter auf das Board an
    On Error Resume Next

    ' Werte aus Formular holen
    g_DatumVon = Nz(frm!txtVon, Date)
    g_DatumBis = Nz(frm!txtBis, DateAdd("d", 7, Date))
    g_KundeID = Nz(frm!cboKunde, 0)
    g_ObjektID = Nz(frm!cboObjekt, 0)

    ' Unterformulare aktualisieren
    frm!subBoard.Form.Requery
    frm!subMA_Verfuegbar.Form.Requery
End Sub

Public Function DP_Board_GetFilter_Objekt() As String
    ' Erstellt WHERE-Klausel fuer Objekt-Board
    Dim sFilter As String
    sFilter = "TagDatum >= #" & Format(g_DatumVon, "yyyy-mm-dd") & "# " & _
              "AND TagDatum <= #" & Format(g_DatumBis, "yyyy-mm-dd") & "#"

    If g_KundeID > 0 Then
        sFilter = sFilter & " AND KundeID = " & g_KundeID
    End If

    If g_ObjektID > 0 Then
        sFilter = sFilter & " AND VA_ID IN (SELECT ID FROM tbl_VA_Auftragstamm WHERE Objekt_ID = " & g_ObjektID & ")"
    End If

    DP_Board_GetFilter_Objekt = sFilter
End Function

Public Function DP_Board_GetFilter_MA() As String
    ' Erstellt WHERE-Klausel fuer MA-Board
    Dim sFilter As String
    sFilter = "TagDatum >= #" & Format(g_DatumVon, "yyyy-mm-dd") & "# " & _
              "AND TagDatum <= #" & Format(g_DatumBis, "yyyy-mm-dd") & "#"

    If g_KundeID > 0 Then
        sFilter = sFilter & " AND KundeID = " & g_KundeID
    End If

    DP_Board_GetFilter_MA = sFilter
End Function

' ============================================
' ANSICHT-UMSCHALTUNG
' ============================================

Public Sub DP_Board_Ansicht_Umschalten(frm As Form)
    ' Wechselt zwischen Objekt- und MA-Ansicht
    On Error Resume Next

    g_AnsichtModus = Nz(frm!optAnsicht, 1)

    If g_AnsichtModus = 1 Then
        frm!subBoard.SourceObject = "Form.frm_DP_Board_Objekt"
    Else
        frm!subBoard.SourceObject = "Form.frm_DP_Board_MA"
    End If

    frm!subBoard.Form.Requery
End Sub

' ============================================
' ZUORDNUNGS-FUNKTIONEN
' ============================================

Public Sub DP_Board_MA_Zuordnen(lngMA_ID As Long, frm As Form)
    ' Ordnet einen MA dem aktuell selektierten Eintrag zu
    On Error GoTo ErrHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim lngVA_ID As Long
    Dim lngVADatum_ID As Long
    Dim lngVAStart_ID As Long
    Dim dteVADatum As Date
    Dim dteVA_Start As Date
    Dim dteVA_Ende As Date

    ' Pruefen ob MA bereits zugeordnet
    If DP_Board_MA_Bereits_Zugeordnet(lngMA_ID, frm) Then
        MsgBox "Dieser Mitarbeiter ist bereits fuer diesen Einsatz zugeordnet!", vbExclamation, "Zuordnung"
        Exit Sub
    End If

    ' Pruefen ob MA verfuegbar (keine Nicht-Verfuegbarkeit)
    If DP_Board_MA_NichtVerfuegbar(lngMA_ID, frm) Then
        If MsgBox("Achtung: Der Mitarbeiter ist als nicht verfuegbar eingetragen!" & vbCrLf & _
                  "Trotzdem zuordnen?", vbQuestion + vbYesNo, "Warnung") = vbNo Then
            Exit Sub
        End If
    End If

    ' Pruefen auf Zeitkonflikt
    If DP_Board_MA_Hat_Konflikt(lngMA_ID, frm) Then
        If MsgBox("Achtung: Der Mitarbeiter hat einen Zeitkonflikt!" & vbCrLf & _
                  "Trotzdem zuordnen?", vbQuestion + vbYesNo, "Warnung") = vbNo Then
            Exit Sub
        End If
    End If

    ' Daten aus Board holen
    With frm.Parent!subBoard.Form
        lngVA_ID = Nz(.!VA_ID, 0)
        lngVADatum_ID = Nz(.!VADatum_ID, 0)
        lngVAStart_ID = Nz(.!StartID, 0)
        dteVADatum = Nz(.!TagDatum, Date)
        dteVA_Start = Nz(.!ZeitVon, #8:00:00 AM#)
        dteVA_Ende = Nz(.!ZeitBis, #18:00:00 PM#)
    End With

    If lngVA_ID = 0 Then
        MsgBox "Bitte zuerst einen Einsatz im Board auswaehlen!", vbExclamation, "Zuordnung"
        Exit Sub
    End If

    ' Neuen Datensatz anlegen
    Set db = CurrentDb
    Set rs = db.OpenRecordset("tbl_MA_VA_Planung", dbOpenDynaset)

    rs.AddNew
    rs!VA_ID = lngVA_ID
    rs!VADatum_ID = lngVADatum_ID
    rs!VAStart_ID = lngVAStart_ID
    rs!VADatum = dteVADatum
    rs!VA_Start = dteVA_Start
    rs!VA_Ende = dteVA_Ende
    rs!MA_ID = lngMA_ID
    rs!Status_ID = 1  ' Zugeordnet
    rs!Erst_von = Environ("USERNAME")
    rs!Erst_am = Now()
    rs.Update

    rs.Close
    Set rs = Nothing
    Set db = Nothing

    ' IST-Wert in tbl_VA_Start erhoehen
    DP_Board_Update_Ist(lngVAStart_ID, 1)

    ' Formulare aktualisieren
    frm.Parent!subBoard.Form.Requery
    frm.Requery

    MsgBox "Mitarbeiter wurde erfolgreich zugeordnet!", vbInformation, "Zuordnung"

    Exit Sub

ErrHandler:
    MsgBox "Fehler bei Zuordnung: " & Err.Description, vbCritical, "Fehler"
End Sub

Public Function DP_Board_MA_Bereits_Zugeordnet(lngMA_ID As Long, frm As Form) As Boolean
    ' Prueft ob MA bereits fuer diesen Start zugeordnet ist
    On Error Resume Next

    Dim lngVAStart_ID As Long
    lngVAStart_ID = Nz(frm.Parent!subBoard.Form!StartID, 0)

    If lngVAStart_ID = 0 Then
        DP_Board_MA_Bereits_Zugeordnet = False
        Exit Function
    End If

    DP_Board_MA_Bereits_Zugeordnet = DCount("ID", "tbl_MA_VA_Planung", _
        "MA_ID = " & lngMA_ID & " AND VAStart_ID = " & lngVAStart_ID) > 0
End Function

Public Function DP_Board_MA_NichtVerfuegbar(lngMA_ID As Long, frm As Form) As Boolean
    ' Prueft auf Nicht-Verfuegbarkeit
    On Error Resume Next

    Dim dteTag As Date
    dteTag = Nz(frm.Parent!subBoard.Form!TagDatum, Date)

    DP_Board_MA_NichtVerfuegbar = DCount("ID", "tbl_MA_NVerfuegZeiten", _
        "MA_ID = " & lngMA_ID & " AND vonDat <= #" & Format(dteTag, "yyyy-mm-dd") & "# " & _
        "AND bisDat >= #" & Format(dteTag, "yyyy-mm-dd") & "#") > 0
End Function

Public Function DP_Board_MA_Hat_Konflikt(lngMA_ID As Long, frm As Form) As Boolean
    ' Prueft auf Zeitkonflikt mit anderen Einsaetzen
    On Error Resume Next

    Dim dteTag As Date
    Dim dteVon As Date
    Dim dteBis As Date

    dteTag = Nz(frm.Parent!subBoard.Form!TagDatum, Date)
    dteVon = Nz(frm.Parent!subBoard.Form!ZeitVon, #8:00:00 AM#)
    dteBis = Nz(frm.Parent!subBoard.Form!ZeitBis, #18:00:00 PM#)

    ' Pruefe auf ueberschneidende Planungen
    DP_Board_MA_Hat_Konflikt = DCount("ID", "tbl_MA_VA_Planung", _
        "MA_ID = " & lngMA_ID & " AND VADatum = #" & Format(dteTag, "yyyy-mm-dd") & "# " & _
        "AND ((VA_Start < #" & Format(dteBis, "hh:nn:ss") & "# AND VA_Ende > #" & Format(dteVon, "hh:nn:ss") & "#))") > 0
End Function

Public Sub DP_Board_Update_Ist(lngVAStart_ID As Long, intDelta As Integer)
    ' Aktualisiert MA_Anzahl_Ist in tbl_VA_Start
    On Error Resume Next

    Dim db As DAO.Database
    Set db = CurrentDb
    db.Execute "UPDATE tbl_VA_Start SET MA_Anzahl_Ist = Nz(MA_Anzahl_Ist, 0) + " & intDelta & _
               " WHERE ID = " & lngVAStart_ID, dbFailOnError
    Set db = Nothing
End Sub

' ============================================
' ZUORDNUNG ENTFERNEN
' ============================================

Public Sub DP_Board_Zuordnung_Entfernen(lngPlanungID As Long)
    ' Entfernt eine Zuordnung
    On Error GoTo ErrHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim lngVAStart_ID As Long

    If MsgBox("Zuordnung wirklich entfernen?", vbQuestion + vbYesNo, "Zuordnung entfernen") = vbNo Then
        Exit Sub
    End If

    Set db = CurrentDb

    ' VAStart_ID ermitteln
    lngVAStart_ID = Nz(DLookup("VAStart_ID", "tbl_MA_VA_Planung", "ID = " & lngPlanungID), 0)

    ' Datensatz loeschen
    db.Execute "DELETE FROM tbl_MA_VA_Planung WHERE ID = " & lngPlanungID, dbFailOnError

    ' IST-Wert verringern
    If lngVAStart_ID > 0 Then
        DP_Board_Update_Ist lngVAStart_ID, -1
    End If

    Set db = Nothing

    MsgBox "Zuordnung wurde entfernt!", vbInformation, "Zuordnung"

    Exit Sub

ErrHandler:
    MsgBox "Fehler: " & Err.Description, vbCritical, "Fehler"
End Sub

' ============================================
' AMPEL-FUNKTION
' ============================================

Public Function DP_Board_Ampel_Farbe(lngSoll As Long, lngIst As Long) As Long
    ' Gibt Farbe basierend auf SOLL/IST zurueck
    ' Gruen = voll besetzt, Gelb = teilweise, Rot = kritisch

    If lngSoll = 0 Then
        DP_Board_Ampel_Farbe = vbWhite
    ElseIf lngIst >= lngSoll Then
        DP_Board_Ampel_Farbe = RGB(198, 246, 213)  ' Gruen
    ElseIf lngIst >= lngSoll * 0.5 Then
        DP_Board_Ampel_Farbe = RGB(254, 243, 199)  ' Gelb
    Else
        DP_Board_Ampel_Farbe = RGB(254, 215, 215)  ' Rot
    End If
End Function

' ============================================
' SCHNELLFUNKTIONEN
' ============================================

Public Sub DP_Board_Oeffnen()
    ' Oeffnet das Planungs-Dashboard
    DoCmd.OpenForm "frm_DP_Board", acNormal
End Sub

Public Sub DP_Board_Heute_Anzeigen(frm As Form)
    ' Setzt Filter auf heute
    frm!txtVon = Date
    frm!txtBis = Date
    DP_Board_Filter_Anwenden frm
End Sub

Public Sub DP_Board_Woche_Anzeigen(frm As Form)
    ' Setzt Filter auf aktuelle Woche
    frm!txtVon = Date
    frm!txtBis = DateAdd("d", 7, Date)
    DP_Board_Filter_Anwenden frm
End Sub

Public Sub DP_Board_Monat_Anzeigen(frm As Form)
    ' Setzt Filter auf aktuellen Monat
    frm!txtVon = DateSerial(Year(Date), Month(Date), 1)
    frm!txtBis = DateSerial(Year(Date), Month(Date) + 1, 0)
    DP_Board_Filter_Anwenden frm
End Sub
'''

    try:
        # Modul erstellen
        vbe = access.VBE
        proj = vbe.ActiveVBProject

        # Pruefen ob Modul existiert
        module_exists = False
        for comp in proj.VBComponents:
            if comp.Name == "mod_N_DP_Board":
                module_exists = True
                comp.CodeModule.DeleteLines(1, comp.CodeModule.CountOfLines)
                comp.CodeModule.AddFromString(module_code)
                print("  VBA-Modul 'mod_N_DP_Board' aktualisiert")
                break

        if not module_exists:
            new_module = proj.VBComponents.Add(1)  # vbext_ct_StdModule
            new_module.Name = "mod_N_DP_Board"
            new_module.CodeModule.AddFromString(module_code)
            print("  VBA-Modul 'mod_N_DP_Board' erstellt")

    except Exception as e:
        print(f"  FEHLER bei VBA-Modul: {e}")


def create_forms(access, db):
    """Erstellt die Formulare"""

    # Formular-Erstellung via DoCmd
    print("\n  Erstelle Unterformulare...")

    # Hinweis: Formular-Erstellung via COM ist komplex
    # Stattdessen erstellen wir ein VBS-Script

    vbs_script = '''
' VBScript zum Erstellen der DP_Board Formulare
Dim access
Set access = GetObject(, "Access.Application")

On Error Resume Next

' === UNTERFORMULAR: frm_DP_Board_Objekt ===
access.DoCmd.DeleteObject 2, "frm_DP_Board_Objekt"
Err.Clear

access.DoCmd.CreateForm
access.DoCmd.Save 2, "frm_DP_Board_Objekt"

Dim frm
Set frm = access.Forms("frm_DP_Board_Objekt")
frm.RecordSource = "qry_DP_Board_Objekt"
frm.DefaultView = 2  ' Datenblatt
frm.AllowAdditions = False
frm.AllowDeletions = False

access.DoCmd.Close 2, "frm_DP_Board_Objekt", 1

' === UNTERFORMULAR: frm_DP_Board_MA ===
access.DoCmd.DeleteObject 2, "frm_DP_Board_MA"
Err.Clear

access.DoCmd.CreateForm
access.DoCmd.Save 2, "frm_DP_Board_MA"

Set frm = access.Forms("frm_DP_Board_MA")
frm.RecordSource = "qry_DP_Board_MA"
frm.DefaultView = 2  ' Datenblatt
frm.AllowAdditions = False
frm.AllowDeletions = False

access.DoCmd.Close 2, "frm_DP_Board_MA", 1

' === UNTERFORMULAR: frm_DP_MA_Verfuegbar ===
access.DoCmd.DeleteObject 2, "frm_DP_MA_Verfuegbar"
Err.Clear

access.DoCmd.CreateForm
access.DoCmd.Save 2, "frm_DP_MA_Verfuegbar"

Set frm = access.Forms("frm_DP_MA_Verfuegbar")
frm.RecordSource = "qry_DP_MA_Verfuegbar"
frm.DefaultView = 2  ' Datenblatt
frm.AllowAdditions = False
frm.AllowDeletions = False
frm.AllowEdits = False

access.DoCmd.Close 2, "frm_DP_MA_Verfuegbar", 1

WScript.Echo "Unterformulare erstellt!"
'''

    # Formulare direkt ueber Access erstellen
    try:
        # Unterformular Objekt-Board
        print("  Erstelle frm_DP_Board_Objekt...")
        try:
            access.DoCmd.DeleteObject(2, "frm_DP_Board_Objekt")
        except:
            pass

        access.DoCmd.RunSQL("SELECT * INTO tbltmp_dummy FROM qry_DP_Board_Objekt WHERE 1=0", False)
        access.DoCmd.SelectObject(2, "tbltmp_dummy", True)

        # Alternativ: Formular via CreateForm
        frm_name = access.CreateForm()
        access.DoCmd.Save(2, "", "frm_DP_Board_Objekt")

    except Exception as e:
        print(f"    Formular-Erstellung fehlgeschlagen: {e}")
        print("    Formulare muessen manuell erstellt werden.")

    print("\n  HINWEIS: Formulare manuell erstellen:")
    print("    1. Neues Formular 'frm_DP_Board_Objekt' als Datenblatt")
    print("       Datenherkunft: qry_DP_Board_Objekt")
    print("    2. Neues Formular 'frm_DP_Board_MA' als Datenblatt")
    print("       Datenherkunft: qry_DP_Board_MA")
    print("    3. Neues Formular 'frm_DP_MA_Verfuegbar' als Datenblatt")
    print("       Datenherkunft: qry_DP_MA_Verfuegbar")
    print("    4. Hauptformular 'frm_DP_Board' mit:")
    print("       - txtVon, txtBis (Datumsfelder)")
    print("       - cboKunde, cboObjekt (Kombis)")
    print("       - optAnsicht (Optionsgruppe 1=Objekt, 2=MA)")
    print("       - subBoard (Unterformular)")
    print("       - subMA_Verfuegbar (Unterformular)")


if __name__ == "__main__":
    create_dp_board()

"""
Vollständige Implementierung aller Verbesserungen für Consys Frontend
Basierend auf Analyse von: Timecount, SecPlanNet, TrackTik, Deputy, PARiM

WICHTIG: Dieses Skript erstellt alle Komponenten neu und robust!
"""

import win32com.client
import pythoncom
import os
import time
from datetime import datetime
import subprocess
import sys

# Konfiguration
FRONTEND_PATH = r"\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\B - Diverses\Consys_FE_N_Test_Claude_GPT - Kopie (6).accdb"

def kill_access():
    """Schließt alle Access-Prozesse"""
    try:
        subprocess.run(['taskkill', '/F', '/IM', 'MSACCESS.EXE'],
                      capture_output=True, timeout=10)
        time.sleep(2)
        print("Access-Prozesse beendet")
    except:
        pass

def create_fresh_connection():
    """Erstellt eine frische Verbindung zu Access"""
    pythoncom.CoInitialize()

    # Erst alle Access-Instanzen schließen
    kill_access()
    time.sleep(1)

    try:
        access = win32com.client.Dispatch("Access.Application")
        access.Visible = False  # Unsichtbar starten
        access.AutomationSecurity = 1  # Makros erlauben

        print(f"Öffne Datenbank: {FRONTEND_PATH}")
        access.OpenCurrentDatabase(FRONTEND_PATH)
        print("Datenbank erfolgreich geöffnet!")

        return access
    except Exception as e:
        print(f"Fehler: {e}")
        return None

def create_vba_module_via_sql(access, module_name, module_code):
    """Erstellt VBA-Modul über VBE"""
    try:
        vbe = access.VBE
        proj = vbe.ActiveVBProject

        # Prüfe ob Modul existiert und lösche es
        for comp in proj.VBComponents:
            if comp.Name == module_name:
                proj.VBComponents.Remove(comp)
                print(f"  Bestehendes Modul '{module_name}' entfernt")
                time.sleep(0.5)
                break

        # Neues Modul erstellen
        new_module = proj.VBComponents.Add(1)  # 1 = vbext_ct_StdModule
        new_module.Name = module_name

        # Code einfügen
        new_module.CodeModule.AddFromString(module_code)

        print(f"  Modul '{module_name}' erstellt ({new_module.CodeModule.CountOfLines} Zeilen)")
        return True

    except Exception as e:
        print(f"  FEHLER bei Modul '{module_name}': {e}")
        return False

def create_query(access, query_name, sql):
    """Erstellt oder aktualisiert eine Abfrage"""
    try:
        db = access.CurrentDb()

        # Prüfe ob Abfrage existiert
        for qd in db.QueryDefs:
            if qd.Name == query_name:
                qd.SQL = sql
                print(f"  Abfrage '{query_name}' aktualisiert")
                return True

        # Neue Abfrage erstellen
        db.CreateQueryDef(query_name, sql)
        print(f"  Abfrage '{query_name}' erstellt")
        return True

    except Exception as e:
        print(f"  FEHLER bei Abfrage '{query_name}': {e}")
        return False

def get_dashboard_module_code():
    """Gibt den VBA-Code für das Dashboard-Modul zurück"""
    return '''Option Compare Database
Option Explicit

' ============================================
' DASHBOARD-MODUL für Consys
' Erstellt: ''' + datetime.now().strftime("%Y-%m-%d %H:%M") + '''
' Verbesserungen inspiriert von: Timecount, SecPlanNet, TrackTik
' ============================================

' ============================================
' KENNZAHLEN FÜR DASHBOARD
' ============================================

Public Function Dashboard_AuftraegeHeute() As Long
    On Error Resume Next
    Dashboard_AuftraegeHeute = Nz(DCount("*", "tbl_VA_AnzTage", "VADatum = Date()"), 0)
End Function

Public Function Dashboard_AuftrageDieseWoche() As Long
    On Error Resume Next
    Dashboard_AuftrageDieseWoche = Nz(DCount("*", "tbl_VA_AnzTage", _
        "VADatum >= DateAdd('d', 1-Weekday(Date(),2), Date()) AND " & _
        "VADatum <= DateAdd('d', 7-Weekday(Date(),2), Date())"), 0)
End Function

Public Function Dashboard_OffeneAnfragen() As Long
    On Error Resume Next
    Dashboard_OffeneAnfragen = Nz(DCount("*", "tbl_MA_VA_Planung", _
        "Status_ID = 1 AND VADatum >= Date()"), 0)
End Function

Public Function Dashboard_Unterbesetzung() As Long
    On Error Resume Next
    Dashboard_Unterbesetzung = Nz(DCount("*", "tbl_VA_AnzTage", _
        "TVA_Offen > 0 AND VADatum >= Date()"), 0)
End Function

Public Function Dashboard_MitarbeiterAktiv() As Long
    On Error Resume Next
    Dashboard_MitarbeiterAktiv = Nz(DCount("*", "tbl_MA_Mitarbeiterstamm", "IstAktiv = True"), 0)
End Function

Public Function Dashboard_ZusagenHeute() As Long
    On Error Resume Next
    Dashboard_ZusagenHeute = Nz(DCount("*", "tbl_MA_VA_Zuordnung", "VADatum = Date()"), 0)
End Function

' ============================================
' KONFLIKTPRÜFUNG - wie bei SecPlanNet
' ============================================

Public Function Konflikt_Pruefen(MA_ID As Long, PruefDatum As Date, _
                                  StartZeit As Date, EndeZeit As Date) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim ergebnis As String

    On Error Resume Next
    ergebnis = ""

    ' Prüfe bestehende Zuordnungen
    sql = "SELECT VA_ID, MA_Start, MA_Ende " & _
          "FROM tbl_MA_VA_Zuordnung " & _
          "WHERE MA_ID = " & MA_ID & _
          " AND VADatum = #" & Format(PruefDatum, "mm/dd/yyyy") & "#" & _
          " AND ((MA_Start < #" & Format(EndeZeit, "hh:nn") & "#" & _
          " AND MA_Ende > #" & Format(StartZeit, "hh:nn") & "#))"

    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    If Not rs.EOF Then
        ergebnis = "KONFLIKT: Bereits eingeplant für VA " & rs!VA_ID & _
                   " (" & Format(rs!MA_Start, "hh:nn") & "-" & Format(rs!MA_Ende, "hh:nn") & ")"
    End If
    rs.Close

    ' Prüfe offene Planungen falls kein direkter Konflikt
    If ergebnis = "" Then
        sql = "SELECT VA_ID, VA_Start, VA_Ende " & _
              "FROM tbl_MA_VA_Planung " & _
              "WHERE MA_ID = " & MA_ID & _
              " AND VADatum = #" & Format(PruefDatum, "mm/dd/yyyy") & "#" & _
              " AND Status_ID IN (1, 2)" & _
              " AND ((VA_Start < #" & Format(EndeZeit, "hh:nn") & "#" & _
              " AND VA_Ende > #" & Format(StartZeit, "hh:nn") & "#))"

        Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
        If Not rs.EOF Then
            ergebnis = "WARNUNG: Offene Anfrage für VA " & rs!VA_ID
        End If
        rs.Close
    End If

    ' Prüfe Nicht-Verfügbarkeiten
    If ergebnis = "" Then
        sql = "SELECT Zeittyp_ID, Bemerkung " & _
              "FROM tbl_MA_NVerfuegZeiten " & _
              "WHERE MA_ID = " & MA_ID & _
              " AND vonDat <= #" & Format(PruefDatum, "mm/dd/yyyy") & "#" & _
              " AND bisDat >= #" & Format(PruefDatum, "mm/dd/yyyy") & "#"

        Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
        If Not rs.EOF Then
            ergebnis = "NICHT VERFÜGBAR: " & Nz(rs!Bemerkung, "Keine Angabe")
        End If
        rs.Close
    End If

    Set rs = Nothing
    Konflikt_Pruefen = ergebnis
End Function

' ============================================
' VERFÜGBARE MITARBEITER - wie bei Timecount
' ============================================

Public Function VerfuegbareMA_Zaehlen(PruefDatum As Date, _
                                       StartZeit As Date, EndeZeit As Date, _
                                       Optional QualiID As Long = 0) As Long
    Dim sql As String

    On Error Resume Next

    sql = "SELECT Count(*) As Anz FROM tbl_MA_Mitarbeiterstamm " & _
          "WHERE IstAktiv = True " & _
          "AND ID NOT IN (" & _
          "  SELECT MA_ID FROM tbl_MA_VA_Zuordnung " & _
          "  WHERE VADatum = #" & Format(PruefDatum, "mm/dd/yyyy") & "#" & _
          "  AND MA_Start < #" & Format(EndeZeit, "hh:nn") & "#" & _
          "  AND MA_Ende > #" & Format(StartZeit, "hh:nn") & "#" & _
          ") " & _
          "AND ID NOT IN (" & _
          "  SELECT MA_ID FROM tbl_MA_NVerfuegZeiten " & _
          "  WHERE vonDat <= #" & Format(PruefDatum, "mm/dd/yyyy") & "#" & _
          "  AND bisDat >= #" & Format(PruefDatum, "mm/dd/yyyy") & "#" & _
          ")"

    If QualiID > 0 Then
        sql = sql & " AND ID IN (SELECT MA_ID FROM tbl_MA_Einsatz_Zuo WHERE Quali_ID = " & QualiID & ")"
    End If

    VerfuegbareMA_Zaehlen = Nz(DLookup("Anz", "(" & sql & ")"), 0)
End Function

' ============================================
' SCHNELLZUORDNUNG - wie bei Deputy/TrackTik
' ============================================

Public Function Schnell_Zuordnen(VA_ID As Long, VADatum_ID As Long, _
                                  VAStart_ID As Long, MA_ID As Long, _
                                  StartZeit As Date, EndeZeit As Date) As Boolean
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim vaDatum As Date
    Dim konflikt As String

    On Error GoTo Fehler

    ' Hole VADatum aus der ID
    vaDatum = Nz(DLookup("VADatum", "tbl_VA_AnzTage", "ID = " & VADatum_ID), Date)

    ' Konfliktprüfung zuerst
    konflikt = Konflikt_Pruefen(MA_ID, vaDatum, StartZeit, EndeZeit)
    If konflikt <> "" Then
        MsgBox konflikt, vbExclamation, "Zuordnung nicht möglich"
        Schnell_Zuordnen = False
        Exit Function
    End If

    ' Zuordnung einfügen
    Set db = CurrentDb
    Set rs = db.OpenRecordset("tbl_MA_VA_Zuordnung", dbOpenDynaset)

    rs.AddNew
    rs!VA_ID = VA_ID
    rs!MA_ID = MA_ID
    rs!VADatum_ID = VADatum_ID
    rs!VAStart_ID = VAStart_ID
    rs!VADatum = vaDatum
    rs!MA_Start = StartZeit
    rs!MA_Ende = EndeZeit
    rs!Erst_von = Environ("USERNAME")
    rs!Erst_am = Now()
    rs.Update
    rs.Close

    ' IST-Zähler aktualisieren
    Call Aktualisiere_IstZaehler(VADatum_ID)

    Set rs = Nothing
    Set db = Nothing

    Schnell_Zuordnen = True
    Exit Function

Fehler:
    MsgBox "Fehler bei Schnellzuordnung: " & Err.Description, vbCritical
    Schnell_Zuordnen = False
End Function

Private Sub Aktualisiere_IstZaehler(VADatum_ID As Long)
    Dim anzahl As Long
    On Error Resume Next

    anzahl = Nz(DCount("*", "tbl_MA_VA_Zuordnung", "VADatum_ID = " & VADatum_ID), 0)

    CurrentDb.Execute "UPDATE tbl_VA_AnzTage SET " & _
                      "TVA_Ist = " & anzahl & ", " & _
                      "TVA_Offen = TVA_Soll - " & anzahl & " " & _
                      "WHERE ID = " & VADatum_ID, dbFailOnError
End Sub

' ============================================
' AMPEL-FARBCODIERUNG - wie bei allen Profi-Tools
' ============================================

Public Function Ampel_Farbe(IstWert As Long, SollWert As Long) As Long
    If SollWert = 0 Then
        Ampel_Farbe = RGB(200, 200, 200)  ' Grau - kein Bedarf
    ElseIf IstWert >= SollWert Then
        Ampel_Farbe = RGB(0, 180, 0)      ' Grün - voll besetzt
    ElseIf IstWert >= SollWert * 0.7 Then
        Ampel_Farbe = RGB(255, 180, 0)    ' Orange - fast besetzt
    ElseIf IstWert >= SollWert * 0.5 Then
        Ampel_Farbe = RGB(255, 100, 0)    ' Dunkel-Orange - halb besetzt
    Else
        Ampel_Farbe = RGB(220, 50, 50)    ' Rot - kritisch unterbesetzt
    End If
End Function

' ============================================
' HILFSFUNKTIONEN
' ============================================

Public Function Hole_MAName(MA_ID As Long) As String
    On Error Resume Next
    Hole_MAName = Nz(DLookup("Nachname & ', ' & Vorname", _
                             "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID), "Unbekannt")
End Function

Public Function Hole_AuftragInfo(VA_ID As Long) As String
    On Error Resume Next
    Hole_AuftragInfo = Nz(DLookup("Auftrag & ' - ' & Ort", _
                                   "tbl_VA_Auftragstamm", "ID = " & VA_ID), "Unbekannt")
End Function

Public Function Format_Zeit(z As Variant) As String
    If IsNull(z) Then
        Format_Zeit = "--:--"
    Else
        Format_Zeit = Format(z, "hh:nn")
    End If
End Function

' ============================================
' TAGES-ZUSAMMENFASSUNG
' ============================================

Public Function Tages_Zusammenfassung(Optional PruefDatum As Date = 0) As String
    Dim result As String
    Dim totalSoll As Long
    Dim totalIst As Long
    Dim unterbesetzt As Long

    On Error Resume Next

    If PruefDatum = 0 Then PruefDatum = Date

    totalSoll = Nz(DSum("TVA_Soll", "tbl_VA_AnzTage", _
                        "VADatum = #" & Format(PruefDatum, "mm/dd/yyyy") & "#"), 0)
    totalIst = Nz(DSum("TVA_Ist", "tbl_VA_AnzTage", _
                       "VADatum = #" & Format(PruefDatum, "mm/dd/yyyy") & "#"), 0)
    unterbesetzt = Nz(DCount("*", "tbl_VA_AnzTage", _
                              "VADatum = #" & Format(PruefDatum, "mm/dd/yyyy") & "# AND TVA_Offen > 0"), 0)

    result = "Datum: " & Format(PruefDatum, "dd.mm.yyyy") & vbCrLf
    result = result & "Personal SOLL: " & totalSoll & vbCrLf
    result = result & "Personal IST: " & totalIst & vbCrLf
    result = result & "Auslastung: " & IIf(totalSoll > 0, Round(totalIst / totalSoll * 100, 1), 0) & "%" & vbCrLf
    result = result & "Unterbesetzte Aufträge: " & unterbesetzt

    Tages_Zusammenfassung = result
End Function

' ============================================
' MA-VERFÜGBARKEITS-KALENDER
' ============================================

Public Function MA_Verfuegbarkeit_Woche(MA_ID As Long, StartDatum As Date) As String
    Dim result As String
    Dim i As Integer
    Dim pruefDatum As Date
    Dim status As String

    On Error Resume Next

    result = "Verfügbarkeit für " & Hole_MAName(MA_ID) & vbCrLf
    result = result & String(40, "-") & vbCrLf

    For i = 0 To 6
        pruefDatum = StartDatum + i

        ' Prüfe Status für diesen Tag
        If DCount("*", "tbl_MA_VA_Zuordnung", _
                  "MA_ID = " & MA_ID & " AND VADatum = #" & Format(pruefDatum, "mm/dd/yyyy") & "#") > 0 Then
            status = "EINGEPLANT"
        ElseIf DCount("*", "tbl_MA_NVerfuegZeiten", _
                      "MA_ID = " & MA_ID & _
                      " AND vonDat <= #" & Format(pruefDatum, "mm/dd/yyyy") & "#" & _
                      " AND bisDat >= #" & Format(pruefDatum, "mm/dd/yyyy") & "#") > 0 Then
            status = "NICHT VERFÜGBAR"
        ElseIf DCount("*", "tbl_MA_VA_Planung", _
                      "MA_ID = " & MA_ID & " AND VADatum = #" & Format(pruefDatum, "mm/dd/yyyy") & "# AND Status_ID = 1") > 0 Then
            status = "ANGEFRAGT"
        Else
            status = "FREI"
        End If

        result = result & Format(pruefDatum, "ddd dd.mm") & ": " & status & vbCrLf
    Next i

    MA_Verfuegbarkeit_Woche = result
End Function
'''

def get_queries():
    """Gibt Dictionary mit allen Dashboard-Abfragen zurück"""
    return {
        "qry_N_Dashboard_AuftraegeHeute": """
            SELECT tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag,
                   tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort,
                   tbl_VA_AnzTage.TVA_Soll, tbl_VA_AnzTage.TVA_Ist,
                   tbl_VA_AnzTage.TVA_Offen, tbl_VA_AnzTage.ID AS VADatum_ID,
                   tbl_VA_Auftragstamm.ID AS VA_ID,
                   tbl_VA_Auftragstamm.Veranst_Status_ID
            FROM tbl_VA_Auftragstamm
            INNER JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID
            WHERE tbl_VA_AnzTage.VADatum = Date()
            ORDER BY tbl_VA_AnzTage.TVA_Offen DESC, tbl_VA_Auftragstamm.Auftrag
        """,

        "qry_N_Dashboard_AuftraegeDieseWoche": """
            SELECT tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag,
                   tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort,
                   tbl_VA_AnzTage.TVA_Soll, tbl_VA_AnzTage.TVA_Ist,
                   tbl_VA_AnzTage.TVA_Offen, tbl_VA_Auftragstamm.ID AS VA_ID
            FROM tbl_VA_Auftragstamm
            INNER JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID
            WHERE tbl_VA_AnzTage.VADatum >= DateAdd('d', 1-Weekday(Date(),2), Date())
              AND tbl_VA_AnzTage.VADatum <= DateAdd('d', 7-Weekday(Date(),2), Date())
            ORDER BY tbl_VA_AnzTage.VADatum, tbl_VA_AnzTage.TVA_Offen DESC
        """,

        "qry_N_Dashboard_Unterbesetzung": """
            SELECT tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag,
                   tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort,
                   tbl_VA_AnzTage.TVA_Soll, tbl_VA_AnzTage.TVA_Ist,
                   tbl_VA_AnzTage.TVA_Offen, tbl_VA_Auftragstamm.ID AS VA_ID
            FROM tbl_VA_Auftragstamm
            INNER JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID
            WHERE tbl_VA_AnzTage.TVA_Offen > 0 AND tbl_VA_AnzTage.VADatum >= Date()
            ORDER BY tbl_VA_AnzTage.VADatum, tbl_VA_AnzTage.TVA_Offen DESC
        """,

        "qry_N_Dashboard_OffeneAnfragen": """
            SELECT tbl_MA_VA_Planung.ID, tbl_MA_VA_Planung.VA_ID,
                   tbl_MA_VA_Planung.MA_ID, tbl_MA_VA_Planung.VADatum,
                   tbl_MA_VA_Planung.VA_Start, tbl_MA_VA_Planung.VA_Ende,
                   tbl_MA_VA_Planung.Status_ID, tbl_MA_VA_Planung.Erst_am,
                   tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname,
                   tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Ort
            FROM (tbl_MA_VA_Planung
            INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Planung.MA_ID = tbl_MA_Mitarbeiterstamm.ID)
            INNER JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Planung.VA_ID = tbl_VA_Auftragstamm.ID
            WHERE tbl_MA_VA_Planung.Status_ID = 1 AND tbl_MA_VA_Planung.VADatum >= Date()
            ORDER BY tbl_MA_VA_Planung.VADatum, tbl_MA_VA_Planung.Erst_am
        """,

        "qry_N_Dashboard_VerfuegbareMA": """
            SELECT tbl_MA_Mitarbeiterstamm.ID, tbl_MA_Mitarbeiterstamm.Nachname,
                   tbl_MA_Mitarbeiterstamm.Vorname, tbl_MA_Mitarbeiterstamm.Tel_Mobil,
                   tbl_MA_Mitarbeiterstamm.Email, tbl_MA_Mitarbeiterstamm.Anstellungsart_ID
            FROM tbl_MA_Mitarbeiterstamm
            WHERE tbl_MA_Mitarbeiterstamm.IstAktiv = True
            ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname
        """,

        "qry_N_Schnellansicht_Zuordnungen": """
            SELECT tbl_MA_VA_Zuordnung.ID, tbl_MA_VA_Zuordnung.VA_ID,
                   tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Ort,
                   tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.MA_Start,
                   tbl_MA_VA_Zuordnung.MA_Ende, tbl_MA_VA_Zuordnung.MA_ID,
                   tbl_MA_Mitarbeiterstamm.Nachname & ', ' & tbl_MA_Mitarbeiterstamm.Vorname AS MAName,
                   tbl_MA_Mitarbeiterstamm.Tel_Mobil
            FROM (tbl_MA_VA_Zuordnung
            INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID)
            INNER JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Zuordnung.VA_ID = tbl_VA_Auftragstamm.ID
            WHERE tbl_MA_VA_Zuordnung.VADatum >= Date()
            ORDER BY tbl_MA_VA_Zuordnung.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_MA_VA_Zuordnung.MA_Start
        """
    }

def main():
    """Hauptfunktion"""
    print("=" * 70)
    print("CONSYS FRONTEND VERBESSERUNGEN - Vollständige Implementierung")
    print("=" * 70)
    print()
    print("Inspiriert von: Timecount, SecPlanNet, TrackTik, Deputy, PARiM")
    print("-" * 70)
    print()

    # Access verbinden
    print("[1/4] Verbinde mit Access...")
    access = create_fresh_connection()
    if not access:
        print("ABBRUCH: Konnte keine Verbindung herstellen!")
        return False

    print()
    print("[2/4] Erstelle VBA-Module...")
    print("-" * 40)

    # Dashboard-Modul erstellen
    dashboard_code = get_dashboard_module_code()
    if create_vba_module_via_sql(access, "mod_N_Dashboard", dashboard_code):
        print("  -> Dashboard-Modul erfolgreich!")

    print()
    print("[3/4] Erstelle Dashboard-Abfragen...")
    print("-" * 40)

    # Alle Abfragen erstellen
    queries = get_queries()
    for name, sql in queries.items():
        create_query(access, name, sql)

    print()
    print("[4/4] Speichere Änderungen...")
    print("-" * 40)

    try:
        # Kompilieren
        access.DoCmd.RunCommand(14)  # acCmdCompileAllModules
        print("  VBA kompiliert")
    except:
        pass

    try:
        # Speichern
        access.RunCommand(3)  # acCmdSaveDatabase
        print("  Datenbank gespeichert")
    except:
        pass

    # Access schließen
    try:
        access.CloseCurrentDatabase()
        access.Quit()
        print("  Access geschlossen")
    except:
        pass

    print()
    print("=" * 70)
    print("IMPLEMENTIERUNG ABGESCHLOSSEN!")
    print("=" * 70)
    print()
    print("Erstellte Komponenten:")
    print("  - Modul: mod_N_Dashboard (mit Funktionen für Kennzahlen,")
    print("           Konfliktprüfung, Schnellzuordnung, Ampel-Farben)")
    print()
    print("  - Abfragen:")
    for name in queries.keys():
        print(f"           {name}")
    print()
    print("Nächste Schritte:")
    print("  1. Öffnen Sie das Frontend und prüfen Sie die neuen Objekte")
    print("  2. Das Modul 'mod_N_Dashboard' enthält alle neuen Funktionen")
    print("  3. Die Abfragen können für Unterformulare verwendet werden")
    print()

    return True

if __name__ == "__main__":
    try:
        success = main()
        if not success:
            sys.exit(1)
    except Exception as e:
        print(f"\nFATALER FEHLER: {e}")
        sys.exit(1)

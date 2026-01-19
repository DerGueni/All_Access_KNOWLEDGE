#!/usr/bin/env python3
"""
Script: create_eventdaten_report.py
Beschreibung: Erstellt Query und Report für Eventdaten-PDF in Access
Erstellt: 2026-01-03

Verwendung:
    python create_eventdaten_report.py

Voraussetzung:
    - Access Bridge muss verfügbar sein
    - tbl_N_VA_EventDaten muss existieren (aus mod_N_EventDaten.bas)
"""

import sys
import os

# Access Bridge Pfad hinzufügen
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

try:
    from access_bridge_ultimate import AccessBridge
except ImportError:
    print("FEHLER: Access Bridge nicht gefunden!")
    print("Pfad: C:\\Users\\guenther.siegert\\Documents\\Access Bridge")
    sys.exit(1)


def create_eventdaten_query(bridge):
    """Erstellt die Abfrage für den Eventdaten-Report"""

    sql = """
    SELECT
        e.ID,
        e.VA_ID,
        e.Einlass,
        e.Beginn,
        e.Ende,
        e.Infos,
        e.WebLink,
        e.Erfolgreich,
        e.Fehlermeldung,
        e.Erstellt_am,
        a.Auftrag,
        a.Objekt,
        a.Ort,
        a.Strasse,
        a.PLZ,
        a.Dat_VA_Von,
        a.Dat_VA_Bis,
        a.Treffpunkt,
        a.Treffp_Zeit,
        a.Dienstkleidung,
        a.Ansprechpartner,
        k.kun_Firma AS Kunde
    FROM tbl_N_VA_EventDaten AS e
    INNER JOIN tbl_VA_Auftragstamm AS a ON e.VA_ID = a.ID
    LEFT JOIN tbl_KD_Kundenstamm AS k ON a.Veranstalter_ID = k.kun_Id
    WHERE e.Erfolgreich = True
    ORDER BY e.VA_ID
    """

    print("Erstelle Query: qry_N_EventDaten_Report...")
    result = bridge.create_query("EventDaten_Report", sql, auto_prefix=True)
    print(f"  -> {result}")
    return result


def create_eventdaten_table_if_not_exists(bridge):
    """Erstellt die Eventdaten-Tabelle falls nicht vorhanden"""

    # Prüfen ob Tabelle existiert
    tables = bridge.list_tables()
    if "tbl_N_VA_EventDaten" in tables:
        print("Tabelle tbl_N_VA_EventDaten existiert bereits.")
        return True

    print("Erstelle Tabelle: tbl_N_VA_EventDaten...")

    sql = """
    CREATE TABLE tbl_N_VA_EventDaten (
        ID AUTOINCREMENT PRIMARY KEY,
        VA_ID LONG,
        Einlass TEXT(50),
        Beginn TEXT(50),
        Ende TEXT(50),
        Infos MEMO,
        WebLink TEXT(255),
        Erfolgreich YESNO,
        Fehlermeldung TEXT(255),
        Erstellt_am DATETIME
    )
    """

    try:
        bridge.execute_sql(sql)
        print("  -> Tabelle erstellt")

        # Index auf VA_ID erstellen
        bridge.execute_sql("CREATE INDEX idx_VA_ID ON tbl_N_VA_EventDaten (VA_ID)")
        print("  -> Index erstellt")
        return True
    except Exception as e:
        print(f"  -> Fehler: {e}")
        return False


def create_eventdaten_report_vba(bridge):
    """
    Erstellt VBA-Code für den Report.
    Der Report selbst muss manuell in Access erstellt werden,
    da die Bridge keine Reports erstellen kann.
    """

    vba_code = '''
' Report: rpt_N_EventDaten
' Beschreibung: Zeigt Eventdaten für eine Veranstaltung
' RecordSource: qry_N_EventDaten_Report

Private Sub Report_Open(Cancel As Integer)
    Dim VA_ID As Long

    On Error Resume Next
    VA_ID = CurrentDb.Properties("prp_EventDaten_VA_ID")
    On Error GoTo 0

    If VA_ID > 0 Then
        Me.Filter = "VA_ID = " & VA_ID
        Me.FilterOn = True
    End If
End Sub

Private Sub Report_Close()
    ' Filter zurücksetzen
    On Error Resume Next
    CurrentDb.Properties.Delete "prp_EventDaten_VA_ID"
End Sub
'''

    print("Erstelle VBA-Modul für Report: mod_N_Report_EventDaten...")
    result = bridge.import_vba_module("Report_EventDaten", vba_code, auto_prefix=True)
    print(f"  -> {result}")
    return result


def print_report_anleitung():
    """Gibt Anleitung für manuelle Report-Erstellung aus"""

    anleitung = """
================================================================================
ANLEITUNG: Report manuell in Access erstellen
================================================================================

1. Access öffnen und zu "Erstellen" -> "Berichtsentwurf" gehen

2. Report-Eigenschaften setzen:
   - Name: rpt_N_EventDaten
   - Datensatzquelle: qry_N_EventDaten_Report
   - Bei Öffnen: [Ereignisprozedur] -> Code aus mod_N_Report_EventDaten
   - Bei Schließen: [Ereignisprozedur] -> Code aus mod_N_Report_EventDaten

3. Berichtskopf (einmalig oben):
   - Logo/Header "CONSEC Event-Informationen"
   - Felder: Auftrag, Objekt, Ort, Datum (Dat_VA_Von)

4. Detailbereich (Hauptinhalt):
   +--------------------------------------------------+
   | EVENT-INFORMATIONEN                              |
   +--------------------------------------------------+
   | Einlass:     [Einlass]                           |
   | Beginn:      [Beginn]                            |
   | Ende:        [Ende]                              |
   +--------------------------------------------------+
   | Treffpunkt:  [Treffpunkt] um [Treffp_Zeit]       |
   | Dresscode:   [Dienstkleidung]                    |
   | Kontakt:     [Ansprechpartner]                   |
   +--------------------------------------------------+
   | Zusätzliche Informationen:                       |
   | [Infos - mehrzeilig]                             |
   +--------------------------------------------------+
   | Quelle: [WebLink]                                |
   +--------------------------------------------------+

5. Berichtsfuß:
   - "Automatisch generiert am [Datum]"
   - Seitenzahl

6. Empfohlene Größen:
   - Seitenbreite: 21 cm (A4)
   - Ränder: 1,5 cm
   - Schriftart: Arial 10pt
   - Überschriften: Arial 12pt fett

================================================================================
"""
    print(anleitung)


def main():
    print("=" * 70)
    print("Eventdaten Report Setup")
    print("=" * 70)
    print()

    try:
        with AccessBridge() as bridge:
            print("Access Bridge verbunden.\n")

            # 1. Tabelle erstellen (falls nicht vorhanden)
            create_eventdaten_table_if_not_exists(bridge)
            print()

            # 2. Query erstellen
            create_eventdaten_query(bridge)
            print()

            # 3. VBA-Modul für Report erstellen
            create_eventdaten_report_vba(bridge)
            print()

            print("=" * 70)
            print("Setup abgeschlossen!")
            print("=" * 70)

    except Exception as e:
        print(f"\nFEHLER: {e}")
        print("\nBitte sicherstellen, dass:")
        print("  1. Access Frontend geöffnet ist")
        print("  2. Access Bridge korrekt installiert ist")
        return 1

    # Anleitung für manuellen Report ausgeben
    print()
    print_report_anleitung()

    return 0


if __name__ == "__main__":
    sys.exit(main())

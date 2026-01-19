"""
Prüfe und korrigiere die Abfrage für Bearbeitbarkeit
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("PRÜFE ABFRAGE qry_N_DP_Einsatzliste")
    print("=" * 70)

    # Hole aktuelle SQL
    for qdef in bridge.current_db.QueryDefs:
        if qdef.Name == "qry_N_DP_Einsatzliste":
            print(f"Aktuelle SQL:\n{qdef.SQL}")
            break

    # Das Problem: LEFT JOIN mit berechneten Feldern macht die Abfrage nicht bearbeitbar
    # Lösung: Direkter Zugriff auf tbl_MA_VA_Zuordnung mit DLookup für MA_Name

    print("\n" + "=" * 70)
    print("KORRIGIERE ABFRAGE FÜR BEARBEITBARKEIT")
    print("=" * 70)

    # Neue SQL - direkt auf Tabelle, MA_Name als berechnetes Feld
    # Bei JOINs muss die Haupttabelle eindeutig sein für Bearbeitbarkeit
    new_sql = """SELECT
    tbl_MA_VA_Zuordnung.ID,
    tbl_MA_VA_Zuordnung.VA_ID,
    tbl_MA_VA_Zuordnung.VADatum_ID,
    tbl_MA_VA_Zuordnung.VAStart_ID,
    tbl_MA_VA_Zuordnung.PosNr,
    tbl_MA_VA_Zuordnung.MA_ID,
    tbl_MA_Mitarbeiterstamm.Nachname & ' ' & tbl_MA_Mitarbeiterstamm.Vorname AS MA_Name,
    tbl_MA_VA_Zuordnung.MA_Start,
    tbl_MA_VA_Zuordnung.MA_Ende,
    Round(([MA_Ende]-[MA_Start])*24,2) AS Std,
    tbl_MA_VA_Zuordnung.Bemerkungen,
    tbl_MA_VA_Zuordnung.PKW,
    tbl_MA_VA_Zuordnung.Einsatzleitung,
    tbl_MA_VA_Zuordnung.IstFraglich
FROM tbl_MA_VA_Zuordnung
LEFT JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID
ORDER BY tbl_MA_VA_Zuordnung.MA_Start, tbl_MA_VA_Zuordnung.PosNr;"""

    for qdef in bridge.current_db.QueryDefs:
        if qdef.Name == "qry_N_DP_Einsatzliste":
            qdef.SQL = new_sql
            print("[OK] Abfrage aktualisiert")
            print(f"\nNeue SQL:\n{new_sql}")
            break

    # Prüfe nochmal das Formular
    print("\n" + "=" * 70)
    print("PRÜFE FORMULAR-EINSTELLUNGEN")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        print(f"RecordSource: {form.RecordSource}")
        print(f"AllowEdits: {form.AllowEdits}")
        print(f"AllowAdditions: {form.AllowAdditions}")
        print(f"AllowDeletions: {form.AllowDeletions}")
        print(f"RecordsetType: {form.RecordsetType}")

        # Stelle sicher dass alles auf bearbeitbar steht
        form.AllowEdits = True
        form.AllowAdditions = True
        form.AllowDeletions = True
        form.RecordsetType = 0  # Dynaset

        # Prüfe auch RecordLocks
        try:
            print(f"RecordLocks: {form.RecordLocks}")
            form.RecordLocks = 0  # No Locks
        except:
            pass

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)
        print("\n[OK] Formular gespeichert!")

    except Exception as e:
        print(f"Fehler: {e}")
        try:
            bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
        except:
            pass

print("\n[FERTIG]")

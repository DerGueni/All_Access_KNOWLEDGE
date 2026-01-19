"""
Korrigiere Einsatzliste: Bearbeitung JA, Hinzufügen NEIN
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("KORRIGIERE EINSATZLISTE - NUR BEARBEITUNG")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        print("\nAktuelle Einstellungen:")
        print(f"  AllowEdits: {form.AllowEdits}")
        print(f"  AllowAdditions: {form.AllowAdditions}")
        print(f"  AllowDeletions: {form.AllowDeletions}")
        print(f"  DataEntry: {form.DataEntry}")
        print(f"  RecordsetType: {form.RecordsetType}")

        print("\nSetze neue Einstellungen:")
        form.AllowEdits = True        # Bearbeitung erlauben
        form.AllowAdditions = False   # KEINE neuen Datensätze
        form.AllowDeletions = False   # Kein Löschen
        form.DataEntry = False        # Nicht nur Dateneingabe
        form.RecordsetType = 0        # Dynaset (bearbeitbar)

        print(f"  AllowEdits: {form.AllowEdits}")
        print(f"  AllowAdditions: {form.AllowAdditions}")
        print(f"  AllowDeletions: {form.AllowDeletions}")
        print(f"  DataEntry: {form.DataEntry}")
        print(f"  RecordsetType: {form.RecordsetType}")

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)
        print("\n[OK] Gespeichert!")

    except Exception as e:
        print(f"Fehler: {e}")
        try:
            bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
        except:
            pass

    # Prüfe auch die Abfrage - vielleicht ist sie nicht bearbeitbar
    print("\n" + "=" * 70)
    print("PRÜFE ABFRAGE")
    print("=" * 70)

    for qdef in bridge.current_db.QueryDefs:
        if qdef.Name == "qry_N_DP_Einsatzliste":
            print(f"  Updatable: {qdef.Updatable}")
            print(f"  SQL:\n{qdef.SQL}")
            break

print("\n[FERTIG]")

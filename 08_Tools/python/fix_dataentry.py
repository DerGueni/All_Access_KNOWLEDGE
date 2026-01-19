"""
Korrigiere DataEntry und Link-Felder
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("KORRIGIERE DATAENTRY UND LINK-FELDER")
    print("=" * 70)

    # 1. Korrigiere Unterformular
    print("\n1. Korrigiere zsub_N_DP_Einsatzliste...")
    try:
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        print(f"  DataEntry war: {form.DataEntry}")
        form.DataEntry = False  # Nicht nur Dateneingabe, sondern auch Bearbeitung!
        print(f"  DataEntry jetzt: {form.DataEntry}")

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)
        print("  [OK] Unterformular gespeichert!")

    except Exception as e:
        print(f"  Fehler: {e}")
        try:
            bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
        except:
            pass

    # 2. Setze Link-Felder im Dashboard (falls nötig)
    print("\n2. Prüfe Link-Felder im Dashboard...")
    try:
        bridge.access_app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("frm_N_DP_Dashboard")

        for ctrl in form.Controls:
            if ctrl.Name == "sub_Einsatzliste":
                print(f"  LinkMasterFields: '{ctrl.LinkMasterFields}'")
                print(f"  LinkChildFields: '{ctrl.LinkChildFields}'")
                # Link-Felder sind leer - das könnte gewollt sein
                # wenn alle Einsätze angezeigt werden sollen
                break

        bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)

    except Exception as e:
        print(f"  Fehler: {e}")

    # 3. Verifiziere
    print("\n3. Verifiziere...")
    try:
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")
        print(f"  DataEntry: {form.DataEntry}")
        print(f"  AllowEdits: {form.AllowEdits}")
        print(f"  AllowAdditions: {form.AllowAdditions}")
        print(f"  RecordsetType: {form.RecordsetType}")
        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
    except:
        pass

print("\n[FERTIG]")

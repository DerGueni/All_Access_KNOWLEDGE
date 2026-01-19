"""
Prüfe Link-Felder und Subform-Einstellungen im Dashboard
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("PRÜFE SUBFORM-EINSTELLUNGEN IM DASHBOARD")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("frm_N_DP_Dashboard")

        print("\nSubform 'sub_Einsatzliste' Eigenschaften:")
        for ctrl in form.Controls:
            if ctrl.Name == "sub_Einsatzliste":
                print(f"  SourceObject: {ctrl.SourceObject}")
                try:
                    print(f"  LinkMasterFields: {ctrl.LinkMasterFields}")
                except:
                    print(f"  LinkMasterFields: (nicht verfügbar)")
                try:
                    print(f"  LinkChildFields: {ctrl.LinkChildFields}")
                except:
                    print(f"  LinkChildFields: (nicht verfügbar)")
                try:
                    print(f"  Locked: {ctrl.Locked}")
                except:
                    pass
                try:
                    print(f"  Enabled: {ctrl.Enabled}")
                except:
                    pass
                break

        bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)

        # Prüfe auch das Unterformular selbst direkt
        print("\n" + "=" * 70)
        print("PRÜFE UNTERFORMULAR DIREKT")
        print("=" * 70)

        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        time.sleep(0.5)
        subform = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        print(f"\nFormular-Eigenschaften:")
        print(f"  RecordSource: {subform.RecordSource}")
        print(f"  AllowEdits: {subform.AllowEdits}")
        print(f"  AllowAdditions: {subform.AllowAdditions}")
        print(f"  AllowDeletions: {subform.AllowDeletions}")
        print(f"  RecordsetType: {subform.RecordsetType}")
        print(f"  DataEntry: {subform.DataEntry}")

        try:
            print(f"  Recordset.Updatable: Teste...")
        except:
            pass

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)

        # Teste die Abfrage direkt
        print("\n" + "=" * 70)
        print("TESTE ABFRAGE DIREKT")
        print("=" * 70)

        for qdef in bridge.current_db.QueryDefs:
            if qdef.Name == "qry_N_DP_Einsatzliste":
                print(f"  Updatable: {qdef.Updatable}")
                print(f"  Type: {qdef.Type}")
                break

    except Exception as e:
        print(f"Fehler: {e}")
        import traceback
        traceback.print_exc()

print("\n[FERTIG]")

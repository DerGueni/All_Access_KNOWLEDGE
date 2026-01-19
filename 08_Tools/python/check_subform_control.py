"""
Prüfe das Subform-Control im Dashboard genauer
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("PRÜFE SUBFORM-CONTROL IM DASHBOARD")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("frm_N_DP_Dashboard")

        for ctrl in form.Controls:
            if ctrl.Name == "sub_Einsatzliste":
                print(f"\nControl: {ctrl.Name}")
                print(f"  SourceObject: {ctrl.SourceObject}")
                print(f"  Locked: {ctrl.Locked}")
                print(f"  Enabled: {ctrl.Enabled}")

                # Entsperre das Subform-Control
                ctrl.Locked = False
                ctrl.Enabled = True
                print("\n  -> Entsperrt und aktiviert")
                break

        bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
        print("\n[OK] Dashboard gespeichert!")

    except Exception as e:
        print(f"Fehler: {e}")
        try:
            bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)
        except:
            pass

    # Prüfe auch das Hauptformular
    print("\n" + "=" * 70)
    print("PRÜFE HAUPTFORMULAR frm_N_DP_Dashboard")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("frm_N_DP_Dashboard")

        print(f"AllowEdits: {form.AllowEdits}")
        print(f"RecordsetType: {form.RecordsetType}")

        # Aktiviere Bearbeitung im Hauptformular
        form.AllowEdits = True

        bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)

    except Exception as e:
        print(f"Fehler: {e}")

    # Öffne das Dashboard in Normalansicht und prüfe das Unterformular
    print("\n" + "=" * 70)
    print("TESTE IN NORMALANSICHT")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("frm_N_DP_Dashboard", 0)  # Normal View
        time.sleep(1)

        dashboard = bridge.access_app.Forms("frm_N_DP_Dashboard")

        # Zugriff auf das Unterformular
        subform_ctrl = dashboard.Controls("sub_Einsatzliste")
        subform = subform_ctrl.Form

        print(f"Unterformular RecordSource: {subform.RecordSource}")
        print(f"Unterformular AllowEdits: {subform.AllowEdits}")
        print(f"Unterformular Recordset.RecordCount: {subform.Recordset.RecordCount}")

        # Prüfe ob Recordset bearbeitbar ist
        try:
            rs = subform.Recordset
            print(f"Recordset.Updatable: {rs.Updatable}")
        except Exception as e:
            print(f"Recordset-Fehler: {e}")

        bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)

    except Exception as e:
        print(f"Fehler: {e}")
        import traceback
        traceback.print_exc()

print("\n[FERTIG]")

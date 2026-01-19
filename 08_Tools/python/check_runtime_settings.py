"""
Prüfe Runtime-Einstellungen wenn das Dashboard geöffnet ist
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("PRÜFE RUNTIME-EINSTELLUNGEN IM DASHBOARD")
    print("=" * 70)

    try:
        # Öffne Dashboard in Normalansicht
        bridge.access_app.DoCmd.OpenForm("frm_N_DP_Dashboard", 0)
        time.sleep(1)

        dashboard = bridge.access_app.Forms("frm_N_DP_Dashboard")
        subform_ctrl = dashboard.Controls("sub_Einsatzliste")
        subform = subform_ctrl.Form

        print(f"\nUnterformular Runtime-Eigenschaften:")
        print(f"  RecordSource: {subform.RecordSource}")
        print(f"  Filter: '{subform.Filter}'")
        print(f"  FilterOn: {subform.FilterOn}")
        print(f"  AllowEdits: {subform.AllowEdits}")
        print(f"  AllowAdditions: {subform.AllowAdditions}")
        print(f"  Recordset.Updatable: {subform.Recordset.Updatable}")

        # Prüfe alle bearbeitbaren Controls
        print(f"\nControl-Status zur Laufzeit:")
        for ctrl in subform.Controls:
            try:
                if ctrl.ControlType in [109, 106]:  # TextBox, CheckBox
                    if ctrl.Width > 0:
                        locked = ctrl.Locked
                        enabled = ctrl.Enabled
                        print(f"  {ctrl.Name}: Locked={locked}, Enabled={enabled}")
            except:
                pass

        bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)

    except Exception as e:
        print(f"Fehler: {e}")
        import traceback
        traceback.print_exc()

    # Prüfe ob es VBA-Code gibt, der das Formular sperrt
    print("\n" + "=" * 70)
    print("PRÜFE VBA-CODE VON zsub_N_DP_Einsatzliste")
    print("=" * 70)

    vbe = bridge.access_app.VBE
    proj = vbe.ActiveVBProject

    for comp in proj.VBComponents:
        if "zsub_N_DP_Einsatzliste" in comp.Name:
            code_module = comp.CodeModule
            if code_module.CountOfLines > 0:
                code = code_module.Lines(1, code_module.CountOfLines)
                print(f"\nCode in {comp.Name}:")
                print(code)
            else:
                print(f"\n{comp.Name}: Kein Code vorhanden")
            break

print("\n[FERTIG]")

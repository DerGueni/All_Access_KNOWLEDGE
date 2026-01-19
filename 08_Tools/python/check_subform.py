"""
Prüfe welches Unterformular im Dashboard für Einsatzliste verwendet wird
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("PRÜFE UNTERFORMULAR IM DASHBOARD")
    print("=" * 70)

    # Öffne Dashboard und prüfe das Einsatzliste-Subform
    try:
        bridge.access_app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("frm_N_DP_Dashboard")

        print("\nSubform-Controls im Dashboard:")
        for ctrl in form.Controls:
            try:
                if ctrl.ControlType == 112:  # Subform
                    source = ""
                    try:
                        source = ctrl.SourceObject
                    except:
                        pass
                    print(f"  {ctrl.Name} -> SourceObject: '{source}'")
            except:
                pass

        bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)

    except Exception as e:
        print(f"Fehler: {e}")

    # Liste alle Formulare mit "einsatz" im Namen
    print("\n" + "=" * 70)
    print("ALLE FORMULARE MIT 'EINSATZ' IM NAMEN")
    print("=" * 70)

    forms_list = bridge.list_forms()
    for frm in forms_list:
        if "einsatz" in frm.lower():
            print(f"  - {frm}")

print("\n[FERTIG]")

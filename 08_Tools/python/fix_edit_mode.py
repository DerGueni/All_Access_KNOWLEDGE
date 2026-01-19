"""
Aktiviere Bearbeitung in zsub_N_DP_Einsatzliste
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("AKTIVIERE BEARBEITUNG IN EINSATZLISTE")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)  # Design View
        time.sleep(0.5)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        # Zeige aktuelle Einstellungen
        print("\nAktuelle Einstellungen:")
        print(f"  AllowEdits: {form.AllowEdits}")
        print(f"  AllowAdditions: {form.AllowAdditions}")
        print(f"  AllowDeletions: {form.AllowDeletions}")
        print(f"  RecordsetType: {form.RecordsetType}")

        # Aktiviere Bearbeitung
        print("\nAktiviere Bearbeitung...")
        form.AllowEdits = True
        form.AllowAdditions = True
        form.AllowDeletions = True
        form.RecordsetType = 0  # Dynaset (bearbeitbar)

        # Prüfe auch die einzelnen Controls
        print("\nPrüfe Control-Einstellungen:")
        for ctrl in form.Controls:
            try:
                if ctrl.ControlType == 109:  # TextBox
                    if hasattr(ctrl, 'Locked'):
                        if ctrl.Locked:
                            ctrl.Locked = False
                            print(f"  {ctrl.Name}: Locked = False")
                    if hasattr(ctrl, 'Enabled'):
                        if not ctrl.Enabled:
                            ctrl.Enabled = True
                            print(f"  {ctrl.Name}: Enabled = True")
                elif ctrl.ControlType == 106:  # CheckBox
                    if hasattr(ctrl, 'Locked'):
                        if ctrl.Locked:
                            ctrl.Locked = False
                            print(f"  {ctrl.Name}: Locked = False")
                    if hasattr(ctrl, 'Enabled'):
                        if not ctrl.Enabled:
                            ctrl.Enabled = True
                            print(f"  {ctrl.Name}: Enabled = True")
            except:
                pass

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)
        print("\n[OK] Formular gespeichert!")

        # Verifiziere
        print("\nVerifiziere:")
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")
        print(f"  AllowEdits: {form.AllowEdits}")
        print(f"  AllowAdditions: {form.AllowAdditions}")
        print(f"  AllowDeletions: {form.AllowDeletions}")
        print(f"  RecordsetType: {form.RecordsetType}")
        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)

    except Exception as e:
        print(f"Fehler: {e}")
        import traceback
        traceback.print_exc()
        try:
            bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
        except:
            pass

print("\n[FERTIG]")

"""
Entsperre alle Controls im Formular
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("ENTSPERRE ALLE CONTROLS")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        print("\nControl-Status:")
        for ctrl in form.Controls:
            try:
                ctrl_type = ctrl.ControlType
                if ctrl_type in [109, 106, 110, 111]:  # TextBox, CheckBox, ListBox, ComboBox
                    locked = False
                    enabled = True
                    try:
                        locked = ctrl.Locked
                    except:
                        pass
                    try:
                        enabled = ctrl.Enabled
                    except:
                        pass

                    print(f"  {ctrl.Name}: Locked={locked}, Enabled={enabled}")

                    # Entsperre
                    try:
                        ctrl.Locked = False
                        ctrl.Enabled = True
                    except Exception as e:
                        print(f"    -> Fehler beim Entsperren: {e}")

            except:
                pass

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)
        print("\n[OK] Gespeichert!")

        # Verifiziere
        print("\nVerifiziere nach Speichern:")
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        for ctrl in form.Controls:
            try:
                ctrl_type = ctrl.ControlType
                if ctrl_type in [109, 106] and ctrl.Width > 0:
                    locked = ctrl.Locked if hasattr(ctrl, 'Locked') else 'N/A'
                    enabled = ctrl.Enabled if hasattr(ctrl, 'Enabled') else 'N/A'
                    print(f"  {ctrl.Name}: Locked={locked}, Enabled={enabled}")
            except:
                pass

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)

    except Exception as e:
        print(f"Fehler: {e}")
        import traceback
        traceback.print_exc()

print("\n[FERTIG]")

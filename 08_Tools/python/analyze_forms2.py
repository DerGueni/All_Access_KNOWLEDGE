"""
Analysiere frm_Menuefuehrung und frm_N_DP_Dashboard
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("ANALYSE DER FORMULARE")
    print("=" * 70)

    # Analysiere frm_Menuefuehrung
    print("\n" + "=" * 70)
    print("frm_Menuefuehrung - STRUKTUR")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("frm_Menuefuehrung", 1)  # Design View
        time.sleep(1)
        form = bridge.access_app.Forms("frm_Menuefuehrung")

        print(f"Breite: {form.Width} twips ({form.Width/567:.1f} cm)")
        try:
            print(f"Detail-Höhe: {form.Section(0).Height} twips ({form.Section(0).Height/567:.1f} cm)")
        except:
            pass
        print(f"RecordSource: {form.RecordSource}")
        print(f"DefaultView: {form.DefaultView}")

        print("\nControls (Buttons und wichtige Elemente):")
        for ctrl in form.Controls:
            try:
                ctrl_type = ctrl.ControlType
                if ctrl_type == 104 or "btn" in ctrl.Name.lower():  # CommandButton
                    print(f"  BTN: {ctrl.Name} (Left:{ctrl.Left}, Top:{ctrl.Top}, W:{ctrl.Width}, H:{ctrl.Height})")
                elif ctrl_type == 112:  # Subform
                    print(f"  SUB: {ctrl.Name} (Left:{ctrl.Left}, Top:{ctrl.Top}, W:{ctrl.Width}, H:{ctrl.Height})")
            except:
                pass

        bridge.access_app.DoCmd.Close(2, "frm_Menuefuehrung", 2)
    except Exception as e:
        print(f"Fehler frm_Menuefuehrung: {e}")

    # Analysiere frm_N_DP_Dashboard
    print("\n" + "=" * 70)
    print("frm_N_DP_Dashboard - STRUKTUR")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # Design View
        time.sleep(1)
        form = bridge.access_app.Forms("frm_N_DP_Dashboard")

        print(f"Breite: {form.Width} twips ({form.Width/567:.1f} cm)")
        try:
            print(f"Detail-Höhe: {form.Section(0).Height} twips ({form.Section(0).Height/567:.1f} cm)")
        except:
            pass

        print("\nAlle Controls:")
        for ctrl in form.Controls:
            try:
                ctrl_type = ctrl.ControlType
                print(f"  {ctrl.Name} (Type:{ctrl_type}, Left:{ctrl.Left}, Top:{ctrl.Top}, W:{ctrl.Width}, H:{ctrl.Height})")
            except Exception as e:
                print(f"  {ctrl.Name} - Fehler: {e}")

        bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)
    except Exception as e:
        print(f"Fehler frm_N_DP_Dashboard: {e}")

    # VBA-Code von frm_Menuefuehrung
    print("\n" + "=" * 70)
    print("VBA-CODE von Form_frm_Menuefuehrung")
    print("=" * 70)

    vbe = bridge.access_app.VBE
    proj = vbe.ActiveVBProject

    for comp in proj.VBComponents:
        if comp.Name == "Form_frm_Menuefuehrung":
            code_module = comp.CodeModule
            if code_module.CountOfLines > 0:
                code = code_module.Lines(1, code_module.CountOfLines)
                print(code[:3000])
                if len(code) > 3000:
                    print(f"\n... ({len(code)} Zeichen insgesamt)")
            break

print("\n[FERTIG]")

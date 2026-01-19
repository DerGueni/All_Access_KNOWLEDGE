"""
Analysiere frm_Menuefuehrung und frm_DP_Dashboard
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("ANALYSE DER FORMULARE")
    print("=" * 70)

    # Liste alle Formulare mit "menu" oder "dashboard" im Namen
    print("\nFormulare mit 'menu' oder 'dashboard':")
    for doc in bridge.access_app.CurrentProject.AllForms:
        if "menu" in doc.Name.lower() or "dashboard" in doc.Name.lower() or "dp_" in doc.Name.lower():
            print(f"  - {doc.Name}")

    # Analysiere frm_Menuefuehrung
    print("\n" + "=" * 70)
    print("frm_Menuefuehrung - STRUKTUR")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("frm_Menuefuehrung", 1)  # Design View
        time.sleep(1)
        form = bridge.access_app.Forms("frm_Menuefuehrung")

        print(f"Breite: {form.Width} twips ({form.Width/567:.1f} cm)")
        print(f"RecordSource: {form.RecordSource}")
        print(f"DefaultView: {form.DefaultView}")

        print("\nControls:")
        for ctrl in form.Controls:
            try:
                ctrl_type = ctrl.ControlType
                print(f"  - {ctrl.Name} (Type: {ctrl_type}, Left: {ctrl.Left}, Top: {ctrl.Top}, Width: {ctrl.Width})")
            except:
                print(f"  - {ctrl.Name}")

        bridge.access_app.DoCmd.Close(2, "frm_Menuefuehrung", 2)
    except Exception as e:
        print(f"Fehler: {e}")

    # Analysiere frm_DP_Dashboard (falls vorhanden)
    print("\n" + "=" * 70)
    print("SUCHE DASHBOARD FORMULARE")
    print("=" * 70)

    dashboard_forms = []
    for doc in bridge.access_app.CurrentProject.AllForms:
        if "dp_dashboard" in doc.Name.lower() or "n_dp" in doc.Name.lower():
            dashboard_forms.append(doc.Name)
            print(f"  - {doc.Name}")

    if dashboard_forms:
        for frm_name in dashboard_forms[:3]:  # Nur die ersten 3
            print(f"\n--- {frm_name} ---")
            try:
                bridge.access_app.DoCmd.OpenForm(frm_name, 1)
                time.sleep(0.5)
                form = bridge.access_app.Forms(frm_name)
                print(f"Breite: {form.Width} twips ({form.Width/567:.1f} cm)")
                print(f"Höhe: {form.Section(0).Height} twips (Detail)")
                bridge.access_app.DoCmd.Close(2, frm_name, 2)
            except Exception as e:
                print(f"Fehler: {e}")

print("\n[FERTIG]")

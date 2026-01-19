"""
Liste alle Controls in frm_MA_Mitarbeiterstamm mit 'excel' oder 'zeitkonto' im Namen
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    print("=" * 70)
    print("CONTROLS IN frm_MA_Mitarbeiterstamm")
    print("=" * 70)

    # Öffne Formular in Design-Modus
    try:
        bridge.access_app.DoCmd.OpenForm("frm_MA_Mitarbeiterstamm", 1)  # 1 = Design View
        import time
        time.sleep(1)

        form = bridge.access_app.Forms("frm_MA_Mitarbeiterstamm")

        print(f"\nAlle Controls mit 'btn' im Namen:")
        for ctrl in form.Controls:
            if "btn" in ctrl.Name.lower():
                print(f"  - {ctrl.Name}")

        print(f"\nAlle Controls mit 'excel' oder 'zeitkonto' im Namen:")
        for ctrl in form.Controls:
            if "excel" in ctrl.Name.lower() or "zeitkonto" in ctrl.Name.lower() or "zk" in ctrl.Name.lower():
                print(f"  - {ctrl.Name}")

        bridge.access_app.DoCmd.Close(2, "frm_MA_Mitarbeiterstamm", 2)  # 2 = ohne Speichern
    except Exception as e:
        print(f"Fehler: {e}")

    # Suche auch in allen Forms nach btn_N_excel
    print("\n" + "=" * 70)
    print("SUCHE IN ALLEN FORMULAREN NACH btn_N_excel...")
    print("=" * 70)

    for doc in bridge.access_app.CurrentProject.AllForms:
        try:
            bridge.access_app.DoCmd.OpenForm(doc.Name, 1)
            import time
            time.sleep(0.3)

            form = bridge.access_app.Forms(doc.Name)
            for ctrl in form.Controls:
                if "btn_n_excel" in ctrl.Name.lower():
                    print(f"  GEFUNDEN: {ctrl.Name} in Form {doc.Name}")

            bridge.access_app.DoCmd.Close(2, doc.Name, 2)
        except:
            pass

print("\n[FERTIG]")

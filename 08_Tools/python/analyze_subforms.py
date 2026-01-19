"""
Analysiere zsub_lstAuftrag und sub_ma_va_zuordnung
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("ANALYSE UNTERFORMULARE")
    print("=" * 70)

    # Analysiere zsub_lstAuftrag
    print("\n" + "=" * 70)
    print("zsub_lstAuftrag - STRUKTUR")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("zsub_lstAuftrag", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("zsub_lstAuftrag")

        print(f"RecordSource: {form.RecordSource}")
        print(f"DefaultView: {form.DefaultView}")
        print(f"Breite: {form.Width} twips")

        print("\nControls:")
        for ctrl in form.Controls:
            try:
                ctrl_type = ctrl.ControlType
                ctrl_source = ""
                try:
                    ctrl_source = ctrl.ControlSource
                except:
                    pass
                print(f"  {ctrl.Name} (Type:{ctrl_type}, Left:{ctrl.Left}, W:{ctrl.Width}, Source:{ctrl_source})")
            except Exception as e:
                print(f"  {ctrl.Name} - Fehler: {e}")

        bridge.access_app.DoCmd.Close(2, "zsub_lstAuftrag", 2)
    except Exception as e:
        print(f"Fehler: {e}")

    # Suche nach sub_ma_va_zuordnung
    print("\n" + "=" * 70)
    print("SUCHE sub_ma_va_zuordnung")
    print("=" * 70)

    forms_found = []
    for doc in bridge.access_app.CurrentProject.AllForms:
        if "zuordnung" in doc.Name.lower() or "zuo" in doc.Name.lower():
            forms_found.append(doc.Name)
            print(f"  - {doc.Name}")

    # Analysiere sub_MA_VA_Zuordnung falls vorhanden
    for frm_name in ["sub_MA_VA_Zuordnung", "sub_ma_va_zuordnung", "zsub_MA_VA_Zuordnung"]:
        try:
            print(f"\n--- {frm_name} ---")
            bridge.access_app.DoCmd.OpenForm(frm_name, 1)
            time.sleep(0.5)
            form = bridge.access_app.Forms(frm_name)

            print(f"RecordSource: {form.RecordSource}")

            print("\nControls:")
            for ctrl in form.Controls:
                try:
                    ctrl_type = ctrl.ControlType
                    ctrl_source = ""
                    try:
                        ctrl_source = ctrl.ControlSource
                    except:
                        pass
                    if ctrl_source:
                        print(f"  {ctrl.Name} -> {ctrl_source}")
                except:
                    pass

            bridge.access_app.DoCmd.Close(2, frm_name, 2)
            break
        except:
            pass

    # Prüfe die Abfrage hinter zsub_lstAuftrag
    print("\n" + "=" * 70)
    print("ABFRAGE-ANALYSE")
    print("=" * 70)

    # Hole RecordSource nochmal
    try:
        bridge.access_app.DoCmd.OpenForm("zsub_lstAuftrag", 1)
        form = bridge.access_app.Forms("zsub_lstAuftrag")
        rs = form.RecordSource
        bridge.access_app.DoCmd.Close(2, "zsub_lstAuftrag", 2)

        if rs:
            print(f"RecordSource: {rs}")
            # Prüfe ob es eine Abfrage ist
            for qdef in bridge.current_db.QueryDefs:
                if qdef.Name == rs:
                    print(f"\nSQL von {rs}:")
                    print(qdef.SQL[:2000])
                    break
    except Exception as e:
        print(f"Fehler: {e}")

print("\n[FERTIG]")

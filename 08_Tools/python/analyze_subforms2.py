"""
Analysiere zsub_lstAuftrag und sub_MA_VA_Zuordnung
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

    # Analysiere sub_MA_VA_Zuordnung
    print("\n" + "=" * 70)
    print("sub_MA_VA_Zuordnung - STRUKTUR")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("sub_MA_VA_Zuordnung", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("sub_MA_VA_Zuordnung")

        print(f"RecordSource: {form.RecordSource}")
        print(f"DefaultView: {form.DefaultView}")
        print(f"Breite: {form.Width} twips")

        print("\nControls mit ControlSource:")
        for ctrl in form.Controls:
            try:
                ctrl_type = ctrl.ControlType
                ctrl_source = ""
                try:
                    ctrl_source = ctrl.ControlSource
                except:
                    pass
                if ctrl_source or ctrl_type == 109:  # TextBox
                    print(f"  {ctrl.Name} (Type:{ctrl_type}, Left:{ctrl.Left}, W:{ctrl.Width}, Source:{ctrl_source})")
            except:
                pass

        bridge.access_app.DoCmd.Close(2, "sub_MA_VA_Zuordnung", 2)
    except Exception as e:
        print(f"Fehler sub_MA_VA_Zuordnung: {e}")

    # Prüfe die Abfrage qry_N_DP_Auftraege_Liste
    print("\n" + "=" * 70)
    print("ABFRAGE qry_N_DP_Auftraege_Liste")
    print("=" * 70)

    try:
        for qdef in bridge.current_db.QueryDefs:
            if qdef.Name == "qry_N_DP_Auftraege_Liste":
                print(f"SQL:")
                print(qdef.SQL)
                break
    except Exception as e:
        print(f"Fehler: {e}")

    # Suche nach Feldern Einsatzleitung und Information in Abfragen
    print("\n" + "=" * 70)
    print("SUCHE NACH Einsatzleitung/Information FELDERN")
    print("=" * 70)

    try:
        for qdef in bridge.current_db.QueryDefs:
            sql_lower = qdef.SQL.lower()
            if "einsatzleitung" in sql_lower or "information" in sql_lower:
                print(f"\n{qdef.Name}:")
                print(qdef.SQL[:500])
                if len(qdef.SQL) > 500:
                    print("...")
    except Exception as e:
        print(f"Fehler: {e}")

print("\n[FERTIG]")

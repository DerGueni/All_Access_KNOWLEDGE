"""
Prüfe die Abfrage-Struktur und erweitere bei Bedarf
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("PRÜFE TABELLENSTRUKTUR")
    print("=" * 70)

    # Prüfe Felder in tbl_VA_Auftragstamm (hat evtl. Einsatzleitung direkt)
    print("\nFelder in tbl_VA_Auftragstamm:")
    for tdef in bridge.current_db.TableDefs:
        if tdef.Name == "tbl_VA_Auftragstamm":
            for fld in tdef.Fields:
                if "einsatz" in fld.Name.lower() or "info" in fld.Name.lower() or "leitung" in fld.Name.lower():
                    print(f"  - {fld.Name} ({fld.Type})")

    # Prüfe Felder in tbl_VA_AnzTage
    print("\nFelder in tbl_VA_AnzTage:")
    for tdef in bridge.current_db.TableDefs:
        if tdef.Name == "tbl_VA_AnzTage":
            for fld in tdef.Fields:
                print(f"  - {fld.Name} ({fld.Type})")

    # Verifiziere das Formular
    print("\n" + "=" * 70)
    print("VERIFIZIERE zsub_lstAuftrag")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("zsub_lstAuftrag", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("zsub_lstAuftrag")

        print(f"RecordSource: {form.RecordSource}")
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
                print(f"  {ctrl.Name} (Type:{ctrl_type}, Left:{ctrl.Left}, W:{ctrl.Width}, Source:'{ctrl_source}')")
            except:
                pass

        bridge.access_app.DoCmd.Close(2, "zsub_lstAuftrag", 2)
    except Exception as e:
        print(f"Fehler: {e}")

print("\n[FERTIG]")

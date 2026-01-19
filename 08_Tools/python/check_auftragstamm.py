"""
Prüfe alle Felder in tbl_VA_Auftragstamm
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    print("=" * 70)
    print("ALLE FELDER IN tbl_VA_Auftragstamm")
    print("=" * 70)

    for tdef in bridge.current_db.TableDefs:
        if tdef.Name == "tbl_VA_Auftragstamm":
            for fld in tdef.Fields:
                print(f"  - {fld.Name} (Type:{fld.Type})")

    print("\n" + "=" * 70)
    print("ALLE FELDER IN tbl_MA_VA_Zuordnung")
    print("=" * 70)

    for tdef in bridge.current_db.TableDefs:
        if tdef.Name == "tbl_MA_VA_Zuordnung":
            for fld in tdef.Fields:
                print(f"  - {fld.Name} (Type:{fld.Type})")

print("\n[FERTIG]")

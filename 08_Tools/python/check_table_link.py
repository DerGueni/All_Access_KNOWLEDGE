"""
Prüfe ob die Tabelle verknüpft ist und ob sie bearbeitbar ist
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("PRÜFE TABELLENVERKNÜPFUNG")
    print("=" * 70)

    # Prüfe tbl_MA_VA_Zuordnung
    for tdef in bridge.current_db.TableDefs:
        if tdef.Name == "tbl_MA_VA_Zuordnung":
            print(f"\nTabelle: {tdef.Name}")
            print(f"  Connect: {tdef.Connect}")
            print(f"  SourceTableName: {tdef.SourceTableName}")
            print(f"  Updatable: {tdef.Updatable}")
            print(f"  Attributes: {tdef.Attributes}")
            break

    # Versuche einen direkten Test mit der Tabelle
    print("\n" + "=" * 70)
    print("TESTE DIREKTEN ZUGRIFF AUF TABELLE")
    print("=" * 70)

    try:
        rs = bridge.current_db.OpenRecordset("tbl_MA_VA_Zuordnung", 2)  # dbOpenDynaset
        print(f"Recordset geöffnet")
        print(f"  Updatable: {rs.Updatable}")
        print(f"  RecordCount: {rs.RecordCount}")

        if rs.RecordCount > 0:
            rs.MoveFirst()
            print(f"  Erster Datensatz ID: {rs.Fields('ID').Value}")
            print(f"  Field 'Bemerkungen' Updatable: Teste Edit...")

            try:
                rs.Edit()
                print(f"    -> Edit erfolgreich!")
                rs.CancelUpdate()
            except Exception as e:
                print(f"    -> Edit FEHLGESCHLAGEN: {e}")

        rs.Close()

    except Exception as e:
        print(f"Fehler: {e}")
        import traceback
        traceback.print_exc()

    # Teste auch die Abfrage direkt
    print("\n" + "=" * 70)
    print("TESTE DIREKTEN ZUGRIFF AUF ABFRAGE")
    print("=" * 70)

    try:
        rs = bridge.current_db.OpenRecordset("qry_N_DP_Einsatzliste", 2)
        print(f"Recordset geöffnet")
        print(f"  Updatable: {rs.Updatable}")

        if rs.RecordCount > 0:
            rs.MoveFirst()
            print(f"  Teste Edit auf Abfrage...")

            try:
                rs.Edit()
                print(f"    -> Edit erfolgreich!")
                rs.CancelUpdate()
            except Exception as e:
                print(f"    -> Edit FEHLGESCHLAGEN: {e}")

        rs.Close()

    except Exception as e:
        print(f"Fehler: {e}")

print("\n[FERTIG]")

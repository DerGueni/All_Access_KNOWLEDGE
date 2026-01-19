"""
Öffne das Formular zsub_N_DP_Einsatzliste direkt und teste Bearbeitung
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("TESTE FORMULAR DIREKT (NICHT ALS UNTERFORMULAR)")
    print("=" * 70)

    try:
        # Öffne das Formular direkt in Normalansicht
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 0)  # acNormal
        time.sleep(1)

        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        print(f"\nFormular-Eigenschaften:")
        print(f"  RecordSource: {form.RecordSource}")
        print(f"  AllowEdits: {form.AllowEdits}")
        print(f"  AllowAdditions: {form.AllowAdditions}")
        print(f"  RecordsetType: {form.RecordsetType}")
        print(f"  DataEntry: {form.DataEntry}")

        print(f"\nRecordset-Info:")
        rs = form.Recordset
        print(f"  RecordCount: {rs.RecordCount}")
        print(f"  Updatable: {rs.Updatable}")
        print(f"  BOF: {rs.BOF}")
        print(f"  EOF: {rs.EOF}")

        if not rs.EOF and not rs.BOF:
            print(f"\nTeste Edit im Formular-Recordset...")
            try:
                rs.Edit()
                print(f"  -> Edit erfolgreich!")
                rs.CancelUpdate()
            except Exception as e:
                print(f"  -> Edit FEHLGESCHLAGEN: {e}")

        # Lasse das Formular kurz offen
        print("\nFormular ist jetzt offen - bitte manuell testen ob Bearbeitung möglich ist")
        print("Drücke Enter zum Schließen...")

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)

    except Exception as e:
        print(f"Fehler: {e}")
        import traceback
        traceback.print_exc()

print("\n[FERTIG]")

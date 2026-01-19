"""
Beschränke MA-ComboBox auf Anstellungsart_ID 3 und 5
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("FILTER COMBOBOX AUF ANSTELLUNGSART 3 UND 5")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)  # Design
        time.sleep(0.5)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        for ctrl in form.Controls:
            if ctrl.Name == "cboMA_ID":
                print(f"Alte RowSource: {ctrl.RowSource}")

                # Neue RowSource mit Filter auf Anstellungsart_ID 3 und 5
                new_rowsource = "SELECT ID, Nachname & ' ' & Vorname AS Name FROM tbl_MA_Mitarbeiterstamm WHERE IstAktiv = True AND Anstellungsart_ID IN (3, 5) ORDER BY Nachname, Vorname"
                ctrl.RowSource = new_rowsource

                print(f"Neue RowSource: {ctrl.RowSource}")
                break

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)
        print("\n[OK] Gespeichert!")

    except Exception as e:
        print(f"Fehler: {e}")
        try:
            bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
        except:
            pass

print("\n[FERTIG]")

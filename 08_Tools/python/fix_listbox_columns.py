"""
Fix ListBox Spaltenbreiten fuer lst_MA_Auswahl
Das Problem: Spalten zeigen #Gelöscht statt der richtigen Werte
Loesung: ColumnWidths anpassen (in Twips: 1440 = 1 Inch)
"""
import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

from access_bridge_ultimate import AccessBridge
import time

print("=" * 70)
print("FIX LISTBOX SPALTENBREITEN")
print("=" * 70)

try:
    with AccessBridge() as bridge:
        # frm_N_DP_Dashboard im Design-Modus oeffnen
        print("\n[1] Oeffne frm_N_DP_Dashboard im Design-Modus...")
        bridge.access_app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
        time.sleep(0.5)

        frm = bridge.access_app.Forms("frm_N_DP_Dashboard")

        # lst_MA_Auswahl finden
        for i in range(frm.Controls.Count):
            ctl = frm.Controls(i)
            if ctl.Name == "lst_MA_Auswahl":
                print(f"\n[2] Gefunden: lst_MA_Auswahl")
                print(f"    ControlType: {ctl.ControlType}")  # 110 = ListBox
                print(f"    ColumnCount: {ctl.ColumnCount}")
                print(f"    ColumnWidths: {ctl.ColumnWidths}")
                print(f"    RowSource: {ctl.RowSource}")
                print(f"    BoundColumn: {ctl.BoundColumn}")

                # Spaltenbreiten in Twips (1440 Twips = 1 Inch, ca. 567 Twips = 1 cm)
                # MA_ID (hidden), Name, von, bis
                # 0; 2500; 700; 700 (in Twips)
                ctl.ColumnCount = 4
                ctl.ColumnWidths = "0;2500;700;700"
                ctl.BoundColumn = 1

                print(f"\n    ColumnCount jetzt: 4")
                print(f"    ColumnWidths jetzt: 0;2500;700;700")
                print(f"    BoundColumn jetzt: 1")
                break

        bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)  # acSaveYes
        print("\n[OK] frm_N_DP_Dashboard gespeichert")

        print("\n" + "=" * 70)
        print("[OK] SPALTENBREITEN KORRIGIERT")
        print("=" * 70)

except Exception as e:
    print(f"\n[!] FEHLER: {e}")
    import traceback
    traceback.print_exc()

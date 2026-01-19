"""
Fix ListBox Spaltenbreiten - Version 2
"""
import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

from access_bridge_ultimate import AccessBridge
import time

print("=" * 70)
print("FIX LISTBOX SPALTENBREITEN V2")
print("=" * 70)

try:
    with AccessBridge() as bridge:
        # frm_N_DP_Dashboard im Design-Modus oeffnen
        print("\n[1] Oeffne frm_N_DP_Dashboard im Design-Modus...")

        # Falls offen, erst schliessen
        try:
            bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)  # acSaveNo
            time.sleep(0.3)
        except:
            pass

        bridge.access_app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
        time.sleep(0.5)

        frm = bridge.access_app.Forms("frm_N_DP_Dashboard")

        # lst_MA_Auswahl finden
        for i in range(frm.Controls.Count):
            ctl = frm.Controls(i)
            if ctl.Name == "lst_MA_Auswahl":
                print(f"\n[2] Gefunden: lst_MA_Auswahl")
                print(f"    ColumnCount: {ctl.ColumnCount}")
                print(f"    ColumnWidths: {ctl.ColumnWidths}")

                # Versuche die Eigenschaften zu setzen
                try:
                    ctl.ColumnCount = 4
                    print(f"    ColumnCount gesetzt: 4")
                except Exception as e:
                    print(f"    [!] ColumnCount Fehler: {e}")

                try:
                    ctl.ColumnWidths = "0;2500;700;700"
                    print(f"    ColumnWidths gesetzt: 0;2500;700;700")
                except Exception as e:
                    print(f"    [!] ColumnWidths Fehler: {e}")

                break

        # Versuche mit RunCommand zu speichern
        print("\n[3] Speichere mit RunCommand...")
        try:
            bridge.access_app.RunCommand(3)  # acCmdSave
            print("    [OK] Mit RunCommand gespeichert")
        except Exception as e:
            print(f"    [!] RunCommand Fehler: {e}")

        # Formular schliessen mit Speichern
        print("\n[4] Schliesse Formular...")
        try:
            bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)  # acSaveYes
            print("    [OK] Formular geschlossen und gespeichert")
        except Exception as e:
            print(f"    [!] Close Fehler: {e}")
            # Alternativ ohne Speichern schliessen
            try:
                bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard")
                print("    Formular geschlossen (ohne explizites Save)")
            except:
                pass

        print("\n" + "=" * 70)
        print("[INFO] Bitte Dashboard manuell oeffnen und pruefen!")
        print("=" * 70)

except Exception as e:
    print(f"\n[!] FEHLER: {e}")
    import traceback
    traceback.print_exc()

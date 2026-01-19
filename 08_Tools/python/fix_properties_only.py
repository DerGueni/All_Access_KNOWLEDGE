"""
Fix nur Formular-Eigenschaften - nachdem Hauptformular geschlossen
"""
import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

import win32com.client
import pythoncom
import time

print("=" * 70)
print("FIX FORMULAR-EIGENSCHAFTEN")
print("=" * 70)
print("\nBITTE ZUERST: Schliessen Sie das frm_N_DP_Dashboard Formular in Access!")
print("Dann druecken Sie Enter...")
input()

try:
    pythoncom.CoInitialize()

    app = win32com.client.GetObject(Class="Access.Application")
    print("[OK] Access verbunden")

    app.DoCmd.SetWarnings(False)

    # 1. Alle Dashboard-Formulare schliessen
    print("\n[1] Schliesse alle offenen Formulare...")
    for form_name in ["frm_N_DP_Dashboard", "zsub_N_DP_Einsatzliste", "zsub_lstAuftrag"]:
        try:
            app.DoCmd.Close(2, form_name, 2)  # acSaveNo
            print(f"    Geschlossen: {form_name}")
        except:
            pass

    time.sleep(1)

    # 2. Einsatzliste oeffnen und AllowEdits setzen
    print("\n[2] Oeffne zsub_N_DP_Einsatzliste im Design-Modus...")
    app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)  # acDesign
    time.sleep(0.5)

    frm = app.Forms("zsub_N_DP_Einsatzliste")
    print(f"    AllowEdits vorher: {frm.AllowEdits}")
    frm.AllowEdits = True
    frm.AllowAdditions = False
    frm.AllowDeletions = False
    print(f"    AllowEdits jetzt: True")

    app.RunCommand(3)  # acCmdSave
    app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)
    print("    [OK] Gespeichert")

    # 3. Hauptformular ListBox korrigieren
    print("\n[3] Oeffne frm_N_DP_Dashboard im Design-Modus...")
    app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
    time.sleep(0.5)

    frm = app.Forms("frm_N_DP_Dashboard")

    for i in range(frm.Controls.Count):
        ctl = frm.Controls(i)
        if ctl.Name == "lst_MA_Auswahl":
            print(f"    lst_MA_Auswahl gefunden")
            print(f"    ColumnCount vorher: {ctl.ColumnCount}")
            print(f"    ColumnWidths vorher: {ctl.ColumnWidths}")
            ctl.ColumnCount = 4
            ctl.ColumnWidths = "0;2800;600;600"
            print(f"    ColumnCount jetzt: 4")
            print(f"    ColumnWidths jetzt: 0;2800;600;600")
            break

    app.RunCommand(3)  # acCmdSave
    app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
    print("    [OK] Gespeichert")

    app.DoCmd.SetWarnings(True)

    print("\n" + "=" * 70)
    print("[OK] EIGENSCHAFTEN GESETZT!")
    print("=" * 70)
    print("\nJetzt bitte frm_N_DP_Dashboard neu oeffnen und testen.")

except Exception as e:
    print(f"\n[!] FEHLER: {e}")
    import traceback
    traceback.print_exc()

finally:
    pythoncom.CoUninitialize()

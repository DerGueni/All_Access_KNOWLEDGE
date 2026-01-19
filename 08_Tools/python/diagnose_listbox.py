"""
Diagnose Listbox Events - Warum funktioniert Doppelklick nicht?
"""
import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

import win32com.client
import pythoncom
import time

print("=" * 70)
print("DIAGNOSE LISTBOX EVENTS")
print("=" * 70)

try:
    pythoncom.CoInitialize()

    app = win32com.client.GetObject(Class="Access.Application")
    print("[OK] Access verbunden")

    # 1. Formular im Design-Modus öffnen
    print("\n[1] Schliesse und oeffne frm_N_DP_Dashboard im Design-Modus...")

    try:
        app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)
    except:
        pass
    time.sleep(0.5)

    app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
    time.sleep(0.5)

    frm = app.Forms("frm_N_DP_Dashboard")

    # 2. lstMA Listbox finden und Events prüfen
    print("\n[2] Analysiere lstMA Listbox...")

    for i in range(frm.Controls.Count):
        ctl = frm.Controls(i)
        if ctl.Name == "lstMA":
            print(f"    Name: {ctl.Name}")
            print(f"    ControlType: {ctl.ControlType}")  # 110 = ListBox

            # Event-Eigenschaften prüfen
            try:
                on_dbl_click = ctl.OnDblClick
                print(f"    OnDblClick: '{on_dbl_click}'")
            except Exception as e:
                print(f"    OnDblClick: FEHLER - {e}")

            try:
                on_click = ctl.OnClick
                print(f"    OnClick: '{on_click}'")
            except Exception as e:
                print(f"    OnClick: FEHLER - {e}")

            # Wenn OnDblClick leer ist, setzen wir es
            if not on_dbl_click or on_dbl_click == "":
                print("\n    [!] OnDblClick ist LEER - setze auf [Event Procedure]")
                ctl.OnDblClick = "[Event Procedure]"
                print("    [OK] OnDblClick gesetzt")

            break

    # 3. lst_MA_Auswahl auch prüfen
    print("\n[3] Analysiere lst_MA_Auswahl Listbox...")

    for i in range(frm.Controls.Count):
        ctl = frm.Controls(i)
        if ctl.Name == "lst_MA_Auswahl":
            print(f"    Name: {ctl.Name}")

            try:
                on_dbl_click = ctl.OnDblClick
                print(f"    OnDblClick: '{on_dbl_click}'")
            except Exception as e:
                print(f"    OnDblClick: FEHLER - {e}")

            if not on_dbl_click or on_dbl_click == "":
                print("\n    [!] OnDblClick ist LEER - setze auf [Event Procedure]")
                ctl.OnDblClick = "[Event Procedure]"
                print("    [OK] OnDblClick gesetzt")

            break

    # 4. Formular-Modul prüfen
    print("\n[4] Pruefe Formular-Modul...")

    vbe = app.VBE
    proj = vbe.ActiveVBProject

    form_module_found = False
    for comp in proj.VBComponents:
        # Suche nach dem richtigen Form-Modul
        if "frm_N_DP_Dashboard" in comp.Name or "frm_N_DB_Dashboard" in comp.Name:
            print(f"    Gefunden: {comp.Name} (Type: {comp.Type})")
            cm = comp.CodeModule
            if cm.CountOfLines > 0:
                code = cm.Lines(1, cm.CountOfLines)
                print(f"    Code-Zeilen: {cm.CountOfLines}")

                # Prüfe ob lstMA_DblClick existiert
                if "lstMA_DblClick" in code:
                    print("    [OK] lstMA_DblClick vorhanden")
                else:
                    print("    [!] lstMA_DblClick FEHLT!")

                if "lst_MA_Auswahl_DblClick" in code:
                    print("    [OK] lst_MA_Auswahl_DblClick vorhanden")
                else:
                    print("    [!] lst_MA_Auswahl_DblClick FEHLT!")

            form_module_found = True

    if not form_module_found:
        print("    [!] Kein passendes Form-Modul gefunden!")

    # 5. Speichern
    print("\n[5] Speichere Formular...")
    app.RunCommand(3)  # acCmdSave
    app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
    print("    [OK] Gespeichert")

    print("\n" + "=" * 70)
    print("DIAGNOSE ABGESCHLOSSEN")
    print("=" * 70)

except Exception as e:
    print(f"\n[!] FEHLER: {e}")
    import traceback
    traceback.print_exc()

finally:
    pythoncom.CoUninitialize()

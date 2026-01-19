"""
Diagnose Dashboard - Analysiert die aktuellen Einstellungen
"""
import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

from access_bridge_ultimate import AccessBridge
import time

print("=" * 70)
print("DASHBOARD DIAGNOSE")
print("=" * 70)

try:
    with AccessBridge() as bridge:
        # 1. Hauptformular analysieren
        print("\n[1] HAUPTFORMULAR frm_N_DP_Dashboard")
        print("-" * 50)

        try:
            bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)
            time.sleep(0.3)
        except:
            pass

        bridge.access_app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
        time.sleep(0.5)
        frm = bridge.access_app.Forms("frm_N_DP_Dashboard")

        print(f"  RecordSource: {frm.RecordSource}")
        print(f"  AllowEdits: {frm.AllowEdits}")
        print(f"  AllowAdditions: {frm.AllowAdditions}")

        # Controls auflisten
        print("\n  Controls:")
        for i in range(frm.Controls.Count):
            ctl = frm.Controls(i)
            try:
                ct = ctl.ControlType
                if ct == 112:  # Subform
                    print(f"    [{ctl.Name}] SUBFORM -> SourceObject: {ctl.SourceObject}")
                elif ct == 110:  # ListBox
                    print(f"    [{ctl.Name}] LISTBOX")
                    print(f"      RowSource: {ctl.RowSource[:100] if ctl.RowSource else 'LEER'}...")
                    print(f"      ColumnCount: {ctl.ColumnCount}")
                    print(f"      ColumnWidths: {ctl.ColumnWidths}")
                elif ct == 104:  # Button
                    print(f"    [{ctl.Name}] BUTTON -> OnClick: {getattr(ctl, 'OnClick', 'N/A')}")
            except:
                pass

        bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)
        time.sleep(0.3)

        # 2. Einsatzliste Unterformular analysieren
        print("\n[2] UNTERFORMULAR zsub_N_DP_Einsatzliste")
        print("-" * 50)

        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        time.sleep(0.5)
        frm = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        print(f"  RecordSource: {frm.RecordSource}")
        print(f"  AllowEdits: {frm.AllowEdits}")
        print(f"  AllowAdditions: {frm.AllowAdditions}")
        print(f"  AllowDeletions: {frm.AllowDeletions}")
        print(f"  DataEntry: {frm.DataEntry}")
        print(f"  RecordsetType: {frm.RecordsetType}")

        # Hat das Formular Code?
        print(f"\n  Form Module:")
        try:
            vbe = bridge.access_app.VBE
            proj = vbe.ActiveVBProject
            for comp in proj.VBComponents:
                if comp.Name == "Form_zsub_N_DP_Einsatzliste":
                    code_module = comp.CodeModule
                    if code_module.CountOfLines > 0:
                        code = code_module.Lines(1, code_module.CountOfLines)
                        print(f"  VBA Code ({code_module.CountOfLines} Zeilen):")
                        print("-" * 40)
                        print(code)
                        print("-" * 40)
                    break
        except Exception as e:
            print(f"  [!] VBA-Fehler: {e}")

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)

        # 3. VBA Modul pruefen
        print("\n[3] VBA MODUL mod_N_DP_Dashboard")
        print("-" * 50)

        try:
            vbe = bridge.access_app.VBE
            proj = vbe.ActiveVBProject
            for comp in proj.VBComponents:
                if comp.Name == "mod_N_DP_Dashboard":
                    code_module = comp.CodeModule
                    if code_module.CountOfLines > 0:
                        # Nur die ersten 100 Zeilen
                        lines = min(100, code_module.CountOfLines)
                        code = code_module.Lines(1, lines)
                        print(f"  Erste {lines} Zeilen:")
                        print("-" * 40)
                        print(code)
                        print("-" * 40)
                    break
        except Exception as e:
            print(f"  [!] VBA-Fehler: {e}")

        # 4. Hauptformular Code pruefen
        print("\n[4] HAUPTFORMULAR CODE Form_frm_N_DP_Dashboard")
        print("-" * 50)

        try:
            for comp in proj.VBComponents:
                if "frm_N_DP_Dashboard" in comp.Name or "frm_N_DB_Dashboard" in comp.Name:
                    code_module = comp.CodeModule
                    if code_module.CountOfLines > 0:
                        code = code_module.Lines(1, code_module.CountOfLines)
                        print(f"  {comp.Name} ({code_module.CountOfLines} Zeilen):")
                        print("-" * 40)
                        print(code)
                        print("-" * 40)
        except Exception as e:
            print(f"  [!] VBA-Fehler: {e}")

except Exception as e:
    print(f"\n[!] FEHLER: {e}")
    import traceback
    traceback.print_exc()

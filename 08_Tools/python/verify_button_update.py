"""
Verifiziere den aktualisierten btn_N_ExcelOeffnen Button
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    print("=" * 70)
    print("VERIFIZIERE btn_N_ExcelOeffnen_Click")
    print("=" * 70)

    vbe = bridge.access_app.VBE
    proj = vbe.ActiveVBProject

    for comp in proj.VBComponents:
        if comp.Name == "Form_frm_MA_Mitarbeiterstamm":
            code_module = comp.CodeModule
            total_lines = code_module.CountOfLines

            # Finde und zeige die Funktion
            in_function = False
            for i in range(1, total_lines + 1):
                line = code_module.Lines(i, 1)
                if "Sub btn_N_ExcelOeffnen_Click" in line:
                    in_function = True
                    print(f"\n{'='*70}")
                    print(f"btn_N_ExcelOeffnen_Click (ab Zeile {i})")
                    print(f"{'='*70}")

                if in_function:
                    print(f"{i}: {line}")
                    if line.strip() == "End Sub":
                        break

            break

print("\n[FERTIG]")

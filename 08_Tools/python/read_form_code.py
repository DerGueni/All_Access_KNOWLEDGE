"""
Lese den vollständigen Code von Form_frm_MA_Mitarbeiterstamm
und suche nach dem Excel-Öffnen Code
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    print("=" * 70)
    print("CODE VON Form_frm_MA_Mitarbeiterstamm")
    print("=" * 70)

    vbe = bridge.access_app.VBE
    proj = vbe.ActiveVBProject

    for comp in proj.VBComponents:
        if comp.Name == "Form_frm_MA_Mitarbeiterstamm":
            code_module = comp.CodeModule
            if code_module.CountOfLines > 0:
                code = code_module.Lines(1, code_module.CountOfLines)

                # Finde die btnZeitkonto_Click Funktion
                lines = code.split('\n')
                in_function = False
                function_code = []

                for i, line in enumerate(lines):
                    if "Sub btnZeitkonto_Click" in line:
                        in_function = True
                        print(f"\n{'='*70}")
                        print(f"btnZeitkonto_Click (ab Zeile {i+1})")
                        print(f"{'='*70}")

                    if in_function:
                        print(f"{i+1}: {line}")
                        if line.strip() == "End Sub":
                            in_function = False
                            print()
                            break

print("\n[FERTIG]")

"""
Finde die Funktion DP_Mitarbeiter_Anfragen
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    print("=" * 70)
    print("SUCHE FUNKTION DP_Mitarbeiter_Anfragen")
    print("=" * 70)

    vbe = bridge.access_app.VBE
    proj = vbe.ActiveVBProject

    for comp in proj.VBComponents:
        code_module = comp.CodeModule
        if code_module.CountOfLines > 0:
            code = code_module.Lines(1, code_module.CountOfLines)
            if "Sub DP_Mitarbeiter_Anfragen" in code or "Function DP_Mitarbeiter_Anfragen" in code:
                print(f"\n{'='*70}")
                print(f"GEFUNDEN IN: {comp.Name}")
                print(f"{'='*70}")

                # Finde die Funktion und zeige sie komplett
                lines = code.split('\n')
                in_function = False
                for i, line in enumerate(lines):
                    if "DP_Mitarbeiter_Anfragen" in line and ("Sub " in line or "Function " in line):
                        in_function = True
                        print(f"\nAb Zeile {i+1}:")

                    if in_function:
                        print(f"{i+1}: {line}")
                        if line.strip() == "End Sub" or line.strip() == "End Function":
                            break

print("\n[FERTIG]")

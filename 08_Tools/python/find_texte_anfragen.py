"""
Finde die Funktionen Texte_lesen und Anfragen
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    print("=" * 70)
    print("SUCHE FUNKTIONEN Texte_lesen UND Anfragen")
    print("=" * 70)

    vbe = bridge.access_app.VBE
    proj = vbe.ActiveVBProject

    for comp in proj.VBComponents:
        code_module = comp.CodeModule
        if code_module.CountOfLines > 0:
            code = code_module.Lines(1, code_module.CountOfLines)

            # Suche nach Texte_lesen
            if "Sub Texte_lesen" in code or "Function Texte_lesen" in code:
                print(f"\n{'='*70}")
                print(f"Texte_lesen GEFUNDEN IN: {comp.Name}")
                print(f"{'='*70}")

                lines = code.split('\n')
                in_function = False
                for i, line in enumerate(lines):
                    if "Texte_lesen" in line and ("Sub " in line or "Function " in line):
                        in_function = True
                        print(f"\nAb Zeile {i+1}:")

                    if in_function:
                        print(f"{i+1}: {line}")
                        if line.strip() == "End Sub" or line.strip() == "End Function":
                            in_function = False
                            print()

            # Suche nach Anfragen (als eigenständige Sub)
            if "Sub Anfragen()" in code or "Public Sub Anfragen" in code:
                print(f"\n{'='*70}")
                print(f"Anfragen GEFUNDEN IN: {comp.Name}")
                print(f"{'='*70}")

                lines = code.split('\n')
                in_function = False
                for i, line in enumerate(lines):
                    if ("Sub Anfragen()" in line or "Public Sub Anfragen" in line) and "End Sub" not in line:
                        in_function = True
                        print(f"\nAb Zeile {i+1}:")

                    if in_function:
                        print(f"{i+1}: {line}")
                        if line.strip() == "End Sub":
                            break

print("\n[FERTIG]")

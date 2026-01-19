"""
Suche nach allen Excel-bezogenen Button-Funktionen
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    print("=" * 70)
    print("SUCHE NACH ALLEN EXCEL/ZEITKONTO BUTTON-FUNKTIONEN")
    print("=" * 70)

    vbe = bridge.access_app.VBE
    proj = vbe.ActiveVBProject

    for comp in proj.VBComponents:
        code_module = comp.CodeModule
        if code_module.CountOfLines > 0:
            code = code_module.Lines(1, code_module.CountOfLines)

            # Suche nach Sub-Funktionen die "excel" im Namen haben
            lines = code.split('\n')
            for i, line in enumerate(lines):
                if "sub " in line.lower() and "excel" in line.lower() and "click" in line.lower():
                    print(f"\nGEFUNDEN in {comp.Name}:")
                    # Zeige 30 Zeilen ab der Funktion
                    end = min(len(lines), i + 40)
                    for j in range(i, end):
                        print(f"{j+1}: {lines[j]}")
                        if lines[j].strip().lower() == "end sub":
                            break
                    print("-" * 70)

print("\n[FERTIG]")

"""
Zeige den vollständigen Code von mod_N_DP_Dashboard und die Anfragen-Funktion
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    print("=" * 70)
    print("PRÜFE mod_N_DP_Dashboard UND zmd_Mail.Anfragen")
    print("=" * 70)

    vbe = bridge.access_app.VBE
    proj = vbe.ActiveVBProject

    # Suche nach der Anfragen Sub in zmd_Mail
    for comp in proj.VBComponents:
        if comp.Name == "zmd_Mail":
            code_module = comp.CodeModule
            code = code_module.Lines(1, code_module.CountOfLines)

            # Suche nach "Sub Anfragen" oder "Public Sub Anfragen"
            lines = code.split('\n')
            for i, line in enumerate(lines):
                if "Sub Anfragen" in line and "End Sub" not in line:
                    print(f"\n{'='*70}")
                    print(f"Anfragen in zmd_Mail (Zeile {i+1}):")
                    print(f"{'='*70}")
                    # Zeige die Funktion
                    for j in range(i, min(len(lines), i+50)):
                        print(f"{j+1}: {lines[j]}")
                        if lines[j].strip() == "End Sub":
                            break
                    break
            break

    # Zeige auch die relevanten Modulvariablen
    print("\n" + "=" * 70)
    print("MODULVARIABLEN IN mod_N_DP_Dashboard")
    print("=" * 70)

    for comp in proj.VBComponents:
        if comp.Name == "mod_N_DP_Dashboard":
            code_module = comp.CodeModule
            code = code_module.Lines(1, min(50, code_module.CountOfLines))
            print(code)
            break

print("\n[FERTIG]")

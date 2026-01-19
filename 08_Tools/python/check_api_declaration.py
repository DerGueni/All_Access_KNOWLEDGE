"""
Prüfe ob GetSystemMetrics32 API-Deklaration vorhanden ist
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    print("=" * 70)
    print("PRÜFE API-DEKLARATION GetSystemMetrics32")
    print("=" * 70)

    vbe = bridge.access_app.VBE
    proj = vbe.ActiveVBProject

    found = False
    found_in = []

    for comp in proj.VBComponents:
        code_module = comp.CodeModule
        if code_module.CountOfLines > 0:
            code = code_module.Lines(1, code_module.CountOfLines)
            if "getsystemmetrics" in code.lower():
                found = True
                found_in.append(comp.Name)
                print(f"\nGefunden in: {comp.Name}")
                lines = code.split('\n')
                for i, line in enumerate(lines):
                    if "getsystemmetrics" in line.lower():
                        print(f"  Zeile {i+1}: {line}")

    if not found:
        print("\n[!] GetSystemMetrics32 NICHT gefunden!")
        print("    Muss zum Form-Modul hinzugefügt werden.")
    else:
        print(f"\n[OK] Gefunden in: {', '.join(found_in)}")

print("\n[FERTIG]")

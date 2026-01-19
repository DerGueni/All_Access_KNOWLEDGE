"""
Finde den Code für cmd_MA_Anfragen Button
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    print("=" * 70)
    print("SUCHE CODE FÜR cmd_MA_Anfragen")
    print("=" * 70)

    vbe = bridge.access_app.VBE
    proj = vbe.ActiveVBProject

    # Suche in allen Modulen nach cmd_MA_Anfragen oder MA_Anfragen
    for comp in proj.VBComponents:
        code_module = comp.CodeModule
        if code_module.CountOfLines > 0:
            code = code_module.Lines(1, code_module.CountOfLines)
            if "cmd_MA_Anfragen" in code or "MA_Anfragen" in code.replace(" ", ""):
                print(f"\n{'='*70}")
                print(f"GEFUNDEN IN: {comp.Name}")
                print(f"{'='*70}")

                # Zeige relevante Zeilen
                lines = code.split('\n')
                for i, line in enumerate(lines):
                    if "anfragen" in line.lower() or "cmd_ma" in line.lower():
                        # Zeige Kontext
                        start = max(0, i - 2)
                        end = min(len(lines), i + 30)
                        print(f"\n... Zeilen {start+1}-{end} ...")
                        for j in range(start, end):
                            print(f"{j+1}: {lines[j]}")
                        print()
                        break

print("\n[FERTIG]")

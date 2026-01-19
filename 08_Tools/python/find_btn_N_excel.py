"""
Suche spezifisch nach btn_N_excelOeffnen im Code
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    print("=" * 70)
    print("SUCHE NACH btn_N_excelOeffnen und PfadZK")
    print("=" * 70)

    vbe = bridge.access_app.VBE
    proj = vbe.ActiveVBProject

    # Durchsuche alle Module nach btn_N_excel
    for comp in proj.VBComponents:
        code_module = comp.CodeModule
        if code_module.CountOfLines > 0:
            code = code_module.Lines(1, code_module.CountOfLines)
            if "btn_N_excel" in code.lower():
                print(f"\n{'='*70}")
                print(f"GEFUNDEN IN: {comp.Name} (Type: {comp.Type})")
                print(f"{'='*70}")
                print(code)
                print("-" * 70)

    # Suche nach PfadZK
    print("\n" + "=" * 70)
    print("SUCHE NACH PfadZK Definition...")
    print("=" * 70)

    for comp in proj.VBComponents:
        code_module = comp.CodeModule
        if code_module.CountOfLines > 0:
            code = code_module.Lines(1, code_module.CountOfLines)
            if "pfadzk" in code.lower() and ("function" in code.lower() or "public" in code.lower() or "property" in code.lower()):
                print(f"\n{'='*70}")
                print(f"PFADZK in: {comp.Name}")
                print(f"{'='*70}")
                # Zeige nur relevante Teile
                lines = code.split('\n')
                for i, line in enumerate(lines):
                    if 'pfadzk' in line.lower():
                        # Zeige Kontext (10 Zeilen vorher und nachher)
                        start = max(0, i - 5)
                        end = min(len(lines), i + 15)
                        print(f"\n... Zeilen {start+1}-{end} ...")
                        for j in range(start, end):
                            print(f"{j+1}: {lines[j]}")
                        print()

print("\n[FERTIG]")

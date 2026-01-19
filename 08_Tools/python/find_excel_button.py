"""
Suche nach dem btn_N_excelOeffnen Button-Code in den VBA-Modulen
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    print("=" * 70)
    print("SUCHE NACH btn_N_excelOeffnen")
    print("=" * 70)

    # Liste alle Module
    modules = bridge.list_modules()
    print(f"\nGefundene Module ({len(modules)}):")
    for m in modules:
        print(f"  - {m}")

    # Durchsuche alle Module nach dem Button-Code
    vbe = bridge.access_app.VBE
    proj = vbe.ActiveVBProject

    print("\n" + "=" * 70)
    print("DURCHSUCHE MODULE NACH 'excel' und 'zeitkonto'...")
    print("=" * 70)

    for comp in proj.VBComponents:
        if comp.Type == 1:  # Standard Module
            code_module = comp.CodeModule
            if code_module.CountOfLines > 0:
                code = code_module.Lines(1, code_module.CountOfLines)
                # Suche nach relevanten Keywords
                if "excel" in code.lower() or "zeitkonto" in code.lower() or "btn_N_excel" in code.lower():
                    print(f"\n{'='*70}")
                    print(f"MODUL: {comp.Name}")
                    print(f"{'='*70}")
                    print(code[:5000] if len(code) > 5000 else code)
                    print("-" * 70)

    # Suche auch in Form-Modulen
    print("\n" + "=" * 70)
    print("DURCHSUCHE FORM-MODULE...")
    print("=" * 70)

    for comp in proj.VBComponents:
        if comp.Type == 100:  # Form Module
            code_module = comp.CodeModule
            if code_module.CountOfLines > 0:
                code = code_module.Lines(1, code_module.CountOfLines)
                if "excel" in code.lower() or "zeitkonto" in code.lower():
                    print(f"\n{'='*70}")
                    print(f"FORM-MODUL: {comp.Name}")
                    print(f"{'='*70}")
                    print(code[:5000] if len(code) > 5000 else code)
                    print("-" * 70)

print("\n[FERTIG]")

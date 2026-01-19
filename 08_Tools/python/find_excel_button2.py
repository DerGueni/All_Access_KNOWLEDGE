"""
Suche spezifisch nach dem btn_N_excelOeffnen Button-Code
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    print("=" * 70)
    print("SUCHE NACH btn_N_excelOeffnen CODE")
    print("=" * 70)

    vbe = bridge.access_app.VBE
    proj = vbe.ActiveVBProject

    # Durchsuche spezifisch mod_N_MA_Zeitkonto
    for comp in proj.VBComponents:
        if "zeitkonto" in comp.Name.lower() or "ma_zeitkonto" in comp.Name.lower():
            code_module = comp.CodeModule
            if code_module.CountOfLines > 0:
                code = code_module.Lines(1, code_module.CountOfLines)
                print(f"\n{'='*70}")
                print(f"MODUL: {comp.Name} (Type: {comp.Type})")
                print(f"{'='*70}")
                print(code)
                print("-" * 70)

    # Durchsuche auch Form-Module nach dem Button
    print("\n" + "=" * 70)
    print("SUCHE IN FORM-MODULEN NACH btn_N_excel...")
    print("=" * 70)

    for comp in proj.VBComponents:
        if comp.Type == 100:  # Form Module
            code_module = comp.CodeModule
            if code_module.CountOfLines > 0:
                code = code_module.Lines(1, code_module.CountOfLines)
                if "btn_N_excel" in code.lower() or "exceloeffnen" in code.lower():
                    print(f"\n{'='*70}")
                    print(f"FORM-MODUL: {comp.Name}")
                    print(f"{'='*70}")
                    print(code)
                    print("-" * 70)

    # Suche auch in allen Standard-Modulen nach dem Button
    print("\n" + "=" * 70)
    print("SUCHE IN ALLEN MODULEN NACH btn_N_excel...")
    print("=" * 70)

    for comp in proj.VBComponents:
        if comp.Type == 1:  # Standard Module
            code_module = comp.CodeModule
            if code_module.CountOfLines > 0:
                code = code_module.Lines(1, code_module.CountOfLines)
                if "btn_N_excel" in code.lower() or "exceloeffnen" in code.lower():
                    print(f"\n{'='*70}")
                    print(f"MODUL: {comp.Name}")
                    print(f"{'='*70}")
                    print(code)
                    print("-" * 70)

print("\n[FERTIG]")

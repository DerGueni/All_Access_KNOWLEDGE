#!/usr/bin/env python3
"""
Findet alle Module die Get_Priv_Property DEFINIEREN (nicht nur aufrufen)
"""

import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")
from access_bridge_ultimate import AccessBridge

def main():
    print("=" * 70)
    print("SUCHE Get_Priv_Property DEFINITIONEN")
    print("=" * 70)
    print()

    try:
        with AccessBridge() as bridge:
            print("Access Bridge verbunden.\n")

            vba_project = bridge.access_app.VBE.ActiveVBProject
            definitions = []

            for component in vba_project.VBComponents:
                try:
                    code_module = component.CodeModule
                    line_count = code_module.CountOfLines

                    if line_count > 0:
                        code = code_module.Lines(1, line_count)

                        # Suche nach DEFINITION (nicht Aufruf)
                        for i, line in enumerate(code.split('\n'), 1):
                            # Function oder Property Get Definition
                            if ("Function Get_Priv_Property" in line or
                                "Property Get Get_Priv_Property" in line):
                                if "'" not in line[:line.find("Get_Priv_Property")]:  # Nicht auskommentiert
                                    definitions.append((component.Name, i, line.strip()))
                                    print(f"DEFINITION in: {component.Name}")
                                    print(f"  Zeile {i}: {line.strip()}")
                                    print()

                except Exception as e:
                    pass

            print()
            print("=" * 70)
            if len(definitions) > 1:
                print(f"DUPLIKAT GEFUNDEN! {len(definitions)} Definitionen:")
                for name, line, code in definitions:
                    print(f"  - {name} (Zeile {line})")
            elif len(definitions) == 1:
                print(f"Nur 1 Definition gefunden: {definitions[0][0]}")
                print("Kein Duplikat-Problem.")
            else:
                print("Keine Definition gefunden!")
            print("=" * 70)

    except Exception as e:
        print(f"\nFEHLER: {e}")
        import traceback
        traceback.print_exc()
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())

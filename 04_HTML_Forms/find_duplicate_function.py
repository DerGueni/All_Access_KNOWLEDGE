#!/usr/bin/env python3
"""
Sucht nach doppelten Funktionen/Properties in VBA-Modulen
"""

import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")
from access_bridge_ultimate import AccessBridge

SEARCH_NAME = "Get_Priv_Property"

def main():
    print("=" * 70)
    print(f"SUCHE NACH: {SEARCH_NAME}")
    print("=" * 70)
    print()

    try:
        with AccessBridge() as bridge:
            print("Access Bridge verbunden.\n")

            vba_project = bridge.access_app.VBE.ActiveVBProject
            found_in = []

            for component in vba_project.VBComponents:
                try:
                    code_module = component.CodeModule
                    line_count = code_module.CountOfLines

                    if line_count > 0:
                        code = code_module.Lines(1, line_count)

                        if SEARCH_NAME in code:
                            found_in.append(component.Name)
                            print(f"GEFUNDEN in: {component.Name}")

                            # Zeilen mit dem Namen anzeigen
                            for i, line in enumerate(code.split('\n'), 1):
                                if SEARCH_NAME in line:
                                    print(f"  Zeile {i}: {line.strip()}")
                            print()

                except Exception as e:
                    pass

            print()
            print("=" * 70)
            if len(found_in) > 1:
                print(f"DUPLIKAT GEFUNDEN! '{SEARCH_NAME}' existiert in {len(found_in)} Modulen:")
                for m in found_in:
                    print(f"  - {m}")
            elif len(found_in) == 1:
                print(f"'{SEARCH_NAME}' nur in einem Modul gefunden: {found_in[0]}")
            else:
                print(f"'{SEARCH_NAME}' nicht gefunden")
            print("=" * 70)

    except Exception as e:
        print(f"\nFEHLER: {e}")
        import traceback
        traceback.print_exc()
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""
Prueft den VBA-Code des cmd_HTML_Ansicht Buttons
"""

import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")
from access_bridge_ultimate import AccessBridge

FORM_NAME = "frm_Menuefuehrung"

def main():
    print("=" * 70)
    print("CHECK HTML ANSICHT BUTTON CODE")
    print("=" * 70)
    print()

    try:
        with AccessBridge() as bridge:
            print("Access Bridge verbunden.\n")

            # Versuche das Formular-Modul zu lesen
            try:
                # VBA-Projekt zugreifen
                vba_project = bridge.access_app.VBE.ActiveVBProject

                for component in vba_project.VBComponents:
                    if component.Name == FORM_NAME or "Menuefuehrung" in component.Name:
                        print(f"Komponente gefunden: {component.Name}")
                        print(f"Typ: {component.Type}")

                        # Code-Modul lesen
                        code_module = component.CodeModule
                        line_count = code_module.CountOfLines

                        if line_count > 0:
                            code = code_module.Lines(1, line_count)

                            # Nach cmd_HTML_Ansicht suchen
                            if "cmd_HTML_Ansicht" in code or "HTML" in code:
                                print(f"\nRelevanter Code ({line_count} Zeilen):")
                                print("-" * 50)
                                for i, line in enumerate(code.split('\n'), 1):
                                    if "HTML" in line or "cmd_HTML" in line or "Sub cmd_" in line or "Shell" in line or "OpenForm" in line:
                                        print(f"{i:4}: {line}")
                                print("-" * 50)
                        print()

            except Exception as e:
                print(f"VBA-Zugriff Fehler: {e}")
                import traceback
                traceback.print_exc()

    except Exception as e:
        print(f"\nFEHLER: {e}")
        import traceback
        traceback.print_exc()
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())

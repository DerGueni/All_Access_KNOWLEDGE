#!/usr/bin/env python3
"""
Entfernt die doppelte Get_Priv_Property aus mod_N_EventDaten_PDF
"""

import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")
from access_bridge_ultimate import AccessBridge

MODULE_NAME = "mod_N_Eventdaten_PDF"

def main():
    print("=" * 70)
    print("FIX DUPLICATE Get_Priv_Property")
    print("=" * 70)
    print()

    try:
        with AccessBridge() as bridge:
            print("Access Bridge verbunden.\n")

            # Pruefen ob Modul existiert
            modules = bridge.list_modules()
            if MODULE_NAME not in modules:
                print(f"Modul '{MODULE_NAME}' nicht in der Datenbank gefunden.")
                print("Kein Duplikat-Problem vorhanden.")
                return 0

            print(f"Modul '{MODULE_NAME}' gefunden - pruefe auf Get_Priv_Property...")

            # VBA-Projekt zugreifen
            vba_project = bridge.access_app.VBE.ActiveVBProject

            # Modul finden
            module_component = None
            for component in vba_project.VBComponents:
                if component.Name == MODULE_NAME:
                    module_component = component
                    break

            if not module_component:
                print("Modul-Komponente nicht gefunden")
                return 1

            code_module = module_component.CodeModule
            line_count = code_module.CountOfLines

            if line_count == 0:
                print("Modul ist leer")
                return 0

            # Code durchsuchen
            code = code_module.Lines(1, line_count)

            if "Get_Priv_Property" not in code:
                print("Keine Get_Priv_Property im Modul - OK")
                return 0

            print("Get_Priv_Property gefunden - entferne duplikate Funktionen...")

            # Zeilen mit Set_Priv_Property und Get_Priv_Property finden und entfernen
            lines_to_delete = []
            in_function = False
            function_start = 0

            for i in range(1, line_count + 1):
                line = code_module.Lines(i, 1)

                # Start einer zu loeschenden Funktion
                if "Sub Set_Priv_Property(" in line or "Function Get_Priv_Property(" in line:
                    in_function = True
                    function_start = i
                    print(f"  Gefunden Zeile {i}: {line.strip()}")

                # Ende der Funktion
                if in_function and "End Sub" in line or (in_function and "End Function" in line):
                    lines_to_delete.append((function_start, i))
                    in_function = False

            # Auch Kommentare davor loeschen (Hilfsfunktion-Header)
            # Zeilen von hinten nach vorne loeschen (damit Zeilennummern stimmen)
            for start, end in reversed(lines_to_delete):
                # Header-Kommentare finden (3 Zeilen davor)
                actual_start = start
                for j in range(start - 1, max(1, start - 5), -1):
                    check_line = code_module.Lines(j, 1)
                    if "'===" in check_line or "' Hilfsfunktion" in check_line:
                        actual_start = j
                    else:
                        break

                delete_count = end - actual_start + 1
                print(f"  Loesche Zeilen {actual_start} bis {end} ({delete_count} Zeilen)")
                code_module.DeleteLines(actual_start, delete_count)

            print()
            print("=" * 70)
            print("DUPLIKATE ENTFERNT!")
            print("=" * 70)
            print()
            print("Die Funktionen Get_Priv_Property und Set_Priv_Property")
            print("werden jetzt aus mdlPrivProperty verwendet.")
            print()

    except Exception as e:
        print(f"\nFEHLER: {e}")
        import traceback
        traceback.print_exc()
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())

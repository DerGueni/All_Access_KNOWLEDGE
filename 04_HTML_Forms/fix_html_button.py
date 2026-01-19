#!/usr/bin/env python3
"""
Ersetzt den VBA-Code des cmd_HTML_Ansicht Buttons
um WebView2 Shell zu oeffnen statt Browser + API Server
"""

import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")
from access_bridge_ultimate import AccessBridge

FORM_NAME = "frm_Menuefuehrung"

# Neuer Code fuer den Button
NEW_BUTTON_CODE = '''Private Sub cmd_HTML_Ansicht_Click()
    ' Oeffnet HTML-Formulare in WebView2 mit Shell/Sidebar
    ' KEIN API Server erforderlich!
    Call OpenShell_Auftragstamm(0)
End Sub'''

def main():
    print("=" * 70)
    print("FIX HTML ANSICHT BUTTON - WebView2 Shell")
    print("=" * 70)
    print()

    try:
        with AccessBridge() as bridge:
            print("Access Bridge verbunden.\n")

            # VBA-Projekt zugreifen
            vba_project = bridge.access_app.VBE.ActiveVBProject

            # Formular-Komponente finden
            form_component = None
            for component in vba_project.VBComponents:
                if component.Name == f"Form_{FORM_NAME}":
                    form_component = component
                    break

            if not form_component:
                print(f"FEHLER: Form_{FORM_NAME} nicht gefunden!")
                return 1

            print(f"Formular-Modul gefunden: {form_component.Name}")

            # Code-Modul
            code_module = form_component.CodeModule
            line_count = code_module.CountOfLines

            if line_count == 0:
                print("FEHLER: Kein Code im Formular!")
                return 1

            # Gesamten Code lesen
            full_code = code_module.Lines(1, line_count)

            print(f"Aktueller Code: {line_count} Zeilen")

            # Suche nach der alten Sub
            start_line = 0
            end_line = 0

            for i in range(1, line_count + 1):
                line = code_module.Lines(i, 1)
                if "Private Sub cmd_HTML_Ansicht_Click()" in line or "Sub cmd_HTML_Ansicht_Click()" in line:
                    start_line = i
                    print(f"  Start gefunden: Zeile {i}")
                elif start_line > 0 and "End Sub" in line:
                    end_line = i
                    print(f"  Ende gefunden: Zeile {i}")
                    break

            if start_line == 0:
                print("FEHLER: cmd_HTML_Ansicht_Click Sub nicht gefunden!")
                return 1

            # Alten Code anzeigen
            print(f"\nAlter Code (Zeilen {start_line}-{end_line}):")
            print("-" * 50)
            old_code = code_module.Lines(start_line, end_line - start_line + 1)
            print(old_code)
            print("-" * 50)

            # Alten Code loeschen
            print(f"\nLoesche Zeilen {start_line} bis {end_line}...")
            code_module.DeleteLines(start_line, end_line - start_line + 1)

            # Neuen Code einfuegen
            print("Fuege neuen Code ein...")
            code_module.InsertLines(start_line, NEW_BUTTON_CODE)

            # Verifizieren
            new_line_count = code_module.CountOfLines
            print(f"\nNeuer Code: {new_line_count} Zeilen")

            # Neuen Code anzeigen
            print("\nNeuer Code:")
            print("-" * 50)
            print(code_module.Lines(start_line, 5))
            print("-" * 50)

            print()
            print("=" * 70)
            print("BUTTON CODE AKTUALISIERT!")
            print("=" * 70)
            print()
            print("Der 'HTML Ansicht' Button ruft jetzt auf:")
            print("  OpenShell_Auftragstamm(0)")
            print()
            print("Das oeffnet:")
            print("  - WebView2 Host (nicht Browser)")
            print("  - Shell mit Sidebar")
            print("  - OHNE API Server!")
            print()

    except Exception as e:
        print(f"\nFEHLER: {e}")
        import traceback
        traceback.print_exc()
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())

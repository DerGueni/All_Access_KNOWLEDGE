#!/usr/bin/env python3
"""
Aktualisiert den cmd_HTML_Ansicht Button in frm_Menuefuehrung
um die WebView2 Shell zu oeffnen
"""

import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")
from access_bridge_ultimate import AccessBridge

FORM_NAME = "frm_Menuefuehrung"
BUTTON_NAME = "cmd_HTML_Ansicht"
NEW_ONCLICK = "=OpenShell_Auftragstamm(0)"

def main():
    print("=" * 70)
    print("UPDATE HTML ANSICHT BUTTON")
    print("=" * 70)
    print()

    try:
        with AccessBridge() as bridge:
            print("Access Bridge verbunden.\n")

            print(f"Oeffne {FORM_NAME} im Entwurfsmodus...")
            bridge.access_app.DoCmd.OpenForm(FORM_NAME, 1, "", "", 0, 1)

            frm = bridge.access_app.Forms(FORM_NAME)

            # Button finden
            print(f"Suche Button '{BUTTON_NAME}'...")
            ctl = frm.Controls(BUTTON_NAME)

            old_onclick = ""
            try:
                old_onclick = ctl.OnClick
            except:
                pass

            print(f"  Gefunden!")
            print(f"  Aktueller OnClick: {old_onclick}")

            # OnClick aktualisieren
            ctl.OnClick = NEW_ONCLICK
            print(f"  Neuer OnClick:     {NEW_ONCLICK}")

            # Formular speichern
            bridge.access_app.DoCmd.Close(2, FORM_NAME, 1)  # acSaveYes=1
            print(f"\nFormular gespeichert!")

            print()
            print("=" * 70)
            print("BUTTON AKTUALISIERT!")
            print("=" * 70)
            print()
            print("Der 'HTML Ansicht' Button oeffnet jetzt:")
            print("  - WebView2 Host (nicht Browser)")
            print("  - Shell mit Sidebar (bleibt persistent)")
            print("  - Auftragsverwaltung als Startformular")
            print("  - KEIN API Server erforderlich!")
            print()

    except Exception as e:
        print(f"\nFEHLER: {e}")
        import traceback
        traceback.print_exc()
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())

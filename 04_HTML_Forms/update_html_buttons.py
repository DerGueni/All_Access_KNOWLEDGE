#!/usr/bin/env python3
"""
Update HTML Buttons - Aktualisiert die OnClick Events der HTML Ansicht Buttons
"""

import sys
import os

# Access Bridge Pfad hinzufuegen
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge

# Button-Konfiguration: Formular -> (ID-Feld, Funktion)
BUTTON_CONFIG = {
    "frm_VA_Auftragstamm": ("ID", "OpenShell_Auftragstamm"),
    "frm_MA_Mitarbeiterstamm": ("ID", "OpenShell_Mitarbeiterstamm"),
    "frm_KD_Kundenstamm": ("kun_Id", "OpenShell_Kundenstamm"),
    "frm_OB_Objekt": ("ID", "OpenShell_Objekt"),
}

def update_button_onclick(bridge, form_name, id_field, function_name):
    """Aktualisiert den OnClick Event eines HTML-Buttons"""
    try:
        # Formular im Entwurfsmodus oeffnen
        # acDesign=1, acWindowHidden=1
        bridge.access_app.DoCmd.OpenForm(form_name, 1, "", "", 0, 1)

        frm = bridge.access_app.Forms(form_name)
        button_found = False

        for ctl in frm.Controls:
            try:
                ctl_type = ctl.ControlType
                if ctl_type is None:
                    continue
            except:
                continue

            # Nur CommandButtons (104) pruefen
            if ctl_type == 104:
                caption = ""
                name = ""

                try:
                    name = ctl.Name
                except:
                    pass

                try:
                    caption = ctl.Caption
                except:
                    pass

                # Button mit "HTML" im Namen oder Caption suchen
                if "HTML" in str(caption).upper() or "HTML" in str(name).upper():
                    old_onclick = ""
                    try:
                        old_onclick = ctl.OnClick
                    except:
                        pass

                    # Neuen OnClick setzen
                    new_onclick = f"={function_name}([{id_field}])"
                    ctl.OnClick = new_onclick

                    print(f"  Button '{name}' ({caption}):")
                    print(f"    Alt:  {old_onclick}")
                    print(f"    Neu:  {new_onclick}")
                    button_found = True

        # Formular speichern und schliessen
        bridge.access_app.DoCmd.Close(2, form_name, 1)  # acForm=2, acSaveYes=1

        if not button_found:
            print(f"  -> Kein HTML-Button gefunden")

        return button_found

    except Exception as e:
        print(f"  -> Fehler: {e}")
        import traceback
        traceback.print_exc()
        try:
            bridge.access_app.DoCmd.Close(2, form_name, 0)  # acSaveNo=0
        except:
            pass
        return False


def main():
    print("=" * 70)
    print("UPDATE HTML BUTTONS - WebView2 Shell")
    print("=" * 70)
    print()

    try:
        with AccessBridge() as bridge:
            print("Access Bridge verbunden.\n")

            # Verfuegbare Formulare pruefen
            forms = bridge.list_forms()

            for form_name, (id_field, function_name) in BUTTON_CONFIG.items():
                print(f"Aktualisiere {form_name}...")

                if form_name in forms:
                    update_button_onclick(bridge, form_name, id_field, function_name)
                else:
                    print(f"  -> Formular nicht gefunden")

                print()

            print("=" * 70)
            print("BUTTONS AKTUALISIERT!")
            print("=" * 70)
            print()
            print("Die 'HTML Ansicht' Buttons oeffnen jetzt:")
            print("  - WebView2 Host (nicht Browser)")
            print("  - Shell mit Sidebar (bleibt persistent)")
            print("  - Formulare werden im iframe geladen")
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

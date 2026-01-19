#!/usr/bin/env python3
"""Listet alle Buttons im Menueformular auf"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")
from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    # Alle Menuefuehrung Formulare finden
    forms = bridge.list_forms()
    menu_forms = [f for f in forms if "menu" in f.lower()]
    print(f"\nGefundene Menu-Formulare: {menu_forms}\n")

    for form_name in menu_forms:
        print(f"\n{'='*60}")
        print(f"FORMULAR: {form_name}")
        print(f"{'='*60}")

        try:
            bridge.access_app.DoCmd.OpenForm(form_name, 1, "", "", 0, 1)
            frm = bridge.access_app.Forms(form_name)

            print("\nButtons mit 'HTML' oder 'Web' oder 'Ansicht':")
            for ctl in frm.Controls:
                try:
                    if ctl.ControlType == 104:
                        name = str(ctl.Name)
                        caption = ""
                        onclick = ""
                        try:
                            caption = str(ctl.Caption)
                        except:
                            pass
                        try:
                            onclick = str(ctl.OnClick)
                        except:
                            pass

                        # Alle Buttons anzeigen die relevant sein koennten
                        search_terms = ["html", "web", "ansicht", "shell", "browser"]
                        if any(t in name.lower() or t in caption.lower() for t in search_terms):
                            print(f"  >>> {name}")
                            print(f"      Caption: {caption}")
                            print(f"      OnClick: {onclick}")
                except:
                    pass

            bridge.access_app.DoCmd.Close(2, form_name, 0)

        except Exception as e:
            print(f"  Fehler: {e}")

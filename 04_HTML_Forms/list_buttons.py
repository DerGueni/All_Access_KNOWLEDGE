#!/usr/bin/env python3
"""Listet alle Buttons in den Zielformularen auf"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")
from access_bridge_ultimate import AccessBridge

TARGET_FORMS = ["frm_VA_Auftragstamm", "frm_MA_Mitarbeiterstamm", "frm_KD_Kundenstamm", "frm_OB_Objekt"]

with AccessBridge() as bridge:
    for form_name in TARGET_FORMS:
        print(f"\n{'='*60}")
        print(f"FORMULAR: {form_name}")
        print(f"{'='*60}")

        try:
            bridge.access_app.DoCmd.OpenForm(form_name, 1, "", "", 0, 1)
            frm = bridge.access_app.Forms(form_name)

            print("\nAlle CommandButtons (ControlType=104):")
            for ctl in frm.Controls:
                try:
                    if ctl.ControlType == 104:
                        name = ctl.Name
                        caption = ""
                        onclick = ""
                        try:
                            caption = ctl.Caption
                        except:
                            pass
                        try:
                            onclick = ctl.OnClick
                        except:
                            pass
                        print(f"  - {name}")
                        print(f"    Caption: {caption}")
                        print(f"    OnClick: {onclick}")
                except:
                    pass

            bridge.access_app.DoCmd.Close(2, form_name, 0)

        except Exception as e:
            print(f"  Fehler: {e}")

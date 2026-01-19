# -*- coding: utf-8 -*-
"""
Detaillierte Analyse von Unterformular und Bericht
"""

import win32com.client
import pythoncom
import time

def main():
    print("=" * 70)
    print("DETAILLIERTE ANALYSE: Unterformular und Bericht")
    print("=" * 70)

    pythoncom.CoInitialize()

    try:
        access = win32com.client.GetObject(Class="Access.Application")
        print("Access-Verbindung hergestellt!")

        # === 1. Unterformular analysieren ===
        print("\n" + "=" * 70)
        print("1. UNTERFORMULAR sub_OB_Objekt_Positionen")
        print("=" * 70)

        try:
            access.DoCmd.OpenForm("sub_OB_Objekt_Positionen", 1)  # acViewDesign
            time.sleep(1)

            frm = access.Forms("sub_OB_Objekt_Positionen")
            print(f"RecordSource: {frm.RecordSource}")
            print(f"DefaultView: {frm.DefaultView}")

            print("\nALLE CONTROLS:")
            for i in range(frm.Controls.Count):
                ctl = frm.Controls.Item(i)
                name = ctl.Name
                ctrl_type = ctl.ControlType

                type_names = {
                    100: "Label",
                    109: "TextBox",
                    106: "CheckBox",
                    110: "ListBox",
                    111: "ComboBox",
                    104: "Button",
                    112: "SubForm"
                }
                type_name = type_names.get(ctrl_type, f"Type{ctrl_type}")

                # ControlSource fuer gebundene Controls
                try:
                    source = ctl.ControlSource
                    print(f"  {type_name}: {name} -> ControlSource: {source}")
                except:
                    print(f"  {type_name}: {name}")

            access.DoCmd.Close(2, "sub_OB_Objekt_Positionen", 2)

        except Exception as e:
            print(f"Unterformular-Fehler: {e}")

        # === 2. Bericht analysieren ===
        print("\n" + "=" * 70)
        print("2. BERICHT rpt_OB_Objekt")
        print("=" * 70)

        try:
            access.DoCmd.OpenReport("rpt_OB_Objekt", 1)  # acViewDesign
            time.sleep(1)

            rpt = access.Reports("rpt_OB_Objekt")
            print(f"RecordSource: {rpt.RecordSource}")

            print("\nALLE CONTROLS:")
            for i in range(rpt.Controls.Count):
                ctl = rpt.Controls.Item(i)
                name = ctl.Name
                ctrl_type = ctl.ControlType

                type_names = {
                    100: "Label",
                    109: "TextBox",
                    106: "CheckBox",
                    112: "SubReport",
                    114: "Rectangle",
                    118: "Line"
                }
                type_name = type_names.get(ctrl_type, f"Type{ctrl_type}")

                if ctrl_type in [109, 112]:  # TextBox oder SubReport
                    try:
                        source = ctl.ControlSource
                        print(f"  {type_name}: {name} -> ControlSource: {source}")
                    except:
                        print(f"  {type_name}: {name}")

            access.DoCmd.Close(3, "rpt_OB_Objekt", 2)

        except Exception as e:
            print(f"Bericht-Fehler: {e}")

        # === 3. Sub-Bericht analysieren ===
        print("\n" + "=" * 70)
        print("3. SUB-BERICHT rpt_OB_Objekt_Sub")
        print("=" * 70)

        try:
            access.DoCmd.OpenReport("rpt_OB_Objekt_Sub", 1)  # acViewDesign
            time.sleep(1)

            rpt = access.Reports("rpt_OB_Objekt_Sub")
            print(f"RecordSource: {rpt.RecordSource}")

            print("\nALLE CONTROLS:")
            for i in range(rpt.Controls.Count):
                ctl = rpt.Controls.Item(i)
                name = ctl.Name
                ctrl_type = ctl.ControlType

                type_names = {
                    100: "Label",
                    109: "TextBox",
                    106: "CheckBox",
                    112: "SubReport"
                }
                type_name = type_names.get(ctrl_type, f"Type{ctrl_type}")

                if ctrl_type == 109:  # TextBox
                    try:
                        source = ctl.ControlSource
                        print(f"  {type_name}: {name} -> ControlSource: {source}")
                    except:
                        print(f"  {type_name}: {name}")
                elif ctrl_type == 100:  # Label
                    try:
                        caption = ctl.Caption
                        if 'zeit' in name.lower() or 'zeit' in caption.lower():
                            print(f"  {type_name}: {name} -> Caption: {caption}")
                    except:
                        pass

            access.DoCmd.Close(3, "rpt_OB_Objekt_Sub", 2)

        except Exception as e:
            print(f"Sub-Bericht-Fehler: {e}")

        print("\n" + "=" * 70)
        print("ANALYSE ABGESCHLOSSEN")
        print("=" * 70)

    except Exception as e:
        print(f"Hauptfehler: {e}")

    finally:
        pythoncom.CoUninitialize()

if __name__ == "__main__":
    main()

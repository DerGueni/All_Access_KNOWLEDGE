# -*- coding: utf-8 -*-
"""
Analysiert ein Access-Formular und gibt alle Controls mit Eigenschaften aus
"""

import sys
import win32com.client
import time

def analyze_form(form_name):
    """Analysiert ein Access-Formular und gibt Details zurueck"""

    app = None
    try:
        # Access-Instanz holen
        app = win32com.client.GetObject(Class="Access.Application")
        print(f"\n{'='*60}")
        print(f"ANALYSE: {form_name}")
        print(f"{'='*60}")

        # Formular oeffnen
        try:
            app.DoCmd.OpenForm(form_name, 0)  # acNormal = 0
            time.sleep(1)
        except Exception as e:
            print(f"Fehler beim Oeffnen: {e}")
            return None

        # Formular-Objekt holen
        frm = app.Forms(form_name)

        # Formular-Eigenschaften
        print(f"\n--- FORMULAR-EIGENSCHAFTEN ---")
        try:
            print(f"Caption: {frm.Caption}")
            print(f"RecordSource: {frm.RecordSource}")
            print(f"DefaultView: {frm.DefaultView}")
            print(f"Width: {frm.Width} twips ({frm.Width/1440:.2f} inch)")
            print(f"ScrollBars: {frm.ScrollBars}")
            print(f"NavigationButtons: {frm.NavigationButtons}")
            print(f"RecordSelectors: {frm.RecordSelectors}")
            print(f"DividingLines: {frm.DividingLines}")
        except:
            pass

        # Sektionen
        print(f"\n--- SEKTIONEN ---")
        sections = {0: "Detail", 1: "FormHeader", 2: "FormFooter", 3: "PageHeader", 4: "PageFooter"}
        for sec_id, sec_name in sections.items():
            try:
                sec = frm.Section(sec_id)
                print(f"{sec_name}: Height={sec.Height} twips, BackColor={sec.BackColor}")
            except:
                pass

        # Controls sammeln
        print(f"\n--- CONTROLS ({frm.Controls.Count} gesamt) ---")
        controls_by_type = {}

        for ctl in frm.Controls:
            try:
                ctl_type = ctl.ControlType
                ctl_name = ctl.Name

                if ctl_type not in controls_by_type:
                    controls_by_type[ctl_type] = []

                info = {
                    'name': ctl_name,
                    'type': ctl_type,
                    'left': getattr(ctl, 'Left', 0),
                    'top': getattr(ctl, 'Top', 0),
                    'width': getattr(ctl, 'Width', 0),
                    'height': getattr(ctl, 'Height', 0),
                }

                # Zusaetzliche Eigenschaften je nach Typ
                if ctl_type == 100:  # Label
                    info['caption'] = getattr(ctl, 'Caption', '')
                elif ctl_type == 104:  # CommandButton
                    info['caption'] = getattr(ctl, 'Caption', '')
                    info['onclick'] = getattr(ctl, 'OnClick', '')
                elif ctl_type == 109:  # TextBox
                    info['control_source'] = getattr(ctl, 'ControlSource', '')
                elif ctl_type == 110:  # ListBox
                    info['row_source'] = getattr(ctl, 'RowSource', '')[:100] if getattr(ctl, 'RowSource', '') else ''
                elif ctl_type == 111:  # ComboBox
                    info['row_source'] = getattr(ctl, 'RowSource', '')[:100] if getattr(ctl, 'RowSource', '') else ''
                elif ctl_type == 112:  # Subform
                    info['source_object'] = getattr(ctl, 'SourceObject', '')
                elif ctl_type == 106:  # OptionGroup
                    pass
                elif ctl_type == 114:  # TabControl
                    info['pages'] = []
                    try:
                        for page in ctl.Pages:
                            info['pages'].append(page.Caption)
                    except:
                        pass

                controls_by_type[ctl_type].append(info)

            except Exception as e:
                print(f"  Fehler bei Control: {e}")

        # Ausgabe nach Typ sortiert
        type_names = {
            100: 'Label', 104: 'CommandButton', 109: 'TextBox',
            110: 'ListBox', 111: 'ComboBox', 112: 'Subform',
            106: 'OptionGroup', 114: 'TabControl', 101: 'Rectangle',
            102: 'Line', 103: 'Image', 105: 'OptionButton',
            107: 'CheckBox', 108: 'BoundObjFrame', 113: 'CustomControl',
            118: 'PageBreak', 119: 'WebBrowser', 122: 'NavigationControl'
        }

        for ctl_type, controls in sorted(controls_by_type.items()):
            type_name = type_names.get(ctl_type, f'Type_{ctl_type}')
            print(f"\n{type_name} ({len(controls)}):")
            for ctl in controls:
                print(f"  - {ctl['name']}: L={ctl['left']}, T={ctl['top']}, W={ctl['width']}, H={ctl['height']}")
                if 'caption' in ctl:
                    print(f"    Caption: {ctl['caption']}")
                if 'control_source' in ctl and ctl['control_source']:
                    print(f"    ControlSource: {ctl['control_source']}")
                if 'row_source' in ctl and ctl['row_source']:
                    print(f"    RowSource: {ctl['row_source'][:50]}...")
                if 'source_object' in ctl:
                    print(f"    SourceObject: {ctl['source_object']}")
                if 'onclick' in ctl and ctl['onclick']:
                    print(f"    OnClick: {ctl['onclick']}")
                if 'pages' in ctl:
                    print(f"    Pages: {ctl['pages']}")

        # Formular schliessen
        app.DoCmd.Close(2, form_name, 0)  # acForm=2, acSaveNo=0

        return controls_by_type

    except Exception as e:
        print(f"Fehler: {e}")
        import traceback
        traceback.print_exc()
        return None

if __name__ == "__main__":
    if len(sys.argv) > 1:
        form_name = sys.argv[1]
    else:
        form_name = "frm_N_Dienstplanuebersicht"

    analyze_form(form_name)

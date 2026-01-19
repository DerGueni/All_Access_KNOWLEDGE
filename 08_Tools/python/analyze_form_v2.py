# -*- coding: utf-8 -*-
"""
Analysiert ein Access-Formular detailliert
"""

import sys
import time
import json
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

from access_bridge_ultimate import AccessBridge

CONTROL_TYPES = {
    100: 'Label', 104: 'CommandButton', 109: 'TextBox',
    110: 'ListBox', 111: 'ComboBox', 112: 'Subform',
    106: 'OptionGroup', 114: 'TabControl', 101: 'Rectangle',
    102: 'Line', 103: 'Image', 105: 'OptionButton',
    107: 'CheckBox', 108: 'BoundObjFrame', 113: 'CustomControl',
    118: 'PageBreak', 119: 'WebBrowser', 122: 'NavigationControl'
}

def analyze_form(form_name):
    with AccessBridge() as bridge:
        print(f"\n{'='*60}")
        print(f"DETAILANALYSE: {form_name}")
        print(f"{'='*60}")

        try:
            # Formular oeffnen
            bridge.access_app.DoCmd.OpenForm(form_name, 0)
            time.sleep(1)

            frm = bridge.access_app.Forms(form_name)

            # Eigenschaften
            print(f"\n--- FORMULAR-EIGENSCHAFTEN ---")
            print(f"Caption: {frm.Caption}")
            print(f"RecordSource: {frm.RecordSource}")
            print(f"DefaultView: {frm.DefaultView}")
            print(f"Width: {frm.Width} twips = {frm.Width/1440:.1f} inch")
            print(f"NavigationButtons: {frm.NavigationButtons}")

            # Sektionen
            print(f"\n--- SEKTIONEN ---")
            for sec_id, sec_name in [(0, "Detail"), (1, "FormHeader"), (2, "FormFooter")]:
                try:
                    sec = frm.Section(sec_id)
                    # BackColor in RGB umwandeln
                    bc = sec.BackColor
                    r = bc & 0xFF
                    g = (bc >> 8) & 0xFF
                    b = (bc >> 16) & 0xFF
                    print(f"  {sec_name}: H={sec.Height} twips, BackColor=#{r:02X}{g:02X}{b:02X} ({bc})")
                except:
                    pass

            # Controls nach Typ sammeln
            controls_by_type = {}
            for ctl in frm.Controls:
                try:
                    ct = ctl.ControlType
                    if ct not in controls_by_type:
                        controls_by_type[ct] = []
                    controls_by_type[ct].append(ctl)
                except:
                    pass

            # Ausgabe
            for ct, ctls in sorted(controls_by_type.items()):
                type_name = CONTROL_TYPES.get(ct, f'Type_{ct}')
                print(f"\n--- {type_name} ({len(ctls)}) ---")

                for ctl in ctls[:20]:  # Max 20 pro Typ
                    try:
                        name = ctl.Name
                        visible = getattr(ctl, 'Visible', True)
                        vis_str = "" if visible else " [HIDDEN]"

                        if ct == 104:  # CommandButton
                            caption = getattr(ctl, 'Caption', '')
                            onclick = getattr(ctl, 'OnClick', '')
                            print(f"  {name}: '{caption}'{vis_str}")
                            if onclick:
                                print(f"    -> OnClick: {onclick}")
                        elif ct == 100:  # Label
                            caption = getattr(ctl, 'Caption', '')
                            if caption and len(caption) > 3:
                                print(f"  {name}: '{caption[:50]}'{vis_str}")
                        elif ct == 109:  # TextBox
                            cs = getattr(ctl, 'ControlSource', '')
                            if cs:
                                print(f"  {name}: [{cs}]{vis_str}")
                        elif ct == 111:  # ComboBox
                            rs = getattr(ctl, 'RowSource', '')[:80]
                            print(f"  {name}: {rs}{vis_str}")
                        elif ct == 112:  # Subform
                            so = getattr(ctl, 'SourceObject', '')
                            print(f"  {name}: -> {so}{vis_str}")
                        elif ct == 114:  # TabControl
                            pages = []
                            try:
                                for p in ctl.Pages:
                                    pages.append(p.Caption)
                            except:
                                pass
                            print(f"  {name}: Pages={pages}{vis_str}")
                        else:
                            print(f"  {name}{vis_str}")
                    except Exception as e:
                        print(f"  Fehler: {e}")

                if len(ctls) > 20:
                    print(f"  ... und {len(ctls)-20} weitere")

            # Schliessen
            bridge.access_app.DoCmd.Close(2, form_name, 0)

        except Exception as e:
            print(f"FEHLER: {e}")
            import traceback
            traceback.print_exc()

if __name__ == "__main__":
    form_name = sys.argv[1] if len(sys.argv) > 1 else "frm_Menuefuehrung"
    analyze_form(form_name)

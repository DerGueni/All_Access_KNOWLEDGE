# -*- coding: utf-8 -*-
"""
Vergleicht Access-Formular mit HTML-Formular
Oeffnet beide nebeneinander und analysiert Unterschiede
"""

import sys
import os
import time
import subprocess
import json

sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

# Access Bridge importieren
try:
    from access_bridge_ultimate import AccessBridge
    HAS_BRIDGE = True
except:
    HAS_BRIDGE = False
    print("WARNUNG: AccessBridge nicht verfuegbar")

# Pfade
HTML_PATH = r"C:\Users\guenther.siegert\Documents\Consys_HTML\02_web\forms"
REPORT_PATH = r"C:\Users\guenther.siegert\Documents\Consys_HTML\04_tests"

# Mapping von Access-Formularen zu HTML-Dateien
FORM_MAPPING = {
    "frm_N_Dienstplanuebersicht": "frm_N_Dienstplanuebersicht.html",
    "frm_VA_Planungsuebersicht": "frm_VA_Planungsuebersicht.html",
    "frm_va_Auftragstamm": "frm_va_Auftragstamm.html",
    "frm_MA_Mitarbeiterstamm": "frm_MA_Mitarbeiterstamm.html",
    "frm_KD_Kundenstamm": "frm_KD_Kundenstamm.html",
    "frm_MA_Abwesenheit": "frm_MA_Abwesenheit.html",
    "frm_MA_Zeitkonten": "frm_MA_Zeitkonten.html",
    "frm_Ausweis_Create": "frm_Ausweis_Create.html",
    "frm_Einsatzuebersicht": "frm_Einsatzuebersicht.html",
    "frm_OB_Objekt": "frm_OB_Objekt.html",
    "frm_N_Lohnabrechnungen": "frm_N_Lohnabrechnungen.html",
    "frm_N_Mitarbeiterauswahl": "frm_N_Mitarbeiterauswahl.html",
    "frm_N_Stundenauswertung": "frm_N_Stundenauswertung.html",
    "frm_N_Email_versenden": "frm_N_Email_versenden.html",
}

# Control-Typ-Namen
CONTROL_TYPES = {
    100: 'Label',
    104: 'CommandButton',
    109: 'TextBox',
    110: 'ListBox',
    111: 'ComboBox',
    112: 'Subform',
    106: 'OptionGroup',
    114: 'TabControl',
    101: 'Rectangle',
    102: 'Line',
    103: 'Image',
    105: 'OptionButton',
    107: 'CheckBox',
    108: 'BoundObjFrame',
    113: 'CustomControl',
    118: 'PageBreak',
    119: 'WebBrowser',
    122: 'NavigationControl'
}

def open_html_form(form_name):
    """Oeffnet HTML-Formular im Browser"""
    if form_name in FORM_MAPPING:
        html_file = os.path.join(HTML_PATH, FORM_MAPPING[form_name])
        if os.path.exists(html_file):
            subprocess.Popen(['cmd', '/c', 'start', '', html_file], shell=True)
            print(f"HTML geoeffnet: {html_file}")
            return True
    return False

def analyze_access_form(bridge, form_name):
    """Analysiert Access-Formular und gibt Struktur zurueck"""
    result = {
        "name": form_name,
        "properties": {},
        "sections": {},
        "controls": {},
        "buttons": [],
        "textboxes": [],
        "combos": [],
        "subforms": [],
        "tabs": []
    }

    try:
        # Formular oeffnen
        bridge.app.DoCmd.OpenForm(form_name, 0)  # acNormal
        time.sleep(0.5)

        frm = bridge.app.Forms(form_name)

        # Formular-Eigenschaften
        result["properties"] = {
            "Caption": str(getattr(frm, 'Caption', '')),
            "RecordSource": str(getattr(frm, 'RecordSource', '')),
            "DefaultView": getattr(frm, 'DefaultView', 0),
            "Width": getattr(frm, 'Width', 0),
            "NavigationButtons": getattr(frm, 'NavigationButtons', False)
        }

        # Sektionen
        sections = {0: "Detail", 1: "FormHeader", 2: "FormFooter"}
        for sec_id, sec_name in sections.items():
            try:
                sec = frm.Section(sec_id)
                result["sections"][sec_name] = {
                    "Height": sec.Height,
                    "BackColor": sec.BackColor
                }
            except:
                pass

        # Controls analysieren
        for ctl in frm.Controls:
            try:
                ctl_type = ctl.ControlType
                ctl_name = ctl.Name
                type_name = CONTROL_TYPES.get(ctl_type, f'Type_{ctl_type}')

                info = {
                    'name': ctl_name,
                    'type': type_name,
                    'type_id': ctl_type,
                    'left': getattr(ctl, 'Left', 0),
                    'top': getattr(ctl, 'Top', 0),
                    'width': getattr(ctl, 'Width', 0),
                    'height': getattr(ctl, 'Height', 0),
                    'visible': getattr(ctl, 'Visible', True)
                }

                # Spezifische Eigenschaften
                if ctl_type == 100:  # Label
                    info['caption'] = str(getattr(ctl, 'Caption', ''))
                elif ctl_type == 104:  # CommandButton
                    info['caption'] = str(getattr(ctl, 'Caption', ''))
                    info['onclick'] = str(getattr(ctl, 'OnClick', ''))
                    result["buttons"].append(info)
                elif ctl_type == 109:  # TextBox
                    info['control_source'] = str(getattr(ctl, 'ControlSource', ''))
                    result["textboxes"].append(info)
                elif ctl_type == 111:  # ComboBox
                    info['row_source'] = str(getattr(ctl, 'RowSource', ''))[:100]
                    result["combos"].append(info)
                elif ctl_type == 112:  # Subform
                    info['source_object'] = str(getattr(ctl, 'SourceObject', ''))
                    result["subforms"].append(info)
                elif ctl_type == 114:  # TabControl
                    pages = []
                    try:
                        for page in ctl.Pages:
                            pages.append(str(page.Caption))
                    except:
                        pass
                    info['pages'] = pages
                    result["tabs"].append(info)

                if type_name not in result["controls"]:
                    result["controls"][type_name] = []
                result["controls"][type_name].append(info)

            except Exception as e:
                pass

        # Formular schliessen
        bridge.app.DoCmd.Close(2, form_name, 0)

    except Exception as e:
        result["error"] = str(e)

    return result

def compare_and_report(form_name):
    """Vergleicht Access und HTML und erstellt Bericht"""
    print(f"\n{'='*60}")
    print(f"VERGLEICH: {form_name}")
    print(f"{'='*60}")

    # HTML oeffnen
    open_html_form(form_name)

    # Access analysieren
    if HAS_BRIDGE:
        try:
            with AccessBridge() as bridge:
                analysis = analyze_access_form(bridge, form_name)

                print(f"\n--- ACCESS-ANALYSE ---")
                print(f"Caption: {analysis['properties'].get('Caption', 'N/A')}")
                print(f"RecordSource: {analysis['properties'].get('RecordSource', 'N/A')}")

                print(f"\n--- BUTTONS ({len(analysis['buttons'])}) ---")
                for btn in analysis['buttons']:
                    print(f"  {btn['name']}: '{btn.get('caption', '')}' -> {btn.get('onclick', '')}")

                print(f"\n--- TEXTBOXEN ({len(analysis['textboxes'])}) ---")
                for tb in analysis['textboxes'][:10]:
                    print(f"  {tb['name']}: {tb.get('control_source', '')}")
                if len(analysis['textboxes']) > 10:
                    print(f"  ... und {len(analysis['textboxes'])-10} weitere")

                print(f"\n--- COMBOS ({len(analysis['combos'])}) ---")
                for cb in analysis['combos'][:5]:
                    print(f"  {cb['name']}: {cb.get('row_source', '')[:50]}")

                print(f"\n--- SUBFORMS ({len(analysis['subforms'])}) ---")
                for sf in analysis['subforms']:
                    print(f"  {sf['name']}: {sf.get('source_object', '')}")

                print(f"\n--- TABS ---")
                for tab in analysis['tabs']:
                    print(f"  {tab['name']}: {tab.get('pages', [])}")

                # Bericht speichern
                report_file = os.path.join(REPORT_PATH, f"{form_name}.access_analysis.json")
                with open(report_file, 'w', encoding='utf-8') as f:
                    json.dump(analysis, f, indent=2, ensure_ascii=False)
                print(f"\nAnalyse gespeichert: {report_file}")

                return analysis

        except Exception as e:
            print(f"Fehler bei Access-Analyse: {e}")
            return None
    else:
        print("AccessBridge nicht verfuegbar - nur HTML wird geoeffnet")
        return None

def main():
    if len(sys.argv) > 1:
        form_name = sys.argv[1]
    else:
        # Alle Formulare vergleichen
        for form_name in FORM_MAPPING.keys():
            compare_and_report(form_name)
            print("\nDruecke Enter fuer naechstes Formular...")
            input()
        return

    compare_and_report(form_name)

if __name__ == "__main__":
    main()

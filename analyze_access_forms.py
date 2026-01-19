"""
Access-Formulare Analyse Script
Extrahiert alle Controls, Events, Validierungen und Tab-Order aus allen Formularen
"""
import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

from access_bridge_ultimate import AccessBridge
import json
from datetime import datetime
import os

result = {
    'meta': {
        'extracted': datetime.now().isoformat(),
        'database': '0_Consys_FE_Test.accdb',
        'total_forms': 0,
        'errors': []
    },
    'forms': {}
}

try:
    with AccessBridge() as bridge:
        print('[INFO] Verbindung zu Access hergestellt')

        # Liste aller Formulare
        all_forms = bridge.list_forms()
        result['meta']['total_forms'] = len(all_forms)
        print(f'[INFO] Gefunden: {len(all_forms)} Formulare')

        for idx, form_name in enumerate(all_forms, 1):
            print(f'[{idx}/{len(all_forms)}] Analysiere: {form_name}')

            try:
                form_data = {
                    'name': form_name,
                    'controls': [],
                    'events': {},
                    'validations': [],
                    'tab_order': [],
                    'properties': {}
                }

                # Formular öffnen (Design-Ansicht)
                app = bridge.access_app
                app.DoCmd.OpenForm(form_name, 0)  # 0 = Design View

                frm = app.Forms(form_name)

                # Formular-Properties
                try:
                    form_data['properties']['RecordSource'] = str(frm.RecordSource) if frm.RecordSource else None
                    form_data['properties']['DefaultView'] = int(frm.DefaultView)
                    form_data['properties']['AllowEdits'] = bool(frm.AllowEdits)
                    form_data['properties']['AllowAdditions'] = bool(frm.AllowAdditions)
                    form_data['properties']['AllowDeletions'] = bool(frm.AllowDeletions)
                except Exception as e:
                    print(f'  [WARN] Properties: {e}')

                # Controls durchgehen
                control_count = 0
                for ctrl in frm.Controls:
                    try:
                        ctrl_data = {
                            'Name': str(ctrl.Name),
                            'ControlType': int(ctrl.ControlType)
                        }

                        # ControlType Namen zuordnen
                        ctrl_types = {
                            100: 'Label', 104: 'CommandButton', 109: 'TextBox',
                            110: 'ListBox', 111: 'ComboBox', 106: 'CheckBox',
                            112: 'Subform', 105: 'OptionButton', 122: 'TabControl'
                        }
                        ctrl_data['ControlTypeName'] = ctrl_types.get(int(ctrl.ControlType), f'Type_{ctrl.ControlType}')

                        # Properties je nach Control-Typ
                        try:
                            if hasattr(ctrl, 'ControlSource'):
                                ctrl_data['ControlSource'] = str(ctrl.ControlSource) if ctrl.ControlSource else None
                        except: pass

                        try:
                            if hasattr(ctrl, 'Caption'):
                                ctrl_data['Caption'] = str(ctrl.Caption) if ctrl.Caption else None
                        except: pass

                        try:
                            if hasattr(ctrl, 'RowSource'):
                                ctrl_data['RowSource'] = str(ctrl.RowSource) if ctrl.RowSource else None
                        except: pass

                        try:
                            if hasattr(ctrl, 'ValidationRule'):
                                rule = str(ctrl.ValidationRule) if ctrl.ValidationRule else None
                                if rule:
                                    ctrl_data['ValidationRule'] = rule
                                    ctrl_data['ValidationText'] = str(ctrl.ValidationText) if ctrl.ValidationText else None
                                    form_data['validations'].append({
                                        'Control': str(ctrl.Name),
                                        'Rule': rule,
                                        'Text': str(ctrl.ValidationText) if ctrl.ValidationText else None
                                    })
                        except: pass

                        try:
                            if hasattr(ctrl, 'LimitToList'):
                                ctrl_data['LimitToList'] = bool(ctrl.LimitToList)
                        except: pass

                        try:
                            if hasattr(ctrl, 'Required'):
                                ctrl_data['Required'] = bool(ctrl.Required)
                        except: pass

                        try:
                            if hasattr(ctrl, 'TabIndex'):
                                tab_idx = int(ctrl.TabIndex)
                                ctrl_data['TabIndex'] = tab_idx
                                form_data['tab_order'].append({
                                    'TabIndex': tab_idx,
                                    'Control': str(ctrl.Name)
                                })
                        except: pass

                        # OnClick Event (nur CommandButton)
                        if int(ctrl.ControlType) == 104:
                            try:
                                if hasattr(ctrl, 'OnClick'):
                                    onclick = str(ctrl.OnClick) if ctrl.OnClick else None
                                    if onclick:
                                        ctrl_data['OnClick'] = onclick
                            except: pass

                        form_data['controls'].append(ctrl_data)
                        control_count += 1

                    except Exception as e:
                        print(f'  [WARN] Control: {e}')
                        continue

                print(f'  -> {control_count} Controls extrahiert')

                # VBA Events aus Modul (falls vorhanden)
                try:
                    if frm.HasModule:
                        module = app.VBE.VBProjects(app.CurrentProject.Name).VBComponents(form_name).CodeModule
                        line_count = module.CountOfLines

                        if line_count > 0:
                            code = module.Lines(1, line_count)

                            # Events finden
                            event_markers = [
                                'Private Sub Form_Load()',
                                'Private Sub Form_Current()',
                                'Private Sub Form_BeforeUpdate(',
                                'Private Sub Form_AfterUpdate(',
                                '_Click()',
                                '_AfterUpdate()',
                                '_BeforeUpdate(',
                                '_Change()',
                                '_GotFocus()',
                                '_LostFocus()'
                            ]

                            for marker in event_markers:
                                if marker in code:
                                    # Event-Namen extrahieren
                                    if 'Form_' in marker:
                                        event_name = marker.split('(')[0].replace('Private Sub ', '')
                                        form_data['events'][event_name] = True
                                    else:
                                        # Control-Event
                                        event_type = marker.replace('()', '')
                                        if event_type not in form_data['events']:
                                            form_data['events'][event_type] = []

                            print(f'  -> {len(form_data["events"])} Event-Typen gefunden')

                except Exception as e:
                    print(f'  [WARN] VBA Module: {e}')

                # Tab-Order sortieren
                form_data['tab_order'].sort(key=lambda x: x['TabIndex'])

                # Formular schließen
                app.DoCmd.Close(2, form_name, 2)  # acForm, Save=No

                result['forms'][form_name] = form_data

            except Exception as e:
                error_msg = f'{form_name}: {str(e)}'
                print(f'  [ERROR] {error_msg}')
                result['meta']['errors'].append(error_msg)

                # Versuche Formular zu schließen
                try:
                    app.DoCmd.Close(2, form_name, 2)
                except:
                    pass

                continue

        print(f'[INFO] Analyse abgeschlossen: {len(result["forms"])} Formulare erfolgreich')

except Exception as e:
    print(f'[ERROR] Bridge-Fehler: {e}')
    result['meta']['errors'].append(f'Bridge: {str(e)}')

# Speichern
output_dir = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\_reports'
os.makedirs(output_dir, exist_ok=True)

output_file = os.path.join(output_dir, 'ACCESS_FORMULARE_ANALYSE_2026-01-15.json')
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(result, f, indent=2, ensure_ascii=False)

print(f'[SUCCESS] Gespeichert: {output_file}')
print(f'[SUMMARY] {result["meta"]["total_forms"]} Formulare, {len(result["forms"])} erfolgreich, {len(result["meta"]["errors"])} Fehler')

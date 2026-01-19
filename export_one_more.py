"""
Export eines weiteren Formulars als Ersatz
"""
import sys
import os

sys.path.append(r'C:\Users\guenther.siegert\Documents\Access Bridge')
from access_bridge_ultimate import AccessBridge

# Alternatives Formular (statt frm_Rechnungen_bezahlt_offen)
FORM_NAME = 'frmTop_RechnungsStamm'

OUTPUT_DIR = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\Access_Abgleich\forms'

def get_color_name(color_value):
    if color_value is None:
        return "-"
    color_map = {
        16777215: "Weiss", 0: "Schwarz", 8355711: "Grau",
        4210752: "Dunkelgrau", 10921638: "Hellgrau", 8210719: "Blau",
        255: "Rot", 65280: "Gruen", 16777088: "Gelb"
    }
    return f"{color_value} ({color_map.get(color_value, 'Unbekannt')})"

def get_view_name(view_value):
    view_map = {
        0: "SingleForm", 1: "Continuous", 2: "Datasheet",
        3: "PivotTable", 4: "PivotChart", 5: "SplitForm"
    }
    return view_map.get(view_value, f"Unknown ({view_value})")

def get_control_type_name(ctrl):
    try:
        type_value = ctrl.ControlType
        type_map = {
            100: "Label", 104: "CommandButton", 109: "TextBox",
            110: "ListBox", 111: "ComboBox", 112: "Subform",
            106: "OptionButton", 107: "OptionGroup", 108: "CheckBox",
            103: "ToggleButton", 114: "Image", 105: "BoundObjectFrame",
            113: "TabControl", 122: "Rectangle", 118: "Line"
        }
        return type_map.get(type_value, f"Unknown ({type_value})")
    except:
        return "Unknown"

with AccessBridge() as bridge:
    print(f"Exportiere {FORM_NAME}...")

    app = bridge.access_app
    app.DoCmd.OpenForm(FORM_NAME, 0)
    frm = app.Forms(FORM_NAME)

    md_content = f"# {FORM_NAME}\n\n"
    md_content += "## Formular-Metadaten\n\n"
    md_content += "| Eigenschaft | Wert |\n|-------------|------|\n"
    md_content += f"| **Name** | {FORM_NAME} |\n"

    try:
        record_source = frm.RecordSource if frm.RecordSource else "-"
        md_content += f"| **Datensatzquelle** | {record_source} |\n"

        if record_source and record_source != "-":
            if record_source.upper().startswith("SELECT"):
                md_content += f"| **Datenquellentyp** | SQL |\n"
            elif "qry_" in record_source.lower():
                md_content += f"| **Datenquellentyp** | Query |\n"
            elif "tbl_" in record_source.lower():
                md_content += f"| **Datenquellentyp** | Table |\n"
    except:
        md_content += f"| **Datensatzquelle** | - |\n"

    try: md_content += f"| **Default View** | {get_view_name(frm.DefaultView)} |\n"
    except: md_content += f"| **Default View** | - |\n"

    try: md_content += f"| **Allow Edits** | {'Ja' if frm.AllowEdits else 'Nein'} |\n"
    except: md_content += f"| **Allow Edits** | - |\n"

    try: md_content += f"| **Allow Additions** | {'Ja' if frm.AllowAdditions else 'Nein'} |\n"
    except: md_content += f"| **Allow Additions** | - |\n"

    try: md_content += f"| **Allow Deletions** | {'Ja' if frm.AllowDeletions else 'Nein'} |\n"
    except: md_content += f"| **Allow Deletions** | - |\n"

    try: md_content += f"| **Data Entry** | {'Ja' if frm.DataEntry else 'Nein'} |\n"
    except: md_content += f"| **Data Entry** | - |\n"

    try: md_content += f"| **Navigation Buttons** | {'Ja' if frm.NavigationButtons else 'Nein'} |\n"
    except: md_content += f"| **Navigation Buttons** | - |\n"

    md_content += "\n## Controls\n\n"

    controls_by_type = {}

    for ctrl in frm.Controls:
        try:
            ctrl_type = get_control_type_name(ctrl)
            if ctrl_type not in controls_by_type:
                controls_by_type[ctrl_type] = []

            ctrl_info = {'name': ctrl.Name, 'type': ctrl_type}

            try: ctrl_info['control_source'] = ctrl.ControlSource if ctrl.ControlSource else "-"
            except: ctrl_info['control_source'] = "-"

            try: ctrl_info['caption'] = ctrl.Caption if ctrl.Caption else "-"
            except: ctrl_info['caption'] = "-"

            try:
                ctrl_info['left'] = ctrl.Left
                ctrl_info['top'] = ctrl.Top
                ctrl_info['width'] = ctrl.Width
                ctrl_info['height'] = ctrl.Height
            except:
                ctrl_info['left'] = "-"
                ctrl_info['top'] = "-"
                ctrl_info['width'] = "-"
                ctrl_info['height'] = "-"

            try: ctrl_info['forecolor'] = get_color_name(ctrl.ForeColor)
            except: ctrl_info['forecolor'] = "-"

            try: ctrl_info['backcolor'] = get_color_name(ctrl.BackColor)
            except: ctrl_info['backcolor'] = "-"

            try: ctrl_info['tab_index'] = ctrl.TabIndex
            except: ctrl_info['tab_index'] = "-"

            events = []
            event_props = ['OnClick', 'AfterUpdate', 'BeforeUpdate', 'OnChange',
                          'OnDblClick', 'OnEnter', 'OnExit', 'GotFocus', 'LostFocus']

            for event_prop in event_props:
                try:
                    event_val = getattr(ctrl, event_prop, None)
                    if event_val and str(event_val).strip():
                        events.append(f"{event_prop}: {event_val}")
                except:
                    pass

            ctrl_info['events'] = events
            controls_by_type[ctrl_type].append(ctrl_info)
        except:
            pass

    for ctrl_type in sorted(controls_by_type.keys()):
        ctrls = controls_by_type[ctrl_type]

        if ctrl_type == "Label":
            md_content += f"### Labels (Bezeichnungsfelder)\n\n"
            md_content += "| Name | Position (L/T) | Groesse (W/H) | ForeColor |\n"
            md_content += "|------|----------------|---------------|-----------||\n"
            for ctrl in ctrls:
                md_content += f"| {ctrl['name']} | {ctrl['left']} / {ctrl['top']} | {ctrl['width']} x {ctrl['height']} | {ctrl['forecolor']} |\n"

        elif ctrl_type == "TextBox":
            md_content += f"\n### TextBoxen\n\n"
            md_content += "| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex |\n"
            md_content += "|------|----------------|----------------|---------------|----------||\n"
            for ctrl in ctrls:
                md_content += f"| {ctrl['name']} | {ctrl['control_source']} | {ctrl['left']} / {ctrl['top']} | {ctrl['width']} x {ctrl['height']} | {ctrl['tab_index']} |\n"

        elif ctrl_type == "CommandButton":
            md_content += f"\n### Buttons (Schaltflaechen)\n\n"
            md_content += "| Name | Caption | Position (L/T) | Groesse (W/H) | Events |\n"
            md_content += "|------|---------|----------------|---------------|--------|\n"
            for ctrl in ctrls:
                events_str = "; ".join(ctrl['events']) if ctrl['events'] else "-"
                md_content += f"| {ctrl['name']} | {ctrl['caption']} | {ctrl['left']} / {ctrl['top']} | {ctrl['width']} x {ctrl['height']} | {events_str} |\n"

        elif ctrl_type == "ComboBox":
            md_content += f"\n### ComboBoxen (Auswahllisten)\n\n"
            md_content += "| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex |\n"
            md_content += "|------|----------------|----------------|---------------|----------|\n"
            for ctrl in ctrls:
                md_content += f"| {ctrl['name']} | {ctrl['control_source']} | {ctrl['left']} / {ctrl['top']} | {ctrl['width']} x {ctrl['height']} | {ctrl['tab_index']} |\n"

        elif ctrl_type == "Subform":
            md_content += f"\n### Subforms (Unterformulare)\n\n"
            md_content += "| Name | Source Object | Position (L/T) | Groesse (W/H) |\n"
            md_content += "|------|---------------|----------------|---------------|\n"
            for ctrl in ctrls:
                md_content += f"| {ctrl['name']} | {ctrl['control_source']} | {ctrl['left']} / {ctrl['top']} | {ctrl['width']} x {ctrl['height']} |\n"

        else:
            md_content += f"\n### {ctrl_type}s\n\n"
            md_content += "| Name | Caption | Position (L/T) | Groesse (W/H) |\n"
            md_content += "|------|---------|----------------|---------------|\n"
            for ctrl in ctrls:
                md_content += f"| {ctrl['name']} | {ctrl['caption']} | {ctrl['left']} / {ctrl['top']} | {ctrl['width']} x {ctrl['height']} |\n"

    md_content += "\n## Events\n\n### Formular-Events\n"

    form_event_props = ['OnOpen', 'OnLoad', 'OnClose', 'OnCurrent',
                       'BeforeUpdate', 'AfterUpdate', 'OnActivate', 'OnDeactivate']

    for event_prop in form_event_props:
        try:
            event_val = getattr(frm, event_prop, None)
            if event_val and str(event_val).strip():
                md_content += f"- {event_prop}: {event_val}\n"
            else:
                md_content += f"- {event_prop}: Keine\n"
        except:
            md_content += f"- {event_prop}: Keine\n"

    md_content += "\n## VBA-Code\n\n"

    try:
        if frm.HasModule:
            md_content += "```vba\n"
            try:
                vba_project = app.VBE.ActiveVBProject
                for component in vba_project.VBComponents:
                    if component.Name == f"Form_{FORM_NAME}":
                        code_module = component.CodeModule
                        line_count = code_module.CountOfLines
                        if line_count > 0:
                            vba_code = code_module.Lines(1, line_count)
                            md_content += vba_code
                        break
            except Exception as e:
                md_content += f"' VBA-Code konnte nicht extrahiert werden: {e}\n"
            md_content += "```\n"
        else:
            md_content += "Kein VBA-Code vorhanden.\n"
    except:
        md_content += "VBA-Status konnte nicht ermittelt werden.\n"

    app.DoCmd.Close(2, FORM_NAME, 2)

    output_path = os.path.join(OUTPUT_DIR, f"{FORM_NAME}.md")
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(md_content)

    print(f"OK Exportiert nach: {output_path}")

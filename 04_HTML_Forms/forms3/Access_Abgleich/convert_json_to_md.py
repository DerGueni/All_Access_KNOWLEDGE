# -*- coding: utf-8 -*-
"""
Konvertiert Access JSON-Exports zu Markdown-Dokumentation
"""
import json
import os
from pathlib import Path

# Pfade
BASE_PATH = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE")
JSON_PATH = BASE_PATH / "11_json_Export" / "000_Consys_Eport_11_25" / "30_forms"
SUBFORMS_PATH = BASE_PATH / "11_json_Export" / "000_Consys_Eport_11_25" / "35_subforms"
OUTPUT_PATH = BASE_PATH / "04_HTML_Forms" / "forms3" / "Access_Abgleich" / "forms"

# Zu verarbeitende Formulare
FORMS = [
    ("frm_VA_Auftragstamm", "FRM_frm_VA_Auftragstamm.json"),
    ("frm_MA_Mitarbeiterstamm", "FRM_frm_MA_Mitarbeiterstamm.json"),
    ("frm_KD_Kundenstamm", "FRM_frm_KD_Kundenstamm.json"),
    ("frm_OB_Objekt", "FRM_frm_OB_Objekt.json"),
]

def load_json(filepath):
    """Laedt JSON-Datei mit verschiedenen Encodings und fixt deutsche Booleans"""
    # Versuche verschiedene Encodings
    for encoding in ['utf-8', 'cp1252', 'latin-1']:
        try:
            with open(filepath, 'r', encoding=encoding) as f:
                content = f.read()
            break
        except UnicodeDecodeError:
            continue
    else:
        raise ValueError(f"Konnte Datei nicht lesen: {filepath}")

    # Fixe deutsche Booleans (ohne Anfuehrungszeichen)
    import re
    # Ersetze :wahr, :falsch (case-insensitive)
    content = re.sub(r':wahr\b', ':true', content, flags=re.IGNORECASE)
    content = re.sub(r':falsch\b', ':false', content, flags=re.IGNORECASE)

    return json.loads(content)

def get_form_events(data):
    """Extrahiert Formular-Events"""
    events = data.get('events', {})
    result = []
    for event_name, event_data in events.items():
        if event_data:
            kind = event_data.get('kind', '')
            handler = event_data.get('handler', '') or event_data.get('macro', '')
            if kind or handler:
                result.append((event_name, kind, handler))
    return result

def categorize_controls(controls):
    """Kategorisiert Controls nach Typ"""
    buttons = []
    textboxes = []
    comboboxes = []
    listboxes = []
    subforms = []
    labels = []
    tabs = []
    checkboxes = []
    optiongroups = []
    other = []

    for ctrl in controls:
        ctrl_type = ctrl.get('type', 'Unknown')
        name = ctrl.get('name', 'Unbenannt')

        if ctrl_type == 'CommandButton':
            buttons.append(ctrl)
        elif ctrl_type == 'TextBox':
            textboxes.append(ctrl)
        elif ctrl_type == 'ComboBox':
            comboboxes.append(ctrl)
        elif ctrl_type == 'ListBox':
            listboxes.append(ctrl)
        elif ctrl_type == 'SubForm':
            subforms.append(ctrl)
        elif ctrl_type == 'Label':
            labels.append(ctrl)
        elif ctrl_type == 'TabControl':
            tabs.append(ctrl)
        elif ctrl_type == 'CheckBox':
            checkboxes.append(ctrl)
        elif ctrl_type == 'OptionGroup':
            optiongroups.append(ctrl)
        else:
            other.append(ctrl)

    return {
        'buttons': buttons,
        'textboxes': textboxes,
        'comboboxes': comboboxes,
        'listboxes': listboxes,
        'subforms': subforms,
        'labels': labels,
        'tabs': tabs,
        'checkboxes': checkboxes,
        'optiongroups': optiongroups,
        'other': other
    }

def get_onclick_handler(ctrl):
    """Extrahiert OnClick Handler"""
    events = ctrl.get('events', {})
    onclick = events.get('OnClick', {})
    if onclick:
        kind = onclick.get('kind', '')
        handler = onclick.get('handler', '') or onclick.get('macro', '')
        if kind == 'Procedure':
            return f"VBA: {handler}"
        elif kind == 'Macro' and handler:
            return f"Makro: {handler}"
    return ""

def get_control_events(ctrl):
    """Extrahiert alle relevanten Events eines Controls"""
    events = ctrl.get('events', {})
    result = []
    for event_name in ['OnClick', 'OnDblClick', 'OnChange', 'AfterUpdate', 'BeforeUpdate']:
        event_data = events.get(event_name, {})
        if event_data:
            kind = event_data.get('kind', '')
            handler = event_data.get('handler', '') or event_data.get('macro', '')
            if handler:
                result.append(f"{event_name}: {kind}")
    return ", ".join(result) if result else "-"

def escape_md(text):
    """Escaped Markdown-Sonderzeichen in Tabellenzellen"""
    if text is None:
        return ""
    text = str(text)
    # Pipe-Zeichen escapen
    text = text.replace("|", "\\|")
    # Newlines durch Leerzeichen ersetzen
    text = text.replace("\n", " ").replace("\r", "")
    return text

def generate_markdown(form_name, data):
    """Generiert Markdown-Dokumentation fuer ein Formular"""
    lines = []

    # Header
    lines.append(f"# Access-Export: {form_name}")
    lines.append("")
    lines.append(f"*Generiert aus JSON-Export*")
    lines.append("")

    # Formular-Eigenschaften
    lines.append("## Formular-Eigenschaften")
    lines.append("")
    lines.append("| Eigenschaft | Wert |")
    lines.append("|-------------|------|")

    # RecordSource
    record_source = data.get('record_source', {})
    rs_type = record_source.get('type', '-')
    rs_ref = record_source.get('ref', '-')
    lines.append(f"| RecordSource | {escape_md(rs_ref)} ({rs_type}) |")

    # Properties
    props = data.get('properties', {})
    for prop_name in ['AllowEdits', 'AllowAdditions', 'AllowDeletions', 'DataEntry',
                      'DefaultView', 'NavigationButtons', 'Filter', 'OrderBy']:
        if prop_name in props:
            lines.append(f"| {prop_name} | {escape_md(str(props[prop_name]))} |")

    lines.append("")

    # Formular-Events
    lines.append("## Formular-Events")
    lines.append("")
    form_events = get_form_events(data)
    if form_events:
        lines.append("| Event | Kind | Handler |")
        lines.append("|-------|------|---------|")
        for event_name, kind, handler in form_events:
            lines.append(f"| {event_name} | {kind} | {escape_md(handler)} |")
    else:
        lines.append("*Keine Events definiert*")
    lines.append("")

    # Controls
    controls = data.get('controls', [])
    categorized = categorize_controls(controls)
    total_controls = len(controls)

    lines.append(f"## Controls ({total_controls} Stueck)")
    lines.append("")

    # Buttons
    buttons = categorized['buttons']
    if buttons:
        lines.append(f"### Buttons ({len(buttons)} Stueck)")
        lines.append("")
        lines.append("| Name | Caption | OnClick | Enabled | Visible |")
        lines.append("|------|---------|---------|---------|---------|")
        for btn in buttons:
            name = btn.get('name', '')
            props = btn.get('properties', {})
            caption = props.get('Caption', '-')
            onclick = get_onclick_handler(btn)
            enabled = props.get('Enabled', 'Wahr')
            visible = props.get('Visible', 'Wahr')
            lines.append(f"| {escape_md(name)} | {escape_md(caption)} | {escape_md(onclick)} | {escape_md(enabled)} | {escape_md(visible)} |")
        lines.append("")

    # TextBoxen
    textboxes = categorized['textboxes']
    if textboxes:
        lines.append(f"### TextBoxen ({len(textboxes)} Stueck)")
        lines.append("")
        lines.append("| Name | ControlSource | Format | DefaultValue | Events |")
        lines.append("|------|---------------|--------|--------------|--------|")
        for tb in textboxes:
            name = tb.get('name', '')
            ctrl_source = tb.get('control_source', '-')
            props = tb.get('properties', {})
            fmt = props.get('Format', '-')
            default = props.get('DefaultValue', '-')
            events = get_control_events(tb)
            lines.append(f"| {escape_md(name)} | {escape_md(ctrl_source)} | {escape_md(fmt)} | {escape_md(default)} | {escape_md(events)} |")
        lines.append("")

    # ComboBoxen
    comboboxes = categorized['comboboxes']
    if comboboxes:
        lines.append(f"### ComboBoxen ({len(comboboxes)} Stueck)")
        lines.append("")
        lines.append("| Name | ControlSource | RowSource | BoundColumn | Events |")
        lines.append("|------|---------------|-----------|-------------|--------|")
        for cb in comboboxes:
            name = cb.get('name', '')
            ctrl_source = cb.get('control_source', '-')
            row_source = cb.get('row_source', {})
            rs_ref = row_source.get('ref', '-') if isinstance(row_source, dict) else str(row_source)
            list_props = cb.get('list_props', {})
            bound_col = list_props.get('BoundColumn', '-')
            events = get_control_events(cb)
            # Kuerze lange RowSource
            if len(rs_ref) > 50:
                rs_ref = rs_ref[:50] + "..."
            lines.append(f"| {escape_md(name)} | {escape_md(ctrl_source)} | {escape_md(rs_ref)} | {escape_md(bound_col)} | {escape_md(events)} |")
        lines.append("")

    # ListBoxen
    listboxes = categorized['listboxes']
    if listboxes:
        lines.append(f"### ListBoxen ({len(listboxes)} Stueck)")
        lines.append("")
        lines.append("| Name | RowSource | ColumnCount | Events |")
        lines.append("|------|-----------|-------------|--------|")
        for lb in listboxes:
            name = lb.get('name', '')
            row_source = lb.get('row_source', {})
            rs_ref = row_source.get('ref', '-') if isinstance(row_source, dict) else str(row_source)
            list_props = lb.get('list_props', {})
            col_count = list_props.get('ColumnCount', '-')
            events = get_control_events(lb)
            if len(rs_ref) > 50:
                rs_ref = rs_ref[:50] + "..."
            lines.append(f"| {escape_md(name)} | {escape_md(rs_ref)} | {escape_md(col_count)} | {escape_md(events)} |")
        lines.append("")

    # Unterformulare
    subforms = categorized['subforms']
    if subforms:
        lines.append(f"### Unterformulare ({len(subforms)} Stueck)")
        lines.append("")
        lines.append("| Name | SourceObject | LinkMasterFields | LinkChildFields |")
        lines.append("|------|--------------|------------------|-----------------|")
        for sf in subforms:
            name = sf.get('name', '')
            subform_info = sf.get('subform', {})
            source_obj = subform_info.get('source_object', '-')
            link_master = ", ".join(subform_info.get('link_master_fields', []))
            link_child = ", ".join(subform_info.get('link_child_fields', []))
            lines.append(f"| {escape_md(name)} | {escape_md(source_obj)} | {escape_md(link_master)} | {escape_md(link_child)} |")
        lines.append("")

    # Tabs
    tabs = categorized['tabs']
    if tabs:
        lines.append(f"### TabControls ({len(tabs)} Stueck)")
        lines.append("")
        lines.append("| Name | Visible | TabIndex |")
        lines.append("|------|---------|----------|")
        for tab in tabs:
            name = tab.get('name', '')
            props = tab.get('properties', {})
            visible = props.get('Visible', 'Wahr')
            tab_idx = props.get('TabIndex', '-')
            lines.append(f"| {escape_md(name)} | {escape_md(visible)} | {escape_md(tab_idx)} |")
        lines.append("")

    # CheckBoxen
    checkboxes = categorized['checkboxes']
    if checkboxes:
        lines.append(f"### CheckBoxen ({len(checkboxes)} Stueck)")
        lines.append("")
        lines.append("| Name | ControlSource | DefaultValue | Events |")
        lines.append("|------|---------------|--------------|--------|")
        for chk in checkboxes:
            name = chk.get('name', '')
            ctrl_source = chk.get('control_source', '-')
            props = chk.get('properties', {})
            default = props.get('DefaultValue', '-')
            events = get_control_events(chk)
            lines.append(f"| {escape_md(name)} | {escape_md(ctrl_source)} | {escape_md(default)} | {escape_md(events)} |")
        lines.append("")

    # Labels (nur Anzahl)
    labels = categorized['labels']
    if labels:
        lines.append(f"### Labels ({len(labels)} Stueck)")
        lines.append("")
        lines.append("*Labels werden nicht im Detail aufgelistet*")
        lines.append("")

    # Andere Controls
    other = categorized['other']
    if other:
        lines.append(f"### Andere Controls ({len(other)} Stueck)")
        lines.append("")
        lines.append("| Name | Typ |")
        lines.append("|------|-----|")
        for ctrl in other:
            name = ctrl.get('name', '')
            ctrl_type = ctrl.get('type', 'Unknown')
            lines.append(f"| {escape_md(name)} | {escape_md(ctrl_type)} |")
        lines.append("")

    # Zusammenfassung
    lines.append("## Zusammenfassung")
    lines.append("")
    lines.append(f"- **Gesamt Controls:** {total_controls}")
    lines.append(f"- **Buttons:** {len(buttons)}")
    lines.append(f"- **TextBoxen:** {len(textboxes)}")
    lines.append(f"- **ComboBoxen:** {len(comboboxes)}")
    lines.append(f"- **ListBoxen:** {len(listboxes)}")
    lines.append(f"- **Unterformulare:** {len(subforms)}")
    lines.append(f"- **Labels:** {len(labels)}")
    lines.append(f"- **Andere:** {len(other)}")
    lines.append("")

    return "\n".join(lines)

def main():
    """Hauptfunktion"""
    # Output-Verzeichnis erstellen
    OUTPUT_PATH.mkdir(parents=True, exist_ok=True)

    for form_name, json_file in FORMS:
        json_path = JSON_PATH / json_file

        if not json_path.exists():
            print(f"FEHLER: {json_path} nicht gefunden!")
            continue

        print(f"Verarbeite {form_name}...")

        try:
            data = load_json(json_path)
            markdown = generate_markdown(form_name, data)

            output_file = OUTPUT_PATH / f"{form_name}.md"
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(markdown)

            print(f"  -> {output_file} erstellt")

        except Exception as e:
            print(f"FEHLER bei {form_name}: {e}")

    print("\nFertig!")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Parst alle Access-Export MD-Dateien und erstellt ein Master-Inventar
"""

import re
from pathlib import Path
from collections import defaultdict
import json

def parse_md_file(md_file):
    """Parst eine einzelne MD-Datei und extrahiert Statistiken"""
    try:
        content = md_file.read_text(encoding='utf-8')
    except:
        return None

    form_name = md_file.stem
    is_subform = md_file.parent.name == 'subforms'

    # RecordSource extrahieren
    record_source = ''
    patterns = [
        r'\|\s*RecordSource\s*\|\s*(.+?)\s*\|',
        r'\*\*RecordSource\*\*:\s*(.+)',
        r'\*\*Datensatzquelle\*\*\s*\|\s*(.+?)\s*\|',
        r'RecordSource.*?:\s*(.+)',
    ]
    for pattern in patterns:
        rs_match = re.search(pattern, content, re.IGNORECASE)
        if rs_match:
            record_source = rs_match.group(1).strip()
            break

    # Controls zählen - Variante 1: "## Controls (136 Stueck)"
    controls_total = 0
    buttons = 0
    textboxes = 0
    comboboxes = 0
    subforms_count = 0
    labels = 0
    listboxes = 0
    tabs = 0

    controls_match = re.search(r'##\s*Controls\s*\((\d+)\s*Stueck\)', content)
    if controls_match:
        controls_total = int(controls_match.group(1))

        # Detaillierte Control-Counts
        btn_match = re.search(r'###\s*Buttons\s*\((\d+)\s*Stueck\)', content)
        if btn_match:
            buttons = int(btn_match.group(1))

        txt_match = re.search(r'###\s*TextBoxen\s*\((\d+)\s*Stueck\)', content)
        if txt_match:
            textboxes = int(txt_match.group(1))

        cbo_match = re.search(r'###\s*ComboBoxen\s*\((\d+)\s*Stueck\)', content)
        if cbo_match:
            comboboxes = int(cbo_match.group(1))

        sub_match = re.search(r'###\s*SubForm.*?\((\d+)\s*Stueck\)', content)
        if sub_match:
            subforms_count = int(sub_match.group(1))

        lbl_match = re.search(r'###\s*Labels\s*\((\d+)\s*Stueck\)', content)
        if lbl_match:
            labels = int(lbl_match.group(1))

        lst_match = re.search(r'###\s*ListBoxen\s*\((\d+)\s*Stueck\)', content)
        if lst_match:
            listboxes = int(lst_match.group(1))

        tab_match = re.search(r'###\s*Tab.*?Controls?\s*\((\d+)\s*Stueck\)', content)
        if tab_match:
            tabs = int(tab_match.group(1))
    else:
        # Variante 2: Controls manuell zählen aus Tabellen
        # Zähle Tabellenzeilen nach "### Labels", "### TextBoxen", etc.

        # Labels
        lbl_section = re.search(r'###\s*Labels.*?\n(.*?)\n###', content, re.DOTALL | re.IGNORECASE)
        if lbl_section:
            # Zähle Zeilen die mit "|" starten (Tabellenzeilen, ohne Header)
            table_lines = [line for line in lbl_section.group(1).split('\n')
                          if line.strip().startswith('|') and not '---' in line]
            labels = max(0, len(table_lines) - 1)  # -1 für Header

        # TextBoxen
        txt_section = re.search(r'###\s*TextBoxen.*?\n(.*?)(?:\n###|\Z)', content, re.DOTALL | re.IGNORECASE)
        if txt_section:
            table_lines = [line for line in txt_section.group(1).split('\n')
                          if line.strip().startswith('|') and not '---' in line]
            textboxes = max(0, len(table_lines) - 1)

        # ComboBoxen
        cbo_section = re.search(r'###\s*ComboBoxen.*?\n(.*?)(?:\n###|\Z)', content, re.DOTALL | re.IGNORECASE)
        if cbo_section:
            table_lines = [line for line in cbo_section.group(1).split('\n')
                          if line.strip().startswith('|') and not '---' in line]
            comboboxes = max(0, len(table_lines) - 1)

        # Buttons
        btn_section = re.search(r'###\s*Buttons.*?\n(.*?)(?:\n###|\Z)', content, re.DOTALL | re.IGNORECASE)
        if btn_section:
            table_lines = [line for line in btn_section.group(1).split('\n')
                          if line.strip().startswith('|') and not '---' in line]
            buttons = max(0, len(table_lines) - 1)

        # Total berechnen
        controls_total = labels + textboxes + comboboxes + buttons + subforms_count + listboxes + tabs

    # Events zählen
    events = {}
    events_total = 0

    # Formular-Events Section
    in_form_events = False
    for line in content.split('\n'):
        if '## Formular-Events' in line or '## Events' in line:
            in_form_events = True
        elif line.startswith('##') and not ('Events' in line):
            in_form_events = False
        elif in_form_events and line.startswith('|') and 'Procedure' in line:
            # Event-Zeile: | OnLoad | Procedure | (auto) |
            parts = [p.strip() for p in line.split('|')]
            if len(parts) >= 3 and parts[1] and parts[2] == 'Procedure':
                event_type = parts[1]
                events[event_type] = events.get(event_type, 0) + 1
                events_total += 1
        elif in_form_events and ('**On' in line or '- On' in line):
            # Alternative Formate: "**OnLoad**", "- OnLoad: Procedure"
            evt_match = re.search(r'\*\*(On\w+)\*\*|^-\s+(On\w+):', line)
            if evt_match:
                event_type = evt_match.group(1) or evt_match.group(2)
                if 'Procedure' in line or '(auto)' in line:
                    events[event_type] = events.get(event_type, 0) + 1
                    events_total += 1

    # VBA-Zeilen schätzen (50 Zeilen pro Event)
    vba_lines = events_total * 50

    return {
        'name': form_name,
        'is_subform': is_subform,
        'controls_total': controls_total,
        'buttons': buttons,
        'textboxes': textboxes,
        'comboboxes': comboboxes,
        'subforms': subforms_count,
        'labels': labels,
        'listboxes': listboxes,
        'tabs': tabs,
        'events': events,
        'events_total': events_total,
        'vba_lines': vba_lines,
        'record_source': record_source
    }


def categorize_form(form_name):
    """Kategorisiert ein Formular nach Namen"""
    name = form_name.lower()

    if 'va_' in name or name.startswith('sub_va'):
        return 'Auftraege'
    elif 'ma_' in name or name.startswith('sub_ma'):
        return 'Mitarbeiter'
    elif 'kd_' in name:
        return 'Kunden'
    elif 'ob_' in name or name.startswith('sub_ob'):
        return 'Objekte'
    elif 'dp_' in name or name.startswith('sub_dp'):
        return 'Dienstplan'
    elif 'ausweis' in name or 'angebot' in name or 'rechnung' in name or 'rch_' in name:
        return 'Dokumente'
    elif name.startswith('zfrm') or name.startswith('frmtop') or name.startswith('frmoff'):
        return 'System'
    else:
        return 'Sonstiges'


def main():
    forms_dir = Path('forms')
    subforms_dir = Path('subforms')

    all_data = []

    # Parse alle Formulare
    for md_file in list(forms_dir.glob('*.md')) + list(subforms_dir.glob('*.md')):
        if md_file.name in ['EXPORT_STATUS.md', 'INDEX.md']:
            continue

        form_data = parse_md_file(md_file)
        if form_data:
            all_data.append(form_data)

    # Nach Name sortieren
    all_data.sort(key=lambda x: (not x['is_subform'], x['name']))

    # JSON speichern
    with open('inventory_data.json', 'w', encoding='utf-8') as f:
        json.dump(all_data, f, indent=2, ensure_ascii=False)

    print(f"Parsed {len(all_data)} Formulare")
    print(f"JSON gespeichert: inventory_data.json")

    # Statistiken berechnen
    total_forms = len([f for f in all_data if not f['is_subform']])
    total_subforms = len([f for f in all_data if f['is_subform']])
    total_controls = sum(f['controls_total'] for f in all_data)
    total_events = sum(f['events_total'] for f in all_data)

    print(f"\nStatistiken:")
    print(f"  Hauptformulare: {total_forms}")
    print(f"  Subformulare: {total_subforms}")
    print(f"  Controls gesamt: {total_controls}")
    print(f"  Events gesamt: {total_events}")

    # Top 10 größte Formulare
    largest = sorted(all_data, key=lambda x: x['controls_total'], reverse=True)[:10]
    print(f"\nTop 10 größte Formulare:")
    for i, f in enumerate(largest, 1):
        print(f"  {i}. {f['name']}: {f['controls_total']} Controls")

    # Top 10 komplexeste Formulare
    most_complex = sorted(all_data, key=lambda x: x['events_total'], reverse=True)[:10]
    print(f"\nTop 10 komplexeste Formulare (Events):")
    for i, f in enumerate(most_complex, 1):
        print(f"  {i}. {f['name']}: {f['events_total']} Events")

    # Kategorien
    categories = defaultdict(list)
    for f in all_data:
        cat = categorize_form(f['name'])
        categories[cat].append(f)

    print(f"\nFormulare nach Kategorie:")
    for cat, forms in sorted(categories.items()):
        controls = sum(f['controls_total'] for f in forms)
        events = sum(f['events_total'] for f in forms)
        print(f"  {cat}: {len(forms)} Formulare, {controls} Controls, {events} Events")


if __name__ == '__main__':
    main()

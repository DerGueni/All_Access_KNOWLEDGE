#!/usr/bin/env python3
"""
Generiert MASTER_INVENTORY.md aus inventory_data.json
"""

import json
from datetime import datetime
from collections import defaultdict

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
    # JSON laden
    with open('inventory_data.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Statistiken berechnen
    total_forms = len([f for f in data if not f['is_subform']])
    total_subforms = len([f for f in data if f['is_subform']])
    total_controls = sum(f['controls_total'] for f in data)
    total_events = sum(f['events_total'] for f in data)
    total_buttons = sum(f['buttons'] for f in data)
    total_textboxes = sum(f['textboxes'] for f in data)
    total_comboboxes = sum(f['comboboxes'] for f in data)
    total_labels = sum(f['labels'] for f in data)
    total_subform_controls = sum(f['subforms'] for f in data)  # Subform-Controls (nicht Anzahl Subformulare!)
    total_listboxes = sum(f['listboxes'] for f in data)
    total_tabs = sum(f['tabs'] for f in data)

    # Event-Typen sammeln
    event_types = defaultdict(int)
    for f in data:
        for event, count in f['events'].items():
            event_types[event] += count

    # Kategorien gruppieren
    categories = defaultdict(list)
    for f in data:
        cat = categorize_form(f['name'])
        categories[cat].append(f)

    # Top 10 Listen
    largest = sorted(data, key=lambda x: x['controls_total'], reverse=True)[:10]
    most_complex = sorted(data, key=lambda x: x['events_total'], reverse=True)[:10]
    most_buttons = sorted(data, key=lambda x: x['buttons'], reverse=True)[:10]

    # Markdown generieren
    md = []
    md.append('# Access-Formulare Master-Inventar')
    md.append('')
    md.append(f'**Exportiert:** {datetime.now().strftime("%Y-%m-%d")}')
    md.append(f'**Anzahl Formulare:** {total_forms + total_subforms} ({total_forms} Haupt + {total_subforms} Sub)')
    md.append(f'**Anzahl Controls gesamt:** {total_controls:,}')
    md.append(f'**Anzahl Events gesamt:** {total_events}')
    md.append('')

    # Übersicht nach Kategorie
    md.append('## Übersicht nach Kategorie')
    md.append('')
    for cat in sorted(categories.keys()):
        forms = categories[cat]
        controls = sum(f['controls_total'] for f in forms)
        events = sum(f['events_total'] for f in forms)
        buttons = sum(f['buttons'] for f in forms)
        main_count = len([f for f in forms if not f['is_subform']])
        sub_count = len([f for f in forms if f['is_subform']])

        md.append(f'### {cat} ({len(forms)} Formulare: {main_count} Haupt + {sub_count} Sub)')
        md.append('')
        md.append('| Formular | Typ | Controls | Events | Buttons | TextBoxen | ComboBoxen | RecordSource |')
        md.append('|----------|-----|----------|--------|---------|-----------|------------|--------------|')

        for f in sorted(forms, key=lambda x: (x['is_subform'], x['name'])):
            typ = 'Sub' if f['is_subform'] else 'Haupt'
            rs = f['record_source'][:50] + '...' if len(f['record_source']) > 50 else f['record_source']
            md.append(f"| {f['name']} | {typ} | {f['controls_total']} | {f['events_total']} | {f['buttons']} | {f['textboxes']} | {f['comboboxes']} | {rs} |")

        md.append('')
        md.append(f'**Summe:** {controls} Controls, {events} Events, {buttons} Buttons')
        md.append('')

    # Control-Statistik
    md.append('## Control-Statistik')
    md.append('')
    md.append('| Control-Typ | Anzahl Gesamt | Mit Events | Durchschnitt pro Formular |')
    md.append('|-------------|---------------|------------|---------------------------|')

    controls_with_events = sum(1 for f in data if f['buttons'] > 0 and f['events_total'] > 0)
    md.append(f'| CommandButton | {total_buttons:,} | {controls_with_events} | {total_buttons / len(data):.1f} |')
    md.append(f'| TextBox | {total_textboxes:,} | - | {total_textboxes / len(data):.1f} |')
    md.append(f'| ComboBox | {total_comboboxes:,} | - | {total_comboboxes / len(data):.1f} |')
    md.append(f'| Label | {total_labels:,} | - | {total_labels / len(data):.1f} |')
    md.append(f'| SubForm | {total_subform_controls:,} | - | {total_subform_controls / len(data):.1f} |')
    md.append(f'| ListBox | {total_listboxes:,} | - | {total_listboxes / len(data):.1f} |')
    md.append(f'| TabControl | {total_tabs:,} | - | {total_tabs / len(data):.1f} |')
    md.append('')

    # Event-Statistik
    md.append('## Event-Statistik')
    md.append('')
    md.append('| Event-Typ | Anzahl | Häufigste Formulare |')
    md.append('|-----------|--------|---------------------|')

    for event, count in sorted(event_types.items(), key=lambda x: x[1], reverse=True)[:15]:
        # Finde Formulare mit diesem Event
        forms_with_event = [(f['name'], f['events'].get(event, 0))
                            for f in data if event in f['events']]
        forms_with_event.sort(key=lambda x: x[1], reverse=True)
        top_forms = ', '.join([f'{name} ({cnt})' for name, cnt in forms_with_event[:3]])
        md.append(f'| {event} | {count} | {top_forms} |')

    md.append('')

    # Top 10 Größte Formulare
    md.append('## Top 10 Größte Formulare')
    md.append('')
    md.append('| Rang | Formular | Typ | Controls | Events | Buttons | VBA-Zeilen (geschätzt) |')
    md.append('|------|----------|-----|----------|--------|---------|------------------------|')

    for i, f in enumerate(largest, 1):
        typ = 'Sub' if f['is_subform'] else 'Haupt'
        md.append(f"| {i} | {f['name']} | {typ} | {f['controls_total']} | {f['events_total']} | {f['buttons']} | {f['vba_lines']} |")

    md.append('')

    # Top 10 Komplexeste Formulare
    md.append('## Top 10 Komplexeste Formulare (nach Events)')
    md.append('')
    md.append('| Rang | Formular | Typ | Events | VBA-Zeilen (geschätzt) | Controls | Event-Typen |')
    md.append('|------|----------|-----|--------|------------------------|----------|-------------|')

    for i, f in enumerate(most_complex, 1):
        typ = 'Sub' if f['is_subform'] else 'Haupt'
        event_names = ', '.join(f['events'].keys())
        if len(event_names) > 40:
            event_names = event_names[:40] + '...'
        md.append(f"| {i} | {f['name']} | {typ} | {f['events_total']} | {f['vba_lines']} | {f['controls_total']} | {event_names} |")

    md.append('')

    # Top 10 Button-reichste Formulare
    md.append('## Top 10 Button-reichste Formulare')
    md.append('')
    md.append('| Rang | Formular | Typ | Buttons | Controls Gesamt | Button-Anteil |')
    md.append('|------|----------|-----|---------|-----------------|---------------|')

    for i, f in enumerate(most_buttons, 1):
        typ = 'Sub' if f['is_subform'] else 'Haupt'
        ratio = f['buttons'] / f['controls_total'] * 100 if f['controls_total'] > 0 else 0
        md.append(f"| {i} | {f['name']} | {typ} | {f['buttons']} | {f['controls_total']} | {ratio:.1f}% |")

    md.append('')

    # Zusammenfassung
    md.append('## Zusammenfassung')
    md.append('')
    md.append(f'- **Gesamtzahl Formulare:** {total_forms + total_subforms} ({total_forms} Hauptformulare, {total_subforms} Subformulare)')
    md.append(f'- **Gesamtzahl Controls:** {total_controls:,}')
    md.append(f'- **Gesamtzahl Events:** {total_events}')
    md.append(f'- **Gesamtzahl Buttons:** {total_buttons:,}')
    md.append(f'- **Durchschnitt Controls pro Formular:** {total_controls / len(data):.1f}')
    md.append(f'- **Durchschnitt Events pro Formular:** {total_events / len(data):.1f}')
    md.append(f'- **Geschätzte VBA-Zeilen gesamt:** {sum(f["vba_lines"] for f in data):,}')
    md.append('')
    md.append('**Kategorien:**')
    for cat in sorted(categories.keys()):
        forms = categories[cat]
        controls = sum(f['controls_total'] for f in forms)
        events = sum(f['events_total'] for f in forms)
        md.append(f'- **{cat}:** {len(forms)} Formulare, {controls} Controls, {events} Events')

    md.append('')
    md.append('---')
    md.append('')
    md.append('*Generiert aus Access-Export JSON-Dateien*')

    # Speichern
    with open('MASTER_INVENTORY.md', 'w', encoding='utf-8') as f:
        f.write('\n'.join(md))

    print('MASTER_INVENTORY.md erfolgreich erstellt!')
    print(f'- {len(data)} Formulare analysiert')
    print(f'- {total_controls:,} Controls gesamt')
    print(f'- {total_events} Events gesamt')

if __name__ == '__main__':
    main()

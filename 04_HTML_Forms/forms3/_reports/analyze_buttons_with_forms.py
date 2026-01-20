"""
Button-Abweichungsanalyse mit Formular-Zuordnung
Vergleicht Buttons zwischen HTML und Access mit genauer Formular-Zuordnung
"""

import sys
import os
import re
import unicodedata
from pathlib import Path
import pandas as pd
import json
from datetime import datetime
from bs4 import BeautifulSoup

# Access Bridge importieren
sys.path.append(r'C:\Users\guenther.siegert\Documents\Access Bridge')
from access_bridge_ultimate import AccessBridge

# Pfade
HTML_DIR = Path(r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3')
REPORTS_DIR = HTML_DIR / '_reports'
REPORTS_DIR.mkdir(exist_ok=True)
EXPORTS_FORMS_DIR = Path(r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\exports\forms')

# Button-Datenstrukturen
html_buttons = []  # {form, name, label, function, onclick}
access_buttons = []  # {form, name, label, onclick, vba_function}

def normalize_text(value):
    if value is None:
        return ''
    text = str(value).strip().lower()
    # Deutsche Sonderzeichen vereinheitlichen
    text = text.replace('ß', 'ss')
    text = unicodedata.normalize('NFKD', text)
    text = ''.join(ch for ch in text if not unicodedata.combining(ch))
    text = re.sub(r'[^a-z0-9]+', '', text)
    return text


def normalize_name(value):
    text = normalize_text(value)
    # Entferne typische Access/HTML-Präfixe
    for prefix in ('cmd', 'btn', 'button', 'bt'):
        if text.startswith(prefix):
            text = text[len(prefix):]
            break
    # Entferne häufige Suffixe
    for suffix in ('button', 'btn', 'cmd'):
        if text.endswith(suffix) and len(text) > len(suffix):
            text = text[:-len(suffix)]
            break
    return text


def build_aliases():
    # Manuelle Alias-Mappings: HTML-ID -> Access-Name (normalisiert)
    # Nur dort nutzen, wo identische Funktion/Label bekannt ist
    return {
        'btnclose': 'btnformularschliessen',
        'btn_formular_schliessen': 'btnformularschliessen',
        'btnschliessen': 'btnformularschliessen',
        'cmdclose': 'btnformularschliessen',
        'cmdschliessen': 'btnformularschliessen',
        'cmd_schliessen': 'btnformularschliessen',
        'btnexit': 'btnformularschliessen',
        'cmdexit': 'btnformularschliessen',
        'btncancel': 'btnabbrechen',
        'cmdcancel': 'btnabbrechen',
        'btnabbruch': 'btnabbrechen',
        'cmdabbruch': 'btnabbrechen',
        'btnok': 'btnspeichern',
        'cmdok': 'btnspeichern',
        'btnsave': 'btnspeichern',
        'cmdsave': 'btnspeichern',
        'btnrefresh': 'btnaktualisieren',
        'cmdrefresh': 'btnaktualisieren',
    }


ALIASES = build_aliases()


def extract_html_buttons(html_file):
    """Extrahiert alle Buttons aus einer HTML-Datei"""
    buttons = []

    with open(html_file, 'r', encoding='utf-8') as f:
        soup = BeautifulSoup(f.read(), 'html.parser')

    # Finde alle Buttons (button + input[type=button|submit|reset])
    button_nodes = list(soup.find_all('button'))
    for input_btn in soup.find_all('input'):
        input_type = (input_btn.get('type') or '').lower()
        if input_type in ('button', 'submit', 'reset'):
            button_nodes.append(input_btn)

    for button in button_nodes:
        btn_id = button.get('id', '')
        btn_class = button.get('class', [])
        btn_onclick = button.get('onclick', '')
        btn_text = button.get_text(strip=True) if button.name == 'button' else ''
        btn_value = button.get('value', '')
        btn_title = button.get('title', '')
        btn_action = button.get('data-action', '')
        btn_aria = button.get('aria-label', '')

        # Extrahiere Funktion aus onclick
        function = ''
        if btn_onclick:
            match = re.search(r'(\w+)\s*\(', btn_onclick)
            if match:
                function = match.group(1)

        label = btn_text or btn_value or btn_title or btn_aria or btn_action or btn_id
        buttons.append({
            'form': html_file.name,
            'name': btn_id,
            'label': label,
            'function': function,
            'onclick': btn_onclick,
            'class': ' '.join(btn_class) if isinstance(btn_class, list) else btn_class,
            'data_action': btn_action,
            'title': btn_title,
            'value': btn_value,
            'aria_label': btn_aria
        })

    return buttons

def extract_access_buttons(allow_forms=None):
    """Extrahiert alle Buttons aus Access-Formularen"""
    buttons = []

    with AccessBridge() as bridge:
        forms = bridge.list_forms()
        print(f"Analysiere {len(forms)} Access-Formulare...")

        for form_name in forms:
            try:
                # Überspringe System-Formulare
                if form_name.startswith('~'):
                    continue
                if allow_forms and form_name not in allow_forms:
                    continue

                print(f"  +- {form_name}")

                # Öffne Formular in Design-Ansicht
                bridge.access_app.DoCmd.OpenForm(form_name, 0)  # acDesign = 0
                form = bridge.access_app.Forms(form_name)

                # Durchsuche alle Controls
                for ctrl in form.Controls:
                    try:
                        # Nur CommandButtons
                        if ctrl.ControlType == 104:  # acCommandButton
                            btn_name = ctrl.Name
                            btn_caption = getattr(ctrl, 'Caption', '')
                            btn_onclick = getattr(ctrl, 'OnClick', '')

                            # Extrahiere VBA-Funktion aus OnClick
                            vba_function = ''
                            if btn_onclick:
                                # Format: =FunctionName() oder [Event Procedure]
                                if btn_onclick == '[Event Procedure]':
                                    vba_function = f'{btn_name}_Click'
                                else:
                                    match = re.search(r'=\s*(\w+)\s*\(', btn_onclick)
                                    if match:
                                        vba_function = match.group(1)

                            buttons.append({
                                'form': form_name,
                                'name': btn_name,
                                'label': btn_caption,
                                'onclick': btn_onclick,
                                'vba_function': vba_function
                            })
                    except Exception as e:
                        pass

                # Schließe Formular
                bridge.access_app.DoCmd.Close(2, form_name, 2)  # acForm, acSaveNo

            except Exception as e:
                print(f"    [WARN] Fehler bei {form_name}: {e}")

    return buttons

def load_loose_json(path):
    raw = path.read_text(encoding='latin-1')
    raw = raw.replace('\ufeff', '')
    # Entferne trailing commas vor } oder ]
    raw = re.sub(r',\s*([}\]])', r'\1', raw)
    return json.loads(raw)


def extract_access_buttons_from_exports(allow_forms=None):
    """Extrahiert Buttons aus Access-Exports (controls.json)."""
    buttons = []
    if not EXPORTS_FORMS_DIR.exists():
        return buttons

    form_dirs = [p for p in EXPORTS_FORMS_DIR.iterdir() if p.is_dir()]
    for form_dir in form_dirs:
        form_name = form_dir.name
        if allow_forms and form_name not in allow_forms:
            continue
        controls_path = form_dir / 'controls.json'
        if not controls_path.exists():
            continue
        try:
            data = load_loose_json(controls_path)
            controls = data.get('Controls') or data.get('controls') or []
        except Exception as e:
            print(f"    [WARN] Export-JSON Fehler bei {form_name}: {e}")
            continue

        for ctrl in controls:
            try:
                if ctrl.get('ControlType') == 104:  # acCommandButton
                    btn_name = ctrl.get('Name', '')
                    btn_caption = ctrl.get('Caption', '')
                    btn_onclick = ctrl.get('OnClick', '')

                    vba_function = ''
                    if btn_onclick:
                        if btn_onclick == '[Event Procedure]':
                            vba_function = f'{btn_name}_Click'
                        else:
                            match = re.search(r'=\s*(\w+)\s*\(', str(btn_onclick))
                            if match:
                                vba_function = match.group(1)

                    buttons.append({
                        'form': form_name,
                        'name': btn_name,
                        'label': btn_caption,
                        'onclick': btn_onclick,
                        'vba_function': vba_function
                    })
            except Exception:
                pass

    return buttons

def match_buttons():
    """Vergleicht HTML- und Access-Buttons und erstellt Abweichungsliste"""
    comparisons = []

    # Access-Index pro Formular
    access_by_form = {}
    for btn in access_buttons:
        access_by_form.setdefault(btn['form'], []).append(btn)

    # 1. Vergleiche HTML-Buttons mit Access
    for html_btn in html_buttons:
        # Suche passendes Access-Formular (ohne .html)
        html_form_base = html_btn['form'].replace('.html', '')

        # Access-Buttons für Formular
        access_candidates = access_by_form.get(html_form_base, [])

        # Vorbereitung: Normalisierte Werte
        html_name = html_btn['name']
        html_label = html_btn['label']
        html_function = html_btn['function']
        html_name_norm = normalize_name(html_name)
        html_label_norm = normalize_text(html_label)
        html_alias = ALIASES.get(normalize_text(html_name), '')

        # Matching-Priorität: Name exakt -> Name normalisiert -> Alias -> Funktion -> Label
        matching_access = []

        # 1) Exakter Name
        matching_access = [ab for ab in access_candidates if ab['name'] == html_name]

        # 2) Normalisierter Name (btn/cmd/Unterstriche)
        if not matching_access and html_name_norm:
            matching_access = [
                ab for ab in access_candidates
                if normalize_name(ab['name']) == html_name_norm
            ]

        # 3) Alias-Mapping
        if not matching_access and html_alias:
            matching_access = [
                ab for ab in access_candidates
                if normalize_name(ab['name']) == html_alias
            ]

        # 4) Funktion (OnClick -> VBA)
        if not matching_access and html_function:
            html_function_norm = normalize_name(html_function)
            matching_access = [
                ab for ab in access_candidates
                if ab.get('vba_function') == html_function
                or ab.get('vba_function') == f"{ab['name']}_Click"
                or normalize_name(ab.get('vba_function')) == html_function_norm
            ]

        # 5) Label-Normalisierung
        if not matching_access and html_label_norm:
            matching_access = [
                ab for ab in access_candidates
                if normalize_text(ab.get('label')) == html_label_norm
            ]

        if matching_access:
            # Button existiert in beiden
            access_btn = matching_access[0]

            # Prüfe ob identisch
            label_match = normalize_text(html_btn['label']) == normalize_text(access_btn['label'])
            function_match = normalize_name(html_btn['function']) == normalize_name(access_btn['vba_function'])

            if label_match and function_match:
                status = '[OK] identisch'
            else:
                status = '[WARN] abweichend'

            comparisons.append({
                'HTML_Formular': html_btn['form'],
                'HTML_Button': html_btn['name'],
                'HTML_Label': html_btn['label'],
                'HTML_Funktion': html_btn['function'],
                'Access_Formular': access_btn['form'],
                'Access_Button': access_btn['name'],
                'Access_Label': access_btn['label'],
                'Access_VBA': access_btn['vba_function'],
                'Status': status,
                'Bemerkung': '' if status == '[OK] identisch' else 'Label/Funktion weicht ab'
            })
        else:
            # Button nur in HTML
            comparisons.append({
                'HTML_Formular': html_btn['form'],
                'HTML_Button': html_btn['name'],
                'HTML_Label': html_btn['label'],
                'HTML_Funktion': html_btn['function'],
                'Access_Formular': '-',
                'Access_Button': '-',
                'Access_Label': '-',
                'Access_VBA': '-',
                'Status': '[NEW] nur in HTML',
                'Bemerkung': 'Kein Access-Aequivalent gefunden'
            })

    # 2. Finde Access-Buttons die nicht in HTML sind
    for access_btn in access_buttons:
        access_form_html = access_btn['form'] + '.html'

        matching_html = [
            hb for hb in html_buttons
            if hb['form'] == access_form_html and hb['name'] == access_btn['name']
        ]

        # Zusätzliche Mapping-Regeln für Access->HTML
        if not matching_html:
            access_name_norm = normalize_name(access_btn['name'])
            access_label_norm = normalize_text(access_btn['label'])
            matching_html = [
                hb for hb in html_buttons
                if hb['form'] == access_form_html and (
                    normalize_name(hb['name']) == access_name_norm or
                    normalize_text(hb['label']) == access_label_norm or
                    normalize_name(hb.get('function')) == normalize_name(access_btn.get('vba_function'))
                )
            ]
        if not matching_html:
            access_alias = ALIASES.get(normalize_text(access_btn['name']), '')
            if access_alias:
                matching_html = [
                    hb for hb in html_buttons
                    if hb['form'] == access_form_html and normalize_name(hb['name']) == access_alias
                ]

        if not matching_html:
            # Button nur in Access
            comparisons.append({
                'HTML_Formular': access_form_html,
                'HTML_Button': '-',
                'HTML_Label': '-',
                'HTML_Funktion': '-',
                'Access_Formular': access_btn['form'],
                'Access_Button': access_btn['name'],
                'Access_Label': access_btn['label'],
                'Access_VBA': access_btn['vba_function'],
                'Status': '[MISS] fehlt in HTML',
                'Bemerkung': 'In Access vorhanden, aber nicht in HTML'
            })

    return comparisons

def create_reports(comparisons):
    """Erstellt Excel und Markdown Reports"""
    df = pd.DataFrame(comparisons)

    # Abweichungen nummerieren (nur nicht-[OK])
    df['Nr'] = ''
    deviation_mask = df['Status'] != '[OK] identisch'
    df.loc[deviation_mask, 'Nr'] = range(1, deviation_mask.sum() + 1)
    # Nr-Spalte nach vorne ziehen
    cols = ['Nr'] + [c for c in df.columns if c != 'Nr']
    df = df[cols]

    # Sortiere nach HTML-Formular und Status
    df = df.sort_values(['HTML_Formular', 'Status', 'HTML_Button'])

    # Version 1: Nach Formular gruppiert
    date_tag = datetime.now().strftime('%Y-%m-%d')
    excel_file = REPORTS_DIR / f'BUTTON_ABWEICHUNGEN_MIT_FORMULAR_{date_tag}.xlsx'
    with pd.ExcelWriter(excel_file, engine='openpyxl') as writer:
        df.to_excel(writer, sheet_name='Nach Formular', index=False)

        # Version 2: Nach Funktion gruppiert
        df_by_function = df.sort_values(['HTML_Funktion', 'HTML_Formular', 'Status'])
        df_by_function.to_excel(writer, sheet_name='Nach Funktion', index=False)

        # Statistik
        stats = {
            'Kategorie': ['[OK] identisch', '[WARN] abweichend', '[MISS] fehlt in HTML', '[NEW] nur in HTML', 'GESAMT'],
            'Anzahl': [
                len(df[df['Status'] == '[OK] identisch']),
                len(df[df['Status'] == '[WARN] abweichend']),
                len(df[df['Status'] == '[MISS] fehlt in HTML']),
                len(df[df['Status'] == '[NEW] nur in HTML']),
                len(df)
            ]
        }
        pd.DataFrame(stats).to_excel(writer, sheet_name='Statistik', index=False)

    print(f"\n[OK] Excel-Report erstellt: {excel_file}")

    # Markdown-Report
    md_file = REPORTS_DIR / f'BUTTON_ABWEICHUNGEN_MIT_FORMULAR_{date_tag}.md'
    with open(md_file, 'w', encoding='utf-8') as f:
        f.write('# Button-Abweichungsanalyse mit Formular-Zuordnung\n\n')
        f.write(f'**Erstellt:** {date_tag}\n\n')

        # Statistik
        f.write('## Statistik\n\n')
        f.write('| Status | Anzahl |\n')
        f.write('|--------|--------|\n')
        for cat, count in zip(stats['Kategorie'], stats['Anzahl']):
            f.write(f'| {cat} | {count} |\n')

        # Version 1: Nach Formular
        f.write('\n## Version 1: Nach HTML-Formular gruppiert\n\n')
        current_form = None
        for _, row in df.iterrows():
            if row['HTML_Formular'] != current_form:
                current_form = row['HTML_Formular']
                f.write(f'\n### {current_form}\n\n')
                f.write('| HTML Button | HTML Label | HTML Funktion | Access Formular | Access Button | Access VBA | Status | Bemerkung |\n')
                f.write('|-------------|------------|---------------|-----------------|---------------|------------|--------|------------|\n')

            f.write(f"| {row['HTML_Button']} | {row['HTML_Label']} | {row['HTML_Funktion']} | ")
            f.write(f"{row['Access_Formular']} | {row['Access_Button']} | {row['Access_VBA']} | ")
            f.write(f"{row['Status']} | {row['Bemerkung']} |\n")

        # Version 2: Nach Funktion
        f.write('\n## Version 2: Nach Funktion gruppiert\n\n')
        current_function = None
        for _, row in df_by_function.iterrows():
            if row['HTML_Funktion'] != current_function:
                current_function = row['HTML_Funktion']
                f.write(f'\n### Funktion: {current_function if current_function else "(keine)"}\n\n')
                f.write('| HTML Formular | HTML Button | HTML Label | Access Formular | Access Button | Access VBA | Status | Bemerkung |\n')
                f.write('|---------------|-------------|------------|-----------------|---------------|------------|--------|------------|\n')

            f.write(f"| {row['HTML_Formular']} | {row['HTML_Button']} | {row['HTML_Label']} | ")
            f.write(f"{row['Access_Formular']} | {row['Access_Button']} | {row['Access_VBA']} | ")
            f.write(f"{row['Status']} | {row['Bemerkung']} |\n")

    print(f"[OK] Markdown-Report erstellt: {md_file}")

def main():
    global html_buttons, access_buttons

    print("Button-Abweichungsanalyse startet...\n")

    # 1. HTML-Buttons extrahieren
    print("Analysiere HTML-Formulare...")
    html_files = list(HTML_DIR.glob('*.html'))
    html_files = [f for f in html_files if '.bak' not in f.name]

    for html_file in html_files:
        print(f"  +- {html_file.name}")
        html_buttons.extend(extract_html_buttons(html_file))

    print(f"\n[OK] {len(html_buttons)} HTML-Buttons gefunden\n")

    # 2. Access-Buttons extrahieren
    print("Analysiere Access-Formulare...")
    html_form_bases = {f.name.replace('.html', '') for f in html_files}
    access_buttons = extract_access_buttons_from_exports(allow_forms=html_form_bases)
    if not access_buttons:
        access_buttons = extract_access_buttons(allow_forms=html_form_bases)
    print(f"\n[OK] {len(access_buttons)} Access-Buttons gefunden\n")

    # 3. Vergleiche Buttons
    print("Vergleiche Buttons...")
    comparisons = match_buttons()
    print(f"[OK] {len(comparisons)} Button-Vergleiche erstellt\n")

    # 4. Erstelle Reports
    print("Erstelle Reports...")
    create_reports(comparisons)

    print("\n[OK] Analyse abgeschlossen!")

if __name__ == '__main__':
    main()

"""
Button-Abweichungsanalyse mit Formular-Zuordnung
Vergleicht Buttons zwischen HTML und Access mit genauer Formular-Zuordnung
"""

import sys
import os
import re
from pathlib import Path
import pandas as pd
from bs4 import BeautifulSoup

# Access Bridge importieren
sys.path.append(r'C:\Users\guenther.siegert\Documents\Access Bridge')
from access_bridge_ultimate import AccessBridge

# Pfade
HTML_DIR = Path(r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3')
REPORTS_DIR = HTML_DIR / '_reports'
REPORTS_DIR.mkdir(exist_ok=True)

# Button-Datenstrukturen
html_buttons = []  # {form, name, label, function, onclick}
access_buttons = []  # {form, name, label, onclick, vba_function}

def extract_html_buttons(html_file):
    """Extrahiert alle Buttons aus einer HTML-Datei"""
    buttons = []

    with open(html_file, 'r', encoding='utf-8') as f:
        soup = BeautifulSoup(f.read(), 'html.parser')

    # Finde alle Buttons
    for button in soup.find_all('button'):
        btn_id = button.get('id', '')
        btn_class = button.get('class', [])
        btn_onclick = button.get('onclick', '')
        btn_text = button.get_text(strip=True)

        # Extrahiere Funktion aus onclick
        function = ''
        if btn_onclick:
            match = re.search(r'(\w+)\s*\(', btn_onclick)
            if match:
                function = match.group(1)

        buttons.append({
            'form': html_file.name,
            'name': btn_id,
            'label': btn_text,
            'function': function,
            'onclick': btn_onclick,
            'class': ' '.join(btn_class) if isinstance(btn_class, list) else btn_class
        })

    return buttons

def extract_access_buttons():
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

def match_buttons():
    """Vergleicht HTML- und Access-Buttons und erstellt Abweichungsliste"""
    comparisons = []

    # 1. Vergleiche HTML-Buttons mit Access
    for html_btn in html_buttons:
        # Suche passendes Access-Formular (ohne .html)
        html_form_base = html_btn['form'].replace('.html', '')

        # Suche entsprechenden Access-Button
        matching_access = [
            ab for ab in access_buttons
            if ab['form'] == html_form_base and ab['name'] == html_btn['name']
        ]

        if matching_access:
            # Button existiert in beiden
            access_btn = matching_access[0]

            # Prüfe ob identisch
            label_match = html_btn['label'].lower() == access_btn['label'].lower()
            function_match = html_btn['function'] == access_btn['vba_function']

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

    # Sortiere nach HTML-Formular und Status
    df = df.sort_values(['HTML_Formular', 'Status', 'HTML_Button'])

    # Version 1: Nach Formular gruppiert
    excel_file = REPORTS_DIR / 'BUTTON_ABWEICHUNGEN_MIT_FORMULAR_2026-01-15.xlsx'
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
    md_file = REPORTS_DIR / 'BUTTON_ABWEICHUNGEN_MIT_FORMULAR_2026-01-15.md'
    with open(md_file, 'w', encoding='utf-8') as f:
        f.write('# Button-Abweichungsanalyse mit Formular-Zuordnung\n\n')
        f.write('**Erstellt:** 2026-01-15\n\n')

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
    access_buttons = extract_access_buttons()
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

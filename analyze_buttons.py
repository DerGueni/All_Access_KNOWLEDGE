"""
Button-Funktionalitäts-Analyse für alle HTML-Formulare
Prüft JEDEN Button auf Existenz, Caption, Handler, Ziel und Parameter
"""

import os
import re
import json
from pathlib import Path
from bs4 import BeautifulSoup
import pandas as pd

# Pfade
FORMS_DIR = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms"
JSON_DIR = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\11_json_Export"
SPECS_DIR = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\05_Dokumentation\specs"
VBA_DIR = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\01_VBA"

# Ergebnis-Struktur
results = []

def extract_buttons_from_html(html_path):
    """Extrahiert alle Buttons aus HTML-Datei"""
    buttons = []

    try:
        with open(html_path, 'r', encoding='utf-8') as f:
            soup = BeautifulSoup(f.read(), 'html.parser')

            # Finde alle Button-Elemente
            for btn in soup.find_all(['button', 'input']):
                if btn.name == 'input' and btn.get('type') not in ['button', 'submit']:
                    continue

                button_info = {
                    'element': btn.name,
                    'id': btn.get('id', ''),
                    'class': btn.get('class', []),
                    'text': btn.get_text(strip=True) if btn.name == 'button' else btn.get('value', ''),
                    'onclick': btn.get('onclick', ''),
                    'data_action': btn.get('data-action', ''),
                    'html': str(btn)[:200]  # Erste 200 Zeichen
                }
                buttons.append(button_info)

    except Exception as e:
        print(f"Fehler beim Lesen von {html_path}: {e}")

    return buttons

def extract_logic_functions(logic_path):
    """Extrahiert Funktionen aus .logic.js Datei"""
    functions = []

    try:
        if os.path.exists(logic_path):
            with open(logic_path, 'r', encoding='utf-8') as f:
                content = f.read()

                # Finde alle Funktionen
                func_pattern = r'function\s+(\w+)\s*\('
                functions = re.findall(func_pattern, content)

                # Finde Event-Listener
                listener_pattern = r'addEventListener\([\'"](\w+)[\'"]'
                listeners = re.findall(listener_pattern, content)

                # Finde onclick-Handler
                onclick_pattern = r'onclick\s*=.*?[\'"](\w+)\('
                onclick_funcs = re.findall(onclick_pattern, content)

                return {
                    'functions': functions,
                    'listeners': listeners,
                    'onclick_handlers': onclick_funcs
                }
    except Exception as e:
        print(f"Fehler beim Lesen von {logic_path}: {e}")

    return {'functions': [], 'listeners': [], 'onclick_handlers': []}

def load_access_spec(form_name):
    """Lädt Access-Spec aus JSON (wenn vorhanden)"""
    spec_path = os.path.join(SPECS_DIR, f"{form_name}.spec.json")

    try:
        if os.path.exists(spec_path):
            with open(spec_path, 'r', encoding='utf-8') as f:
                return json.load(f)
    except Exception as e:
        print(f"Fehler beim Lesen von {spec_path}: {e}")

    return None

def analyze_form(html_path):
    """Analysiert ein einzelnes Formular"""
    form_name = Path(html_path).stem

    # Überspringe Backup/Test-Versionen
    if any(x in form_name.lower() for x in ['backup', 'test', 'generated', 'precise', '_codes']):
        return None

    print(f"\n=== Analysiere: {form_name} ===")

    # Extrahiere Buttons aus HTML
    html_buttons = extract_buttons_from_html(html_path)

    # Finde zugehörige Logic-Datei
    logic_dir = os.path.join(FORMS_DIR, 'logic')
    logic_path = os.path.join(logic_dir, f"{form_name}.logic.js")

    # Alternative Pfade für Logic-Dateien
    if not os.path.exists(logic_path):
        logic_path = os.path.join(FORMS_DIR, '_Codes', 'logic', f"{form_name}.logic.js")

    logic_info = extract_logic_functions(logic_path)

    # Lade Access-Spec
    access_spec = load_access_spec(form_name)

    # Analysiere jeden Button
    for btn in html_buttons:
        btn_text = btn['text']
        btn_id = btn['id']
        onclick = btn['onclick']

        # Status-Prüfung
        has_handler = bool(onclick or btn['data_action'])
        has_logic_file = os.path.exists(logic_path)

        # Ziel-Extraktion
        target = None
        if onclick:
            # Suche nach DoCmd.OpenForm-Äquivalent
            if 'navigate' in onclick.lower():
                match = re.search(r'[\'"](\w+)[\'"]', onclick)
                if match:
                    target = match.group(1)

        status = "OK" if has_handler else "FEHLT"
        if has_handler and not target and 'navigate' not in onclick.lower():
            status = "OK"  # Nicht alle Buttons navigieren

        result = {
            'Formular': form_name,
            'Button_ID': btn_id,
            'Button_Text': btn_text,
            'Handler_Vorhanden': 'Ja' if has_handler else 'NEIN',
            'onClick': onclick[:100] if onclick else '',
            'Ziel_Formular': target or '',
            'Logic_Datei': 'Ja' if has_logic_file else 'Nein',
            'Status': status,
            'HTML_Snippet': btn['html'][:100]
        }

        results.append(result)

    return {
        'form': form_name,
        'buttons_count': len(html_buttons),
        'has_logic': has_logic_file,
        'logic_functions': len(logic_info['functions'])
    }

def main():
    """Hauptfunktion"""
    print("=== BUTTON-FUNKTIONALITÄTS-ANALYSE GESTARTET ===\n")

    # Finde alle HTML-Formulare
    html_files = list(Path(FORMS_DIR).rglob("frm_*.html"))

    # Filtere Duplikate und unwichtige Versionen
    main_forms = []
    for html_file in html_files:
        path_str = str(html_file)

        # Priorität: V2 > ohne Suffix > Rest
        if '_V2.html' in path_str:
            main_forms.append(html_file)
        elif any(x in path_str.lower() for x in ['backup', 'generated', 'precise', '_codes', '_v2', 'test']):
            continue
        else:
            # Prüfe ob V2-Version existiert
            v2_path = path_str.replace('.html', '_V2.html')
            if not os.path.exists(v2_path):
                main_forms.append(html_file)

    print(f"Gefundene Hauptformulare: {len(main_forms)}\n")

    summaries = []
    for html_file in sorted(main_forms):
        summary = analyze_form(html_file)
        if summary:
            summaries.append(summary)

    # Erstelle DataFrame und Excel-Export
    if results:
        df = pd.DataFrame(results)

        # Sortiere nach Formular und Status
        df = df.sort_values(['Formular', 'Status'], ascending=[True, False])

        # Export
        output_file = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\BUTTON_ANALYSE_REPORT.xlsx"
        with pd.ExcelWriter(output_file, engine='openpyxl') as writer:
            # Haupt-Übersicht
            df.to_excel(writer, sheet_name='Button_Übersicht', index=False)

            # Problematische Buttons
            df_fehler = df[df['Handler_Vorhanden'] == 'NEIN']
            if not df_fehler.empty:
                df_fehler.to_excel(writer, sheet_name='Fehlende_Handler', index=False)

            # Zusammenfassung pro Formular
            df_summary = df.groupby('Formular').agg({
                'Button_ID': 'count',
                'Handler_Vorhanden': lambda x: (x == 'Ja').sum(),
                'Status': lambda x: (x == 'FEHLT').sum()
            }).rename(columns={
                'Button_ID': 'Gesamt_Buttons',
                'Handler_Vorhanden': 'Mit_Handler',
                'Status': 'Ohne_Handler'
            })
            df_summary.to_excel(writer, sheet_name='Zusammenfassung')

        print(f"\n=== REPORT ERSTELLT ===")
        print(f"Datei: {output_file}")
        print(f"\nStatistik:")
        print(f"  Gesamt Formulare: {len(df['Formular'].unique())}")
        print(f"  Gesamt Buttons: {len(df)}")
        print(f"  Mit Handler: {(df['Handler_Vorhanden'] == 'Ja').sum()}")
        print(f"  Ohne Handler: {(df['Handler_Vorhanden'] == 'NEIN').sum()}")

        # Zeige fehlende Handler
        if not df_fehler.empty:
            print(f"\n=== FEHLENDE HANDLER ({len(df_fehler)}) ===")
            for _, row in df_fehler.head(10).iterrows():
                print(f"  {row['Formular']} -> {row['Button_Text']} ({row['Button_ID']})")
            if len(df_fehler) > 10:
                print(f"  ... und {len(df_fehler) - 10} weitere")
    else:
        print("Keine Buttons gefunden!")

if __name__ == "__main__":
    main()

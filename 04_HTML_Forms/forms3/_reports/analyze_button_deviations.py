"""
Button-Abweichungsanalyse: HTML vs Access
Erstellt Excel und Markdown Reports mit Formular-Zuordnung
"""

import os
import re
import json
from pathlib import Path
from collections import defaultdict
import sys

# Access Bridge importieren
sys.path.append(r"C:\Users\guenther.siegert\Documents\Access Bridge")
from access_bridge_ultimate import AccessBridge

# Pfade
FORMS3_PATH = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3")
REPORT_PATH = FORMS3_PATH / "_reports"
REPORT_PATH.mkdir(exist_ok=True)

# Hauptformulare (nicht Subforms oder Test-Dateien)
MAIN_FORMS = [
    'frm_va_Auftragstamm.html',
    'frm_MA_Mitarbeiterstamm.html',
    'frm_KD_Kundenstamm.html',
    'frm_OB_Objekt.html',
    'frm_DP_Dienstplan_MA.html',
    'frm_DP_Dienstplan_Objekt.html',
    'frm_Einsatzuebersicht.html',
    'frm_MA_VA_Schnellauswahl.html',
    'frm_MA_Abwesenheit.html',
    'frm_MA_Zeitkonten.html',
    'frm_Abwesenheiten.html',
    'frm_Kundenpreise_gueni.html',
    'frm_Rueckmeldestatistik.html',
    'frm_Angebot.html',
    'frm_Rechnung.html',
    'frm_MA_Serien_eMail_Auftrag.html',
    'frm_MA_Serien_eMail_dienstplan.html',
    'frm_Systeminfo.html',
    'frm_N_Bewerber.html',
    'frm_Menuefuehrung1.html',
]


def extract_html_buttons(html_path):
    """Extrahiere alle Buttons aus einem HTML-Formular"""
    buttons = []

    try:
        with open(html_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Pattern für verschiedene Button-Typen
        patterns = [
            # <button id="..." data-action="...">Label</button>
            r'<button[^>]*id=["\']([^"\']+)["\'][^>]*data-action=["\']([^"\']+)["\'][^>]*>([^<]+)</button>',
            # <button id="..." onclick="...">Label</button>
            r'<button[^>]*id=["\']([^"\']+)["\'][^>]*onclick=["\']([^"\']+)["\'][^>]*>([^<]+)</button>',
            # <button data-action="..." id="...">Label</button>
            r'<button[^>]*data-action=["\']([^"\']+)["\'][^>]*id=["\']([^"\']+)["\'][^>]*>([^<]+)</button>',
            # Einfache Buttons
            r'<button[^>]*id=["\']([^"\']+)["\'][^>]*>([^<]+)</button>',
        ]

        for pattern in patterns:
            matches = re.findall(pattern, content, re.IGNORECASE)
            for match in matches:
                if len(match) == 3:
                    btn_id, action, label = match
                elif len(match) == 2:
                    btn_id, label = match
                    action = ""
                else:
                    continue

                # Bereinige Label
                label = re.sub(r'\s+', ' ', label).strip()

                buttons.append({
                    'id': btn_id,
                    'label': label,
                    'action': action,
                    'formular': html_path.name
                })

    except Exception as e:
        print(f"Fehler beim Lesen von {html_path.name}: {e}")

    return buttons


def extract_access_buttons():
    """Extrahiere alle Buttons aus Access-Formularen"""
    buttons_by_form = defaultdict(list)

    try:
        with AccessBridge() as bridge:
            forms = bridge.list_forms()
            print(f"\nAnalysiere {len(forms)} Access-Formulare...")

            for form_name in forms:
                # Nur Hauptformulare (frm_*, nicht sub_*, nicht zfrm_*)
                if not form_name.startswith('frm_'):
                    continue

                try:
                    # Formular öffnen im Design-Modus
                    app = bridge.access_app
                    app.DoCmd.OpenForm(form_name, 2)  # 2 = acDesign

                    form_obj = app.Forms(form_name)

                    # Alle Controls durchgehen
                    for ctrl in form_obj.Controls:
                        # Nur CommandButtons
                        if ctrl.ControlType == 104:  # acCommandButton
                            btn_name = ctrl.Name
                            btn_caption = getattr(ctrl, 'Caption', btn_name)

                            # OnClick Event
                            onclick = ""
                            try:
                                onclick = ctrl.OnClick or ""
                            except:
                                pass

                            buttons_by_form[form_name].append({
                                'name': btn_name,
                                'caption': btn_caption,
                                'onclick': onclick,
                                'formular': form_name
                            })

                    # Formular schließen
                    app.DoCmd.Close(2, form_name, 2)  # acForm, acSaveNo

                    print(f"  {form_name}: {len(buttons_by_form[form_name])} Buttons")

                except Exception as e:
                    print(f"  Fehler bei {form_name}: {e}")
                    try:
                        app.DoCmd.Close(2, form_name, 2)
                    except:
                        pass

    except Exception as e:
        print(f"Fehler bei Access-Verbindung: {e}")

    return buttons_by_form


def match_buttons(html_buttons, access_buttons):
    """Vergleiche HTML und Access Buttons"""
    results = []

    # Erstelle Mapping: Access-Formularname -> HTML-Formularname
    form_mapping = {
        'frm_va_Auftragstamm': 'frm_va_Auftragstamm.html',
        'frm_MA_Mitarbeiterstamm': 'frm_MA_Mitarbeiterstamm.html',
        'frm_KD_Kundenstamm': 'frm_KD_Kundenstamm.html',
        'frm_OB_Objekt': 'frm_OB_Objekt.html',
        'frm_DP_Dienstplan_MA': 'frm_DP_Dienstplan_MA.html',
        'frm_DP_Dienstplan_Objekt': 'frm_DP_Dienstplan_Objekt.html',
        'frm_Einsatzuebersicht': 'frm_Einsatzuebersicht.html',
        'frm_MA_VA_Schnellauswahl': 'frm_MA_VA_Schnellauswahl.html',
        'frm_MA_Abwesenheit': 'frm_MA_Abwesenheit.html',
        'frm_MA_Zeitkonten': 'frm_MA_Zeitkonten.html',
        'frm_Abwesenheiten': 'frm_Abwesenheiten.html',
        'frm_Kundenpreise_gueni': 'frm_Kundenpreise_gueni.html',
        'frm_Rueckmeldestatistik': 'frm_Rueckmeldestatistik.html',
        'frm_Angebot': 'frm_Angebot.html',
        'frm_Rechnung': 'frm_Rechnung.html',
        'frm_MA_Serien_eMail_Auftrag': 'frm_MA_Serien_eMail_Auftrag.html',
        'frm_MA_Serien_eMail_dienstplan': 'frm_MA_Serien_eMail_dienstplan.html',
        'frm_Systeminfo': 'frm_Systeminfo.html',
        'frm_N_Bewerber': 'frm_N_Bewerber.html',
        'frm_Menuefuehrung1': 'frm_Menuefuehrung1.html',
    }

    # Gruppiere HTML-Buttons nach Formular
    html_by_form = defaultdict(list)
    for btn in html_buttons:
        html_by_form[btn['formular']].append(btn)

    # Vergleiche pro Formular
    for access_form, html_form in form_mapping.items():
        access_btns = access_buttons.get(access_form, [])
        html_btns = html_by_form.get(html_form, [])

        # Erstelle Label-Maps für schnellen Lookup
        access_labels = {btn['caption'].lower(): btn for btn in access_btns}
        html_labels = {btn['label'].lower(): btn for btn in html_btns}

        # Access Buttons mit HTML abgleichen
        for acc_btn in access_btns:
            label_lower = acc_btn['caption'].lower()

            if label_lower in html_labels:
                # Match gefunden
                html_btn = html_labels[label_lower]
                results.append({
                    'status': 'OK',
                    'html_form': html_form,
                    'access_form': access_form,
                    'label': acc_btn['caption'],
                    'html_id': html_btn['id'],
                    'html_action': html_btn['action'],
                    'access_name': acc_btn['name'],
                    'access_onclick': acc_btn['onclick'],
                })
            else:
                # Fehlt in HTML
                results.append({
                    'status': 'MISS',
                    'html_form': html_form,
                    'access_form': access_form,
                    'label': acc_btn['caption'],
                    'html_id': '',
                    'html_action': '',
                    'access_name': acc_btn['name'],
                    'access_onclick': acc_btn['onclick'],
                })

        # HTML Buttons die nicht in Access sind
        for html_btn in html_btns:
            label_lower = html_btn['label'].lower()

            if label_lower not in access_labels:
                results.append({
                    'status': 'NEW',
                    'html_form': html_form,
                    'access_form': access_form,
                    'label': html_btn['label'],
                    'html_id': html_btn['id'],
                    'html_action': html_btn['action'],
                    'access_name': '',
                    'access_onclick': '',
                })

    return results


def create_markdown_report(results):
    """Erstelle Markdown-Report"""
    report_path = REPORT_PATH / "BUTTON_ABWEICHUNGEN_MIT_FORMULAR_2026-01-15.md"

    # Gruppiere nach HTML-Formular
    by_html_form = defaultdict(list)
    for r in results:
        by_html_form[r['html_form']].append(r)

    # Statistiken
    stats = {
        'OK': len([r for r in results if r['status'] == 'OK']),
        'MISS': len([r for r in results if r['status'] == 'MISS']),
        'NEW': len([r for r in results if r['status'] == 'NEW']),
        'total': len(results)
    }

    with open(report_path, 'w', encoding='utf-8') as f:
        f.write("# Button-Abweichungsanalyse: HTML vs Access\n\n")
        f.write(f"**Erstellt:** {Path(__file__).stem}\n")
        f.write(f"**Datum:** 2026-01-15\n\n")

        f.write("## Zusammenfassung\n\n")
        f.write(f"- **Gesamt:** {stats['total']} Button-Einträge\n")
        f.write(f"- **[OK] Identisch:** {stats['OK']} ({stats['OK']*100//stats['total'] if stats['total'] else 0}%)\n")
        f.write(f"- **[MISS] Fehlt in HTML:** {stats['MISS']}\n")
        f.write(f"- **[NEW] Nur in HTML:** {stats['NEW']}\n\n")

        f.write("## Legende\n\n")
        f.write("- **[OK]** - Button existiert in beiden (HTML und Access) mit gleichem Label\n")
        f.write("- **[MISS]** - Button existiert nur in Access, fehlt in HTML\n")
        f.write("- **[NEW]** - Button existiert nur in HTML, nicht in Access\n\n")

        f.write("---\n\n")
        f.write("## Details nach HTML-Formular\n\n")

        for html_form in sorted(by_html_form.keys()):
            buttons = by_html_form[html_form]

            f.write(f"### {html_form}\n\n")

            # Statistik für dieses Formular
            form_stats = {
                'OK': len([b for b in buttons if b['status'] == 'OK']),
                'MISS': len([b for b in buttons if b['status'] == 'MISS']),
                'NEW': len([b for b in buttons if b['status'] == 'NEW']),
            }
            f.write(f"**Buttons:** {len(buttons)} | ")
            f.write(f"OK: {form_stats['OK']} | MISS: {form_stats['MISS']} | NEW: {form_stats['NEW']}\n\n")

            # Tabelle
            f.write("| Status | Label | HTML ID | HTML Action | Access Name | Access OnClick |\n")
            f.write("|--------|-------|---------|-------------|-------------|----------------|\n")

            for btn in sorted(buttons, key=lambda x: (x['status'], x['label'])):
                status_icon = {
                    'OK': '✅',
                    'MISS': '❌',
                    'NEW': '➕'
                }[btn['status']]

                f.write(f"| {status_icon} {btn['status']} | {btn['label']} | ")
                f.write(f"{btn['html_id']} | {btn['html_action'][:30]}... | ")
                f.write(f"{btn['access_name']} | {btn['access_onclick'][:30]}... |\n")

            f.write("\n")

    print(f"\n[OK] Markdown-Report erstellt: {report_path}")
    return report_path


def create_excel_report(results):
    """Erstelle Excel-Report (CSV für einfache Kompatibilität)"""
    import csv

    report_path = REPORT_PATH / "BUTTON_ABWEICHUNGEN_MIT_FORMULAR_2026-01-15.csv"

    with open(report_path, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Status', 'HTML_Formular', 'Access_Formular', 'Label',
            'HTML_ID', 'HTML_Action', 'Access_Name', 'Access_OnClick'
        ])

        writer.writeheader()

        for r in sorted(results, key=lambda x: (x['html_form'], x['status'], x['label'])):
            writer.writerow({
                'Status': r['status'],
                'HTML_Formular': r['html_form'],
                'Access_Formular': r['access_form'],
                'Label': r['label'],
                'HTML_ID': r['html_id'],
                'HTML_Action': r['html_action'],
                'Access_Name': r['access_name'],
                'Access_OnClick': r['access_onclick'],
            })

    print(f"[OK] CSV-Report erstellt: {report_path}")
    return report_path


def main():
    print("=" * 80)
    print("Button-Abweichungsanalyse: HTML vs Access")
    print("=" * 80)

    # Schritt 1: HTML-Buttons extrahieren
    print("\n[1/4] Extrahiere HTML-Buttons...")
    html_buttons = []

    for form_file in MAIN_FORMS:
        form_path = FORMS3_PATH / form_file
        if form_path.exists():
            buttons = extract_html_buttons(form_path)
            html_buttons.extend(buttons)
            print(f"  {form_file}: {len(buttons)} Buttons")

    print(f"\n  Gesamt HTML-Buttons: {len(html_buttons)}")

    # Schritt 2: Access-Buttons extrahieren
    print("\n[2/4] Extrahiere Access-Buttons...")
    access_buttons = extract_access_buttons()
    total_access = sum(len(btns) for btns in access_buttons.values())
    print(f"\n  Gesamt Access-Buttons: {total_access}")

    # Schritt 3: Matching
    print("\n[3/4] Vergleiche Buttons...")
    results = match_buttons(html_buttons, access_buttons)
    print(f"  {len(results)} Einträge erstellt")

    # Schritt 4: Reports erstellen
    print("\n[4/4] Erstelle Reports...")
    md_path = create_markdown_report(results)
    csv_path = create_excel_report(results)

    print("\n" + "=" * 80)
    print("[OK] FERTIG!")
    print("=" * 80)
    print(f"\nReports gespeichert in:")
    print(f"  - {md_path}")
    print(f"  - {csv_path}")


if __name__ == "__main__":
    main()

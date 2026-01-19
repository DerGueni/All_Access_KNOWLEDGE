#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Header Validierungs-Script
Analysiert alle HTML-Formulare auf korrekte Header-Implementierung
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Tuple

# Basis-Pfad
FORMS_DIR = Path(__file__).parent.parent

# Erwartete Header-Eigenschaften
EXPECTED_HEADER = {
    'bg_color': ['#d0d0d0', '#d3d3d3'],  # Graue Farbe
    'min_height': 60,  # Mindesthöhe in px
    'max_height': 90,  # Maximalhöhe in px
    'title_font_size_min': 20,  # Minimale Titel-Schriftgröße
    'title_font_size_max': 35,  # Maximale Titel-Schriftgröße
    'button_font_size': 12,  # Button-Schriftgröße
}

# Hauptformulare die einen Header haben sollten
HAUPTFORMULARE = [
    'frm_va_Auftragstamm.html',
    'frm_KD_Kundenstamm.html',
    'frm_MA_Mitarbeiterstamm.html',
    'frm_OB_Objekt.html',
    'frm_DP_Dienstplan_MA.html',
    'frm_DP_Dienstplan_Objekt.html',
    'frm_MA_VA_Schnellauswahl.html',
    'frm_Einsatzuebersicht.html',
    'frm_MA_Abwesenheit.html',
    'frm_MA_Zeitkonten.html',
    'frm_Menuefuehrung1.html',
    'frm_Abwesenheiten.html',
    'frm_Ausweis_Create.html',
    'frm_Kundenpreise_gueni.html',
    'frm_MA_VA_Positionszuordnung.html',
    'frm_N_Bewerber.html',
    'frm_abwesenheitsuebersicht.html',
    'frm_Rueckmeldestatistik.html',
    'frm_Systeminfo.html',
]


def extract_css_value(content: str, selector: str, property: str) -> str | None:
    """Extrahiert einen CSS-Wert aus dem Content"""
    # Pattern für CSS-Regeln
    pattern = rf'{re.escape(selector)}\s*{{[^}}]*{re.escape(property)}:\s*([^;}}]+)'
    match = re.search(pattern, content, re.IGNORECASE | re.DOTALL)
    if match:
        return match.group(1).strip()
    return None


def extract_inline_style(content: str, element_pattern: str, property: str) -> str | None:
    """Extrahiert einen Inline-Style-Wert"""
    # Pattern für inline styles
    pattern = rf'<{element_pattern}[^>]*style="[^"]*{property}:\s*([^;"]+)'
    match = re.search(pattern, content, re.IGNORECASE)
    if match:
        return match.group(1).strip()
    return None


def parse_size(value: str) -> float | None:
    """Konvertiert CSS-Größenangabe zu Pixel"""
    if not value:
        return None

    value = value.lower().strip()

    # px
    if 'px' in value:
        return float(value.replace('px', '').strip())

    # rem (angenommen 16px base)
    if 'rem' in value:
        return float(value.replace('rem', '').strip()) * 16

    # em (angenommen 16px base)
    if 'em' in value:
        return float(value.replace('em', '').strip()) * 16

    # Nur Zahl
    try:
        return float(value)
    except:
        return None


def validate_form_header(file_path: Path) -> Dict:
    """Validiert den Header eines Formulars"""

    result = {
        'file': file_path.name,
        'exists': False,
        'header_found': False,
        'header_class': None,
        'bg_color': None,
        'bg_color_ok': False,
        'height': None,
        'height_ok': False,
        'title_found': False,
        'title_font_size': None,
        'title_font_size_ok': False,
        'buttons_found': False,
        'button_count': 0,
        'issues': [],
        'warnings': [],
    }

    # Datei existiert?
    if not file_path.exists():
        result['issues'].append('Datei nicht gefunden')
        return result

    result['exists'] = True

    # Datei lesen
    try:
        content = file_path.read_text(encoding='utf-8')
    except Exception as e:
        result['issues'].append(f'Fehler beim Lesen: {e}')
        return result

    # Header-Element suchen
    header_patterns = [
        r'<header[^>]*class="[^"]*form-header[^"]*"',
        r'<div[^>]*class="[^"]*form-header[^"]*"',
        r'<div[^>]*class="[^"]*header-bar[^"]*"',
        r'<div[^>]*class="[^"]*app-header[^"]*"',
        r'<div[^>]*class="[^"]*\.header[^"]*"',
    ]

    for pattern in header_patterns:
        if re.search(pattern, content, re.IGNORECASE):
            result['header_found'] = True
            # Extrahiere Klasse
            match = re.search(pattern, content, re.IGNORECASE)
            if match:
                class_match = re.search(r'class="([^"]+)"', match.group(0))
                if class_match:
                    result['header_class'] = class_match.group(1)
            break

    if not result['header_found']:
        result['issues'].append('Kein Header-Element gefunden')
        return result

    # CSS-Selektoren für Header
    header_selectors = ['.form-header', '.header-bar', '.app-header', '.header']

    # Hintergrundfarbe prüfen
    for selector in header_selectors:
        bg_color = extract_css_value(content, selector, 'background')
        if not bg_color:
            bg_color = extract_css_value(content, selector, 'background-color')

        if bg_color:
            result['bg_color'] = bg_color
            # Prüfe ob graue Farbe
            if any(color in bg_color.lower() for color in EXPECTED_HEADER['bg_color']):
                result['bg_color_ok'] = True
            else:
                # Prüfe ob es eine Gradient mit Grau ist
                if 'gradient' in bg_color.lower() and '#d' in bg_color.lower():
                    result['bg_color_ok'] = True
                    result['warnings'].append(f'Header verwendet Gradient statt Solid Color: {bg_color}')
            break

    if not result['bg_color']:
        result['issues'].append('Keine Header-Hintergrundfarbe gefunden')
    elif not result['bg_color_ok']:
        result['issues'].append(f'Header-Farbe nicht grau: {result["bg_color"]}')

    # Höhe prüfen
    for selector in header_selectors:
        height = extract_css_value(content, selector, 'height')
        if height:
            height_px = parse_size(height)
            if height_px:
                result['height'] = height_px
                if EXPECTED_HEADER['min_height'] <= height_px <= EXPECTED_HEADER['max_height']:
                    result['height_ok'] = True
                else:
                    result['issues'].append(f'Header-Höhe außerhalb Bereich: {height_px}px (erwartet: {EXPECTED_HEADER["min_height"]}-{EXPECTED_HEADER["max_height"]}px)')
                break

    if not result['height']:
        result['warnings'].append('Keine feste Header-Höhe gefunden')

    # Titel suchen
    title_patterns = [
        r'<h1[^>]*>([^<]+)</h1>',
        r'<[^>]*class="[^"]*app-title[^"]*"[^>]*>',
        r'<[^>]*class="[^"]*form-title[^"]*"[^>]*>',
        r'<[^>]*class="[^"]*header-title[^"]*"[^>]*>',
    ]

    for pattern in title_patterns:
        if re.search(pattern, content, re.IGNORECASE):
            result['title_found'] = True
            break

    # Titel-Schriftgröße
    title_selectors = ['.app-title', '.form-title', '.header-title', 'h1']
    for selector in title_selectors:
        font_size = extract_css_value(content, selector, 'font-size')
        if font_size:
            size_px = parse_size(font_size)
            if size_px:
                result['title_font_size'] = size_px
                if EXPECTED_HEADER['title_font_size_min'] <= size_px <= EXPECTED_HEADER['title_font_size_max']:
                    result['title_font_size_ok'] = True
                else:
                    result['issues'].append(f'Titel-Schriftgröße außerhalb Bereich: {size_px}px (erwartet: {EXPECTED_HEADER["title_font_size_min"]}-{EXPECTED_HEADER["title_font_size_max"]}px)')
                break

    if result['title_found'] and not result['title_font_size']:
        result['warnings'].append('Titel gefunden, aber keine Schriftgröße')

    # Buttons im Header zählen
    button_pattern = r'<button[^>]*>|<div[^>]*class="[^"]*btn[^"]*"[^>]*>'
    buttons = re.findall(button_pattern, content)
    result['button_count'] = len(buttons)
    if result['button_count'] > 0:
        result['buttons_found'] = True

    return result


def generate_markdown_report(results: List[Dict]) -> str:
    """Generiert einen Markdown-Report"""

    report = []
    report.append("# Header Validierungs-Report")
    report.append("")
    report.append(f"**Datum:** {Path(__file__).stat().st_mtime}")
    report.append(f"**Analysierte Formulare:** {len(results)}")
    report.append("")

    # Statistiken
    with_header = sum(1 for r in results if r['header_found'])
    correct_color = sum(1 for r in results if r['bg_color_ok'])
    correct_height = sum(1 for r in results if r['height_ok'])
    correct_title = sum(1 for r in results if r['title_font_size_ok'])

    report.append("## Zusammenfassung")
    report.append("")
    report.append(f"- ✅ Header vorhanden: {with_header}/{len(results)} ({with_header*100//len(results)}%)")
    report.append(f"- ✅ Korrekte Farbe: {correct_color}/{len(results)} ({correct_color*100//len(results)}%)")
    report.append(f"- ✅ Korrekte Höhe: {correct_height}/{len(results)} ({correct_height*100//len(results)}%)")
    report.append(f"- ✅ Korrekte Titel-Größe: {correct_title}/{len(results)} ({correct_title*100//len(results)}%)")
    report.append("")

    # Detaillierte Tabelle
    report.append("## Detaillierte Validierung")
    report.append("")
    report.append("| Formular | Header | Farbe | Höhe | Titel | Buttons | Status |")
    report.append("|----------|--------|-------|------|-------|---------|--------|")

    for r in results:
        status = "✅" if (r['header_found'] and r['bg_color_ok'] and r['height_ok'] and r['title_font_size_ok']) else "❌"
        header = "✅" if r['header_found'] else "❌"
        color = "✅" if r['bg_color_ok'] else "❌"
        height = "✅" if r['height_ok'] else "⚠️"
        title = "✅" if r['title_font_size_ok'] else "❌"
        buttons = f"{r['button_count']}" if r['buttons_found'] else "0"

        report.append(f"| {r['file']} | {header} | {color} | {height} | {title} | {buttons} | {status} |")

    report.append("")

    # Probleme
    report.append("## Gefundene Probleme")
    report.append("")

    for r in results:
        if r['issues']:
            report.append(f"### {r['file']}")
            report.append("")
            for issue in r['issues']:
                report.append(f"- ❌ {issue}")
            if r['warnings']:
                for warning in r['warnings']:
                    report.append(f"- ⚠️ {warning}")
            report.append("")

    # Details
    report.append("## Technische Details")
    report.append("")

    for r in results:
        report.append(f"### {r['file']}")
        report.append("")
        report.append(f"- **Header-Klasse:** `{r['header_class'] or 'N/A'}`")
        report.append(f"- **Hintergrundfarbe:** `{r['bg_color'] or 'N/A'}`")
        report.append(f"- **Höhe:** `{r['height']}px` {'' if r['height_ok'] else '❌'}" if r['height'] else "- **Höhe:** N/A")
        report.append(f"- **Titel-Schriftgröße:** `{r['title_font_size']}px` {'' if r['title_font_size_ok'] else '❌'}" if r['title_font_size'] else "- **Titel-Schriftgröße:** N/A")
        report.append(f"- **Buttons:** {r['button_count']}")
        report.append("")

    return "\n".join(report)


def main():
    """Hauptfunktion"""

    print("=== Header Validierung ===")
    print(f"Verzeichnis: {FORMS_DIR}")
    print()

    results = []

    for form_name in HAUPTFORMULARE:
        form_path = FORMS_DIR / form_name
        print(f"Analysiere: {form_name}...", end=" ")

        result = validate_form_header(form_path)
        results.append(result)

        if result['header_found'] and result['bg_color_ok']:
            print("OK")
        elif result['header_found']:
            print("WARN")
        else:
            print("FEHLT")

    print()
    print("Generiere Report...")

    report = generate_markdown_report(results)

    # Report speichern
    report_path = FORMS_DIR / 'HEADER_VALIDATION_REPORT.md'
    report_path.write_text(report, encoding='utf-8')

    print(f"Report gespeichert: {report_path}")
    print()

    # Statistiken ausgeben
    with_header = sum(1 for r in results if r['header_found'])
    correct = sum(1 for r in results if r['header_found'] and r['bg_color_ok'] and r['height_ok'])

    print(f"Ergebnis: {correct}/{len(results)} Formulare vollständig korrekt")
    print(f"Header vorhanden: {with_header}/{len(results)}")


if __name__ == '__main__':
    main()

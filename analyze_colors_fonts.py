"""
Analyse-Skript für Farb- und Schriftgrößen-Inventar der HTML-Formulare
"""
import re
import os
from pathlib import Path
from collections import defaultdict

# Pfad zu den Formularen
FORMS_DIR = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms")

def extract_colors_and_fonts(html_content):
    """Extrahiert Farben und Schriftgrößen aus HTML-Dateien"""
    colors = set()
    font_sizes = set()
    backgrounds = set()

    # Regex-Patterns
    color_pattern = r'color:\s*([#\w(),-]+);'
    bg_pattern = r'background(?:-color)?:\s*([^;]+);'
    font_size_pattern = r'font-size:\s*([^;]+);'

    # Farben extrahieren
    for match in re.finditer(color_pattern, html_content, re.IGNORECASE):
        colors.add(match.group(1).strip())

    # Hintergrundfarben extrahieren
    for match in re.finditer(bg_pattern, html_content, re.IGNORECASE):
        bg = match.group(1).strip()
        backgrounds.add(bg)

    # Schriftgrößen extrahieren
    for match in re.finditer(font_size_pattern, html_content, re.IGNORECASE):
        font_sizes.add(match.group(1).strip())

    return colors, backgrounds, font_sizes

def analyze_forms():
    """Analysiert alle Hauptformulare"""
    results = {}

    # Nur Hauptformulare (frm_*.html) im root-Ordner
    for file_path in FORMS_DIR.glob("frm_*.html"):
        if file_path.is_file():
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                colors, backgrounds, font_sizes = extract_colors_and_fonts(content)
                results[file_path.name] = {
                    'colors': colors,
                    'backgrounds': backgrounds,
                    'font_sizes': font_sizes
                }

    return results

def generate_report(results):
    """Generiert einen übersichtlichen Report"""
    all_colors = set()
    all_backgrounds = set()
    all_font_sizes = set()

    # Aggregiere alle Werte
    for data in results.values():
        all_colors.update(data['colors'])
        all_backgrounds.update(data['backgrounds'])
        all_font_sizes.update(data['font_sizes'])

    report = []
    report.append("=" * 80)
    report.append("FARB- UND SCHRIFTGROSSEN-INVENTAR - HTML FORMULARE")
    report.append("=" * 80)
    report.append("")

    # Hintergrundfarben
    report.append("## HINTERGRUNDFARBEN (GLOBAL)")
    report.append("-" * 80)
    for bg in sorted(all_backgrounds):
        count = sum(1 for data in results.values() if bg in data['backgrounds'])
        report.append(f"  {bg:<50} ({count} Formulare)")
    report.append("")

    # Textfarben
    report.append("## TEXTFARBEN (GLOBAL)")
    report.append("-" * 80)
    for color in sorted(all_colors):
        count = sum(1 for data in results.values() if color in data['colors'])
        report.append(f"  {color:<50} ({count} Formulare)")
    report.append("")

    # Schriftgrößen
    report.append("## SCHRIFTGROSSEN (GLOBAL)")
    report.append("-" * 80)
    for size in sorted(all_font_sizes):
        count = sum(1 for data in results.values() if size in data['font_sizes'])
        report.append(f"  {size:<50} ({count} Formulare)")
    report.append("")

    # Pro Formular
    report.append("=" * 80)
    report.append("DETAILS PRO FORMULAR")
    report.append("=" * 80)
    report.append("")

    for form_name, data in sorted(results.items()):
        report.append(f"\n### {form_name}")
        report.append("-" * 80)
        report.append(f"  Hintergrundfarben: {len(data['backgrounds'])}")
        report.append(f"  Textfarben: {len(data['colors'])}")
        report.append(f"  Schriftgrößen: {len(data['font_sizes'])}")

    return "\n".join(report)

def main():
    print("Starte Analyse der HTML-Formulare...")
    results = analyze_forms()
    print(f"✓ {len(results)} Formulare analysiert")

    report = generate_report(results)

    # Report speichern
    output_file = FORMS_DIR.parent.parent / "COLOR_FONT_INVENTORY.txt"
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(report)

    print(f"✓ Report gespeichert: {output_file}")
    print("\n" + "=" * 80)
    print(report[:2000] + "\n... (Siehe vollständigen Report in COLOR_FONT_INVENTORY.txt)")

if __name__ == "__main__":
    main()

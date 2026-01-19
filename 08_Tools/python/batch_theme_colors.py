# -*- coding: utf-8 -*-
"""
CCD AUTOPILOT - Schritt 2: Theme-Farben korrigieren
Ersetzt alle falschen Farben durch Königsblau (#4169E1)
"""

import os
import re
from pathlib import Path

FORMS_DIR = r"C:\Users\guenther.siegert\Documents\Consys_HTML\02_web\forms"
CSS_DIR = r"C:\Users\guenther.siegert\Documents\Consys_HTML\02_web\css"

# Königsblau Theme
KOENIGSBLAU = "#4169E1"
KOENIGSBLAU_DARK = "#3558c0"

# Falsche Farben die ersetzt werden sollen
WRONG_COLORS = {
    # Lila/Violett
    "#6a5acd": KOENIGSBLAU,
    "#5a4abd": KOENIGSBLAU_DARK,
    "rgb(106, 90, 205)": KOENIGSBLAU,
    "rgb(90, 74, 189)": KOENIGSBLAU_DARK,
    # Weitere Access-Standardfarben
    "#4472c4": KOENIGSBLAU,  # Office Blue
    "#5b9bd5": KOENIGSBLAU,  # Light Office Blue
    "#2e75b6": KOENIGSBLAU,  # Dark Office Blue
}

def fix_colors_in_file(filepath):
    """Ersetzt falsche Farben in einer Datei"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return {"file": os.path.basename(filepath), "error": str(e), "changes": []}

    original = content
    changes = []

    for wrong, correct in WRONG_COLORS.items():
        pattern = re.compile(re.escape(wrong), re.IGNORECASE)
        matches = pattern.findall(content)
        if matches:
            content = pattern.sub(correct, content)
            changes.append(f"{wrong} -> {correct} ({len(matches)}x)")

    # Spezielle Patterns: linear-gradient mit falschen Farben
    gradient_pattern = r'(linear-gradient\s*\(\s*\d+deg\s*,\s*)#6a5acd(\s*\d*%?\s*,\s*)#5a4abd'
    if re.search(gradient_pattern, content, re.IGNORECASE):
        content = re.sub(
            gradient_pattern,
            rf'\g<1>{KOENIGSBLAU}\g<2>{KOENIGSBLAU_DARK}',
            content,
            flags=re.IGNORECASE
        )
        changes.append("Header-Gradient korrigiert")

    # Style-Tags mit accent-color
    accent_pattern = r'--accent-color:\s*#6a5acd'
    if re.search(accent_pattern, content, re.IGNORECASE):
        content = re.sub(
            accent_pattern,
            f'--accent-color: {KOENIGSBLAU}',
            content,
            flags=re.IGNORECASE
        )
        changes.append("--accent-color korrigiert")

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

    return {
        "file": os.path.basename(filepath),
        "modified": content != original,
        "changes": changes
    }

def process_directory(directory, extensions):
    """Verarbeitet alle Dateien mit bestimmten Erweiterungen"""
    results = []

    for ext in extensions:
        for filepath in Path(directory).glob(f"*{ext}"):
            result = fix_colors_in_file(str(filepath))
            results.append(result)

    return results

def main():
    print("=" * 60)
    print("CCD AUTOPILOT - Theme Farben Korrektur")
    print("Ziel: Königsblau (#4169E1)")
    print("=" * 60)

    all_results = []

    # HTML-Dateien
    print("\n[1/3] HTML-Dateien in forms/...")
    html_results = process_directory(FORMS_DIR, [".html"])
    all_results.extend(html_results)
    modified_html = sum(1 for r in html_results if r.get("modified"))
    print(f"  {len(html_results)} Dateien geprüft, {modified_html} modifiziert")

    # CSS-Dateien in forms/
    print("\n[2/3] CSS-Dateien in forms/...")
    css_results = process_directory(FORMS_DIR, [".css"])
    all_results.extend(css_results)
    modified_css = sum(1 for r in css_results if r.get("modified"))
    print(f"  {len(css_results)} Dateien geprüft, {modified_css} modifiziert")

    # CSS-Dateien in css/
    print("\n[3/3] CSS-Dateien in css/...")
    css_results2 = process_directory(CSS_DIR, [".css"])
    all_results.extend(css_results2)
    modified_css2 = sum(1 for r in css_results2 if r.get("modified"))
    print(f"  {len(css_results2)} Dateien geprüft, {modified_css2} modifiziert")

    # Zusammenfassung
    print("\n" + "=" * 60)
    print("ZUSAMMENFASSUNG")
    print("=" * 60)

    total_modified = sum(1 for r in all_results if r.get("modified"))
    print(f"Gesamt geprüft: {len(all_results)} Dateien")
    print(f"Modifiziert:    {total_modified} Dateien")

    if total_modified > 0:
        print("\nGeänderte Dateien:")
        for r in all_results:
            if r.get("modified"):
                print(f"  - {r['file']}")
                for change in r.get("changes", []):
                    print(f"      {change}")

    return all_results

if __name__ == "__main__":
    main()

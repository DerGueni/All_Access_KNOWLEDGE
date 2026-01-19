# -*- coding: utf-8 -*-
"""
CCD AUTOPILOT - Schritt 8: Bildschirmgroessen-Pruefung
Prueft ob alle Formulare responsive Media Queries haben
"""

import os
import re
from pathlib import Path

FORMS_DIR = r"C:\Users\guenther.siegert\Documents\Consys_HTML\02_web\forms"
CSS_DIR = r"C:\Users\guenther.siegert\Documents\Consys_HTML\02_web\css"

# Erwartete Breakpoints (11" bis 23" Monitore)
EXPECTED_BREAKPOINTS = [
    ("1920px", "21-23 Zoll"),
    ("1400px", "15-20 Zoll"),
    ("1200px", "13-14 Zoll"),
    ("1000px", "11-12 Zoll"),
]

def check_css_file(filepath):
    """Prueft CSS-Datei auf responsive Breakpoints"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return {"file": os.path.basename(filepath), "error": str(e)}

    result = {
        "file": os.path.basename(filepath),
        "has_media_queries": "@media" in content,
        "breakpoints": [],
        "responsive_score": 0
    }

    # Finde alle Media Query Breakpoints
    media_matches = re.findall(r'@media[^{]+\{', content)
    for match in media_matches:
        # Extrahiere Pixel-Werte
        px_values = re.findall(r'(\d+)px', match)
        for px in px_values:
            if px not in result["breakpoints"]:
                result["breakpoints"].append(px)

    # Berechne Responsive Score
    score = 0
    for bp, desc in EXPECTED_BREAKPOINTS:
        bp_value = bp.replace("px", "")
        if bp_value in result["breakpoints"]:
            score += 25
    result["responsive_score"] = score

    # Pruefe auf problematische Patterns
    result["issues"] = []

    # Feste Breiten ueber 1600px
    large_widths = re.findall(r'width:\s*(\d{4,})px', content)
    large_widths = [w for w in large_widths if int(w) > 1600]
    if large_widths:
        result["issues"].append(f"Sehr grosse feste Breiten: {large_widths}")

    # Nur px-basierte Hoehen/Breiten ohne Media Queries
    if not result["has_media_queries"]:
        fixed_sizes = len(re.findall(r':\s*\d+px', content))
        if fixed_sizes > 20:
            result["issues"].append(f"Viele feste Pixel-Werte ({fixed_sizes}x) ohne Media Queries")

    return result

def check_html_file(filepath):
    """Prueft HTML-Datei auf responsive Elemente"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return {"file": os.path.basename(filepath), "error": str(e)}

    result = {
        "file": os.path.basename(filepath),
        "has_viewport": 'name="viewport"' in content,
        "has_flex": "display: flex" in content or "display:flex" in content,
        "has_grid": "display: grid" in content or "display:grid" in content,
        "inline_media_queries": "@media" in content,
        "linked_css": [],
        "issues": []
    }

    # Finde verlinkte CSS-Dateien
    css_links = re.findall(r'<link[^>]+href="([^"]+\.css)"', content)
    result["linked_css"] = css_links

    if not result["has_viewport"]:
        result["issues"].append("Kein Viewport Meta-Tag")

    return result

def main():
    print("=" * 60)
    print("CCD AUTOPILOT - Bildschirmgroessen-Pruefung")
    print("Ziel: Responsive fuer 11-23 Zoll Monitore")
    print("=" * 60)

    html_results = []
    css_results = []

    # HTML-Dateien pruefen
    print("\n[1/2] HTML-Dateien...")
    for filepath in Path(FORMS_DIR).glob("*.html"):
        result = check_html_file(str(filepath))
        html_results.append(result)

    # CSS-Dateien in forms/ pruefen
    print("[2/2] CSS-Dateien...")
    for filepath in Path(FORMS_DIR).glob("*.css"):
        result = check_css_file(str(filepath))
        css_results.append(result)

    # Auch app-layout.css pruefen
    app_layout = os.path.join(CSS_DIR, "app-layout.css")
    if os.path.exists(app_layout):
        result = check_css_file(app_layout)
        css_results.append(result)

    # Zusammenfassung
    print("\n" + "=" * 60)
    print("CSS RESPONSIVE ANALYSE")
    print("=" * 60)

    fully_responsive = 0
    partially_responsive = 0
    not_responsive = 0

    for r in css_results:
        score = r.get("responsive_score", 0)
        status = ""
        if score >= 75:
            status = "VOLLSTAENDIG RESPONSIVE"
            fully_responsive += 1
        elif score >= 50:
            status = "TEILWEISE RESPONSIVE"
            partially_responsive += 1
        elif r.get("has_media_queries"):
            status = "BASIC RESPONSIVE"
            partially_responsive += 1
        else:
            status = "NICHT RESPONSIVE"
            not_responsive += 1

        bp_str = ", ".join(r.get("breakpoints", [])[:4]) if r.get("breakpoints") else "-"
        print(f"  {r['file'][:35]:<35} [{score:>3}%] {status} | BP: {bp_str}")

    print("\n" + "-" * 60)
    print(f"Vollstaendig responsive:  {fully_responsive}")
    print(f"Teilweise responsive:     {partially_responsive}")
    print(f"Nicht responsive:         {not_responsive}")

    # HTML Viewport Check
    print("\n" + "=" * 60)
    print("HTML VIEWPORT CHECK")
    print("=" * 60)

    no_viewport = [r for r in html_results if not r.get("has_viewport")]
    if no_viewport:
        print("Formulare OHNE Viewport Meta-Tag:")
        for r in no_viewport:
            print(f"  - {r['file']}")
    else:
        print("Alle HTML-Dateien haben Viewport Meta-Tag!")

    # Flexbox/Grid Usage
    with_flex = sum(1 for r in html_results if r.get("has_flex"))
    with_grid = sum(1 for r in html_results if r.get("has_grid"))
    print(f"\nMit Flexbox: {with_flex}/{len(html_results)}")
    print(f"Mit CSS Grid: {with_grid}/{len(html_results)}")

    return {
        "html": html_results,
        "css": css_results,
        "summary": {
            "fully_responsive": fully_responsive,
            "partially_responsive": partially_responsive,
            "not_responsive": not_responsive
        }
    }

if __name__ == "__main__":
    main()

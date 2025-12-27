#!/usr/bin/env python3
"""
Visual Compare Tool für Access-zu-HTML Formular-Nachbildung
Macht Screenshots von HTML-Formularen und vergleicht sie mit dem Original
"""

import os
import sys
from pathlib import Path
from playwright.sync_api import sync_playwright

# Pfade
BASE_DIR = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE")
FORMS_DIR = BASE_DIR / "04_HTML_Forms" / "forms"
SCREENSHOTS_DIR = BASE_DIR / "Screenshots ACCESS Formulare"
OUTPUT_DIR = BASE_DIR / "04_HTML_Forms" / "screenshots"

def ensure_dirs():
    """Erstellt Output-Verzeichnis falls nicht vorhanden"""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

def take_screenshot(html_path: str, output_name: str = None, width: int = 1920, height: int = 1080) -> str:
    """
    Macht einen Screenshot einer HTML-Datei

    Args:
        html_path: Pfad zur HTML-Datei
        output_name: Name für den Screenshot (ohne Extension)
        width: Viewport-Breite
        height: Viewport-Höhe

    Returns:
        Pfad zum Screenshot
    """
    ensure_dirs()

    html_path = Path(html_path)
    if not html_path.exists():
        raise FileNotFoundError(f"HTML-Datei nicht gefunden: {html_path}")

    if output_name is None:
        output_name = html_path.stem

    output_path = OUTPUT_DIR / f"{output_name}.png"

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(viewport={'width': width, 'height': height})

        # Lade HTML-Datei
        page.goto(f"file:///{html_path.as_posix()}")

        # Warte bis Seite geladen
        page.wait_for_load_state('networkidle')

        # Screenshot machen
        page.screenshot(path=str(output_path), full_page=False)

        browser.close()

    print(f"Screenshot gespeichert: {output_path}")
    return str(output_path)


def compare_screenshots(html_screenshot: str, original_screenshot: str, crop_top: int = 0) -> dict:
    """
    Vergleicht zwei Screenshots und gibt Unterschiede zurück

    Args:
        crop_top: Pixel vom oberen Rand abschneiden (z.B. Access-Ribbon)

    Returns:
        dict mit Vergleichsergebnissen
    """
    try:
        from PIL import Image, ImageChops, ImageDraw
        import math
    except ImportError:
        print("Pillow nicht installiert. Installiere mit: pip install Pillow")
        return {"error": "Pillow nicht installiert"}

    img1 = Image.open(html_screenshot).convert('RGB')
    img2 = Image.open(original_screenshot).convert('RGB')

    # Optional: Oberen Bereich abschneiden (Access-Ribbon)
    if crop_top > 0:
        img2 = img2.crop((0, crop_top, img2.width, img2.height))

    # Groessen angleichen falls unterschiedlich
    if img1.size != img2.size:
        # Resize img2 to match img1
        img2 = img2.resize(img1.size, Image.Resampling.LANCZOS)

    # Differenzbild erstellen
    diff = ImageChops.difference(img1, img2)

    # Statistiken berechnen
    diff_pixels = list(diff.getdata())
    total_diff = sum(sum(pixel) for pixel in diff_pixels)
    max_possible = len(diff_pixels) * 255 * 3
    similarity = 1 - (total_diff / max_possible)

    # Differenzbild speichern
    diff_path = OUTPUT_DIR / "diff.png"

    # Verstärke Unterschiede für bessere Sichtbarkeit
    diff_enhanced = diff.point(lambda x: min(255, x * 10))
    diff_enhanced.save(str(diff_path))

    # Overlay erstellen (Original mit roten Markierungen für Unterschiede)
    overlay = img2.copy()
    overlay_draw = ImageDraw.Draw(overlay)

    # Finde Bereiche mit großen Unterschieden
    diff_gray = diff.convert('L')
    threshold = 30

    result = {
        "similarity_percent": round(similarity * 100, 2),
        "html_screenshot": html_screenshot,
        "original_screenshot": original_screenshot,
        "diff_image": str(diff_path),
        "html_size": img1.size,
        "original_size": Image.open(original_screenshot).size,
    }

    print(f"\n{'='*60}")
    print(f"VERGLEICHSERGEBNIS")
    print(f"{'='*60}")
    print(f"Ähnlichkeit: {result['similarity_percent']}%")
    print(f"HTML-Screenshot: {result['html_screenshot']}")
    print(f"Original: {result['original_screenshot']}")
    print(f"Differenzbild: {result['diff_image']}")
    print(f"{'='*60}\n")

    return result


def analyze_form(form_name: str):
    """
    Analysiert ein Formular und vergleicht mit Original

    Args:
        form_name: Name des Formulars (z.B. "frm_va_Auftragstamm")
    """
    from PIL import Image

    # Finde HTML-Datei
    html_candidates = [
        FORMS_DIR / f"{form_name}.html",
        FORMS_DIR / f"{form_name}_v2.html",
        FORMS_DIR / f"{form_name}_precise.html",
    ]

    html_path = None
    for candidate in html_candidates:
        if candidate.exists():
            html_path = candidate
            break

    if not html_path:
        print(f"Keine HTML-Datei gefunden fuer: {form_name}")
        return

    # Finde Original-Screenshot
    original_candidates = [
        SCREENSHOTS_DIR / f"{form_name}.jpg",
        SCREENSHOTS_DIR / f"{form_name}.png",
        SCREENSHOTS_DIR / f"frm_VA_Auftragstamm.jpg",  # Spezialfall
    ]

    original_path = None
    for candidate in original_candidates:
        if candidate.exists():
            original_path = candidate
            break

    if not original_path:
        print(f"Kein Original-Screenshot gefunden fuer: {form_name}")
        return

    print(f"\nAnalysiere: {form_name}")
    print(f"HTML: {html_path}")
    print(f"Original: {original_path}")

    # Hole Original-Groesse
    orig_img = Image.open(str(original_path))
    orig_width, orig_height = orig_img.size
    print(f"Original-Groesse: {orig_width}x{orig_height}")

    # Screenshot machen - gleiche Groesse wie Original
    screenshot_path = take_screenshot(str(html_path), f"{form_name}_current",
                                      width=orig_width, height=orig_height)

    # Vergleichen - 50 Pixel oben abschneiden (Access-Ribbon)
    result = compare_screenshots(screenshot_path, str(original_path), crop_top=50)

    return result


def interactive_improve(form_name: str):
    """
    Interaktiver Modus: Zeigt Unterschiede und erlaubt schrittweise Verbesserung
    """
    result = analyze_form(form_name)

    if result and result.get('similarity_percent', 0) < 95:
        print("\n⚠️  Signifikante Unterschiede gefunden!")
        print(f"Differenzbild wurde gespeichert: {result.get('diff_image')}")
        print("\nNächste Schritte:")
        print("1. Öffne das Differenzbild um Problemstellen zu identifizieren")
        print("2. Passe das HTML/CSS entsprechend an")
        print("3. Führe dieses Script erneut aus")
    elif result:
        print("\n✅ Sehr gute Übereinstimmung!")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        form_name = sys.argv[1]
    else:
        form_name = "frm_va_Auftragstamm_v2"

    # Einzelner Screenshot
    if len(sys.argv) > 2 and sys.argv[2] == "--screenshot-only":
        html_path = FORMS_DIR / f"{form_name}.html"
        if html_path.exists():
            take_screenshot(str(html_path), form_name)
        else:
            print(f"Datei nicht gefunden: {html_path}")
    else:
        # Vollständige Analyse
        interactive_improve(form_name)

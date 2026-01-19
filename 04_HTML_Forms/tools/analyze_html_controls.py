"""
Analysiert HTML-Formular Controls
"""

import sys
import io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

from playwright.sync_api import sync_playwright
import json
from pathlib import Path

# Pfade
SCREENSHOTS_DIR = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\screenshots_test")
HTML_PATH = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\frm_va_Auftragstamm.html")

def capture_html_screenshot():
    """Erstellt Screenshot des HTML-Formulars"""
    print("Erstelle HTML-Screenshot...")

    screenshot_path = SCREENSHOTS_DIR / "html_frm_va_Auftragstamm.png"

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context(viewport={'width': 1600, 'height': 1200})
        page = context.new_page()

        # Öffne HTML
        page.goto(f"file:///{HTML_PATH.as_posix()}")
        print("  ✓ HTML geladen")

        # Warte auf vollständiges Laden
        page.wait_for_load_state('networkidle')
        page.wait_for_timeout(2000)

        # Screenshot
        page.screenshot(path=str(screenshot_path), full_page=True)
        print(f"  ✓ Screenshot: {screenshot_path}")

        browser.close()

    return screenshot_path

def analyze_html_controls():
    """Analysiert alle Controls im HTML"""
    print("\nAnalysiere HTML-Controls...")

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(viewport={'width': 1600, 'height': 1200})
        page.goto(f"file:///{HTML_PATH.as_posix()}")
        page.wait_for_load_state('networkidle')

        # Extrahiere Controls
        result = page.evaluate("""() => {
            const controls = {
                textboxes: [],
                labels: [],
                buttons: [],
                checkboxes: [],
                comboboxes: [],
                tabs: [],
                subforms: [],
                rectangles: []
            };

            // TextBoxes
            document.querySelectorAll('input[type="text"], input:not([type]), textarea').forEach(el => {
                const rect = el.getBoundingClientRect();
                if (el.offsetParent !== null) {
                    controls.textboxes.push({
                        id: el.id,
                        name: el.name || el.id,
                        placeholder: el.placeholder,
                        left: Math.round(rect.left),
                        top: Math.round(rect.top),
                        width: Math.round(rect.width),
                        height: Math.round(rect.height)
                    });
                }
            });

            // Labels
            document.querySelectorAll('label, .label').forEach(el => {
                const rect = el.getBoundingClientRect();
                if (el.offsetParent !== null) {
                    controls.labels.push({
                        id: el.id,
                        text: el.textContent.trim(),
                        for: el.getAttribute('for'),
                        left: Math.round(rect.left),
                        top: Math.round(rect.top),
                        width: Math.round(rect.width),
                        height: Math.round(rect.height)
                    });
                }
            });

            // Buttons
            document.querySelectorAll('button, input[type="button"], input[type="submit"]').forEach(el => {
                const rect = el.getBoundingClientRect();
                if (el.offsetParent !== null) {
                    controls.buttons.push({
                        id: el.id,
                        text: el.textContent.trim() || el.value,
                        left: Math.round(rect.left),
                        top: Math.round(rect.top),
                        width: Math.round(rect.width),
                        height: Math.round(rect.height)
                    });
                }
            });

            // Checkboxes
            document.querySelectorAll('input[type="checkbox"]').forEach(el => {
                const rect = el.getBoundingClientRect();
                if (el.offsetParent !== null) {
                    controls.checkboxes.push({
                        id: el.id,
                        name: el.name || el.id,
                        left: Math.round(rect.left),
                        top: Math.round(rect.top),
                        width: Math.round(rect.width),
                        height: Math.round(rect.height)
                    });
                }
            });

            // Comboboxes/Select
            document.querySelectorAll('select').forEach(el => {
                const rect = el.getBoundingClientRect();
                if (el.offsetParent !== null) {
                    controls.comboboxes.push({
                        id: el.id,
                        name: el.name || el.id,
                        left: Math.round(rect.left),
                        top: Math.round(rect.top),
                        width: Math.round(rect.width),
                        height: Math.round(rect.height)
                    });
                }
            });

            // Tabs
            document.querySelectorAll('.tab-button, [role="tab"]').forEach(el => {
                const rect = el.getBoundingClientRect();
                if (el.offsetParent !== null) {
                    controls.tabs.push({
                        id: el.id,
                        text: el.textContent.trim(),
                        left: Math.round(rect.left),
                        top: Math.round(rect.top),
                        width: Math.round(rect.width),
                        height: Math.round(rect.height)
                    });
                }
            });

            // Subforms (Iframes)
            document.querySelectorAll('iframe').forEach(el => {
                const rect = el.getBoundingClientRect();
                if (el.offsetParent !== null) {
                    controls.subforms.push({
                        id: el.id,
                        src: el.src,
                        left: Math.round(rect.left),
                        top: Math.round(rect.top),
                        width: Math.round(rect.width),
                        height: Math.round(rect.height)
                    });
                }
            });

            // Rectangles/Dividers
            document.querySelectorAll('.rectangle, .divider, hr').forEach(el => {
                const rect = el.getBoundingClientRect();
                if (el.offsetParent !== null) {
                    controls.rectangles.push({
                        id: el.id,
                        className: el.className,
                        left: Math.round(rect.left),
                        top: Math.round(rect.top),
                        width: Math.round(rect.width),
                        height: Math.round(rect.height)
                    });
                }
            });

            return controls;
        }""")

        browser.close()

    return result

def print_analysis(controls):
    """Gibt Analyse aus"""
    print("\n" + "="*80)
    print("HTML-FORMULAR ANALYSE: frm_va_Auftragstamm")
    print("="*80)

    total = sum(len(v) for v in controls.values())
    print(f"\nGesamt Controls: {total}\n")

    # TextBoxes
    print(f"TextBoxes ({len(controls['textboxes'])}):")
    for ctrl in controls['textboxes']:
        print(f"  • {ctrl['name']}: {ctrl['width']}x{ctrl['height']}px @ ({ctrl['left']}, {ctrl['top']})")

    # Labels
    print(f"\nLabels ({len(controls['labels'])}):")
    for ctrl in controls['labels'][:20]:  # Top 20
        text = ctrl['text'][:40] + '...' if len(ctrl['text']) > 40 else ctrl['text']
        print(f"  • {text}")

    # Buttons
    print(f"\nButtons ({len(controls['buttons'])}):")
    for ctrl in controls['buttons']:
        print(f"  • {ctrl['text']}: {ctrl['width']}x{ctrl['height']}px @ ({ctrl['left']}, {ctrl['top']})")

    # Checkboxes
    print(f"\nCheckboxes ({len(controls['checkboxes'])}):")
    for ctrl in controls['checkboxes']:
        print(f"  • {ctrl['name']}")

    # Comboboxes
    print(f"\nComboboxes ({len(controls['comboboxes'])}):")
    for ctrl in controls['comboboxes']:
        print(f"  • {ctrl['name']}: {ctrl['width']}x{ctrl['height']}px")

    # Tabs
    print(f"\nTabs ({len(controls['tabs'])}):")
    for ctrl in controls['tabs']:
        print(f"  • {ctrl['text']}")

    # Subforms
    print(f"\nSubforms ({len(controls['subforms'])}):")
    for ctrl in controls['subforms']:
        src = ctrl['src'].split('/')[-1] if ctrl['src'] else 'N/A'
        print(f"  • {ctrl['id']}: {src} ({ctrl['width']}x{ctrl['height']}px)")

    # Rectangles
    print(f"\nRectangles/Dividers ({len(controls['rectangles'])}):")
    for ctrl in controls['rectangles'][:10]:
        print(f"  • {ctrl['className']}: {ctrl['width']}x{ctrl['height']}px")

    print("\n" + "="*80)

    # Speichere als JSON
    report_path = SCREENSHOTS_DIR / "html_controls_analysis.json"
    with open(report_path, 'w', encoding='utf-8') as f:
        json.dump(controls, f, indent=2, ensure_ascii=False)
    print(f"Analyse gespeichert: {report_path}")

if __name__ == "__main__":
    print("Starte HTML-Analyse...\n")

    # Screenshot
    screenshot_path = capture_html_screenshot()

    # Analysiere Controls
    controls = analyze_html_controls()

    # Ausgabe
    print_analysis(controls)

    print("\n✓ Analyse abgeschlossen!")
    print(f"\nDateien:")
    print(f"  Screenshot: {screenshot_path}")
    print(f"  Analyse:    {SCREENSHOTS_DIR / 'html_controls_analysis.json'}")

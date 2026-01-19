"""
Visueller Abgleich: Access vs HTML Formular
Erstellt Screenshots und vergleicht Vollständigkeit der Controls
"""

import sys
import io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

import win32com.client
import time
from PIL import ImageGrab
import pygetwindow as gw
from playwright.sync_api import sync_playwright
import json
from pathlib import Path

# Pfade
SCREENSHOTS_DIR = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\screenshots_test")
HTML_PATH = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\frm_va_Auftragstamm.html")
JSON_EXPORT_PATH = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\11_json_Export\000_Consys_Eport_11_25\30_forms\FRM_frm_va_Auftragstamm.json")
SPEC_PATH = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\05_Dokumentation\specs\frm_va_Auftragstamm.spec.json")

def capture_access_form():
    """Öffnet Access-Formular und erstellt Screenshot"""
    print("1. Öffne Access-Formular...")

    try:
        # Verbinde zu laufender Access-Instanz
        access = win32com.client.GetActiveObject("Access.Application")
        print(f"   ✓ Verbunden mit Access: {access.CurrentDb().Name}")

        # Öffne Formular
        access.DoCmd.OpenForm("frm_va_Auftragstamm")
        print("   ✓ Formular geöffnet")

        # Warte bis Formular geladen
        time.sleep(2)

        # Finde Access-Fenster
        windows = gw.getWindowsWithTitle("frm_va_Auftragstamm")
        if not windows:
            # Suche nach Hauptfenster
            windows = gw.getWindowsWithTitle("Microsoft Access")

        if windows:
            window = windows[0]
            window.activate()
            time.sleep(0.5)

            # Screenshot
            screenshot = ImageGrab.grab()
            screenshot_path = SCREENSHOTS_DIR / "access_frm_va_Auftragstamm.png"
            screenshot.save(screenshot_path)
            print(f"   ✓ Screenshot gespeichert: {screenshot_path}")

            return screenshot_path
        else:
            print("   ✗ Konnte Access-Fenster nicht finden")
            return None

    except Exception as e:
        print(f"   ✗ Fehler: {e}")
        return None

def capture_html_form():
    """Öffnet HTML-Formular und erstellt Screenshot"""
    print("\n2. Öffne HTML-Formular...")

    screenshot_path = SCREENSHOTS_DIR / "html_frm_va_Auftragstamm.png"

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        page = browser.new_page(viewport={'width': 1920, 'height': 1080})

        # Öffne HTML
        page.goto(f"file:///{HTML_PATH.as_posix()}")
        print("   ✓ HTML geladen")

        # Warte auf vollständiges Laden
        page.wait_for_load_state('networkidle')
        time.sleep(1)

        # Screenshot
        page.screenshot(path=str(screenshot_path), full_page=True)
        print(f"   ✓ Screenshot gespeichert: {screenshot_path}")

        browser.close()

    return screenshot_path

def analyze_access_controls():
    """Analysiert Access-Controls aus JSON"""
    print("\n3. Analysiere Access-Controls...")

    controls = {}

    # Lade FRM JSON
    if JSON_EXPORT_PATH.exists():
        with open(JSON_EXPORT_PATH, 'r', encoding='utf-8') as f:
            frm_data = json.load(f)

        # Analysiere Controls
        if 'controls' in frm_data:
            for ctrl_name, ctrl_data in frm_data['controls'].items():
                ctrl_type = ctrl_data.get('ControlType', 'Unknown')
                visible = ctrl_data.get('Visible', 'Wahr')

                # Nur sichtbare Controls
                if visible == 'Wahr':
                    controls[ctrl_name] = {
                        'type': ctrl_type,
                        'left': ctrl_data.get('Left', 0),
                        'top': ctrl_data.get('Top', 0),
                        'width': ctrl_data.get('Width', 0),
                        'height': ctrl_data.get('Height', 0)
                    }

    # Lade Spec JSON für Captions
    if SPEC_PATH.exists():
        with open(SPEC_PATH, 'r', encoding='utf-8') as f:
            spec_data = json.load(f)

        # Ergänze Captions
        for section in spec_data.get('sections', []):
            for ctrl in section.get('controls', []):
                ctrl_name = ctrl.get('name')
                if ctrl_name in controls:
                    controls[ctrl_name]['caption'] = ctrl.get('caption', '')

    print(f"   ✓ {len(controls)} sichtbare Controls gefunden")

    # Gruppiere nach Typ
    by_type = {}
    for ctrl_name, ctrl_data in controls.items():
        ctrl_type = ctrl_data['type']
        if ctrl_type not in by_type:
            by_type[ctrl_type] = []
        by_type[ctrl_type].append(ctrl_name)

    print("\n   Controls nach Typ:")
    for ctrl_type, ctrl_list in sorted(by_type.items()):
        print(f"   - {ctrl_type}: {len(ctrl_list)}")

    return controls

def analyze_html_controls():
    """Analysiert HTML-Controls aus DOM"""
    print("\n4. Analysiere HTML-Controls...")

    controls = {}

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        page.goto(f"file:///{HTML_PATH.as_posix()}")
        page.wait_for_load_state('networkidle')

        # Extrahiere alle Controls
        result = page.evaluate("""() => {
            const controls = [];

            // Alle Input-Felder
            document.querySelectorAll('input, textarea, select').forEach(el => {
                const rect = el.getBoundingClientRect();
                controls.push({
                    id: el.id || el.name || '',
                    type: el.tagName + (el.type ? ':' + el.type : ''),
                    left: rect.left,
                    top: rect.top,
                    width: rect.width,
                    height: rect.height,
                    visible: el.offsetParent !== null
                });
            });

            // Alle Labels
            document.querySelectorAll('label').forEach(el => {
                const rect = el.getBoundingClientRect();
                controls.push({
                    id: el.id || '',
                    type: 'LABEL',
                    caption: el.textContent.trim(),
                    left: rect.left,
                    top: rect.top,
                    width: rect.width,
                    height: rect.height,
                    visible: el.offsetParent !== null
                });
            });

            // Alle Buttons
            document.querySelectorAll('button').forEach(el => {
                const rect = el.getBoundingClientRect();
                controls.push({
                    id: el.id || '',
                    type: 'BUTTON',
                    caption: el.textContent.trim(),
                    left: rect.left,
                    top: rect.top,
                    width: rect.width,
                    height: rect.height,
                    visible: el.offsetParent !== null
                });
            });

            // Alle Tabs
            document.querySelectorAll('.tab-button, [role="tab"]').forEach(el => {
                const rect = el.getBoundingClientRect();
                controls.push({
                    id: el.id || '',
                    type: 'TAB',
                    caption: el.textContent.trim(),
                    left: rect.left,
                    top: rect.top,
                    width: rect.width,
                    height: rect.height,
                    visible: el.offsetParent !== null
                });
            });

            // Alle Iframes (Subforms)
            document.querySelectorAll('iframe').forEach(el => {
                const rect = el.getBoundingClientRect();
                controls.push({
                    id: el.id || '',
                    type: 'IFRAME',
                    src: el.src,
                    left: rect.left,
                    top: rect.top,
                    width: rect.width,
                    height: rect.height,
                    visible: el.offsetParent !== null
                });
            });

            return controls;
        }""")

        browser.close()

    # Konvertiere zu Dictionary
    for ctrl in result:
        if ctrl['visible'] and ctrl['id']:
            controls[ctrl['id']] = ctrl

    print(f"   ✓ {len(controls)} HTML-Controls gefunden")

    # Gruppiere nach Typ
    by_type = {}
    for ctrl_name, ctrl_data in controls.items():
        ctrl_type = ctrl_data['type']
        if ctrl_type not in by_type:
            by_type[ctrl_type] = []
        by_type[ctrl_type].append(ctrl_name)

    print("\n   Controls nach Typ:")
    for ctrl_type, ctrl_list in sorted(by_type.items()):
        print(f"   - {ctrl_type}: {len(ctrl_list)}")

    return controls

def compare_controls(access_controls, html_controls):
    """Vergleicht Access und HTML Controls"""
    print("\n5. Vergleiche Controls...\n")

    # Type-Mapping Access -> HTML
    TYPE_MAPPING = {
        '100': 'LABEL',           # Label
        '104': 'BUTTON',          # CommandButton
        '109': 'INPUT:text',      # TextBox
        '111': 'SELECT',          # ComboBox
        '112': 'IFRAME',          # SubForm
        '106': 'INPUT:checkbox',  # CheckBox
        '122': 'TAB',             # TabControl
    }

    report = {
        'total_access': len(access_controls),
        'total_html': len(html_controls),
        'missing': [],
        'position_diff': [],
        'size_diff': [],
        'extra_html': [],
    }

    # Prüfe jedes Access-Control
    for acc_name, acc_data in access_controls.items():
        acc_type = TYPE_MAPPING.get(str(acc_data['type']), acc_data['type'])

        # Suche in HTML
        found = False
        for html_name, html_data in html_controls.items():
            # Matching: Name oder Caption
            if (acc_name.lower() in html_name.lower() or
                html_name.lower() in acc_name.lower() or
                (acc_data.get('caption', '') and acc_data.get('caption', '') in html_data.get('caption', ''))):

                found = True

                # Prüfe Position (Twips -> Pixel)
                acc_left_px = acc_data['left'] / 15
                acc_top_px = acc_data['top'] / 15

                pos_diff_x = abs(acc_left_px - html_data['left'])
                pos_diff_y = abs(acc_top_px - html_data['top'])

                if pos_diff_x > 20 or pos_diff_y > 20:  # Toleranz 20px
                    report['position_diff'].append({
                        'name': acc_name,
                        'access_pos': (acc_left_px, acc_top_px),
                        'html_pos': (html_data['left'], html_data['top']),
                        'diff': (pos_diff_x, pos_diff_y)
                    })

                # Prüfe Größe
                acc_width_px = acc_data['width'] / 15
                acc_height_px = acc_data['height'] / 15

                size_diff_w = abs(acc_width_px - html_data['width'])
                size_diff_h = abs(acc_height_px - html_data['height'])

                if size_diff_w > 20 or size_diff_h > 20:  # Toleranz 20px
                    report['size_diff'].append({
                        'name': acc_name,
                        'access_size': (acc_width_px, acc_height_px),
                        'html_size': (html_data['width'], html_data['height']),
                        'diff': (size_diff_w, size_diff_h)
                    })

                break

        if not found:
            report['missing'].append({
                'name': acc_name,
                'type': acc_type,
                'caption': acc_data.get('caption', ''),
                'position': (acc_data['left'] / 15, acc_data['top'] / 15)
            })

    # Prüfe Extra-Controls in HTML
    access_names_lower = [n.lower() for n in access_controls.keys()]
    for html_name, html_data in html_controls.items():
        if not any(acc_name in html_name.lower() for acc_name in access_names_lower):
            report['extra_html'].append({
                'name': html_name,
                'type': html_data['type']
            })

    # Berechne Vollständigkeit
    matched = report['total_access'] - len(report['missing'])
    completeness = (matched / report['total_access'] * 100) if report['total_access'] > 0 else 0
    report['completeness'] = completeness

    return report

def print_report(report):
    """Gibt Bericht aus"""
    print("="*80)
    print("VERGLEICHSBERICHT: frm_va_Auftragstamm")
    print("="*80)

    print(f"\nZusammenfassung:")
    print(f"  Access-Controls (gesamt): {report['total_access']}")
    print(f"  HTML-Controls (gesamt):   {report['total_html']}")
    print(f"  Vollständigkeit:          {report['completeness']:.1f}%")

    print(f"\nFehlende Controls ({len(report['missing'])}):")
    if report['missing']:
        for ctrl in report['missing'][:20]:  # Top 20
            print(f"  ✗ {ctrl['name']} ({ctrl['type']})")
            if ctrl['caption']:
                print(f"    Caption: {ctrl['caption']}")
    else:
        print("  ✓ Alle Controls vorhanden!")

    print(f"\nPosition-Abweichungen ({len(report['position_diff'])}):")
    if report['position_diff']:
        for ctrl in report['position_diff'][:10]:  # Top 10
            print(f"  ⚠ {ctrl['name']}")
            print(f"    Access: {ctrl['access_pos']}, HTML: {ctrl['html_pos']}")
            print(f"    Diff: ({ctrl['diff'][0]:.1f}px, {ctrl['diff'][1]:.1f}px)")
    else:
        print("  ✓ Keine signifikanten Abweichungen!")

    print(f"\nGröße-Abweichungen ({len(report['size_diff'])}):")
    if report['size_diff']:
        for ctrl in report['size_diff'][:10]:  # Top 10
            print(f"  ⚠ {ctrl['name']}")
            print(f"    Access: {ctrl['access_size']}, HTML: {ctrl['html_size']}")
            print(f"    Diff: ({ctrl['diff'][0]:.1f}px, {ctrl['diff'][1]:.1f}px)")
    else:
        print("  ✓ Keine signifikanten Abweichungen!")

    if report['extra_html']:
        print(f"\nZusätzliche HTML-Controls ({len(report['extra_html'])}):")
        for ctrl in report['extra_html'][:10]:
            print(f"  ℹ {ctrl['name']} ({ctrl['type']})")

    print("\n" + "="*80)

    # Speichere Report
    report_path = SCREENSHOTS_DIR / "vergleichsbericht.json"
    with open(report_path, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
    print(f"Bericht gespeichert: {report_path}")

if __name__ == "__main__":
    print("Starte visuellen Abgleich...\n")

    # Screenshots erstellen
    access_screenshot = capture_access_form()
    html_screenshot = capture_html_form()

    # Controls analysieren
    access_controls = analyze_access_controls()
    html_controls = analyze_html_controls()

    # Vergleichen
    report = compare_controls(access_controls, html_controls)

    # Bericht ausgeben
    print_report(report)

    print("\n✓ Abgleich abgeschlossen!")
    print(f"\nScreenshots:")
    print(f"  Access: {SCREENSHOTS_DIR / 'access_frm_va_Auftragstamm.png'}")
    print(f"  HTML:   {SCREENSHOTS_DIR / 'html_frm_va_Auftragstamm.png'}")

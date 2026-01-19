"""
FINALER Playwright Test für frm_va_Auftragstamm.html
Alle Button-IDs und Tab-Selektoren korrigiert
"""

from playwright.sync_api import sync_playwright
import time
from datetime import datetime
import json

def test_auftragstamm_final():
    results = []

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False, slow_mo=300)
        context = browser.new_context(viewport={'width': 1600, 'height': 1000})
        page = context.new_page()

        console_logs = []
        page.on('console', lambda msg: console_logs.append(f"[{msg.type}] {msg.text}"))

        try:
            print("\n[INFO] Oeffne Formular...")
            page.goto('http://localhost:8080/forms/frm_va_Auftragstamm.html', wait_until='networkidle')
            time.sleep(2)

            # Screenshot initial
            page.screenshot(path="C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/final_initial.png")

            # NAVIGATION BUTTONS
            print("\n[TEST] Navigation Buttons...")
            for btn_id, name in [('btnFirst', 'Erste'), ('btnPrev', 'Zurueck'), ('btnNext', 'Vor'), ('btnLast', 'Letzte')]:
                btn = page.locator(f'#{btn_id}')
                status = 'PASS' if btn.is_visible() and not btn.is_disabled() else 'FAIL'
                results.append({'kategorie': 'Navigation', 'button': name, 'status': status, 'id': btn_id})
                if status == 'PASS':
                    btn.click()
                    time.sleep(0.3)

            # CRUD BUTTONS
            print("[TEST] CRUD Buttons...")
            for btn_id, name in [('btnNeuerAuftrag', 'Neu'), ('btnAuftragKopieren', 'Kopieren'), ('btnAuftragLoeschen', 'Loeschen')]:
                btn = page.locator(f'#{btn_id}')
                status = 'PASS' if btn.is_visible() and not btn.is_disabled() else 'FAIL'
                results.append({'kategorie': 'CRUD', 'button': name, 'status': status, 'id': btn_id})

            # EINSATZLISTE BUTTONS
            print("[TEST] Einsatzliste Buttons...")
            for btn_id, name in [
                ('btnEinsatzlisteBOS', 'Senden BOS'),
                ('btnEinsatzlisteSUB', 'Senden SUB'),
                ('btnEinsatzlisteSenden', 'Senden MA'),
                ('btnEinsatzlisteDrucken', 'Drucken'),
                ('btnNamensliste', 'Namensliste')
            ]:
                btn = page.locator(f'#{btn_id}')
                status = 'PASS' if btn.is_visible() and not btn.is_disabled() else 'FAIL'
                results.append({'kategorie': 'Einsatzliste', 'button': name, 'status': status, 'id': btn_id})

            # MITARBEITERAUSWAHL
            print("[TEST] Mitarbeiterauswahl...")
            btn = page.locator('#btnSchnellPlan')
            status = 'PASS' if btn.is_visible() and not btn.is_disabled() else 'FAIL'
            results.append({'kategorie': 'Mitarbeiterauswahl', 'button': 'Mitarbeiterauswahl', 'status': status, 'id': 'btnSchnellPlan'})

            # TABS - KORRIGIERTE SELEKTOREN
            print("[TEST] Tabs...")
            for data_tab, name in [
                ('tab-einsatzliste', 'Einsatzliste'),
                ('tab-antworten', 'Antworten'),
                ('tab-zusatzdateien', 'Zusatzdateien'),
                ('tab-rechnung', 'Rechnung'),
                ('tab-bemerkungen', 'Bemerkungen')
            ]:
                try:
                    tab = page.locator(f'button.tab-btn[data-tab="{data_tab}"]')
                    if tab.is_visible(timeout=1000):
                        tab.click()
                        time.sleep(0.5)

                        # Prüfe ob Tab-Content sichtbar wird
                        content_visible = page.locator(f'#{data_tab}').is_visible()

                        status = 'PASS' if content_visible else 'WARNING'
                        details = f'Tab klickbar, Content {"sichtbar" if content_visible else "nicht sichtbar"}'
                        results.append({'kategorie': 'Tabs', 'button': f'Tab {name}', 'status': status, 'details': details})

                        # Screenshot pro Tab
                        page.screenshot(path=f"C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/final_tab_{data_tab}.png")
                    else:
                        results.append({'kategorie': 'Tabs', 'button': f'Tab {name}', 'status': 'FAIL', 'details': 'Tab nicht sichtbar'})
                except Exception as e:
                    results.append({'kategorie': 'Tabs', 'button': f'Tab {name}', 'status': 'FAIL', 'details': str(e)[:50]})

            # ZUSÄTZLICHE BUTTONS
            print("[TEST] Zusaetzliche Buttons...")
            for btn_id, name in [
                ('btnClose', 'Schliessen'),
                ('btnDatumLeft', 'Datum <'),
                ('btnDatumRight', 'Datum >')
            ]:
                btn = page.locator(f'#{btn_id}')
                status = 'PASS' if btn.is_visible() else 'FAIL'
                results.append({'kategorie': 'Zusaetzlich', 'button': name, 'status': status, 'id': btn_id})

            # TAB-SPEZIFISCHE BUTTONS (wenn in Tab sichtbar)
            print("[TEST] Tab-spezifische Buttons...")

            # Einsatzliste-Tab Buttons
            page.locator('button.tab-btn[data-tab="tab-einsatzliste"]').click()
            time.sleep(0.5)

            for btn_id, name in [
                ('btnPlanKopie', 'Plan kopieren'),
                ('btnBWNNamen', 'BWN Namen'),
                ('btnBWNDruck', 'BWN drucken'),
                ('btnBWNSend', 'BWN senden'),
                ('btnSortieren', 'Sortieren'),
                ('btnAbwesenheiten', 'Abwesenheiten')
            ]:
                btn = page.locator(f'#{btn_id}')
                if btn.count() > 0:
                    status = 'PASS' if btn.is_visible() else 'FAIL'
                    results.append({'kategorie': 'Tab-Buttons (Einsatzliste)', 'button': name, 'status': status, 'id': btn_id})

            # Zusatzdateien-Tab Buttons
            page.locator('button.tab-btn[data-tab="tab-zusatzdateien"]').click()
            time.sleep(0.5)

            btn = page.locator('#btnNeuAttach')
            if btn.count() > 0:
                status = 'PASS' if btn.is_visible() else 'FAIL'
                results.append({'kategorie': 'Tab-Buttons (Zusatzdateien)', 'button': 'Neuer Attach', 'status': status, 'id': 'btnNeuAttach'})

            # Rechnung-Tab Buttons
            page.locator('button.tab-btn[data-tab="tab-rechnung"]').click()
            time.sleep(0.5)

            for btn_id, name in [
                ('btnPDFKopf', 'Rechnung PDF'),
                ('btnPDFPos', 'Berechnungsliste PDF'),
                ('btnLoad', 'Daten laden'),
                ('btnRchLex', 'Rechnung Lexware')
            ]:
                btn = page.locator(f'#{btn_id}')
                if btn.count() > 0:
                    status = 'PASS' if btn.is_visible() else 'FAIL'
                    results.append({'kategorie': 'Tab-Buttons (Rechnung)', 'button': name, 'status': status, 'id': btn_id})

            # Final Screenshot
            page.screenshot(path="C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/final_complete.png")

        finally:
            time.sleep(1)
            browser.close()

    # REPORT ERSTELLEN
    print("\n" + "="*80)
    print("FINALER BUTTON TEST REPORT - frm_va_Auftragstamm.html")
    print("="*80)

    total = len(results)
    passed = sum(1 for r in results if r['status'] == 'PASS')
    failed = sum(1 for r in results if r['status'] == 'FAIL')
    warning = sum(1 for r in results if r['status'] == 'WARNING')

    print(f"\nGesamt: {total} Tests")
    print(f"PASS: {passed} ({passed*100//total}%)")
    print(f"FAIL: {failed} ({failed*100//total if total > 0 else 0}%)")
    print(f"WARNING: {warning}")

    print("\n" + "-"*80)
    print("ERGEBNISSE NACH KATEGORIE:")
    print("-"*80)

    current_cat = None
    for r in results:
        cat = r.get('kategorie', 'Unknown')
        if cat != current_cat:
            current_cat = cat
            print(f"\n### {cat}")

        symbol = "[OK]" if r['status'] == 'PASS' else "[!!]" if r['status'] == 'FAIL' else "[WW]"
        button = r.get('button', 'Unknown')
        btn_id = r.get('id', '')
        details = r.get('details', '')

        line = f"{symbol} {button}"
        if btn_id:
            line += f" ({btn_id})"
        if details:
            line += f" - {details}"

        print(line)

    # JSON speichern
    json_file = "C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/final_report.json"
    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump({
            'timestamp': datetime.now().isoformat(),
            'summary': {'total': total, 'passed': passed, 'failed': failed, 'warning': warning},
            'results': results
        }, f, indent=2, ensure_ascii=False)

    print(f"\n\n[INFO] JSON-Report: {json_file}")
    print("="*80)

if __name__ == '__main__':
    test_auftragstamm_final()

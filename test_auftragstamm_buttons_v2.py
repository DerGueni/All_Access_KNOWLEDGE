"""
Playwright Test v2 für frm_va_Auftragstamm.html Button-Funktionalität
MIT KORRIGIERTEN BUTTON-IDs
"""

from playwright.sync_api import sync_playwright, TimeoutError as PlaywrightTimeoutError
import time
from datetime import datetime
import json

class ButtonTestReport:
    def __init__(self):
        self.results = []
        self.screenshots = []

    def add_result(self, category, button_name, status, details):
        self.results.append({
            'category': category,
            'button': button_name,
            'status': status,
            'details': details,
            'timestamp': datetime.now().isoformat()
        })

    def print_report(self):
        print("\n" + "="*80)
        print("BUTTON TEST REPORT v2 - frm_va_Auftragstamm.html (KORRIGIERTE IDs)")
        print("="*80)
        print(f"\nTest durchgefuehrt: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"Gesamt Tests: {len(self.results)}")

        passed = sum(1 for r in self.results if r['status'] == 'PASS')
        failed = sum(1 for r in self.results if r['status'] == 'FAIL')
        warning = sum(1 for r in self.results if r['status'] == 'WARNING')

        print(f"PASS: {passed} | FAIL: {failed} | WARNING: {warning}")
        print("\n" + "-"*80)

        current_category = None
        for result in self.results:
            if result['category'] != current_category:
                current_category = result['category']
                print(f"\n### {current_category} ###")

            status_symbol = "[OK]" if result['status'] == "PASS" else "[!!]" if result['status'] == "FAIL" else "[WW]"
            print(f"{status_symbol} [{result['status']}] {result['button']}")
            print(f"  -> {result['details']}")

        print("\n" + "="*80)

        if self.screenshots:
            print("\nScreenshots erstellt:")
            for screenshot in self.screenshots:
                print(f"  - {screenshot}")

def test_auftragstamm_buttons_v2():
    report = ButtonTestReport()

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False, slow_mo=300)
        context = browser.new_context(viewport={'width': 1600, 'height': 1000})
        page = context.new_page()

        console_logs = []
        page.on('console', lambda msg: console_logs.append(f"[{msg.type}] {msg.text}"))
        page.on('pageerror', lambda err: console_logs.append(f"[ERROR] {err}"))

        try:
            print("\n[INFO] Oeffne Formular: http://localhost:8080/forms/frm_va_Auftragstamm.html")
            page.goto('http://localhost:8080/forms/frm_va_Auftragstamm.html', wait_until='networkidle')
            time.sleep(2)

            screenshot_path = f"C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/test_v2_initial.png"
            page.screenshot(path=screenshot_path)
            report.screenshots.append(screenshot_path)

            # ========================================================================
            # KATEGORIE 1: NAVIGATION BUTTONS (KORRIGIERTE IDs)
            # ========================================================================
            print("\n[TEST] Kategorie: Navigation (korrigierte IDs)")

            nav_buttons = [
                ('btnFirst', 'Erste Datensatz (btnFirst)'),
                ('btnPrev', 'Vorherige Datensatz (btnPrev)'),
                ('btnNext', 'Naechste Datensatz (btnNext)'),
                ('btnLast', 'Letzte Datensatz (btnLast)')
            ]

            for btn_id, btn_name in nav_buttons:
                try:
                    button = page.locator(f'#{btn_id}')
                    if button.is_visible(timeout=1000):
                        is_enabled = not button.is_disabled()
                        console_logs.clear()

                        if is_enabled:
                            button.click()
                            time.sleep(0.5)

                            has_logs = len(console_logs) > 0
                            report.add_result('Navigation', btn_name, 'PASS',
                                f'Button sichtbar & klickbar | Console-Logs: {len(console_logs)}')
                        else:
                            report.add_result('Navigation', btn_name, 'WARNING', 'Button disabled')
                    else:
                        report.add_result('Navigation', btn_name, 'FAIL', 'Button nicht sichtbar')
                except Exception as e:
                    report.add_result('Navigation', btn_name, 'FAIL', f'Error: {str(e)[:80]}')

            screenshot_path = f"C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/test_v2_navigation.png"
            page.screenshot(path=screenshot_path)
            report.screenshots.append(screenshot_path)

            # ========================================================================
            # KATEGORIE 2: CRUD BUTTONS
            # ========================================================================
            print("\n[TEST] Kategorie: CRUD")

            crud_buttons = [
                ('btnNeuerAuftrag', 'Neuer Auftrag'),
                ('btnAuftragKopieren', 'Auftrag kopieren'),
                ('btnAuftragLoeschen', 'Auftrag loeschen')
            ]

            for btn_id, btn_name in crud_buttons:
                try:
                    button = page.locator(f'#{btn_id}')
                    if button.is_visible(timeout=1000):
                        is_enabled = not button.is_disabled()
                        console_logs.clear()

                        if is_enabled:
                            button.click()
                            time.sleep(1)

                            # Prüfe auf Modal/Dialog/Alert
                            modal_visible = page.locator('.modal, [role="dialog"], .dialog, .swal2-container').count() > 0

                            details = f'Button klickbar'
                            if modal_visible:
                                details += ' | Modal/Dialog geoeffnet'
                            if console_logs:
                                details += f' | Console: {len(console_logs)} Logs'

                            report.add_result('CRUD', btn_name, 'PASS', details)

                            # Modal schließen
                            if modal_visible:
                                try:
                                    # Verschiedene Close-Strategien
                                    close_selectors = [
                                        '.swal2-cancel',
                                        '.swal2-close',
                                        'button:has-text("Abbrechen")',
                                        'button:has-text("Schliessen")',
                                        '[aria-label="Close"]'
                                    ]
                                    for selector in close_selectors:
                                        if page.locator(selector).count() > 0:
                                            page.locator(selector).first.click()
                                            time.sleep(0.5)
                                            break
                                except:
                                    page.keyboard.press('Escape')
                                    time.sleep(0.5)
                        else:
                            report.add_result('CRUD', btn_name, 'WARNING', 'Button disabled')
                    else:
                        report.add_result('CRUD', btn_name, 'FAIL', 'Button nicht sichtbar')
                except Exception as e:
                    report.add_result('CRUD', btn_name, 'FAIL', f'Error: {str(e)[:80]}')

            screenshot_path = f"C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/test_v2_crud.png"
            page.screenshot(path=screenshot_path)
            report.screenshots.append(screenshot_path)

            # ========================================================================
            # KATEGORIE 3: EINSATZLISTE BUTTONS (KORRIGIERTE IDs)
            # ========================================================================
            print("\n[TEST] Kategorie: Einsatzliste (korrigierte IDs)")

            einsatz_buttons = [
                ('btnEinsatzlisteBOS', 'Einsatzliste senden BOS (btnEinsatzlisteBOS)'),
                ('btnEinsatzlisteSUB', 'Einsatzliste senden SUB (btnEinsatzlisteSUB)'),
                ('btnEinsatzlisteSenden', 'Einsatzliste senden MA (btnEinsatzlisteSenden)'),
                ('btnEinsatzlisteDrucken', 'Einsatzliste drucken'),
                ('btnNamensliste', 'Namensliste ESS')
            ]

            for btn_id, btn_name in einsatz_buttons:
                try:
                    button = page.locator(f'#{btn_id}')
                    if button.is_visible(timeout=1000):
                        is_enabled = not button.is_disabled()
                        console_logs.clear()

                        if is_enabled:
                            button.click()
                            time.sleep(1)

                            modal_visible = page.locator('.modal, [role="dialog"], .dialog, .swal2-container').count() > 0

                            details = f'Button klickbar'
                            if modal_visible:
                                details += ' | Dialog geoeffnet'
                            if console_logs:
                                details += f' | Console: {len(console_logs)} Logs'

                            report.add_result('Einsatzliste', btn_name, 'PASS', details)

                            # Dialog schließen
                            if modal_visible:
                                try:
                                    page.keyboard.press('Escape')
                                    time.sleep(0.5)
                                except:
                                    pass
                        else:
                            report.add_result('Einsatzliste', btn_name, 'WARNING', 'Button disabled')
                    else:
                        report.add_result('Einsatzliste', btn_name, 'FAIL', 'Button nicht sichtbar')
                except Exception as e:
                    report.add_result('Einsatzliste', btn_name, 'FAIL', f'Error: {str(e)[:80]}')

            screenshot_path = f"C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/test_v2_einsatzliste.png"
            page.screenshot(path=screenshot_path)
            report.screenshots.append(screenshot_path)

            # ========================================================================
            # KATEGORIE 4: MITARBEITERAUSWAHL (KORRIGIERTE ID)
            # ========================================================================
            print("\n[TEST] Kategorie: Mitarbeiterauswahl (korrigierte ID)")

            try:
                button = page.locator('#btnSchnellPlan')
                if button.is_visible(timeout=1000):
                    is_enabled = not button.is_disabled()
                    console_logs.clear()

                    if is_enabled:
                        button.click()
                        time.sleep(2)

                        # Prüfe auf verschiedene UI-Änderungen
                        modal_visible = page.locator('.modal, [role="dialog"], iframe').count() > 0

                        details = f'Button klickbar (btnSchnellPlan)'
                        if modal_visible:
                            details += ' | Modal/Subform sichtbar'
                        if console_logs:
                            details += f' | Console: {len(console_logs)} Logs'

                        report.add_result('Mitarbeiterauswahl', 'Mitarbeiterauswahl oeffnen', 'PASS', details)

                        # Schließen
                        if modal_visible:
                            try:
                                page.keyboard.press('Escape')
                                time.sleep(0.5)
                            except:
                                pass
                    else:
                        report.add_result('Mitarbeiterauswahl', 'Mitarbeiterauswahl oeffnen', 'WARNING', 'Button disabled')
                else:
                    report.add_result('Mitarbeiterauswahl', 'Mitarbeiterauswahl oeffnen', 'FAIL', 'Button nicht sichtbar')
            except Exception as e:
                report.add_result('Mitarbeiterauswahl', 'Mitarbeiterauswahl oeffnen', 'FAIL', f'Error: {str(e)[:80]}')

            # ========================================================================
            # KATEGORIE 5: TAB NAVIGATION (FLEXIBLE SELEKTOREN)
            # ========================================================================
            print("\n[TEST] Kategorie: Tabs (flexible Selektoren)")

            # Versuche verschiedene Tab-Selektoren
            tab_configs = [
                ('Einsatzliste', ['a:has-text("Einsatzliste")', '.tab-item:has-text("Einsatzliste")', '[data-tab="einsatzliste"]']),
                ('Antworten ausstehend', ['a:has-text("Antworten")', '.tab-item:has-text("Antworten")', '[data-tab="antworten"]']),
                ('Zusatzdateien', ['a:has-text("Zusatzdateien")', '.tab-item:has-text("Zusatzdateien")', '[data-tab="zusatzdateien"]']),
                ('Rechnung', ['a:has-text("Rechnung")', '.tab-item:has-text("Rechnung")', '[data-tab="rechnung"]']),
                ('Bemerkungen', ['a:has-text("Bemerkungen")', '.tab-item:has-text("Bemerkungen")', '[data-tab="bemerkungen"]'])
            ]

            for tab_name, selectors in tab_configs:
                found = False
                for selector in selectors:
                    try:
                        tab = page.locator(selector).first
                        if tab.is_visible(timeout=500):
                            console_logs.clear()
                            tab.click()
                            time.sleep(0.5)

                            details = f'Tab gefunden mit Selector: {selector}'
                            if console_logs:
                                details += f' | Console: {len(console_logs)} Logs'

                            report.add_result('Tabs', f'Tab: {tab_name}', 'PASS', details)

                            # Screenshot
                            tab_key = tab_name.lower().replace(' ', '_')
                            screenshot_path = f"C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/test_v2_tab_{tab_key}.png"
                            page.screenshot(path=screenshot_path)
                            report.screenshots.append(screenshot_path)

                            found = True
                            break
                    except:
                        continue

                if not found:
                    report.add_result('Tabs', f'Tab: {tab_name}', 'FAIL',
                        f'Tab nicht gefunden mit Selektoren: {selectors}')

            # ========================================================================
            # KATEGORIE 6: ZUSÄTZLICHE HEADER-BUTTONS
            # ========================================================================
            print("\n[TEST] Kategorie: Zusaetzliche Header-Buttons")

            additional_buttons = [
                ('btnClose', 'Schliessen-Button'),
                ('btnDatumLeft', 'Datum zurueck'),
                ('btnDatumRight', 'Datum vor')
            ]

            for btn_id, btn_name in additional_buttons:
                try:
                    button = page.locator(f'#{btn_id}')
                    if button.is_visible(timeout=1000):
                        is_enabled = not button.is_disabled()

                        if is_enabled:
                            report.add_result('Zusaetzliche Buttons', btn_name, 'PASS',
                                f'Button sichtbar & enabled ({btn_id})')
                        else:
                            report.add_result('Zusaetzliche Buttons', btn_name, 'WARNING', 'Button disabled')
                    else:
                        report.add_result('Zusaetzliche Buttons', btn_name, 'FAIL', 'Button nicht sichtbar')
                except Exception as e:
                    report.add_result('Zusaetzliche Buttons', btn_name, 'FAIL', f'Error: {str(e)[:80]}')

            # ========================================================================
            # CONSOLE LOGS SPEICHERN
            # ========================================================================
            if console_logs:
                log_file = "C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/test_v2_console.log"
                with open(log_file, 'w', encoding='utf-8') as f:
                    f.write("CONSOLE LOGS - frm_va_Auftragstamm.html Button Tests v2\n")
                    f.write("="*80 + "\n\n")
                    for log in console_logs:
                        f.write(log + "\n")
                print(f"[INFO] Console-Logs gespeichert: {log_file}")

            # Final Screenshot
            screenshot_path = f"C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/test_v2_final.png"
            page.screenshot(path=screenshot_path)
            report.screenshots.append(screenshot_path)

        except Exception as e:
            print(f"\n[ERROR] Test abgebrochen: {str(e)}")
            report.add_result('System', 'Test Execution', 'FAIL', f'Fatal Error: {str(e)}')

        finally:
            print("\n[INFO] Schliesse Browser...")
            time.sleep(2)
            browser.close()

    # Report ausgeben
    report.print_report()

    # Report als JSON speichern
    report_file = "C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/test_v2_report.json"
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(report.results, f, indent=2, ensure_ascii=False)
    print(f"\n[INFO] JSON-Report gespeichert: {report_file}")

    # Summary-Report als Markdown
    md_file = "C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/test_v2_summary.md"
    with open(md_file, 'w', encoding='utf-8') as f:
        f.write("# Button Test v2 - Summary\n\n")
        f.write(f"**Test Zeit:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")

        passed = sum(1 for r in report.results if r['status'] == 'PASS')
        failed = sum(1 for r in report.results if r['status'] == 'FAIL')
        warning = sum(1 for r in report.results if r['status'] == 'WARNING')

        f.write(f"**Gesamt:** {len(report.results)} Tests\n")
        f.write(f"- PASS: {passed}\n")
        f.write(f"- FAIL: {failed}\n")
        f.write(f"- WARNING: {warning}\n\n")

        f.write("## Ergebnisse nach Kategorie\n\n")
        current_cat = None
        for r in report.results:
            if r['category'] != current_cat:
                current_cat = r['category']
                f.write(f"\n### {current_cat}\n\n")

            status_icon = ":white_check_mark:" if r['status'] == "PASS" else ":x:" if r['status'] == "FAIL" else ":warning:"
            f.write(f"{status_icon} **{r['button']}** - {r['details']}\n")

    print(f"[INFO] Markdown-Summary gespeichert: {md_file}")

if __name__ == '__main__':
    print("="*80)
    print("PLAYWRIGHT BUTTON TEST v2 - frm_va_Auftragstamm.html")
    print("MIT KORRIGIERTEN BUTTON-IDs")
    print("="*80)
    print("\nStarte Test...\n")

    test_auftragstamm_buttons_v2()

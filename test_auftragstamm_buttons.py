"""
Playwright Test für frm_va_Auftragstamm.html Button-Funktionalität
Testet alle Buttons systematisch und erstellt einen detaillierten Report
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
        print("BUTTON TEST REPORT - frm_va_Auftragstamm.html")
        print("="*80)
        print(f"\nTest durchgeführt: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
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

def test_auftragstamm_buttons():
    report = ButtonTestReport()

    with sync_playwright() as p:
        # Browser starten (headless=False für visuelle Überwachung)
        browser = p.chromium.launch(headless=False, slow_mo=500)
        context = browser.new_context(viewport={'width': 1600, 'height': 1000})
        page = context.new_page()

        # Console-Logs sammeln
        console_logs = []
        page.on('console', lambda msg: console_logs.append(f"[{msg.type}] {msg.text}"))

        # Fehler sammeln
        page.on('pageerror', lambda err: print(f"PAGE ERROR: {err}"))

        try:
            print("\n[INFO] Öffne Formular: http://localhost:8080/forms/frm_va_Auftragstamm.html")
            page.goto('http://localhost:8080/forms/frm_va_Auftragstamm.html', wait_until='networkidle')
            time.sleep(2)

            # Initial Screenshot
            screenshot_path = f"C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/test_auftragstamm_initial.png"
            page.screenshot(path=screenshot_path)
            report.screenshots.append(screenshot_path)
            print(f"[INFO] Screenshot gespeichert: {screenshot_path}")

            # ========================================================================
            # KATEGORIE 1: NAVIGATION BUTTONS
            # ========================================================================
            print("\n[TEST] Kategorie: Navigation")

            nav_buttons = [
                ('btnErsterDatensatz', 'Erste Datensatz'),
                ('btnVorherigerDatensatz', 'Vorherige Datensatz'),
                ('btnNaechsterDatensatz', 'Nächste Datensatz'),
                ('btnLetzterDatensatz', 'Letzte Datensatz')
            ]

            for btn_id, btn_name in nav_buttons:
                try:
                    button = page.locator(f'#{btn_id}')
                    if button.is_visible(timeout=1000):
                        is_enabled = not button.is_disabled()
                        if is_enabled:
                            console_logs.clear()
                            button.click()
                            time.sleep(0.5)

                            # Prüfe ob API-Call oder UI-Änderung
                            relevant_logs = [log for log in console_logs if btn_id in log or 'Navigation' in log or 'Datensatz' in log]

                            report.add_result(
                                'Navigation',
                                btn_name,
                                'PASS',
                                f'Button klickbar, Logs: {len(relevant_logs)} Einträge'
                            )
                        else:
                            report.add_result('Navigation', btn_name, 'WARNING', 'Button disabled')
                    else:
                        report.add_result('Navigation', btn_name, 'FAIL', 'Button nicht sichtbar')
                except Exception as e:
                    report.add_result('Navigation', btn_name, 'FAIL', f'Error: {str(e)[:100]}')

            # Screenshot nach Navigation-Tests
            screenshot_path = f"C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/test_auftragstamm_navigation.png"
            page.screenshot(path=screenshot_path)
            report.screenshots.append(screenshot_path)

            # ========================================================================
            # KATEGORIE 2: CRUD BUTTONS
            # ========================================================================
            print("\n[TEST] Kategorie: CRUD")

            crud_buttons = [
                ('btnNeuerAuftrag', 'Neuer Auftrag'),
                ('btnAuftragKopieren', 'Auftrag kopieren'),
                ('btnAuftragLoeschen', 'Auftrag löschen')
            ]

            for btn_id, btn_name in crud_buttons:
                try:
                    button = page.locator(f'#{btn_id}')
                    if button.is_visible(timeout=1000):
                        is_enabled = not button.is_disabled()
                        if is_enabled:
                            console_logs.clear()
                            button.click()
                            time.sleep(1)

                            # Prüfe auf Modal/Dialog
                            modal_visible = page.locator('.modal, [role="dialog"], .dialog').count() > 0

                            details = f'Button klickbar'
                            if modal_visible:
                                details += ', Modal/Dialog geöffnet'
                            if console_logs:
                                details += f', {len(console_logs)} Console-Logs'

                            report.add_result('CRUD', btn_name, 'PASS', details)

                            # Modal schließen falls vorhanden
                            if modal_visible:
                                try:
                                    close_btn = page.locator('.modal-close, [aria-label="Close"], button:has-text("Abbrechen")').first
                                    if close_btn.is_visible(timeout=500):
                                        close_btn.click()
                                        time.sleep(0.3)
                                except:
                                    pass
                        else:
                            report.add_result('CRUD', btn_name, 'WARNING', 'Button disabled')
                    else:
                        report.add_result('CRUD', btn_name, 'FAIL', 'Button nicht sichtbar')
                except Exception as e:
                    report.add_result('CRUD', btn_name, 'FAIL', f'Error: {str(e)[:100]}')

            # Screenshot nach CRUD-Tests
            screenshot_path = f"C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/test_auftragstamm_crud.png"
            page.screenshot(path=screenshot_path)
            report.screenshots.append(screenshot_path)

            # ========================================================================
            # KATEGORIE 3: EINSATZLISTE BUTTONS
            # ========================================================================
            print("\n[TEST] Kategorie: Einsatzliste")

            einsatz_buttons = [
                ('btnEinsatzlisteSendenBOS', 'Einsatzliste senden BOS'),
                ('btnEinsatzlisteSendenSUB', 'Einsatzliste senden SUB'),
                ('btnEinsatzlisteSendenMA', 'Einsatzliste senden MA'),
                ('btnEinsatzlisteDrucken', 'Einsatzliste drucken')
            ]

            for btn_id, btn_name in einsatz_buttons:
                try:
                    button = page.locator(f'#{btn_id}')
                    if button.is_visible(timeout=1000):
                        is_enabled = not button.is_disabled()
                        if is_enabled:
                            console_logs.clear()
                            button.click()
                            time.sleep(1)

                            # Prüfe auf Modal/Dialog/Alert
                            modal_visible = page.locator('.modal, [role="dialog"], .dialog, .alert').count() > 0

                            details = f'Button klickbar'
                            if modal_visible:
                                details += ', Dialog geöffnet'
                            if console_logs:
                                details += f', {len(console_logs)} Console-Logs'

                            report.add_result('Einsatzliste', btn_name, 'PASS', details)

                            # Dialog schließen
                            if modal_visible:
                                try:
                                    close_btn = page.locator('.modal-close, [aria-label="Close"], button:has-text("Abbrechen"), button:has-text("Schließen")').first
                                    if close_btn.is_visible(timeout=500):
                                        close_btn.click()
                                        time.sleep(0.3)
                                except:
                                    page.keyboard.press('Escape')
                                    time.sleep(0.3)
                        else:
                            report.add_result('Einsatzliste', btn_name, 'WARNING', 'Button disabled')
                    else:
                        report.add_result('Einsatzliste', btn_name, 'FAIL', 'Button nicht sichtbar')
                except Exception as e:
                    report.add_result('Einsatzliste', btn_name, 'FAIL', f'Error: {str(e)[:100]}')

            # Screenshot nach Einsatzliste-Tests
            screenshot_path = f"C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/test_auftragstamm_einsatzliste.png"
            page.screenshot(path=screenshot_path)
            report.screenshots.append(screenshot_path)

            # ========================================================================
            # KATEGORIE 4: MITARBEITERAUSWAHL
            # ========================================================================
            print("\n[TEST] Kategorie: Mitarbeiterauswahl")

            try:
                button = page.locator('#btnMitarbeiterauswahl')
                if button.is_visible(timeout=1000):
                    is_enabled = not button.is_disabled()
                    if is_enabled:
                        console_logs.clear()
                        button.click()
                        time.sleep(1)

                        # Prüfe auf Subform/Modal
                        subform_visible = page.locator('iframe, .subform, [role="dialog"]').count() > 0

                        details = f'Button klickbar'
                        if subform_visible:
                            details += ', Subform/Dialog geöffnet'
                        if console_logs:
                            details += f', {len(console_logs)} Console-Logs'

                        report.add_result('Mitarbeiterauswahl', 'Mitarbeiterauswahl öffnen', 'PASS', details)

                        # Schließen
                        if subform_visible:
                            try:
                                close_btn = page.locator('.modal-close, [aria-label="Close"], button:has-text("Schließen")').first
                                if close_btn.is_visible(timeout=500):
                                    close_btn.click()
                                    time.sleep(0.3)
                            except:
                                page.keyboard.press('Escape')
                                time.sleep(0.3)
                    else:
                        report.add_result('Mitarbeiterauswahl', 'Mitarbeiterauswahl öffnen', 'WARNING', 'Button disabled')
                else:
                    report.add_result('Mitarbeiterauswahl', 'Mitarbeiterauswahl öffnen', 'FAIL', 'Button nicht sichtbar')
            except Exception as e:
                report.add_result('Mitarbeiterauswahl', 'Mitarbeiterauswahl öffnen', 'FAIL', f'Error: {str(e)[:100]}')

            # ========================================================================
            # KATEGORIE 5: TAB NAVIGATION
            # ========================================================================
            print("\n[TEST] Kategorie: Tabs")

            tabs = [
                ('#tabEinsatzliste, [data-tab="einsatzliste"], a:has-text("Einsatzliste")', 'Tab: Einsatzliste'),
                ('#tabAntworten, [data-tab="antworten"], a:has-text("Antworten")', 'Tab: Antworten ausstehend'),
                ('#tabZusatzdateien, [data-tab="zusatzdateien"], a:has-text("Zusatzdateien")', 'Tab: Zusatzdateien'),
                ('#tabRechnung, [data-tab="rechnung"], a:has-text("Rechnung")', 'Tab: Rechnung'),
                ('#tabBemerkungen, [data-tab="bemerkungen"], a:has-text("Bemerkungen")', 'Tab: Bemerkungen')
            ]

            for tab_selector, tab_name in tabs:
                try:
                    tab = page.locator(tab_selector).first
                    if tab.is_visible(timeout=1000):
                        console_logs.clear()
                        tab.click()
                        time.sleep(0.5)

                        # Prüfe ob Tab-Content sichtbar wird
                        is_active = tab.evaluate('el => el.classList.contains("active") || el.closest(".active") !== null')

                        details = f'Tab klickbar'
                        if is_active:
                            details += ', Tab aktiv'
                        if console_logs:
                            details += f', {len(console_logs)} Console-Logs'

                        report.add_result('Tabs', tab_name, 'PASS', details)

                        # Screenshot von jedem Tab
                        tab_key = tab_name.lower().replace(' ', '_').replace(':', '')
                        screenshot_path = f"C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/test_auftragstamm_{tab_key}.png"
                        page.screenshot(path=screenshot_path)
                        report.screenshots.append(screenshot_path)
                    else:
                        report.add_result('Tabs', tab_name, 'FAIL', 'Tab nicht sichtbar')
                except Exception as e:
                    report.add_result('Tabs', tab_name, 'FAIL', f'Error: {str(e)[:100]}')

            # ========================================================================
            # FINALE CONSOLE LOGS ANALYSE
            # ========================================================================
            print("\n[INFO] Sammle finale Console-Logs...")
            time.sleep(1)

            if console_logs:
                log_file = "C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/test_auftragstamm_console.log"
                with open(log_file, 'w', encoding='utf-8') as f:
                    f.write("CONSOLE LOGS - frm_va_Auftragstamm.html Button Tests\n")
                    f.write("="*80 + "\n\n")
                    for log in console_logs:
                        f.write(log + "\n")
                print(f"[INFO] Console-Logs gespeichert: {log_file}")

            # Final Screenshot
            screenshot_path = f"C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/test_auftragstamm_final.png"
            page.screenshot(path=screenshot_path)
            report.screenshots.append(screenshot_path)

        except Exception as e:
            print(f"\n[ERROR] Test abgebrochen: {str(e)}")
            report.add_result('System', 'Test Execution', 'FAIL', f'Fatal Error: {str(e)}')

        finally:
            print("\n[INFO] Schließe Browser...")
            time.sleep(2)
            browser.close()

    # Report ausgeben
    report.print_report()

    # Report als JSON speichern
    report_file = "C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/artifacts/test_auftragstamm_report.json"
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(report.results, f, indent=2, ensure_ascii=False)
    print(f"\n[INFO] JSON-Report gespeichert: {report_file}")

if __name__ == '__main__':
    print("="*80)
    print("PLAYWRIGHT BUTTON TEST - frm_va_Auftragstamm.html")
    print("="*80)
    print("\nVoraussetzungen:")
    print("  1. Server läuft auf http://localhost:8080")
    print("  2. Playwright installiert: pip install playwright && playwright install")
    print("\nStarte Test...\n")

    test_auftragstamm_buttons()

"""
Browser-Test: Öffnet Auftragstamm und macht Screenshot
"""
import time
import os

try:
    from playwright.sync_api import sync_playwright
    PLAYWRIGHT_OK = True
except ImportError:
    PLAYWRIGHT_OK = False
    print("Playwright nicht installiert. Installiere mit: pip install playwright && playwright install chromium")

if PLAYWRIGHT_OK:
    screenshot_path = os.path.join(os.path.dirname(__file__), "screenshot_auftragstamm.png")

    with sync_playwright() as p:
        print("Starte Browser...")
        browser = p.chromium.launch(headless=False)
        page = browser.new_page(viewport={"width": 1600, "height": 900})

        print("Lade Auftragstamm...")
        page.goto("http://localhost:8080/frm_va_Auftragstamm.html")

        # Warte auf Daten-Laden
        print("Warte auf Daten...")
        time.sleep(5)

        # Prüfe Console-Fehler
        console_messages = []
        page.on("console", lambda msg: console_messages.append(f"{msg.type}: {msg.text}"))

        # Warte nochmal
        time.sleep(2)

        # Screenshot machen
        print(f"Mache Screenshot: {screenshot_path}")
        page.screenshot(path=screenshot_path)

        # Zeige Console-Ausgaben
        if console_messages:
            print("\n=== Browser Console ===")
            for msg in console_messages[-20:]:
                print(msg)

        # Prüfe ob Aufträge geladen wurden
        try:
            rows = page.query_selector_all("#auftraegeBody tr")
            print(f"\n=== Ergebnis ===")
            print(f"Aufträge in Tabelle: {len(rows)}")
            if len(rows) > 0:
                print("ERFOLG: Aufträge wurden geladen!")
            else:
                print("FEHLER: Keine Aufträge in Tabelle")
        except Exception as e:
            print(f"Fehler beim Prüfen: {e}")

        print("\nBrowser bleibt 10 Sekunden offen...")
        time.sleep(10)

        browser.close()
        print(f"\nScreenshot gespeichert: {screenshot_path}")

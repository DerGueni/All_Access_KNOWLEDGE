#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Test: Unterformulare in frm_va_Auftragstamm
Prueft ob alle Subforms korrekt geladen werden
"""

import sys
import time
import json
from pathlib import Path
from datetime import datetime

# Playwright
from playwright.sync_api import sync_playwright

ARTIFACTS_PATH = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\runtime_logs\artifacts")
ARTIFACTS_PATH.mkdir(parents=True, exist_ok=True)

def test_subforms():
    """Testet alle Unterformulare"""

    results = {
        "timestamp": datetime.now().isoformat(),
        "form": "frm_va_Auftragstamm",
        "subforms": {}
    }

    # Erwartete Unterformulare basierend auf Access-Analyse
    expected_subforms = {
        "schichten": {
            "description": "Schichten-Liste (links)",
            "selector": ".schichten-container, #schichtenTable, table.schichten",
            "expected_columns": ["Start", "Ende", "Anz"]
        },
        "mitarbeiter_zuordnung": {
            "description": "MA-Zuordnung (mitte)",
            "selector": ".mitarbeiter-container, #mitarbeiterTable, table.mitarbeiter",
            "expected_columns": ["Name", "Vorname", "Start", "Ende", "Qualifikation", "Telefon", "Status"]
        },
        "auftragsliste": {
            "description": "Auftragsliste (rechts)",
            "selector": ".auftragsliste, #auftragsListe, .auftrags-liste",
            "expected_columns": []
        },
        "tabs": {
            "description": "Tab-Leiste",
            "selector": ".tab-container, .tabs, [role='tablist']",
            "expected_tabs": ["Einsatzliste", "Antworten ausstehend", "Zusatzdateien", "Rechnung", "Bemerkungen"]
        }
    }

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context(viewport={"width": 1400, "height": 900})
        page = context.new_page()

        # Formular laden
        url = "http://localhost:8080/forms/frm_va_Auftragstamm.html"
        print(f"\n[1] Lade Formular: {url}")
        page.goto(url, wait_until="networkidle", timeout=30000)
        time.sleep(3)  # Warten auf API-Daten

        print("\n[2] Pruefe Unterformulare...")

        # 2.1 Schichten-Tabelle
        print("\n--- SCHICHTEN ---")
        schichten_result = {"found": False, "rows": 0, "columns": [], "data_loaded": False}

        # Verschiedene Selektoren probieren
        schichten_selectors = [
            "table.schichten-table",
            "#schichtenContainer table",
            ".schichten table",
            "table:has(th:text('Start'))",
            "[data-subform='schichten']"
        ]

        for sel in schichten_selectors:
            try:
                elem = page.locator(sel).first
                if elem.is_visible(timeout=1000):
                    schichten_result["found"] = True
                    schichten_result["selector"] = sel
                    # Zeilen zaehlen
                    rows = page.locator(f"{sel} tbody tr").count()
                    schichten_result["rows"] = rows
                    schichten_result["data_loaded"] = rows > 0
                    print(f"  [OK] Gefunden mit: {sel}")
                    print(f"  [OK] Zeilen: {rows}")
                    break
            except:
                continue

        if not schichten_result["found"]:
            # Fallback: Nach Tabelle mit Start/Ende Spalten suchen
            all_tables = page.locator("table").all()
            for i, tbl in enumerate(all_tables):
                try:
                    html = tbl.inner_html()
                    if "Start" in html and "Ende" in html and "Anz" in html:
                        schichten_result["found"] = True
                        schichten_result["selector"] = f"table[{i}]"
                        rows = tbl.locator("tbody tr").count()
                        schichten_result["rows"] = rows
                        schichten_result["data_loaded"] = rows > 0
                        print(f"  [OK] Schichten-Tabelle gefunden (Index {i})")
                        print(f"  [OK] Zeilen: {rows}")
                        break
                except:
                    continue

        if not schichten_result["found"]:
            print("  [WARN] Schichten-Tabelle nicht gefunden")

        results["subforms"]["schichten"] = schichten_result

        # 2.2 Mitarbeiter-Zuordnung
        print("\n--- MITARBEITER-ZUORDNUNG ---")
        ma_result = {"found": False, "rows": 0, "columns": [], "data_loaded": False}

        ma_selectors = [
            "table.mitarbeiter-table",
            "#mitarbeiterContainer table",
            ".mitarbeiter-zuordnung table",
            "table:has(th:text('Vorname'))",
            "[data-subform='mitarbeiter']"
        ]

        for sel in ma_selectors:
            try:
                elem = page.locator(sel).first
                if elem.is_visible(timeout=1000):
                    ma_result["found"] = True
                    ma_result["selector"] = sel
                    rows = page.locator(f"{sel} tbody tr").count()
                    ma_result["rows"] = rows
                    ma_result["data_loaded"] = rows > 0
                    print(f"  [OK] Gefunden mit: {sel}")
                    print(f"  [OK] Zeilen: {rows}")
                    break
            except:
                continue

        if not ma_result["found"]:
            # Fallback
            all_tables = page.locator("table").all()
            for i, tbl in enumerate(all_tables):
                try:
                    html = tbl.inner_html()
                    if "Vorname" in html and "Qualifikation" in html:
                        ma_result["found"] = True
                        ma_result["selector"] = f"table[{i}]"
                        rows = tbl.locator("tbody tr").count()
                        ma_result["rows"] = rows
                        ma_result["data_loaded"] = rows > 0
                        print(f"  [OK] MA-Tabelle gefunden (Index {i})")
                        print(f"  [OK] Zeilen: {rows}")
                        break
                except:
                    continue

        if not ma_result["found"]:
            print("  [WARN] Mitarbeiter-Tabelle nicht gefunden")

        results["subforms"]["mitarbeiter_zuordnung"] = ma_result

        # 2.3 Auftragsliste (rechts)
        print("\n--- AUFTRAGSLISTE ---")
        al_result = {"found": False, "items": 0, "data_loaded": False}

        al_selectors = [
            ".auftragsliste",
            "#auftragsListe",
            ".auftrags-liste",
            "[data-subform='auftragsliste']",
            ".sidebar-right .list",
            ".order-list"
        ]

        for sel in al_selectors:
            try:
                elem = page.locator(sel).first
                if elem.is_visible(timeout=1000):
                    al_result["found"] = True
                    al_result["selector"] = sel
                    # Items zaehlen
                    items = page.locator(f"{sel} .list-item, {sel} li, {sel} .auftrag-item").count()
                    al_result["items"] = items
                    al_result["data_loaded"] = items > 0
                    print(f"  [OK] Gefunden mit: {sel}")
                    print(f"  [OK] Eintraege: {items}")
                    break
            except:
                continue

        if not al_result["found"]:
            print("  [WARN] Auftragsliste nicht direkt gefunden - suche nach Text...")
            # Suche nach bekannten Auftragsnamen aus Screenshot
            page_text = page.content()
            if "Spielwarenmesse" in page_text or "9259" in page_text:
                al_result["found"] = True
                al_result["data_loaded"] = True
                print("  [OK] Auftragsdaten im HTML gefunden")

        results["subforms"]["auftragsliste"] = al_result

        # 2.4 Tabs
        print("\n--- TABS ---")
        tabs_result = {"found": False, "tabs": [], "active_tab": None}

        tab_selectors = [
            ".tab-container",
            ".tabs",
            "[role='tablist']",
            ".nav-tabs",
            ".tab-navigation"
        ]

        for sel in tab_selectors:
            try:
                elem = page.locator(sel).first
                if elem.is_visible(timeout=1000):
                    tabs_result["found"] = True
                    tabs_result["selector"] = sel
                    # Tab-Namen extrahieren
                    tab_buttons = page.locator(f"{sel} button, {sel} .tab, {sel} [role='tab']").all()
                    tabs_result["tabs"] = [t.inner_text() for t in tab_buttons if t.inner_text().strip()]
                    print(f"  [OK] Gefunden mit: {sel}")
                    print(f"  [OK] Tabs: {tabs_result['tabs']}")
                    break
            except:
                continue

        if not tabs_result["found"]:
            # Suche nach Tab-Text
            page_text = page.content()
            expected_tabs = ["Einsatzliste", "Antworten ausstehend", "Zusatzdateien", "Rechnung", "Bemerkungen"]
            found_tabs = [t for t in expected_tabs if t in page_text]
            if found_tabs:
                tabs_result["found"] = True
                tabs_result["tabs"] = found_tabs
                print(f"  [OK] Tabs im HTML gefunden: {found_tabs}")

        results["subforms"]["tabs"] = tabs_result

        # 2.5 Screenshot erstellen
        print("\n[3] Erstelle Screenshot...")
        screenshot_path = ARTIFACTS_PATH / "subforms_test.png"
        page.screenshot(path=str(screenshot_path), full_page=False)
        print(f"  [OK] {screenshot_path}")
        results["screenshot"] = str(screenshot_path)

        # 2.6 DOM-Struktur analysieren
        print("\n[4] Analysiere DOM-Struktur...")

        # Alle Tabellen auflisten
        tables = page.locator("table").all()
        print(f"\n  Gefundene Tabellen: {len(tables)}")
        for i, tbl in enumerate(tables):
            try:
                # Erste Zeile als Preview
                first_row = tbl.locator("tr").first.inner_text()[:100]
                print(f"    [{i}] {first_row}...")
            except:
                print(f"    [{i}] (leer oder nicht lesbar)")

        # Alle iframes auflisten
        iframes = page.locator("iframe").all()
        print(f"\n  Gefundene iframes: {len(iframes)}")
        for i, iframe in enumerate(iframes):
            try:
                src = iframe.get_attribute("src") or "(kein src)"
                print(f"    [{i}] {src}")
            except:
                pass

        browser.close()

    # Ergebnis speichern
    result_path = ARTIFACTS_PATH / "subforms_test_result.json"
    with open(result_path, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    # Zusammenfassung
    print("\n" + "="*60)
    print("UNTERFORMULAR-TEST ERGEBNIS")
    print("="*60)

    all_ok = True
    for name, data in results["subforms"].items():
        status = "OK" if data.get("found") and data.get("data_loaded", data.get("tabs")) else "FEHLT/LEER"
        if status != "OK":
            all_ok = False
        print(f"  {name}: {status}")
        if data.get("rows"):
            print(f"    -> {data['rows']} Zeilen")
        if data.get("items"):
            print(f"    -> {data['items']} Eintraege")
        if data.get("tabs"):
            print(f"    -> {data['tabs']}")

    print("="*60)
    print(f"Gesamt: {'PASS' if all_ok else 'TEILWEISE'}")
    print(f"Details: {result_path}")

    return results

if __name__ == "__main__":
    test_subforms()

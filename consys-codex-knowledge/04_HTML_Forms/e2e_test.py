#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
CONSYS E2E Test - Playwright-basiert
Testet ob HTML-Formulare korrekt geladen und sichtbar sind
"""

import os
import sys
import json
import time
import socket
from datetime import datetime
from pathlib import Path

# Konfiguration
BASE_PATH = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms")
SHELL_HTML = BASE_PATH / "shell.html"
LOG_PATH = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\runtime_logs\e2e.jsonl")
ARTIFACTS_PATH = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\runtime_logs\artifacts")
API_PORT = 5000
HTTP_PORT = 8080

# Anker fuer Sichtbarkeits-Check
VISIBILITY_ANCHORS = {
    "auftraege": [".form-header", ".main-content", "h1, .header-title"],
    "default": [".main-content", "body"]
}


def log_e2e(action, details="", run_id=None):
    """Schreibt E2E Log"""
    try:
        LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
        entry = {
            "ts": datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")[:-3],
            "run_id": run_id or f"e2e_{int(time.time()*1000)}",
            "action": action,
            "details": details
        }
        with open(LOG_PATH, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry) + "\n")
        print(f"[E2E] {action}: {details}")
    except Exception as e:
        print(f"[E2E LOG ERROR] {e}")


def is_port_in_use(port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('localhost', port)) == 0


def check_api_server():
    """Prueft ob API-Server laeuft"""
    if not is_port_in_use(API_PORT):
        return False, "API-Server nicht erreichbar auf Port 5000"

    try:
        import urllib.request
        # Nur Root-Endpoint pruefen (schneller als /api/tables)
        response = urllib.request.urlopen(f'http://localhost:{API_PORT}/', timeout=5)
        return True, "API-Server antwortet"
    except Exception as e:
        return False, f"API-Server Fehler: {e}"


def check_http_server():
    """Prueft ob HTTP-Server laeuft"""
    if not is_port_in_use(HTTP_PORT):
        return False, "HTTP-Server nicht erreichbar auf Port 8080"
    return True, "HTTP-Server laeuft"


def run_playwright_test(form_id="auftraege"):
    """Fuehrt Playwright-Test durch"""
    run_id = f"e2e_{int(time.time()*1000)}"

    log_e2e("E2E_TEST_START", f"form_id={form_id}", run_id)

    # 1. API-Server Check
    api_ok, api_msg = check_api_server()
    log_e2e("API_CHECK", f"ok={api_ok}|msg={api_msg}", run_id)

    if not api_ok:
        log_e2e("E2E_TEST_FAIL", "API-Server nicht verfuegbar", run_id)
        return {
            "status": "FAIL",
            "reason": "API_SERVER_UNAVAILABLE",
            "details": api_msg,
            "run_id": run_id
        }

    # 1b. HTTP-Server Check
    http_ok, http_msg = check_http_server()
    log_e2e("HTTP_CHECK", f"ok={http_ok}|msg={http_msg}", run_id)

    if not http_ok:
        log_e2e("E2E_TEST_FAIL", "HTTP-Server nicht verfuegbar", run_id)
        return {
            "status": "FAIL",
            "reason": "HTTP_SERVER_UNAVAILABLE",
            "details": http_msg,
            "run_id": run_id
        }

    # 2. Playwright Test
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        log_e2e("E2E_TEST_FAIL", "Playwright nicht installiert. Bitte: pip install playwright && playwright install", run_id)
        return {
            "status": "FAIL",
            "reason": "PLAYWRIGHT_NOT_INSTALLED",
            "run_id": run_id
        }

    result = {
        "status": "UNKNOWN",
        "run_id": run_id,
        "form_id": form_id
    }

    with sync_playwright() as p:
        # Browser starten (headless fuer Test)
        browser = p.chromium.launch(headless=False)  # headless=False um zu sehen was passiert
        context = browser.new_context(viewport={"width": 1280, "height": 900})
        page = context.new_page()

        # Direkt das Formular laden (ohne Shell)
        form_file_map = {
            "auftraege": "frm_va_Auftragstamm.html",
            "mitarbeiter": "frm_MA_Mitarbeiterstamm.html",
            "kunden": "frm_KD_Kundenstamm.html",
            "objekte": "frm_OB_Objekt.html",
            "dienstplan": "frm_DP_Dienstplan_MA.html",
            "dashboard": "frm_Menuefuehrung.html"
        }
        form_file = form_file_map.get(form_id, f"frm_{form_id}.html")
        form_url = f"http://localhost:{HTTP_PORT}/forms/{form_file}"
        log_e2e("BROWSER_NAVIGATE", f"url={form_url}", run_id)

        try:
            # Seite laden
            page.goto(form_url, wait_until="domcontentloaded", timeout=30000)
            log_e2e("PAGE_LOADED", "domcontentloaded reached", run_id)

            # Kurz warten fuer JS-Initialisierung
            page.wait_for_timeout(2000)
            log_e2e("JS_INIT_WAIT", "2s wait complete", run_id)

            # Anker pruefen
            anchors = VISIBILITY_ANCHORS.get(form_id, VISIBILITY_ANCHORS["default"])
            visible_anchors = []
            missing_anchors = []

            for anchor in anchors:
                try:
                    element = page.locator(anchor).first
                    if element.is_visible(timeout=3000):
                        bbox = element.bounding_box()
                        if bbox and bbox["width"] > 0 and bbox["height"] > 0:
                            visible_anchors.append(anchor)
                        else:
                            missing_anchors.append(f"{anchor} (bbox=0)")
                    else:
                        missing_anchors.append(f"{anchor} (not visible)")
                except:
                    missing_anchors.append(f"{anchor} (not found)")

            log_e2e("VISIBILITY_CHECK", f"visible={visible_anchors}|missing={missing_anchors}", run_id)

            # Screenshot erstellen
            ARTIFACTS_PATH.mkdir(parents=True, exist_ok=True)
            screenshot_path = ARTIFACTS_PATH / f"run_{run_id}" / f"{form_id}.png"
            screenshot_path.parent.mkdir(parents=True, exist_ok=True)

            page.screenshot(path=str(screenshot_path), full_page=False)
            log_e2e("SCREENSHOT_SAVED", f"path={screenshot_path}", run_id)

            # Ergebnis
            if len(visible_anchors) > 0:
                result["status"] = "PASS"
                result["visible_anchors"] = visible_anchors
                result["screenshot"] = str(screenshot_path)
                log_e2e("E2E_TEST_PASS", f"visible_anchors={len(visible_anchors)}", run_id)
            else:
                result["status"] = "FAIL"
                result["reason"] = "NO_VISIBLE_ANCHORS"
                result["missing_anchors"] = missing_anchors
                result["screenshot"] = str(screenshot_path)
                log_e2e("E2E_TEST_FAIL", f"no visible anchors|missing={missing_anchors}", run_id)

        except Exception as e:
            log_e2e("E2E_TEST_ERROR", str(e), run_id)
            result["status"] = "FAIL"
            result["reason"] = "EXCEPTION"
            result["error"] = str(e)

            # Screenshot auch bei Fehler
            try:
                ARTIFACTS_PATH.mkdir(parents=True, exist_ok=True)
                screenshot_path = ARTIFACTS_PATH / f"run_{run_id}" / f"{form_id}_error.png"
                screenshot_path.parent.mkdir(parents=True, exist_ok=True)
                page.screenshot(path=str(screenshot_path))
                result["screenshot"] = str(screenshot_path)
            except:
                pass

        finally:
            browser.close()

    return result


def print_report(result):
    """Gibt formatierten Report aus"""
    print("\n" + "="*60)
    print("E2E TEST REPORT")
    print("="*60)
    print(f"Status:     {result.get('status', 'UNKNOWN')}")
    print(f"Run-ID:     {result.get('run_id', 'N/A')}")
    print(f"Form-ID:    {result.get('form_id', 'N/A')}")

    if result.get("reason"):
        print(f"Reason:     {result['reason']}")
    if result.get("error"):
        print(f"Error:      {result['error']}")
    if result.get("visible_anchors"):
        print(f"Visible:    {result['visible_anchors']}")
    if result.get("missing_anchors"):
        print(f"Missing:    {result['missing_anchors']}")
    if result.get("screenshot"):
        print(f"Screenshot: {result['screenshot']}")

    print("="*60 + "\n")


if __name__ == "__main__":
    form_id = sys.argv[1] if len(sys.argv) > 1 else "auftraege"

    print(f"\nStarte E2E Test fuer: {form_id}")
    print("-"*40)

    result = run_playwright_test(form_id)
    print_report(result)

    # Exit-Code basierend auf Ergebnis
    sys.exit(0 if result["status"] == "PASS" else 1)

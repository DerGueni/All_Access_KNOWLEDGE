#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Screenshot vom Access-Formular frm_va_Auftragstamm erstellen
Verwendet pyautogui für Screenshot nach Formular-Öffnung
"""

import sys
import os
import time
import subprocess

# Pfade
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

try:
    import pyautogui
    print("[OK] pyautogui importiert")
except ImportError:
    print("[INFO] Installiere pyautogui...")
    subprocess.run([sys.executable, "-m", "pip", "install", "pyautogui"], check=True)
    import pyautogui

try:
    from PIL import Image
    print("[OK] PIL importiert")
except ImportError:
    print("[INFO] Installiere Pillow...")
    subprocess.run([sys.executable, "-m", "pip", "install", "Pillow"], check=True)
    from PIL import Image

# Output-Pfad
OUTPUT_DIR = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\runtime_logs\artifacts"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def capture_access_form():
    """Öffnet Access-Formular und macht Screenshot"""

    print("\n" + "="*60)
    print("ACCESS FORMULAR SCREENSHOT")
    print("="*60)

    # 1. Versuche Access Bridge zu nutzen
    try:
        from access_bridge_ultimate import AccessBridge

        print("\n[1] Öffne Access-Datenbank...")
        with AccessBridge() as bridge:
            print(f"[OK] Verbunden mit: {bridge.frontend_path}")

            # 2. Formular öffnen
            print("\n[2] Öffne Formular frm_va_Auftragstamm...")
            bridge.open_form("frm_va_Auftragstamm", view=0)  # 0 = Normal View

            # 3. Warten bis Formular geladen
            print("[3] Warte 3 Sekunden auf Formular-Laden...")
            time.sleep(3)

            # 4. Screenshot machen
            print("\n[4] Erstelle Screenshot...")
            screenshot = pyautogui.screenshot()

            # 5. Speichern
            screenshot_path = os.path.join(OUTPUT_DIR, "access_frm_va_Auftragstamm.png")
            screenshot.save(screenshot_path)
            print(f"[OK] Screenshot gespeichert: {screenshot_path}")

            # 6. Optional: Formular schließen
            print("\n[5] Formular bleibt offen für manuelle Inspektion")

            return screenshot_path

    except Exception as e:
        print(f"[ERROR] Access Bridge Fehler: {e}")
        print("\n[FALLBACK] Versuche manuellen Screenshot...")

        # Fallback: Einfacher Desktop-Screenshot
        time.sleep(2)
        screenshot = pyautogui.screenshot()
        screenshot_path = os.path.join(OUTPUT_DIR, "desktop_screenshot.png")
        screenshot.save(screenshot_path)
        print(f"[OK] Desktop-Screenshot gespeichert: {screenshot_path}")
        return screenshot_path


def capture_active_window():
    """Macht Screenshot nur vom aktiven Fenster"""
    try:
        import win32gui
        import win32ui
        import win32con
        from ctypes import windll

        # Aktives Fenster finden
        hwnd = win32gui.GetForegroundWindow()

        # Fenster-Rect
        left, top, right, bottom = win32gui.GetWindowRect(hwnd)
        width = right - left
        height = bottom - top

        # Screenshot des Fensters
        screenshot = pyautogui.screenshot(region=(left, top, width, height))

        screenshot_path = os.path.join(OUTPUT_DIR, "access_window_frm_va_Auftragstamm.png")
        screenshot.save(screenshot_path)
        print(f"[OK] Fenster-Screenshot gespeichert: {screenshot_path}")
        return screenshot_path

    except Exception as e:
        print(f"[ERROR] Fenster-Screenshot fehlgeschlagen: {e}")
        return None


if __name__ == "__main__":
    print("Starte Access-Formular Screenshot-Capture...")
    print("HINWEIS: Access muss geöffnet sein oder wird automatisch geöffnet.")
    print("")

    result = capture_access_form()

    if result:
        print(f"\n[FERTIG] Screenshot erstellt: {result}")
    else:
        print("\n[FEHLER] Screenshot konnte nicht erstellt werden")

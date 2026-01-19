#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Screenshot vom Access-Formular - mit Fenster-Fokus
"""

import sys
import os
import time
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

import pyautogui
from PIL import Image

# Win32 für Fensterfokus
try:
    import win32gui
    import win32con
    HAS_WIN32 = True
except ImportError:
    print("[WARN] pywin32 nicht installiert - verwende Fallback")
    HAS_WIN32 = False

OUTPUT_DIR = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\runtime_logs\artifacts"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def find_access_window():
    """Findet das Access-Fenster"""
    access_hwnd = None

    def enum_handler(hwnd, results):
        if win32gui.IsWindowVisible(hwnd):
            title = win32gui.GetWindowText(hwnd)
            if "Microsoft Access" in title or "Consys" in title or "frm_va_Auftragstamm" in title.lower() or "auftragsverwaltung" in title.lower():
                results.append((hwnd, title))

    results = []
    win32gui.EnumWindows(enum_handler, results)

    # Bevorzuge Fenster mit "Auftrag" im Titel
    for hwnd, title in results:
        if "auftrag" in title.lower():
            return hwnd, title

    # Sonst erstes Access-Fenster
    for hwnd, title in results:
        if "access" in title.lower() or "consys" in title.lower():
            return hwnd, title

    return None, None

def capture_window(hwnd):
    """Macht Screenshot eines bestimmten Fensters"""
    # Fenster in den Vordergrund
    win32gui.SetForegroundWindow(hwnd)
    time.sleep(0.5)

    # Fenster-Position und Größe
    rect = win32gui.GetWindowRect(hwnd)
    left, top, right, bottom = rect
    width = right - left
    height = bottom - top

    print(f"[INFO] Fenster-Position: ({left}, {top}) - Größe: {width}x{height}")

    # Screenshot des Bereichs
    screenshot = pyautogui.screenshot(region=(left, top, width, height))
    return screenshot

def main():
    print("\n" + "="*60)
    print("ACCESS FENSTER SCREENSHOT")
    print("="*60)

    # 1. Access Bridge nutzen um Formular zu öffnen
    try:
        from access_bridge_ultimate import AccessBridge

        print("\n[1] Öffne Access und Formular...")
        with AccessBridge() as bridge:
            # Formular öffnen
            bridge.open_form("frm_va_Auftragstamm", view=0)
            print("[OK] Formular geöffnet")

            # Warten
            time.sleep(2)

            # 2. Access-Fenster finden
            if HAS_WIN32:
                print("\n[2] Suche Access-Fenster...")
                hwnd, title = find_access_window()

                if hwnd:
                    print(f"[OK] Gefunden: {title}")

                    # 3. Screenshot machen
                    print("\n[3] Erstelle Screenshot...")
                    screenshot = capture_window(hwnd)

                    # Speichern
                    screenshot_path = os.path.join(OUTPUT_DIR, "access_frm_va_Auftragstamm_window.png")
                    screenshot.save(screenshot_path)
                    print(f"[OK] Screenshot gespeichert: {screenshot_path}")

                    return screenshot_path
                else:
                    print("[WARN] Kein Access-Fenster gefunden")

            # Fallback: Vollbild-Screenshot
            print("\n[FALLBACK] Vollbild-Screenshot...")
            time.sleep(1)
            screenshot = pyautogui.screenshot()
            screenshot_path = os.path.join(OUTPUT_DIR, "access_frm_va_Auftragstamm_fullscreen.png")
            screenshot.save(screenshot_path)
            print(f"[OK] Screenshot gespeichert: {screenshot_path}")
            return screenshot_path

    except Exception as e:
        print(f"[ERROR] {e}")
        import traceback
        traceback.print_exc()
        return None

if __name__ == "__main__":
    result = main()
    if result:
        print(f"\n[FERTIG] {result}")

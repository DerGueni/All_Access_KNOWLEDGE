#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Einfacher Access Screenshot - wartet auf manuelle Formular-Öffnung
"""

import sys
import os
import time
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

import pyautogui
from PIL import Image
import win32gui
import win32con
import ctypes

OUTPUT_DIR = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\runtime_logs\artifacts"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def get_all_windows():
    """Listet alle sichtbaren Fenster"""
    windows = []
    def enum_handler(hwnd, results):
        if win32gui.IsWindowVisible(hwnd):
            title = win32gui.GetWindowText(hwnd)
            if title:
                results.append((hwnd, title))
    win32gui.EnumWindows(enum_handler, windows)
    return windows

def capture_by_title(search_term):
    """Screenshot eines Fensters nach Titel-Suche"""
    windows = get_all_windows()

    print(f"\n[INFO] Suche Fenster mit '{search_term}'...")
    for hwnd, title in windows:
        if search_term.lower() in title.lower():
            print(f"[OK] Gefunden: {title[:80]}...")

            # Fensterposition holen
            rect = win32gui.GetWindowRect(hwnd)
            left, top, right, bottom = rect
            width = right - left
            height = bottom - top

            print(f"[INFO] Position: ({left}, {top}), Größe: {width}x{height}")

            # Screenshot des Bereichs
            if width > 100 and height > 100:
                screenshot = pyautogui.screenshot(region=(left, top, width, height))
                return screenshot, title

    return None, None

def main():
    print("\n" + "="*60)
    print("ACCESS FORMULAR SCREENSHOT")
    print("="*60)

    # 1. Öffne das Formular über Access Bridge
    print("\n[1] Öffne Access-Formular...")
    try:
        from access_bridge_ultimate import AccessBridge
        with AccessBridge() as bridge:
            bridge.open_form("frm_va_Auftragstamm", view=0)
            print("[OK] Formular geöffnet")
    except Exception as e:
        print(f"[WARN] Bridge-Fehler: {e}")
        print("[INFO] Bitte Formular manuell öffnen...")

    # 2. Warte etwas
    print("\n[2] Warte 3 Sekunden...")
    time.sleep(3)

    # 3. Suche nach Access-Fenster
    print("\n[3] Suche Access-Fenster...")

    # Liste alle Fenster
    windows = get_all_windows()
    access_windows = [(h, t) for h, t in windows if "access" in t.lower() or "consys" in t.lower() or "auftrag" in t.lower()]

    print(f"[INFO] Gefundene Access-Fenster: {len(access_windows)}")
    for hwnd, title in access_windows:
        print(f"  - {title[:70]}...")

    # 4. Screenshots von Access-Fenstern machen
    print("\n[4] Erstelle Screenshots...")

    # Versuche verschiedene Suchbegriffe
    for search in ["Auftragsverwaltung", "frm_va_Auftragstamm", "Access - Consys"]:
        screenshot, title = capture_by_title(search)
        if screenshot:
            filename = f"access_form_{search.replace(' ', '_')[:20]}.png"
            filepath = os.path.join(OUTPUT_DIR, filename)
            screenshot.save(filepath)
            print(f"[OK] Gespeichert: {filepath}")

    # 5. Auch Vollbild als Backup
    print("\n[5] Backup: Vollbild-Screenshot...")
    fullscreen = pyautogui.screenshot()
    fullscreen_path = os.path.join(OUTPUT_DIR, "access_fullscreen_backup.png")
    fullscreen.save(fullscreen_path)
    print(f"[OK] {fullscreen_path}")

    print("\n[FERTIG] Screenshots erstellt in:")
    print(f"  {OUTPUT_DIR}")

if __name__ == "__main__":
    main()

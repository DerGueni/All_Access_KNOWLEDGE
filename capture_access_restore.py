#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Access Screenshot mit Fenster-Restore
"""

import sys
import os
import time
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

import pyautogui
import win32gui
import win32con
import ctypes

OUTPUT_DIR = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\runtime_logs\artifacts"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def find_access_window():
    """Findet Access-Fenster"""
    results = []
    def enum_handler(hwnd, results):
        if win32gui.IsWindow(hwnd):
            title = win32gui.GetWindowText(hwnd)
            if "Access" in title and "Consys" in title:
                results.append((hwnd, title))
    win32gui.EnumWindows(enum_handler, results)
    return results[0] if results else (None, None)

def restore_and_capture(hwnd):
    """Fenster wiederherstellen und Screenshot machen"""
    print(f"[INFO] Fenster-Handle: {hwnd}")

    # Fenster wiederherstellen falls minimiert
    placement = win32gui.GetWindowPlacement(hwnd)
    print(f"[INFO] Window Placement: {placement}")

    if placement[1] == win32con.SW_SHOWMINIMIZED:
        print("[INFO] Fenster ist minimiert - stelle wieder her...")
        win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
        time.sleep(0.5)

    # In den Vordergrund bringen
    try:
        # Methode 1: SetForegroundWindow mit Trick
        ctypes.windll.user32.SetForegroundWindow(hwnd)
    except:
        pass

    try:
        # Methode 2: BringWindowToTop
        win32gui.BringWindowToTop(hwnd)
    except:
        pass

    time.sleep(1)

    # Fensterposition holen
    rect = win32gui.GetWindowRect(hwnd)
    left, top, right, bottom = rect
    width = right - left
    height = bottom - top

    print(f"[INFO] Position nach Restore: ({left}, {top}), Groesse: {width}x{height}")

    if left < -1000 or width < 100:
        print("[WARN] Fenster noch minimiert - Vollbild-Screenshot...")
        return pyautogui.screenshot()

    # Screenshot des Bereichs
    screenshot = pyautogui.screenshot(region=(left, top, width, height))
    return screenshot

def main():
    print("\n" + "="*60)
    print("ACCESS FORMULAR SCREENSHOT MIT RESTORE")
    print("="*60)

    # 1. Formular oeffnen
    print("\n[1] Oeffne Access-Formular...")
    try:
        from access_bridge_ultimate import AccessBridge
        with AccessBridge() as bridge:
            bridge.open_form("frm_va_Auftragstamm", view=0)
            print("[OK] Formular geoeffnet")
    except Exception as e:
        print(f"[WARN] Bridge-Fehler: {e}")

    time.sleep(2)

    # 2. Access-Fenster finden
    print("\n[2] Suche Access-Fenster...")
    hwnd, title = find_access_window()

    if not hwnd:
        print("[ERROR] Kein Access-Fenster gefunden!")
        return

    print(f"[OK] Gefunden: {title[:60]}...")

    # 3. Screenshot mit Restore
    print("\n[3] Erstelle Screenshot...")
    screenshot = restore_and_capture(hwnd)

    # 4. Speichern
    filepath = os.path.join(OUTPUT_DIR, "access_frm_va_Auftragstamm.png")
    screenshot.save(filepath)
    print(f"[OK] Gespeichert: {filepath}")

    print("\n[FERTIG]")

if __name__ == "__main__":
    main()

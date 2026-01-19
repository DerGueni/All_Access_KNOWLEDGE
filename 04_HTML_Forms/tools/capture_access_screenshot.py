"""
Erstellt Screenshot des Access-Formulars
"""

import sys
import io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

import win32com.client
import time
from PIL import ImageGrab, Image
import win32gui
import win32con
from pathlib import Path

SCREENSHOTS_DIR = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\screenshots_test")

def capture_access_form():
    """Öffnet Access-Formular und erstellt Screenshot"""
    print("Erstelle Access-Screenshot...")

    try:
        # Verbinde zu Access
        access = win32com.client.GetActiveObject("Access.Application")
        print(f"  ✓ Access verbunden")

        # Schließe das Formular falls offen
        try:
            access.DoCmd.Close(2, "frm_va_Auftragstamm", 2)  # 2=acForm, 2=acSaveNo
            time.sleep(0.5)
        except:
            pass

        # Öffne Formular
        access.DoCmd.OpenForm("frm_va_Auftragstamm", 0)  # 0=acNormal
        print("  ✓ Formular geöffnet")

        # Warte bis geladen
        time.sleep(3)

        # Finde das Access-Hauptfenster
        def enum_windows_callback(hwnd, windows):
            if win32gui.IsWindowVisible(hwnd):
                title = win32gui.GetWindowText(hwnd)
                if "Microsoft Access" in title or "frm_va_Auftragstamm" in title:
                    windows.append((hwnd, title))
            return True

        windows = []
        win32gui.EnumWindows(enum_windows_callback, windows)

        if windows:
            # Nimm das erste gefundene Fenster
            hwnd, title = windows[0]
            print(f"  ✓ Fenster gefunden: {title}")

            # Bringe Fenster in den Vordergrund
            win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
            win32gui.SetForegroundWindow(hwnd)
            time.sleep(1)

            # Hole Fenster-Position
            rect = win32gui.GetWindowRect(hwnd)
            x1, y1, x2, y2 = rect

            # Screenshot des Fensters
            screenshot = ImageGrab.grab(bbox=(x1, y1, x2, y2))
            screenshot_path = SCREENSHOTS_DIR / "access_frm_va_Auftragstamm.png"
            screenshot.save(screenshot_path)
            print(f"  ✓ Screenshot: {screenshot_path}")

            return screenshot_path
        else:
            print("  ✗ Konnte Access-Fenster nicht finden")

            # Fallback: Full-Screen Screenshot
            screenshot = ImageGrab.grab()
            screenshot_path = SCREENSHOTS_DIR / "access_frm_va_Auftragstamm_fullscreen.png"
            screenshot.save(screenshot_path)
            print(f"  ✓ Fullscreen Screenshot: {screenshot_path}")
            return screenshot_path

    except Exception as e:
        print(f"  ✗ Fehler: {e}")
        import traceback
        traceback.print_exc()
        return None

if __name__ == "__main__":
    capture_access_form()
    print("\n✓ Screenshot erstellt!")

"""
Restore Dashboard from backup
"""
import win32com.client
import pythoncom
import subprocess
import time
from pathlib import Path

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (4).accdb"
BACKUP_PATH = r"C:\Users\guenther.siegert\Documents\Access Bridge\temp_dashboard.txt"

def start_killer():
    p = Path(r"C:\Users\guenther.siegert\Documents\Access Bridge\DialogKillerPermanent.ps1")
    if p.exists():
        return subprocess.Popen(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", str(p), "-Minutes", "30", "-IntervalMs", "50"],
            creationflags=subprocess.CREATE_NO_WINDOW, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return None

print("=" * 70)
print("RESTORE DASHBOARD")
print("=" * 70)

killer = start_killer()

try:
    pythoncom.CoInitialize()

    print("\n[1] Access verbinden...")
    try:
        app = win32com.client.GetObject(Class="Access.Application")
    except:
        app = win32com.client.Dispatch("Access.Application")
        app.Visible = True
        app.UserControl = True
        app.OpenCurrentDatabase(FRONTEND_PATH, False)
        time.sleep(3)

    print("[OK] Access verbunden")

    # Prüfe ob Backup existiert
    if not Path(BACKUP_PATH).exists():
        print(f"\n[FEHLER] Backup nicht gefunden: {BACKUP_PATH}")
    else:
        print(f"\n[2] Backup gefunden: {BACKUP_PATH}")

        # Versuche Formular zu löschen falls es existiert
        try:
            app.DoCmd.DeleteObject(2, "frm_N_DP_Dashboard")
            print("    Existierendes Formular gelöscht")
        except:
            print("    Formular existiert nicht (wird neu erstellt)")

        # Importiere aus Backup
        print("\n[3] Importiere aus Backup...")
        app.LoadFromText(2, "frm_N_DP_Dashboard", BACKUP_PATH)
        print("    [OK] Formular wiederhergestellt")

        # Prüfung
        print("\n[4] Prüfe Formular...")
        app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)
        time.sleep(0.5)
        frm = app.Forms("frm_N_DP_Dashboard")
        print(f"    Detail BackColor: {frm.Section(0).BackColor}")
        app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)

    print("\n" + "=" * 70)
    print("FERTIG")
    print("=" * 70)

except Exception as e:
    print(f"\n[FEHLER] {e}")
    import traceback
    traceback.print_exc()

finally:
    if killer:
        try:
            killer.terminate()
        except:
            pass
    pythoncom.CoUninitialize()

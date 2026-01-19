"""
Verify Dashboard Design
"""
import win32com.client
import pythoncom
import subprocess
import time
from pathlib import Path

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (4).accdb"

def start_killer():
    p = Path(r"C:\Users\guenther.siegert\Documents\Access Bridge\DialogKillerPermanent.ps1")
    if p.exists():
        return subprocess.Popen(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", str(p), "-Minutes", "30", "-IntervalMs", "50"],
            creationflags=subprocess.CREATE_NO_WINDOW, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return None

print("=" * 70)
print("VERIFY DASHBOARD DESIGN")
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

    # Öffne Dashboard
    print("\n[2] Öffne frm_N_DP_Dashboard...")
    try:
        app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)
    except:
        pass

    app.DoCmd.OpenForm("frm_N_DP_Dashboard", 0)  # Normal view
    time.sleep(1)

    frm = app.Forms("frm_N_DP_Dashboard")

    print("\n[3] Eigenschaften:")
    print(f"    Detail (Section 0):")
    print(f"        BackColor: {frm.Section(0).BackColor}")
    print(f"        Height: {frm.Section(0).Height}")

    try:
        print(f"\n    Header (Section 1):")
        print(f"        BackColor: {frm.Section(1).BackColor}")
        print(f"        Height: {frm.Section(1).Height}")
        print(f"        Visible: {frm.Section(1).Visible}")
    except Exception as e:
        print(f"    Header: {e}")

    try:
        print(f"\n    Footer (Section 2):")
        print(f"        BackColor: {frm.Section(2).BackColor}")
        print(f"        Height: {frm.Section(2).Height}")
        print(f"        Visible: {frm.Section(2).Visible}")
    except Exception as e:
        print(f"    Footer: {e}")

    print("\n[4] Controls im Header:")
    try:
        header = frm.Section(1)
        for i in range(frm.Controls.Count):
            ctl = frm.Controls(i)
            try:
                if ctl.Section == 1:
                    print(f"        {ctl.Name}: Type={ctl.ControlType}")
            except:
                pass
    except:
        print("        Keine Controls im Header")

    print("\n" + "=" * 70)
    print("DASHBOARD IST GEÖFFNET - Prüfen Sie die Anzeige")
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

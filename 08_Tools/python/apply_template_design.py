"""
Apply Template Design to Dashboard
Wendet das Design von frm_N_template auf frm_N_DP_Dashboard an
"""
import win32com.client
import pythoncom
import subprocess
import time
from pathlib import Path

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (4).accdb"

# Design-Konstanten aus frm_N_template
BLUE_COLOR = 11671107      # Blau für Header/Footer
GRAY_COLOR = 14277081      # Grau für Detail
HEADER_HEIGHT = 1318       # Höhe Formularkopf
FOOTER_HEIGHT = 347        # Höhe Formularfuß

def start_killer():
    p = Path(r"C:\Users\guenther.siegert\Documents\Access Bridge\DialogKillerPermanent.ps1")
    if p.exists():
        return subprocess.Popen(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", str(p), "-Minutes", "30", "-IntervalMs", "50"],
            creationflags=subprocess.CREATE_NO_WINDOW, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return None

print("=" * 70)
print("APPLY TEMPLATE DESIGN TO DASHBOARD")
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

    # Formulare schliessen
    for form_name in ["frm_N_DP_Dashboard", "frm_N_template"]:
        try:
            app.DoCmd.Close(2, form_name, 2)
        except:
            pass
    time.sleep(0.5)

    # Dashboard im Design-Modus öffnen
    print("\n[2] Öffne frm_N_DP_Dashboard im Design-Modus...")
    app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign = 1
    time.sleep(1)

    frm = app.Forms("frm_N_DP_Dashboard")

    # Aktuelle Eigenschaften anzeigen
    print(f"    Aktuelle Detail BackColor: {frm.Section(0).BackColor}")

    # Prüfen ob Header/Footer existieren
    try:
        header = frm.Section(1)  # acHeader
        print(f"    Header existiert: BackColor={header.BackColor}, Height={header.Height}")
    except:
        print("    Header existiert NICHT")

    try:
        footer = frm.Section(2)  # acFooter
        print(f"    Footer existiert: BackColor={footer.BackColor}, Height={footer.Height}")
    except:
        print("    Footer existiert NICHT")

    # Design-Eigenschaften setzen
    print("\n[3] Setze Design-Eigenschaften...")

    # Detail-Bereich (grau)
    frm.Section(0).BackColor = GRAY_COLOR
    print(f"    Detail BackColor: {GRAY_COLOR} (grau)")

    # Formular-Eigenschaften
    frm.RecordSelectors = False
    frm.NavigationButtons = False
    frm.DividingLines = False
    print("    RecordSelectors=False, NavigationButtons=False, DividingLines=False")

    # Header aktivieren falls nicht vorhanden
    try:
        header = frm.Section(1)
        header.BackColor = BLUE_COLOR
        header.Height = HEADER_HEIGHT
        print(f"    Header BackColor: {BLUE_COLOR} (blau), Height: {HEADER_HEIGHT}")
    except Exception as e:
        print(f"    [!] Header-Fehler: {e}")
        # Header muss über Formular-Eigenschaft aktiviert werden
        # In Access VBA: Me.HasFormHeader = True

    # Footer aktivieren falls nicht vorhanden
    try:
        footer = frm.Section(2)
        footer.BackColor = BLUE_COLOR
        footer.Height = FOOTER_HEIGHT
        print(f"    Footer BackColor: {BLUE_COLOR} (blau), Height: {FOOTER_HEIGHT}")
    except Exception as e:
        print(f"    [!] Footer-Fehler: {e}")

    # Speichern
    print("\n[4] Speichern...")
    app.DoCmd.Save(2, "frm_N_DP_Dashboard")
    print("    [OK] Gespeichert")

    # Schliessen und neu öffnen zur Prüfung
    app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
    time.sleep(0.5)

    # Prüfung: Im Formular-Modus öffnen
    print("\n[5] Öffne zur Prüfung...")
    app.DoCmd.OpenForm("frm_N_DP_Dashboard", 0)  # acNormal = 0
    time.sleep(1)

    frm = app.Forms("frm_N_DP_Dashboard")
    print(f"    Detail BackColor: {frm.Section(0).BackColor}")

    print("\n" + "=" * 70)
    print("DESIGN ANGEWENDET")
    print("=" * 70)
    print("\nHinweis: Falls Header/Footer nicht sichtbar sind,")
    print("müssen diese manuell im Design-Modus über")
    print("Ansicht > Formularkopf/-fuss aktiviert werden.")

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

"""
Apply Template Design to Dashboard V6
Einfacher Ansatz: Nur Farben setzen, Header/Footer muss manuell aktiviert werden
"""
import win32com.client
import pythoncom
import subprocess
import time
from pathlib import Path

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (4).accdb"

# Design-Konstanten
BLUE_COLOR = 11671107      # Blau für Header/Footer
GRAY_COLOR = 14277081      # Grau für Detail

def start_killer():
    p = Path(r"C:\Users\guenther.siegert\Documents\Access Bridge\DialogKillerPermanent.ps1")
    if p.exists():
        return subprocess.Popen(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", str(p), "-Minutes", "30", "-IntervalMs", "50"],
            creationflags=subprocess.CREATE_NO_WINDOW, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return None

print("=" * 70)
print("APPLY TEMPLATE DESIGN V6 - Einfacher Ansatz")
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
    for form_name in ["frm_N_DP_Dashboard"]:
        try:
            app.DoCmd.Close(2, form_name, 2)
        except:
            pass
    time.sleep(0.5)

    # Dashboard im Design öffnen
    print("\n[2] Öffne frm_N_DP_Dashboard im Design...")
    app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
    time.sleep(1)

    frm = app.Forms("frm_N_DP_Dashboard")

    # Detail-Bereich Farbe setzen
    print("\n[3] Setze Eigenschaften...")
    frm.Section(0).BackColor = GRAY_COLOR
    print(f"    Detail BackColor: {GRAY_COLOR}")

    # Weitere Formular-Eigenschaften
    frm.RecordSelectors = False
    frm.NavigationButtons = False
    frm.DividingLines = False

    # Prüfe ob Header/Footer existiert
    has_header = False
    has_footer = False
    try:
        h = frm.Section(1)
        has_header = True
        h.BackColor = BLUE_COLOR
        print(f"    Header BackColor: {BLUE_COLOR}")
    except:
        print("    [!] Header existiert nicht")

    try:
        f = frm.Section(2)
        has_footer = True
        f.BackColor = BLUE_COLOR
        print(f"    Footer BackColor: {BLUE_COLOR}")
    except:
        print("    [!] Footer existiert nicht")

    # Speichern
    print("\n[4] Speichern...")
    app.DoCmd.Save(2, "frm_N_DP_Dashboard")
    app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)

    # Info für Benutzer
    if not has_header or not has_footer:
        print("\n" + "=" * 70)
        print("MANUELLE SCHRITTE ERFORDERLICH")
        print("=" * 70)
        print("""
Um Header und Footer hinzuzufügen:

1. Öffnen Sie frm_N_DP_Dashboard im Entwurf
2. Klicken Sie auf: Entwurf > Formularkopf/-fuss (im Ribbon)
   ODER: Rechtsklick > Formularkopf/-fuss anzeigen
3. Setzen Sie im Eigenschaftenblatt:
   - Formularkopf > Hintergrundfarbe: 11671107
   - Formularkopf > Höhe: 3,5 cm
   - Formularfuss > Hintergrundfarbe: 11671107
   - Formularfuss > Höhe: 0,9 cm
4. Speichern und schließen

Der graue Detailbereich ist bereits eingestellt.
""")

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

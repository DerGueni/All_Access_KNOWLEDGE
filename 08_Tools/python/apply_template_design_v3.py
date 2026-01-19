"""
Apply Template Design to Dashboard V3
Kopiert Design-Elemente von frm_N_template
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

def start_killer():
    p = Path(r"C:\Users\guenther.siegert\Documents\Access Bridge\DialogKillerPermanent.ps1")
    if p.exists():
        return subprocess.Popen(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", str(p), "-Minutes", "30", "-IntervalMs", "50"],
            creationflags=subprocess.CREATE_NO_WINDOW, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return None

print("=" * 70)
print("APPLY TEMPLATE DESIGN V3")
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

    # Analysiere frm_N_template genauer
    print("\n[2] Analysiere frm_N_template...")
    app.DoCmd.OpenForm("frm_N_template", 1)  # Design
    time.sleep(0.5)

    template = app.Forms("frm_N_template")

    # Header-Controls sammeln
    header_controls = []
    print("\n    Header-Controls:")
    try:
        header = template.Section(1)
        for i in range(template.Controls.Count):
            ctl = template.Controls(i)
            try:
                if ctl.Section == 1:  # Header
                    info = {
                        'name': ctl.Name,
                        'type': ctl.ControlType,
                        'left': ctl.Left,
                        'top': ctl.Top,
                        'width': ctl.Width,
                        'height': ctl.Height
                    }
                    # Zusätzliche Properties je nach Typ
                    try:
                        info['caption'] = ctl.Caption
                    except:
                        pass
                    try:
                        info['backcolor'] = ctl.BackColor
                    except:
                        pass
                    try:
                        info['forecolor'] = ctl.ForeColor
                    except:
                        pass

                    header_controls.append(info)
                    print(f"        {ctl.Name}: Type={ctl.ControlType}, Left={ctl.Left}, Top={ctl.Top}")
            except:
                pass
    except Exception as e:
        print(f"    Header-Fehler: {e}")

    # Footer-Controls sammeln
    footer_controls = []
    print("\n    Footer-Controls:")
    try:
        footer = template.Section(2)
        for i in range(template.Controls.Count):
            ctl = template.Controls(i)
            try:
                if ctl.Section == 2:  # Footer
                    info = {
                        'name': ctl.Name,
                        'type': ctl.ControlType,
                        'left': ctl.Left,
                        'top': ctl.Top,
                        'width': ctl.Width,
                        'height': ctl.Height
                    }
                    footer_controls.append(info)
                    print(f"        {ctl.Name}: Type={ctl.ControlType}")
            except:
                pass
    except Exception as e:
        print(f"    Footer-Fehler: {e}")

    app.DoCmd.Close(2, "frm_N_template", 2)

    # Da Header/Footer nicht programmatisch aktiviert werden können,
    # erstellen wir eine Anleitung
    print("\n" + "=" * 70)
    print("MANUELLE SCHRITTE ERFORDERLICH")
    print("=" * 70)
    print("""
Um Header und Footer zum Dashboard hinzuzufügen:

1. Öffnen Sie frm_N_DP_Dashboard im Entwurfsmodus
2. Menü: Ansicht > Formularkopf/-fuss (oder Rechtsklick > Formularkopf/-fuss)
3. Setzen Sie folgende Eigenschaften im Eigenschaftenblatt:

   Formularkopf (Section 1):
   - Hintergrundfarbe: 11671107
   - Höhe: ca. 3,5 cm (1318 Twips)

   Detailbereich (Section 0):
   - Hintergrundfarbe: 14277081 (bereits gesetzt)

   Formularfuss (Section 2):
   - Hintergrundfarbe: 11671107
   - Höhe: ca. 0,9 cm (347 Twips)

4. Kopieren Sie das Logo und die Versions-/Datums-Labels aus frm_N_template

Alternativ: Kopieren Sie frm_N_template und benennen Sie es um.
""")

    # Detail-Bereich nochmal setzen falls nicht geschehen
    print("\n[3] Setze Detail-Hintergrund...")
    app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)
    time.sleep(0.5)
    frm = app.Forms("frm_N_DP_Dashboard")
    frm.Section(0).BackColor = GRAY_COLOR
    frm.RecordSelectors = False
    frm.NavigationButtons = False
    frm.DividingLines = False
    app.DoCmd.Save(2, "frm_N_DP_Dashboard")
    app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
    print("    [OK] Detail-Bereich ist grau")

    print("\n" + "=" * 70)
    print("FERTIG - Manuelle Schritte beachten!")
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

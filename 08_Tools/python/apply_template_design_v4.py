"""
Apply Template Design to Dashboard V4
Verwendet SaveAsText/LoadFromText um Header/Footer hinzuzufügen
"""
import win32com.client
import pythoncom
import subprocess
import time
import re
from pathlib import Path

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (4).accdb"
EXPORT_PATH = r"C:\Users\guenther.siegert\Documents\Access Bridge\temp_dashboard.txt"

def start_killer():
    p = Path(r"C:\Users\guenther.siegert\Documents\Access Bridge\DialogKillerPermanent.ps1")
    if p.exists():
        return subprocess.Popen(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", str(p), "-Minutes", "30", "-IntervalMs", "50"],
            creationflags=subprocess.CREATE_NO_WINDOW, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return None

print("=" * 70)
print("APPLY TEMPLATE DESIGN V4 - SaveAsText/LoadFromText")
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

    # Exportiere frm_N_template als Text
    print("\n[2] Exportiere frm_N_template...")
    template_path = r"C:\Users\guenther.siegert\Documents\Access Bridge\temp_template.txt"
    app.SaveAsText(2, "frm_N_template", template_path)  # acForm = 2
    print(f"    Exportiert nach: {template_path}")

    # Lese Template-Inhalt
    with open(template_path, 'r', encoding='utf-16') as f:
        template_content = f.read()

    # Extrahiere Header-Section aus Template
    # Suche nach Begin Section "FormHeader"
    header_match = re.search(r'Begin Section\s*[\r\n]+\s*Name ="Formularkopf".*?End', template_content, re.DOTALL)
    if header_match:
        print(f"    Header-Section gefunden ({len(header_match.group())} Zeichen)")
    else:
        print("    [!] Header-Section nicht gefunden")

    footer_match = re.search(r'Begin Section\s*[\r\n]+\s*Name ="Formularfu.*?End', template_content, re.DOTALL)
    if footer_match:
        print(f"    Footer-Section gefunden ({len(footer_match.group())} Zeichen)")
    else:
        print("    [!] Footer-Section nicht gefunden")

    # Exportiere Dashboard
    print("\n[3] Exportiere frm_N_DP_Dashboard...")
    app.SaveAsText(2, "frm_N_DP_Dashboard", EXPORT_PATH)
    print(f"    Exportiert nach: {EXPORT_PATH}")

    # Lese Dashboard-Inhalt
    with open(EXPORT_PATH, 'r', encoding='utf-16') as f:
        dashboard_content = f.read()

    print(f"    Dashboard-Länge: {len(dashboard_content)} Zeichen")

    # Zeige erste 2000 Zeichen zur Analyse
    print("\n[4] Dashboard-Struktur (Anfang):")
    print("-" * 50)
    print(dashboard_content[:2000])
    print("-" * 50)

    # Prüfe ob Header bereits existiert
    if 'Name ="Formularkopf"' in dashboard_content:
        print("\n    Dashboard hat bereits einen Formularkopf")
    else:
        print("\n    Dashboard hat KEINEN Formularkopf")

    # Modifiziere Dashboard-Inhalt
    print("\n[5] Modifiziere Dashboard...")

    # Setze Hintergrundfarbe im Detail-Bereich
    # Suche nach "Name ="Detailbereich"" und ändere BackColor
    modified = dashboard_content

    # Detail BackColor ändern
    detail_pattern = r'(Begin Section\s*[\r\n]+\s*Name ="Detailbereich".*?BackColor =)\d+'
    if re.search(detail_pattern, modified, re.DOTALL):
        modified = re.sub(detail_pattern, r'\g<1>14277081', modified, flags=re.DOTALL)
        print("    Detail BackColor auf 14277081 (grau) gesetzt")
    else:
        print("    [!] Detail BackColor Pattern nicht gefunden")

    # RecordSelectors, NavigationButtons etc.
    modified = re.sub(r'RecordSelectors =\d+', 'RecordSelectors =0', modified)
    modified = re.sub(r'NavigationButtons =\d+', 'NavigationButtons =0', modified)
    modified = re.sub(r'DividingLines =\d+', 'DividingLines =0', modified)

    # Speichere modifizierte Version
    modified_path = r"C:\Users\guenther.siegert\Documents\Access Bridge\temp_dashboard_modified.txt"
    with open(modified_path, 'w', encoding='utf-16') as f:
        f.write(modified)
    print(f"    Modifiziert gespeichert: {modified_path}")

    # Lösche altes Formular und importiere neues
    print("\n[6] Importiere modifiziertes Formular...")
    try:
        app.DoCmd.DeleteObject(2, "frm_N_DP_Dashboard")
        print("    Altes Formular gelöscht")
    except Exception as e:
        print(f"    [WARN] Löschen: {e}")

    time.sleep(0.5)

    try:
        app.LoadFromText(2, "frm_N_DP_Dashboard", modified_path)
        print("    [OK] Modifiziertes Formular importiert")
    except Exception as e:
        print(f"    [FEHLER] Import: {e}")
        # Versuche Original wiederherzustellen
        try:
            app.LoadFromText(2, "frm_N_DP_Dashboard", EXPORT_PATH)
            print("    Original wiederhergestellt")
        except:
            pass

    # Prüfung
    print("\n[7] Prüfe Ergebnis...")
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

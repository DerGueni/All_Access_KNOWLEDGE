"""
Apply Template Design to Dashboard V8
Korrekter Merge von Header/Footer aus Template
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
print("APPLY TEMPLATE DESIGN V8 - Korrekter Merge")
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

    # Pfade
    template_path = r"C:\Users\guenther.siegert\Documents\Access Bridge\temp_template.txt"
    dashboard_backup = r"C:\Users\guenther.siegert\Documents\Access Bridge\temp_dashboard_modified.txt"

    # Backup Dashboard falls nötig
    print("\n[2] Erstelle frisches Dashboard-Backup...")
    try:
        app.SaveAsText(2, "frm_N_DP_Dashboard", r"C:\Users\guenther.siegert\Documents\Access Bridge\dashboard_backup_fresh.txt")
        dashboard_backup = r"C:\Users\guenther.siegert\Documents\Access Bridge\dashboard_backup_fresh.txt"
        print("    [OK] Backup erstellt")
    except Exception as e:
        print(f"    Backup existiert bereits oder Fehler: {e}")

    # Lese Dateien
    print("\n[3] Lese Dateien...")
    with open(template_path, 'r', encoding='utf-16') as f:
        template_lines = f.readlines()
    with open(dashboard_backup, 'r', encoding='utf-16') as f:
        dashboard_lines = f.readlines()

    print(f"    Template: {len(template_lines)} Zeilen")
    print(f"    Dashboard: {len(dashboard_lines)} Zeilen")

    # Extrahiere Header aus Template (Zeile 1201-1577)
    # Begin FormHeader ... End (inklusive aller verschachtelten Controls)
    print("\n[4] Extrahiere Header aus Template...")
    header_lines = template_lines[1200:1577]  # 0-indexed: 1200 = Zeile 1201
    print(f"    Header: {len(header_lines)} Zeilen")

    # Extrahiere Footer aus Template (Zeile 1674 bis Ende der Section)
    print("\n[5] Extrahiere Footer aus Template...")
    footer_start = 1673  # 0-indexed für Zeile 1674
    footer_end = footer_start
    depth = 0
    for i in range(footer_start, len(template_lines)):
        line = template_lines[i].strip()
        if 'Begin' in line and 'Begin' == line.split()[0]:
            depth += 1
        elif line == 'End':
            depth -= 1
            if depth <= 0:
                footer_end = i + 1
                break

    footer_lines = template_lines[footer_start:footer_end]
    print(f"    Footer: {len(footer_lines)} Zeilen")

    # Finde Position im Dashboard für Header (vor Begin Section)
    print("\n[6] Finde Einfügepositionen im Dashboard...")
    section_pos = None
    for i, line in enumerate(dashboard_lines):
        if 'Begin Section' in line:
            section_pos = i
            break

    if section_pos is None:
        print("    [FEHLER] Begin Section nicht gefunden!")
    else:
        print(f"    Begin Section: Zeile {section_pos + 1}")

        # Finde Ende der Section (vor CodeBehindForm)
        section_end = None
        for i in range(section_pos, len(dashboard_lines)):
            if 'CodeBehindForm' in dashboard_lines[i]:
                section_end = i
                break

        if section_end:
            print(f"    CodeBehindForm: Zeile {section_end + 1}")

        # Baue neues Dashboard
        print("\n[7] Baue neues Dashboard...")
        new_dashboard = []

        # 1. Alles vor Begin Section
        new_dashboard.extend(dashboard_lines[:section_pos])
        print(f"    Teil 1 (vor Section): {len(dashboard_lines[:section_pos])} Zeilen")

        # 2. Header einfügen
        new_dashboard.extend(header_lines)
        print(f"    Teil 2 (Header): {len(header_lines)} Zeilen")

        # 3. Section (bis CodeBehindForm)
        section_content = dashboard_lines[section_pos:section_end]
        # Ändere BackColor im Section-Bereich auf grau
        for i, line in enumerate(section_content):
            if 'BackColor =' in line and i < 10:  # Nur erste BackColor im Section-Header
                section_content[i] = '            BackColor =14277081\n'
                break
        new_dashboard.extend(section_content)
        print(f"    Teil 3 (Section): {len(section_content)} Zeilen")

        # 4. Footer einfügen
        new_dashboard.extend(footer_lines)
        print(f"    Teil 4 (Footer): {len(footer_lines)} Zeilen")

        # 5. Rest (CodeBehindForm etc.)
        new_dashboard.extend(dashboard_lines[section_end:])
        print(f"    Teil 5 (Rest): {len(dashboard_lines[section_end:])} Zeilen")

        print(f"\n    Gesamt: {len(new_dashboard)} Zeilen")

        # Speichern
        merged_path = r"C:\Users\guenther.siegert\Documents\Access Bridge\dashboard_with_header_footer.txt"
        with open(merged_path, 'w', encoding='utf-16') as f:
            f.writelines(new_dashboard)
        print(f"\n[8] Gespeichert: {merged_path}")

        # Importieren
        print("\n[9] Importiere neues Dashboard...")
        try:
            app.DoCmd.DeleteObject(2, "frm_N_DP_Dashboard")
            print("    Altes Formular gelöscht")
        except:
            print("    Formular existiert nicht")

        time.sleep(0.5)

        try:
            app.LoadFromText(2, "frm_N_DP_Dashboard", merged_path)
            print("    [OK] Neues Formular importiert")
        except Exception as e:
            print(f"    [FEHLER] Import: {e}")
            # Wiederherstellen
            print("    Stelle Original wieder her...")
            try:
                app.LoadFromText(2, "frm_N_DP_Dashboard", dashboard_backup)
                print("    [OK] Original wiederhergestellt")
            except:
                pass

        # Prüfung
        print("\n[10] Prüfe Ergebnis...")
        try:
            app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)
            time.sleep(0.5)
            frm = app.Forms("frm_N_DP_Dashboard")
            print(f"    Detail BackColor: {frm.Section(0).BackColor}")
            try:
                print(f"    Header BackColor: {frm.Section(1).BackColor}, Height: {frm.Section(1).Height}")
            except Exception as e:
                print(f"    Header: {e}")
            try:
                print(f"    Footer BackColor: {frm.Section(2).BackColor}, Height: {frm.Section(2).Height}")
            except Exception as e:
                print(f"    Footer: {e}")
            app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
        except Exception as e:
            print(f"    [FEHLER] {e}")

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

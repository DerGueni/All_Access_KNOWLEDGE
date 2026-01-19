"""
Apply Template Design to Dashboard V9
Minimaler Header/Footer ohne komplexe Controls
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

# Minimaler Header (ohne Controls)
MINIMAL_HEADER = """        Begin FormHeader
            Height =1318
            BackColor =11671107
            Name ="Formularkopf"
        End
"""

# Minimaler Footer
MINIMAL_FOOTER = """        Begin FormFooter
            Height =347
            BackColor =11671107
            Name ="Formularfuss"
        End
"""

print("=" * 70)
print("APPLY TEMPLATE DESIGN V9 - Minimaler Header/Footer")
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

    # Backup Dashboard
    print("\n[2] Erstelle Backup...")
    dashboard_backup = r"C:\Users\guenther.siegert\Documents\Access Bridge\dashboard_backup_v9.txt"
    try:
        app.SaveAsText(2, "frm_N_DP_Dashboard", dashboard_backup)
        print("    [OK] Backup erstellt")
    except Exception as e:
        print(f"    [FEHLER] {e}")
        dashboard_backup = r"C:\Users\guenther.siegert\Documents\Access Bridge\dashboard_backup_fresh.txt"

    # Lese Dashboard
    print("\n[3] Lese Dashboard...")
    with open(dashboard_backup, 'r', encoding='utf-16') as f:
        dashboard_lines = f.readlines()
    print(f"    {len(dashboard_lines)} Zeilen")

    # Finde Begin Section
    section_pos = None
    for i, line in enumerate(dashboard_lines):
        if 'Begin Section' in line:
            section_pos = i
            break

    if section_pos is None:
        print("    [FEHLER] Begin Section nicht gefunden!")
    else:
        print(f"    Begin Section: Zeile {section_pos + 1}")

        # Finde Ende von Begin Form Block (vor Begin Section)
        # Und füge Header ein
        new_lines = []
        for i, line in enumerate(dashboard_lines):
            if i == section_pos:
                # Füge Header vor Section ein
                new_lines.append(MINIMAL_HEADER)
            new_lines.append(line)
            # Ändere BackColor im Detail-Bereich
            if i > section_pos and i < section_pos + 15 and 'BackColor =' in line:
                new_lines[-1] = '            BackColor =14277081\n'

        # Finde Ende der Section (vor CodeBehindForm oder End Form)
        code_pos = None
        for i, line in enumerate(new_lines):
            if 'CodeBehindForm' in line:
                code_pos = i
                break

        if code_pos:
            # Füge Footer vor CodeBehindForm ein
            final_lines = new_lines[:code_pos]
            final_lines.append(MINIMAL_FOOTER)
            final_lines.extend(new_lines[code_pos:])
        else:
            final_lines = new_lines

        print(f"    Neue Datei: {len(final_lines)} Zeilen")

        # Speichern
        merged_path = r"C:\Users\guenther.siegert\Documents\Access Bridge\dashboard_minimal_header.txt"
        with open(merged_path, 'w', encoding='utf-16') as f:
            f.writelines(final_lines)
        print(f"\n[4] Gespeichert: {merged_path}")

        # Zeige die ersten Zeilen um Header/Section zu prüfen
        print("\n    Prüfe Struktur:")
        for i, line in enumerate(final_lines[section_pos-2:section_pos+20], section_pos-1):
            print(f"    {i:4d}: {line.rstrip()[:70]}")

        # Importieren
        print("\n[5] Importiere...")
        try:
            app.DoCmd.DeleteObject(2, "frm_N_DP_Dashboard")
        except:
            pass

        time.sleep(0.5)

        try:
            app.LoadFromText(2, "frm_N_DP_Dashboard", merged_path)
            print("    [OK] Importiert")
        except Exception as e:
            print(f"    [FEHLER] {e}")
            # Wiederherstellen
            try:
                app.LoadFromText(2, "frm_N_DP_Dashboard", dashboard_backup)
                print("    Original wiederhergestellt")
            except:
                pass

        # Prüfung
        print("\n[6] Prüfe Ergebnis...")
        try:
            app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)
            time.sleep(0.5)
            frm = app.Forms("frm_N_DP_Dashboard")
            print(f"    Detail: {frm.Section(0).BackColor}")
            try:
                print(f"    Header: {frm.Section(1).BackColor}, H={frm.Section(1).Height}")
            except Exception as e:
                print(f"    Header: nicht vorhanden")
            try:
                print(f"    Footer: {frm.Section(2).BackColor}, H={frm.Section(2).Height}")
            except Exception as e:
                print(f"    Footer: nicht vorhanden")
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

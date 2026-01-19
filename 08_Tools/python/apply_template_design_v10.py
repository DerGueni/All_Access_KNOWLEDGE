"""
Apply Template Design to Dashboard V10
Korrekte Struktur für Header/Footer
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

# Header-Block (mit korrekter Einrückung - 8 Leerzeichen)
HEADER_BLOCK = """        Begin FormHeader
            Height =1318
            BackColor =11671107
            Name ="Formularkopf"
        End
"""

# Footer-Block (mit korrekter Einrückung - 8 Leerzeichen)
FOOTER_BLOCK = """        Begin FormFooter
            Height =347
            BackColor =11671107
            Name ="Formularfuss"
        End
"""

print("=" * 70)
print("APPLY TEMPLATE DESIGN V10")
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
    dashboard_backup = r"C:\Users\guenther.siegert\Documents\Access Bridge\dashboard_backup_v10.txt"
    try:
        app.SaveAsText(2, "frm_N_DP_Dashboard", dashboard_backup)
        print("    [OK] Backup erstellt")
    except Exception as e:
        print(f"    [!] Backup-Fehler, verwende existierendes: {e}")
        dashboard_backup = r"C:\Users\guenther.siegert\Documents\Access Bridge\dashboard_backup_v9.txt"

    # Lese Dashboard
    print("\n[3] Lese Dashboard...")
    with open(dashboard_backup, 'r', encoding='utf-16') as f:
        content = f.read()
        lines = content.split('\n')

    print(f"    {len(lines)} Zeilen")

    # Finde wichtige Positionen
    section_line = None
    code_line = None

    for i, line in enumerate(lines):
        if 'Begin Section' in line and section_line is None:
            section_line = i
        if 'CodeBehindForm' in line:
            code_line = i
            break

    print(f"    Begin Section: Zeile {section_line + 1}")
    print(f"    CodeBehindForm: Zeile {code_line + 1}")

    if section_line and code_line:
        # Finde die drei End-Zeilen vor CodeBehindForm
        # Zeile 529: End (Section), 530: End (Form), 531: End
        # Wir müssen Footer zwischen Section-End und Form-End einfügen

        # Baue neue Datei
        new_lines = []

        # Teil 1: Bis vor Begin Section
        new_lines.extend(lines[:section_line])

        # Header einfügen (ohne trailing newline da split das entfernt)
        header_lines = HEADER_BLOCK.strip().split('\n')
        new_lines.extend(header_lines)

        # Teil 2: Begin Section bis vor die letzten 3 Ends
        # Wir brauchen: End (Section), Footer, End (Form), End
        # Finde die Position der letzten End-Zeilen

        # Suche von code_line rückwärts nach den End-Zeilen
        end_positions = []
        for i in range(code_line - 1, max(0, code_line - 10), -1):
            if lines[i].strip() == 'End':
                end_positions.insert(0, i)

        print(f"    End-Positionen: {end_positions}")

        # Die Section endet bei end_positions[0]
        # Form endet bei end_positions[1]
        # Datei-End bei end_positions[2]

        if len(end_positions) >= 3:
            section_end = end_positions[0]  # Ende der Section
            form_end = end_positions[1]     # Ende von Begin Form

            # Section-Inhalt (mit BackColor-Änderung)
            section_content = lines[section_line:section_end + 1]
            for i, line in enumerate(section_content):
                if 'BackColor =' in line and i < 10:
                    section_content[i] = '            BackColor =14277081'
                    break
            new_lines.extend(section_content)

            # Footer einfügen
            footer_lines = FOOTER_BLOCK.strip().split('\n')
            new_lines.extend(footer_lines)

            # Rest (Form End, End, CodeBehindForm, VBA-Code)
            new_lines.extend(lines[form_end:])

            print(f"\n    Neue Struktur: {len(new_lines)} Zeilen")

            # Zeige relevanten Teil
            print("\n    Struktur um Section:")
            for i in range(section_line - 2, min(section_line + 8, len(new_lines))):
                print(f"    {i+1:4d}: {new_lines[i][:60]}")

            # Zeige Ende
            print("\n    Struktur Ende:")
            # Finde CodeBehindForm in new_lines
            for i, line in enumerate(new_lines):
                if 'CodeBehindForm' in line:
                    for j in range(max(0, i-8), i+2):
                        print(f"    {j+1:4d}: {new_lines[j][:60]}")
                    break

            # Speichern
            merged_path = r"C:\Users\guenther.siegert\Documents\Access Bridge\dashboard_v10.txt"
            with open(merged_path, 'w', encoding='utf-16') as f:
                f.write('\n'.join(new_lines))
            print(f"\n[4] Gespeichert: {merged_path}")

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
                except:
                    print("    Header: nicht vorhanden")
                try:
                    print(f"    Footer: {frm.Section(2).BackColor}, H={frm.Section(2).Height}")
                except:
                    print("    Footer: nicht vorhanden")
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

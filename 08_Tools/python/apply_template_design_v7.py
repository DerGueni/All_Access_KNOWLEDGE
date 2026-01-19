"""
Apply Template Design to Dashboard V7
Kopiert frm_N_template als Basis und fügt Dashboard-Controls hinzu
ODER: Verwendet SendKeys um Header/Footer zu aktivieren
"""
import win32com.client
import pythoncom
import subprocess
import time
from pathlib import Path

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (4).accdb"

# Design-Konstanten
BLUE_COLOR = 11671107
GRAY_COLOR = 14277081

def start_killer():
    p = Path(r"C:\Users\guenther.siegert\Documents\Access Bridge\DialogKillerPermanent.ps1")
    if p.exists():
        return subprocess.Popen(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", str(p), "-Minutes", "30", "-IntervalMs", "50"],
            creationflags=subprocess.CREATE_NO_WINDOW, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return None

print("=" * 70)
print("APPLY TEMPLATE DESIGN V7")
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

    # Ansatz: Exportiere Template und Dashboard, merge sie
    print("\n[2] Exportiere beide Formulare...")

    template_path = r"C:\Users\guenther.siegert\Documents\Access Bridge\temp_template.txt"
    dashboard_path = r"C:\Users\guenther.siegert\Documents\Access Bridge\temp_dashboard.txt"

    # Falls Template nicht existiert, exportieren
    if not Path(template_path).exists():
        app.SaveAsText(2, "frm_N_template", template_path)
        print(f"    Template exportiert")
    else:
        print(f"    Template bereits vorhanden")

    # Dashboard exportieren (frisch)
    app.SaveAsText(2, "frm_N_DP_Dashboard", dashboard_path)
    print(f"    Dashboard exportiert")

    # Lese beide Dateien
    with open(template_path, 'r', encoding='utf-16') as f:
        template_lines = f.readlines()

    with open(dashboard_path, 'r', encoding='utf-16') as f:
        dashboard_lines = f.readlines()

    print(f"\n    Template: {len(template_lines)} Zeilen")
    print(f"    Dashboard: {len(dashboard_lines)} Zeilen")

    # Finde wichtige Positionen im Template
    template_header_start = None
    template_header_end = None
    template_section_start = None
    template_footer_start = None
    template_footer_end = None

    for i, line in enumerate(template_lines):
        if 'Begin FormHeader' in line:
            template_header_start = i
        if template_header_start and template_header_end is None:
            if line.strip() == 'End' and i > template_header_start:
                # Check if this is the header end
                next_lines = ''.join(template_lines[i+1:i+5])
                if 'Begin Section' in next_lines or 'Begin FormFooter' in next_lines:
                    template_header_end = i + 1
        if 'Begin Section' in line and 'Name ="Detailbereich"' in ''.join(template_lines[i:i+10]):
            template_section_start = i
        if 'Begin FormFooter' in line:
            template_footer_start = i
            # Footer endet mit End + End (für Section End und Footer End)
            for j in range(i+1, min(i+50, len(template_lines))):
                if template_lines[j].strip() == 'End':
                    # Check ob nächste Zeile auch End ist oder Code beginnt
                    if j+1 < len(template_lines) and ('End' in template_lines[j+1] or 'CodeBehindForm' in template_lines[j+1]):
                        template_footer_end = j + 1
                        break

    print(f"\n    Template Header: {template_header_start}-{template_header_end}")
    print(f"    Template Section: {template_section_start}")
    print(f"    Template Footer: {template_footer_start}-{template_footer_end}")

    # Finde Position im Dashboard
    dashboard_section_start = None
    for i, line in enumerate(dashboard_lines):
        if 'Begin Section' in line:
            dashboard_section_start = i
            break

    print(f"    Dashboard Section: {dashboard_section_start}")

    if template_header_start and template_footer_start and dashboard_section_start:
        # Extrahiere Template Header (Zeilen template_header_start bis vor Begin Section)
        header_block = []
        in_header = False
        for i, line in enumerate(template_lines):
            if 'Begin FormHeader' in line:
                in_header = True
            if in_header:
                header_block.append(line)
                if 'Begin Section' in line:
                    break
                if i > template_header_start + 2 and line.strip() == 'End':
                    # Prüfe ob nächste Zeile Section beginnt
                    if i+1 < len(template_lines) and 'Begin Section' in template_lines[i+1]:
                        break

        # Extrahiere Template Footer
        footer_block = []
        in_footer = False
        for i, line in enumerate(template_lines):
            if 'Begin FormFooter' in line:
                in_footer = True
            if in_footer:
                footer_block.append(line)
                if line.strip() == 'End' and i > template_footer_start:
                    # Check if this is the actual end
                    break

        print(f"\n    Header Block: {len(header_block)} Zeilen")
        print(f"    Footer Block: {len(footer_block)} Zeilen")

        # Baue neues Dashboard zusammen
        # 1. Alles vor Begin Section
        # 2. Header Block
        # 3. Section (mit grauem Hintergrund)
        # 4. Footer Block
        # 5. Rest (Code etc.)

        new_dashboard = []

        # Teil 1: Vor Section
        for line in dashboard_lines[:dashboard_section_start]:
            new_dashboard.append(line)

        # Teil 2: Header einfügen
        for line in header_block:
            if 'Begin Section' not in line:
                new_dashboard.append(line)

        # Teil 3: Section mit grauem Hintergrund
        section_ended = False
        for i, line in enumerate(dashboard_lines[dashboard_section_start:], dashboard_section_start):
            modified_line = line
            if 'BackColor' in line and not section_ended:
                # Ersetze BackColor im Detail-Bereich
                modified_line = '            BackColor =14277081\n'
            new_dashboard.append(modified_line)

            # Finde Ende der Section (vor CodeBehindForm oder End Form)
            if 'CodeBehindForm' in line or (line.strip() == 'End' and i > dashboard_section_start + 10):
                # Füge Footer vor diesem Ende ein
                # Aber nur einmal
                if not section_ended and 'CodeBehindForm' in line:
                    section_ended = True
                    # Footer vor CodeBehindForm einfügen
                    new_dashboard = new_dashboard[:-1]  # Entferne letzte Zeile
                    for fline in footer_block:
                        new_dashboard.append(fline)
                    new_dashboard.append(line)  # CodeBehindForm wieder hinzufügen
                break

        # Rest des Dashboards (ab CodeBehindForm)
        found_code = False
        for line in dashboard_lines:
            if 'CodeBehindForm' in line:
                found_code = True
                continue
            if found_code:
                new_dashboard.append(line)

        print(f"\n    Neues Dashboard: {len(new_dashboard)} Zeilen")

        # Speichern
        merged_path = r"C:\Users\guenther.siegert\Documents\Access Bridge\temp_dashboard_merged.txt"
        with open(merged_path, 'w', encoding='utf-16') as f:
            f.writelines(new_dashboard)
        print(f"    Gespeichert: {merged_path}")

        # Importieren
        print("\n[3] Importiere neues Dashboard...")
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
            # Original wiederherstellen
            app.LoadFromText(2, "frm_N_DP_Dashboard", dashboard_path)
            print("    Original wiederhergestellt")

    # Prüfung
    print("\n[4] Prüfe Ergebnis...")
    try:
        app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)
        time.sleep(0.5)
        frm = app.Forms("frm_N_DP_Dashboard")
        print(f"    Detail BackColor: {frm.Section(0).BackColor}")
        try:
            print(f"    Header BackColor: {frm.Section(1).BackColor}")
        except:
            print("    Header: nicht vorhanden")
        try:
            print(f"    Footer BackColor: {frm.Section(2).BackColor}")
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

"""
Apply Template Design to Dashboard V5
Fügt Header und Footer aus Template ein
"""
import win32com.client
import pythoncom
import subprocess
import time
import uuid
from pathlib import Path

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (4).accdb"
EXPORT_PATH = r"C:\Users\guenther.siegert\Documents\Access Bridge\temp_dashboard.txt"
TEMPLATE_PATH = r"C:\Users\guenther.siegert\Documents\Access Bridge\temp_template.txt"

def start_killer():
    p = Path(r"C:\Users\guenther.siegert\Documents\Access Bridge\DialogKillerPermanent.ps1")
    if p.exists():
        return subprocess.Popen(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", str(p), "-Minutes", "30", "-IntervalMs", "50"],
            creationflags=subprocess.CREATE_NO_WINDOW, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return None

def generate_guid():
    """Generiert eine GUID im Access-Format"""
    g = uuid.uuid4().bytes
    hex_parts = []
    for i in range(0, 16, 4):
        chunk = g[i:i+4]
        hex_val = ''.join(f'{b:02x}' for b in chunk)
        hex_parts.append(f'0x{hex_val}')
    return hex_parts[0] + hex_parts[1] + hex_parts[2] + hex_parts[3]

print("=" * 70)
print("APPLY TEMPLATE DESIGN V5 - Header/Footer einfügen")
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

    # Exportiere Dashboard
    print("\n[2] Exportiere frm_N_DP_Dashboard...")
    app.SaveAsText(2, "frm_N_DP_Dashboard", EXPORT_PATH)

    # Lese Dashboard-Inhalt
    with open(EXPORT_PATH, 'r', encoding='utf-16') as f:
        dashboard_lines = f.readlines()

    print(f"    Dashboard: {len(dashboard_lines)} Zeilen")

    # Lese Template
    with open(TEMPLATE_PATH, 'r', encoding='utf-16') as f:
        template_lines = f.readlines()

    print(f"    Template: {len(template_lines)} Zeilen")

    # Finde Header im Template (Zeile 1201-1577)
    header_start = None
    header_end = None
    for i, line in enumerate(template_lines):
        if 'Begin FormHeader' in line:
            header_start = i
        if header_start and i > header_start and line.strip() == 'End' and template_lines[i-1].strip() == 'End':
            # Prüfe ob dies das Ende des Headers ist
            pass
        if header_start and 'Begin Section' in line:
            header_end = i
            break

    # Da die Struktur komplex ist, extrahieren wir nur einen vereinfachten Header
    print("\n[3] Erstelle vereinfachten Header und Footer...")

    # Vereinfachter Header
    header_section = """        Begin FormHeader
            CanGrow = NotDefault
            Height =1318
            BackColor =11671107
            Name ="Formularkopf"
            AlternateBackThemeColorIndex =1
            AlternateBackShade =95.0
            Begin
                Begin Label
                    OverlapFlags =93
                    TextFontCharSet =177
                    TextAlign =2
                    TextFontFamily =0
                    Left =26430
                    Top =390
                    Width =1365
                    Height =270
                    FontSize =10
                    LeftMargin =44
                    TopMargin =22
                    RightMargin =44
                    BottomMargin =22
                    BorderColor =8355711
                    ForeColor =16777215
                    Name ="lbl_N_Datum"
                    Caption ="=Date()"
                    ControlSource ="=Date()"
                    FontName ="Arial"
                    GridlineColor =10921638
                    LayoutCachedLeft =26430
                    LayoutCachedTop =390
                    LayoutCachedWidth =27795
                    LayoutCachedHeight =660
                    ThemeFontIndex =-1
                    ForeThemeColorIndex =1
                    ForeTint =100.0
                End
                Begin Label
                    OverlapFlags =93
                    TextFontCharSet =177
                    TextAlign =3
                    TextFontFamily =0
                    Left =26430
                    Top =60
                    Width =1365
                    Height =270
                    FontSize =10
                    LeftMargin =44
                    TopMargin =22
                    RightMargin =44
                    BottomMargin =22
                    BorderColor =8355711
                    ForeColor =16777215
                    Name ="lbl_N_Version"
                    Caption ="/1.55ANALYSETI"
                    FontName ="Arial"
                    GridlineColor =10921638
                    ThemeFontIndex =-1
                    ForeThemeColorIndex =1
                    ForeTint =100.0
                End
                Begin Label
                    OverlapFlags =93
                    TextFontCharSet =177
                    TextAlign =1
                    TextFontFamily =0
                    Left =200
                    Top =400
                    Width =5000
                    Height =500
                    FontSize =14
                    FontWeight =700
                    LeftMargin =44
                    TopMargin =22
                    RightMargin =44
                    BottomMargin =22
                    BorderColor =8355711
                    ForeColor =16777215
                    Name ="lbl_N_Titel"
                    Caption ="Planungs-Dashboard"
                    FontName ="Arial"
                    GridlineColor =10921638
                    ThemeFontIndex =-1
                    ForeThemeColorIndex =1
                    ForeTint =100.0
                End
            End
        End
"""

    # Vereinfachter Footer
    footer_section = """        Begin FormFooter
            Height =347
            BackColor =11671107
            Name ="Formularfuss"
            AlternateBackThemeColorIndex =1
            AlternateBackShade =95.0
        End
"""

    # Finde Position zum Einfügen
    # Header vor "Begin Section", Footer nach dem letzten "End" der Section
    section_line = None
    for i, line in enumerate(dashboard_lines):
        if 'Begin Section' in line:
            section_line = i
            break

    if section_line is None:
        print("    [FEHLER] 'Begin Section' nicht gefunden!")
    else:
        print(f"    'Begin Section' in Zeile {section_line + 1}")

        # Ändere Detail-Hintergrund
        for i in range(section_line, min(section_line + 20, len(dashboard_lines))):
            if 'BackColor' in dashboard_lines[i]:
                dashboard_lines[i] = '            BackColor =14277081\n'
                print(f"    Detail BackColor in Zeile {i + 1} geändert")
                break

        # Füge Header vor Section ein
        new_lines = dashboard_lines[:section_line]
        new_lines.append(header_section)
        new_lines.extend(dashboard_lines[section_line:])

        # Finde Ende der Section und füge Footer ein
        # Suche nach dem vorletzten "End" (das zum Form gehört)
        end_count = 0
        footer_insert = None
        for i in range(len(new_lines) - 1, -1, -1):
            line = new_lines[i].strip()
            if line == 'End':
                end_count += 1
                if end_count == 2:  # Zweites "End" von hinten
                    footer_insert = i
                    break

        if footer_insert:
            print(f"    Footer-Position: Zeile {footer_insert + 1}")
            new_lines.insert(footer_insert, footer_section)
        else:
            print("    [WARN] Footer-Position nicht gefunden")

        # Speichere modifizierte Version
        modified_path = r"C:\Users\guenther.siegert\Documents\Access Bridge\temp_dashboard_v5.txt"
        with open(modified_path, 'w', encoding='utf-16') as f:
            f.writelines(new_lines)
        print(f"    Gespeichert: {modified_path}")

        # Importiere
        print("\n[4] Importiere modifiziertes Formular...")
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
    print("\n[5] Prüfe Ergebnis...")
    try:
        app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # Design
        time.sleep(0.5)
        frm = app.Forms("frm_N_DP_Dashboard")
        print(f"    Detail BackColor: {frm.Section(0).BackColor}")

        try:
            print(f"    Header BackColor: {frm.Section(1).BackColor}, Height: {frm.Section(1).Height}")
        except:
            print("    Header: nicht vorhanden")

        try:
            print(f"    Footer BackColor: {frm.Section(2).BackColor}, Height: {frm.Section(2).Height}")
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

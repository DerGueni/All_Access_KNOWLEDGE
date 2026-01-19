"""
Apply Template Design to Dashboard V2
Aktiviert Header/Footer über DoCmd.RunCommand
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
print("APPLY TEMPLATE DESIGN V2 - Mit Header/Footer Aktivierung")
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

    # VBA-Code erstellen der Header/Footer aktiviert
    vba_code = '''
Public Sub ActivateHeaderFooter()
    On Error Resume Next

    ' Formular im Design öffnen
    DoCmd.OpenForm "frm_N_DP_Dashboard", acDesign

    ' Formular-Referenz
    Dim frm As Form
    Set frm = Forms!frm_N_DP_Dashboard

    ' Header/Footer über Design-Ansicht aktivieren
    ' acCmdFormHdrFtr = 36
    DoCmd.RunCommand 36

    ' Kurz warten
    DoEvents

    ' Jetzt Eigenschaften setzen
    frm.Section(acDetail).BackColor = 14277081      ' Grau
    frm.Section(acHeader).BackColor = 11671107      ' Blau
    frm.Section(acHeader).Height = 1318
    frm.Section(acFooter).BackColor = 11671107      ' Blau
    frm.Section(acFooter).Height = 347

    frm.RecordSelectors = False
    frm.NavigationButtons = False
    frm.DividingLines = False

    ' Speichern
    DoCmd.Save acForm, "frm_N_DP_Dashboard"
    DoCmd.Close acForm, "frm_N_DP_Dashboard", acSaveYes

    On Error GoTo 0
End Sub
'''

    print("\n[2] VBA-Funktion erstellen...")
    vbe = app.VBE
    proj = vbe.ActiveVBProject

    # Temporäres Modul
    temp_mod = None
    for c in proj.VBComponents:
        if c.Name == "mod_TempDesign":
            temp_mod = c
            break

    if not temp_mod:
        temp_mod = proj.VBComponents.Add(1)  # vbext_ct_StdModule
        temp_mod.Name = "mod_TempDesign"

    cm = temp_mod.CodeModule
    if cm.CountOfLines > 0:
        cm.DeleteLines(1, cm.CountOfLines)
    cm.AddFromString(vba_code)
    print("    [OK] VBA-Code eingefügt")

    time.sleep(0.5)

    print("\n[3] VBA-Funktion ausführen...")
    try:
        app.Run("ActivateHeaderFooter")
        print("    [OK] Header/Footer aktiviert")
    except Exception as e:
        print(f"    [FEHLER] {e}")

    time.sleep(1)

    # Temporäres Modul löschen
    try:
        proj.VBComponents.Remove(temp_mod)
        print("    Temp-Modul gelöscht")
    except:
        pass

    # Prüfung
    print("\n[4] Prüfe Ergebnis...")
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

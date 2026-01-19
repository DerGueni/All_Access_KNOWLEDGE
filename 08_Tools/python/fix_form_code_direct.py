"""
Fix Form Code direkt - Formular-Code hinzufuegen
"""
import win32com.client
import pythoncom
import subprocess
import time
from pathlib import Path

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (4).accdb"

FORM_CODE = '''Private Sub lstMA_DblClick(Cancel As Integer)
    If Not IsNull(Me!lstMA) Then DP_MA_Doppelklick Me!lstMA
End Sub

Private Sub lst_MA_Auswahl_DblClick(Cancel As Integer)
    If Not IsNull(Me!lst_MA_Auswahl) Then DP_MA_Aus_Anfrage Me!lst_MA_Auswahl
End Sub

Private Sub cmd_MA_Anfragen_Click()
    DP_Mitarbeiter_Anfragen
End Sub

Private Sub sub_lstAuftrag_Current()
    On Error Resume Next
    Dim subFrm As Form: Set subFrm = Me!sub_lstAuftrag.Form
    If Not subFrm.Recordset.EOF And Not subFrm.Recordset.BOF Then
        Dim VA_ID As Long, AnzTage_ID As Long, VADatum As Date
        VA_ID = Nz(subFrm!VA_ID, 0): AnzTage_ID = Nz(subFrm!AnzTage_ID, 0): VADatum = Nz(subFrm!Datum, Date)
        If VA_ID > 0 And AnzTage_ID > 0 Then DP_Auftrag_Ausgewaehlt VA_ID, AnzTage_ID, VADatum
    End If
    On Error GoTo 0
End Sub

Private Sub Form_Load()
    On Error Resume Next
    CurrentDb.Execute "DELETE FROM ztbl_MA_Schnellauswahl"
    Me!lst_MA_Auswahl.Requery: Me!lstMA.Requery
    On Error GoTo 0
End Sub

Private Sub btn_N_AnsichtWechseln_Click()
    On Error Resume Next
    Dim VA_ID As Long: VA_ID = DP_Get_CurrentVA_ID()
    DoCmd.Close acForm, Me.Name, acSaveNo
    If VA_ID > 0 Then DoCmd.OpenForm "frm_va_auftragstamm", , , "ID = " & VA_ID Else DoCmd.OpenForm "frm_va_auftragstamm"
    On Error GoTo 0
End Sub
'''

def start_killer():
    p = Path(r"C:\Users\guenther.siegert\Documents\Access Bridge\DialogKillerPermanent.ps1")
    if p.exists():
        return subprocess.Popen(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", str(p), "-Minutes", "30", "-IntervalMs", "50"],
            creationflags=subprocess.CREATE_NO_WINDOW, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return None

print("=" * 70)
print("FIX FORM CODE DIRECT")
print("=" * 70)

killer = start_killer()
print("[OK] DialogKiller")

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

    # Alle Formulare schliessen
    for form_name in ["frm_N_DP_Dashboard", "zsub_N_DP_Einsatzliste"]:
        try:
            app.DoCmd.Close(2, form_name, 2)
        except:
            pass
    time.sleep(1)

    # VBE holen
    vbe = app.VBE
    proj = vbe.ActiveVBProject

    if proj is None:
        raise Exception("VBProject ist None")

    # Pruefen ob Form_frm_N_DP_Dashboard existiert
    print("\n[2] Pruefe Form-Module...")
    form_module_exists = False
    for c in proj.VBComponents:
        print(f"    {c.Name} (Type: {c.Type})")
        if c.Name == "Form_frm_N_DP_Dashboard":
            form_module_exists = True

    if not form_module_exists:
        print("\n[3] Form_frm_N_DP_Dashboard existiert NICHT")
        print("    Oeffne Formular im Design-Modus und setze HasModule...")

        app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
        time.sleep(1)

        frm = app.Forms("frm_N_DP_Dashboard")
        print(f"    Aktueller HasModule-Status: {frm.HasModule}")

        if not frm.HasModule:
            frm.HasModule = True
            print("    HasModule auf True gesetzt")

        # Manuell ueber Ctrl+S speichern emulieren
        print("    Speichere mit DoCmd.Save...")
        try:
            app.DoCmd.Save(2, "frm_N_DP_Dashboard")
        except Exception as e:
            print(f"    [WARN] Save Fehler: {e}")

        time.sleep(2)

        # Schliessen und neu oeffnen
        try:
            app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
        except:
            pass
        time.sleep(1)

        # Nochmal pruefen
        print("\n[4] Pruefe nochmal Form-Module...")
        vbe = app.VBE
        proj = vbe.ActiveVBProject
        for c in proj.VBComponents:
            if "Dashboard" in c.Name or "frm_N_DP" in c.Name:
                print(f"    {c.Name} (Type: {c.Type})")
                if c.Name == "Form_frm_N_DP_Dashboard":
                    form_module_exists = True

    if form_module_exists:
        print("\n[5] Fuege Code zu Form_frm_N_DP_Dashboard hinzu...")
        for c in proj.VBComponents:
            if c.Name == "Form_frm_N_DP_Dashboard":
                cm = c.CodeModule
                print(f"    Aktuelle Zeilen: {cm.CountOfLines}")
                if cm.CountOfLines > 0:
                    cm.DeleteLines(1, cm.CountOfLines)
                cm.AddFromString(FORM_CODE)
                print(f"    [OK] Code hinzugefuegt ({cm.CountOfLines} Zeilen)")
                break
    else:
        print("\n[!] Form_frm_N_DP_Dashboard konnte nicht erstellt werden!")
        print("    Manueller Fix erforderlich:")
        print("    1. Oeffnen Sie frm_N_DP_Dashboard im Entwurfsmodus")
        print("    2. Klicken Sie auf 'Code anzeigen' oder druecken Sie Alt+F11")
        print("    3. Das Form-Modul wird automatisch erstellt")
        print("    4. Fuehren Sie dieses Script erneut aus")

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

"""
Fix via DB Module - Nutze das existierende Form_frm_N_DB_Dashboard Modul
und verbinde es mit dem Formular frm_N_DP_Dashboard

Das Problem: Access hat ein Formular-Modul mit falschem Namen erstellt.
Loesung: Den Code im existierenden Modul aktualisieren und pruefen
ob das Formular dieses Modul irgendwie nutzt.
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
print("FIX VIA DB MODULE")
print("=" * 70)
print("Aktualisiere Code in Form_frm_N_DB_Dashboard")
print("und versuche das Formular umzubenennen")
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
    print("\n[2] Schliesse alle Formulare...")
    for form_name in ["frm_N_DP_Dashboard", "frm_N_DB_Dashboard", "zsub_N_DP_Einsatzliste"]:
        try:
            app.DoCmd.Close(2, form_name, 2)
        except:
            pass
    time.sleep(0.5)

    # VBE holen und Code in Form_frm_N_DB_Dashboard aktualisieren
    print("\n[3] Aktualisiere Code in Form_frm_N_DB_Dashboard...")
    vbe = app.VBE
    proj = vbe.ActiveVBProject

    if proj is None:
        raise Exception("VBProject ist None")

    db_module = None
    for c in proj.VBComponents:
        if c.Name == "Form_frm_N_DB_Dashboard":
            db_module = c
            break

    if db_module:
        cm = db_module.CodeModule
        print(f"    Aktuelle Zeilen: {cm.CountOfLines}")
        if cm.CountOfLines > 0:
            cm.DeleteLines(1, cm.CountOfLines)
        cm.AddFromString(FORM_CODE)
        print(f"    [OK] Code aktualisiert ({cm.CountOfLines} Zeilen)")
    else:
        print("    [!] Form_frm_N_DB_Dashboard nicht gefunden!")

    # Pruefen ob frm_N_DB_Dashboard (mit DB) als Formular existiert
    print("\n[4] Pruefe ob Formular frm_N_DB_Dashboard existiert...")
    try:
        app.DoCmd.OpenForm("frm_N_DB_Dashboard", 1)  # acDesign
        print("    [!] frm_N_DB_Dashboard EXISTIERT!")
        print("    Das bedeutet: Es gibt zwei Formulare mit aehnlichem Namen")

        # Schliessen
        try:
            app.DoCmd.Close(2, "frm_N_DB_Dashboard", 2)
        except:
            pass

    except Exception as e:
        print("    frm_N_DB_Dashboard existiert NICHT")
        print("    Das Form-Modul ist verwaist und gehoert zu keinem Formular")

    # Jetzt das richtige Formular oeffnen und pruefen
    print("\n[5] Oeffne frm_N_DP_Dashboard...")
    try:
        app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
        time.sleep(1)

        frm = app.Forms("frm_N_DP_Dashboard")
        print(f"    HasModule: {frm.HasModule}")

        # Formular-Events setzen
        for i in range(frm.Controls.Count):
            ctl = frm.Controls(i)
            if ctl.Name == "lstMA":
                ctl.OnDblClick = "[Event Procedure]"
                print(f"    {ctl.Name}.OnDblClick = [Event Procedure]")
            if ctl.Name == "lst_MA_Auswahl":
                ctl.OnDblClick = "[Event Procedure]"
                ctl.ColumnCount = 4
                ctl.ColumnWidths = "0;2800;600;600"
                print(f"    {ctl.Name} Eigenschaften gesetzt")
            if ctl.Name == "cmd_MA_Anfragen":
                ctl.OnClick = "[Event Procedure]"
                print(f"    {ctl.Name}.OnClick = [Event Procedure]")

        # Speichern
        try:
            app.DoCmd.Save(2, "frm_N_DP_Dashboard")
        except:
            pass

        # Schliessen
        try:
            app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
        except:
            pass

    except Exception as e:
        print(f"    [FEHLER] {e}")

    print("\n" + "=" * 70)
    print("ANALYSE:")
    print("Das Form-Modul heisst 'Form_frm_N_DB_Dashboard' (mit DB)")
    print("Das Formular heisst 'frm_N_DP_Dashboard' (mit DP)")
    print("")
    print("LOESUNG 1: Formular umbenennen zu frm_N_DB_Dashboard")
    print("LOESUNG 2: Form-Modul umbenennen (nicht moeglich via VBA)")
    print("LOESUNG 3: Form-Modul loeschen und neu erstellen lassen")
    print("")
    print("EMPFEHLUNG: Umbenennen Sie das Formular in Access:")
    print("1. Oeffnen Sie den Navigationsbereich")
    print("2. Rechtsklick auf frm_N_DP_Dashboard")
    print("3. Umbenennen zu: frm_N_DB_Dashboard")
    print("4. Dann funktioniert der Code automatisch")
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

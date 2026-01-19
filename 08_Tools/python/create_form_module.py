"""
Erstelle Form-Modul durch Oeffnen des VBA-Editors im Formular-Kontext
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
print("CREATE FORM MODULE")
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
    time.sleep(0.5)

    # Loesche das manuell erstellte Class Module falls vorhanden
    print("\n[2] Loesche falsche Module...")
    vbe = app.VBE
    proj = vbe.ActiveVBProject
    if proj:
        modules_to_delete = []
        for c in proj.VBComponents:
            # Class Module (Type 2) mit dem Namen Form_frm_N_DP_Dashboard loeschen
            if c.Name == "Form_frm_N_DP_Dashboard" and c.Type == 2:
                modules_to_delete.append(c)
                print(f"    Markiert: {c.Name} (Class Module)")

        for m in modules_to_delete:
            try:
                proj.VBComponents.Remove(m)
                print(f"    [OK] Geloescht: {m.Name}")
            except Exception as e:
                print(f"    [!] Fehler: {e}")

    # Formular oeffnen und Code via Module-Property hinzufuegen
    print("\n[3] Oeffne frm_N_DP_Dashboard...")
    app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
    time.sleep(1)

    frm = app.Forms("frm_N_DP_Dashboard")

    # HasModule = True setzen
    frm.HasModule = True
    print("    HasModule = True")

    # Events setzen
    for i in range(frm.Controls.Count):
        ctl = frm.Controls(i)
        if ctl.Name == "lstMA":
            ctl.OnDblClick = "[Event Procedure]"
        if ctl.Name == "lst_MA_Auswahl":
            ctl.OnDblClick = "[Event Procedure]"
            ctl.ColumnCount = 4
            ctl.ColumnWidths = "0;2800;600;600"
        if ctl.Name == "cmd_MA_Anfragen":
            ctl.OnClick = "[Event Procedure]"
    print("    Events gesetzt")

    # Zugriff auf das Form-Modul ueber die Form.Module Eigenschaft
    print("\n[4] Zugriff auf Form.Module...")
    try:
        module = frm.Module
        print(f"    Module Name: {module.Name}")
        print(f"    Module Lines: {module.CountOfLines}")

        # Code hinzufuegen
        if module.CountOfLines > 0:
            module.DeleteLines(1, module.CountOfLines)

        module.AddFromString(FORM_CODE)
        print(f"    [OK] Code hinzugefuegt ({module.CountOfLines} Zeilen)")

    except Exception as e:
        print(f"    [FEHLER] {e}")
        print("    Form.Module nicht verfuegbar")

    # Speichern
    print("\n[5] Speichern...")
    try:
        app.DoCmd.Save(2, "frm_N_DP_Dashboard")
        print("    [OK] Gespeichert")
    except Exception as e:
        print(f"    [WARN] {e}")

    # Schliessen
    try:
        app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
    except:
        pass

    time.sleep(1)

    # Finale Pruefung
    print("\n[6] Finale Pruefung...")
    vbe = app.VBE
    proj = vbe.ActiveVBProject
    if proj:
        found = False
        for c in proj.VBComponents:
            if c.Name == "Form_frm_N_DP_Dashboard":
                found = True
                cm = c.CodeModule
                print(f"    [OK] Form_frm_N_DP_Dashboard ({cm.CountOfLines} Zeilen)")
                if cm.CountOfLines > 0:
                    print(f"    Erste Zeile: {cm.Lines(1, 1)}")

        if not found:
            print("    [!] Form_frm_N_DP_Dashboard nicht gefunden")

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

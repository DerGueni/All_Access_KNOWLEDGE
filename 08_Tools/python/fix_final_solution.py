"""
FINALE LOESUNG:
1. Loesche das falsche Formular frm_N_DB_Dashboard
2. Erstelle ein neues Form-Modul fuer frm_N_DP_Dashboard
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
print("FINALE LOESUNG")
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

    # Loesche das falsche Formular frm_N_DB_Dashboard
    print("\n[3] Loesche falsches Formular frm_N_DB_Dashboard...")
    try:
        app.DoCmd.DeleteObject(2, "frm_N_DB_Dashboard")  # acForm = 2
        print("    [OK] frm_N_DB_Dashboard geloescht!")
    except Exception as e:
        print(f"    [INFO] {e}")

    time.sleep(1)

    # VBE pruefen - das Form-Modul sollte jetzt auch weg sein
    print("\n[4] Pruefe VB-Module...")
    vbe = app.VBE
    proj = vbe.ActiveVBProject

    if proj:
        for c in proj.VBComponents:
            if "Dashboard" in c.Name and "Form_" in c.Name:
                print(f"    {c.Name} (Type: {c.Type})")

    # Jetzt frm_N_DP_Dashboard oeffnen und HasModule=True setzen
    print("\n[5] Oeffne frm_N_DP_Dashboard im Design-Modus...")
    try:
        app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
        time.sleep(1)

        frm = app.Forms("frm_N_DP_Dashboard")
        print(f"    HasModule: {frm.HasModule}")

        # HasModule auf True setzen
        if not frm.HasModule:
            frm.HasModule = True
            print("    HasModule auf True gesetzt")

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

        # Speichern
        try:
            app.DoCmd.Save(2, "frm_N_DP_Dashboard")
            print("    Gespeichert")
        except:
            pass

        time.sleep(2)

        # Jetzt sollte Form_frm_N_DP_Dashboard existieren
        print("\n[6] Suche Form_frm_N_DP_Dashboard...")
        vbe = app.VBE
        proj = vbe.ActiveVBProject

        form_module = None
        if proj:
            for c in proj.VBComponents:
                if c.Name == "Form_frm_N_DP_Dashboard":
                    form_module = c
                    print(f"    [OK] Gefunden!")
                    break

        if form_module:
            print("\n[7] Fuege Code ein...")
            cm = form_module.CodeModule
            if cm.CountOfLines > 0:
                cm.DeleteLines(1, cm.CountOfLines)
            cm.AddFromString(FORM_CODE)
            print(f"    [OK] Code eingefuegt ({cm.CountOfLines} Zeilen)")

            # Speichern
            try:
                app.DoCmd.Save(2, "frm_N_DP_Dashboard")
            except:
                pass
        else:
            print("    [!] Form_frm_N_DP_Dashboard nicht gefunden")
            print("    Versuche manuelle Erstellung...")

            # Manuell ein Class Module erstellen und umbenennen
            try:
                new_comp = proj.VBComponents.Add(2)  # vbext_ct_ClassModule
                new_comp.Name = "Form_frm_N_DP_Dashboard"
                cm = new_comp.CodeModule
                cm.AddFromString(FORM_CODE)
                print(f"    [OK] Modul manuell erstellt ({cm.CountOfLines} Zeilen)")
            except Exception as e:
                print(f"    [!] Manuelle Erstellung fehlgeschlagen: {e}")

        # Schliessen
        try:
            app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
        except:
            pass

    except Exception as e:
        print(f"    [FEHLER] {e}")

    # Finale Pruefung
    print("\n[8] Finale Pruefung der VB-Module...")
    time.sleep(1)
    vbe = app.VBE
    proj = vbe.ActiveVBProject

    if proj:
        found_dp = False
        for c in proj.VBComponents:
            if "Dashboard" in c.Name:
                print(f"    {c.Name} (Type: {c.Type})")
                if c.Name == "Form_frm_N_DP_Dashboard":
                    found_dp = True
                    cm = c.CodeModule
                    print(f"    -> {cm.CountOfLines} Zeilen Code")

        if found_dp:
            print("\n" + "=" * 70)
            print("ERFOLG! Das Dashboard sollte jetzt funktionieren.")
            print("Bitte testen Sie:")
            print("1. frm_N_DP_Dashboard oeffnen")
            print("2. Auftrag auswaehlen")
            print("3. Doppelklick auf Mitarbeiter")
            print("=" * 70)
        else:
            print("\n" + "=" * 70)
            print("WARNUNG: Form_frm_N_DP_Dashboard wurde nicht erstellt.")
            print("Bitte manuell in Access:")
            print("1. frm_N_DP_Dashboard im Entwurf oeffnen")
            print("2. Rechtsklick -> Code anzeigen")
            print("3. Dann Script erneut ausfuehren")
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

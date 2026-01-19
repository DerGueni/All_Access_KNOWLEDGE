"""
Loesche das falsche Form-Modul und arbeite mit dem richtigen Formular
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
print("LOESCHE FALSCHES MODUL UND FIXE RICHTIGES FORMULAR")
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

    # VBE holen
    vbe = app.VBE
    proj = vbe.ActiveVBProject

    if proj is None:
        raise Exception("VBProject ist None")

    # Falsche Module suchen und loeschen
    print("\n[2] Suche und loesche falsche Module...")
    modules_to_delete = []
    for c in proj.VBComponents:
        # Alles mit DB statt DP oder umbenannte Module
        if c.Name == "Form_frm_N_DB_Dashboard":
            modules_to_delete.append(c)
            print(f"    Markiert zum Loeschen: {c.Name}")
        elif c.Name == "Form_frm_N_DP_Dashboard":
            # Pruefen ob es das echte Form-Modul ist oder ein umbenanntes
            # Wenn Type = 100, dann ist es ein Form-Modul
            if c.Type == 100:
                # Pruefen ob es wirklich zum Formular gehoert
                # Wenn das Formular HasModule=False hat, dann ist es ein "verwaistes" Modul
                modules_to_delete.append(c)
                print(f"    Markiert zum Loeschen (verwaist): {c.Name}")

    for comp in modules_to_delete:
        try:
            proj.VBComponents.Remove(comp)
            print(f"    [OK] Geloescht: {comp.Name}")
        except Exception as e:
            print(f"    [WARN] Konnte nicht loeschen: {comp.Name} - {e}")

    time.sleep(1)

    # Alle Formulare schliessen
    print("\n[3] Schliesse alle Formulare...")
    for form_name in ["frm_N_DP_Dashboard", "zsub_N_DP_Einsatzliste"]:
        try:
            app.DoCmd.Close(2, form_name, 2)
        except:
            pass
    time.sleep(0.5)

    # Formular im Design-Modus oeffnen und HasModule=True setzen
    print("\n[4] Oeffne frm_N_DP_Dashboard und setze HasModule...")
    try:
        app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
        time.sleep(1)

        frm = app.Forms("frm_N_DP_Dashboard")
        print(f"    Aktuell HasModule: {frm.HasModule}")

        # HasModule auf True setzen - das erstellt das Form-Modul
        frm.HasModule = True
        print("    HasModule = True gesetzt")

        # ListBox-Events setzen
        for i in range(frm.Controls.Count):
            ctl = frm.Controls(i)
            if ctl.Name == "lstMA":
                ctl.OnDblClick = "[Event Procedure]"
                print("    lstMA.OnDblClick = [Event Procedure]")
            if ctl.Name == "lst_MA_Auswahl":
                ctl.OnDblClick = "[Event Procedure]"
                ctl.ColumnCount = 4
                ctl.ColumnWidths = "0;2800;600;600"
                print("    lst_MA_Auswahl Eigenschaften gesetzt")
            if ctl.Name == "cmd_MA_Anfragen":
                ctl.OnClick = "[Event Procedure]"
                print("    cmd_MA_Anfragen.OnClick = [Event Procedure]")

        # Speichern - das sollte das Form-Modul erstellen
        print("\n[5] Speichere Formular...")
        try:
            app.DoCmd.Save(2, "frm_N_DP_Dashboard")
            print("    [OK] Gespeichert")
        except Exception as e:
            print(f"    [WARN] {e}")

        time.sleep(2)

        # VBE neu holen
        vbe = app.VBE
        proj = vbe.ActiveVBProject

        # Jetzt sollte Form_frm_N_DP_Dashboard existieren
        print("\n[6] Suche Form_frm_N_DP_Dashboard...")
        form_module = None
        if proj:
            for c in proj.VBComponents:
                if c.Name == "Form_frm_N_DP_Dashboard":
                    form_module = c
                    print(f"    [OK] Gefunden: {c.Name}")
                    break

        if form_module:
            print("\n[7] Fuege Code ein...")
            cm = form_module.CodeModule
            if cm.CountOfLines > 0:
                cm.DeleteLines(1, cm.CountOfLines)
            cm.AddFromString(FORM_CODE)
            print(f"    [OK] Code eingefuegt ({cm.CountOfLines} Zeilen)")

            # Nochmal speichern
            try:
                app.DoCmd.Save(2, "frm_N_DP_Dashboard")
            except:
                pass
        else:
            print("\n[!] Form_frm_N_DP_Dashboard wurde NICHT erstellt!")
            print("    Das Speichern mit HasModule=True hat nicht funktioniert.")

        # Schliessen
        try:
            app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
        except:
            pass

    except Exception as e:
        print(f"    [FEHLER] {e}")
        import traceback
        traceback.print_exc()

    # Finale Pruefung
    print("\n[8] Finale Pruefung...")
    time.sleep(1)
    vbe = app.VBE
    proj = vbe.ActiveVBProject

    dp_found = False
    if proj:
        for c in proj.VBComponents:
            if "Dashboard" in c.Name and "Form_" in c.Name:
                print(f"    {c.Name} (Type: {c.Type})")
                if c.Name == "Form_frm_N_DP_Dashboard":
                    dp_found = True
                    cm = c.CodeModule
                    if cm.CountOfLines > 0:
                        print(f"    Code Zeilen: {cm.CountOfLines}")

    print("\n" + "=" * 70)
    if dp_found:
        print("FERTIG! Bitte testen Sie das Dashboard:")
        print("1. Formular oeffnen")
        print("2. Auftrag auswaehlen")
        print("3. Doppelklick auf Mitarbeiter")
    else:
        print("MANUELLE SCHRITTE ERFORDERLICH:")
        print("1. Oeffnen Sie frm_N_DP_Dashboard im Entwurfsmodus")
        print("2. Rechtsklick -> Code anzeigen (oder Alt+F11)")
        print("3. Das erstellt das Form-Modul automatisch")
        print("4. Fuehren Sie dieses Script erneut aus")
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

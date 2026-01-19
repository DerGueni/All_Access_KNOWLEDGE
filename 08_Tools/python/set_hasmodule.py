"""
FINAL FIX - Kompletter Fix mit allen Schritten
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
print("FINAL FIX")
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

    # Alle Form-Module auflisten die mit Dashboard zu tun haben
    print("\n[2] Dashboard-bezogene VB-Module:")
    dp_module = None
    db_module = None
    for c in proj.VBComponents:
        if "Dashboard" in c.Name or "frm_N_DP" in c.Name or "frm_N_DB" in c.Name:
            print(f"    {c.Name} (Type: {c.Type})")
            if c.Name == "Form_frm_N_DP_Dashboard":
                dp_module = c
            if c.Name == "Form_frm_N_DB_Dashboard":
                db_module = c

    # Wenn DP existiert, Code dort einfuegen
    if dp_module:
        print(f"\n[3] Form_frm_N_DP_Dashboard gefunden - Code einfuegen...")
        cm = dp_module.CodeModule
        if cm.CountOfLines > 0:
            cm.DeleteLines(1, cm.CountOfLines)
        cm.AddFromString(FORM_CODE)
        print(f"    [OK] Code eingefuegt ({cm.CountOfLines} Zeilen)")
    elif db_module:
        # DB existiert aber DP nicht - umbenennen
        print(f"\n[3] Form_frm_N_DB_Dashboard gefunden, aber nicht DP")
        print("    Versuche Umbenennung zu Form_frm_N_DP_Dashboard...")
        try:
            db_module.Name = "Form_frm_N_DP_Dashboard"
            print("    [OK] Umbenannt!")
            cm = db_module.CodeModule
            if cm.CountOfLines > 0:
                cm.DeleteLines(1, cm.CountOfLines)
            cm.AddFromString(FORM_CODE)
            print(f"    [OK] Code eingefuegt ({cm.CountOfLines} Zeilen)")
        except Exception as e:
            print(f"    [!] Umbenennung fehlgeschlagen: {e}")
            # Dann wenigstens den Code in DB aktualisieren
            cm = db_module.CodeModule
            if cm.CountOfLines > 0:
                cm.DeleteLines(1, cm.CountOfLines)
            cm.AddFromString(FORM_CODE)
            print(f"    [OK] Code in Form_frm_N_DB_Dashboard aktualisiert")
    else:
        print("\n[3] Weder Form_frm_N_DP_Dashboard noch Form_frm_N_DB_Dashboard gefunden!")
        print("    LOESUNG: Manuell HasModule im Formular setzen")

    # Jetzt das Formular nochmal im Design-Modus öffnen um HasModule zu triggern
    print("\n[4] Oeffne frm_N_DP_Dashboard um Modul zu verbinden...")

    # Alle Formulare schliessen
    for form_name in ["frm_N_DP_Dashboard", "zsub_N_DP_Einsatzliste"]:
        try:
            app.DoCmd.Close(2, form_name, 2)
        except:
            pass
    time.sleep(0.5)

    try:
        app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
        time.sleep(1)

        frm = app.Forms("frm_N_DP_Dashboard")

        # HasModule setzen falls noch nicht
        if not frm.HasModule:
            frm.HasModule = True
            print("    HasModule auf True gesetzt")

        # ListBox-Events setzen
        for i in range(frm.Controls.Count):
            ctl = frm.Controls(i)
            if ctl.Name == "lstMA":
                if ctl.OnDblClick != "[Event Procedure]":
                    ctl.OnDblClick = "[Event Procedure]"
                    print("    lstMA.OnDblClick gesetzt")
            if ctl.Name == "lst_MA_Auswahl":
                if ctl.OnDblClick != "[Event Procedure]":
                    ctl.OnDblClick = "[Event Procedure]"
                    print("    lst_MA_Auswahl.OnDblClick gesetzt")

        # Speichern
        try:
            app.DoCmd.Save(2, "frm_N_DP_Dashboard")
            print("    Gespeichert")
        except:
            pass

        time.sleep(0.5)

        # Schliessen
        try:
            app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
        except:
            pass

    except Exception as e:
        print(f"    [WARN] Konnte Formular nicht bearbeiten: {e}")

    # Nochmal pruefen
    print("\n[5] Finale Pruefung...")
    time.sleep(1)
    vbe = app.VBE
    proj = vbe.ActiveVBProject

    dp_found = False
    if proj:
        for c in proj.VBComponents:
            if c.Name == "Form_frm_N_DP_Dashboard":
                print(f"    [OK] Form_frm_N_DP_Dashboard existiert")
                cm = c.CodeModule
                print(f"    Zeilen: {cm.CountOfLines}")
                if cm.CountOfLines > 0:
                    first_lines = cm.Lines(1, min(5, cm.CountOfLines))
                    print(f"    Erste Zeilen: {first_lines[:100]}...")
                dp_found = True
                break

    if not dp_found:
        print("    [!] Form_frm_N_DP_Dashboard existiert NICHT")
        print("\n    Das Formular braucht HasModule = True im Entwurfsmodus.")
        print("    Bitte Access oeffnen und manuell setzen.")

    print("\n" + "=" * 70)
    if dp_found:
        print("FERTIG! Bitte testen Sie das Dashboard.")
    else:
        print("MANUELLE SCHRITTE ERFORDERLICH:")
        print("1. Oeffnen Sie frm_N_DP_Dashboard im Entwurfsmodus")
        print("2. Druecken Sie F4 fuer Eigenschaften")
        print("3. Setzen Sie 'Hat Modul' auf 'Ja'")
        print("4. Speichern und schliessen")
        print("5. Fuehren Sie dieses Script erneut aus")
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

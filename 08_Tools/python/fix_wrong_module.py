"""
Fix Wrong Module - Kopiere Code von Form_frm_N_DB_Dashboard nach Form_frm_N_DP_Dashboard
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
print("FIX WRONG MODULE")
print("=" * 70)
print("\nDas Problem: Code ist in Form_frm_N_DB_Dashboard (DB)")
print("          aber gebraucht wird Form_frm_N_DP_Dashboard (DP)")
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

    # Loesung 1: Code in Form_frm_N_DB_Dashboard hinzufuegen
    # (Das existierende falsch benannte Modul verwenden)
    print("\n[2] Suche Form_frm_N_DB_Dashboard...")

    db_module_found = False
    for c in proj.VBComponents:
        if c.Name == "Form_frm_N_DB_Dashboard":
            print(f"    Gefunden: {c.Name}")
            cm = c.CodeModule
            print(f"    Aktuelle Zeilen: {cm.CountOfLines}")

            # Existierenden Code lesen
            if cm.CountOfLines > 0:
                old_code = cm.Lines(1, cm.CountOfLines)
                print(f"    Code-Inhalt (erste 200 Zeichen): {old_code[:200]}...")

            # Code aktualisieren
            if cm.CountOfLines > 0:
                cm.DeleteLines(1, cm.CountOfLines)
            cm.AddFromString(FORM_CODE)
            print(f"    [OK] Code aktualisiert ({cm.CountOfLines} Zeilen)")
            db_module_found = True
            break

    if not db_module_found:
        print("    [!] Form_frm_N_DB_Dashboard nicht gefunden!")

    # Info ueber das richtige Modul
    print("\n[3] Suche Form_frm_N_DP_Dashboard (das richtige)...")
    dp_module_found = False
    for c in proj.VBComponents:
        if c.Name == "Form_frm_N_DP_Dashboard":
            print(f"    Gefunden: {c.Name}")
            dp_module_found = True
            cm = c.CodeModule
            if cm.CountOfLines > 0:
                cm.DeleteLines(1, cm.CountOfLines)
            cm.AddFromString(FORM_CODE)
            print(f"    [OK] Code hinzugefuegt ({cm.CountOfLines} Zeilen)")
            break

    if not dp_module_found:
        print("    [!] Form_frm_N_DP_Dashboard existiert NICHT!")
        print("\n    Das bedeutet: Das Formular hat HasModule=False")
        print("    oder das Formular-Modul wurde noch nie erstellt.")
        print("\n    LOESUNG: Umbenennen von Form_frm_N_DB_Dashboard zu Form_frm_N_DP_Dashboard")

        # Versuche umzubenennen
        print("\n[4] Versuche Umbenennung...")
        for c in proj.VBComponents:
            if c.Name == "Form_frm_N_DB_Dashboard":
                try:
                    c.Name = "Form_frm_N_DP_Dashboard"
                    print("    [OK] Umbenannt zu Form_frm_N_DP_Dashboard")
                except Exception as e:
                    print(f"    [!] Umbenennung fehlgeschlagen: {e}")
                    print("    Das ist normal - VBA Form-Module koennen nicht umbenannt werden.")
                    print("    Der Code muss ins richtige Formular eingefuegt werden.")
                break

    print("\n" + "=" * 70)
    print("ANALYSE ABGESCHLOSSEN")
    print("=" * 70)

    if db_module_found and not dp_module_found:
        print("\nDas Problem ist: Das Formular frm_N_DP_Dashboard hat kein")
        print("eigenes Code-Modul (HasModule=False), aber es gibt ein Modul")
        print("mit dem Namen Form_frm_N_DB_Dashboard das moeglicherweise")
        print("von einem aelteren/anderen Formular stammt.")
        print("\nNAECHSTE SCHRITTE:")
        print("1. Oeffnen Sie frm_N_DP_Dashboard im Entwurfsmodus")
        print("2. Setzen Sie HasModule auf 'Ja' in den Eigenschaften")
        print("3. Speichern Sie das Formular")
        print("4. Fuehren Sie dieses Script erneut aus")

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
